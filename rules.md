# CoreBusiness Engineering Rules

## Architecture Rules

- UI tidak boleh menyimpan business logic inti.
- Domain tidak boleh import Flutter, Supabase, atau package UI.
- Data source tidak boleh dipanggil langsung dari widget.
- Repository adalah boundary antara domain dan data implementation.
- Dependency injection wajib lewat `core/di/service_locator.dart`.

## Flutter Rules

- Controller, stream, timer, focus node, dan recognizer harus di-dispose.
- Jangan membuat `TextEditingController` di dalam `build()`.
- Jangan memakai `context.read<T>()` jika ancestor provider belum jelas.
- Form submit harus punya loading state dan double-submit guard.
- Hindari heavy computation di `build()`.

## Supabase Rules

- RLS wajib untuk semua tabel public.
- Authorization berbasis `business_members`, bukan metadata client.
- Service role key tidak boleh masuk Flutter app.
- `app_private` schema tidak boleh diexpose di Supabase Data API.
- RPC privileged wajib guard `auth.uid()`.

## Code Quality Rules

- Satu file boleh besar hanya jika masih satu concern.
- Jangan punya duplicate event/state class untuk BLoC yang sama.
- Hindari hard-coded brand text di tiap halaman; pakai shared constants/component.
- Jangan commit generated output yang tidak relevan.
- Test harus menguji behavior sekarang, bukan template lama.

## AI Collaboration Rules

- Saat meminta AI membuat fitur, sertakan target file/layer.
- Jangan minta refactor besar tanpa daftar behavior yang harus tetap sama.
- Untuk perubahan Supabase, minta AI audit RLS dan migration idempotency.
- Untuk UI, minta AI verifikasi provider, navigation, loading, error, empty state, dan dispose lifecycle.
