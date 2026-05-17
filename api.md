# CoreBusiness API Contract

CoreBusiness memakai Supabase sebagai backend utama.

## API Key Setup

```powershell
flutter run `
  --dart-define=SUPABASE_URL=<project-url> `
  --dart-define=SUPABASE_ANON_KEY=<publishable-key>
```

`SUPABASE_ANON_KEY` adalah publishable key client. Jangan pernah memakai service role key di Flutter.

## Auth

### Google Sign-In

Client flow:

1. Google Sign-In menghasilkan `idToken` dan `accessToken`.
2. App memanggil Supabase Auth `signInWithIdToken`.
3. App memanggil RPC `ensure_current_user_workspace`.
4. App menyimpan `active_business_id`.

## RPC Contracts

### `ensure_current_user_workspace`

Input:

```json
{
  "p_full_name": "string|null",
  "p_email": "string|null",
  "p_avatar_url": "string|null"
}
```

Output:

```json
"business_uuid"
```

### `get_dashboard_summary`

Input:

```json
{
  "p_business_id": "uuid",
  "p_start_date": "iso8601 timestamp",
  "p_end_date": "iso8601 timestamp"
}
```

Output:

```json
[
  {
    "total_income": 0,
    "total_expense": 0,
    "net_profit": 0,
    "wallet_balance": 0,
    "transaction_count": 0,
    "low_stock_count": 0
  }
]
```

### `get_monthly_cashflow`

Input:

```json
{
  "p_business_id": "uuid",
  "p_months": 6
}
```

Output:

```json
[
  {
    "month": "2026-05-01",
    "income": 0,
    "expense": 0,
    "net": 0
  }
]
```

## Client Error Handling

- Timeout harus ditampilkan sebagai masalah jaringan.
- Auth error harus memandu user login ulang.
- RLS/permission error harus ditampilkan sebagai akses tidak tersedia.
- Write operation harus disable tombol submit saat loading.
