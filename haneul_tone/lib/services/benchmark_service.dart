import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/audio/pitch_engine.dart';
import '../core/audio/hybrid_pitch_engine.dart';
import '../core/audio/crepe_engine.dart';
import '../core/audio/pitch_frame.dart';
import '../core/audio/audio_preprocessor.dart';
import '../models/session_model_v2.dart';

/// 벤치마크 모드 서비스
/// 
/// 디바이스 성능 테스트를 통해 최적의 설정 추천
/// 
/// Features:
/// - 다양한 피치 엔진 성능 측정
/// - 실시간 처리 능력 평가
/// - 메모리 사용량 모니터링
/// - 배터리 영향도 측정
/// - 최적 설정 자동 추천
class BenchmarkService {
  static final BenchmarkService _instance = BenchmarkService._internal();
  factory BenchmarkService() => _instance;
  BenchmarkService._internal();
  
  bool _isRunning = false;
  StreamController<BenchmarkProgress>? _progressController;
  
  /// 벤치마크 실행 중 여부
  bool get isRunning => _isRunning;
  
  /// 벤치마크 진행상황 스트림
  Stream<BenchmarkProgress>? get progressStream => _progressController?.stream;
  
  /// 디바이스 성능 벤치마크 실행
  Future<BenchmarkResult> runBenchmark({
    BenchmarkConfig? config,
    void Function(BenchmarkProgress)? onProgress,
  }) async {
    if (_isRunning) {
      throw StateError('Benchmark is already running');
    }
    
    _isRunning = true;
    _progressController = StreamController<BenchmarkProgress>.broadcast();
    
    final benchmarkConfig = config ?? BenchmarkConfig.standard();
    final result = BenchmarkResult();
    
    try {
      print('🚀 벤치마크 모드 시작');
      
      // 1. 시스템 정보 수집
      await _updateProgress('시스템 정보 수집 중...', 0.05, onProgress);
      result.systemInfo = await _collectSystemInfo();
      
      // 2. 오디오 시스템 테스트
      await _updateProgress('오디오 시스템 테스트 중...', 0.15, onProgress);
      result.audioSystemTest = await _testAudioSystem();
      
      // 3. 피치 엔진 성능 테스트
      await _updateProgress('피치 엔진 성능 테스트 시작...', 0.25, onProgress);
      
      // 3.1 Hybrid Engine 테스트
      await _updateProgress('Hybrid 엔진 테스트 중...', 0.35, onProgress);
      result.hybridEngineTest = await _testPitchEngine(
        'Hybrid', 
        () => HybridPitchEngine(),
        benchmarkConfig,
      );
      
      // 3.2 CREPE Engine 테스트 (사용 가능한 경우)
      await _updateProgress('CREPE 엔진 테스트 중...', 0.55, onProgress);
      result.crepeEngineTest = await _testPitchEngine(
        'CREPE-Tiny',
        () => CrepeEngine(),
        benchmarkConfig,
      );
      
      // 4. 실시간 처리 능력 테스트
      await _updateProgress('실시간 처리 테스트 중...', 0.70, onProgress);
      result.realtimeTest = await _testRealtimeCapability(benchmarkConfig);
      
      // 5. 메모리 사용량 테스트
      await _updateProgress('메모리 사용량 테스트 중...', 0.80, onProgress);
      result.memoryTest = await _testMemoryUsage(benchmarkConfig);
      
      // 6. 배터리 영향도 테스트
      await _updateProgress('배터리 영향도 테스트 중...', 0.85, onProgress);
      result.batteryTest = await _testBatteryImpact(benchmarkConfig);
      
      // 7. 최적 설정 계산
      await _updateProgress('최적 설정 계산 중...', 0.90, onProgress);
      result.recommendations = _calculateRecommendations(result);
      
      // 8. 성능 등급 산정
      await _updateProgress('성능 등급 산정 중...', 0.95, onProgress);
      result.performanceGrade = _calculatePerformanceGrade(result);
      
      await _updateProgress('벤치마크 완료!', 1.0, onProgress);
      result.isSuccess = true;
      result.completedAt = DateTime.now();
      
      print('✅ 벤치마크 완료 - 등급: ${result.performanceGrade.grade}');
      
      return result;
    } catch (e, stackTrace) {
      print('❌ 벤치마크 실패: $e');
      print(stackTrace);
      
      result.isSuccess = false;
      result.errorMessage = e.toString();
      result.completedAt = DateTime.now();
      
      return result;
    } finally {
      _isRunning = false;
      await _progressController?.close();
      _progressController = null;
    }
  }
  
  /// 진행상황 업데이트
  Future<void> _updateProgress(
    String status,
    double progress,
    void Function(BenchmarkProgress)? onProgress,
  ) async {
    final progressData = BenchmarkProgress(
      status: status,
      progress: progress,
      timestamp: DateTime.now(),
    );
    
    _progressController?.add(progressData);
    onProgress?.call(progressData);
    
    // UI 업데이트를 위한 짧은 지연
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  /// 시스템 정보 수집
  Future<SystemInfo> _collectSystemInfo() async {
    final systemInfo = SystemInfo();
    
    try {
      // 플랫폼 정보
      systemInfo.platform = defaultTargetPlatform.name;
      systemInfo.isDebugMode = kDebugMode;
      systemInfo.timestamp = DateTime.now();
      
      // 기본 정보 (실제 구현 시 platform_info 패키지 등 활용)
      systemInfo.deviceModel = 'Unknown'; // 실제로는 디바이스별 정보
      systemInfo.osVersion = 'Unknown';
      systemInfo.availableMemoryMB = 4096; // 예시값
      systemInfo.totalMemoryMB = 8192;
      systemInfo.processorCores = 8;
      systemInfo.processorArchitecture = 'arm64';
      
      print('📱 시스템 정보: ${systemInfo.deviceModel} (${systemInfo.platform})');
      
    } catch (e) {
      print('⚠️ 시스템 정보 수집 실패: $e');
      systemInfo.errorMessage = e.toString();
    }
    
    return systemInfo;
  }
  
  /// 오디오 시스템 테스트
  Future<AudioSystemTest> _testAudioSystem() async {
    final test = AudioSystemTest();
    final stopwatch = Stopwatch()..start();
    
    try {
      // 오디오 초기화 테스트
      final preprocessor = AudioPreprocessor();
      await preprocessor.initialize();
      
      test.initializationTimeMs = stopwatch.elapsedMilliseconds;
      test.isInitialized = true;
      
      // 샘플 레이트 테스트
      final sampleRates = [16000, 22050, 44100, 48000];
      for (final rate in sampleRates) {
        final testResult = await _testSampleRate(rate);
        test.supportedSampleRates.add(rate);
        test.sampleRateLatency[rate] = testResult['latency'] as double;
      }
      
      // 기본 오디오 처리 테스트
      final testAudio = _generateTestAudio(16000, 1.0); // 1초 테스트 오디오
      final processedAudio = preprocessor.preprocess(testAudio);
      
      test.processingLatencyMs = stopwatch.elapsedMilliseconds.toDouble();
      test.isProcessingWorking = processedAudio.isNotEmpty;
      
      await preprocessor.dispose();
      
      print('🎵 오디오 시스템: 초기화 ${test.initializationTimeMs}ms, 지원 샘플레이트 ${test.supportedSampleRates.length}개');
      
    } catch (e) {
      print('❌ 오디오 시스템 테스트 실패: $e');
      test.errorMessage = e.toString();
      test.isInitialized = false;
    }
    
    stopwatch.stop();
    test.totalTestTimeMs = stopwatch.elapsedMilliseconds;
    
    return test;
  }
  
  /// 샘플 레이트 테스트
  Future<Map<String, dynamic>> _testSampleRate(int sampleRate) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // 테스트 오디오 생성 및 처리
      final testAudio = _generateTestAudio(sampleRate, 0.1); // 100ms
      final preprocessor = AudioPreprocessor();
      
      final processed = preprocessor.preprocess(testAudio);
      
      stopwatch.stop();
      
      return {
        'supported': true,
        'latency': stopwatch.elapsedMilliseconds.toDouble(),
        'processed_samples': processed.length,
      };
    } catch (e) {
      stopwatch.stop();
      return {
        'supported': false,
        'latency': double.infinity,
        'error': e.toString(),
      };
    }
  }
  
  /// 피치 엔진 성능 테스트
  Future<PitchEngineTest> _testPitchEngine(
    String engineName,
    PitchEngine Function() engineFactory,
    BenchmarkConfig config,
  ) async {
    final test = PitchEngineTest(engineName: engineName);
    final stopwatch = Stopwatch();
    
    try {
      print('🔍 $engineName 엔진 테스트 시작');
      
      // 엔진 초기화
      stopwatch.start();
      final engine = engineFactory();
      await engine.initialize();
      stopwatch.stop();
      
      test.initializationTimeMs = stopwatch.elapsedMilliseconds.toDouble();
      test.isInitialized = true;
      
      // 다양한 주파수로 성능 테스트
      final testFrequencies = [110.0, 220.0, 440.0, 880.0]; // A2, A3, A4, A5
      
      for (final frequency in testFrequencies) {
        final frequencyTest = await _testFrequencyDetection(
          engine,
          frequency,
          config.testDurationSeconds,
        );
        test.frequencyTests[frequency] = frequencyTest;
      }
      
      // 전체 성능 메트릭 계산
      test.averageInferenceTimeMs = test.frequencyTests.values
          .map((t) => t.averageInferenceTimeMs)
          .reduce((a, b) => a + b) / test.frequencyTests.length;
          
      test.averageAccuracy = test.frequencyTests.values
          .map((t) => t.accuracy)
          .reduce((a, b) => a + b) / test.frequencyTests.length;
          
      test.totalProcessedFrames = test.frequencyTests.values
          .map((t) => t.processedFrames)
          .reduce((a, b) => a + b);
      
      // 실시간 처리 가능 여부 확인
      test.canRunRealtime = test.averageInferenceTimeMs <= config.realtimeThresholdMs;
      
      // 정확도 기반 품질 등급
      if (test.averageAccuracy >= 0.95) {
        test.qualityGrade = 'Excellent';
      } else if (test.averageAccuracy >= 0.85) {
        test.qualityGrade = 'Good';
      } else if (test.averageAccuracy >= 0.70) {
        test.qualityGrade = 'Fair';
      } else {
        test.qualityGrade = 'Poor';
      }
      
      await engine.dispose();
      
      print('✅ $engineName 테스트 완료: ${test.qualityGrade}, 실시간=${test.canRunRealtime}');
      
    } catch (e) {
      print('❌ $engineName 엔진 테스트 실패: $e');
      test.errorMessage = e.toString();
      test.isInitialized = false;
    }
    
    return test;
  }
  
  /// 특정 주파수 감지 테스트
  Future<FrequencyTest> _testFrequencyDetection(
    PitchEngine engine,
    double targetFrequency,
    double durationSeconds,
  ) async {
    final test = FrequencyTest(targetFrequency: targetFrequency);
    final stopwatch = Stopwatch();
    
    // 테스트 오디오 생성 (순수 사인파)
    final sampleRate = engine.sampleRate;
    final frameSize = sampleRate ~/ 50; // 20ms frames
    final totalFrames = (durationSeconds * 50).round(); // 50 FPS
    
    final List<double> inferenceTimes = [];
    final List<double> detectedFrequencies = [];
    
    for (int i = 0; i < totalFrames; i++) {
      final audioFrame = _generateSineWave(targetFrequency, frameSize, sampleRate);
      final timeMs = i * 20.0; // 20ms per frame
      
      stopwatch.reset();
      stopwatch.start();
      
      final pitchFrame = await engine.estimatePitch(audioFrame, timeMs);
      
      stopwatch.stop();
      inferenceTimes.add(stopwatch.elapsedMicroseconds / 1000.0); // ms
      
      if (pitchFrame != null && pitchFrame.f0Hz > 0) {
        detectedFrequencies.add(pitchFrame.f0Hz);
      }
    }
    
    // 성능 메트릭 계산
    test.processedFrames = totalFrames;
    test.detectedFrames = detectedFrequencies.length;
    test.averageInferenceTimeMs = inferenceTimes.isEmpty ? 0 : 
        inferenceTimes.reduce((a, b) => a + b) / inferenceTimes.length;
    test.maxInferenceTimeMs = inferenceTimes.isEmpty ? 0 : inferenceTimes.reduce(max);
    test.minInferenceTimeMs = inferenceTimes.isEmpty ? 0 : inferenceTimes.reduce(min);
    
    // 정확도 계산 (±5% 허용 오차)
    if (detectedFrequencies.isNotEmpty) {
      final accurateDetections = detectedFrequencies.where((freq) {
        final error = (freq - targetFrequency).abs() / targetFrequency;
        return error <= 0.05; // 5% 오차 허용
      }).length;
      
      test.accuracy = accurateDetections / detectedFrequencies.length;
      test.averageDetectedFrequency = detectedFrequencies.reduce((a, b) => a + b) / detectedFrequencies.length;
      test.frequencyError = (test.averageDetectedFrequency - targetFrequency).abs();
    } else {
      test.accuracy = 0.0;
      test.averageDetectedFrequency = 0.0;
      test.frequencyError = double.infinity;
    }
    
    return test;
  }
  
  /// 실시간 처리 능력 테스트
  Future<RealtimeTest> _testRealtimeCapability(BenchmarkConfig config) async {
    final test = RealtimeTest();
    
    try {
      print('⚡ 실시간 처리 능력 테스트');
      
      final engine = HybridPitchEngine();
      await engine.initialize();
      
      final sampleRate = engine.sampleRate;
      final frameSize = sampleRate ~/ 50; // 20ms frames
      final testDurationMs = config.realtimeTestDurationMs;
      final expectedFrames = testDurationMs ~/ 20; // 20ms per frame
      
      final List<double> frameTimes = [];
      final stopwatch = Stopwatch()..start();
      
      int processedFrames = 0;
      int droppedFrames = 0;
      
      while (stopwatch.elapsedMilliseconds < testDurationMs) {
        final frameStopwatch = Stopwatch()..start();
        
        // 실시간 오디오 시뮬레이션 (440Hz 사인파)
        final audioFrame = _generateSineWave(440.0, frameSize, sampleRate);
        final timeMs = stopwatch.elapsedMilliseconds.toDouble();
        
        final pitchFrame = await engine.estimatePitch(audioFrame, timeMs);
        
        frameStopwatch.stop();
        final frameTime = frameStopwatch.elapsedMicroseconds / 1000.0; // ms
        
        frameTimes.add(frameTime);
        processedFrames++;
        
        // 실시간 기준 (20ms) 초과 시 드롭된 것으로 간주
        if (frameTime > 20.0) {
          droppedFrames++;
        }
        
        // 20ms 간격 유지를 위한 대기 (실제로는 오디오 콜백에서 처리)
        await Future.delayed(const Duration(milliseconds: 20));
      }
      
      await engine.dispose();
      
      // 성능 메트릭 계산
      test.processedFrames = processedFrames;
      test.droppedFrames = droppedFrames;
      test.expectedFrames = expectedFrames;
      test.frameDropRate = droppedFrames / processedFrames;
      test.averageFrameTimeMs = frameTimes.reduce((a, b) => a + b) / frameTimes.length;
      test.maxFrameTimeMs = frameTimes.reduce(max);
      test.canMaintainRealtime = test.frameDropRate <= config.acceptableDropRate;
      
      // CPU 사용률 추정 (프레임 시간 기반)
      test.estimatedCpuUsage = (test.averageFrameTimeMs / 20.0).clamp(0.0, 1.0);
      
      print('⚡ 실시간 테스트: ${test.processedFrames}프레임, 드롭률=${(test.frameDropRate * 100).toStringAsFixed(1)}%');
      
    } catch (e) {
      print('❌ 실시간 테스트 실패: $e');
      test.errorMessage = e.toString();
    }
    
    return test;
  }
  
  /// 메모리 사용량 테스트
  Future<MemoryTest> _testMemoryUsage(BenchmarkConfig config) async {
    final test = MemoryTest();
    
    try {
      print('💾 메모리 사용량 테스트');
      
      // 기본 메모리 사용량 측정
      test.baselineMemoryMB = await _measureMemoryUsage();
      
      // 피치 엔진들의 메모리 사용량 테스트
      final engines = [
        ('Hybrid', () => HybridPitchEngine()),
        ('CREPE', () => CrepeEngine()),
      ];
      
      for (final (name, factory) in engines) {
        final engine = factory();
        
        final beforeMB = await _measureMemoryUsage();
        await engine.initialize();
        final afterInitMB = await _measureMemoryUsage();
        
        // 처리 중 메모리 사용량 측정
        final audioFrame = _generateTestAudio(engine.sampleRate, 1.0);
        for (int i = 0; i < 100; i++) { // 100프레임 처리
          await engine.estimatePitch(
            Float32List.sublistView(audioFrame, 0, engine.sampleRate ~/ 50),
            i * 20.0,
          );
        }
        
        final afterProcessingMB = await _measureMemoryUsage();
        
        await engine.dispose();
        final afterDisposeMB = await _measureMemoryUsage();
        
        test.engineMemoryUsage[name] = EngineMemoryUsage(
          engineName: name,
          initializationMB: afterInitMB - beforeMB,
          processingMB: afterProcessingMB - afterInitMB,
          peakMB: afterProcessingMB - beforeMB,
          afterDisposeMB: afterDisposeMB - beforeMB,
        );
        
        print('💾 $name 메모리: 초기화 ${(afterInitMB - beforeMB).toStringAsFixed(1)}MB, '
              '처리 ${(afterProcessingMB - afterInitMB).toStringAsFixed(1)}MB');
      }
      
      // 전체 메모리 사용량 계산
      test.peakMemoryMB = test.engineMemoryUsage.values
          .map((usage) => usage.peakMB)
          .reduce(max) + test.baselineMemoryMB;
      
      test.totalMemoryMB = await _measureMemoryUsage();
      
    } catch (e) {
      print('❌ 메모리 테스트 실패: $e');
      test.errorMessage = e.toString();
    }
    
    return test;
  }
  
  /// 배터리 영향도 테스트
  Future<BatteryTest> _testBatteryImpact(BenchmarkConfig config) async {
    final test = BatteryTest();
    
    try {
      print('🔋 배터리 영향도 테스트');
      
      // 배터리 테스트는 실제 환경에서 정확한 측정이 어려우므로
      // CPU 사용률과 추론 시간을 기반으로 추정
      
      final engines = [
        ('Hybrid', () => HybridPitchEngine()),
        ('CREPE', () => CrepeEngine()),
      ];
      
      for (final (name, factory) in engines) {
        final engine = factory();
        await engine.initialize();
        
        final stopwatch = Stopwatch()..start();
        final List<double> cpuTimes = [];
        
        // 1분간 연속 처리 시뮬레이션
        const testDurationMs = 60 * 1000; // 1분
        const frameIntervalMs = 20; // 20ms 간격
        
        while (stopwatch.elapsedMilliseconds < testDurationMs) {
          final frameStopwatch = Stopwatch()..start();
          
          final audioFrame = _generateSineWave(440.0, engine.sampleRate ~/ 50, engine.sampleRate);
          await engine.estimatePitch(audioFrame, stopwatch.elapsedMilliseconds.toDouble());
          
          frameStopwatch.stop();
          cpuTimes.add(frameStopwatch.elapsedMicroseconds / 1000.0);
          
          await Future.delayed(const Duration(milliseconds: frameIntervalMs));
        }
        
        stopwatch.stop();
        
        // 배터리 영향도 추정
        final avgCpuTime = cpuTimes.reduce((a, b) => a + b) / cpuTimes.length;
        final cpuUtilization = avgCpuTime / frameIntervalMs;
        
        // 배터리 영향도 등급 (CPU 사용률 기반)
        String impactGrade;
        if (cpuUtilization <= 0.1) {
          impactGrade = 'Very Low';
        } else if (cpuUtilization <= 0.3) {
          impactGrade = 'Low';
        } else if (cpuUtilization <= 0.6) {
          impactGrade = 'Moderate';
        } else if (cpuUtilization <= 0.8) {
          impactGrade = 'High';
        } else {
          impactGrade = 'Very High';
        }
        
        test.engineBatteryImpact[name] = EngineBatteryImpact(
          engineName: name,
          estimatedCpuUsage: cpuUtilization,
          averageFrameTimeMs: avgCpuTime,
          estimatedBatteryDrainPerHour: cpuUtilization * 100, // % per hour (추정)
          impactGrade: impactGrade,
        );
        
        await engine.dispose();
        
        print('🔋 $name 배터리 영향: $impactGrade (CPU ${(cpuUtilization * 100).toStringAsFixed(1)}%)');
      }
      
    } catch (e) {
      print('❌ 배터리 테스트 실패: $e');
      test.errorMessage = e.toString();
    }
    
    return test;
  }
  
  /// 메모리 사용량 측정 (추정)
  Future<double> _measureMemoryUsage() async {
    // 실제로는 platform channel을 통해 메모리 사용량을 측정
    // 여기서는 시뮬레이션 값 반환
    await Future.delayed(const Duration(milliseconds: 10));
    return 50.0 + Random().nextDouble() * 20; // 50-70MB 시뮬레이션
  }
  
  /// 최적 설정 추천 계산
  BenchmarkRecommendations _calculateRecommendations(BenchmarkResult result) {
    final recommendations = BenchmarkRecommendations();
    
    try {
      print('🎯 최적 설정 계산');
      
      // 사용 가능한 엔진들 평가
      final availableEngines = <String, PitchEngineTest>{};
      
      if (result.hybridEngineTest?.isInitialized == true) {
        availableEngines['Hybrid'] = result.hybridEngineTest!;
      }
      if (result.crepeEngineTest?.isInitialized == true) {
        availableEngines['CREPE-Tiny'] = result.crepeEngineTest!;
      }
      
      if (availableEngines.isEmpty) {
        recommendations.recommendedEngine = 'None';
        recommendations.reason = '사용 가능한 피치 엔진이 없습니다';
        recommendations.qualityScore = 0.0;
        return recommendations;
      }
      
      // 엔진별 점수 계산 (정확도 60%, 성능 30%, 배터리 10%)
      double bestScore = 0.0;
      String bestEngine = '';
      String bestReason = '';
      
      for (final entry in availableEngines.entries) {
        final name = entry.key;
        final test = entry.value;
        
        final accuracyScore = test.averageAccuracy * 0.6;
        final performanceScore = test.canRunRealtime ? 0.3 : (40.0 / test.averageInferenceTimeMs) * 0.3;
        final batteryScore = _getBatteryScore(name, result) * 0.1;
        
        final totalScore = accuracyScore + performanceScore + batteryScore;
        
        if (totalScore > bestScore) {
          bestScore = totalScore;
          bestEngine = name;
          bestReason = _generateRecommendationReason(name, test, result);
        }
      }
      
      recommendations.recommendedEngine = bestEngine;
      recommendations.reason = bestReason;
      recommendations.qualityScore = bestScore;
      
      // 설정 권장사항
      final bestEngineTest = availableEngines[bestEngine]!;
      
      recommendations.settings = BenchmarkSettings(
        pitchEngine: bestEngine,
        enableRealtimeProcessing: bestEngineTest.canRunRealtime,
        frameSize: bestEngineTest.canRunRealtime ? 1024 : 2048,
        hopSize: bestEngineTest.canRunRealtime ? 512 : 1024,
        windowFunction: 'hann',
        enableHighPassFilter: true,
        highPassCutoff: 80.0,
        enableNotchFilter: true,
        notchFrequency: 60.0,
        confidenceThreshold: bestEngineTest.averageAccuracy > 0.9 ? 0.85 : 0.75,
      );
      
      // 추가 권장사항
      if (result.memoryTest?.peakMemoryMB != null && result.memoryTest!.peakMemoryMB > 200) {
        recommendations.additionalRecommendations.add('메모리 사용량이 높습니다. 배경 앱을 종료해보세요.');
      }
      
      if (result.realtimeTest?.frameDropRate != null && result.realtimeTest!.frameDropRate > 0.1) {
        recommendations.additionalRecommendations.add('프레임 드롭이 발생합니다. 다른 앱을 종료하거나 성능 모드를 활성화해보세요.');
      }
      
      if (bestEngine == 'CREPE-Tiny' && result.batteryTest?.engineBatteryImpact['CREPE']?.impactGrade == 'High') {
        recommendations.additionalRecommendations.add('CREPE 엔진은 배터리 소모가 큽니다. 배터리 절약이 필요하면 Hybrid 엔진을 고려해보세요.');
      }
      
      print('🎯 추천 엔진: $bestEngine (점수: ${(bestScore * 100).toStringAsFixed(1)})');
      
    } catch (e) {
      print('❌ 추천 계산 실패: $e');
      recommendations.recommendedEngine = 'Hybrid'; // 기본값
      recommendations.reason = '기본 설정을 사용합니다';
      recommendations.qualityScore = 0.5;
    }
    
    return recommendations;
  }
  
  /// 배터리 점수 계산
  double _getBatteryScore(String engineName, BenchmarkResult result) {
    final batteryImpact = result.batteryTest?.engineBatteryImpact[engineName];
    if (batteryImpact == null) return 0.5;
    
    switch (batteryImpact.impactGrade) {
      case 'Very Low':
        return 1.0;
      case 'Low':
        return 0.8;
      case 'Moderate':
        return 0.6;
      case 'High':
        return 0.4;
      case 'Very High':
        return 0.2;
      default:
        return 0.5;
    }
  }
  
  /// 추천 이유 생성
  String _generateRecommendationReason(
    String engineName,
    PitchEngineTest test,
    BenchmarkResult result,
  ) {
    final reasons = <String>[];
    
    if (test.averageAccuracy >= 0.9) {
      reasons.add('높은 정확도 (${(test.averageAccuracy * 100).toStringAsFixed(1)}%)');
    }
    
    if (test.canRunRealtime) {
      reasons.add('실시간 처리 가능');
    }
    
    final batteryImpact = result.batteryTest?.engineBatteryImpact[engineName];
    if (batteryImpact != null && ['Very Low', 'Low'].contains(batteryImpact.impactGrade)) {
      reasons.add('낮은 배터리 소모');
    }
    
    if (reasons.isEmpty) {
      reasons.add('기본 추천 엔진');
    }
    
    return reasons.join(', ');
  }
  
  /// 성능 등급 산정
  PerformanceGrade _calculatePerformanceGrade(BenchmarkResult result) {
    final grade = PerformanceGrade();
    
    try {
      double totalScore = 0.0;
      int categoryCount = 0;
      
      // 오디오 시스템 점수 (20%)
      if (result.audioSystemTest?.isInitialized == true) {
        final audioScore = _calculateAudioSystemScore(result.audioSystemTest!);
        grade.audioSystemScore = audioScore;
        totalScore += audioScore * 0.2;
        categoryCount++;
      }
      
      // 피치 엔진 점수 (40%)
      double engineScore = 0.0;
      int engineCount = 0;
      
      if (result.hybridEngineTest?.isInitialized == true) {
        final score = _calculateEngineScore(result.hybridEngineTest!);
        grade.hybridEngineScore = score;
        engineScore += score;
        engineCount++;
      }
      
      if (result.crepeEngineTest?.isInitialized == true) {
        final score = _calculateEngineScore(result.crepeEngineTest!);
        grade.crepeEngineScore = score;
        engineScore += score;
        engineCount++;
      }
      
      if (engineCount > 0) {
        grade.pitchEngineScore = engineScore / engineCount;
        totalScore += grade.pitchEngineScore * 0.4;
        categoryCount++;
      }
      
      // 실시간 처리 점수 (25%)
      if (result.realtimeTest != null) {
        final realtimeScore = _calculateRealtimeScore(result.realtimeTest!);
        grade.realtimeScore = realtimeScore;
        totalScore += realtimeScore * 0.25;
        categoryCount++;
      }
      
      // 리소스 효율성 점수 (15%)
      if (result.memoryTest != null && result.batteryTest != null) {
        final resourceScore = _calculateResourceScore(result.memoryTest!, result.batteryTest!);
        grade.resourceEfficiencyScore = resourceScore;
        totalScore += resourceScore * 0.15;
        categoryCount++;
      }
      
      // 전체 점수 계산
      if (categoryCount > 0) {
        grade.overallScore = totalScore / (categoryCount > 0 ? categoryCount : 1);
      } else {
        grade.overallScore = 0.0;
      }
      
      // 등급 결정
      if (grade.overallScore >= 0.9) {
        grade.grade = 'S';
        grade.description = '최고 성능 - 모든 기능을 완벽하게 지원합니다';
      } else if (grade.overallScore >= 0.8) {
        grade.grade = 'A';
        grade.description = '우수한 성능 - 실시간 처리와 높은 정확도를 제공합니다';
      } else if (grade.overallScore >= 0.7) {
        grade.grade = 'B';
        grade.description = '양호한 성능 - 일반적인 사용에 적합합니다';
      } else if (grade.overallScore >= 0.6) {
        grade.grade = 'C';
        grade.description = '보통 성능 - 기본 기능을 사용할 수 있습니다';
      } else if (grade.overallScore >= 0.4) {
        grade.grade = 'D';
        grade.description = '낮은 성능 - 일부 기능에 제한이 있을 수 있습니다';
      } else {
        grade.grade = 'F';
        grade.description = '성능 부족 - 원활한 사용이 어려울 수 있습니다';
      }
      
      print('📊 성능 등급: ${grade.grade} (${(grade.overallScore * 100).toStringAsFixed(1)}점)');
      
    } catch (e) {
      print('❌ 성능 등급 계산 실패: $e');
      grade.grade = 'Unknown';
      grade.description = '성능 평가를 완료할 수 없습니다';
      grade.overallScore = 0.0;
    }
    
    return grade;
  }
  
  /// 오디오 시스템 점수 계산
  double _calculateAudioSystemScore(AudioSystemTest test) {
    double score = 0.0;
    
    // 초기화 시간 점수 (빠를수록 좋음)
    if (test.initializationTimeMs <= 100) {
      score += 0.3;
    } else if (test.initializationTimeMs <= 500) {
      score += 0.2;
    } else if (test.initializationTimeMs <= 1000) {
      score += 0.1;
    }
    
    // 지원 샘플레이트 개수 점수
    if (test.supportedSampleRates.length >= 4) {
      score += 0.3;
    } else if (test.supportedSampleRates.length >= 2) {
      score += 0.2;
    } else if (test.supportedSampleRates.isNotEmpty) {
      score += 0.1;
    }
    
    // 처리 지연시간 점수
    if (test.processingLatencyMs <= 10) {
      score += 0.4;
    } else if (test.processingLatencyMs <= 50) {
      score += 0.3;
    } else if (test.processingLatencyMs <= 100) {
      score += 0.2;
    } else if (test.processingLatencyMs <= 200) {
      score += 0.1;
    }
    
    return score.clamp(0.0, 1.0);
  }
  
  /// 엔진 점수 계산
  double _calculateEngineScore(PitchEngineTest test) {
    double score = 0.0;
    
    // 정확도 점수 (60%)
    score += test.averageAccuracy * 0.6;
    
    // 성능 점수 (30%)
    if (test.canRunRealtime) {
      score += 0.3;
    } else if (test.averageInferenceTimeMs <= 100) {
      score += 0.2;
    } else if (test.averageInferenceTimeMs <= 200) {
      score += 0.1;
    }
    
    // 안정성 점수 (10%)
    if (test.qualityGrade == 'Excellent') {
      score += 0.1;
    } else if (test.qualityGrade == 'Good') {
      score += 0.08;
    } else if (test.qualityGrade == 'Fair') {
      score += 0.05;
    }
    
    return score.clamp(0.0, 1.0);
  }
  
  /// 실시간 처리 점수 계산
  double _calculateRealtimeScore(RealtimeTest test) {
    double score = 0.0;
    
    // 프레임 드롭률 점수 (50%)
    if (test.frameDropRate <= 0.01) { // 1% 이하
      score += 0.5;
    } else if (test.frameDropRate <= 0.05) { // 5% 이하
      score += 0.4;
    } else if (test.frameDropRate <= 0.1) { // 10% 이하
      score += 0.3;
    } else if (test.frameDropRate <= 0.2) { // 20% 이하
      score += 0.2;
    } else if (test.frameDropRate <= 0.3) { // 30% 이하
      score += 0.1;
    }
    
    // 평균 프레임 시간 점수 (30%)
    if (test.averageFrameTimeMs <= 10) {
      score += 0.3;
    } else if (test.averageFrameTimeMs <= 15) {
      score += 0.25;
    } else if (test.averageFrameTimeMs <= 20) {
      score += 0.2;
    } else if (test.averageFrameTimeMs <= 30) {
      score += 0.1;
    }
    
    // 실시간 유지 능력 점수 (20%)
    if (test.canMaintainRealtime) {
      score += 0.2;
    }
    
    return score.clamp(0.0, 1.0);
  }
  
  /// 리소스 효율성 점수 계산
  double _calculateResourceScore(MemoryTest memoryTest, BatteryTest batteryTest) {
    double score = 0.0;
    
    // 메모리 점수 (50%)
    if (memoryTest.peakMemoryMB <= 100) {
      score += 0.5;
    } else if (memoryTest.peakMemoryMB <= 200) {
      score += 0.4;
    } else if (memoryTest.peakMemoryMB <= 300) {
      score += 0.3;
    } else if (memoryTest.peakMemoryMB <= 500) {
      score += 0.2;
    } else if (memoryTest.peakMemoryMB <= 1000) {
      score += 0.1;
    }
    
    // 배터리 점수 (50%)
    final batteryGrades = batteryTest.engineBatteryImpact.values
        .map((impact) => impact.impactGrade)
        .toList();
    
    if (batteryGrades.isNotEmpty) {
      final bestGrade = batteryGrades.reduce((a, b) {
        final gradeOrder = ['Very Low', 'Low', 'Moderate', 'High', 'Very High'];
        return gradeOrder.indexOf(a) <= gradeOrder.indexOf(b) ? a : b;
      });
      
      switch (bestGrade) {
        case 'Very Low':
          score += 0.5;
          break;
        case 'Low':
          score += 0.4;
          break;
        case 'Moderate':
          score += 0.3;
          break;
        case 'High':
          score += 0.2;
          break;
        case 'Very High':
          score += 0.1;
          break;
      }
    }
    
    return score.clamp(0.0, 1.0);
  }
  
  /// 테스트 오디오 생성 (사인파)
  Float32List _generateTestAudio(int sampleRate, double durationSeconds) {
    final samples = (sampleRate * durationSeconds).round();
    final audio = Float32List(samples);
    
    for (int i = 0; i < samples; i++) {
      // 복합 주파수 (440Hz + 880Hz)
      final t = i / sampleRate;
      audio[i] = (sin(2 * pi * 440 * t) + 0.5 * sin(2 * pi * 880 * t)) * 0.5;
    }
    
    return audio;
  }
  
  /// 사인파 생성
  Float32List _generateSineWave(double frequency, int samples, int sampleRate) {
    final audio = Float32List(samples);
    
    for (int i = 0; i < samples; i++) {
      final t = i / sampleRate;
      audio[i] = sin(2 * pi * frequency * t);
    }
    
    return audio;
  }
}

/// 벤치마크 설정
class BenchmarkConfig {
  final double testDurationSeconds;
  final double realtimeThresholdMs;
  final int realtimeTestDurationMs;
  final double acceptableDropRate;
  
  BenchmarkConfig({
    this.testDurationSeconds = 5.0,
    this.realtimeThresholdMs = 40.0,
    this.realtimeTestDurationMs = 30000,
    this.acceptableDropRate = 0.1,
  });
  
  factory BenchmarkConfig.standard() => BenchmarkConfig();
  factory BenchmarkConfig.quick() => BenchmarkConfig(
    testDurationSeconds: 2.0,
    realtimeTestDurationMs: 10000,
  );
  factory BenchmarkConfig.thorough() => BenchmarkConfig(
    testDurationSeconds: 10.0,
    realtimeTestDurationMs: 60000,
  );
}

/// 벤치마크 진행상황
class BenchmarkProgress {
  final String status;
  final double progress; // 0.0 ~ 1.0
  final DateTime timestamp;
  
  BenchmarkProgress({
    required this.status,
    required this.progress,
    required this.timestamp,
  });
}

/// 벤치마크 결과
class BenchmarkResult {
  bool isSuccess = false;
  String? errorMessage;
  DateTime? completedAt;
  
  SystemInfo? systemInfo;
  AudioSystemTest? audioSystemTest;
  PitchEngineTest? hybridEngineTest;
  PitchEngineTest? crepeEngineTest;
  RealtimeTest? realtimeTest;
  MemoryTest? memoryTest;
  BatteryTest? batteryTest;
  BenchmarkRecommendations? recommendations;
  PerformanceGrade? performanceGrade;
  
  /// 벤치마크 소요 시간
  Duration? get duration {
    if (completedAt == null) return null;
    
    final startTime = systemInfo?.timestamp ?? completedAt!.subtract(const Duration(minutes: 5));
    return completedAt!.difference(startTime);
  }
}

/// 시스템 정보
class SystemInfo {
  String platform = '';
  String deviceModel = '';
  String osVersion = '';
  bool isDebugMode = false;
  int availableMemoryMB = 0;
  int totalMemoryMB = 0;
  int processorCores = 0;
  String processorArchitecture = '';
  DateTime? timestamp;
  String? errorMessage;
}

/// 오디오 시스템 테스트 결과
class AudioSystemTest {
  bool isInitialized = false;
  double initializationTimeMs = 0;
  List<int> supportedSampleRates = [];
  Map<int, double> sampleRateLatency = {};
  double processingLatencyMs = 0;
  bool isProcessingWorking = false;
  int totalTestTimeMs = 0;
  String? errorMessage;
}

/// 피치 엔진 테스트 결과
class PitchEngineTest {
  final String engineName;
  bool isInitialized = false;
  double initializationTimeMs = 0;
  double averageInferenceTimeMs = 0;
  double averageAccuracy = 0;
  int totalProcessedFrames = 0;
  bool canRunRealtime = false;
  String qualityGrade = 'Unknown';
  Map<double, FrequencyTest> frequencyTests = {};
  String? errorMessage;
  
  PitchEngineTest({required this.engineName});
}

/// 주파수 테스트 결과
class FrequencyTest {
  final double targetFrequency;
  int processedFrames = 0;
  int detectedFrames = 0;
  double averageInferenceTimeMs = 0;
  double maxInferenceTimeMs = 0;
  double minInferenceTimeMs = 0;
  double accuracy = 0;
  double averageDetectedFrequency = 0;
  double frequencyError = 0;
  
  FrequencyTest({required this.targetFrequency});
}

/// 실시간 처리 테스트 결과
class RealtimeTest {
  int processedFrames = 0;
  int droppedFrames = 0;
  int expectedFrames = 0;
  double frameDropRate = 0;
  double averageFrameTimeMs = 0;
  double maxFrameTimeMs = 0;
  bool canMaintainRealtime = false;
  double estimatedCpuUsage = 0;
  String? errorMessage;
}

/// 메모리 테스트 결과
class MemoryTest {
  double baselineMemoryMB = 0;
  double peakMemoryMB = 0;
  double totalMemoryMB = 0;
  Map<String, EngineMemoryUsage> engineMemoryUsage = {};
  String? errorMessage;
}

/// 엔진별 메모리 사용량
class EngineMemoryUsage {
  final String engineName;
  final double initializationMB;
  final double processingMB;
  final double peakMB;
  final double afterDisposeMB;
  
  EngineMemoryUsage({
    required this.engineName,
    required this.initializationMB,
    required this.processingMB,
    required this.peakMB,
    required this.afterDisposeMB,
  });
}

/// 배터리 테스트 결과
class BatteryTest {
  Map<String, EngineBatteryImpact> engineBatteryImpact = {};
  String? errorMessage;
}

/// 엔진별 배터리 영향도
class EngineBatteryImpact {
  final String engineName;
  final double estimatedCpuUsage;
  final double averageFrameTimeMs;
  final double estimatedBatteryDrainPerHour;
  final String impactGrade;
  
  EngineBatteryImpact({
    required this.engineName,
    required this.estimatedCpuUsage,
    required this.averageFrameTimeMs,
    required this.estimatedBatteryDrainPerHour,
    required this.impactGrade,
  });
}

/// 벤치마크 추천 설정
class BenchmarkRecommendations {
  String recommendedEngine = '';
  String reason = '';
  double qualityScore = 0;
  BenchmarkSettings? settings;
  List<String> additionalRecommendations = [];
}

/// 벤치마크 기반 설정
class BenchmarkSettings {
  final String pitchEngine;
  final bool enableRealtimeProcessing;
  final int frameSize;
  final int hopSize;
  final String windowFunction;
  final bool enableHighPassFilter;
  final double highPassCutoff;
  final bool enableNotchFilter;
  final double notchFrequency;
  final double confidenceThreshold;
  
  BenchmarkSettings({
    required this.pitchEngine,
    required this.enableRealtimeProcessing,
    required this.frameSize,
    required this.hopSize,
    required this.windowFunction,
    required this.enableHighPassFilter,
    required this.highPassCutoff,
    required this.enableNotchFilter,
    required this.notchFrequency,
    required this.confidenceThreshold,
  });
}

/// 성능 등급
class PerformanceGrade {
  String grade = '';
  String description = '';
  double overallScore = 0;
  double audioSystemScore = 0;
  double pitchEngineScore = 0;
  double hybridEngineScore = 0;
  double crepeEngineScore = 0;
  double realtimeScore = 0;
  double resourceEfficiencyScore = 0;
}