import 'dart:math';

import 'package:logger/logger.dart';

import '../models/usage_log.dart';
import '../models/pricing_model.dart';
import 'llm_proxy_service.dart';
import 'daily_batch_service.dart';
import 'database_service.dart';

/// Test service for demonstrating LLM usage tracking
class LlmTestService {
  static final _instance = LlmTestService._internal();
  static LlmTestService get instance => _instance;
  LlmTestService._internal();

  final Logger _logger = Logger();
  final Random _random = Random();

  /// Generate mock LLM usage data for testing
  Future<void> generateMockUsageData() async {
    try {
      final database = await DatabaseService.instance.initialize();
      final proxyService = LlmProxyService.instance;
      await proxyService.initialize(database);
      
      _logger.i('모크 LLM 사용량 데이터 생성 시작');

      // Initialize pricing models
      await proxyService.initializePricingModels();

      // Generate 50 mock usage logs
      for (int i = 0; i < 50; i++) {
        await _createMockUsageLog(i);
      }

      // Run batch processing to create daily statistics
      final batchService = DailyBatchService.instance;
      await batchService.initialize(database);
      
      // Process data for the last 7 days
      final now = DateTime.now();
      for (int day = 0; day < 7; day++) {
        final targetDate = now.subtract(Duration(days: day));
        await batchService.runDailyBatch(targetDate: targetDate);
      }

      _logger.i('모크 데이터 생성 및 배치 처리 완료');
    } catch (e, stackTrace) {
      _logger.e('모크 데이터 생성 실패', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Create a single mock usage log entry
  Future<void> _createMockUsageLog(int index) async {
    final providers = ['OpenAI', 'Gemini', 'Perplexity', 'Anthropic'];
    final models = ['GPT-5', 'Gemini Pro', 'Claude 4', 'Sonar'];
    final apps = ['Clintest', 'Lingumo', 'AreumFit', 'HaneulTone'];

    final provider = providers[_random.nextInt(providers.length)];
    final model = models[_random.nextInt(models.length)];
    final appId = apps[_random.nextInt(apps.length)];

    // Generate random token counts
    final inputTokens = 100 + _random.nextInt(1500);
    final outputTokens = 50 + _random.nextInt(800);
    final totalTokens = inputTokens + outputTokens;

    // Generate random response time (50-2000ms)
    final responseTimeMs = 50 + _random.nextInt(1950);

    // Calculate cost based on provider and model
    final cost = _calculateMockCost(provider, model, inputTokens, outputTokens);

    // Create usage log with builder pattern
    final usageLog = UsageLogBuilder()
        .app(appId)
        .provider(provider)
        .model(model)
        .requestType('chat')
        .tokens(input: inputTokens, output: outputTokens)
        .responseTime(responseTimeMs)
        .cost(cost)
        .success()
        .build();

    // Set additional fields
    usageLog.requestId = 'test_req_${index}_${DateTime.now().millisecondsSinceEpoch}';
    usageLog.timestamp = DateTime.now().subtract(Duration(
      hours: _random.nextInt(168), // Random time within last week
      minutes: _random.nextInt(60),
    ));

    // Save to database
    await DatabaseService.instance.createUsageLog(usageLog);
    
    if (index % 10 == 0) {
      _logger.i('모크 로그 생성 진행: ${index + 1}/50');
    }
  }

  /// Calculate mock cost based on provider and model
  double _calculateMockCost(String provider, String model, int inputTokens, int outputTokens) {
    // Simplified cost calculation for testing
    switch (provider) {
      case 'OpenAI':
        return (inputTokens * 0.0015 + outputTokens * 0.002) / 1000;
      case 'Gemini':
        return (inputTokens * 0.000375 + outputTokens * 0.00075) / 1000;
      case 'Perplexity':
        return (inputTokens * 0.0002 + outputTokens * 0.0002) / 1000;
      case 'Anthropic':
        return (inputTokens * 0.00025 + outputTokens * 0.00125) / 1000;
      default:
        return 0.0;
    }
  }

  /// Get summary of generated mock data
  Future<Map<String, dynamic>> getMockDataSummary() async {
    try {
      final logs = await LlmProxyService.instance.getUsageLogs(limit: 1000);
      final batchService = DailyBatchService.instance;
      final dailyStats = await batchService.getDailyStats(limit: 100);

      final providerCosts = <String, double>{};
      final modelCalls = <String, int>{};
      
      for (final log in logs) {
        providerCosts[log.provider] = (providerCosts[log.provider] ?? 0) + log.cost;
        modelCalls[log.model] = (modelCalls[log.model] ?? 0) + 1;
      }

      return {
        'totalLogs': logs.length,
        'totalDailyStats': dailyStats.length,
        'providerCosts': providerCosts,
        'modelCalls': modelCalls,
        'totalCost': providerCosts.values.fold(0.0, (sum, cost) => sum + cost),
        'totalCalls': modelCalls.values.fold(0, (sum, calls) => sum + calls),
      };
    } catch (e) {
      _logger.e('모크 데이터 요약 조회 실패', error: e);
      return {};
    }
  }

  /// Clear all test data
  Future<void> clearMockData() async {
    try {
      await DatabaseService.instance.clearAllData();
      _logger.i('모든 테스트 데이터 정리 완료');
    } catch (e, stackTrace) {
      _logger.e('테스트 데이터 정리 실패', error: e, stackTrace: stackTrace);
    }
  }
}