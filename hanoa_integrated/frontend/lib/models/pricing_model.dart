import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pricing_model.g.dart';

@collection
@JsonSerializable()
class PricingModel {
  Id id = Isar.autoIncrement;

  /// 공급자 (openai, gemini, perplexity, anthropic)
  @Index()
  @JsonKey(defaultValue: '')
  String provider = '';

  /// 모델명 (gpt-4o, gemini-pro, sonar-small 등)
  @Index(unique: true)
  @JsonKey(defaultValue: '')
  String model = '';

  /// 모델 표시명
  @JsonKey(defaultValue: '')
  String displayName = '';

  /// 입력 토큰 단가 (USD per 1M tokens)
  @JsonKey(defaultValue: 0.0)
  double inputPricePerMToken = 0.0;

  /// 출력 토큰 단가 (USD per 1M tokens)
  @JsonKey(defaultValue: 0.0)
  double outputPricePerMToken = 0.0;

  /// 최소 비용 (USD)
  @JsonKey(defaultValue: 0.0)
  double minimumCost = 0.0;

  /// 최대 컨텍스트 길이
  @JsonKey(defaultValue: 0)
  int maxContextLength = 0;

  /// 최대 출력 길이
  @JsonKey(defaultValue: 0)
  int maxOutputLength = 0;

  /// 지원하는 기능들 (JSON 배열 문자열)
  @JsonKey(defaultValue: '[]')
  String supportedFeatures = '[]';

  /// 모델 설명
  @JsonKey(defaultValue: '')
  String description = '';

  /// 활성 상태
  @JsonKey(defaultValue: true)
  bool isActive = true;

  /// 생성 시간
  @JsonKey(name: 'created_at')
  DateTime createdAt = DateTime.now();

  /// 수정 시간
  @JsonKey(name: 'updated_at')
  DateTime updatedAt = DateTime.now();

  PricingModel();

  factory PricingModel.fromJson(Map<String, dynamic> json) => _$PricingModelFromJson(json);
  Map<String, dynamic> toJson() => _$PricingModelToJson(this);

  /// 토큰 수에 따른 비용 계산
  double calculateCost({required int inputTokens, required int outputTokens}) {
    final inputCost = (inputTokens / 1000000) * inputPricePerMToken;
    final outputCost = (outputTokens / 1000000) * outputPricePerMToken;
    final totalCost = inputCost + outputCost;
    
    return totalCost > minimumCost ? totalCost : minimumCost;
  }

  @override
  String toString() {
    return 'PricingModel{provider: $provider, model: $model, input: \$${inputPricePerMToken}/1M, output: \$${outputPricePerMToken}/1M}';
  }
}

/// 기본 가격 모델 데이터
class DefaultPricingModels {
  static List<PricingModel> get all => [
    // OpenAI Models
    _createModel(
      provider: 'openai',
      model: 'gpt-5',
      displayName: 'GPT-5',
      inputPrice: 1.25,
      outputPrice: 10.00,
      maxContext: 128000,
      maxOutput: 8000,
      description: '가장 강력한 OpenAI 모델',
    ),
    _createModel(
      provider: 'openai',
      model: 'gpt-5-mini',
      displayName: 'GPT-5 Mini',
      inputPrice: 0.25,
      outputPrice: 2.00,
      maxContext: 128000,
      maxOutput: 8000,
      description: '비용 효율적인 고성능 모델',
    ),
    _createModel(
      provider: 'openai',
      model: 'gpt-5-nano',
      displayName: 'GPT-5 Nano',
      inputPrice: 0.05,
      outputPrice: 0.40,
      maxContext: 128000,
      maxOutput: 8000,
      description: '초경량 경제적 모델',
    ),

    // Gemini Models
    _createModel(
      provider: 'gemini',
      model: 'gemini-2.5-pro',
      displayName: 'Gemini 2.5 Pro',
      inputPrice: 1.25,
      outputPrice: 10.00,
      maxContext: 2000000,
      maxOutput: 8000,
      description: '텍스트/멀티모달, 고성능 reasoning',
    ),
    _createModel(
      provider: 'gemini',
      model: 'gemini-2.5-flash',
      displayName: 'Gemini 2.5 Flash',
      inputPrice: 0.30,
      outputPrice: 2.50,
      maxContext: 1000000,
      maxOutput: 8000,
      description: '초고속·경량 텍스트/멀티모달',
    ),
    _createModel(
      provider: 'gemini',
      model: 'gemini-2.5-flash-lite',
      displayName: 'Gemini 2.5 Flash Lite',
      inputPrice: 0.10,
      outputPrice: 0.40,
      maxContext: 1000000,
      maxOutput: 8000,
      description: '초저가, 대량 작업용',
    ),
    _createModel(
      provider: 'gemini',
      model: 'gemini-2.0-pro',
      displayName: 'Gemini 2.0 Pro',
      inputPrice: 0.50,
      outputPrice: 3.00,
      maxContext: 2000000,
      maxOutput: 8000,
      description: '구세대, 텍스트 중심',
    ),
    _createModel(
      provider: 'gemini',
      model: 'gemini-2.0-flash',
      displayName: 'Gemini 2.0 Flash',
      inputPrice: 0.15,
      outputPrice: 0.60,
      maxContext: 1000000,
      maxOutput: 8000,
      description: '구세대, 경량형',
    ),

    // Perplexity Models
    _createModel(
      provider: 'perplexity',
      model: 'llama-3.1-sonar-small-128k-online',
      displayName: 'Llama 3.1 Sonar Small Online',
      inputPrice: 0.20,
      outputPrice: 0.20,
      maxContext: 127072,
      maxOutput: 4000,
      description: '초저가·빠름·온라인 검색',
    ),
    _createModel(
      provider: 'perplexity',
      model: 'llama-3.1-sonar-large-128k-online',
      displayName: 'Llama 3.1 Sonar Large Online',
      inputPrice: 1.00,
      outputPrice: 1.00,
      maxContext: 127072,
      maxOutput: 4000,
      description: '표준·고성능·온라인 검색',
    ),
    _createModel(
      provider: 'perplexity',
      model: 'llama-3.1-sonar-huge-128k-online',
      displayName: 'Llama 3.1 Sonar Huge Online',
      inputPrice: 5.00,
      outputPrice: 5.00,
      maxContext: 127072,
      maxOutput: 4000,
      description: '최고성능·대규모 분석·온라인 검색',
    ),
    _createModel(
      provider: 'perplexity',
      model: 'sonar',
      displayName: 'Sonar',
      inputPrice: 1.00,
      outputPrice: 1.00,
      maxContext: 127072,
      maxOutput: 4000,
      description: '실시간 검색, 온라인 가능',
    ),
    _createModel(
      provider: 'perplexity',
      model: 'sonar-pro',
      displayName: 'Sonar Pro',
      inputPrice: 3.00,
      outputPrice: 15.00,
      maxContext: 127072,
      maxOutput: 4000,
      description: '고정밀 응답, 복잡질의 최적화',
    ),
    _createModel(
      provider: 'perplexity',
      model: 'sonar-reasoning',
      displayName: 'Sonar Reasoning',
      inputPrice: 1.00,
      outputPrice: 5.00,
      maxContext: 127072,
      maxOutput: 4000,
      description: '심층 추론 특화',
    ),
    _createModel(
      provider: 'perplexity',
      model: 'sonar-deep-research',
      displayName: 'Sonar Deep Research',
      inputPrice: 2.00,
      outputPrice: 8.00,
      maxContext: 127072,
      maxOutput: 4000,
      description: '전문 지식, 논문 등 실시간 검색',
    ),

    // Anthropic Models  
    _createModel(
      provider: 'anthropic',
      model: 'claude-4-opus-20250514',
      displayName: 'Claude 4 Opus',
      inputPrice: 15.00,
      outputPrice: 75.00,
      maxContext: 200000,
      maxOutput: 8000,
      description: '최신 Opus, 최고성능, 비전, 20만맥락',
    ),
    _createModel(
      provider: 'anthropic',
      model: 'claude-4-sonnet-20250514',
      displayName: 'Claude 4 Sonnet',
      inputPrice: 3.00,
      outputPrice: 15.00,
      maxContext: 200000,
      maxOutput: 8000,
      description: '최신 Sonnet, 빠른 실무, 20만맥락',
    ),
    _createModel(
      provider: 'anthropic',
      model: 'claude-3-5-sonnet-latest',
      displayName: 'Claude 3.5 Sonnet Latest',
      inputPrice: 3.00,
      outputPrice: 15.00,
      maxContext: 200000,
      maxOutput: 8000,
      description: 'Sonnet 3.5, 20만맥락',
    ),
    _createModel(
      provider: 'anthropic',
      model: 'claude-3-5-haiku-latest',
      displayName: 'Claude 3.5 Haiku Latest',
      inputPrice: 0.80,
      outputPrice: 4.00,
      maxContext: 200000,
      maxOutput: 8000,
      description: 'Haiku 3.5, 가장 빠르고 저렴',
    ),
    _createModel(
      provider: 'anthropic',
      model: 'claude-3-haiku-20240307',
      displayName: 'Claude 3 Haiku',
      inputPrice: 0.25,
      outputPrice: 1.25,
      maxContext: 200000,
      maxOutput: 8000,
      description: '3세대 Haiku, 초저가',
    ),
  ];

  static PricingModel _createModel({
    required String provider,
    required String model,
    required String displayName,
    required double inputPrice,
    required double outputPrice,
    required int maxContext,
    required int maxOutput,
    required String description,
    double minimumCost = 0.0001,
  }) {
    return PricingModel()
      ..provider = provider
      ..model = model
      ..displayName = displayName
      ..inputPricePerMToken = inputPrice
      ..outputPricePerMToken = outputPrice
      ..minimumCost = minimumCost
      ..maxContextLength = maxContext
      ..maxOutputLength = maxOutput
      ..supportedFeatures = '["text", "chat"]'
      ..description = description
      ..isActive = true
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
  }
}