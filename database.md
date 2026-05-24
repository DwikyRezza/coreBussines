# CoreBusiness Database (Firestore Schema)

CoreBusiness menggunakan Cloud Firestore sebagai NoSQL database utama dengan model data berorientasi Tenant (Multi-Business Workspace).

## Firestore Collections & Documents

### `/users/{userId}`
Menyimpan data profil pengguna dan status onboarding aplikasi.
- `onboarding_completed`: boolean
- `active_business_id`: string
- `full_name`: string
- `avatar_url`: string
- `updated_at`: timestamp

### `/businesses/{businessId}`
Menyimpan konfigurasi utama dan detail entitas bisnis.
- `name`: string
- `owner_id`: string (userId dari pembuat bisnis)
- `business_type`: string
- `business_size`: string
- `currency`: string (default: `'IDR'`)
- `timezone`: string (default: `'Asia/Jakarta'`)
- `details`: map (description, address, whatsapp, email)
- `enabled_features`: array of string
- `created_at`: timestamp
- `updated_at`: timestamp

#### Sub-koleksi di bawah `/businesses/{businessId}`:

1. **/members/{userId}**
   Relasi anggota tim ke bisnis beserta perannya.
   - `user_id`: string
   - `name`: string
   - `email`: string
   - `photo_url`: string
   - `role`: string (`'owner'`, `'admin'`, `'staff'`)
   - `joined_at`: timestamp
   - `updated_at`: timestamp
   - `status`: string (`'active'`, `'pending'`)

2. **/wallets/{walletId}**
   Akun kas, bank, atau e-wallet milik bisnis.
   - `name`: string
   - `type`: string (`'cash'`, `'bank'`, `'ewallet'`)
   - `balance`: number (double/int)
   - `updated_at`: timestamp

3. **/categories/{categoryId}**
   Kategori transaksi.
   - `id`: string
   - `name`: string
   - `iconKey`: string
   - `isIncome`: boolean

4. **/transactions/{transactionId}**
   Data transaksi pemasukan/pengeluaran bisnis.
   - `createdByUserId`: string
   - `businessId`: string
   - `amount`: number
   - `type`: string (`'income'`, `'expense'`)
   - `walletId`: string
   - `categoryId`: string
   - `description`: string
   - `date`: timestamp
   - `created_at`: timestamp

5. **/notifications/{notificationId}**
   Notifikasi sistem dan alur kerja antar anggota tim.
   - `targetUserId`: string
   - `title`: string
   - `message`: string
   - `isRead`: boolean
   - `created_at`: timestamp

6. **/activity_logs/{logId}**
   Audit log aktivitas operasional bisnis (bersifat *immutable* / tidak dapat diubah/dihapus).
   - `performedByUserId`: string
   - `action`: string
   - `details`: string
   - `created_at`: timestamp

## Firestore Security Rules

Keamanan data ditegakkan melalui aturan berikut (didefinisikan di `firestore.rules`):
- **Otorisasi Tim:** User hanya bisa membaca/menulis data bisnis jika tercatat sebagai member di `/businesses/{businessId}/members/{userId}`.
- **Owner Only:** Penghapusan bisnis dan pengelolaan member hanya bisa dilakukan oleh member dengan role `'owner'`.
- **Aman saat Reset:** Aturan `members` dan `wallets` mendukung pembuatan bisnis baru dalam database kosong tanpa mengalami crash evaluasi `get()` dengan memadukan pengecekan `!exists(...)`.
- **Immutable Log:** Koleksi `activity_logs` tidak memperbolehkan operasi `update` maupun `delete`.
