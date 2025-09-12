import 'dart:math' as math;
import 'dart:typed_data';

/// 오디오 전처리 클래스
/// 
/// HaneulTone v1 고도화 - 피치 분석 품질 향상을 위한 전처리 파이프라인
/// 
/// Features:
/// - 고역통과 필터 (HPF): 저주파 노이즈 제거
/// - 노치 필터: 전원 주파수 노이즈 제거 (50Hz/60Hz)
/// - RMS 기반 노이즈 바닥 추정
/// - 다운샘플링: 48kHz → 24kHz
/// - Biquad IIR 필터 구조 사용
class Preprocess {
  static const double _defaultSampleRate = 24000.0;
  
  /// 고역통과 필터 (Butterworth 2차)
  /// 
  /// [signal]: 입력 신호
  /// [sampleRate]: 샘플링 레이트
  /// [cutoffFreq]: 차단 주파수 (기본 80Hz)
  /// [returns]: 필터링된 신호
  static Float32List highPass(
    Float32List signal,
    int sampleRate, {
    double cutoffFreq = 80.0,
  }) {
    if (signal.isEmpty) return Float32List(0);
    
    final filter = _ButterworthHighPass(cutoffFreq, sampleRate.toDouble());
    final output = Float32List(signal.length);
    
    for (int i = 0; i < signal.length; i++) {
      output[i] = filter.process(signal[i]);
    }
    
    return output;
  }

  /// 노치 필터 (전원 주파수 제거)
  /// 
  /// [signal]: 입력 신호
  /// [sampleRate]: 샘플링 레이트
  /// [notchFreq]: 노치 주파수 (50Hz 또는 60Hz)
  /// [qFactor]: Q 팩터 (기본 30, 높을수록 좁은 대역)
  /// [returns]: 필터링된 신호
  static Float32List notch(
    Float32List signal,
    int sampleRate, {
    double notchFreq = 50.0,
    double qFactor = 30.0,
  }) {
    if (signal.isEmpty) return Float32List(0);
    
    final filter = _NotchFilter(notchFreq, qFactor, sampleRate.toDouble());
    final output = Float32List(signal.length);
    
    for (int i = 0; i < signal.length; i++) {
      output[i] = filter.process(signal[i]);
    }
    
    return output;
  }

  /// RMS 기반 노이즈 바닥 추정
  /// 
  /// [signal]: 입력 신호
  /// [windowSizeMs]: 분석 윈도우 크기 (밀리초, 기본 50ms)
  /// [percentile]: 백분위수 (기본 10%, 하위 10%를 노이즈로 간주)
  /// [returns]: 추정된 노이즈 바닥 (dBFS)
  static double estimateNoiseFloor(
    Float32List signal, {
    double windowSizeMs = 50.0,
    double percentile = 0.1,
  }) {
    if (signal.isEmpty) return -60.0; // 기본값
    
    const sampleRate = _defaultSampleRate;
    final windowSamples = (windowSizeMs * sampleRate / 1000.0).round();
    final hopSamples = windowSamples ~/ 2;
    
    if (windowSamples >= signal.length) {
      // 신호가 너무 짧으면 전체 RMS 계산
      final rms = _calculateRMS(signal, 0, signal.length);
      return _rmsToDbfs(rms);
    }
    
    // 슬라이딩 윈도우로 RMS 계산
    final rmsValues = <double>[];
    
    for (int start = 0; start + windowSamples <= signal.length; start += hopSamples) {
      final rms = _calculateRMS(signal, start, windowSamples);
      if (rms > 0) {
        rmsValues.add(rms);
      }
    }
    
    if (rmsValues.isEmpty) return -60.0;
    
    // 백분위수 계산
    rmsValues.sort();
    final index = (rmsValues.length * percentile).floor();
    final noiseRms = rmsValues[math.max(0, math.min(index, rmsValues.length - 1))];
    
    return _rmsToDbfs(noiseRms);
  }

  /// 적응형 게이트 (노이즈 바닥 기준)
  /// 
  /// [signal]: 입력 신호
  /// [noiseFloorDb]: 노이즈 바닥 (dBFS)
  /// [thresholdDb]: 게이트 임계값 (노이즈 바닥 대비, 기본 +6dB)
  /// [returns]: 게이팅된 신호
  static Float32List adaptiveGate(
    Float32List signal,
    double noiseFloorDb, {
    double thresholdDb = 6.0,
  }) {
    if (signal.isEmpty) return Float32List(0);
    
    final gateThreshold = _dbfsToLinear(noiseFloorDb + thresholdDb);
    final output = Float32List.fromList(signal);
    
    for (int i = 0; i < output.length; i++) {
      if (output[i].abs() < gateThreshold) {
        output[i] = 0.0;
      }
    }
    
    return output;
  }

  /// 48kHz → 24kHz 다운샘플링 (안티앨리어싱 필터 포함)
  /// 
  /// [signal]: 입력 신호 (48kHz)
  /// [returns]: 다운샘플링된 신호 (24kHz)
  static Float32List downsample48kTo24k(Float32List signal) {
    if (signal.isEmpty) return Float32List(0);
    
    // 안티앨리어싱 저역통과 필터 (12kHz 차단)
    final antiAlias = _ButterworthLowPass(12000.0, 48000.0);
    final filtered = Float32List(signal.length);
    
    for (int i = 0; i < signal.length; i++) {
      filtered[i] = antiAlias.process(signal[i]);
    }
    
    // 2:1 데시메이션
    final outputLength = signal.length ~/ 2;
    final output = Float32List(outputLength);
    
    for (int i = 0; i < outputLength; i++) {
      output[i] = filtered[i * 2];
    }
    
    return output;
  }

  /// 전체 전처리 파이프라인
  /// 
  /// [signal]: 입력 신호
  /// [inputSampleRate]: 입력 샘플링 레이트
  /// [returns]: 전처리된 신호와 메타데이터
  static PreprocessResult processAudio(
    Float32List signal,
    int inputSampleRate, {
    bool enableDownsampling = true,
    bool enableHPF = true,
    bool enableNotch = true,
    double hpfCutoff = 80.0,
    double notchFreq = 50.0,
  }) {
    if (signal.isEmpty) {
      return PreprocessResult(
        processedSignal: Float32List(0),
        outputSampleRate: inputSampleRate,
        noiseFloorDb: -60.0,
        processingSteps: [],
      );
    }
    
    Float32List currentSignal = Float32List.fromList(signal);
    int currentSampleRate = inputSampleRate;
    final processingSteps = <String>[];
    
    // 1. 다운샘플링 (48kHz → 24kHz)
    if (enableDownsampling && inputSampleRate == 48000) {
      currentSignal = downsample48kTo24k(currentSignal);
      currentSampleRate = 24000;
      processingSteps.add('Downsampling: 48kHz → 24kHz');
    }
    
    // 2. 고역통과 필터
    if (enableHPF) {
      currentSignal = highPass(currentSignal, currentSampleRate, cutoffFreq: hpfCutoff);
      processingSteps.add('High-pass filter: ${hpfCutoff}Hz');
    }
    
    // 3. 노치 필터
    if (enableNotch) {
      currentSignal = notch(currentSignal, currentSampleRate, notchFreq: notchFreq);
      processingSteps.add('Notch filter: ${notchFreq}Hz');
    }
    
    // 4. 노이즈 바닥 추정
    final noiseFloorDb = estimateNoiseFloor(currentSignal);
    processingSteps.add('Noise floor estimation: ${noiseFloorDb.toStringAsFixed(1)}dBFS');
    
    return PreprocessResult(
      processedSignal: currentSignal,
      outputSampleRate: currentSampleRate,
      noiseFloorDb: noiseFloorDb,
      processingSteps: processingSteps,
    );
  }

  // ========== 내부 헬퍼 함수들 ==========

  /// RMS 계산
  static double _calculateRMS(Float32List signal, int start, int length) {
    double sumSquared = 0.0;
    final end = math.min(start + length, signal.length);
    
    for (int i = start; i < end; i++) {
      sumSquared += signal[i] * signal[i];
    }
    
    return math.sqrt(sumSquared / (end - start));
  }

  /// RMS를 dBFS로 변환
  static double _rmsToDbfs(double rms) {
    if (rms <= 0) return -60.0; // 최소값
    return 20.0 * math.log(rms) / math.ln10;
  }

  /// dBFS를 선형 스케일로 변환
  static double _dbfsToLinear(double dbfs) {
    return math.pow(10.0, dbfs / 20.0).toDouble();
  }
}

/// 전처리 결과
class PreprocessResult {
  final Float32List processedSignal;
  final int outputSampleRate;
  final double noiseFloorDb;
  final List<String> processingSteps;

  const PreprocessResult({
    required this.processedSignal,
    required this.outputSampleRate,
    required this.noiseFloorDb,
    required this.processingSteps,
  });

  @override
  String toString() {
    return 'PreprocessResult('
           'samples=${processedSignal.length}, '
           'sampleRate=${outputSampleRate}Hz, '
           'noiseFloor=${noiseFloorDb.toStringAsFixed(1)}dBFS, '
           'steps=[${processingSteps.join(', ')}])';
  }
}

// ========== Biquad 필터 구현 ==========

/// Biquad 필터 기본 클래스
abstract class _BiquadFilter {
  double _x1 = 0.0, _x2 = 0.0;  // 입력 지연
  double _y1 = 0.0, _y2 = 0.0;  // 출력 지연
  
  // Biquad 계수 (a0는 항상 1로 정규화)
  late double b0, b1, b2, a1, a2;
  
  /// 한 샘플 처리
  double process(double input) {
    final output = b0 * input + b1 * _x1 + b2 * _x2 - a1 * _y1 - a2 * _y2;
    
    // 지연 라인 업데이트
    _x2 = _x1;
    _x1 = input;
    _y2 = _y1;
    _y1 = output;
    
    return output;
  }
  
  /// 필터 상태 초기화
  void reset() {
    _x1 = _x2 = _y1 = _y2 = 0.0;
  }
}

/// Butterworth 고역통과 필터 (2차)
class _ButterworthHighPass extends _BiquadFilter {
  _ButterworthHighPass(double cutoffFreq, double sampleRate) {
    final omega = 2.0 * math.pi * cutoffFreq / sampleRate;
    final sin = math.sin(omega);
    final cos = math.cos(omega);
    final alpha = sin / math.sqrt2; // Q = 1/sqrt(2) for Butterworth
    
    // High-pass coefficients
    b0 = (1.0 + cos) / 2.0;
    b1 = -(1.0 + cos);
    b2 = (1.0 + cos) / 2.0;
    a1 = -2.0 * cos;
    a2 = 1.0 - alpha;
    
    // a0로 정규화
    final a0 = 1.0 + alpha;
    b0 /= a0;
    b1 /= a0;
    b2 /= a0;
    a1 /= a0;
    a2 /= a0;
  }
}

/// Butterworth 저역통과 필터 (2차)
class _ButterworthLowPass extends _BiquadFilter {
  _ButterworthLowPass(double cutoffFreq, double sampleRate) {
    final omega = 2.0 * math.pi * cutoffFreq / sampleRate;
    final sin = math.sin(omega);
    final cos = math.cos(omega);
    final alpha = sin / math.sqrt2;
    
    // Low-pass coefficients
    b0 = (1.0 - cos) / 2.0;
    b1 = 1.0 - cos;
    b2 = (1.0 - cos) / 2.0;
    a1 = -2.0 * cos;
    a2 = 1.0 - alpha;
    
    // a0로 정규화
    final a0 = 1.0 + alpha;
    b0 /= a0;
    b1 /= a0;
    b2 /= a0;
    a1 /= a0;
    a2 /= a0;
  }
}

/// 노치 필터
class _NotchFilter extends _BiquadFilter {
  _NotchFilter(double notchFreq, double qFactor, double sampleRate) {
    final omega = 2.0 * math.pi * notchFreq / sampleRate;
    final sin = math.sin(omega);
    final cos = math.cos(omega);
    final alpha = sin / (2.0 * qFactor);
    
    // Notch coefficients
    b0 = 1.0;
    b1 = -2.0 * cos;
    b2 = 1.0;
    a1 = -2.0 * cos;
    a2 = 1.0 - alpha;
    
    // a0로 정규화
    final a0 = 1.0 + alpha;
    b0 /= a0;
    b1 /= a0;
    b2 /= a0;
    a1 /= a0;
    a2 /= a0;
  }
}