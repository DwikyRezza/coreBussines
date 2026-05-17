# CoreBusiness Architecture

## Architecture Style

Project memakai feature-first layered architecture:

```text
lib/
  core/
    config/
    di/
    error/
    router/
    shell/
    theme/
    usecases/
    utils/
  features/
    <feature>/
      data/
      domain/
      presentation/
```

## Dependency Rule

Dependency harus mengarah ke dalam:

```text
presentation -> domain -> data contract
data -> domain entity / repository contract
core -> shared infrastructure only
```

Yang harus dihindari:

- Domain bergantung ke Flutter widget.
- Domain bergantung ke Supabase SDK.
- Data layer memanggil UI.
- Feature saling import presentation layer milik feature lain.

## Layer Responsibilities

### Presentation

- Widget, page, BLoC, UI state.
- Validasi input ringan yang dekat dengan form.
- Tidak menyimpan aturan bisnis inti.

### Domain

- Entity.
- Repository contract.
- Use case.
- Business rule yang bisa diuji tanpa Flutter.

### Data

- Model.
- Data source remote/local.
- Mapping JSON.
- Implementasi repository.

## State Management

- BLoC digunakan untuk flow yang punya loading, success, error, dan event history.
- `setState` boleh untuk state form lokal yang tidak perlu dishare.
- Single source of truth data operasional harus repository, bukan widget.

## Runtime Boundaries

- Supabase Auth dan database hanya dipanggil dari data layer.
- Active business context disimpan di local storage sebagai pointer, tetapi otorisasi tetap di RLS.
- Dashboard sebaiknya memakai RPC aggregation agar client tidak menarik banyak row.

## Recommended Next Architecture Work

1. Buat `BusinessContextRepository` untuk active business.
2. Buat `SupabaseHomeDataSource`.
3. Buat `SupabaseTransactionDataSource`.
4. Pisahkan BLoC event/state transaksi ke file sendiri atau biarkan di satu file, jangan dua-duanya.
5. Buat shared app bar dan page scaffold agar branding tidak tersebar di puluhan page.
