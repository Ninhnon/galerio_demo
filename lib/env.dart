import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAppIdAndroid =>
      dotenv.env['FIREBASE_APP_ID_ANDROID'] ?? '';
  static String get firebaseAppIdIOS => dotenv.env['FIREBASE_APP_ID_IOS'] ?? '';
  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseStorageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseIOSClientId =>
      dotenv.env['FIREBASE_IOS_CLIENT_ID'] ?? '';
  static String get firebaseIOSBundleId =>
      dotenv.env['FIREBASE_IOS_BUNDLE_ID'] ?? '';
  static String get firebaseAndroidClientId =>
      dotenv.env['FIREBASE_ANDROID_CLIENT_ID'] ?? '';
  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
  static String get webAppUrl => dotenv.env['WEB_APP_URL'] ?? '';

  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  static bool validateConfig() {
    final requiredVars = [
      'FIREBASE_API_KEY',
      'FIREBASE_APP_ID_ANDROID',
      'FIREBASE_APP_ID_IOS',
      'FIREBASE_MESSAGING_SENDER_ID',
      'FIREBASE_PROJECT_ID',
      'FIREBASE_STORAGE_BUCKET',
      'FIREBASE_IOS_CLIENT_ID',
      'FIREBASE_IOS_BUNDLE_ID',
      'GOOGLE_WEB_CLIENT_ID',
      'WEB_APP_URL',
    ];

    for (final key in requiredVars) {
      if (dotenv.env[key]?.isEmpty ?? true) {
        throw Exception('Missing required environment variable: $key');
      }
    }

    return true;
  }
}
