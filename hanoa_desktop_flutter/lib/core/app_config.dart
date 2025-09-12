import 'package:dotenv/dotenv.dart';

class AppConfig {
  static late DotEnv _env;
  static bool _initialized = false;

  static void initialize(DotEnv env) {
    _env = env;
    _initialized = true;
  }

  static String get _checkInitialized {
    if (!_initialized) {
      throw Exception('AppConfig not initialized. Call AppConfig.initialize() first.');
    }
    return '';
  }

  // Firebase configuration
  static String get firebaseApiKey {
    _checkInitialized;
    return _env['FIREBASE_API_KEY'] ?? '';
  }

  static String get firebaseProjectId {
    _checkInitialized;
    return _env['FIREBASE_PROJECT_ID'] ?? '';
  }

  // OpenAI configuration
  static String get openaiApiKey {
    _checkInitialized;
    return _env['OPENAI_API_KEY'] ?? '';
  }

  // Gemini AI configuration
  static String get geminiApiKey {
    _checkInitialized;
    return _env['GEMINI_API_KEY'] ?? '';
  }

  // Server configuration
  static String get serverUrl {
    _checkInitialized;
    return _env['SERVER_URL'] ?? 'http://localhost:3000';
  }

  static String get appUrl {
    _checkInitialized;
    return _env['APP_URL'] ?? 'http://localhost:3000/';
  }

  // Development settings
  static bool get isDev {
    _checkInitialized;
    return _env['NODE_ENV'] != 'production';
  }

  // Jobs polling settings
  static int get jobsPollMs {
    _checkInitialized;
    return int.tryParse(_env['JOBS_POLL_MS'] ?? '10000') ?? 10000;
  }

  // Window settings
  static String get userModelId {
    _checkInitialized;
    return _env['USER_MODEL_ID'] ?? 'com.hanoa.clintest';
  }

  // Database settings
  static String get databasePath {
    _checkInitialized;
    return _env['DATABASE_PATH'] ?? 'hanoa_desktop.db';
  }

  // Logging settings
  static bool get enableLogging {
    _checkInitialized;
    return _env['ENABLE_LOGGING']?.toLowerCase() == 'true';
  }

  // AI Model settings
  static String get defaultAIModel {
    _checkInitialized;
    return _env['DEFAULT_AI_MODEL'] ?? 'gpt-4o';
  }

  static double get aiTemperature {
    _checkInitialized;
    return double.tryParse(_env['AI_TEMPERATURE'] ?? '0.7') ?? 0.7;
  }
}