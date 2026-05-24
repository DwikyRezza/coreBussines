# CoreBusiness Engineering Rules

## Architecture Rules

- UI tidak boleh menyimpan business logic inti.
- Domain tidak boleh import Flutter, Firebase SDK, atau package UI.
- Data source tidak boleh dipanggil langsung dari widget.
- Repository adalah boundary antara domain dan data implementation.
- Dependency injection wajib lewat `core/di/service_locator.dart`.

## Flutter Rules

- Controller, stream, timer, focus node, dan recognizer harus di-dispose.
- Jangan membuat `TextEditingController` di dalam `build()`.
- Jangan memakai `context.read<T>()` jika ancestor provider belum jelas.
- Form submit harus punya loading state dan double-submit guard.
- Hindari heavy computation di `build()`.

## Firebase & Firestore Rules

- Firestore Security Rules wajib diaktifkan untuk mengamankan seluruh koleksi.
- Otorisasi akses data berbasis subkoleksi `members` di bawah `/businesses/{businessId}/members/{userId}`, bukan dari metadata client.
- Rules harus diamankan dari crash evaluasi: selalu gunakan `exists()` sebelum memanggil data dari `get()` jika dokumen target berpotensi tidak ada (misalnya saat database baru di-reset/kosong).
- Kredensial Firebase (`google-services.json` / `GoogleService-Info.plist`) dikonfigurasi dengan benar dan aman.

## Code Quality Rules

- Satu file boleh besar hanya jika masih satu concern (pecah BLoC atau Page yang terlalu besar jika concern-nya sudah bercabang).
- Jangan memiliki duplicate event/state class untuk BLoC yang sama.
- Hindari hard-coded brand text di tiap halaman; pakai shared constants/component.
- Jangan commit generated output atau file konfigurasi local `.env` yang berisi API key sensitif.
- Test harus menguji behavior sekarang, bukan template lama.

## AI Collaboration Rules

- Saat meminta AI membuat fitur, sertakan target file/layer.
- Jangan meminta refactor besar tanpa daftar behavior yang harus tetap sama.
- Untuk perubahan Firestore, minta AI untuk mengaudit Firestore Security Rules agar tidak ada celah keamanan atau rule crash.
- Untuk UI, minta AI verifikasi provider, navigation, loading, error, empty state, dan dispose lifecycle.
