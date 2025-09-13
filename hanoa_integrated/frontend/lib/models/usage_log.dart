import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'usage_log.g.dart';

@collection
@JsonSerializable()
class UsageLog {
  Id id = Isar.autoIncrement;

  /// 요청 고유 식별자 (UUID)
  @Index()
  @JsonKey(defaultValue: '')
  String requestId = '';

  /// 요청 시간
  @Index()
  @JsonKey(name: 'timestamp')
  DateTime timestamp = DateTime.now();

  /// 앱 식별자 (clintest, lingumo, areumfit, haneul_tone, hanoa_hub)
  @Index()
  @JsonKey(defaultValue: '')
  String appId = '';

  /// LLM 공급자 (openai, gemini, perplexity, anthropic)
  @Index()
  @JsonKey(defaultValue: '')
  String provider = '';

  /// 모델명 (gpt-4o, gemini-pro, sonar-small 등)
  @Index()
  @JsonKey(defaultValue: '')
  String model = '';

  /// 요청 타입 (chat, completion, embedding, image)
  @JsonKey(defaultValue: '')
  String requestType = '';

  /// 입력 토큰 수
  @JsonKey(defaultValue: 0)
  int inputTokens = 0;

  /// 출력 토큰 수  
  @JsonKey(defaultValue: 0)
  int outputTokens = 0;

  /// 총 토큰 수 (input + output)
  @JsonKey(defaultValue: 0)
  int totalTokens = 0;

  /// 응답 시간 (밀리초)
  @JsonKey(defaultValue: 0)
  int responseTimeMs = 0;

  /// 요청 상태 (success, error, timeout)
  @Index()
  @JsonKey(defaultValue: 'success')
  String status = 'success';

  /// 오류 코드 (HTTP 상태 코드 또는 에러 타입)
  @JsonKey(defaultValue: '')
  String errorCode = '';

  /// 오류 메시지
  @JsonKey(defaultValue: '')
  String errorMessage = '';

  /// 계산된 비용 (USD)
  @JsonKey(defaultValue: 0.0)
  double cost = 0.0;

  /// 사용자 ID (선택적)
  @JsonKey(defaultValue: '')
  String userId = '';

  /// 세션 ID (선택적)
  @JsonKey(defaultValue: '')
  String sessionId = '';

  /// 프롬프트 해시 (개인정보 보호)
  @JsonKey(defaultValue: '')
  String promptHash = '';

  /// 응답 해시 (개인정보 보호)
  @JsonKey(defaultValue: '')
  String responseHash = '';

  /// 메타데이터 (JSON 문자열)
  @JsonKey(defaultValue: '{}')
  String metadata = '{}';

  /// 생성 시간
  @JsonKey(name: 'created_at')
  DateTime createdAt = DateTime.now();

  UsageLog();

  factory UsageLog.fromJson(Map<String, dynamic> json) => _$UsageLogFromJson(json);
  Map<String, dynamic> toJson() => _$UsageLogToJson(this);

  @override
  String toString() {
    return 'UsageLog{requestId: $requestId, appId: $appId, provider: $provider, model: $model, totalTokens: $totalTokens, cost: $cost, status: $status}';
  }
}

/// 사용량 로그 생성을 위한 헬퍼 클래스
class UsageLogBuilder {
  final UsageLog _log = UsageLog();

  UsageLogBuilder() {
    _log.requestId = _generateRequestId();
    _log.timestamp = DateTime.now();
    _log.createdAt = DateTime.now();
  }

  UsageLogBuilder app(String appId) {
    _log.appId = appId;
    return this;
  }

  UsageLogBuilder provider(String provider) {
    _log.provider = provider;
    return this;
  }

  UsageLogBuilder model(String model) {
    _log.model = model;
    return this;
  }

  UsageLogBuilder requestType(String type) {
    _log.requestType = type;
    return this;
  }

  UsageLogBuilder tokens({int input = 0, int output = 0}) {
    _log.inputTokens = input;
    _log.outputTokens = output;
    _log.totalTokens = input + output;
    return this;
  }

  UsageLogBuilder responseTime(int milliseconds) {
    _log.responseTimeMs = milliseconds;
    return this;
  }

  UsageLogBuilder success() {
    _log.status = 'success';
    return this;
  }

  UsageLogBuilder error(String code, String message) {
    _log.status = 'error';
    _log.errorCode = code;
    _log.errorMessage = message;
    return this;
  }

  UsageLogBuilder cost(double usdCost) {
    _log.cost = usdCost;
    return this;
  }

  UsageLogBuilder user(String userId) {
    _log.userId = userId;
    return this;
  }

  UsageLogBuilder session(String sessionId) {
    _log.sessionId = sessionId;
    return this;
  }

  UsageLogBuilder promptHash(String hash) {
    _log.promptHash = hash;
    return this;
  }

  UsageLogBuilder responseHash(String hash) {
    _log.responseHash = hash;
    return this;
  }

  UsageLogBuilder metadata(Map<String, dynamic> meta) {
    _log.metadata = _encodeJson(meta);
    return this;
  }

  UsageLog build() => _log;

  String _generateRequestId() {
    return 'req_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  String _encodeJson(Map<String, dynamic> json) {
    try {
      return json.toString();
    } catch (e) {
      return '{}';
    }
  }
}

/// 사용량 통계를 위한 집계 데이터
@JsonSerializable()
class UsageStats {
  @JsonKey(defaultValue: '')
  String period = '';
  
  @JsonKey(defaultValue: '')
  String appId = '';
  
  @JsonKey(defaultValue: '')
  String provider = '';
  
  @JsonKey(defaultValue: '')
  String model = '';
  
  @JsonKey(defaultValue: 0)
  int totalRequests = 0;
  
  @JsonKey(defaultValue: 0)
  int successfulRequests = 0;
  
  @JsonKey(defaultValue: 0)
  int failedRequests = 0;
  
  @JsonKey(defaultValue: 0)
  int totalTokens = 0;
  
  @JsonKey(defaultValue: 0)
  double totalCost = 0.0;
  
  @JsonKey(defaultValue: 0)
  double avgResponseTime = 0.0;
  
  @JsonKey(defaultValue: 0.0)
  double errorRate = 0.0;

  UsageStats();

  factory UsageStats.fromJson(Map<String, dynamic> json) => _$UsageStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UsageStatsToJson(this);
}