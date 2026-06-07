class AppConfig {
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );
  static const googleAndroidClientId = String.fromEnvironment(
    'GOOGLE_ANDROID_CLIENT_ID',
  );
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const receiptScanApiUrl = String.fromEnvironment(
    'RECEIPT_SCAN_API_URL',
    defaultValue: '/api/ai/scan',
  );

  static const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );
  static const firebaseAuthDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
  );
  static const firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );

  const AppConfig._();

  static void validateForWeb() {
    final missing = <String>[
      if (firebaseApiKey.isEmpty) 'FIREBASE_API_KEY',
      if (firebaseAppId.isEmpty) 'FIREBASE_APP_ID',
      if (firebaseMessagingSenderId.isEmpty) 'FIREBASE_MESSAGING_SENDER_ID',
      if (firebaseProjectId.isEmpty) 'FIREBASE_PROJECT_ID',
      if (firebaseAuthDomain.isEmpty) 'FIREBASE_AUTH_DOMAIN',
      if (firebaseStorageBucket.isEmpty) 'FIREBASE_STORAGE_BUCKET',
      if (googleWebClientId.isEmpty) 'GOOGLE_WEB_CLIENT_ID',
    ];
    if (missing.isNotEmpty) {
      throw StateError(
        'Konfigurasi web belum lengkap: ${missing.join(', ')}.',
      );
    }
  }
}
