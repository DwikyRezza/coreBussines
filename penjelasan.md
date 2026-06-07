# Penjelasan Lengkap Proyek CoreBusiness

Dokumen ini memberikan penjelasan menyeluruh dan detail mengenai proyek **CoreBusiness**, sebuah aplikasi manajemen keuangan pribadi & operasional bisnis tingkat produksi (production-grade) yang dibangun menggunakan Flutter dan Firebase.

---

## 1. Ringkasan Proyek & Tech Stack

**CoreBusiness** dirancang untuk membantu pemilik bisnis kecil-menengah mengelola transaksi keuangan (pemasukan/pengeluaran), memantau performa bisnis melalui dashboard analitik, melacak inventaris dan katalog, mengelola berbagai akun kas/bank (wallets), menjadwalkan kegiatan operasional, serta berkolaborasi dalam tim (multi-user) dengan pembagian peran (Role-Based Access Control).

### Tech Stack Utama:
*   **Framework:** Flutter (Dart SDK ^3.5.0)
*   **Arsitektur:** Clean Architecture dengan pendekatan *Feature-First* (layered architecture).
*   **State Management:** BLoC (`flutter_bloc`), `rxdart` untuk reactive streams, dan `setState` untuk form lokal.
*   **Navigation:** `go_router` untuk navigasi deklaratif dan penanganan otorisasi berbasis rute.
*   **Dependency Injection:** `get_it` sebagai service locator manual tanpa perlu codegen.
*   **Database & Backend:** Firebase Client SDK (Firebase Auth, Cloud Firestore sebagai database NoSQL utama, dan Firebase Storage untuk file upload).
*   **AI Integration:** Gemini API via `google_generative_ai` untuk memindai struk/tanda terima secara otomatis (AI Receipt Scanner).
*   **Visualisasi Data:** `fl_chart` untuk grafik analitik keuangan.
*   **Ekspor Data:** `pdf` dan `printing` untuk pembuatan dokumen laporan keuangan dalam format PDF.
*   **Keamanan Lokal:** `flutter_secure_storage` untuk menyimpan data sensitif dan `local_auth` untuk verifikasi biometrik/PIN.

---

## 2. Struktur Arsitektur Kode (Clean Architecture)

Proyek ini menerapkan pembagian folder berbasis fitur (*feature-first*):

*   `lib/core/`: Berisi infrastruktur bersama (*shared infrastructure*) yang digunakan di seluruh aplikasi (router, tema, utilitas, penyimpanan lokal, widget global, dan layanan inti).
*   `lib/features/`: Berisi modul-modul bisnis aplikasi yang terisolasi. Setiap fitur dibagi menjadi tiga layer sesuai prinsip Clean Architecture:
    1.  **Domain Layer:** Menyimpan aturan bisnis inti (entity, usecase, kontrak repository). Layer ini murni Dart dan tidak bergantung pada Flutter atau SDK eksternal.
    2.  **Data Layer:** Mengimplementasikan kontrak repository, model data (serialisasi JSON/Firestore), dan interaksi ke data source (Firestore, Local Storage, API eksternal).
    3.  **Presentation Layer:** Menangani UI (widget, halaman) dan pengelolaan state (BLoC/Cubit).

---

## 3. Penjelasan Detail Berkas di Root Direktori

Berikut adalah penjelasan berkas-berkas konfigurasi dan dokumentasi pada tingkat root proyek:

*   **[pubspec.yaml](file:///d:/Rezza/Self Project/corebussiness/pubspec.yaml):** Berkas konfigurasi utama Flutter yang mendefinisikan nama proyek, deskripsi, versi SDK Dart, dependensi pihak ketiga (Firebase, BLoC, GoRouter, dll.), aset gambar/ikon/lottie, serta dev dependensi untuk testing.
*   **[pubspec.lock](file:///d:/Rezza/Self Project/corebussiness/pubspec.lock):** Berkas pengunci versi dependensi yang memastikan seluruh tim development menggunakan versi library yang persis sama.
*   **[analysis_options.yaml](file:///d:/Rezza/Self Project/corebussiness/analysis_options.yaml):** Menentukan aturan analisis statis (*lint rules*) Dart untuk menjaga kualitas dan konsistensi penulisan kode.
*   **[Dockerfile](file:///d:/Rezza/Self Project/corebussiness/Dockerfile) & [compose.yaml](file:///d:/Rezza/Self Project/corebussiness/compose.yaml):** Digunakan untuk melakukan containerization aplikasi jika ingin dijalankan di lingkungan Docker (misalnya untuk deployment web/server backend).
*   **[.env](file:///d:/Rezza/Self Project/corebussiness/.env) & [.env.example](file:///d:/Rezza/Self Project/corebussiness/.env.example):** Menyimpan variabel lingkungan sensitif seperti API Keys Firebase dan Gemini API Key agar tidak terekspos di repositori Git.
*   **[firestore.rules](file:///d:/Rezza/Self Project/corebussiness/firestore.rules):** Aturan keamanan Firestore (*Firestore Security Rules*) untuk mengontrol hak akses baca/tulis data berbasis hak akses tim (role-based) langsung di tingkat server database.
*   **[storage.rules](file:///d:/Rezza/Self Project/corebussiness/storage.rules):** Aturan akses Firebase Storage untuk mengamankan berkas gambar struk atau berkas unggahan pengguna.
*   **[architecture.md](file:///d:/Rezza/Self Project/corebussiness/architecture.md):** Dokumentasi gaya arsitektur proyek, aturan dependensi antar layer, manajemen state, runtime boundaries, dan rencana refaktorisasi ke depan.
*   **[database.md](file:///d:/Rezza/Self Project/corebussiness/database.md):** Penjelasan skema database NoSQL Firestore (skema koleksi `/users`, `/businesses`, sub-koleksi `members`, `wallets`, `categories`, `transactions`, `notifications`, dan `activity_logs`).
*   **[design.md](file:///d:/Rezza/Self Project/corebussiness/design.md):** Panduan UX, prinsip visual (warna semantik untuk pemasukan dan pengeluaran), serta aturan interaksi form dan penanganan error.
*   **[rules.md](file:///d:/Rezza/Self Project/corebussiness/rules.md):** Aturan teknis rekayasa (*engineering rules*) yang mencakup lifecycle widget (dispose), batas Firestore, dan panduan kolaborasi dengan AI.
*   **[api.md](file:///d:/Rezza/Self Project/corebussiness/api.md):** Kontrak integrasi dengan Firebase Auth, alur Google Sign-In, kontrak transaksi setup bisnis atomik, dan kebijakan penanganan error klien.
*   **[requirements.md](file:///d:/Rezza/Self Project/corebussiness/requirements.md):** Persyaratan fungsional (fitur inti) dan non-fungsional aplikasi (target konkurensi, keandalan, dan penanganan kegagalan jaringan).
*   **[tasks.md](file:///d:/Rezza/Self Project/corebussiness/tasks.md):** Daftar tugas/todo list pengerjaan proyek.

---

## 4. Penjelasan Detail Direktori `lib/core` (Shared/Infrastruktur)

Folder ini berisi komponen global yang digunakan secara menyeluruh di aplikasi:

### A. Config (`lib/core/config/`)
*   **[app_config.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/config/app_config.dart):** Membaca dan menampung kredensial dari environment variable (Google Web Client ID, Gemini API Key, Firebase Project ID) dan memiliki metode validasi untuk lingkungan web.

### B. Dependency Injection (`lib/core/di/`)
*   **[service_locator.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/di/service_locator.dart):** Pusat konfigurasi seluruh dependensi aplikasi menggunakan `GetIt`. Semua datasource, repository, usecase, bloc, dan service didaftarkan di sini untuk keperluan *dependency injection*.

### C. Error Handling (`lib/core/error/`)
*   **[exceptions.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/error/exceptions.dart):** Menampung kelas *custom exception* seperti `ServerException` (kegagalan server) dan `CacheException` (kegagalan penyimpanan lokal).
*   **[failures.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/error/failures.dart):** Kelas representasi error/kegagalan yang dikembalikan ke UI menggunakan tipe data `Either` dari dartz (seperti `ServerFailure`, `CacheFailure`).
*   **[error_mapper.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/error/error_mapper.dart):** Mengubah objek `Failure` atau Firestore exception menjadi pesan teks berbahasa Indonesia yang mudah dipahami pengguna di layar aplikasi.

### D. Router (`lib/core/router/`)
*   **[app_router.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/router/app_router.dart):** Konfigurasi `GoRouter` yang mendefinisikan semua rute halaman (Splash, Login, Setup Bisnis, Home/Dashboard, Transaksi, Analitik, Pengaturan, dll.) lengkap dengan pengecekan autentikasi pengguna dan otorisasi peran (*role-based redirect*).
*   **[router_notifier.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/router/router_notifier.dart):** Memantau perubahan status autentikasi (`AuthRepository`) dan status kunci aplikasi (`AppLockController`) untuk memicu pengalihan rute secara otomatis.

### E. Security (`lib/core/security/`)
*   **[permission_policy.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/security/permission_policy.dart):** Berisi logika penentuan hak akses pengguna (Owner, Admin, Staff) terhadap fitur-fitur spesifik di aplikasi (misalnya: Staff tidak bisa menghapus bisnis atau mengubah member).

### F. Services (`lib/core/services/`)
*   **[app_lock_controller.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/services/app_lock_controller.dart):** Mengontrol alur penguncian aplikasi menggunakan PIN keamanan atau biometrik jika aplikasi sedang tidak aktif (App Lock).
*   **[business_context_service.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/services/business_context_service.dart):** Menyimpan dan memperbarui data bisnis aktif secara lokal guna mengoptimalkan kinerja pembacaan database Firestore agar tidak terjadi pembacaan berulang-ulang (*excessive reads*).
*   **[pdf_report_service.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/services/pdf_report_service.dart):** Layanan backend lokal untuk mengekspor rekap transaksi menjadi dokumen laporan berbentuk PDF yang siap dicetak/dibagikan.
*   **[scan_usage_limiter.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/services/scan_usage_limiter.dart):** Membatasi jumlah pemindaian struk berbasis AI per hari untuk menjaga penggunaan kuota API Gemini tetap efisien.

### G. Shell (`lib/core/shell/`)
*   **[app_shell.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/shell/app_shell.dart):** Halaman shell navigasi utama dengan menu navigasi bawah (*Bottom Navigation Bar* seperti Beranda, Riwayat, Analitik, Jadwal, dan Pengaturan).

### H. Storage (`lib/core/storage/`)
*   **[local_storage_service.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/storage/local_storage_service.dart):** Membungkus SharedPreferences untuk membaca dan menyimpan konfigurasi lokal sederhana (mode tema, id bisnis aktif, caching status user).

### I. Theme (`lib/core/theme/`)
*   Menampung konfigurasi visual aplikasi:
    *   **[app_colors.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/theme/app_colors.dart):** Defini palet warna aplikasi (Primary, Secondary, Success/Income, Error/Expense, Neutral).
    *   **[app_spacing.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/theme/app_spacing.dart):** Ukuran padding, margin, dan radius standard.
    *   **[app_typography.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/theme/app_typography.dart):** Konfigurasi text style berdasarkan Google Fonts.
    *   **[app_theme.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/theme/app_theme.dart) & [theme.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/theme/theme.dart):** Objek `ThemeData` untuk tema terang (*light*) dan gelap (*dark*).
    *   **[theme_controller.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/theme/theme_controller.dart):** Mengatur perubahan tema aplikasi secara dinamis dan menyimpannya di SharedPreferences.

### J. Use Cases (`lib/core/usecases/`)
*   **[usecase.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/usecases/usecase.dart):** Kontrak dasar (*base class*) untuk mendefinisikan UseCase yang mewakili satu aksi bisnis spesifik aplikasi.

### K. Utils (`lib/core/utils/`)
*   **[activity_logger.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/utils/activity_logger.dart):** Logger lokal untuk mencatat audit aktivitas pengguna (misal: "Menghapus transaksi Rp100.000").
*   **[debouncer.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/utils/debouncer.dart):** Utilitas untuk mencegah pemanggilan berulang dalam rentang waktu yang sangat cepat (misal: membatasi request saat pengguna sedang mengetik kata kunci pencarian).
*   **[formatters.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/utils/formatters.dart):** Formatter untuk memformat angka menjadi mata uang rupiah (IDR) serta memformat objek `DateTime` ke string tanggal lokal Indonesia.
*   **[responsive_helper.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/utils/responsive_helper.dart):** Menyediakan helper responsivitas UI untuk membedakan tampilan mobile, tablet, atau desktop.

### L. Widgets (`lib/core/widgets/`)
*   **[core_app_bar.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/widgets/core_app_bar.dart):** Widget AppBar kustom yang konsisten di semua halaman aplikasi.
*   **[security_verification_helper.dart](file:///d:/Rezza/Self Project/corebussiness/lib/core/widgets/security_verification_helper.dart):** Helper UI untuk menampilkan dialog atau halaman verifikasi PIN/biometrik saat mengakses area sensitif aplikasi.

---

## 5. Penjelasan Detail Direktori `lib/features` (Fitur Aplikasi)

Setiap fitur dikelompokkan dalam satu folder modular:

### 1. Analytics (`lib/features/analytics/`)
Fitur visualisasi grafik perkembangan keuangan bisnis.
*   **Domain:** `analytics_entities.dart` mendefinisikan ringkasan data statistik analitik.
*   **Presentation:**
    *   `analytics_bloc.dart`: Menghitung data keuangan bulanan/mingguan dari repository transaksi untuk dipetakan ke dalam format grafik.
    *   `analytics_page.dart` & `analytics_overview_page.dart`: Halaman utama grafik pemasukan/pengeluaran dan profit bisnis.
    *   `financial_overview_page.dart`: Rincian mendalam performa neraca arus kas bisnis.
    *   `smart_ai_insights_page.dart`: Layar rekomendasi bisnis pintar berbasis AI Gemini.
    *   `report_export_page.dart`: Menu untuk memilih filter tanggal laporan lalu memicu ekspor PDF.
    *   `business_score_page.dart`: Memberikan skor kesehatan bisnis berdasarkan parameter rasio keuangan.
    *   `financial_goals_page.dart`: Menetapkan dan memantau progres target keuangan bisnis (tabungan/anggaran).

### 2. Auth (`lib/features/auth/`)
Sistem pendaftaran dan otentikasi akun pengguna.
*   **Domain:** `user_entity.dart` (data model pengguna) dan kontrak `auth_repository.dart` serta usecase `sign_in_with_google.dart`.
*   **Data:** `auth_remote_datasource.dart` (penghubung ke Firebase Auth & Google Sign-In) dan `auth_repository_impl.dart`.
*   **Presentation:** `auth_bloc.dart` untuk loading login, logout, dan pengecekan sesi. `login_page.dart` adalah halaman masuk utama aplikasi menggunakan Google Sign-In.

### 3. Business (`lib/features/business/`)
*   **Presentation:** `business_portfolio_page.dart` menampilkan info profil entitas bisnis yang aktif saat ini serta daftar workspace bisnis yang dimiliki oleh pengguna.

### 4. Catalog (`lib/features/catalog/`)
*   **Presentation:** `catalog_page.dart` digunakan untuk mengelola daftar katalog produk, harga jual, dan stok awal produk dagang.

### 5. Home (`lib/features/home/`)
Halaman beranda/dashboard utama setelah masuk aplikasi.
*   **Domain & Data:** Menyediakan endpoint pengumpulan ringkasan cepat data saldo kas saat ini, total transaksi hari ini, dan status kelengkapan setup profil bisnis.
*   **Presentation:**
    *   `home_bloc.dart`: Mengatur pemuatan data dashboard secara real-time.
    *   `home_page.dart`: Layar beranda utama yang menampilkan kartu ringkasan saldo, pintasan aksi cepat (scan struk, tambah transaksi), dan grafik singkat.
    *   `business_setup_score_card.dart` & `home_widgets.dart`: Komponen kartu petunjuk untuk mendorong owner melengkapi data bisnis/tim pada awal pendaftaran.

### 6. Inventory (`lib/features/inventory/`)
*   **Presentation:** `inventory_overview_page.dart` memantau keluar masuknya barang, jumlah stok menipis, serta nilai total aset inventaris barang yang dimiliki.

### 7. Notifications (`lib/features/notifications/`)
Sistem peringatan sistem dan notifikasi internal tim.
*   **Data:** `notification_local_datasource.dart`, `notification_remote_datasource.dart` ( Firestore sync ), dan impl repository.
*   **Services:**
    *   `notification_service.dart`: Integrasi dengan push notification lokal ponsel (`flutter_local_notifications`).
    *   `weekly_summary_notification_service.dart`: Menghasilkan rangkuman notifikasi rekap mingguan bisnis secara berkala.
*   **Presentation:** `recent_alerts_page.dart` menampilkan daftar notifikasi masuk dan `notifications_empty_page.dart` jika tidak ada notifikasi baru.

### 8. Onboarding (`lib/features/onboarding/`)
Alur pengenalan dan konfigurasi awal saat pertama kali membuka aplikasi.
*   **Domain:** `onboarding_slide.dart` dan `smart_setup_policy.dart` (kebijakan validasi setup data bisnis).
*   **Presentation:**
    *   `splash_page.dart`: Halaman splash screen pembuka untuk mengecek status login & onboarding.
    *   `onboarding_page.dart`: Slider panduan visual aplikasi untuk pengguna baru.
    *   `smart_business_setup_page.dart`: Layar setup bisnis baru. Menjalankan transaksi database Firestore secara atomik untuk membuat bisnis, workspace, wallet default (Cash), dan kategori pertama.

### 9. Schedule (`lib/features/schedule/`)
Penjadwalan aktivitas bisnis (misal tenggat waktu pembayaran, jadwal shift, dll.).
*   **Data & Domain:** `schedule_local_datasource.dart` menyimpan jadwal operasional di penyimpanan internal perangkat dan `schedule_model.dart` representasi data jadwal.
*   **Presentation:** `schedule_page.dart` untuk menampilkan kalender/list jadwal dan `add_schedule_page.dart` untuk form penambahan jadwal baru.

### 10. Search (`lib/features/search/`)
*   **Presentation:** `search_page.dart` menyediakan form pencarian cepat riwayat transaksi secara real-time dan `search_empty_page.dart` untuk penanganan data tidak ditemukan.

### 11. Settings (`lib/features/settings/`)
Pusat konfigurasi akun dan profil bisnis.
*   **Domain & Data:** Kelas model `app_lock_settings.dart` dan `dashboard_card_entity.dart` serta repositori enkripsi penyimpanan PIN aplikasi.
*   **Presentation:**
    *   `settings_page.dart`: Menu utama pengaturan.
    *   `dashboard_customize_page.dart`: Mengatur susunan/visibilitas kartu ringkasan di dashboard utama sesuai kebutuhan pengguna.
    *   `team_management_page.dart` & `invite_team_member_sheet.dart`: Mengelola daftar tim bisnis dan mengundang staf baru.
    *   `app_lock_page.dart` & `security_settings_page.dart`: Konfigurasi penguncian keamanan PIN/Biometrik.
    *   `category_management_page.dart` & `tag_management_page.dart`: Kustomisasi kategori & tag transaksi pemasukan/pengeluaran.
    *   `activity_log_page.dart`: Audit log riwayat aktivitas tim dalam mengedit data bisnis.
    *   `theme_settings_page.dart`: Memilih tema aplikasi (Terang, Gelap, atau Sistem).
    *   `edit_profile_page.dart`, `about_page.dart`, `help_faq_page.dart`, `sync_settings_page.dart`, dan `empty_states_overview_page.dart` untuk menu pelengkap lainnya.

### 12. Transactions (`lib/features/transactions/`)
Modul transaksi yang merupakan jantung dari aplikasi keuangan ini.
*   **Domain:** `transaction_entities.dart` mendefinisikan tipe transaksi (income/expense), status pembayaran, kategori, dompet, dll. Use case `add_transaction.dart` dan `delete_transaction.dart`.
*   **Data:**
    *   `ai_receipt_scanner.dart`: Menghubungi Gemini API untuk menganalisis gambar foto struk belanja, mendeteksi harga total, nama toko, tanggal transaksi secara otomatis.
    *   `transaction_local_datasource.dart` & `transaction_remote_datasource.dart`: Menyimpan transaksi offline/online ke Firestore dan Firebase Storage.
*   **Presentation:**
    *   `transaction_bloc.dart` & `filter_bloc.dart`: Mengelola flow mutasi data transaksi, proses upload struk, dan pemfilteran kategori/tanggal.
    *   `add_transaction_page.dart` & `edit_transaction_page.dart`: Form pencatatan transaksi.
    *   `history_page.dart`: Menampilkan daftar semua riwayat transaksi secara lengkap beserta filter.
    *   `transaction_detail_page.dart` & `invoice_detail_page.dart`: Rincian lengkap suatu transaksi keuangan beserta file lampiran struk.
    *   `scan_receipt_intro_page.dart`, `camera_scan_page.dart`, `ai_detection_page.dart`, dan `scan_receipt_result_page.dart`: Alur pemindaian foto struk dengan kamera lalu diproses oleh kecerdasan buatan (AI OCR) sebelum disimpan menjadi form transaksi.

### 13. Wallets (`lib/features/wallets/`)
*   **Presentation:** `wallets_page.dart` mengelola akun keuangan bisnis (seperti saldo Kas Fisik, Rekening Bank Mandiri, saldo E-Wallet OVO/GoPay, dsb.) beserta riwayat mutasi antar wallet.

---

## 6. Berkas Uji Coba & Alat Pembantu (`test/` & `tool/`)

*   `test/`: Berisi berkas unit test dan widget test untuk memastikan aturan keamanan bisnis dan alur navigasi berjalan dengan benar:
    *   `test/core/security/permission_policy_test.dart`: Menguji pembatasan hak akses pengguna.
    *   `test/features/onboarding/domain/smart_setup_policy_test.dart` & `test/features/onboarding/bloc/onboarding_bloc_test.dart`: Menguji alur startup bisnis baru.
*   `tool/`: Berisi skrip pembantu developer:
    *   `tool/fix_const_errors.dart`: Script untuk memperbaiki penulisan const di seluruh codebase secara otomatis.
    *   `tool/fix_dark_mode.dart`: Script untuk merapikan aturan tema warna gelap pada UI widget.
