import 'dart:math' as math;

/// 단일 프레임의 피치 정보를 담는 데이터 클래스
/// 
/// HaneulTone v1 고도화 - 피치 분석 결과의 기본 단위
class PitchFrame {
  /// 프레임 시간 위치 (밀리초)
  final double timeMs;
  
  /// 추정된 기본 주파수 (Hz)
  /// 0.0이면 무성음/침묵으로 간주
  final double f0Hz;
  
  /// A4=440Hz 기준 센트 값
  /// f0Hz가 0이면 이 값도 0
  final double cents;
  
  /// 유성음 확률 (0.0 ~ 1.0)
  /// YIN aperiodicity 기반으로 계산
  final double voicingProb;
  
  /// 피치 추정 신뢰도 (0.0 ~ 1.0)
  /// FFT+YIN 일치도 기반으로 계산 (차이 ≤35c면 High, >35c면 Low)
  final double confidence;

  const PitchFrame({
    required this.timeMs,
    required this.f0Hz,
    required this.cents,
    required this.voicingProb,
    required this.confidence,
  });

  /// Hz를 A4=440Hz 기준 센트로 변환
  static double hzToCents(double hz) {
    if (hz <= 0) return 0.0;
    const double a4Hz = 440.0;
    return 1200.0 * math.log(hz / a4Hz) / math.ln2;
  }

  /// 센트를 Hz로 변환
  static double centsToHz(double cents) {
    if (cents == 0.0) return 0.0;
    const double a4Hz = 440.0;
    return a4Hz * math.pow(2, cents / 1200.0);
  }

  /// 유성음인지 판단 (임계치 기반)
  bool get isVoiced => voicingProb > 0.5 && f0Hz > 0;

  /// 고신뢰도 프레임인지 판단
  bool get isHighConfidence => confidence > 0.7;

  @override
  String toString() {
    return 'PitchFrame(${timeMs.toStringAsFixed(1)}ms, '
           '${f0Hz.toStringAsFixed(1)}Hz, '
           '${cents.toStringAsFixed(1)}c, '
           'voicing=${voicingProb.toStringAsFixed(2)}, '
           'conf=${confidence.toStringAsFixed(2)})';
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'timeMs': timeMs,
      'f0Hz': f0Hz,
      'cents': cents,
      'voicingProb': voicingProb,
      'confidence': confidence,
    };
  }

  /// JSON에서 역직렬화
  factory PitchFrame.fromJson(Map<String, dynamic> json) {
    return PitchFrame(
      timeMs: (json['timeMs'] as num).toDouble(),
      f0Hz: (json['f0Hz'] as num).toDouble(),
      cents: (json['cents'] as num).toDouble(),
      voicingProb: (json['voicingProb'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  /// 두 PitchFrame의 센트 차이 (절댓값)
  double centsDifference(PitchFrame other) {
    if (!isVoiced || !other.isVoiced) return double.infinity;
    return (cents - other.cents).abs();
  }

  /// 피치 프레임 간 가중 평균 계산
  static PitchFrame weightedAverage(List<PitchFrame> frames, List<double> weights) {
    if (frames.isEmpty || weights.isEmpty || frames.length != weights.length) {
      throw ArgumentError('frames와 weights의 길이가 일치하지 않습니다.');
    }

    double totalWeight = weights.reduce((a, b) => a + b);
    if (totalWeight == 0) return frames.first;

    double weightedTimeMs = 0.0;
    double weightedF0Hz = 0.0;
    double weightedCents = 0.0;
    double weightedVoicingProb = 0.0;
    double weightedConfidence = 0.0;

    for (int i = 0; i < frames.length; i++) {
      final weight = weights[i] / totalWeight;
      final frame = frames[i];
      
      weightedTimeMs += frame.timeMs * weight;
      weightedF0Hz += frame.f0Hz * weight;
      weightedCents += frame.cents * weight;
      weightedVoicingProb += frame.voicingProb * weight;
      weightedConfidence += frame.confidence * weight;
    }

    return PitchFrame(
      timeMs: weightedTimeMs,
      f0Hz: weightedF0Hz,
      cents: weightedCents,
      voicingProb: weightedVoicingProb,
      confidence: weightedConfidence,
    );
  }
}