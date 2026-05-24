# CoreBusiness

CoreBusiness adalah aplikasi Flutter untuk operasional bisnis UMKM: manajemen transaksi keuangan, pengelolaan kas/dompet, katalog produk, stok inventory, analitik, dan kolaborasi tim multi-user.

## Quick Start

1. Pastikan Anda telah menaruh file konfigurasi Firebase:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
2. Konfigurasikan file `.env` di root project Anda dengan menyertakan Google Client ID & Gemini API Key:
   ```env
   GOOGLE_WEB_CLIENT_ID=your-google-web-client-id
   GOOGLE_ANDROID_CLIENT_ID=your-google-android-client-id
   GEMINI_API_KEY=your-gemini-api-key
   ```
3. Jalankan aplikasi:
   ```powershell
   flutter pub get
   flutter run
   ```

## Project Documents

- `requirements.md` - Requirement fungsional, non-fungsional, dan reliabilitas sistem.
- `design.md` - Arah desain produk dan panduan visual/UX.
- `architecture.md` - Struktur layer, dependency rule, dan batasan runtime.
- `database.md` - Struktur skema Cloud Firestore dan Security Rules.
- `api.md` - Kontrak database writes, onboarding transaction, dan alur autentikasi.
- `rules.md` - Aturan engineering untuk kolaborasi manusia dan AI.
- `tasks.md` - Backlog prioritas teknis dan status progres pengerjaan.

## Architecture

Project memakai feature-first layered architecture:

```text
lib/
  core/
    config/      - Konfigurasi aplikasi & env
    di/          - Dependency Injection (GetIt)
    error/       - Model & handler error/failure
    router/      - Routing GoRouter & Route guards
    shell/       - Layout utama (AppShell) dengan caching context
    theme/       - Konfigurasi warna & visual theme
    utils/       - Helper & Logger aktivitas
  features/
    auth/        - Autentikasi Google & Firebase Auth
    onboarding/  - Setup awal bisnis (Smart Business Setup)
    home/        - Dashboard utama & skor kelengkapan bisnis
    transactions/ - Catat transaksi & scan struk belanja AI (Gemini)
    wallets/     - Pengelolaan kas & dompet bisnis
    settings/    - Pengaturan profil & manajemen tim (karyawan)
```

Dependency utama mengalir ke dalam:
```text
presentation -> domain -> data contract
```
Business logic tidak boleh bergantung pada UI. Firebase SDK hanya boleh diakses melalui Remote Data Sources di data layer.

## Firestore Security Rules

Aturan keamanan Firestore diatur dalam file `firestore.rules` di root project. Aturan ini memastikan:
1. Keamanan berbasis penyewa (Tenant) - pengguna hanya bisa melihat data dari bisnis di mana mereka terdaftar sebagai member.
2. Akses bertingkat - fitur owner-only seperti menghapus bisnis atau mengelola tim terlindungi dengan aman.
3. Ketahanan inisialisasi - transaksi setup bisnis baru tetap aman tanpa risiko crash evaluasi aturan saat database dalam kondisi kosong.

Untuk melakukan deploy rules secara manual, salin isi file `firestore.rules` lalu publish di tab Rules menu Firestore pada Firebase Console.
