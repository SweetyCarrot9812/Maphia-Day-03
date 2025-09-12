import 'dart:math' as math;
import 'dart:typed_data';
import 'pitch_frame.dart';
import 'pitch_engine.dart';
import 'window_functions.dart';

/// YIN 피치 추정 알고리즘 구현
/// 
/// HaneulTone v1 고도화 - 고품질 피치 추정을 위한 YIN 알고리즘
/// 
/// References:
/// - de Cheveigné, A. & Kawahara, H. (2002). YIN, a fundamental frequency estimator 
///   for speech and music. Journal of the Acoustical Society of America, 111, 1917-1930.
class YinEstimator implements PitchEngine {
  final double _threshold;
  final double _minFreq;
  final double _maxFreq;
  
  /// YIN 생성자
  /// 
  /// [threshold]: aperiodicity threshold (0.1-0.2 권장)
  /// [minFreq]: 최소 주파수 (Hz)
  /// [maxFreq]: 최대 주파수 (Hz)
  YinEstimator({
    double threshold = 0.15,
    double minFreq = 70.0,
    double maxFreq = 1000.0,
  }) : _threshold = threshold,
       _minFreq = minFreq,
       _maxFreq = maxFreq;

  @override
  String get engineName => 'YIN';

  @override
  double get minFreqHz => _minFreq;

  @override
  double get maxFreqHz => _maxFreq;

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
    final frames = <PitchFrame>[];
    final windowSize = frameSize;
    final hopLength = hopSize;
    final numFrames = ((pcm.length - windowSize) / hopLength).floor() + 1;

    // 주파수 범위에 따른 최대/최소 지연 계산
    final maxTau = (sampleRate / _minFreq).round();
    final minTau = (sampleRate / _maxFreq).round();

    for (int frameIdx = 0; frameIdx < numFrames; frameIdx++) {
      final startSample = frameIdx * hopLength;
      final endSample = math.min(startSample + windowSize, pcm.length);
      
      if (endSample - startSample < windowSize) break;

      // 프레임 추출
      final frame = Float32List.sublistView(pcm, startSample, endSample);
      
      // YIN 알고리즘 적용
      final yinResult = _computeYin(frame, sampleRate, minTau, maxTau);
      
      final timeMs = (startSample / sampleRate) * 1000.0;
      final pitchFrame = PitchFrame(
        timeMs: timeMs,
        f0Hz: yinResult.f0Hz,
        cents: PitchFrame.hzToCents(yinResult.f0Hz),
        voicingProb: yinResult.voicingProb,
        confidence: yinResult.confidence,
      );

      frames.add(pitchFrame);
    }

    return frames;
  }

  /// YIN 알고리즘 핵심 계산
  _YinResult _computeYin(Float32List frame, int sampleRate, int minTau, int maxTau) {
    final frameLength = frame.length;
    final halfLength = frameLength ~/ 2;
    
    // Step 1: 자기상관 함수 계산 (차분 함수로 변환)
    final differenceFunction = Float32List(halfLength);
    _computeDifferenceFunction(frame, differenceFunction);

    // Step 2: 누적 평균 정규화 차분 함수 (CMND) 계산
    final cumulativeMean = Float32List(halfLength);
    _computeCumulativeMeanNormalizedDifference(differenceFunction, cumulativeMean);

    // Step 3: 절대 임계치를 이용한 주기 추정
    final bestTau = _findBestPeriod(cumulativeMean, minTau, maxTau, _threshold);
    
    if (bestTau == -1) {
      // 주기를 찾지 못함 (무성음 또는 잡음)
      return _YinResult(
        f0Hz: 0.0,
        voicingProb: 0.0,
        confidence: 0.0,
      );
    }

    // Step 4: 파라볼라 보간을 통한 정밀 주기 추정
    final preciseTau = _parabolicInterpolation(cumulativeMean, bestTau);
    final f0Hz = sampleRate / preciseTau;
    
    // aperiodicity → voicing probability 변환
    final aperiodicity = cumulativeMean[bestTau];
    final voicingProb = 1.0 - math.min(aperiodicity, 1.0);
    
    // 신뢰도: voicing probability와 주파수 유효성을 고려
    final confidence = _computeConfidence(voicingProb, f0Hz);

    return _YinResult(
      f0Hz: f0Hz,
      voicingProb: voicingProb,
      confidence: confidence,
    );
  }

  /// Step 1: 차분 함수 계산
  /// d_t(τ) = Σ[x_j - x_{j+τ}]²
  void _computeDifferenceFunction(Float32List frame, Float32List differenceFunction) {
    final frameLength = frame.length;
    
    for (int tau = 0; tau < differenceFunction.length; tau++) {
      double sum = 0.0;
      for (int j = 0; j < frameLength - tau; j++) {
        final diff = frame[j] - frame[j + tau];
        sum += diff * diff;
      }
      differenceFunction[tau] = sum;
    }
  }

  /// Step 2: 누적 평균 정규화 차분 함수 계산
  /// d'_t(τ) = d_t(τ) / [(1/τ) * Σ_{j=1}^τ d_t(j)]  for τ ≥ 1
  void _computeCumulativeMeanNormalizedDifference(
    Float32List differenceFunction,
    Float32List cumulativeMean,
  ) {
    cumulativeMean[0] = 1.0; // 정의에 의해 τ=0일 때는 1
    
    double cumulativeSum = differenceFunction[0];
    
    for (int tau = 1; tau < cumulativeMean.length; tau++) {
      cumulativeSum += differenceFunction[tau];
      final mean = cumulativeSum / tau;
      
      if (mean > 0) {
        cumulativeMean[tau] = differenceFunction[tau] / mean;
      } else {
        cumulativeMean[tau] = 1.0;
      }
    }
  }

  /// Step 3: 절대 임계치를 이용한 최적 주기 찾기
  int _findBestPeriod(Float32List cumulativeMean, int minTau, int maxTau, double threshold) {
    // 유효한 τ 범위 내에서 검색
    final searchStart = math.max(1, minTau);
    final searchEnd = math.min(cumulativeMean.length - 1, maxTau);
    
    if (searchStart >= searchEnd) return -1;

    // 첫 번째 최소값을 찾되, 임계값 이하인 경우만
    for (int tau = searchStart; tau < searchEnd; tau++) {
      if (cumulativeMean[tau] < threshold) {
        // 지역 최소값인지 확인
        if (tau == searchStart || 
            (cumulativeMean[tau] < cumulativeMean[tau - 1] && 
             cumulativeMean[tau] < cumulativeMean[tau + 1])) {
          return tau;
        }
      }
    }

    // 임계값 이하의 값을 찾지 못한 경우, 전체 범위에서 전역 최소값 반환
    int bestTau = searchStart;
    double minValue = cumulativeMean[searchStart];
    
    for (int tau = searchStart + 1; tau < searchEnd; tau++) {
      if (cumulativeMean[tau] < minValue) {
        minValue = cumulativeMean[tau];
        bestTau = tau;
      }
    }
    
    // 전역 최소값도 임계값의 2배를 넘으면 주기 없음으로 판단
    return minValue < threshold * 2.0 ? bestTau : -1;
  }

  /// Step 4: 파라볼라 보간을 통한 정밀 주기 추정
  double _parabolicInterpolation(Float32List cumulativeMean, int bestTau) {
    if (bestTau <= 0 || bestTau >= cumulativeMean.length - 1) {
      return bestTau.toDouble();
    }

    final y1 = cumulativeMean[bestTau - 1];
    final y2 = cumulativeMean[bestTau];
    final y3 = cumulativeMean[bestTau + 1];

    // 파라볼라 보간: x = -b/2a where y = ax² + bx + c
    final a = 0.5 * (y1 - 2 * y2 + y3);
    final b = 0.5 * (y3 - y1);

    if (a.abs() < 1e-10) return bestTau.toDouble(); // 거의 선형인 경우

    final offset = -b / (2 * a);
    return bestTau + math.max(-0.5, math.min(0.5, offset)); // ±0.5 범위로 제한
  }

  /// 신뢰도 계산
  double _computeConfidence(double voicingProb, double f0Hz) {
    // 주파수 유효성 체크
    if (f0Hz < _minFreq || f0Hz > _maxFreq) return 0.0;
    
    // voicing probability와 주파수 안정성을 종합한 신뢰도
    final freqConfidence = _computeFrequencyConfidence(f0Hz);
    return voicingProb * freqConfidence;
  }

  /// 주파수 기반 신뢰도 계산
  double _computeFrequencyConfidence(double f0Hz) {
    // 음성 주파수 범위에서 가중치 적용
    if (f0Hz >= 80 && f0Hz <= 800) {
      return 1.0; // 최적 범위
    } else if (f0Hz >= 70 && f0Hz <= 1000) {
      // 경계 영역에서 점진적 감소
      final distanceFromOptimal = math.min(
        (f0Hz - 80).abs(),
        (f0Hz - 800).abs(),
      );
      return math.max(0.3, 1.0 - distanceFromOptimal / 200.0);
    } else {
      return 0.1; // 범위 밖
    }
  }
}

/// YIN 알고리즘 계산 결과
class _YinResult {
  final double f0Hz;
  final double voicingProb;
  final double confidence;

  const _YinResult({
    required this.f0Hz,
    required this.voicingProb,
    required this.confidence,
  });
}