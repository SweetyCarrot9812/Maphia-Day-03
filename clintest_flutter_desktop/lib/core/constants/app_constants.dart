class AppConstants {
  // 앱 정보
  static const String appName = 'Clintest Desktop';
  static const String appVersion = '1.0.0';
  
  // API 엔드포인트
  static const String apiBaseUrl = 'http://localhost:8000';
  static const String nursingEndpoint = '/api/nursing';
  static const String aiPipelineEndpoint = '/api/ai-pipeline';
  static const String srsEndpoint = '/api/srs';
  static const String jobsEndpoint = '/api/jobs';
  
  // UI 설정
  static const double defaultPadding = 16.0;
  static const double cardElevation = 4.0;
  static const double borderRadius = 12.0;
  
  // 창 크기 설정
  static const double defaultWindowWidth = 1200.0;
  static const double defaultWindowHeight = 800.0;
  static const double minWindowWidth = 800.0;
  static const double minWindowHeight = 600.0;
  
  // 로컬 스토리지 키
  static const String userPrefsKey = 'user_preferences';
  static const String themePrefsKey = 'theme_preferences';
  static const String windowStateKey = 'window_state';
  
  // 색상
  static const int primaryColor = 0xFF2196F3;
  static const int secondaryColor = 0xFF03DAC6;
  static const int errorColor = 0xFFB00020;
}

class ApiEndpoints {
  // 간호사 시험 관련
  static const String nursingQuestions = '/nursing/questions';
  static const String nursingCategories = '/nursing/categories';
  static const String nursingResults = '/nursing/results';
  
  // AI 파이프라인
  static const String aiGenerate = '/ai/generate';
  static const String aiAnalyze = '/ai/analyze';
  
  // SRS 시스템
  static const String srsCards = '/srs/cards';
  static const String srsReviews = '/srs/reviews';
  static const String srsStats = '/srs/stats';
  
  // Jobs 큐
  static const String jobsList = '/jobs/list';
  static const String jobsStatus = '/jobs/status';
  static const String jobsCreate = '/jobs/create';
}

enum QuestionType {
  multipleChoice,
  trueFalse,
  shortAnswer,
  essay,
}

enum Difficulty {
  easy,
  medium,
  hard,
}

enum JobStatus {
  pending,
  running,
  completed,
  failed,
}