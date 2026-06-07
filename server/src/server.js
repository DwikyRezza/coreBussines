const http = require("node:http");
const crypto = require("node:crypto");

const port = Number(process.env.PORT || 8080);
const apiKey = process.env.GEMINI_API_KEY || "";
const firebaseProjectId = process.env.FIREBASE_PROJECT_ID || "";
const model = process.env.GEMINI_MODEL || "gemini-2.0-flash";
const maxBodyBytes = 12 * 1024 * 1024;
const rateWindowMs = 60 * 1000;
const rateLimit = Number(process.env.RATE_LIMIT_PER_MINUTE || 20);
const requestsByIp = new Map();
let firebaseCertificates = {};
let firebaseCertificatesExpireAt = 0;

const prompt = `
Kamu adalah asisten akuntansi. Ekstrak data dari foto struk.
Balas hanya JSON valid dengan format:
{"title":"...","amount":0,"isIncome":false,"category":"...","note":"..."}
Kategori: Makanan, Transportasi, Belanja, Hiburan, Tagihan, Kesehatan,
Pendidikan, atau Lainnya. amount harus angka dan isIncome harus false.
`;

function sendJson(response, status, value) {
  response.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "Cache-Control": "no-store",
    "X-Content-Type-Options": "nosniff",
  });
  response.end(JSON.stringify(value));
}

function clientIp(request) {
  return String(
    request.headers["x-real-ip"] || request.socket.remoteAddress || "unknown",
  ).trim();
}

function isRateLimited(ip) {
  const now = Date.now();
  const current = requestsByIp.get(ip);
  if (!current || now - current.startedAt >= rateWindowMs) {
    requestsByIp.set(ip, { startedAt: now, count: 1 });
    return false;
  }
  current.count += 1;
  return current.count > rateLimit;
}

async function readJson(request) {
  const chunks = [];
  let total = 0;
  for await (const chunk of request) {
    total += chunk.length;
    if (total > maxBodyBytes) {
      const error = new Error("Payload terlalu besar.");
      error.statusCode = 413;
      throw error;
    }
    chunks.push(chunk);
  }
  return JSON.parse(Buffer.concat(chunks).toString("utf8"));
}

function decodeJwtPart(value) {
  return JSON.parse(Buffer.from(value, "base64url").toString("utf8"));
}

async function getFirebaseCertificates() {
  if (
    Object.keys(firebaseCertificates).length > 0 &&
    Date.now() < firebaseCertificatesExpireAt
  ) {
    return firebaseCertificates;
  }

  const response = await fetch(
    "https://www.googleapis.com/robot/v1/metadata/x509/" +
      "securetoken@system.gserviceaccount.com",
    { signal: AbortSignal.timeout(5000) },
  );
  if (!response.ok) {
    throw new Error("Firebase certificates unavailable.");
  }

  firebaseCertificates = await response.json();
  const cacheControl = response.headers.get("cache-control") || "";
  const maxAge = Number(cacheControl.match(/max-age=(\d+)/)?.[1] || 300);
  firebaseCertificatesExpireAt = Date.now() + maxAge * 1000;
  return firebaseCertificates;
}

async function verifyFirebaseIdToken(request) {
  const authorization = String(request.headers.authorization || "");
  if (!authorization.startsWith("Bearer ")) {
    const error = new Error("Autentikasi diperlukan.");
    error.statusCode = 401;
    throw error;
  }

  const token = authorization.slice(7);
  const parts = token.split(".");
  if (parts.length !== 3) {
    const error = new Error("Token autentikasi tidak valid.");
    error.statusCode = 401;
    throw error;
  }

  let header;
  let payload;
  try {
    header = decodeJwtPart(parts[0]);
    payload = decodeJwtPart(parts[1]);
  } catch {
    const error = new Error("Token autentikasi tidak valid.");
    error.statusCode = 401;
    throw error;
  }

  const nowSeconds = Math.floor(Date.now() / 1000);
  const validClaims =
    header.alg === "RS256" &&
    typeof header.kid === "string" &&
    payload.aud === firebaseProjectId &&
    payload.iss === `https://securetoken.google.com/${firebaseProjectId}` &&
    typeof payload.sub === "string" &&
    payload.sub.length > 0 &&
    payload.sub.length <= 128 &&
    Number(payload.exp) > nowSeconds &&
    Number(payload.iat) <= nowSeconds;
  if (!validClaims) {
    const error = new Error("Sesi login tidak valid atau sudah berakhir.");
    error.statusCode = 401;
    throw error;
  }

  const certificates = await getFirebaseCertificates();
  const certificate = certificates[header.kid];
  const signatureValid =
    typeof certificate === "string" &&
    crypto.verify(
      "RSA-SHA256",
      Buffer.from(`${parts[0]}.${parts[1]}`),
      certificate,
      Buffer.from(parts[2], "base64url"),
    );
  if (!signatureValid) {
    const error = new Error("Token autentikasi tidak valid.");
    error.statusCode = 401;
    throw error;
  }
  return payload;
}

function parseGeminiJson(text) {
  const cleaned = text
    .trim()
    .replace(/^```(?:json)?\s*/i, "")
    .replace(/\s*```$/, "");
  const value = JSON.parse(cleaned);
  if (
    typeof value.title !== "string" ||
    typeof value.amount !== "number" ||
    !Number.isFinite(value.amount)
  ) {
    throw new Error("Respons AI tidak memiliki data transaksi yang valid.");
  }
  return {
    title: value.title.slice(0, 200),
    amount: value.amount,
    isIncome: false,
    category: String(value.category || "Lainnya").slice(0, 80),
    note: String(value.note || "").slice(0, 2000),
  };
}

async function scanReceipt(body) {
  const imageBase64 = body.imageBase64;
  const mimeType = body.mimeType;
  if (
    typeof imageBase64 !== "string" ||
    imageBase64.length === 0 ||
    !["image/jpeg", "image/png", "image/webp"].includes(mimeType)
  ) {
    const error = new Error("Gambar struk tidak valid.");
    error.statusCode = 400;
    throw error;
  }

  const endpoint =
    `https://generativelanguage.googleapis.com/v1beta/models/` +
    `${encodeURIComponent(model)}:generateContent?key=${encodeURIComponent(apiKey)}`;
  const upstream = await fetch(endpoint, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents: [
        {
          parts: [
            { text: prompt },
            { inlineData: { mimeType, data: imageBase64 } },
          ],
        },
      ],
      generationConfig: { responseMimeType: "application/json" },
    }),
    signal: AbortSignal.timeout(55000),
  });

  if (!upstream.ok) {
    throw new Error(`Gemini gagal memproses struk (${upstream.status}).`);
  }
  const payload = await upstream.json();
  const text = payload?.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!text) throw new Error("Gemini tidak mengembalikan hasil scan.");
  return parseGeminiJson(text);
}

const server = http.createServer(async (request, response) => {
  if (request.method === "GET" && request.url === "/healthz") {
    return sendJson(response, 200, { status: "ok" });
  }
  if (request.method !== "POST" || request.url !== "/ai/scan") {
    return sendJson(response, 404, { message: "Endpoint tidak ditemukan." });
  }
  if (!apiKey) {
    return sendJson(response, 503, {
      message: "Layanan scan AI belum dikonfigurasi.",
    });
  }

  try {
    if (!firebaseProjectId) {
      const error = new Error("Firebase project belum dikonfigurasi.");
      error.statusCode = 503;
      throw error;
    }
    const user = await verifyFirebaseIdToken(request);
    if (isRateLimited(`${user.sub}:${clientIp(request)}`)) {
      return sendJson(response, 429, {
        message: "Terlalu banyak permintaan. Silakan coba lagi sebentar.",
      });
    }
    const body = await readJson(request);
    const result = await scanReceipt(body);
    return sendJson(response, 200, result);
  } catch (error) {
    const status = Number(error.statusCode || 502);
    return sendJson(response, status, {
      message: status >= 500
        ? "Gagal memproses struk. Silakan coba kembali."
        : error.message,
    });
  }
});

server.listen(port, "0.0.0.0", () => {
  console.log(`CoreBusiness AI proxy listening on ${port}`);
});
