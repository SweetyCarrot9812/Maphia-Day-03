import 'dart:typed_data';
import 'dart:math' as math;
import 'pitch_frame.dart';
import 'pitch_engine.dart';
import 'yin_estimator.dart';
import 'fft_estimator.dart';
import 'window_functions.dart';

/// 하이브리드 피치 추정 엔진
/// 
/// HaneulTone v1 고도화 - FFT와 YIN을 결합한 고정밀 피치 추정
/// 
/// Features:
/// - FFT + YIN 결과의 지능형 융합
/// - 신뢰도 기반 가중 평균
/// - 센트 차이 ≤35c면 High confidence, >35c면 Low confidence
/// - Median filtering을 통한 시간적 평활화
/// - 적응형 보정 알고리즘
class HybridPitchEngine implements PitchEngine {
  final YinEstimator _yin;
  final FftEstimator _fft;
  final double _consistencyThreshold; // 센트 단위
  final int _medianFilterSize;
  late final double _yinWeight;
  late final double _fftWeight;
  
  /// 하이브리드 엔진 생성자
  /// 
  /// [consistencyThreshold]: FFT-YIN 일치 임계값 (센트, 기본 35c)
  /// [medianFilterSize]: 중간값 필터 크기 (기본 5)
  /// [yinWeight]: YIN 가중치 (기본 0.6)
  /// [fftWeight]: FFT 가중치 (기본 0.4)
  HybridPitchEngine({
    double minFreq = 70.0,
    double maxFreq = 1000.0,
    double yinThreshold = 0.15,
    double consistencyThreshold = 35.0,
    int medianFilterSize = 5,
    double yinWeight = 0.6,
    double fftWeight = 0.4,
  }) : _yin = YinEstimator(
         threshold: yinThreshold,
         minFreq: minFreq,
         maxFreq: maxFreq,
       ),
       _fft = FftEstimator(
         minFreq: minFreq,
         maxFreq: maxFreq,
       ),
       _consistencyThreshold = consistencyThreshold,
       _medianFilterSize = medianFilterSize,
       _yinWeight = yinWeight,
       _fftWeight = fftWeight {
    // 가중치 정규화
    final totalWeight = yinWeight + fftWeight;
    if (totalWeight > 0) {
      _yinWeight = yinWeight / totalWeight;
      _fftWeight = fftWeight / totalWeight;
    }
  }

  @override
  String get engineName => 'Hybrid(YIN+FFT)';

  @override
  double get minFreqHz => _yin.minFreqHz;

  @override
  double get maxFreqHz => _yin.maxFreqHz;

  @override
  int get preferredSampleRate => 24000;

  @override
  int get frameSize => (preferredSampleRate * 0.04).round();

  @override
  int get hopSize => (preferredSampleRate * 0.01).round();

  @override
  WindowType get windowType => WindowType.hann;

  @override
  Future<List<PitchFrame>> estimate(Float32List pcm, int sampleRate) async {
    // 병렬로 YIN과 FFT 실행
    final futures = await Future.wait([
      _yin.estimate(pcm, sampleRate),
      _fft.estimate(pcm, sampleRate),
    ]);

    final yinFrames = futures[0];
    final fftFrames = futures[1];

    // 프레임 수 정렬 (짧은 쪽에 맞춤)
    final minFrames = math.min(yinFrames.length, fftFrames.length);
    if (minFrames == 0) return [];

    // 하이브리드 융합
    final hybridFrames = <PitchFrame>[];
    for (int i = 0; i < minFrames; i++) {
      final yinFrame = yinFrames[i];
      final fftFrame = fftFrames[i];
      
      final fusedFrame = _fuseFrames(yinFrame, fftFrame);
      hybridFrames.add(fusedFrame);
    }

    // 시간적 평활화 (Median filtering)
    final smoothedFrames = _applyMedianFilter(hybridFrames);

    return smoothedFrames;
  }

  /// YIN과 FFT 프레임을 융합
  PitchFrame _fuseFrames(PitchFrame yinFrame, PitchFrame fftFrame) {
    // 시간은 YIN 기준 (더 정확한 시간 정렬)
    final timeMs = yinFrame.timeMs;

    // 둘 다 무성음이면 무성음으로 처리
    if (!yinFrame.isVoiced && !fftFrame.isVoiced) {
      return PitchFrame(
        timeMs: timeMs,
        f0Hz: 0.0,
        cents: 0.0,
        voicingProb: 0.0,
        confidence: 0.0,
      );
    }

    // 하나만 유성음이면 해당 결과 사용 (신뢰도 조정)
    if (yinFrame.isVoiced && !fftFrame.isVoiced) {
      return _adjustSingleEngineFrame(yinFrame, 0.8); // YIN 단독 사용 시 신뢰도 약간 감소
    }
    
    if (!yinFrame.isVoiced && fftFrame.isVoiced) {
      return _adjustSingleEngineFrame(fftFrame, 0.7); // FFT 단독 사용 시 신뢰도 더 감소
    }

    // 둘 다 유성음인 경우 - 정교한 융합 실행
    return _fuseVoicedFrames(yinFrame, fftFrame, timeMs);
  }

  /// 단일 엔진 프레임의 신뢰도 조정
  PitchFrame _adjustSingleEngineFrame(PitchFrame frame, double confidenceMultiplier) {
    return PitchFrame(
      timeMs: frame.timeMs,
      f0Hz: frame.f0Hz,
      cents: frame.cents,
      voicingProb: frame.voicingProb,
      confidence: frame.confidence * confidenceMultiplier,
    );
  }

  /// 두 유성음 프레임을 융합
  PitchFrame _fuseVoicedFrames(PitchFrame yinFrame, PitchFrame fftFrame, double timeMs) {
    // 센트 차이 계산
    final centsDiff = (yinFrame.cents - fftFrame.cents).abs();
    
    // 일치도 기반 신뢰도 계산
    final isConsistent = centsDiff <= _consistencyThreshold;
    final consistencyFactor = isConsistent ? 1.0 : math.exp(-centsDiff / _consistencyThreshold);
    
    // 가중 평균 계산
    final totalWeight = _yinWeight * yinFrame.confidence + _fftWeight * fftFrame.confidence;
    
    if (totalWeight == 0) {
      // 둘 다 신뢰도가 0인 경우
      return PitchFrame(
        timeMs: timeMs,
        f0Hz: 0.0,
        cents: 0.0,
        voicingProb: 0.0,
        confidence: 0.0,
      );
    }

    // 신뢰도 기반 가중치 재계산
    final adjustedYinWeight = (_yinWeight * yinFrame.confidence) / totalWeight;
    final adjustedFftWeight = (_fftWeight * fftFrame.confidence) / totalWeight;

    // 가중 평균 계산
    final fusedF0Hz = adjustedYinWeight * yinFrame.f0Hz + adjustedFftWeight * fftFrame.f0Hz;
    final fusedCents = adjustedYinWeight * yinFrame.cents + adjustedFftWeight * fftFrame.cents;
    final fusedVoicingProb = adjustedYinWeight * yinFrame.voicingProb + adjustedFftWeight * fftFrame.voicingProb;
    
    // 융합된 신뢰도 계산
    final baseConfidence = adjustedYinWeight * yinFrame.confidence + adjustedFftWeight * fftFrame.confidence;
    final fusedConfidence = baseConfidence * consistencyFactor;

    // 추가 검증: 주파수 유효성
    final isValidFreq = fusedF0Hz >= minFreqHz && fusedF0Hz <= maxFreqHz;
    final finalConfidence = isValidFreq ? fusedConfidence : 0.0;

    return PitchFrame(
      timeMs: timeMs,
      f0Hz: fusedF0Hz,
      cents: fusedCents,
      voicingProb: fusedVoicingProb,
      confidence: finalConfidence,
    );
  }

  /// 중간값 필터를 통한 시간적 평활화
  List<PitchFrame> _applyMedianFilter(List<PitchFrame> frames) {
    if (frames.length <= _medianFilterSize) {
      return frames; // 필터 크기보다 작으면 그대로 반환
    }

    final smoothedFrames = <PitchFrame>[];
    final halfSize = _medianFilterSize ~/ 2;

    for (int i = 0; i < frames.length; i++) {
      final startIdx = math.max(0, i - halfSize);
      final endIdx = math.min(frames.length - 1, i + halfSize);
      
      // 윈도우 내 유성음 프레임만 수집
      final voicedFramesInWindow = <PitchFrame>[];
      for (int j = startIdx; j <= endIdx; j++) {
        if (frames[j].isVoiced) {
          voicedFramesInWindow.add(frames[j]);
        }
      }

      PitchFrame smoothedFrame;
      
      if (voicedFramesInWindow.isEmpty) {
        // 윈도우 내 유성음이 없으면 원본 사용
        smoothedFrame = frames[i];
      } else if (voicedFramesInWindow.length == 1) {
        // 유성음이 하나뿐이면 원본과 혼합
        smoothedFrame = _blendFrames(frames[i], voicedFramesInWindow.first, 0.7);
      } else {
        // 중간값 필터 적용
        smoothedFrame = _computeMedianFrame(frames[i], voicedFramesInWindow);
      }

      smoothedFrames.add(smoothedFrame);
    }

    return smoothedFrames;
  }

  /// 중간값 프레임 계산
  PitchFrame _computeMedianFrame(PitchFrame originalFrame, List<PitchFrame> voicedFrames) {
    // 주파수들을 정렬하여 중간값 찾기
    final frequencies = voicedFrames.map((f) => f.f0Hz).toList()..sort();
    final cents = voicedFrames.map((f) => f.cents).toList()..sort();
    final voicingProbs = voicedFrames.map((f) => f.voicingProb).toList()..sort();
    final confidences = voicedFrames.map((f) => f.confidence).toList()..sort();

    final n = voicedFrames.length;
    final midIndex = n ~/ 2;

    double medianF0Hz, medianCents, medianVoicingProb, medianConfidence;

    if (n % 2 == 1) {
      // 홀수 개수: 중간값
      medianF0Hz = frequencies[midIndex];
      medianCents = cents[midIndex];
      medianVoicingProb = voicingProbs[midIndex];
      medianConfidence = confidences[midIndex];
    } else {
      // 짝수 개수: 중간 두 값의 평균
      medianF0Hz = (frequencies[midIndex - 1] + frequencies[midIndex]) / 2;
      medianCents = (cents[midIndex - 1] + cents[midIndex]) / 2;
      medianVoicingProb = (voicingProbs[midIndex - 1] + voicingProbs[midIndex]) / 2;
      medianConfidence = (confidences[midIndex - 1] + confidences[midIndex]) / 2;
    }

    return PitchFrame(
      timeMs: originalFrame.timeMs,
      f0Hz: medianF0Hz,
      cents: medianCents,
      voicingProb: medianVoicingProb,
      confidence: medianConfidence,
    );
  }

  /// 두 프레임을 가중 혼합
  PitchFrame _blendFrames(PitchFrame frame1, PitchFrame frame2, double frame1Weight) {
    final frame2Weight = 1.0 - frame1Weight;
    
    return PitchFrame(
      timeMs: frame1.timeMs,
      f0Hz: frame1Weight * frame1.f0Hz + frame2Weight * frame2.f0Hz,
      cents: frame1Weight * frame1.cents + frame2Weight * frame2.cents,
      voicingProb: frame1Weight * frame1.voicingProb + frame2Weight * frame2.voicingProb,
      confidence: frame1Weight * frame1.confidence + frame2Weight * frame2.confidence,
    );
  }

  /// 엔진 통계 정보
  Map<String, dynamic> getEngineStats(List<PitchFrame> frames) {
    if (frames.isEmpty) {
      return {
        'totalFrames': 0,
        'voicedFrames': 0,
        'voicedRatio': 0.0,
        'avgConfidence': 0.0,
        'highConfidenceRatio': 0.0,
      };
    }

    final voicedFrames = frames.where((f) => f.isVoiced).toList();
    final highConfidenceFrames = frames.where((f) => f.isHighConfidence).toList();
    
    double avgConfidence = 0.0;
    if (voicedFrames.isNotEmpty) {
      avgConfidence = voicedFrames.map((f) => f.confidence).reduce((a, b) => a + b) / voicedFrames.length;
    }

    return {
      'totalFrames': frames.length,
      'voicedFrames': voicedFrames.length,
      'voicedRatio': voicedFrames.length / frames.length,
      'avgConfidence': avgConfidence,
      'highConfidenceRatio': highConfidenceFrames.length / frames.length,
      'engineName': engineName,
    };
  }
}
