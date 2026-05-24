# CoreBusiness Requirements

## Functional Requirements

1. User bisa login dengan Google melalui Firebase Auth.
2. Setelah login, user diarahkan ke onboarding/setup flow (jika belum selesai) untuk membuat:
   - Profile user di Firestore,
   - Bisnis baru (workspace) di Firestore,
   - Membership dengan role `owner` pada bisnis tersebut,
   - Wallet default `Cash`,
   - Kategori sistem awal.
3. User bisa mencatat transaksi income dan expense.
4. User bisa melihat ringkasan saldo, income, expense, profit, dan transaksi terbaru pada dashboard.
5. User bisa mengelola wallet (nama, tipe, saldo).
6. User bisa mengelola kategori (nama, ikon, jenis income/expense).
7. User bisa mengelola produk dan inventory.
8. User bisa mengundang anggota tim ke bisnis dengan role tertentu (admin, staff) melalui link invite/email.
9. User hanya bisa mengakses data bisnis tempat dia menjadi member yang aktif.

## Non-Functional Requirements

- Target concurrency: 3000+ active users.
- Semua operasi write harus idempotent atau punya guard terhadap double submit.
- App harus tetap responsive di low-end device dengan caching context yang efisien (menghindari overload Firestore read).
- Semua fitur core harus bisa diuji tanpa UI.
- Data authorization wajib ditegakkan di database melalui Firestore Security Rules, bukan hanya di client.
- Network failure harus menghasilkan error yang bisa dipahami dan retryable.

## Reliability Requirements

- Tidak boleh ada hard-coded API key atau kredensial sensitif di repository.
- Tidak boleh ada business logic penting di widget.
- Tidak boleh ada controller, stream, timer, atau recognizer yang tidak di-dispose.
- Tidak boleh ada write/read permission yang longgar di Firestore Rules.

## Current Gaps & Status

- Firebase Auth dan Cloud Firestore terintegrasi penuh untuk pendaftaran, setup bisnis, wallet, kategori, dan transaksi.
- Firestore Security Rules telah diperkuat untuk mengamankan data per-bisnis dan mendukung pendaftaran awal yang aman di database kosong.
- Caching pada `BusinessContext` di `AppShell` diimplementasikan untuk mencegah overhead pembacaan Firestore pada setiap navigasi.
- Widget test lama sudah disesuaikan dan coverage tes navigasi perlu terus dikembangkan.
