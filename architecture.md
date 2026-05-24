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
- Domain bergantung ke Firebase/Firestore SDK.
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
- Data source remote/local (menghubungkan ke Firestore, Firebase Auth, Firebase Storage).
- Mapping JSON / Firestore DocumentSnapshot converter.
- Implementasi repository.

## State Management

- BLoC digunakan untuk flow yang memiliki loading, success, error, dan event history.
- `setState` diperbolehkan untuk state form lokal yang tidak perlu dibagikan ke widget lain.
- Single source of truth data operasional harus berupa repository, bukan diletakkan di dalam widget.

## Runtime Boundaries

- Firebase Auth dan Cloud Firestore hanya dipanggil dari data layer (Data Source).
- Active business context di-cache pada tingkat shell/presentation layer untuk meminimalkan beban Firestore read di concurrent user yang tinggi.
- Otentikasi dan otorisasi data wajib divalidasi di sisi Cloud Firestore menggunakan Security Rules.

## Recommended Next Architecture Work

1. Melakukan refaktorisasi `SmartSetupBloc` dan `smart_business_setup_page.dart` yang berukuran besar menjadi modul-modul sub-step yang lebih kecil dan modular.
2. Meningkatkan cakupan unit testing pada BLoC dan Repository layer.
3. Membuat shared app bar dan page scaffold terstandarisasi untuk UI yang konsisten.
