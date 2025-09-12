import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 성능 모니터링 및 최적화 서비스
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final Map<String, DateTime> _operationStartTimes = {};
  final Map<String, List<int>> _operationDurations = {};
  final List<String> _performanceLogs = [];
  
  Timer? _memoryMonitorTimer;
  Timer? _performanceReportTimer;
  
  bool _isMonitoring = false;

  /// 성능 모니터링 시작
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    
    // 메모리 사용량 주기적 체크 (30초마다)
    _memoryMonitorTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkMemoryUsage(),
    );
    
    // 성능 리포트 주기적 생성 (5분마다)
    _performanceReportTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _generatePerformanceReport(),
    );
    
    debugPrint('Performance monitoring started');
  }

  /// 성능 모니터링 중지
  void stopMonitoring() {
    _isMonitoring = false;
    _memoryMonitorTimer?.cancel();
    _performanceReportTimer?.cancel();
    debugPrint('Performance monitoring stopped');
  }

  /// 작업 시작 시간 기록
  void startOperation(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
  }

  /// 작업 완료 시간 기록
  void endOperation(String operationName) {
    final startTime = _operationStartTimes.remove(operationName);
    if (startTime == null) return;

    final duration = DateTime.now().difference(startTime).inMilliseconds;
    
    if (!_operationDurations.containsKey(operationName)) {
      _operationDurations[operationName] = [];
    }
    
    _operationDurations[operationName]!.add(duration);
    
    // 느린 작업 감지 (2초 초과)
    if (duration > 2000) {
      _logPerformanceIssue('SLOW_OPERATION', {
        'operation': operationName,
        'duration': duration,
        'threshold': 2000,
      });
    }
    
    debugPrint('Operation "$operationName" completed in ${duration}ms');
  }

  /// 데이터베이스 쿼리 성능 측정
  Future<T> measureDatabaseQuery<T>(
    String queryName,
    Future<T> Function() query,
  ) async {
    startOperation('db_query_$queryName');
    
    try {
      final result = await query();
      endOperation('db_query_$queryName');
      return result;
    } catch (e) {
      endOperation('db_query_$queryName');
      _logPerformanceIssue('DATABASE_ERROR', {
        'query': queryName,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// 네트워크 요청 성능 측정
  Future<T> measureNetworkRequest<T>(
    String requestName,
    Future<T> Function() request,
  ) async {
    startOperation('network_$requestName');
    
    try {
      final result = await request();
      endOperation('network_$requestName');
      return result;
    } catch (e) {
      endOperation('network_$requestName');
      _logPerformanceIssue('NETWORK_ERROR', {
        'request': requestName,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// UI 렌더링 성능 측정
  void measureUIOperation(String operationName, VoidCallback operation) {
    startOperation('ui_$operationName');
    
    try {
      operation();
      endOperation('ui_$operationName');
    } catch (e) {
      endOperation('ui_$operationName');
      _logPerformanceIssue('UI_ERROR', {
        'operation': operationName,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// 메모리 사용량 체크
  Future<void> _checkMemoryUsage() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // 플랫폼별 메모리 정보 수집 (실제 구현에서는 플랫폼 채널 사용)
        final memoryInfo = await _getMemoryInfo();
        
        if (memoryInfo['usedMemoryMB'] > 500) { // 500MB 초과 시 경고
          _logPerformanceIssue('HIGH_MEMORY_USAGE', {
            'usedMemory': memoryInfo['usedMemoryMB'],
            'totalMemory': memoryInfo['totalMemoryMB'],
            'threshold': 500,
          });
        }
      }
    } catch (e) {
      debugPrint('Memory check failed: $e');
    }
  }

  /// 메모리 정보 수집 (실제 구현에서는 플랫폼 채널 사용)
  Future<Map<String, dynamic>> _getMemoryInfo() async {
    // 개발용 더미 데이터
    return {
      'usedMemoryMB': 200 + DateTime.now().millisecond % 300,
      'totalMemoryMB': 4096,
    };
  }

  /// 성능 이슈 로깅
  void _logPerformanceIssue(String issueType, Map<String, dynamic> details) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '$timestamp - $issueType: $details';
    
    _performanceLogs.add(logEntry);
    debugPrint('PERFORMANCE_ISSUE: $logEntry');
    
    // 로그 크기 제한 (최대 1000개)
    if (_performanceLogs.length > 1000) {
      _performanceLogs.removeRange(0, 500);
    }
  }

  /// 성능 리포트 생성
  Future<void> _generatePerformanceReport() async {
    final report = await getPerformanceReport();
    debugPrint('Performance Report: $report');
    
    // 필요시 원격 서버로 리포트 전송
    _sendPerformanceReport(report);
  }

  /// 성능 통계 조회
  Future<Map<String, dynamic>> getPerformanceReport() async {
    final report = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'operationStats': {},
      'recentIssues': _performanceLogs.take(10).toList(),
      'systemInfo': await _getSystemInfo(),
    };

    // 각 작업의 통계 계산
    for (final entry in _operationDurations.entries) {
      final durations = entry.value;
      if (durations.isEmpty) continue;

      final avgDuration = durations.reduce((a, b) => a + b) / durations.length;
      final maxDuration = durations.reduce((a, b) => a > b ? a : b);
      final minDuration = durations.reduce((a, b) => a < b ? a : b);

      report['operationStats'][entry.key] = {
        'count': durations.length,
        'averageDuration': avgDuration.round(),
        'maxDuration': maxDuration,
        'minDuration': minDuration,
      };
    }

    return report;
  }

  /// 시스템 정보 수집
  Future<Map<String, dynamic>> _getSystemInfo() async {
    return {
      'platform': Platform.operatingSystem,
      'platformVersion': Platform.operatingSystemVersion,
      'isDebug': kDebugMode,
      'isProfile': kProfileMode,
      'isRelease': kReleaseMode,
    };
  }

  /// 성능 리포트를 원격 서버로 전송
  void _sendPerformanceReport(Map<String, dynamic> report) {
    // 실제 구현에서는 HTTP 클라이언트를 통해 서버로 전송
    if (kDebugMode) {
      debugPrint('Performance report ready to send: ${report.keys}');
    }
  }

  /// 앱 시작 시간 최적화 체크
  void checkAppStartupPerformance() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final startupTime = DateTime.now().millisecondsSinceEpoch;
      // 앱 시작 시간이 3초를 초과하면 경고
      if (startupTime > 3000) {
        _logPerformanceIssue('SLOW_STARTUP', {
          'startupTime': startupTime,
          'threshold': 3000,
        });
      }
    });
  }

  /// 프레임 드롭 감지
  void detectFrameDrops() {
    if (kDebugMode) {
      // 개발 모드에서만 프레임 드롭 감지
      WidgetsBinding.instance.addTimingsCallback((timings) {
        for (final timing in timings) {
          final frameDuration = timing.totalSpan.inMilliseconds;
          // 16.67ms (60fps 기준) 초과 시 프레임 드롭으로 간주
          if (frameDuration > 16.67) {
            _logPerformanceIssue('FRAME_DROP', {
              'frameDuration': frameDuration,
              'threshold': 16.67,
            });
          }
        }
      });
    }
  }

  /// 캐시 효율성 분석
  void analyzeCacheEfficiency(String cacheType, int hits, int misses) {
    final hitRate = hits / (hits + misses);
    
    if (hitRate < 0.8) { // 히트율이 80% 미만이면 비효율적
      _logPerformanceIssue('LOW_CACHE_EFFICIENCY', {
        'cacheType': cacheType,
        'hits': hits,
        'misses': misses,
        'hitRate': hitRate,
        'threshold': 0.8,
      });
    }
  }

  /// 배터리 사용량 최적화 힌트
  List<String> getBatteryOptimizationHints() {
    final hints = <String>[];
    
    // 성능 통계 기반으로 힌트 생성
    for (final entry in _operationDurations.entries) {
      final avgDuration = entry.value.isEmpty 
          ? 0 
          : entry.value.reduce((a, b) => a + b) / entry.value.length;
      
      if (avgDuration > 1000) {
        hints.add('${entry.key} 작업을 최적화하면 배터리 사용량을 줄일 수 있습니다');
      }
    }
    
    return hints;
  }

  /// 성능 통계 초기화
  void clearPerformanceStats() {
    _operationDurations.clear();
    _performanceLogs.clear();
    debugPrint('Performance statistics cleared');
  }

  /// 성능 데이터를 로컬 저장소에 저장
  Future<void> savePerformanceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final report = await getPerformanceReport();
      await prefs.setString('last_performance_report', report.toString());
    } catch (e) {
      debugPrint('Failed to save performance data: $e');
    }
  }

  /// 메모리 누수 감지
  void detectMemoryLeaks() {
    Timer.periodic(const Duration(minutes: 10), (_) async {
      final memoryInfo = await _getMemoryInfo();
      final usedMemory = memoryInfo['usedMemoryMB'] as int;
      
      // 메모리 사용량이 지속적으로 증가하는지 확인
      final prefs = await SharedPreferences.getInstance();
      final lastMemoryUsage = prefs.getInt('last_memory_usage') ?? usedMemory;
      
      if (usedMemory > lastMemoryUsage + 100) { // 100MB 이상 증가
        _logPerformanceIssue('POTENTIAL_MEMORY_LEAK', {
          'currentMemory': usedMemory,
          'lastMemory': lastMemoryUsage,
          'increase': usedMemory - lastMemoryUsage,
        });
      }
      
      await prefs.setInt('last_memory_usage', usedMemory);
    });
  }

  /// 리소스 정리
  void dispose() {
    stopMonitoring();
    _operationStartTimes.clear();
    _operationDurations.clear();
    _performanceLogs.clear();
  }
}