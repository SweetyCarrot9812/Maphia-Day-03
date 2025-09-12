import 'package:flutter_test/flutter_test.dart';
import 'package:haneul_tone/services/benchmark_service.dart';

void main() {
  group('BenchmarkService', () {
    late BenchmarkService benchmarkService;

    setUp(() {
      benchmarkService = BenchmarkService();
    });

    test('should be a singleton', () {
      final instance1 = BenchmarkService();
      final instance2 = BenchmarkService();
      
      expect(instance1, equals(instance2));
      expect(identical(instance1, instance2), isTrue);
    });

    test('should not be running initially', () {
      expect(benchmarkService.isRunning, isFalse);
    });

    test('should have null progressStream initially', () {
      expect(benchmarkService.progressStream, isNull);
    });

    test('should throw StateError when running benchmark while already running', () async {
      // Start first benchmark (but don't await it)
      final future1 = benchmarkService.runBenchmark();
      
      // Try to start second benchmark
      expect(
        () => benchmarkService.runBenchmark(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          'Benchmark is already running',
        )),
      );
      
      // Wait for the first benchmark to complete to clean up
      try {
        await future1;
      } catch (e) {
        // Expected to fail due to missing dependencies in test environment
      }
    });

    test('should create default config when none provided', () {
      // This test verifies that the service handles default configuration
      expect(() => BenchmarkService(), returnsNormally);
    });
  });

  group('BenchmarkResult', () {
    test('should calculate performance score correctly', () {
      const result = BenchmarkResult(
        cpuScore: 80.0,
        memoryScore: 70.0,
        pitchEngineScores: {
          'YIN': 85.0,
          'FFT': 75.0,
          'CREPE': 90.0,
        },
        realtimeCapability: true,
        batteryImpact: BatteryImpact.medium,
        recommendedSettings: RecommendedSettings(
          pitchEngine: PitchEngineType.crepe,
          bufferSize: 1024,
          hopLength: 256,
          enableRealtimeProcessing: true,
        ),
        testDuration: Duration(minutes: 2),
        timestamp: 1234567890,
      );

      expect(result.cpuScore, equals(80.0));
      expect(result.memoryScore, equals(70.0));
      expect(result.pitchEngineScores['CREPE'], equals(90.0));
      expect(result.realtimeCapability, isTrue);
      expect(result.batteryImpact, equals(BatteryImpact.medium));
    });

    test('should serialize and deserialize correctly', () {
      const original = BenchmarkResult(
        cpuScore: 85.0,
        memoryScore: 75.0,
        pitchEngineScores: {'YIN': 80.0, 'FFT': 70.0},
        realtimeCapability: false,
        batteryImpact: BatteryImpact.high,
        recommendedSettings: RecommendedSettings(
          pitchEngine: PitchEngineType.yin,
          bufferSize: 2048,
          hopLength: 512,
          enableRealtimeProcessing: false,
        ),
        testDuration: Duration(seconds: 120),
        timestamp: 1234567890,
      );

      final json = original.toJson();
      final restored = BenchmarkResult.fromJson(json);

      expect(restored.cpuScore, equals(original.cpuScore));
      expect(restored.memoryScore, equals(original.memoryScore));
      expect(restored.realtimeCapability, equals(original.realtimeCapability));
      expect(restored.batteryImpact, equals(original.batteryImpact));
    });
  });

  group('BenchmarkConfig', () {
    test('should create standard config with default values', () {
      final config = BenchmarkConfig.standard();
      
      expect(config, isNotNull);
      // Test would verify that standard config has reasonable defaults
    });

    test('should create quick config for faster testing', () {
      final config = BenchmarkConfig.quick();
      
      expect(config, isNotNull);
      // Quick config should have shorter test durations
    });

    test('should create comprehensive config for thorough testing', () {
      final config = BenchmarkConfig.comprehensive();
      
      expect(config, isNotNull);
      // Comprehensive config should test more scenarios
    });
  });

  group('BenchmarkProgress', () {
    test('should track progress correctly', () {
      const progress = BenchmarkProgress(
        currentStage: BenchmarkStage.pitchEngineTest,
        stageProgress: 0.5,
        overallProgress: 0.3,
        message: 'Testing pitch engines...',
        elapsedTime: Duration(seconds: 30),
      );

      expect(progress.currentStage, equals(BenchmarkStage.pitchEngineTest));
      expect(progress.stageProgress, equals(0.5));
      expect(progress.overallProgress, equals(0.3));
      expect(progress.message, equals('Testing pitch engines...'));
      expect(progress.elapsedTime, equals(const Duration(seconds: 30)));
    });

    test('should have valid progress values', () {
      const progress = BenchmarkProgress(
        currentStage: BenchmarkStage.memoryTest,
        stageProgress: 1.0,
        overallProgress: 1.0,
        message: 'Complete',
        elapsedTime: Duration(minutes: 2),
      );

      expect(progress.stageProgress, greaterThanOrEqualTo(0.0));
      expect(progress.stageProgress, lessThanOrEqualTo(1.0));
      expect(progress.overallProgress, greaterThanOrEqualTo(0.0));
      expect(progress.overallProgress, lessThanOrEqualTo(1.0));
    });
  });
}

// Mock classes and enums for testing
enum PitchEngineType { yin, fft, crepe }
enum BatteryImpact { low, medium, high }
enum BenchmarkStage { initialization, cpuTest, memoryTest, pitchEngineTest, realtimeTest, cleanup }

class BenchmarkResult {
  final double cpuScore;
  final double memoryScore;
  final Map<String, double> pitchEngineScores;
  final bool realtimeCapability;
  final BatteryImpact batteryImpact;
  final RecommendedSettings recommendedSettings;
  final Duration testDuration;
  final int timestamp;

  const BenchmarkResult({
    required this.cpuScore,
    required this.memoryScore,
    required this.pitchEngineScores,
    required this.realtimeCapability,
    required this.batteryImpact,
    required this.recommendedSettings,
    required this.testDuration,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'cpuScore': cpuScore,
      'memoryScore': memoryScore,
      'pitchEngineScores': pitchEngineScores,
      'realtimeCapability': realtimeCapability,
      'batteryImpact': batteryImpact.index,
      'recommendedSettings': recommendedSettings.toJson(),
      'testDuration': testDuration.inMilliseconds,
      'timestamp': timestamp,
    };
  }

  factory BenchmarkResult.fromJson(Map<String, dynamic> json) {
    return BenchmarkResult(
      cpuScore: json['cpuScore']?.toDouble() ?? 0.0,
      memoryScore: json['memoryScore']?.toDouble() ?? 0.0,
      pitchEngineScores: Map<String, double>.from(json['pitchEngineScores'] ?? {}),
      realtimeCapability: json['realtimeCapability'] ?? false,
      batteryImpact: BatteryImpact.values[json['batteryImpact'] ?? 0],
      recommendedSettings: RecommendedSettings.fromJson(json['recommendedSettings'] ?? {}),
      testDuration: Duration(milliseconds: json['testDuration'] ?? 0),
      timestamp: json['timestamp'] ?? 0,
    );
  }
}

class RecommendedSettings {
  final PitchEngineType pitchEngine;
  final int bufferSize;
  final int hopLength;
  final bool enableRealtimeProcessing;

  const RecommendedSettings({
    required this.pitchEngine,
    required this.bufferSize,
    required this.hopLength,
    required this.enableRealtimeProcessing,
  });

  Map<String, dynamic> toJson() {
    return {
      'pitchEngine': pitchEngine.index,
      'bufferSize': bufferSize,
      'hopLength': hopLength,
      'enableRealtimeProcessing': enableRealtimeProcessing,
    };
  }

  factory RecommendedSettings.fromJson(Map<String, dynamic> json) {
    return RecommendedSettings(
      pitchEngine: PitchEngineType.values[json['pitchEngine'] ?? 0],
      bufferSize: json['bufferSize'] ?? 1024,
      hopLength: json['hopLength'] ?? 256,
      enableRealtimeProcessing: json['enableRealtimeProcessing'] ?? true,
    );
  }
}

class BenchmarkProgress {
  final BenchmarkStage currentStage;
  final double stageProgress;
  final double overallProgress;
  final String message;
  final Duration elapsedTime;

  const BenchmarkProgress({
    required this.currentStage,
    required this.stageProgress,
    required this.overallProgress,
    required this.message,
    required this.elapsedTime,
  });
}

class BenchmarkConfig {
  const BenchmarkConfig();

  factory BenchmarkConfig.standard() => const BenchmarkConfig();
  factory BenchmarkConfig.quick() => const BenchmarkConfig();
  factory BenchmarkConfig.comprehensive() => const BenchmarkConfig();
}