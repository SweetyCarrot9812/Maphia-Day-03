import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_constants.dart';
import '../../features/onboarding/models/onboarding_models.dart';

/// 인증 상태 관리 Provider
class AuthProvider extends ChangeNotifier {
  static const _secureStorage = FlutterSecureStorage();

  // Private fields
  bool _isAuthenticated = false;
  bool _isLoading = true;
  bool _isOnboardingCompleted = false;
  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _userProfile;
  String? _errorMessage;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;
  String? get userName => _userProfile?['name'];
  String? get userEmail => _userProfile?['email'];
  String? get userNickname => _userProfile?['nickname'];

  /// Provider 인스턴스를 context에서 가져오는 헬퍼
  static AuthProvider of(BuildContext context) {
    return context.read<AuthProvider>();
  }

  /// 초기화 - 저장된 인증 정보 확인
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 저장된 토큰 확인
      _accessToken = await _secureStorage.read(key: AppConstants.keyAccessToken);
      _refreshToken = await _secureStorage.read(key: AppConstants.keyRefreshToken);

      // 사용자 프로필 확인
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(AppConstants.keyUserProfile);
      if (profileJson != null) {
        // JSON 파싱 (실제로는 json.decode 사용)
        _userProfile = {}; // 임시
      }

      // 온보딩 완료 여부 확인
      _isOnboardingCompleted = prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;

      // 인증 상태 설정
      _isAuthenticated = _accessToken != null && _refreshToken != null;

      // 자동 로그인 설정 확인
      final autoLogin = prefs.getBool(AppConstants.keyAutoLogin) ?? false;
      if (!autoLogin) {
        await logout();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '초기화 중 오류가 발생했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 로그인
  Future<bool> login({
    required String email,
    required String password,
    bool autoLogin = true,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // TODO: 실제 API 호출
      await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션

      // 임시 토큰 (실제로는 API 응답에서 받아옴)
      _accessToken = 'temp_access_token_${DateTime.now().millisecondsSinceEpoch}';
      _refreshToken = 'temp_refresh_token_${DateTime.now().millisecondsSinceEpoch}';

      // 임시 사용자 정보
      _userProfile = {
        'id': '1',
        'email': email,
        'name': '홍길동',
        'nickname': '길동이',
        'createdAt': DateTime.now().toIso8601String(),
      };

      // 보안 저장소에 토큰 저장
      await _secureStorage.write(key: AppConstants.keyAccessToken, value: _accessToken);
      await _secureStorage.write(key: AppConstants.keyRefreshToken, value: _refreshToken);

      // SharedPreferences에 사용자 정보 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserProfile, _userProfile.toString()); // 실제로는 JSON
      await prefs.setBool(AppConstants.keyAutoLogin, autoLogin);

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = '로그인에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 회원가입
  Future<bool> register({
    required String name,
    required String nickname,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // TODO: 실제 API 호출
      await Future.delayed(const Duration(seconds: 2)); // 시뮬레이션

      // 회원가입 후 자동 로그인
      final loginSuccess = await login(email: email, password: password);

      return loginSuccess;
    } catch (e) {
      _errorMessage = '회원가입에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 온보딩 완료
  Future<void> completeOnboarding(OnboardingData data) async {
    try {
      _isLoading = true;
      notifyListeners();

      // TODO: 온보딩 데이터를 서버에 저장
      await Future.delayed(const Duration(milliseconds: 500));

      // 온보딩 데이터를 안전한 저장소에 저장
      await _secureStorage.write(
        key: 'onboarding_data',
        value: jsonEncode(data.toMap()),
      );

      // 사용자 프로필 업데이트
      _userProfile = {
        ..._userProfile!,
        'displayName': data.displayName,
        'preferredPackage': data.preferredPackage,
        'studyField': data.studyField,
        'notificationsEnabled': data.notificationsEnabled,
        'notificationTime': data.notificationTime,
        'languageCode': data.languageCode,
        'countryCode': data.countryCode,
        'dataConsentGiven': data.dataConsentGiven,
        'onboardingCompletedAt': DateTime.now().toIso8601String(),
      };

      // 온보딩 완료 플래그 설정
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyOnboardingCompleted, true);
      await prefs.setString(AppConstants.keyUserProfile, jsonEncode(_userProfile));

      _isOnboardingCompleted = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '온보딩 저장에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 저장된 온보딩 데이터 조회
  Future<OnboardingData?> getOnboardingData() async {
    try {
      final dataString = await _secureStorage.read(key: 'onboarding_data');
      if (dataString != null) {
        final dataMap = jsonDecode(dataString) as Map<String, dynamic>;
        return OnboardingData(
          displayName: dataMap['displayName'],
          preferredPackage: dataMap['preferredPackage'],
          studyField: dataMap['studyField'],
          notificationsEnabled: dataMap['notificationsEnabled'],
          notificationTime: dataMap['notificationTime'],
          languageCode: dataMap['languageCode'],
          countryCode: dataMap['countryCode'],
          dataConsentGiven: dataMap['dataConsentGiven'],
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      // 보안 저장소 클리어
      await _secureStorage.deleteAll();

      // SharedPreferences 클리어
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyUserProfile);
      await prefs.remove(AppConstants.keyOnboardingCompleted);
      await prefs.remove(AppConstants.keyAutoLogin);

      // 상태 초기화
      _isAuthenticated = false;
      _isOnboardingCompleted = false;
      _accessToken = null;
      _refreshToken = null;
      _userProfile = null;
      _errorMessage = null;
      _isLoading = false;

      notifyListeners();
    } catch (e) {
      _errorMessage = '로그아웃 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  /// 토큰 갱신
  Future<bool> refreshTokens() async {
    try {
      if (_refreshToken == null) return false;

      // TODO: 실제 토큰 갱신 API 호출
      await Future.delayed(const Duration(milliseconds: 500));

      // 새 토큰 (임시)
      _accessToken = 'new_access_token_${DateTime.now().millisecondsSinceEpoch}';
      
      await _secureStorage.write(key: AppConstants.keyAccessToken, value: _accessToken);
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '토큰 갱신에 실패했습니다: $e';
      await logout(); // 토큰 갱신 실패 시 로그아웃
      return false;
    }
  }

  /// 사용자 프로필 업데이트
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      notifyListeners();

      // TODO: 실제 API 호출
      await Future.delayed(const Duration(seconds: 1));

      _userProfile = {
        ..._userProfile!,
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserProfile, _userProfile.toString());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '프로필 업데이트에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 에러 메시지 클리어
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 개발용 더미 로그인 (빠른 테스트용)
  Future<void> devLogin() async {
    await login(
      email: 'test@hanoa.com',
      password: 'password123',
      autoLogin: true,
    );
  }

  /// 개발용 온보딩 완료
  Future<void> devCompleteOnboarding() async {
    final testData = OnboardingData(
      displayName: '테스트 사용자',
      preferredPackage: AppConstants.moduleStudyId,
      studyField: AppConstants.defaultStudyField,
      notificationsEnabled: true,
      notificationTime: AppConstants.defaultAlarmTime,
      languageCode: 'ko',
      countryCode: 'KR',
      dataConsentGiven: true,
    );
    await completeOnboarding(testData);
  }
}

/// AuthProvider를 위한 확장 메서드
extension AuthProviderExtension on BuildContext {
  AuthProvider get auth => read<AuthProvider>();
}