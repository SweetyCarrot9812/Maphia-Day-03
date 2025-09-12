import 'dart:typed_data';
import 'dart:async';

import '../core/audio/pitch_engine.dart';
import '../core/audio/hybrid_pitch_engine.dart';
import '../core/audio/crepe_engine.dart';
import '../core/audio/pitch_frame.dart';
import '../core/audio/preprocess.dart';

/// 고급 피치 분석 서비스
/// 
/// HaneulTone v1 고도화 - 다중 엔진 피치 분석
/// 
/// Features:
/// - 다중 피치 엔진 지원 (Hybrid, CREPE)
/// - 성능 기반 엔진 자동 선택
/// - 적응형 품질 제어
/// - 실시간/배치 모드 지원
class AdvancedPitchService {
  final Map<PitchEngineType, PitchEngine> _engines = {};
  final AudioPreprocessor _preprocessor;
  
  PitchEngineType _currentEngineType = PitchEngineType.hybrid;
  PitchEngine? _currentEngine;
  
  /// 엔진 성능 통계
  final Map<PitchEngineType, EngineStats> _engineStats = {};
  
  /// 품질 설정
  PitchQualityMode _qualityMode = PitchQualityMode.balanced;
  
  bool _isInitialized = false;
  StreamController<PitchAnalysisEvent>? _eventController;

  AdvancedPitchService({required int sampleRate})
      : _preprocessor = AudioPreprocessor(sampleRate: sampleRate);

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    print('🚀 고급 피치 분석 서비스 초기화 중...');
    
    _eventController = StreamController<PitchAnalysisEvent>.broadcast();
    
    try {
      // 1. 기본 하이브리드 엔진 초기화
      final hybridEngine = HybridPitchEngine(sampleRate: _preprocessor.sampleRate);
      await hybridEngine.initialize();
      _engines[PitchEngineType.hybrid] = hybridEngine;
      _engineStats[PitchEngineType.hybrid] = EngineStats();
      
      // 2. CREPE 엔진 초기화 (선택적)
      await _initializeCrepeEngine();
      
      // 3. 초기 엔진 설정
      _currentEngine = _engines[_currentEngineType];
      
      _isInitialized = true;
      _notifyEvent(PitchAnalysisEvent.initialized());
      
      print('✅ 고급 피치 분석 서비스 초기화 완료');
    } catch (e) {
      print('❌ 피치 서비스 초기화 실패: $e');
      _notifyEvent(PitchAnalysisEvent.error('초기화 실패: $e'));
      rethrow;
    }
  }

  /// CREPE 엔진 초기화 (선택적)
  Future<void> _initializeCrepeEngine() async {
    try {
      final crepeEngine = CrepeEngine();
      await crepeEngine.initialize();
      
      _engines[PitchEngineType.crepe] = crepeEngine;
      _engineStats[PitchEngineType.crepe] = EngineStats();
      
      print('🤖 CREPE-Tiny 엔진 사용 가능');
      _notifyEvent(PitchAnalysisEvent.engineAvailable(PitchEngineType.crepe));
    } catch (e) {
      print('⚠️ CREPE 엔진 초기화 실패 (선택사항): $e');
      // CREPE 실패는 치명적이지 않음
    }
  }

  /// 이벤트 스트림
  Stream<PitchAnalysisEvent> get events => _eventController?.stream ?? const Stream.empty();

  /// 현재 엔진 타입
  PitchEngineType get currentEngineType => _currentEngineType;

  /// 사용 가능한 엔진들
  List<PitchEngineType> get availableEngines => _engines.keys.toList();

  /// 품질 모드 설정
  void setQualityMode(PitchQualityMode mode) {
    _qualityMode = mode;
    _notifyEvent(PitchAnalysisEvent.qualityModeChanged(mode));
    print('🎛️ 품질 모드 변경: $mode');
  }

  /// 엔진 수동 전환
  Future<void> switchEngine(PitchEngineType engineType) async {
    if (!_engines.containsKey(engineType)) {
      throw ArgumentError('엔진을 사용할 수 없습니다: $engineType');
    }

    _currentEngineType = engineType;
    _currentEngine = _engines[engineType];
    
    _notifyEvent(PitchAnalysisEvent.engineSwitched(engineType));
    print('🔄 피치 엔진 전환: $engineType');
  }

  /// 자동 엔진 선택 (성능 기반)
  Future<void> optimizeEngineSelection() async {
    if (_engines.length <= 1) return;

    print('🧠 최적 엔진 자동 선택 중...');
    
    // 각 엔진의 성능 평가
    PitchEngineType? bestEngine;
    double bestScore = 0;
    
    for (final entry in _engines.entries) {
      final engineType = entry.key;
      final stats = _engineStats[engineType]!;
      
      final score = _calculateEngineScore(engineType, stats);
      print('📊 $engineType 점수: ${score.toStringAsFixed(2)}');
      
      if (score > bestScore) {
        bestScore = score;
        bestEngine = engineType;
      }
    }
    
    if (bestEngine != null && bestEngine != _currentEngineType) {
      await switchEngine(bestEngine);
      print('🎯 최적 엔진 선택: $bestEngine (점수: ${bestScore.toStringAsFixed(2)})');
    }
  }

  /// 엔진 성능 점수 계산
  double _calculateEngineScore(PitchEngineType engineType, EngineStats stats) {
    double score = 0;
    
    // 정확도 점수 (40%)
    score += stats.averageAccuracy * 0.4;
    
    // 속도 점수 (30%)
    final targetTime = _qualityMode == PitchQualityMode.realtime ? 20.0 : 40.0;
    final speedScore = (targetTime / (stats.averageProcessingTime + 1)).clamp(0, 1);
    score += speedScore * 0.3;
    
    // 신뢰도 점수 (20%)
    score += stats.averageConfidence * 0.2;
    
    // 안정성 점수 (10%)
    final stabilityScore = stats.totalFrames > 0 ? (1.0 - stats.errorRate) : 0.5;
    score += stabilityScore * 0.1;
    
    // 엔진별 보너스
    switch (engineType) {
      case PitchEngineType.crepe:
        score += 0.1; // 높은 정확도 보너스
        break;
      case PitchEngineType.hybrid:
        score += 0.05; // 안정성 보너스
        break;
    }
    
    return score.clamp(0, 1);
  }

  /// 피치 분석 실행
  Future<PitchFrame?> analyzePitch(Float32List audioFrame, double timeMs) async {
    if (!_isInitialized || _currentEngine == null) {
      return null;
    }

    final stopwatch = Stopwatch()..start();
    
    try {
      // 1. 전처리
      final preprocessed = await _preprocessor.process(audioFrame);
      
      // 2. 품질 모드에 따른 처리
      PitchFrame? result;
      switch (_qualityMode) {
        case PitchQualityMode.fast:
          result = await _fastAnalysis(preprocessed, timeMs);
          break;
          
        case PitchQualityMode.balanced:
          result = await _balancedAnalysis(preprocessed, timeMs);
          break;
          
        case PitchQualityMode.highAccuracy:
          result = await _highAccuracyAnalysis(preprocessed, timeMs);
          break;
          
        case PitchQualityMode.realtime:
          result = await _realtimeAnalysis(preprocessed, timeMs);
          break;
      }
      
      // 3. 통계 업데이트
      stopwatch.stop();
      _updateEngineStats(stopwatch.elapsedMilliseconds.toDouble(), result);
      
      return result;
    } catch (e) {
      stopwatch.stop();
      _updateEngineStats(stopwatch.elapsedMilliseconds.toDouble(), null);
      print('❌ 피치 분석 오류: $e');
      return null;
    }
  }

  /// 빠른 분석 (저품질, 고속)
  Future<PitchFrame?> _fastAnalysis(Float32List audio, double timeMs) async {
    return await _currentEngine!.estimatePitch(audio, timeMs);
  }

  /// 균형 분석 (중품질, 중속)
  Future<PitchFrame?> _balancedAnalysis(Float32List audio, double timeMs) async {
    final result = await _currentEngine!.estimatePitch(audio, timeMs);
    
    // 중간 품질의 후처리
    if (result != null && result.confidence < 0.7) {
      return null; // 낮은 신뢰도 필터링
    }
    
    return result;
  }

  /// 고정밀 분석 (고품질, 저속)
  Future<PitchFrame?> _highAccuracyAnalysis(Float32List audio, double timeMs) async {
    // CREPE 우선 시도
    if (_engines.containsKey(PitchEngineType.crepe)) {
      final crepeResult = await _engines[PitchEngineType.crepe]!
          .estimatePitch(audio, timeMs);
      
      if (crepeResult != null && crepeResult.confidence >= 0.85) {
        return crepeResult;
      }
    }
    
    // 백업으로 하이브리드 사용
    return await _engines[PitchEngineType.hybrid]!.estimatePitch(audio, timeMs);
  }

  /// 실시간 분석 (초저지연)
  Future<PitchFrame?> _realtimeAnalysis(Float32List audio, double timeMs) async {
    // 최소한의 처리로 빠른 결과 제공
    final result = await _currentEngine!.estimatePitch(audio, timeMs);
    return result; // 모든 결과 통과 (낮은 신뢰도도 허용)
  }

  /// 엔진 통계 업데이트
  void _updateEngineStats(double processingTime, PitchFrame? result) {
    final stats = _engineStats[_currentEngineType]!;
    
    stats.totalFrames++;
    stats.totalProcessingTime += processingTime;
    stats.averageProcessingTime = stats.totalProcessingTime / stats.totalFrames;
    
    if (result != null) {
      stats.successfulFrames++;
      stats.totalConfidence += result.confidence;
      stats.averageConfidence = stats.totalConfidence / stats.successfulFrames;
      
      // 정확도는 별도 측정 필요 (참값과의 비교)
      // 여기서는 confidence를 proxy로 사용
      stats.totalAccuracy += result.confidence;
      stats.averageAccuracy = stats.totalAccuracy / stats.successfulFrames;
    } else {
      stats.errorFrames++;
    }
    
    stats.errorRate = stats.errorFrames / stats.totalFrames;
  }

  /// 배치 분석 (비실시간, 전체 파일)
  Future<List<PitchFrame>> analyzeBatch(
    Float32List audioData,
    double frameSize,
    double hopSize,
  ) async {
    if (!_isInitialized) {
      throw StateError('서비스가 초기화되지 않았습니다');
    }

    final results = <PitchFrame>[];
    final frameSamples = (frameSize * _preprocessor.sampleRate / 1000).round();
    final hopSamples = (hopSize * _preprocessor.sampleRate / 1000).round();
    
    print('📦 배치 분석 시작: ${audioData.length}샘플, 프레임: ${frameSamples}, 홉: ${hopSamples}');
    _notifyEvent(PitchAnalysisEvent.batchStarted(audioData.length));
    
    final totalFrames = ((audioData.length - frameSamples) / hopSamples).ceil();
    int processedFrames = 0;
    
    for (int i = 0; i + frameSamples <= audioData.length; i += hopSamples) {
      final frame = Float32List.fromList(
        audioData.sublist(i, i + frameSamples)
      );
      
      final timeMs = i * 1000.0 / _preprocessor.sampleRate;
      final result = await analyzePitch(frame, timeMs);
      
      if (result != null) {
        results.add(result);
      }
      
      processedFrames++;
      if (processedFrames % 50 == 0) {
        final progress = processedFrames / totalFrames;
        _notifyEvent(PitchAnalysisEvent.batchProgress(progress));
        print('📊 배치 진행률: ${(progress * 100).toStringAsFixed(1)}%');
      }
    }
    
    _notifyEvent(PitchAnalysisEvent.batchCompleted(results.length));
    print('✅ 배치 분석 완료: ${results.length}개 프레임');
    
    return results;
  }

  /// 서비스 성능 진단
  Future<ServiceDiagnostics> getDiagnostics() async {
    final engineDiagnostics = <PitchEngineType, Map<String, dynamic>>{};
    
    // 각 엔진의 진단 정보 수집
    for (final entry in _engines.entries) {
      final engineType = entry.key;
      final engine = entry.value;
      final stats = _engineStats[engineType]!;
      
      Map<String, dynamic> engineDiag = {
        'stats': stats.toJson(),
        'available': true,
      };
      
      // CREPE 전용 진단
      if (engine is CrepeEngine) {
        final crepePerf = await engine.getDiagnostics();
        engineDiag['performance'] = {
          'averageInferenceTimeMs': crepePerf.averageInferenceTimeMs,
          'modelSize': crepePerf.modelSize,
          'memoryUsageMB': crepePerf.memoryUsageMB,
          'performanceGrade': crepePerf.performanceGrade,
          'canRunRealtime': crepePerf.canRunRealtime,
        };
      }
      
      engineDiagnostics[engineType] = engineDiag;
    }
    
    return ServiceDiagnostics(
      isInitialized: _isInitialized,
      currentEngine: _currentEngineType,
      qualityMode: _qualityMode,
      availableEngines: availableEngines,
      engineDiagnostics: engineDiagnostics,
      totalProcessedFrames: _engineStats.values
          .map((s) => s.totalFrames)
          .fold(0, (a, b) => a + b),
    );
  }

  /// 이벤트 알림
  void _notifyEvent(PitchAnalysisEvent event) {
    _eventController?.add(event);
  }

  /// 서비스 정리
  Future<void> dispose() async {
    for (final engine in _engines.values) {
      await engine.dispose();
    }
    
    _engines.clear();
    _engineStats.clear();
    
    await _eventController?.close();
    _eventController = null;
    
    _isInitialized = false;
    print('🧹 고급 피치 분석 서비스 정리 완료');
  }
}

/// 피치 엔진 타입
enum PitchEngineType {
  hybrid,   // FFT + YIN 하이브리드
  crepe,    // CREPE-Tiny TFLite
}

/// 품질 모드
enum PitchQualityMode {
  fast,         // 빠른 처리 (저품질)
  balanced,     // 균형 (중품질)
  highAccuracy, // 고정밀 (고품질)  
  realtime,     // 실시간 (초저지연)
}

/// 엔진 성능 통계
class EngineStats {
  int totalFrames = 0;
  int successfulFrames = 0;
  int errorFrames = 0;
  double totalProcessingTime = 0;
  double averageProcessingTime = 0;
  double totalConfidence = 0;
  double averageConfidence = 0;
  double totalAccuracy = 0;
  double averageAccuracy = 0;
  double errorRate = 0;

  Map<String, dynamic> toJson() {
    return {
      'totalFrames': totalFrames,
      'successfulFrames': successfulFrames,
      'errorFrames': errorFrames,
      'averageProcessingTime': averageProcessingTime,
      'averageConfidence': averageConfidence,
      'averageAccuracy': averageAccuracy,
      'errorRate': errorRate,
    };
  }
}

/// 서비스 진단 정보
class ServiceDiagnostics {
  final bool isInitialized;
  final PitchEngineType currentEngine;
  final PitchQualityMode qualityMode;
  final List<PitchEngineType> availableEngines;
  final Map<PitchEngineType, Map<String, dynamic>> engineDiagnostics;
  final int totalProcessedFrames;

  ServiceDiagnostics({
    required this.isInitialized,
    required this.currentEngine,
    required this.qualityMode,
    required this.availableEngines,
    required this.engineDiagnostics,
    required this.totalProcessedFrames,
  });
}

/// 피치 분석 이벤트
class PitchAnalysisEvent {
  final PitchAnalysisEventType type;
  final Map<String, dynamic> data;

  PitchAnalysisEvent(this.type, [this.data = const {}]);

  factory PitchAnalysisEvent.initialized() =>
      PitchAnalysisEvent(PitchAnalysisEventType.initialized);
  
  factory PitchAnalysisEvent.engineAvailable(PitchEngineType engine) =>
      PitchAnalysisEvent(PitchAnalysisEventType.engineAvailable, {'engine': engine});
  
  factory PitchAnalysisEvent.engineSwitched(PitchEngineType engine) =>
      PitchAnalysisEvent(PitchAnalysisEventType.engineSwitched, {'engine': engine});
  
  factory PitchAnalysisEvent.qualityModeChanged(PitchQualityMode mode) =>
      PitchAnalysisEvent(PitchAnalysisEventType.qualityModeChanged, {'mode': mode});
  
  factory PitchAnalysisEvent.batchStarted(int totalSamples) =>
      PitchAnalysisEvent(PitchAnalysisEventType.batchStarted, {'totalSamples': totalSamples});
  
  factory PitchAnalysisEvent.batchProgress(double progress) =>
      PitchAnalysisEvent(PitchAnalysisEventType.batchProgress, {'progress': progress});
  
  factory PitchAnalysisEvent.batchCompleted(int totalFrames) =>
      PitchAnalysisEvent(PitchAnalysisEventType.batchCompleted, {'totalFrames': totalFrames});
  
  factory PitchAnalysisEvent.error(String message) =>
      PitchAnalysisEvent(PitchAnalysisEventType.error, {'message': message});
}

/// 이벤트 타입
enum PitchAnalysisEventType {
  initialized,
  engineAvailable,
  engineSwitched,
  qualityModeChanged,
  batchStarted,
  batchProgress,
  batchCompleted,
  error,
}