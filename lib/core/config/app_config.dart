import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
  static String get googleAndroidClientId => dotenv.env['GOOGLE_ANDROID_CLIENT_ID'] ?? '';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  const AppConfig._();

  static void validate() {}
}
