# CoreBusiness Database

Migration utama:

- `supabase/migrations/20260514_business_platform_schema_upgrade.sql`

## Tables

| Table | Purpose |
| --- | --- |
| `profiles` | Profile user dari Supabase Auth. |
| `businesses` | Tenant bisnis. |
| `business_members` | Membership user ke bisnis dan role. |
| `wallets` | Cash, bank, e-wallet, credit, dan akun lain. |
| `categories` | Kategori transaksi income/expense. |
| `goals` | Target finansial bisnis. |
| `products` | Master katalog produk. |
| `inventory_items` | Stok per produk di bisnis. |
| `transactions` | Header transaksi. |
| `transaction_items` | Detail produk dalam transaksi. |

## RLS Model

- Semua tabel public harus RLS enabled.
- Akses bisnis memakai `business_members`.
- User hanya bisa membaca profil sendiri.
- Owner/admin mengelola bisnis dan member.
- Semua data operasional dicek lewat `business_id`.

## RPC

| RPC | Purpose |
| --- | --- |
| `ensure_current_user_workspace` | Bootstrap profile, business, owner membership, wallet, dan kategori awal. |
| `get_dashboard_summary` | Ringkasan dashboard untuk range tanggal. |
| `get_monthly_cashflow` | Data chart cashflow bulanan. |

## Security Rules

- Jangan expose `app_private` schema di Supabase Data API.
- Jangan hard-code service role key di app.
- Jangan jadikan metadata user sebagai sumber authorization.
- Jangan grant privileged RPC tanpa guard `auth.uid()`.

## Migration Notes

Migration sudah menambahkan guard agar workspace bootstrap tidak bisa dipanggil untuk user lain.

Untuk menjalankan manual di Supabase SQL Editor:

```sql
-- paste isi supabase/migrations/20260514_business_platform_schema_upgrade.sql
```

Jika Supabase CLI tersedia:

```powershell
supabase db push
```
