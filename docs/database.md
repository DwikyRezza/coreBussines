# CoreBusiness Cloud Firestore Database Design

Dokumen ini mendokumentasikan prinsip desain dan struktur skema Cloud Firestore untuk CoreBusiness.

## Prinsip Desain Firestore

- **Tenant Isolation (`businesses`):** Setiap bisnis/UMKM berdiri sebagai dokumen mandiri di bawah `/businesses/{businessId}`. Semua subkoleksi operasional diletakkan secara hierarkis di bawah dokumen bisnis ini untuk kemudahan partisi data dan kemudahan penerapan Firestore Security Rules.
- **Role-Based Access Control (`members`):** Keanggotaan dan izin akses user ditentukan dari subkoleksi `/members/{userId}`. Role yang tersedia: `'owner'`, `'admin'`, dan `'staff'`. Firestore Rules membaca dokumen ini untuk menentukan hak akses user terhadap data bisnis bersangkutan.
- **Denormalisasi untuk Kinerja:** Data pengguna dasar (seperti nama, email, dan avatar) didenormalisasikan di dalam dokumen `/members/{userId}` untuk menghindari N+1 queries saat menampilkan tim di UI.
- **Audit Trail yang Immutable (`activity_logs`):** Log aktivitas ditulis di tingkat bisnis untuk pelacakan audit. Aturan keamanan melarang keras update dan delete pada koleksi ini.

## Detail Struktur Skema & Dokumen

### 1. Koleksi `/users/{userId}` (Root)
Menyimpan informasi global user dari Firebase Auth.

```json
{
  "onboarding_completed": true,
  "active_business_id": "b1b2c3d4-...",
  "full_name": "Dwiky Rezza",
  "avatar_url": "https://lh3.googleusercontent.com/...",
  "updated_at": "Timestamp"
}
```

### 2. Koleksi `/businesses/{businessId}` (Root)
Menyimpan detail operasional tenant bisnis.

```json
{
  "name": "Warung Kopi Rezza",
  "owner_id": "user123_auth_uid",
  "business_type": "F&B",
  "business_size": "medium",
  "currency": "IDR",
  "timezone": "Asia/Jakarta",
  "details": {
    "description": "Premium coffee shop and roastery.",
    "address": "Jl. Sudirman No. 45, Jakarta",
    "whatsapp": "628123456789",
    "email": "contact@warungrezza.com"
  },
  "enabled_features": ["dashboard", "transactions", "wallets", "analytics", "schedule"],
  "created_at": "Timestamp",
  "updated_at": "Timestamp"
}
```

### Sub-koleksi Bisnis:

#### A. `/members/{userId}`
Relasi anggota tim ke bisnis.
* **Security Rule:** Create/Update/Delete hanya bisa dilakukan oleh `'owner'`. Anggota lain hanya bisa membaca list.

#### B. `/wallets/{walletId}`
Dompet atau akun keuangan bisnis.
* **Security Rule:** Anggota terdaftar bisa membaca dan menulis transaksi. Penghapusan wallet dibatasi untuk `'owner'`.

#### C. `/categories/{categoryId}`
Kategori transaksi kustom per-bisnis.
* **Security Rule:** Anggota terdaftar bisa membaca. Pengeditan kategori sistem dibatasi untuk `'owner'`/`'admin'`.

#### D. `/transactions/{transactionId}`
Dokumen transaksi bisnis.
* **Security Rule:** Anggota terdaftar bisa membuat transaksi. Transaksi hanya bisa diperbarui oleh user yang membuatnya.

---

## Mekanisme Firestore Security Rules

Aturan keamanan (`firestore.rules`) ditulis dengan prinsip aman secara bawaan (*secure-by-default*).

### Evaluasi yang Aman Terhadap Database Kosong
Saat user mendaftar pertama kali, dokumen bisnis dan member belum tersimpan di Firestore. Untuk menghindari rule crash ketika membaca dokumen non-existent via `get()`, aturan pendaftaran menggunakan logika guard:
```javascript
(!exists(/databases/$(database)/documents/businesses/$(businessId)) && request.resource.data.role == 'owner')
```
Logika ini memastikan bahwa jika bisnis belum terdaftar di database, user diperbolehkan mendaftarkan dirinya sebagai owner awal bisnis tersebut secara aman.

### Cara Mempublikasikan Rules
1. Salin seluruh isi file [firestore.rules](file:///d:/Rezza/Self%20Project/corebussiness/firestore.rules).
2. Masuk ke **[Firebase Console](https://console.firebase.google.com/)** -> pilih project CoreBusiness.
3. Masuk ke menu **Firestore Database** -> klik tab **Rules**.
4. Tempelkan seluruh isi rules ke editor, lalu klik **Publish**.
