# CoreBusiness Tasks & Roadmap

## P0 - Perbaikan Kritis Sebelum Rilis Produksi

- [x] Hapus hard-coded key dan pindahkan inisialisasi API key ke Firebase Console Config (`google-services.json`).
- [x] Sediakan `AuthBloc` secara konsisten ke `LoginPage`.
- [x] Perbaiki registrasi Dependency Injection (DI) untuk `AuthRepositoryImpl` dan `SmartSetupBloc`.
- [x] Perbaiki crash evaluasi Firestore Security Rules pada database baru/kosong (saat inisialisasi setup bisnis pertama).
- [x] Perbaiki evaluasi relasi dan filter logic pada `HomeBloc`.
- [x] Perbaiki compile error type-folding di seluruh BLoC dan widget page.

## P1 - Integrasi Data & Backup Firebase

- [x] Buat `BusinessContextRepository` untuk memuat info bisnis aktif.
- [x] Hubungkan transaksi ke remote data source Firestore (menggantikan local storage sepenuhnya).
- [x] Hubungkan wallet page ke koleksi Firestore `/wallets`.
- [x] Perbaiki reload/caching pada `AppShell` agar meminimalisir Firestore read redundan (menghindari bottleneck 3000+ active users).
- [ ] Selesaikan integrasi tim pada `team_management_page.dart` (mengirim undangan via email/link ke Firestore `members`).
- [ ] Hubungkan katalog produk dan inventory ke subkoleksi `/products` dan `/inventory_items`.

## P2 - Peningkatan Resiliensi & Keamanan UI

- [ ] Tambahkan policy penanganan timeout jaringan dan auto-retry di tingkat repository.
- [ ] Tambahkan validasi dialog konfirmasi untuk aksi destruktif (seperti menghapus transaksi atau dompet).
- [ ] Tambahkan empty state di halaman wallet, katalog, dan riwayat transaksi jika data Firestore masih kosong.
- [ ] Pastikan validasi form input di sisi Flutter app sinkron dengan validasi tipe data di Firestore.

## P3 - Pembersihan & Kualitas Kode

- [x] Ganti teks branding lama di seluruh UI menjadi `CoreBusiness`.
- [ ] Hapus import yang tidak digunakan (*unused imports*) secara menyeluruh (menyelesaikan warnings dari analyze).
- [ ] Ganti fungsi `.withOpacity(...)` yang deprecated dengan `.withValues(alpha: ...)` pada file-file UI.
- [ ] Pecah file halaman setup bisnis (`smart_business_setup_page.dart`) dan `smart_setup_bloc.dart` yang sangat besar menjadi sub-widget modular.

## P4 - Pengujian Sistem (Test Coverage)

- [ ] Unit test untuk `AuthRepositoryImpl` (login, logout, active user check).
- [ ] Unit test untuk `SmartSetupBloc` (branching logic owner vs staff vs personal).
- [ ] Integration/smoke test untuk alur navigasi dari splash screen -> login -> onboarding -> dashboard.
