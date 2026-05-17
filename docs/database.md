# CoreBusiness Database

Dokumen ini menjelaskan schema Supabase utama untuk CoreBusiness. Migration upgrade ada di:

`supabase/migrations/20260514_business_platform_schema_upgrade.sql`

## Prinsip Desain

- `businesses` adalah tenant root. Semua data operasional mengarah ke `business_id`.
- `business_members` adalah sumber kebenaran akses multi-user. Role tersedia: `owner`, `admin`, `staff`.
- `products` hanya menyimpan master katalog. Stok hidup di `inventory_items` agar produk bisa dikembangkan untuk multi-lokasi, batch, atau varian tanpa memecah katalog.
- `wallets` menyimpan akun kas/bank/e-wallet. Saldo diperbarui lewat trigger transaksi.
- `transactions` adalah header transaksi income/expense. `transaction_items` menyimpan detail produk.
- Dashboard memakai RPC supaya Flutter tidak perlu menarik banyak rows untuk menghitung ringkasan.

## Tabel Utama

| Tabel | Fungsi |
| --- | --- |
| `profiles` | Profil user yang terhubung ke `auth.users`. |
| `businesses` | Entitas bisnis/tenant. |
| `business_members` | Relasi user ke bisnis dan role akses. |
| `wallets` | Akun keuangan seperti Cash, Bank, E-wallet. |
| `categories` | Kategori income/expense per bisnis. |
| `goals` | Target finansial per bisnis. |
| `products` | Master katalog produk. |
| `inventory_items` | Stok per produk dalam bisnis. |
| `transactions` | Header transaksi income/expense. |
| `transaction_items` | Line item produk dalam transaksi. |

## RLS

Semua tabel di schema `public` memakai Row Level Security.

Aturan umumnya:

- User hanya bisa membaca profil sendiri.
- User hanya bisa membaca/mengelola data bisnis jika terdaftar di `business_members`.
- Update data bisnis dan pengelolaan member dibatasi untuk `owner` dan `admin`.
- `transaction_items` mengikuti akses dari parent `transactions`.

Helper RLS berada di schema `app_private` agar fungsi `security definer` tidak diekspos sebagai endpoint public REST.

## Trigger

- `touch_*_updated_at`: otomatis memperbarui `updated_at`.
- `sync_wallet_balance_on_transactions`: menambah/mengurangi saldo wallet untuk `INSERT`, `UPDATE`, dan `DELETE`.
- `sync_inventory_from_transaction_item`: transaksi `income` mengurangi stok, transaksi `expense` menambah stok.
- `recalculate_transaction_amount_from_items`: jika line item berubah, total header transaksi dihitung ulang dari `transaction_items`.

## RPC Untuk Flutter

### `ensure_current_user_workspace`

Dipanggil setelah login. Fungsi ini memastikan:

- Row `profiles` tersedia.
- User memiliki minimal satu bisnis.
- User pertama menjadi `owner`.
- Wallet `Cash` dan kategori sistem awal dibuat.

Contoh:

```dart
final businessId = await supabase.rpc<String>(
  'ensure_current_user_workspace',
  params: {
    'p_full_name': user.fullName,
    'p_email': user.email,
    'p_avatar_url': user.avatarUrl,
  },
);
```

### `get_dashboard_summary`

Mengembalikan ringkasan income, expense, profit, saldo wallet, jumlah transaksi, dan low-stock count.

```dart
final rows = await supabase.rpc(
  'get_dashboard_summary',
  params: {
    'p_business_id': businessId,
    'p_start_date': start.toIso8601String(),
    'p_end_date': end.toIso8601String(),
  },
);
```

### `get_monthly_cashflow`

Mengembalikan cashflow bulanan untuk chart.

```dart
final rows = await supabase.rpc(
  'get_monthly_cashflow',
  params: {
    'p_business_id': businessId,
    'p_months': 6,
  },
);
```

## Cara Menjalankan Migration

Supabase CLI belum tersedia di environment ini. Untuk sekarang, jalankan isi file migration di Supabase SQL Editor.

Jika Supabase CLI sudah tersedia:

```powershell
supabase db push
```

Setelah migration berjalan, login Google dari aplikasi akan memanggil `ensure_current_user_workspace` dan menyimpan `active_business_id` di `SharedPreferences`.

## Catatan Evolusi

Schema ini sengaja disiapkan untuk pengembangan lanjutan:

- Multi-lokasi stok bisa ditambah dengan tabel `inventory_locations`, lalu `inventory_items` diberi `location_id`.
- Audit trail bisa ditambah dengan tabel `wallet_ledger` tanpa mengubah kontrak transaksi utama.
- Invite flow bisa ditambah dengan tabel `business_invites` agar user belum terdaftar bisa diundang lewat email.
- Produk varian bisa ditambah dengan `product_variants`; `inventory_items` dapat diarahkan ke varian tanpa menghapus `products`.
