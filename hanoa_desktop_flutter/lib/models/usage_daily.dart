import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'usage_daily.g.dart';

@collection
@JsonSerializable()
class UsageDaily {
  Id id = Isar.autoIncrement;

  /// 일자 (YYYY-MM-DD 형식)
  @Index()
  @JsonKey(defaultValue: '')
  String date = '';

  /// 앱 식별자
  @Index()
  @JsonKey(defaultValue: '')
  String appId = '';

  /// LLM 공급자
  @Index()
  @JsonKey(defaultValue: '')
  String provider = '';

  /// 모델명
  @Index()
  @JsonKey(defaultValue: '')
  String model = '';

  /// 총 요청 수
  @JsonKey(defaultValue: 0)
  int totalRequests = 0;

  /// 성공한 요청 수
  @JsonKey(defaultValue: 0)
  int successfulRequests = 0;

  /// 실패한 요청 수
  @JsonKey(defaultValue: 0)
  int failedRequests = 0;

  /// 총 입력 토큰 수
  @JsonKey(defaultValue: 0)
  int totalInputTokens = 0;

  /// 총 출력 토큰 수
  @JsonKey(defaultValue: 0)
  int totalOutputTokens = 0;

  /// 총 토큰 수
  @JsonKey(defaultValue: 0)
  int totalTokens = 0;

  /// 총 비용 (USD)
  @JsonKey(defaultValue: 0.0)
  double totalCost = 0.0;

  /// 평균 응답 시간 (밀리초)
  @JsonKey(defaultValue: 0.0)
  double avgResponseTimeMs = 0.0;

  /// 오류율 (0.0 ~ 1.0)
  @JsonKey(defaultValue: 0.0)
  double errorRate = 0.0;

  /// 최대 응답 시간 (밀리초)
  @JsonKey(defaultValue: 0)
  int maxResponseTimeMs = 0;

  /// 최소 응답 시간 (밀리초)
  @JsonKey(defaultValue: 0)
  int minResponseTimeMs = 0;

  /// 생성 시간
  @JsonKey(name: 'created_at')
  DateTime createdAt = DateTime.now();

  /// 업데이트 시간
  @JsonKey(name: 'updated_at')
  DateTime updatedAt = DateTime.now();

  UsageDaily();

  factory UsageDaily.fromJson(Map<String, dynamic> json) => _$UsageDailyFromJson(json);
  Map<String, dynamic> toJson() => _$UsageDailyToJson(this);

  @override
  String toString() {
    return 'UsageDaily{date: $date, appId: $appId, provider: $provider, model: $model, '
           'requests: $totalRequests, cost: \$$totalCost, errorRate: ${(errorRate * 100).toStringAsFixed(1)}%}';
  }

  /// 복합 키 생성 (날짜_앱_프로바이더_모델)
  String get compositeKey => '${date}_${appId}_${provider}_$model';

  /// 성공률 계산 (0.0 ~ 1.0)
  double get successRate => totalRequests > 0 ? successfulRequests / totalRequests : 0.0;

  /// 평균 토큰당 비용 계산 (USD per token)
  double get costPerToken => totalTokens > 0 ? totalCost / totalTokens : 0.0;

  /// 요청당 평균 비용 계산 (USD per request)
  double get costPerRequest => totalRequests > 0 ? totalCost / totalRequests : 0.0;

  /// 요청당 평균 토큰 수
  double get tokensPerRequest => totalRequests > 0 ? totalTokens / totalRequests : 0.0;
}

/// 일일 사용량 집계를 위한 헬퍼 클래스
class UsageDailyAggregator {
  
  /// 특정 날짜의 사용량 로그를 일일 통계로 집계
  static UsageDaily aggregateFromLogs({
    required String date,
    required String appId,
    required String provider,
    required String model,
    required List<Map<String, dynamic>> logs,
  }) {
    final daily = UsageDaily()
      ..date = date
      ..appId = appId
      ..provider = provider
      ..model = model
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    if (logs.isEmpty) return daily;

    // 기본 카운터
    daily.totalRequests = logs.length;
    daily.successfulRequests = logs.where((log) => log['status'] == 'success').length;
    daily.failedRequests = daily.totalRequests - daily.successfulRequests;

    // 토큰 및 비용 집계
    for (final log in logs) {
      daily.totalInputTokens += (log['input_tokens'] as int? ?? 0);
      daily.totalOutputTokens += (log['output_tokens'] as int? ?? 0);
      daily.totalTokens += (log['total_tokens'] as int? ?? 0);
      daily.totalCost += (log['cost'] as double? ?? 0.0);
    }

    // 응답 시간 통계
    final responseTimes = logs
        .map((log) => log['response_time_ms'] as int? ?? 0)
        .where((time) => time > 0)
        .toList();

    if (responseTimes.isNotEmpty) {
      daily.avgResponseTimeMs = responseTimes.reduce((a, b) => a + b) / responseTimes.length;
      daily.maxResponseTimeMs = responseTimes.reduce((a, b) => a > b ? a : b);
      daily.minResponseTimeMs = responseTimes.reduce((a, b) => a < b ? a : b);
    }

    // 오류율 계산
    daily.errorRate = daily.totalRequests > 0 ? daily.failedRequests / daily.totalRequests : 0.0;

    return daily;
  }

  /// 여러 일일 통계를 기간별로 병합
  static UsageDaily mergePeriod({
    required String period, // 예: "2025-09-week-36", "2025-09"
    required String appId,
    required String provider,
    required String model,
    required List<UsageDaily> dailyStats,
  }) {
    final merged = UsageDaily()
      ..date = period
      ..appId = appId
      ..provider = provider
      ..model = model
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    if (dailyStats.isEmpty) return merged;

    // 합계 계산
    for (final daily in dailyStats) {
      merged.totalRequests += daily.totalRequests;
      merged.successfulRequests += daily.successfulRequests;
      merged.failedRequests += daily.failedRequests;
      merged.totalInputTokens += daily.totalInputTokens;
      merged.totalOutputTokens += daily.totalOutputTokens;
      merged.totalTokens += daily.totalTokens;
      merged.totalCost += daily.totalCost;
    }

    // 평균 응답 시간 계산 (가중평균)
    double totalWeightedResponseTime = 0;
    int totalRequestsForAvg = 0;

    for (final daily in dailyStats) {
      if (daily.totalRequests > 0 && daily.avgResponseTimeMs > 0) {
        totalWeightedResponseTime += daily.avgResponseTimeMs * daily.totalRequests;
        totalRequestsForAvg += daily.totalRequests;
      }
    }

    if (totalRequestsForAvg > 0) {
      merged.avgResponseTimeMs = totalWeightedResponseTime / totalRequestsForAvg;
    }

    // 최대/최소 응답 시간
    final maxTimes = dailyStats.map((d) => d.maxResponseTimeMs).where((t) => t > 0);
    final minTimes = dailyStats.map((d) => d.minResponseTimeMs).where((t) => t > 0);

    if (maxTimes.isNotEmpty) {
      merged.maxResponseTimeMs = maxTimes.reduce((a, b) => a > b ? a : b);
    }
    if (minTimes.isNotEmpty) {
      merged.minResponseTimeMs = minTimes.reduce((a, b) => a < b ? a : b);
    }

    // 오류율 재계산
    merged.errorRate = merged.totalRequests > 0 ? merged.failedRequests / merged.totalRequests : 0.0;

    return merged;
  }

  /// 날짜 형식 생성 헬퍼
  static String formatDate(DateTime date) => 
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String formatWeek(DateTime date) {
    final weekNumber = _getWeekNumber(date);
    return '${date.year}-week-$weekNumber';
  }

  static String formatMonth(DateTime date) => 
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';

  static int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(startOfYear).inDays;
    return ((daysDifference + startOfYear.weekday) / 7).ceil();
  }
}