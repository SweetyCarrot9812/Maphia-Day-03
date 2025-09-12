import 'dart:math' as math;
import 'dart:typed_data';

/// 윈도우 함수 타입
enum WindowType {
  hann,
  hamming,
  blackman,
  rectangular
}

/// 오디오 DSP용 윈도우 함수 구현
/// 
/// HaneulTone v1 고도화 - 프리 앨리어싱과 스펙트럼 누출 최소화
class WindowFunctions {
  /// Hann 윈도우 (기본 권장)
  /// 부엽 억제와 메인로브 폭의 좋은 균형
  static Float32List hann(int length) {
    final window = Float32List(length);
    for (int i = 0; i < length; i++) {
      window[i] = 0.5 - 0.5 * math.cos(2 * math.pi * i / (length - 1));
    }
    return window;
  }

  /// Hamming 윈도우
  /// Hann보다 약간 더 나은 부엽 억제
  static Float32List hamming(int length) {
    final window = Float32List(length);
    const double alpha = 0.54;
    const double beta = 0.46;
    
    for (int i = 0; i < length; i++) {
      window[i] = alpha - beta * math.cos(2 * math.pi * i / (length - 1));
    }
    return window;
  }

  /// Blackman 윈도우
  /// 매우 좋은 부엽 억제, 약간 넓은 메인로브
  static Float32List blackman(int length) {
    final window = Float32List(length);
    const double a0 = 0.42;
    const double a1 = 0.5;
    const double a2 = 0.08;
    
    for (int i = 0; i < length; i++) {
      final double factor = 2 * math.pi * i / (length - 1);
      window[i] = a0 - a1 * math.cos(factor) + a2 * math.cos(2 * factor);
    }
    return window;
  }

  /// 직사각형 윈도우 (윈도우 없음과 동일)
  static Float32List rectangular(int length) {
    return Float32List.fromList(List.filled(length, 1.0));
  }

  /// 윈도우 함수 팩토리
  static Float32List create(WindowType type, int length) {
    switch (type) {
      case WindowType.hann:
        return hann(length);
      case WindowType.hamming:
        return hamming(length);
      case WindowType.blackman:
        return blackman(length);
      case WindowType.rectangular:
        return rectangular(length);
    }
  }

  /// 윈도우를 신호에 적용
  static void applyWindow(Float32List signal, Float32List window) {
    if (signal.length != window.length) {
      throw ArgumentError('신호와 윈도우의 길이가 일치하지 않습니다.');
    }
    
    for (int i = 0; i < signal.length; i++) {
      signal[i] *= window[i];
    }
  }

  /// 윈도우의 일관성 보정 팩터 계산
  /// 홉 크기와 윈도우 타입에 따른 에너지 보상
  static double coherentGain(WindowType type, int windowLength) {
    switch (type) {
      case WindowType.hann:
        return 2.0; // Hann 윈도우의 평균값은 0.5
      case WindowType.hamming:
        return 1.85; // Hamming 윈도우의 평균값 약 0.54
      case WindowType.blackman:
        return 2.38; // Blackman 윈도우의 평균값 약 0.42
      case WindowType.rectangular:
        return 1.0; // 보정 불필요
    }
  }

  /// COLA (Constant Overlap-Add) 조건 확인
  /// 홉 사이즈가 윈도우 타입과 호환되는지 검증
  static bool isColaCompliant(WindowType type, int windowLength, int hopSize) {
    // 일반적으로 홉 사이즈가 윈도우 길이의 1/2일 때 COLA 조건 만족
    final idealHopSize = windowLength / 2;
    final tolerance = windowLength * 0.1; // 10% 허용오차
    
    return (hopSize - idealHopSize).abs() <= tolerance;
  }

  /// 윈도우의 등가 노이즈 대역폭 (ENBW) 계산
  /// 스펙트럼 분해능 평가용
  static double equivalentNoiseBandwidth(WindowType type, int length) {
    final window = create(type, length);
    double sum1 = 0.0;
    double sum2 = 0.0;
    
    for (int i = 0; i < length; i++) {
      sum1 += window[i];
      sum2 += window[i] * window[i];
    }
    
    // ENBW = N * (sum of w[n]^2) / (sum of w[n])^2
    return length * sum2 / (sum1 * sum1);
  }
}