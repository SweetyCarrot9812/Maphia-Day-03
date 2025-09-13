import 'package:dotenv/dotenv.dart';

class AppConfig {
  static DotEnv? _env;

  // API 키
  static String get openAIApiKey => _env?['OPENAI_API_KEY'] ?? '';
  static String get geminiApiKey => _env?['GEMINI_API_KEY'] ?? '';
  static String get perplexityApiKey => _env?['PERPLEXITY_API_KEY'] ?? '';
  static String get anthropicApiKey => _env?['ANTHROPIC_API_KEY'] ?? '';

  // 데이터베이스
  static String get dbName => _env?['DB_NAME'] ?? 'hanoa_desktop.db';
  static String get firebaseProjectId => _env?['FIREBASE_PROJECT_ID'] ?? 'hanoa-hub';

  // API 설정
  static String get apiBaseUrl => _env?['API_BASE_URL'] ?? 'http://localhost:3000';

  // 디버그 모드
  static bool get isDebug => _env?['DEBUG'] == 'true';

  static void initialize(DotEnv env) {
    _env = env;
  }

  // API 키 유효성 검사
  static bool get hasOpenAIKey => openAIApiKey.isNotEmpty;
  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;
  static bool get hasPerplexityKey => perplexityApiKey.isNotEmpty;
  static bool get hasAnthropicKey => anthropicApiKey.isNotEmpty;

  // 사용 가능한 LLM 프로바이더 목록
  static List<String> get availableProviders {
    List<String> providers = [];
    if (hasOpenAIKey) providers.add('openai');
    if (hasGeminiKey) providers.add('gemini');
    if (hasPerplexityKey) providers.add('perplexity');
    if (hasAnthropicKey) providers.add('anthropic');
    return providers;
  }
}