/// Hanoa 앱의 상수 정의
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Hanoa';
  static const String appVersion = '1.0.0';
  static const String appDescription = '하나의 허브 안에서 다수 서비스를 패키지 모듈로 제공하는 슈퍼앱';

  // Design Constants (프로젝트 구조 문서 기준)
  static const double minFontSize = 16.0; // 16pt 이상
  static const double minTouchTarget = 44.0; // 44px 터치 영역
  static const double cardRadius = 16.0; // 카드 라운드
  static const double buttonRadius = 12.0;
  static const double inputRadius = 12.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Layout
  static const double maxContentWidth = 400.0;
  static const double headerHeight = 60.0;
  static const double bottomNavHeight = 60.0;
  static const double fabHeight = 56.0;

  // Animation Durations
  static const int splashDurationMs = 2500; // 2-3초
  static const int maxSplashDurationMs = 3000; // 최대 3초
  static const int transitionDurationMs = 300; // 250-350ms 전환
  static const int shortTransitionMs = 150;

  // Beta Constants
  static const String betaStatus = 'Beta Free';
  static const String betaMessage = 'Beta 무료 이용 중 · 정식 출시 후 서비스별 요금 적용 예정';
  static const String betaTooltip = 'Beta 기간 무료, 정식 출시 후 요금 적용';

  // Module Constants
  static const String moduleStudyId = 'study';
  static const String moduleExerciseId = 'exercise';
  static const String moduleRestaurantId = 'restaurant';
  static const String moduleChristianId = 'christian';

  static const Map<String, String> moduleNames = {
    moduleStudyId: '공부',
    moduleExerciseId: '운동',
    moduleRestaurantId: '맛집',
    moduleChristianId: '기독교',
  };

  // Onboarding Constants (GPT-5 mini)
  static const int maxOnboardingTurns = 7; // 7턴 내
  static const double onboardingCompletionTarget = 0.9; // 90% 이상 완료
  static const String defaultStudyField = '의학 및 간호학';
  static const String defaultAlarmTime = '07:30';

  // API Constants (추후 설정)
  static const String baseUrl = ''; // TBD
  static const String gptMiniModel = 'gpt-5-mini'; // 온보딩 집사
  static const String gptMainModel = 'gpt-5'; // 메인 AI

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserProfile = 'user_profile';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyAutoLogin = 'auto_login';
  static const String keyLanguageCode = 'language_code';
  static const String keyCountryCode = 'country_code';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxNameLength = 50;
  static const int maxNicknameLength = 20;

  // Performance Thresholds
  static const int skeletonLoadingDurationMs = 500; // ≤500ms
  static const int drawerAnimationMs = 300; // 250-350ms
  static const int homePersonalizationMs = 500; // ≤500ms

  // Asset Paths
  static const String logoPath = 'assets/logo/hanoa_logo.png';
  static const String iconPath = 'assets/icons/';
  static const String imagePath = 'assets/images/';

  // Routes (라우터에서 사용)
  static const String routeSplash = '/';
  static const String routeAuth = '/auth';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeOnboarding = '/onboarding';
  static const String routeHome = '/home';
  static const String routeProfile = '/profile';
  static const String routeSettings = '/settings';

  // Feature Flags (원격 설정용)
  static const String flagOnboardingEnabled = 'onboarding_enabled';
  static const String flagBetaBadgeEnabled = 'beta_badge_enabled';
  static const String flagNewsEnabled = 'news_enabled'; // 뉴스/기사 후순위
  
  // Error Messages
  static const String errorNetworkConnection = '네트워크 연결을 확인해주세요';
  static const String errorInvalidCredentials = '이메일 또는 비밀번호가 올바르지 않습니다';
  static const String errorUserNotFound = '사용자를 찾을 수 없습니다';
  static const String errorEmailAlreadyExists = '이미 사용 중인 이메일입니다';
  static const String errorServerError = '서버 오류가 발생했습니다';
  static const String errorUnknown = '알 수 없는 오류가 발생했습니다';

  // Success Messages
  static const String successRegistration = '회원가입이 완료되었습니다';
  static const String successLogin = '로그인되었습니다';
  static const String successLogout = '로그아웃되었습니다';
  static const String successProfileUpdate = '프로필이 업데이트되었습니다';

  // Validation Messages
  static const String validationEmailRequired = '이메일을 입력해주세요';
  static const String validationEmailInvalid = '올바른 이메일 형식이 아닙니다';
  static const String validationPasswordRequired = '비밀번호를 입력해주세요';
  static const String validationPasswordTooShort = '비밀번호는 8자 이상이어야 합니다';
  static const String validationPasswordConfirmMismatch = '비밀번호가 일치하지 않습니다';
  static const String validationNameRequired = '이름을 입력해주세요';
  static const String validationNameTooLong = '이름은 50자 이내로 입력해주세요';
}