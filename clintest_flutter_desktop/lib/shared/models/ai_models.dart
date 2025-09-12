/// AI 모델 정의 및 설정
/// v3.1: 난이도 기반 분기 + 임베딩 + 이미지 생성

enum AiModel {
  // OpenAI GPT-5 시리즈
  gpt5Standard('gpt-5-standard'),
  gpt5Mini('gpt-5-mini'),
  gpt5Nano('gpt-5-nano'),
  
  // Google Gemini 시리즈  
  gemini25FlashImage('gemini-2.5-flash-image'),
  geminiTextEmbedding004('text-embedding-004'),
  
  // Perplexity (검색용)
  perplexitySonar('sonar'),
  perplexityR1Small('r1-small');

  const AiModel(this.modelName);
  final String modelName;
}

/// AI 모델 라우팅 설정
class AiModelConfig {
  static const Map<String, AiModel> difficultyRouting = {
    'HIGH': AiModel.gpt5Standard,
    'MID': AiModel.gpt5Mini,
    'LOW': AiModel.gpt5Mini,
  };

  static const AiModel planningModel = AiModel.gpt5Standard;
  static const AiModel embeddingModel = AiModel.geminiTextEmbedding004;
  static const AiModel imageModel = AiModel.gemini25FlashImage;

  /// 모델별 비용 (USD per 1M tokens, 2025-08-24 기준)
  static const Map<AiModel, ModelCost> costs = {
    AiModel.gpt5Standard: ModelCost(input: 1.25, output: 10.00),
    AiModel.gpt5Mini: ModelCost(input: 0.25, output: 2.00),
    AiModel.gpt5Nano: ModelCost(input: 0.05, output: 0.40),
    AiModel.gemini25FlashImage: ModelCost(input: 0.0375, output: 0.15),
    AiModel.geminiTextEmbedding004: ModelCost(input: 0.0375, output: 0.0),
    AiModel.perplexitySonar: ModelCost(input: 1.00, output: 1.00),
    AiModel.perplexityR1Small: ModelCost(input: 0.20, output: 0.20),
  };

  /// 모델별 토큰 제한
  static const Map<AiModel, int> tokenLimits = {
    AiModel.gpt5Standard: 200000,
    AiModel.gpt5Mini: 128000,
    AiModel.gpt5Nano: 32000,
    AiModel.gemini25FlashImage: 1000000,
    AiModel.geminiTextEmbedding004: 8192,
    AiModel.perplexitySonar: 28000,
    AiModel.perplexityR1Small: 127000,
  };
}

class ModelCost {
  final double input;  // USD per 1M input tokens
  final double output; // USD per 1M output tokens

  const ModelCost({required this.input, required this.output});

  /// 토큰 수 기반 예상 비용 계산
  double calculateCost({required int inputTokens, required int outputTokens}) {
    return (inputTokens / 1000000.0 * input) + (outputTokens / 1000000.0 * output);
  }
}

/// 문제 유형 정의
enum QuestionType {
  mcq('MCQ', '객관식 5지선다'),
  simulation('Simulation', '시뮬레이션 단계별'),
  imageBased('Image-based', '이미지 기반 MCQ'),
  essay('Essay', '서술형 (옵션)');

  const QuestionType(this.id, this.displayName);
  final String id;
  final String displayName;

  /// 기본 활성화 문제 유형
  static const List<QuestionType> defaultTypes = [
    QuestionType.mcq,
    QuestionType.simulation,
    QuestionType.imageBased,
  ];

  /// 옵션 문제 유형 (운영자 설정)
  static const List<QuestionType> optionalTypes = [
    QuestionType.essay,
  ];
}

/// 난이도 레벨
enum DifficultyLevel {
  high('HIGH', '고급', AiModel.gpt5Standard),
  mid('MID', '중급', AiModel.gpt5Mini),
  low('LOW', '초급', AiModel.gpt5Mini);

  const DifficultyLevel(this.id, this.displayName, this.targetModel);
  final String id;
  final String displayName;
  final AiModel targetModel;
}

/// AI 생성 요청 파라미터
class AiGenerationRequest {
  final String conceptText;
  final String subject;
  final DifficultyLevel difficulty;
  final List<QuestionType> questionTypes;
  final int questionCount;
  final bool includeImages;
  final bool includeEssay;
  final Map<String, dynamic> metadata;

  AiGenerationRequest({
    required this.conceptText,
    required this.subject,
    required this.difficulty,
    required this.questionTypes,
    this.questionCount = 5,
    this.includeImages = false,
    this.includeEssay = false,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'conceptText': conceptText,
    'subject': subject,
    'difficulty': difficulty.id,
    'questionTypes': questionTypes.map((t) => t.id).toList(),
    'questionCount': questionCount,
    'includeImages': includeImages,
    'includeEssay': includeEssay,
    'metadata': metadata,
  };

  /// 예상 비용 계산
  double estimatedCost() {
    final inputTokens = _estimateInputTokens();
    final outputTokens = _estimateOutputTokens();
    
    final modelCost = AiModelConfig.costs[difficulty.targetModel]!;
    return modelCost.calculateCost(
      inputTokens: inputTokens,
      outputTokens: outputTokens,
    );
  }

  int _estimateInputTokens() {
    // 개념 텍스트 + 프롬프트 + 컨텍스트
    final conceptTokens = (conceptText.length / 4).ceil(); // 대략적인 토큰 추정
    final promptTokens = 2000; // 시스템 프롬프트 예상
    final contextTokens = includeImages ? 5000 : 1000; // 이미지 컨텍스트
    
    return conceptTokens + promptTokens + contextTokens;
  }

  int _estimateOutputTokens() {
    // 문항당 평균 토큰 수 × 문항 수
    int tokensPerQuestion;
    
    switch (questionTypes.first) {
      case QuestionType.mcq:
        tokensPerQuestion = 300;
      case QuestionType.simulation:
        tokensPerQuestion = 600;
      case QuestionType.imageBased:
        tokensPerQuestion = 400;
      case QuestionType.essay:
        tokensPerQuestion = 800;
    }
    
    return tokensPerQuestion * questionCount;
  }
}

/// AI 응답 래퍼
class AiResponse<T> {
  final T? data;
  final String? error;
  final AiModel modelUsed;
  final int inputTokens;
  final int outputTokens;
  final double cost;
  final Duration responseTime;

  AiResponse({
    this.data,
    this.error,
    required this.modelUsed,
    required this.inputTokens,
    required this.outputTokens,
    required this.cost,
    required this.responseTime,
  });

  bool get isSuccess => error == null && data != null;
  bool get isError => error != null;

  factory AiResponse.success({
    required T data,
    required AiModel modelUsed,
    required int inputTokens,
    required int outputTokens,
    required Duration responseTime,
  }) {
    final cost = AiModelConfig.costs[modelUsed]!.calculateCost(
      inputTokens: inputTokens,
      outputTokens: outputTokens,
    );

    return AiResponse(
      data: data,
      modelUsed: modelUsed,
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      cost: cost,
      responseTime: responseTime,
    );
  }

  factory AiResponse.error({
    required String error,
    required AiModel modelUsed,
    required Duration responseTime,
  }) {
    return AiResponse(
      error: error,
      modelUsed: modelUsed,
      inputTokens: 0,
      outputTokens: 0,
      cost: 0.0,
      responseTime: responseTime,
    );
  }
}

/// 세션 정보 (실시간 동기화용)
class SessionInfo {
  final String sessionId;
  final String userId;
  final String deviceId;
  final String subject;
  final DateTime startedAt;
  final SessionStatus status;
  final int attemptVersion;
  final DateTime lastEventAt;

  SessionInfo({
    required this.sessionId,
    required this.userId,
    required this.deviceId,
    required this.subject,
    required this.startedAt,
    required this.status,
    this.attemptVersion = 1,
    required this.lastEventAt,
  });

  factory SessionInfo.fromJson(Map<String, dynamic> json) {
    return SessionInfo(
      sessionId: json['sessionId'],
      userId: json['userId'],
      deviceId: json['deviceId'],
      subject: json['subject'],
      startedAt: DateTime.parse(json['startedAt']),
      status: SessionStatus.values.byName(json['status']),
      attemptVersion: json['attemptVersion'] ?? 1,
      lastEventAt: DateTime.parse(json['lastEventAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'userId': userId,
    'deviceId': deviceId,
    'subject': subject,
    'startedAt': startedAt.toIso8601String(),
    'status': status.name,
    'attemptVersion': attemptVersion,
    'lastEventAt': lastEventAt.toIso8601String(),
  };

  SessionInfo copyWith({
    SessionStatus? status,
    int? attemptVersion,
    DateTime? lastEventAt,
  }) {
    return SessionInfo(
      sessionId: sessionId,
      userId: userId,
      deviceId: deviceId,
      subject: subject,
      startedAt: startedAt,
      status: status ?? this.status,
      attemptVersion: attemptVersion ?? this.attemptVersion,
      lastEventAt: lastEventAt ?? this.lastEventAt,
    );
  }
}

enum SessionStatus {
  active,
  finished,
  paused,
  cancelled
}

/// 시도 기록 (실시간 동기화용)
class AttemptRecord {
  final String sessionId;
  final String questionId;
  final String? selectedChoice; // A, B, C, D, E, null
  final bool? isCorrect;
  final DateTime? answeredAt;
  final int? latencyMs;
  final DateTime updatedAt;
  final int version;
  final String? requestId; // 중복 방지 토큰

  AttemptRecord({
    required this.sessionId,
    required this.questionId,
    this.selectedChoice,
    this.isCorrect,
    this.answeredAt,
    this.latencyMs,
    required this.updatedAt,
    this.version = 1,
    this.requestId,
  });

  factory AttemptRecord.fromJson(Map<String, dynamic> json) {
    return AttemptRecord(
      sessionId: json['sessionId'],
      questionId: json['questionId'],
      selectedChoice: json['selectedChoice'],
      isCorrect: json['isCorrect'],
      answeredAt: json['answeredAt'] != null ? DateTime.parse(json['answeredAt']) : null,
      latencyMs: json['latencyMs'],
      updatedAt: DateTime.parse(json['updatedAt']),
      version: json['version'] ?? 1,
      requestId: json['requestId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'questionId': questionId,
    'selectedChoice': selectedChoice,
    'isCorrect': isCorrect,
    'answeredAt': answeredAt?.toIso8601String(),
    'latencyMs': latencyMs,
    'updatedAt': updatedAt.toIso8601String(),
    'version': version,
    'requestId': requestId,
  };

  AttemptRecord copyWith({
    String? selectedChoice,
    bool? isCorrect,
    DateTime? answeredAt,
    int? latencyMs,
    DateTime? updatedAt,
    int? version,
  }) {
    return AttemptRecord(
      sessionId: sessionId,
      questionId: questionId,
      selectedChoice: selectedChoice ?? this.selectedChoice,
      isCorrect: isCorrect ?? this.isCorrect,
      answeredAt: answeredAt ?? this.answeredAt,
      latencyMs: latencyMs ?? this.latencyMs,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      requestId: requestId,
    );
  }
}