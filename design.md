# CoreBusiness Design Guide
> Operational business app with calm, high-contrast Slate + Indigo SaaS styling.
> Design direction: **work-focused, clean, high-contrast, compact, and trustworthy**.

CoreBusiness menggunakan inspirasi visual dari light professional SaaS: canvas putih bersih, teks hitam arang tegas, aksen Indigo dan Blue, kartu-kartu dengan border tipis dan radius halus, serta kontrol fungsional yang padat. Tampilan dirancang agar mudah dibaca (*comfortable readability*) dan memiliki kontras tinggi untuk mencegah ketegangan mata saat operasional harian.

---

## 1. Product Direction
CoreBusiness adalah aplikasi operasional bisnis kecil-menengah untuk:
* Mencatat transaksi income dan expense.
* Mengelola wallet seperti cash, bank, dan e-wallet.
* Mengelola katalog produk dan stok inventory.
* Melihat dashboard keuangan dan operasional.
* Mendukung kerja tim multi-user dalam satu bisnis.

---

## 2. Core UX Principles
* **First Screen Must Be Usable:** Halaman utama setelah masuk adalah dashboard siap pakai (ringkasan saldo, shortcut tambah data, riwayat transaksi terakhir).
* **Work-Focused Layout:** Kepadatan informasi yang pas, mudah dipindai cepat, menghindari ornamen dekoratif yang memakan ruang layar.
* **No Receipt Upload (Fitur Bukti Pembayaran Dihapus):** Karena keterbatasan kuota penyimpanan awan (*Storage Subscription*), fitur unggahan foto bukti pembayaran/struk dinonaktifkan. Seluruh pencatatan dilakukan secara digital murni berbasis input data transaksi.
* **Honest Data State:** Gunakan ilustrasi dan panduan *empty state* yang informatif, hindari penggunaan data palsu (*mock data*).
* **Reliable Interactions:** Semua form memiliki validasi sebelum disubmit dan memiliki pelindung klik ganda (*double-submit guard*).

---

## 3. Color System
Menggunakan palet warna Slate + Indigo untuk menghadirkan visual profesional, bersih, dan kontras tinggi.

| Role | Name | Hex | Usage |
| :--- | :--- | :--- | :--- |
| **Primary Text** | Obsidian | `#0F172A` | Judul utama, nominal saldo, teks penting |
| **Secondary Text** | Graphite | `#334155` | Label, deskripsi form, informasi sekunder |
| **Muted Text** | Slate | `#64748B` | Teks pembantu, waktu/tanggal, informasi non-kritis |
| **Disabled** | Mist | `#94A3B8` | Tombol/input non-aktif, ikon mati |
| **Soft Border** | Silver | `#E2E8F0` | Pembatas (divider), border kartu, garis input |
| **Main Surface** | Paper | `#FFFFFF` | Background halaman dalam kartu, dropdown |
| **Secondary Surface**| Bone | `#F8FAFC` | Background utama halaman (Scaffold) |
| **Primary Accent** | Indigo Bloom| `#4F46E5` | Tombol utama, tab aktif, ikon utama |
| **Secondary Accent**| Blue Veil | `#3B82F6` | Highlight sekunder, info penting, grafik |

### Semantic Colors
| Role | Hex | Usage |
| :--- | :--- | :--- |
| **Income / Success** | `#10B981` | Angka pemasukan, status lunas, penanda positif |
| **Expense / Danger** | `#EF4444` | Angka pengeluaran, konfirmasi hapus, penanda negatif |
| **Warning** | `#F59E0B` | Peringatan stok rendah, penundaan pembayaran |
| **Info** | `#0EA5E9` | Notifikasi sistem, sinkronisasi data |

---

## 4. Typography
Menggunakan font keluarga **Inter** untuk keterbacaan antarmuka yang optimal.

* **Display (32px, Medium/Semibold):** Judul onboarding, layar splash, penanda besar.
* **Page Title (20px, Bold):** Judul halaman di App Bar.
* **Section Title (16px, Bold):** Pembatas konten/kategori di dashboard.
* **Body Text (14px, Regular):** Teks keterangan, data tabel, input form.
* **Label (13px, Medium/Semibold):** Judul input, nama kolom, teks tombol.
* **Caption (12px, Regular):** Tanggal transaksi, detail log, catatan kecil.

---

## 5. Layout, Shape, and Elevation
* **Spacing:** Berbasis kelipatan 4px (`4px`, `8px`, `12px`, `16px`, `20px`, `24px`, `32px`).
* **Radius:**
  * Kartu Utama / Modal: 24px
  * ListTile / Kartu Kecil: 16px
  * Tombol & Input: 12px
  * Chip / Status Badge: 32px (Pill)
* **Shadows:** Sangat tipis (`0 1px 2px rgba(15,23,42,0.05)`) untuk menghindari kesan kotor pada antarmuka.

---

## 6. Interaction Rules
* **Submit:** Validasi form -> tampilkan indikator loading pada tombol -> nonaktifkan tombol untuk cegah klik berulang -> berikan snackbar sukses/gagal.
* **Destructive Action:** Wajib menampilkan dialog konfirmasi berbahasa Indonesia yang jelas sebelum menghapus data (misalnya saat menghapus transaksi atau dompet).
