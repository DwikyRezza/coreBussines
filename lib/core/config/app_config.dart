class AppConfig {
  static const supabaseUrl = 'https://mvjkapkiblwfyygjwuzj.supabase.co';
  static const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im12amthcGtpYmx3Znl5Z2p3dXpqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgzNDczOTcsImV4cCI6MjA5MzkyMzM5N30.PxCJly2oDBggkKqWknNs2bf1kzafShF6Nm1zzcW7Rug';
  static const googleWebClientId = '285167183652-1fq3bkgsm44painh30gfsfjk2bjf0g10.apps.googleusercontent.com';
  static const googleAndroidClientId = '285167183652-oqjvhe205s9uoptjqfafmvd3n7cipa59.apps.googleusercontent.com';

  const AppConfig._();

  static void validate() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'Supabase belum dikonfigurasi. Tambahkan SUPABASE_URL dan '
        'SUPABASE_ANON_KEY.',
      );
    }
  }
}
