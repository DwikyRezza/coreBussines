# CoreBusiness Deployment To AWS EC2

## Architecture

- EC2 runs Docker Engine and Docker Compose.
- `web` serves the Flutter Web release through Nginx.
- `ai-proxy` keeps `GEMINI_API_KEY` outside the browser bundle.
- `ai-proxy` verifies the signed Firebase ID token before invoking Gemini.
- Firebase Auth, Firestore, and Storage remain managed Firebase services.
- HTTPS should terminate at an Application Load Balancer (recommended) or a
  reverse proxy with a valid certificate.

## Minimum Production Infrastructure

- Ubuntu 24.04 LTS EC2 instance.
- At least `t3.small` for building on the instance. For `t3.micro`, build the
  images in CI and pull them from ECR instead.
- Security group:
  - SSH `22` only from the administrator IP.
  - HTTP `80` only from the ALB security group.
  - HTTPS `443` exposed by the ALB.
- Route 53 DNS record pointing to the ALB.
- ACM certificate attached to the ALB HTTPS listener.
- ALB target health check: `/healthz`.

## Firebase Preparation

1. Create/register a Firebase Web app for CoreBusiness.
2. Put its public web configuration in `.env.production`.
3. Add the production domain to Firebase Authentication authorized domains.
4. Add the production domain to the Google OAuth Web Client authorized
   JavaScript origins.
5. Deploy the reviewed Firestore and Storage Rules separately.
6. Enable Firebase App Check for Web before public launch.

Firebase Web configuration is visible in browser applications by design. Data
security must rely on Auth, App Check, Firestore Rules, Storage Rules, and API
restrictions. `GEMINI_API_KEY` is server-only and must never be used as a
Flutter `--dart-define`.

## EC2 Installation

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker "$USER"
newgrp docker
docker compose version
```

Clone the repository and prepare environment configuration:

```bash
cp .env.production.example .env.production
nano .env.production
chmod 600 .env.production
```

Build and start:

```bash
docker compose --env-file .env.production build
docker compose --env-file .env.production up -d
docker compose ps
curl --fail http://127.0.0.1/healthz
```

## Release Update

```bash
git pull --ff-only
docker compose --env-file .env.production build
docker compose --env-file .env.production up -d --remove-orphans
docker image prune -f
```

Do not use `git reset --hard` or place `.env.production` in Git.

## Runtime Verification

1. Open `/healthz` and confirm HTTP 200.
2. Open `/` and refresh a nested route such as `/settings`.
3. Test Google Sign-In from the production HTTPS domain.
4. Create a manual transaction and upload a receipt.
5. Scan a receipt after login and confirm `/api/ai/scan` succeeds with a
   Firebase ID token and never exposes the Gemini key.
6. Test direct navigation to a route forbidden for the active role.
7. Inspect browser console and network requests for errors.

## Logs

```bash
docker compose logs --tail=200 web
docker compose logs --tail=200 ai-proxy
docker compose logs -f ai-proxy
```

The AI proxy deliberately avoids logging receipt data and Gemini credentials.

## Rollback

Keep the previous Git revision or image tags available:

```bash
git switch --detach <previous-commit>
docker compose --env-file .env.production build
docker compose --env-file .env.production up -d
```

For stronger production rollback, build versioned images in CI, push them to
ECR, and change Compose image tags rather than building directly on EC2.

## Remaining Production Recommendations

- Move builds to GitHub Actions/CodeBuild and store images in ECR.
- Store `GEMINI_API_KEY` in AWS Secrets Manager or SSM Parameter Store.
- Add AWS WAF rate limiting in front of `/api/`.
- Add centralized logs and alarms.
- Add CloudFront only after validating Flutter service-worker cache behavior.
