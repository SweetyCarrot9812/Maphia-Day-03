import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;
  
  // 키 상수들
  static const String keyUserId = 'user_id';
  static const String keyAuthToken = 'auth_token';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyApiBaseUrl = 'api_base_url';
  static const String keyUserProfile = 'user_profile';
  
  // Clintest-specific settings keys
  static const String keyClintestCountryOfPractice = 'clintest_country_of_practice';
  static const String keyClintestLabelLocale = 'clintest_label_locale';
  static const String keyClintestRole = 'clintest_role';
  static const String keyClintestDepartments = 'clintest_departments';
  static const String keyClintestInterests = 'clintest_interests';
  static const String keyClintestEnableAIParsing = 'clintest_enable_ai_parsing';
  static const String keyClintestEnableAutoTagging = 'clintest_enable_auto_tagging';
  static const String keyClintestAutoTaggingThreshold = 'clintest_auto_tagging_threshold';
  static const String keyClintestOnboardingCompleted = 'clintest_onboarding_completed';
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // String 값 저장/조회
  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }
  
  static String? getString(String key) {
    return _prefs?.getString(key);
  }
  
  // Bool 값 저장/조회
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }
  
  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }
  
  // Int 값 저장/조회
  static Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }
  
  static int getInt(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }
  
  // 특정 키 삭제
  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }
  
  // 모든 데이터 삭제
  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }
  
  // 사용자 관련 편의 메소드들
  static Future<void> saveUserData({
    required String userId,
    required String authToken,
    String? userName,
    String? userEmail,
  }) async {
    await setString(keyUserId, userId);
    await setString(keyAuthToken, authToken);
    if (userName != null) await setString(keyUserName, userName);
    if (userEmail != null) await setString(keyUserEmail, userEmail);
  }
  
  static Future<void> clearUserData() async {
    await remove(keyUserId);
    await remove(keyAuthToken);
    await remove(keyUserName);
    await remove(keyUserEmail);
  }
  
  static bool get isLoggedIn {
    final userId = getString(keyUserId);
    final authToken = getString(keyAuthToken);
    return userId != null && authToken != null;
  }
  
  static String? get userId => getString(keyUserId);
  static String? get authToken => getString(keyAuthToken);
  static String? get userName => getString(keyUserName);
  static String? get userEmail => getString(keyUserEmail);
  
  // API 베이스 URL (기본값: Vercel 배포 서버)
  static String get apiBaseUrl {
    // 로컬 개발 서버 사용 (에뮬레이터에서 localhost는 10.0.2.2로 접근)
    return getString(keyApiBaseUrl) ?? 'http://10.0.2.2:8000';
  }
  
  static Future<void> setApiBaseUrl(String url) async {
    await setString(keyApiBaseUrl, url);
  }
  
  // 첫 실행 여부
  static bool get isFirstLaunch {
    return getBool(keyIsFirstLaunch, defaultValue: true);
  }
  
  static Future<void> setFirstLaunchComplete() async {
    await setBool(keyIsFirstLaunch, false);
  }
  
  // Clintest 온보딩 완료 여부
  static bool get isClintestOnboardingCompleted {
    return getBool(keyClintestOnboardingCompleted, defaultValue: false);
  }
  
  static Future<void> setClintestOnboardingCompleted() async {
    await setBool(keyClintestOnboardingCompleted, true);
  }
  
  // Clintest 설정 관리
  static Future<void> saveClintestSettings({
    String? countryOfPractice,
    String? labelLocale,
    String? role,
    List<String>? departments,
    List<String>? interests,
    bool? enableAIParsing,
    bool? enableAutoTagging,
    double? autoTaggingThreshold,
  }) async {
    if (countryOfPractice != null) await setString(keyClintestCountryOfPractice, countryOfPractice);
    if (labelLocale != null) await setString(keyClintestLabelLocale, labelLocale);
    if (role != null) await setString(keyClintestRole, role);
    if (departments != null) await setString(keyClintestDepartments, departments.join(','));
    if (interests != null) await setString(keyClintestInterests, interests.join(','));
    if (enableAIParsing != null) await setBool(keyClintestEnableAIParsing, enableAIParsing);
    if (enableAutoTagging != null) await setBool(keyClintestEnableAutoTagging, enableAutoTagging);
    if (autoTaggingThreshold != null) await setString(keyClintestAutoTaggingThreshold, autoTaggingThreshold.toString());
  }
  
  // Clintest 설정 조회
  static String? get clintestCountryOfPractice => getString(keyClintestCountryOfPractice);
  static String? get clintestLabelLocale => getString(keyClintestLabelLocale);
  static String? get clintestRole => getString(keyClintestRole);
  
  static List<String> get clintestDepartments {
    final departments = getString(keyClintestDepartments);
    return departments?.isNotEmpty == true ? departments!.split(',') : [];
  }
  
  static List<String> get clintestInterests {
    final interests = getString(keyClintestInterests);
    return interests?.isNotEmpty == true ? interests!.split(',') : [];
  }
  
  static bool get clintestEnableAIParsing => getBool(keyClintestEnableAIParsing, defaultValue: true);
  static bool get clintestEnableAutoTagging => getBool(keyClintestEnableAutoTagging, defaultValue: true);
  
  static double get clintestAutoTaggingThreshold {
    final threshold = getString(keyClintestAutoTaggingThreshold);
    return threshold != null ? double.tryParse(threshold) ?? 0.85 : 0.85;
  }
}