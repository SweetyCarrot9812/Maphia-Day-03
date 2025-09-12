import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/logger.dart';

/// 콘텐츠 버전 관리 서비스 - vYYYY.MM 형식의 버전 태그 관리
class ContentVersionService {
  static final _logger = Loggers.content;
  static const String _versionCacheKey = 'content_versions';
  static const String _lastUpdateKey = 'last_content_update';
  
  // 현재 로컬 버전 캐시
  static Map<String, String> _localVersions = {};
  static DateTime? _lastUpdateCheck;
  
  /// 서비스 초기화 - 로컬 버전 캐시 로드
  static Future<void> initialize() async {
    try {
      await _loadLocalVersions();
      _logger.info('로컬 버전 캐시 로드 완료: $_localVersions');
    } catch (e) {
      _logger.error('초기화 실패', e);
    }
  }
  
  /// 로컬에 저장된 버전 정보 로드
  static Future<void> _loadLocalVersions() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 버전 캐시 로드
    final versionsJson = prefs.getString(_versionCacheKey);
    if (versionsJson != null) {
      final decoded = jsonDecode(versionsJson) as Map<String, dynamic>;
      _localVersions = decoded.map((key, value) => MapEntry(key, value.toString()));
    }
    
    // 마지막 업데이트 시간 로드
    final lastUpdateMs = prefs.getInt(_lastUpdateKey);
    if (lastUpdateMs != null) {
      _lastUpdateCheck = DateTime.fromMillisecondsSinceEpoch(lastUpdateMs);
    }
  }
  
  /// 서버에서 최신 버전 정보 가져오기
  static Future<Map<String, String>> _fetchServerVersions() async {
    try {
      // TODO: 실제 서버 API 호출로 교체
      await Future.delayed(const Duration(milliseconds: 800));
      
      // 임시 서버 응답 시뮬레이션
      return {
        'med_content': 'v2025.09',      // 의학/간호학 콘텐츠
        'lang_content': 'v2025.09',     // 언어 학습 콘텐츠  
        'vocal_content': 'v2025.08',    // 보컬 트레이너 콘텐츠
        'app_config': 'v2025.09',       // 앱 설정/SDUI 
        'feature_flags': 'v2025.09',    // Feature Flag 설정
      };
    } catch (e) {
      print('[ContentVersion] 서버 버전 조회 실패: $e');
      return {};
    }
  }
  
  /// 버전 비교 및 업데이트 필요 여부 확인
  static Future<ContentVersionCheck> checkForUpdates() async {
    try {
      print('[ContentVersion] 버전 확인 시작...');
      
      final serverVersions = await _fetchServerVersions();
      if (serverVersions.isEmpty) {
        return ContentVersionCheck(
          hasUpdates: false,
          error: '서버 버전 정보를 가져올 수 없습니다',
        );
      }
      
      final updatesNeeded = <String, VersionComparison>{}; 
      
      // 패키지별 버전 비교
      for (final entry in serverVersions.entries) {
        final packageId = entry.key;
        final serverVersion = entry.value;
        final localVersion = _localVersions[packageId];
        
        final comparison = VersionComparison(
          packageId: packageId,
          localVersion: localVersion,
          serverVersion: serverVersion,
          needsUpdate: localVersion != serverVersion,
        );
        
        if (comparison.needsUpdate) {
          updatesNeeded[packageId] = comparison;
        }
      }
      
      final result = ContentVersionCheck(
        hasUpdates: updatesNeeded.isNotEmpty,
        updatesNeeded: updatesNeeded,
        serverVersions: serverVersions,
      );
      
      print('[ContentVersion] 버전 확인 완료: ${updatesNeeded.length}개 업데이트 필요');
      return result;
    } catch (e) {
      print('[ContentVersion] 버전 확인 실패: $e');
      return ContentVersionCheck(
        hasUpdates: false,
        error: e.toString(),
      );
    }
  }
  
  /// 특정 패키지 콘텐츠 업데이트 실행
  static Future<bool> updatePackageContent(String packageId, String targetVersion) async {
    try {
      print('[ContentVersion] 패키지 업데이트 시작: $packageId -> $targetVersion');
      
      // 콘텐츠 다운로드 시뮬레이션
      await _downloadPackageContent(packageId, targetVersion);
      
      // 로컬 버전 캐시 업데이트
      _localVersions[packageId] = targetVersion;
      await _saveLocalVersions();
      
      print('[ContentVersion] 패키지 업데이트 완료: $packageId');
      return true;
    } catch (e) {
      print('[ContentVersion] 패키지 업데이트 실패 $packageId: $e');
      return false;
    }
  }
  
  /// 패키지 콘텐츠 다운로드 (실제로는 API에서 데이터 받아옴)
  static Future<void> _downloadPackageContent(String packageId, String version) async {
    switch (packageId) {
      case 'med_content':
        await _downloadMedicalContent(version);
        break;
      case 'lang_content':
        await _downloadLanguageContent(version);
        break;
      case 'vocal_content':
        await _downloadVocalContent(version);
        break;
      case 'app_config':
        await _downloadAppConfig(version);
        break;
      case 'feature_flags':
        await _downloadFeatureFlags(version);
        break;
      default:
        throw Exception('알 수 없는 패키지: $packageId');
    }
  }
  
  /// 의학/간호학 콘텐츠 다운로드
  static Future<void> _downloadMedicalContent(String version) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    // TODO: 실제 API 호출 - 문제은행, 개념, 태그 등
    print('[ContentVersion] 의학 콘텐츠 다운로드 완료: $version');
  }
  
  /// 언어 학습 콘텐츠 다운로드
  static Future<void> _downloadLanguageContent(String version) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    // TODO: 실제 API 호출 - SRS 카드, CEFR 패턴 등
    print('[ContentVersion] 언어 콘텐츠 다운로드 완료: $version');
  }
  
  /// 보컬 트레이너 콘텐츠 다운로드
  static Future<void> _downloadVocalContent(String version) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    // TODO: 실제 API 호출 - 발성 연습, 호흡 가이드 등
    print('[ContentVersion] 보컬 콘텐츠 다운로드 완료: $version');
  }
  
  /// 앱 설정/SDUI 다운로드
  static Future<void> _downloadAppConfig(String version) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: 실제 API 호출 - SDUI 설정, 테마 등
    print('[ContentVersion] 앱 설정 다운로드 완료: $version');
  }
  
  /// Feature Flag 다운로드
  static Future<void> _downloadFeatureFlags(String version) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: 실제 API 호출 - 모듈 활성화 상태 등
    print('[ContentVersion] Feature Flag 다운로드 완료: $version');
  }
  
  /// 로컬 버전 정보 저장
  static Future<void> _saveLocalVersions() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 버전 캐시 저장
    final versionsJson = jsonEncode(_localVersions);
    await prefs.setString(_versionCacheKey, versionsJson);
    
    // 업데이트 시간 저장
    _lastUpdateCheck = DateTime.now();
    await prefs.setInt(_lastUpdateKey, _lastUpdateCheck!.millisecondsSinceEpoch);
  }
  
  /// 전체 콘텐츠 업데이트 (일괄)
  static Future<ContentUpdateResult> updateAllContent() async {
    try {
      print('[ContentVersion] 전체 콘텐츠 업데이트 시작');
      
      final versionCheck = await checkForUpdates();
      if (!versionCheck.hasUpdates) {
        return ContentUpdateResult(
          success: true,
          message: '모든 콘텐츠가 최신 버전입니다',
        );
      }
      
      final results = <String, bool>{};
      var successCount = 0;
      
      // 각 패키지별 업데이트 실행
      for (final entry in versionCheck.updatesNeeded!.entries) {
        final packageId = entry.key;
        final comparison = entry.value;
        
        final success = await updatePackageContent(packageId, comparison.serverVersion);
        results[packageId] = success;
        
        if (success) {
          successCount++;
        }
      }
      
      final totalUpdates = versionCheck.updatesNeeded!.length;
      final message = '$successCount/$totalUpdates 패키지 업데이트 완료';
      
      print('[ContentVersion] 전체 업데이트 완료: $message');
      
      return ContentUpdateResult(
        success: successCount == totalUpdates,
        message: message,
        packageResults: results,
      );
    } catch (e) {
      print('[ContentVersion] 전체 업데이트 실패: $e');
      return ContentUpdateResult(
        success: false,
        message: '업데이트 중 오류 발생: $e',
      );
    }
  }
  
  /// 특정 버전으로 롤백
  static Future<bool> rollbackToVersion(String packageId, String targetVersion) async {
    try {
      print('[ContentVersion] 롤백 시작: $packageId -> $targetVersion');
      
      // TODO: 실제 롤백 로직 (서버에서 이전 버전 데이터 가져오기)
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // 로컬 버전 정보 업데이트
      _localVersions[packageId] = targetVersion;
      await _saveLocalVersions();
      
      print('[ContentVersion] 롤백 완료: $packageId');
      return true;
    } catch (e) {
      print('[ContentVersion] 롤백 실패 $packageId: $e');
      return false;
    }
  }
  
  /// 현재 로컬 버전 정보 가져오기
  static Map<String, String> getLocalVersions() {
    return Map.unmodifiable(_localVersions);
  }
  
  /// 특정 패키지의 로컬 버전 조회
  static String? getPackageVersion(String packageId) {
    return _localVersions[packageId];
  }
  
  /// 마지막 업데이트 확인 시간
  static DateTime? getLastUpdateCheck() {
    return _lastUpdateCheck;
  }
  
  /// 버전 비교 (v2025.09 형식)
  static bool isVersionNewer(String currentVersion, String newVersion) {
    // 간단한 문자열 비교 (vYYYY.MM 형식 가정)
    return newVersion.compareTo(currentVersion) > 0;
  }
}

/// 버전 확인 결과
class ContentVersionCheck {
  final bool hasUpdates;
  final Map<String, VersionComparison>? updatesNeeded;
  final Map<String, String>? serverVersions;
  final String? error;

  ContentVersionCheck({
    required this.hasUpdates,
    this.updatesNeeded,
    this.serverVersions,
    this.error,
  });
}

/// 패키지별 버전 비교 정보
class VersionComparison {
  final String packageId;
  final String? localVersion;
  final String serverVersion;
  final bool needsUpdate;

  VersionComparison({
    required this.packageId,
    this.localVersion,
    required this.serverVersion,
    required this.needsUpdate,
  });
}

/// 콘텐츠 업데이트 결과
class ContentUpdateResult {
  final bool success;
  final String message;
  final Map<String, bool>? packageResults;

  ContentUpdateResult({
    required this.success,
    required this.message,
    this.packageResults,
  });
}