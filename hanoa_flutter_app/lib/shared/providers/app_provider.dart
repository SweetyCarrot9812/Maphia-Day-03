import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../services/content_version_service.dart';

/// 전역 앱 상태 관리 Provider
class AppProvider extends ChangeNotifier {
  // Private fields
  bool _isLoading = false;
  String? _errorMessage;
  Locale _locale = const Locale('ko', 'KR');
  ThemeMode _themeMode = ThemeMode.system;
  
  // Beta 상태
  bool _isBetaFree = true;
  bool _showBetaBadge = true;
  
  // Feature flags
  final Map<String, bool> _featureFlags = {
    AppConstants.flagOnboardingEnabled: true,
    AppConstants.flagBetaBadgeEnabled: true,
    AppConstants.flagNewsEnabled: false, // 뉴스/기사 후순위
  };

  // 앱 설정
  bool _notificationsEnabled = true;
  String _notificationTime = AppConstants.defaultAlarmTime;
  
  // 모듈 상태
  final Map<String, ModuleStatus> _moduleStatuses = {
    AppConstants.moduleStudyId: ModuleStatus.installed,
    AppConstants.moduleExerciseId: ModuleStatus.needsInstall,
    AppConstants.moduleRestaurantId: ModuleStatus.needsInstall,
    AppConstants.moduleChristianId: ModuleStatus.needsInstall,
  };
  
  // 콘텐츠 버전 관리
  Map<String, String> _contentVersions = {};
  bool _hasContentUpdates = false;
  DateTime? _lastVersionCheck;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get isBetaFree => _isBetaFree;
  bool get showBetaBadge => _showBetaBadge;
  Map<String, bool> get featureFlags => Map.unmodifiable(_featureFlags);
  bool get notificationsEnabled => _notificationsEnabled;
  String get notificationTime => _notificationTime;
  Map<String, ModuleStatus> get moduleStatuses => Map.unmodifiable(_moduleStatuses);
  Map<String, String> get contentVersions => Map.unmodifiable(_contentVersions);
  bool get hasContentUpdates => _hasContentUpdates;
  DateTime? get lastVersionCheck => _lastVersionCheck;

  /// Feature flag 확인
  bool isFeatureEnabled(String flagName) {
    return _featureFlags[flagName] ?? false;
  }

  /// 모듈 상태 확인
  ModuleStatus getModuleStatus(String moduleId) {
    return _moduleStatuses[moduleId] ?? ModuleStatus.needsInstall;
  }

  /// 초기화
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();

      // 언어 설정 로드
      final languageCode = prefs.getString(AppConstants.keyLanguageCode) ?? 'ko';
      final countryCode = prefs.getString(AppConstants.keyCountryCode) ?? 'KR';
      _locale = Locale(languageCode, countryCode);

      // 콘텐츠 버전 관리 서비스 초기화
      await ContentVersionService.initialize();
      await _updateContentVersions();

      // 기타 설정들 로드
      // TODO: 서버에서 설정 동기화

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '앱 초기화 중 오류가 발생했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 언어 변경
  Future<void> changeLocale(Locale newLocale) async {
    try {
      _locale = newLocale;
      notifyListeners();

      // 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyLanguageCode, newLocale.languageCode);
      await prefs.setString(AppConstants.keyCountryCode, newLocale.countryCode ?? '');
    } catch (e) {
      _errorMessage = '언어 설정 변경에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 테마 모드 변경
  void changeThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// 알림 설정 변경
  Future<void> updateNotificationSettings({
    bool? enabled,
    String? time,
  }) async {
    try {
      if (enabled != null) {
        _notificationsEnabled = enabled;
      }
      if (time != null) {
        _notificationTime = time;
      }
      
      notifyListeners();

      // TODO: 서버에 설정 동기화
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setString('notification_time', _notificationTime);
    } catch (e) {
      _errorMessage = '알림 설정 변경에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 모듈 설치
  Future<bool> installModule(String moduleId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 설치 시뮬레이션
      await Future.delayed(const Duration(seconds: 2));

      _moduleStatuses[moduleId] = ModuleStatus.installed;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '모듈 설치에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 모듈 업데이트
  Future<bool> updateModule(String moduleId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 업데이트 시뮬레이션
      await Future.delayed(const Duration(seconds: 1));

      _moduleStatuses[moduleId] = ModuleStatus.installed;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '모듈 업데이트에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Feature flag 업데이트 (원격 설정)
  void updateFeatureFlags(Map<String, bool> flags) {
    _featureFlags.addAll(flags);
    notifyListeners();
  }

  /// Beta 상태 업데이트
  void updateBetaStatus({bool? isBetaFree, bool? showBadge}) {
    if (isBetaFree != null) {
      _isBetaFree = isBetaFree;
    }
    if (showBadge != null) {
      _showBetaBadge = showBadge;
    }
    notifyListeners();
  }

  /// 로딩 상태 설정
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 에러 메시지 설정
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// 에러 클리어
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 앱 재시작 (설정 초기화)
  Future<void> restartApp() async {
    await initialize();
  }

  /// 개발용: 모든 모듈 설치됨으로 설정
  void devInstallAllModules() {
    for (final moduleId in _moduleStatuses.keys) {
      _moduleStatuses[moduleId] = ModuleStatus.installed;
    }
    notifyListeners();
  }

  /// 개발용: 특정 모듈 업데이트 필요로 설정
  void devSetModuleNeedsUpdate(String moduleId) {
    _moduleStatuses[moduleId] = ModuleStatus.needsUpdate;
    notifyListeners();
  }

  /// 콘텐츠 버전 정보 업데이트
  Future<void> _updateContentVersions() async {
    try {
      _contentVersions = ContentVersionService.getLocalVersions();
      _lastVersionCheck = ContentVersionService.getLastUpdateCheck();
      notifyListeners();
    } catch (e) {
      print('[AppProvider] 버전 정보 업데이트 실패: $e');
    }
  }

  /// 콘텐츠 업데이트 확인
  Future<void> checkContentUpdates() async {
    try {
      _isLoading = true;
      notifyListeners();

      final versionCheck = await ContentVersionService.checkForUpdates();
      
      if (versionCheck.error != null) {
        _errorMessage = versionCheck.error;
      } else {
        _hasContentUpdates = versionCheck.hasUpdates;
        await _updateContentVersions();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '콘텐츠 업데이트 확인 실패: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 모든 콘텐츠 업데이트
  Future<bool> updateAllContent() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await ContentVersionService.updateAllContent();
      
      if (!result.success) {
        _errorMessage = result.message;
      } else {
        _hasContentUpdates = false;
        await _updateContentVersions();
      }

      _isLoading = false;
      notifyListeners();
      
      return result.success;
    } catch (e) {
      _errorMessage = '콘텐츠 업데이트 실패: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 특정 패키지 콘텐츠 업데이트
  Future<bool> updatePackageContent(String packageId, String targetVersion) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await ContentVersionService.updatePackageContent(packageId, targetVersion);
      
      if (success) {
        await _updateContentVersions();
        
        // 업데이트 후 다시 확인
        final versionCheck = await ContentVersionService.checkForUpdates();
        _hasContentUpdates = versionCheck.hasUpdates;
      } else {
        _errorMessage = '$packageId 업데이트 실패';
      }

      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _errorMessage = '$packageId 업데이트 실패: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 특정 버전으로 롤백
  Future<bool> rollbackPackage(String packageId, String targetVersion) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await ContentVersionService.rollbackToVersion(packageId, targetVersion);
      
      if (success) {
        await _updateContentVersions();
      } else {
        _errorMessage = '$packageId 롤백 실패';
      }

      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _errorMessage = '$packageId 롤백 실패: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 개발용: 강제 버전 확인
  Future<void> devForceVersionCheck() async {
    await checkContentUpdates();
  }
}

/// 모듈 상태 열거형
enum ModuleStatus {
  needsInstall('설치 필요'),
  installing('설치 중'),
  installed('설치됨'),
  needsUpdate('업데이트'),
  updating('업데이트 중');

  const ModuleStatus(this.displayName);
  final String displayName;

  /// 설치가 필요한 상태인지
  bool get needsInstallation => this == ModuleStatus.needsInstall;
  
  /// 설치됨 상태인지
  bool get isInstalled => this == ModuleStatus.installed;
  
  /// 업데이트가 필요한 상태인지
  bool get needsUpdateCheck => this == ModuleStatus.needsUpdate;
  
  /// 진행 중인 상태인지 (설치중/업데이트중)
  bool get isInProgress => 
      this == ModuleStatus.installing || this == ModuleStatus.updating;
}

/// AppProvider를 위한 확장 메서드
extension AppProviderExtension on BuildContext {
  AppProvider get app => read<AppProvider>();
}