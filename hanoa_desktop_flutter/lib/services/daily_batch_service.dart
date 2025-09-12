import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

import '../models/usage_log.dart';
import '../models/usage_daily.dart';

class DailyBatchService {
  static final _instance = DailyBatchService._internal();
  static DailyBatchService get instance => _instance;
  DailyBatchService._internal();

  final Logger _logger = Logger();
  late Isar _isar;
  bool _isRunning = false;

  /// 서비스 초기화
  Future<void> initialize(Isar isar) async {
    _isar = isar;
  }

  /// 새벽 배치 작업 실행 (02:00 AM 기준)
  Future<void> runDailyBatch({DateTime? targetDate}) async {
    if (_isRunning) {
      _logger.w('배치 프로세스가 이미 실행 중입니다.');
      return;
    }

    _isRunning = true;
    final date = targetDate ?? DateTime.now().subtract(Duration(days: 1));
    final dateStr = _formatDate(date);

    try {
      _logger.i('일일 사용량 배치 시작: $dateStr');
      
      // 1. 해당 날짜의 로그 조회
      final logs = await _getUsageLogsForDate(date);
      _logger.i('처리할 로그 수: ${logs.length}개');

      if (logs.isEmpty) {
        _logger.i('처리할 로그가 없습니다: $dateStr');
        return;
      }

      // 2. 앱별, 공급자별, 모델별로 그룹화
      final groupedLogs = _groupLogsByKey(logs);
      _logger.i('그룹 수: ${groupedLogs.length}개');

      // 3. 기존 일일 통계 삭제 (재실행 대비)
      await _cleanupExistingDailyStats(dateStr);

      // 4. 새로운 일일 통계 생성 및 저장
      final dailyStats = <UsageDaily>[];
      
      for (final entry in groupedLogs.entries) {
        final keyParts = entry.key.split('_');
        final appId = keyParts[0];
        final provider = keyParts[1];
        final model = keyParts[2];

        final daily = UsageDailyAggregator.aggregateFromLogs(
          date: dateStr,
          appId: appId,
          provider: provider,
          model: model,
          logs: entry.value,
        );

        dailyStats.add(daily);
      }

      // 5. 배치로 저장
      await _isar.writeTxn(() async {
        await _isar.usageDailys.putAll(dailyStats);
      });

      _logger.i('일일 통계 저장 완료: ${dailyStats.length}개');

      // 6. 주간/월간 통계 업데이트
      await _updatePeriodStats(date);

      // 7. 오래된 로그 정리 (선택적)
      await _cleanupOldLogs(date);

      _logger.i('일일 사용량 배치 완료: $dateStr');

    } catch (error, stackTrace) {
      _logger.e('배치 프로세스 실패', error: error, stackTrace: stackTrace);
      rethrow;
    } finally {
      _isRunning = false;
    }
  }

  /// 특정 날짜의 사용량 로그 조회
  Future<List<Map<String, dynamic>>> _getUsageLogsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final logs = await _isar.usageLogs
        .filter()
        .timestampBetween(startOfDay, endOfDay)
        .findAll();

    return logs.map((log) => {
      'app_id': log.appId,
      'provider': log.provider,
      'model': log.model,
      'status': log.status,
      'input_tokens': log.inputTokens,
      'output_tokens': log.outputTokens,
      'total_tokens': log.totalTokens,
      'response_time_ms': log.responseTimeMs,
      'cost': log.cost,
    }).toList();
  }

  /// 로그를 앱_공급자_모델 키로 그룹화
  Map<String, List<Map<String, dynamic>>> _groupLogsByKey(List<Map<String, dynamic>> logs) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final log in logs) {
      final key = '${log['app_id']}_${log['provider']}_${log['model']}';
      grouped.putIfAbsent(key, () => []).add(log);
    }

    return grouped;
  }

  /// 기존 일일 통계 삭제
  Future<void> _cleanupExistingDailyStats(String date) async {
    await _isar.writeTxn(() async {
      await _isar.usageDailys.filter().dateEqualTo(date).deleteAll();
    });
  }

  /// 주간/월간 통계 업데이트
  Future<void> _updatePeriodStats(DateTime date) async {
    try {
      // 주간 통계 업데이트
      await _updateWeeklyStats(date);
      
      // 월간 통계 업데이트
      await _updateMonthlyStats(date);

    } catch (error) {
      _logger.w('기간별 통계 업데이트 실패', error: error);
    }
  }

  /// 주간 통계 업데이트
  Future<void> _updateWeeklyStats(DateTime date) async {
    final weekPeriod = UsageDailyAggregator.formatWeek(date);
    final weekStart = _getWeekStart(date);
    final weekEnd = weekStart.add(Duration(days: 6));

    // 해당 주의 모든 일일 통계 조회
    final weeklyLogs = await _isar.usageDailys
        .filter()
        .dateGreaterThan(_formatDate(weekStart.subtract(Duration(days: 1))))
        .and()
        .dateLessThan(_formatDate(weekEnd.add(Duration(days: 1))))
        .findAll();

    // 앱_공급자_모델별로 그룹화하여 주간 통계 생성
    final groupedByKey = <String, List<UsageDaily>>{};
    for (final daily in weeklyLogs) {
      final key = '${daily.appId}_${daily.provider}_${daily.model}';
      groupedByKey.putIfAbsent(key, () => []).add(daily);
    }

    // 기존 주간 통계 삭제
    await _isar.writeTxn(() async {
      await _isar.usageDailys.filter().dateEqualTo(weekPeriod).deleteAll();
    });

    // 새로운 주간 통계 생성 및 저장
    final weeklyStats = <UsageDaily>[];
    for (final entry in groupedByKey.entries) {
      final keyParts = entry.key.split('_');
      final weekly = UsageDailyAggregator.mergePeriod(
        period: weekPeriod,
        appId: keyParts[0],
        provider: keyParts[1],
        model: keyParts[2],
        dailyStats: entry.value,
      );
      weeklyStats.add(weekly);
    }

    await _isar.writeTxn(() async {
      await _isar.usageDailys.putAll(weeklyStats);
    });

    _logger.i('주간 통계 업데이트 완료: $weekPeriod (${weeklyStats.length}개)');
  }

  /// 월간 통계 업데이트
  Future<void> _updateMonthlyStats(DateTime date) async {
    final monthPeriod = UsageDailyAggregator.formatMonth(date);
    final monthStart = DateTime(date.year, date.month, 1);
    final monthEnd = DateTime(date.year, date.month + 1, 0);

    // 해당 월의 모든 일일 통계 조회
    final monthlyLogs = await _isar.usageDailys
        .filter()
        .dateGreaterThan(_formatDate(monthStart.subtract(Duration(days: 1))))
        .and()
        .dateLessThan(_formatDate(monthEnd.add(Duration(days: 1))))
        .and()
        .dateContains('-') // 일일 형식 (YYYY-MM-DD)만 포함
        .and()
        .not().dateContains('week') // 주간 통계 제외
        .findAll();

    // 앱_공급자_모델별로 그룹화
    final groupedByKey = <String, List<UsageDaily>>{};
    for (final daily in monthlyLogs) {
      final key = '${daily.appId}_${daily.provider}_${daily.model}';
      groupedByKey.putIfAbsent(key, () => []).add(daily);
    }

    // 기존 월간 통계 삭제
    await _isar.writeTxn(() async {
      await _isar.usageDailys.filter().dateEqualTo(monthPeriod).deleteAll();
    });

    // 새로운 월간 통계 생성 및 저장
    final monthlyStats = <UsageDaily>[];
    for (final entry in groupedByKey.entries) {
      final keyParts = entry.key.split('_');
      final monthly = UsageDailyAggregator.mergePeriod(
        period: monthPeriod,
        appId: keyParts[0],
        provider: keyParts[1],
        model: keyParts[2],
        dailyStats: entry.value,
      );
      monthlyStats.add(monthly);
    }

    await _isar.writeTxn(() async {
      await _isar.usageDailys.putAll(monthlyStats);
    });

    _logger.i('월간 통계 업데이트 완료: $monthPeriod (${monthlyStats.length}개)');
  }

  /// 오래된 로그 정리 (90일 이전)
  Future<void> _cleanupOldLogs(DateTime currentDate) async {
    final cutoffDate = currentDate.subtract(Duration(days: 90));
    
    try {
      final deletedCount = await _isar.writeTxn(() async {
        return await _isar.usageLogs
            .filter()
            .timestampLessThan(cutoffDate)
            .deleteAll();
      });

      if (deletedCount > 0) {
        _logger.i('오래된 로그 정리 완료: ${deletedCount}개');
      }
    } catch (error) {
      _logger.w('오래된 로그 정리 실패', error: error);
    }
  }

  /// 자동 스케줄링 시작 (매일 02:00)
  Future<void> startScheduler() async {
    _logger.i('일일 배치 스케줄러 시작');
    
    // 다음 02:00 시간 계산
    DateTime nextRun = _getNext2AM();
    
    while (true) {
      final now = DateTime.now();
      
      if (now.isAfter(nextRun)) {
        try {
          await runDailyBatch();
        } catch (error) {
          _logger.e('스케줄된 배치 실행 실패', error: error);
        }
        
        // 다음 02:00 계산
        nextRun = _getNext2AM();
      }
      
      // 1분마다 체크
      await Future.delayed(Duration(minutes: 1));
    }
  }

  /// 수동 배치 실행 (특정 기간)
  Future<void> runBatchForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _logger.i('기간별 배치 실행: ${_formatDate(startDate)} ~ ${_formatDate(endDate)}');
    
    DateTime current = startDate;
    
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      try {
        await runDailyBatch(targetDate: current);
        current = current.add(Duration(days: 1));
      } catch (error) {
        _logger.e('날짜별 배치 실패: ${_formatDate(current)}', error: error);
        current = current.add(Duration(days: 1)); // 계속 진행
      }
    }
    
    _logger.i('기간별 배치 완료');
  }

  /// 통계 조회 메서드들
  
  /// 일일 통계 조회
  Future<List<UsageDaily>> getDailyStats({
    String? date,
    String? appId,
    String? provider,
    String? model,
    int limit = 100,
  }) async {
    List<UsageDaily> results;
    
    if (date != null) {
      results = await _isar.usageDailys.filter().dateEqualTo(date).findAll();
    } else if (appId != null) {
      results = await _isar.usageDailys.filter().appIdEqualTo(appId).findAll();
    } else if (provider != null) {
      results = await _isar.usageDailys.filter().providerEqualTo(provider).findAll();
    } else if (model != null) {
      results = await _isar.usageDailys.filter().modelEqualTo(model).findAll();
    } else {
      results = await _isar.usageDailys.where().findAll();
    }
    
    results.sort((a, b) => b.date.compareTo(a.date));
    return results.take(limit).toList();
  }

  /// 기간별 통계 조회
  Future<List<UsageDaily>> getPeriodStats({
    required String period, // 'daily', 'weekly', 'monthly'
    DateTime? startDate,
    DateTime? endDate,
    String? appId,
    String? provider,
  }) async {
    List<UsageDaily> results;

    // 기간별 필터링 로직을 단순화
    if (period == 'weekly') {
      results = await _isar.usageDailys.filter().dateContains('week').findAll();
    } else if (period == 'monthly') {
      results = await _isar.usageDailys.filter()
          .dateContains('-')
          .and()
          .not()
          .dateContains('week')
          .findAll();
    } else {
      // daily: YYYY-MM-DD 형식 (기본)
      results = await _isar.usageDailys.filter()
          .dateContains('-')
          .and()
          .not()
          .dateContains('week')
          .findAll();
    }

    // 추가 필터링 적용
    if (appId != null) {
      results = results.where((r) => r.appId == appId).toList();
    }
    if (provider != null) {
      results = results.where((r) => r.provider == provider).toList();
    }

    results.sort((a, b) => a.date.compareTo(b.date));
    return results;
  }

  /// 헬퍼 메서드들

  String _formatDate(DateTime date) => 
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DateTime _getNext2AM() {
    final now = DateTime.now();
    final tomorrow = now.add(Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 2, 0);
  }

  DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return date.subtract(Duration(days: daysFromMonday));
  }

  /// 배치 상태 확인
  bool get isRunning => _isRunning;

  /// 최근 배치 실행 정보
  Future<Map<String, dynamic>> getBatchStatus() async {
    final latestDaily = await _isar.usageDailys
        .where()
        .sortByCreatedAtDesc()
        .findFirst();

    final totalLogs = await _isar.usageLogs.count();
    final totalDaily = await _isar.usageDailys.count();

    return {
      'is_running': _isRunning,
      'total_logs': totalLogs,
      'total_daily_stats': totalDaily,
      'latest_batch_date': latestDaily?.date,
      'latest_batch_time': latestDaily?.createdAt.toIso8601String(),
      'next_run_time': _getNext2AM().toIso8601String(),
    };
  }
}