import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';

import '../models/usage_log.dart';
import '../models/pricing_model.dart';
import '../core/config.dart';

class LlmProxyService {
  static final _instance = LlmProxyService._internal();
  static LlmProxyService get instance => _instance;
  LlmProxyService._internal();

  final Dio _dio = Dio();
  late Isar _isar;
  Map<String, PricingModel> _pricingCache = {};

  /// 서비스 초기화 - Isar 인스턴스 설정
  Future<void> initialize(Isar isar) async {
    _isar = isar;
    await _loadPricingModels();
  }

  /// 가격 모델 캐시 로드
  Future<void> _loadPricingModels() async {
    final pricingModels = await _isar.pricingModels.where().findAll();
    _pricingCache = {
      for (var model in pricingModels) '${model.provider}_${model.model}': model
    };
  }

  /// OpenAI API 호출
  Future<Map<String, dynamic>> callOpenAI({
    required String appId,
    required String model,
    required List<Map<String, dynamic>> messages,
    String? userId,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) async {
    final requestId = _generateRequestId();
    final timestamp = DateTime.now();
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.openAIApiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 2048,
        },
      );

      stopwatch.stop();
      
      final responseData = response.data;
      final usage = responseData['usage'] ?? {};
      final inputTokens = usage['prompt_tokens'] ?? 0;
      final outputTokens = usage['completion_tokens'] ?? 0;
      final totalTokens = usage['total_tokens'] ?? 0;

      // 비용 계산
      final cost = _calculateCost('openai', model, inputTokens, outputTokens);

      // 로그 저장
      await _saveUsageLog(
        requestId: requestId,
        timestamp: timestamp,
        appId: appId,
        provider: 'openai',
        model: model,
        requestType: 'chat',
        inputTokens: inputTokens,
        outputTokens: outputTokens,
        totalTokens: totalTokens,
        responseTimeMs: stopwatch.elapsedMilliseconds,
        status: 'success',
        cost: cost,
        userId: userId,
        sessionId: sessionId,
        promptHash: _hashContent(messages.toString()),
        responseHash: _hashContent(responseData['choices']?[0]?['message']?['content'] ?? ''),
        metadata: metadata,
      );

      return responseData;

    } catch (error) {
      stopwatch.stop();
      
      // 오류 로그 저장
      await _saveUsageLog(
        requestId: requestId,
        timestamp: timestamp,
        appId: appId,
        provider: 'openai',
        model: model,
        requestType: 'chat',
        responseTimeMs: stopwatch.elapsedMilliseconds,
        status: 'error',
        cost: 0.0,
        errorCode: error is DioException ? error.response?.statusCode.toString() ?? 'unknown' : 'exception',
        errorMessage: error.toString(),
        userId: userId,
        sessionId: sessionId,
        promptHash: _hashContent(messages.toString()),
        metadata: metadata,
      );

      rethrow;
    }
  }

  /// Gemini API 호출
  Future<Map<String, dynamic>> callGemini({
    required String appId,
    required String model,
    required List<Map<String, dynamic>> messages,
    String? userId,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) async {
    final requestId = _generateRequestId();
    final timestamp = DateTime.now();
    final stopwatch = Stopwatch()..start();

    try {
      // Gemini API 형식으로 메시지 변환
      final geminiContents = messages.map((msg) => {
        'role': msg['role'] == 'assistant' ? 'model' : msg['role'],
        'parts': [{'text': msg['content']}],
      }).toList();

      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=${AppConfig.geminiApiKey}',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: {
          'contents': geminiContents,
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2048,
          },
        },
      );

      stopwatch.stop();
      
      final responseData = response.data;
      final usageMetadata = responseData['usageMetadata'] ?? {};
      final inputTokens = usageMetadata['promptTokenCount'] ?? 0;
      final outputTokens = usageMetadata['candidatesTokenCount'] ?? 0;
      final totalTokens = usageMetadata['totalTokenCount'] ?? 0;

      final cost = _calculateCost('gemini', model, inputTokens, outputTokens);

      await _saveUsageLog(
        requestId: requestId,
        timestamp: timestamp,
        appId: appId,
        provider: 'gemini',
        model: model,
        requestType: 'generateContent',
        inputTokens: inputTokens,
        outputTokens: outputTokens,
        totalTokens: totalTokens,
        responseTimeMs: stopwatch.elapsedMilliseconds,
        status: 'success',
        cost: cost,
        userId: userId,
        sessionId: sessionId,
        promptHash: _hashContent(messages.toString()),
        responseHash: _hashContent(responseData['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? ''),
        metadata: metadata,
      );

      return responseData;

    } catch (error) {
      stopwatch.stop();
      
      await _saveUsageLog(
        requestId: requestId,
        timestamp: timestamp,
        appId: appId,
        provider: 'gemini',
        model: model,
        requestType: 'generateContent',
        responseTimeMs: stopwatch.elapsedMilliseconds,
        status: 'error',
        cost: 0.0,
        errorCode: error is DioException ? error.response?.statusCode.toString() ?? 'unknown' : 'exception',
        errorMessage: error.toString(),
        userId: userId,
        sessionId: sessionId,
        promptHash: _hashContent(messages.toString()),
        metadata: metadata,
      );

      rethrow;
    }
  }

  /// Perplexity API 호출
  Future<Map<String, dynamic>> callPerplexity({
    required String appId,
    required String model,
    required List<Map<String, dynamic>> messages,
    String? userId,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) async {
    final requestId = _generateRequestId();
    final timestamp = DateTime.now();
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _dio.post(
        'https://api.perplexity.ai/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.perplexityApiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 2048,
        },
      );

      stopwatch.stop();
      
      final responseData = response.data;
      final usage = responseData['usage'] ?? {};
      final inputTokens = usage['prompt_tokens'] ?? 0;
      final outputTokens = usage['completion_tokens'] ?? 0;
      final totalTokens = usage['total_tokens'] ?? 0;

      final cost = _calculateCost('perplexity', model, inputTokens, outputTokens);

      await _saveUsageLog(
        requestId: requestId,
        timestamp: timestamp,
        appId: appId,
        provider: 'perplexity',
        model: model,
        requestType: 'chat',
        inputTokens: inputTokens,
        outputTokens: outputTokens,
        totalTokens: totalTokens,
        responseTimeMs: stopwatch.elapsedMilliseconds,
        status: 'success',
        cost: cost,
        userId: userId,
        sessionId: sessionId,
        promptHash: _hashContent(messages.toString()),
        responseHash: _hashContent(responseData['choices']?[0]?['message']?['content'] ?? ''),
        metadata: metadata,
      );

      return responseData;

    } catch (error) {
      stopwatch.stop();
      
      await _saveUsageLog(
        requestId: requestId,
        timestamp: timestamp,
        appId: appId,
        provider: 'perplexity',
        model: model,
        requestType: 'chat',
        responseTimeMs: stopwatch.elapsedMilliseconds,
        status: 'error',
        cost: 0.0,
        errorCode: error is DioException ? error.response?.statusCode.toString() ?? 'unknown' : 'exception',
        errorMessage: error.toString(),
        userId: userId,
        sessionId: sessionId,
        promptHash: _hashContent(messages.toString()),
        metadata: metadata,
      );

      rethrow;
    }
  }

  /// Anthropic API 호출
  Future<Map<String, dynamic>> callAnthropic({
    required String appId,
    required String model,
    required List<Map<String, dynamic>> messages,
    String? userId,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) async {
    final requestId = _generateRequestId();
    final timestamp = DateTime.now();
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _dio.post(
        'https://api.anthropic.com/v1/messages',
        options: Options(
          headers: {
            'x-api-key': AppConfig.anthropicApiKey,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          'messages': messages,
          'max_tokens': 2048,
        },
      );

      stopwatch.stop();
      
      final responseData = response.data;
      final usage = responseData['usage'] ?? {};
      final inputTokens = usage['input_tokens'] ?? 0;
      final outputTokens = usage['output_tokens'] ?? 0;
      final totalTokens = inputTokens + outputTokens;

      final cost = _calculateCost('anthropic', model, inputTokens, outputTokens);

      await _saveUsageLog(
        requestId: requestId,
        timestamp: timestamp,
        appId: appId,
        provider: 'anthropic',
        model: model,
        requestType: 'messages',
        inputTokens: inputTokens,
        outputTokens: outputTokens,
        totalTokens: totalTokens,
        responseTimeMs: stopwatch.elapsedMilliseconds,
        status: 'success',
        cost: cost,
        userId: userId,
        sessionId: sessionId,
        promptHash: _hashContent(messages.toString()),
        responseHash: _hashContent(responseData['content']?[0]?['text'] ?? ''),
        metadata: metadata,
      );

      return responseData;

    } catch (error) {
      stopwatch.stop();
      
      await _saveUsageLog(
        requestId: requestId,
        timestamp: timestamp,
        appId: appId,
        provider: 'anthropic',
        model: model,
        requestType: 'messages',
        responseTimeMs: stopwatch.elapsedMilliseconds,
        status: 'error',
        cost: 0.0,
        errorCode: error is DioException ? error.response?.statusCode.toString() ?? 'unknown' : 'exception',
        errorMessage: error.toString(),
        userId: userId,
        sessionId: sessionId,
        promptHash: _hashContent(messages.toString()),
        metadata: metadata,
      );

      rethrow;
    }
  }

  /// 비용 계산
  double _calculateCost(String provider, String model, int inputTokens, int outputTokens) {
    final key = '${provider}_$model';
    final pricingModel = _pricingCache[key];
    
    if (pricingModel != null) {
      return pricingModel.calculateCost(
        inputTokens: inputTokens,
        outputTokens: outputTokens,
      );
    }
    
    // 캐시에 없으면 0으로 반환 (경고 로그 필요)
    print('Warning: Pricing model not found for $key');
    return 0.0;
  }

  /// 사용량 로그 저장
  Future<void> _saveUsageLog({
    required String requestId,
    required DateTime timestamp,
    required String appId,
    required String provider,
    required String model,
    required String requestType,
    int inputTokens = 0,
    int outputTokens = 0,
    int totalTokens = 0,
    required int responseTimeMs,
    required String status,
    String errorCode = '',
    String errorMessage = '',
    required double cost,
    String? userId,
    String? sessionId,
    String promptHash = '',
    String responseHash = '',
    Map<String, dynamic>? metadata,
  }) async {
    final usageLog = UsageLogBuilder()
        .app(appId)
        .provider(provider)
        .model(model)
        .requestType(requestType)
        .tokens(input: inputTokens, output: outputTokens)
        .responseTime(responseTimeMs)
        .cost(cost);

    if (status == 'success') {
      usageLog.success();
    } else {
      usageLog.error(errorCode, errorMessage);
    }

    if (userId != null) usageLog.user(userId);
    if (sessionId != null) usageLog.session(sessionId);
    if (promptHash.isNotEmpty) usageLog.promptHash(promptHash);
    if (responseHash.isNotEmpty) usageLog.responseHash(responseHash);
    if (metadata != null) usageLog.metadata(metadata);

    final log = usageLog.build();
    log.requestId = requestId;
    log.timestamp = timestamp;

    await _isar.writeTxn(() async {
      await _isar.usageLogs.put(log);
    });
  }

  /// 요청 ID 생성
  String _generateRequestId() {
    return 'req_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  /// 컨텐츠 해시 생성
  String _hashContent(String content) {
    return md5.convert(utf8.encode(content)).toString();
  }

  /// 기본 가격 모델 데이터 초기화
  Future<void> initializePricingModels() async {
    final existingCount = await _isar.pricingModels.count();
    if (existingCount == 0) {
      await _isar.writeTxn(() async {
        await _isar.pricingModels.putAll(DefaultPricingModels.all);
      });
      await _loadPricingModels();
    }
  }

  /// 통계용 사용량 조회
  Future<List<UsageLog>> getUsageLogs({
    String? appId,
    String? provider,
    String? model,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    List<UsageLog> results;

    // 가장 구체적인 필터부터 적용
    if (startDate != null && endDate != null) {
      results = await _isar.usageLogs.filter().timestampBetween(startDate, endDate).findAll();
    } else if (appId != null) {
      results = await _isar.usageLogs.filter().appIdEqualTo(appId).findAll();
    } else if (provider != null) {
      results = await _isar.usageLogs.filter().providerEqualTo(provider).findAll();
    } else if (model != null) {
      results = await _isar.usageLogs.filter().modelEqualTo(model).findAll();
    } else {
      results = await _isar.usageLogs.where().findAll();
    }

    // 추가 필터링 적용
    if (appId != null && (startDate == null || endDate == null)) {
      results = results.where((r) => r.appId == appId).toList();
    }
    if (provider != null && (startDate == null || endDate == null)) {
      results = results.where((r) => r.provider == provider).toList();
    }
    if (model != null && (startDate == null || endDate == null)) {
      results = results.where((r) => r.model == model).toList();
    }

    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results.take(limit).toList();
  }
}