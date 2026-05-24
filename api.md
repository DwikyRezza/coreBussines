# CoreBusiness Database Write & Integration Contracts

CoreBusiness menggunakan Firebase Client SDK untuk berinteraksi langsung dengan Firebase Auth, Cloud Firestore, dan Firebase Storage.

## Kredensial & Inisialisasi

Firebase diinisialisasi pada `main.dart` menggunakan:
```dart
await Firebase.initializeApp();
```
Konfigurasi Client API Key dimuat secara lokal lewat file konfigurasi platform (`google-services.json` untuk Android dan `GoogleService-Info.plist` untuk iOS). API Key eksternal seperti Google Web/Android Client ID (untuk Google Sign-In) dan Gemini API Key dimuat via environment variable `.env`.

---

## Alur Integrasi Firebase Auth & Google Sign-In

1. **Google Sign-In Flow:**
   - Client memicu Google Sign-In UI menggunakan Google Client ID.
   - Mengambil token `idToken` dan `accessToken`.
2. **Firebase Auth Sign-In:**
   - Melakukan autentikasi ke Firebase menggunakan `GoogleAuthProvider.credential(idToken: ..., accessToken: ...)`.
3. **Bootstrap Onboarding Flow:**
   - Setelah masuk, status user diperiksa pada dokumen `/users/{userId}` di Firestore.
   - Jika `onboarding_completed` bernilai `false` atau dokumen belum ada, user diarahkan ke `SmartBusinessSetupPage`.
   - Di step onboarding, client mengeksekusi transaksi Firestore (`runTransaction`) untuk menjamin konsistensi data awal bisnis.

---

## Kontrak Transaksi Setup Bisnis (Onboarding)

Semua operasi berikut ditulis secara atomik menggunakan **Firestore Transaction** di `SmartSetupBloc`:

1. **Membuat Bisnis Baru:**
   - Path: `/businesses/{businessId}`
   - Data wajib: `name`, `owner_id`, `business_type`, `business_size`, `currency`, `timezone`, `enabled_features`, `created_at`, `updated_at`.
2. **Membuat Member Pertama (Owner):**
   - Path: `/businesses/{businessId}/members/{userId}`
   - Data wajib: `user_id`, `name`, `email`, `photo_url`, `role: 'owner'`, `joined_at`, `updated_at`, `status: 'active'`.
3. **Membuat Dompet Utama (Cash):**
   - Path: `/businesses/{businessId}/wallets/{walletId}`
   - Data wajib: `name`, `type`, `balance`, `updated_at`.
4. **Memperbarui Dokumen User:**
   - Path: `/users/{userId}`
   - Data wajib: `onboarding_completed: true`, `active_business_id: businessId`, `updated_at`.

---

## Client Error Handling

- **Jaringan Bermasalah:** Ditampilkan sebagai kegagalan koneksi dengan tombol retry.
- **Firebase Auth Errors:** Mengarahkan user kembali ke layar login dengan pesan error yang jelas (misal: akun ditangguhkan atau dibatalkan).
- **Firestore Permission Denied:** Ditampilkan sebagai kegagalan akses data ("Anda tidak memiliki izin untuk mengakses atau mengubah data ini").
- **Double Submit Guard:** Tombol aksi pada form harus dinonaktifkan (`isLoading = true`) selama operasi Firestore berlangsung.
