# CoreBusiness Design Guide

## Product Direction

CoreBusiness adalah aplikasi operasional bisnis kecil-menengah untuk:

- Mencatat transaksi income dan expense.
- Mengelola wallet seperti cash, bank, dan e-wallet.
- Mengelola katalog produk dan stok inventory.
- Melihat dashboard keuangan dan operasional.
- Mendukung kerja tim multi-user dalam satu bisnis.

## UX Principles

- Halaman pertama setelah login harus langsung usable, bukan landing page.
- Semua aksi utama harus cepat ditemukan: tambah transaksi, scan struk, lihat riwayat, cek wallet, cek inventory.
- UI harus work-focused: padat, jelas, dan mudah discan.
- Jangan menampilkan state palsu tanpa label internal. Jika data masih kosong, gunakan empty state yang jujur.
- Hindari teks "mock", "placeholder", atau instruksi teknis di UI production.

## Visual System

- Gunakan brand name `CoreBusiness` secara konsisten.
- Gunakan komponen reusable untuk app bar, section header, transaction tile, empty state, dan primary action.
- Gunakan warna semantik:
  - Income: positif.
  - Expense: peringatan/pengurangan.
  - Primary: aksi utama.
  - Surface/background: area baca.

## Interaction Rules

- Semua submit harus punya loading state dan double-submit guard.
- Semua operasi network harus punya error state dan retry.
- Semua list data harus mendukung empty state.
- Semua destructive action harus minta konfirmasi.
- Semua form harus validasi sebelum hit data layer.
