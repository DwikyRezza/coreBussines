# CoreBusiness Requirements

## Functional Requirements

1. User bisa login dengan Google melalui Supabase Auth.
2. Setelah login, user otomatis punya:
   - profile,
   - business default,
   - membership role `owner`,
   - wallet `Cash`,
   - kategori sistem awal.
3. User bisa mencatat transaksi income dan expense.
4. User bisa melihat ringkasan saldo, income, expense, profit, dan transaksi terbaru.
5. User bisa mengelola wallet.
6. User bisa mengelola kategori.
7. User bisa mengelola produk dan inventory.
8. User bisa mengundang anggota tim dengan role.
9. User hanya bisa mengakses data bisnis tempat dia menjadi member.

## Non-Functional Requirements

- Target concurrency: 3000+ active users.
- Semua operasi write harus idempotent atau punya guard terhadap double submit.
- App harus tetap responsive di low-end device.
- Semua fitur core harus bisa diuji tanpa UI.
- Data authorization wajib ditegakkan di database melalui RLS, bukan hanya di client.
- Network failure harus menghasilkan error yang bisa dipahami dan retryable.

## Reliability Requirements

- Tidak boleh ada hard-coded API key di repository.
- Tidak boleh ada business logic penting di widget.
- Tidak boleh ada controller, stream, timer, atau recognizer yang tidak di-dispose.
- Tidak boleh ada RPC privileged yang bisa dipakai user untuk mengubah data user lain.

## Current Gaps

- Beberapa halaman masih static/mock dan perlu disambungkan ke repository.
- Home dan transaction flow perlu dipindahkan penuh dari local storage ke Supabase.
- Widget test lama sudah diganti menjadi smoke test router-injected, tetapi coverage masih perlu diperluas.
