import 'dart:math';
import 'dart:typed_data';
import 'window_functions.dart';

/// 포먼트 분석기
/// 
/// LPC 기반 포먼트 추출 및 모음 안정성 분석
/// 
/// Features:
/// - LPC (Linear Predictive Coding) 분석
/// - F1, F2, F3 포먼트 추출
/// - 모음 안정성 지표 계산
/// - 실시간 포먼트 트래킹
class FormantAnalyzer {
  static const int _defaultOrder = 12; // LPC 차수
  static const int _formantCount = 3; // F1, F2, F3
  static const double _preEmphasisAlpha = 0.97;
  
  final int lpcOrder;
  final int sampleRate;
  
  /// 이전 샘플 (pre-emphasis용)
  double _prevSample = 0.0;

  FormantAnalyzer({
    required this.sampleRate,
    this.lpcOrder = _defaultOrder,
  });

  /// 오디오 프레임에서 포먼트 추출
  /// 
  /// [frame]: 입력 오디오 프레임 (1024 samples 권장)
  /// [returns]: FormantResult 또는 null (분석 실패시)
  FormantResult? analyzeFrame(Float32List frame) {
    if (frame.length < 512) {
      return null; // 너무 짧은 프레임
    }

    try {
      // 1. Pre-emphasis 필터 적용
      final preEmphasized = _applyPreEmphasis(frame);
      
      // 2. 윈도우 함수 적용
      final windowed = _applyWindow(preEmphasized);
      
      // 3. LPC 계수 계산
      final lpcCoeffs = _computeLPCCoefficients(windowed);
      
      if (lpcCoeffs == null) {
        return null;
      }
      
      // 4. 포먼트 주파수 추출
      final formants = _extractFormants(lpcCoeffs);
      
      if (formants.length < 2) {
        return null; // 최소 F1, F2는 필요
      }
      
      // 5. 모음 분류 및 안정성 계산
      final vowelClass = _classifyVowel(formants);
      final stability = _calculateStability(formants);
      
      return FormantResult(
        f1: formants.length > 0 ? formants[0] : 0.0,
        f2: formants.length > 1 ? formants[1] : 0.0,
        f3: formants.length > 2 ? formants[2] : 0.0,
        vowelClass: vowelClass,
        stability: stability,
        lpcError: lpcCoeffs.prediction_error,
        voicingProbability: _estimateVoicing(preEmphasized),
      );
    } catch (e) {
      print('FormantAnalyzer 오류: $e');
      return null;
    }
  }

  /// Pre-emphasis 필터 적용
  /// 
  /// H(z) = 1 - α*z^(-1), α = 0.97
  Float32List _applyPreEmphasis(Float32List frame) {
    final result = Float32List(frame.length);
    
    for (int i = 0; i < frame.length; i++) {
      final current = frame[i];
      result[i] = current - _preEmphasisAlpha * _prevSample;
      _prevSample = current;
    }
    
    return result;
  }

  /// Hamming 윈도우 적용
  Float32List _applyWindow(Float32List frame) {
    final window = WindowFunctions.hamming(frame.length);
    final result = Float32List(frame.length);
    
    for (int i = 0; i < frame.length; i++) {
      result[i] = frame[i] * window[i];
    }
    
    return result;
  }

  /// LPC 계수 계산 (Levinson-Durbin 알고리즘)
  _LPCResult? _computeLPCCoefficients(Float32List frame) {
    // 1. 자기상관함수 계산
    final autocorr = _computeAutocorrelation(frame, lpcOrder + 1);
    
    if (autocorr[0] <= 0.0) {
      return null; // 에너지가 없음
    }
    
    // 2. Levinson-Durbin 알고리즘으로 LPC 계수 계산
    final coeffs = Float32List(lpcOrder + 1);
    final reflection = Float32List(lpcOrder);
    
    coeffs[0] = 1.0;
    double error = autocorr[0];
    
    for (int i = 1; i <= lpcOrder; i++) {
      double sum = 0.0;
      for (int j = 1; j < i; j++) {
        sum += coeffs[j] * autocorr[i - j];
      }
      
      reflection[i - 1] = -(autocorr[i] + sum) / error;
      coeffs[i] = reflection[i - 1];
      
      for (int j = 1; j < i; j++) {
        coeffs[j] += reflection[i - 1] * coeffs[i - j];
      }
      
      error *= (1.0 - reflection[i - 1] * reflection[i - 1]);
      
      if (error <= 0.0) break;
    }
    
    return _LPCResult(
      coefficients: coeffs,
      reflection_coeffs: reflection,
      prediction_error: error,
    );
  }

  /// 자기상관함수 계산
  Float32List _computeAutocorrelation(Float32List frame, int maxLag) {
    final result = Float32List(maxLag);
    
    for (int lag = 0; lag < maxLag; lag++) {
      double sum = 0.0;
      for (int i = 0; i < frame.length - lag; i++) {
        sum += frame[i] * frame[i + lag];
      }
      result[lag] = sum;
    }
    
    return result;
  }

  /// LPC 계수에서 포먼트 주파수 추출
  List<double> _extractFormants(final _LPCResult lpc) {
    final coeffs = lpc.coefficients;
    final formants = <double>[];
    
    // LPC 계수를 복소수 다항식의 근으로 변환
    final roots = _findPolynomialRoots(coeffs);
    
    for (final root in roots) {
      // 안정적인 극점만 선택 (|z| < 1)
      if (root.magnitude < 1.0) {
        final angle = root.phase;
        if (angle > 0) { // 양의 주파수만
          final freq = angle * sampleRate / (2 * pi);
          
          // 포먼트 주파수 범위 필터링
          if (freq >= 200 && freq <= 4000) {
            formants.add(freq);
          }
        }
      }
    }
    
    // 주파수 순으로 정렬
    formants.sort();
    
    // 최대 3개 포먼트만 반환
    return formants.take(_formantCount).toList();
  }

  /// 다항식의 근 찾기 (단순화된 버전)
  List<Complex> _findPolynomialRoots(Float32List coeffs) {
    final roots = <Complex>[];
    
    // 2차 항까지만 해석적 해법 사용
    if (coeffs.length >= 3) {
      for (int i = 1; i < coeffs.length - 1; i += 2) {
        if (i + 1 < coeffs.length) {
          final a = 1.0;
          final b = coeffs[i];
          final c = coeffs[i + 1];
          
          final discriminant = b * b - 4 * a * c;
          
          if (discriminant >= 0) {
            // 실근
            final sqrt_d = sqrt(discriminant);
            roots.add(Complex((-b + sqrt_d) / (2 * a), 0));
            roots.add(Complex((-b - sqrt_d) / (2 * a), 0));
          } else {
            // 복소근
            final real = -b / (2 * a);
            final imag = sqrt(-discriminant) / (2 * a);
            roots.add(Complex(real, imag));
            roots.add(Complex(real, -imag));
          }
        }
      }
    }
    
    return roots;
  }

  /// 모음 분류
  VowelClass _classifyVowel(List<double> formants) {
    if (formants.length < 2) return VowelClass.unknown;
    
    final f1 = formants[0];
    final f2 = formants[1];
    
    // 한국어 모음 분류 (대략적)
    if (f1 < 400) {
      if (f2 > 2200) return VowelClass.i; // ㅣ
      if (f2 < 1200) return VowelClass.u; // ㅜ
      return VowelClass.high_mid; // 고모음
    } else if (f1 < 600) {
      if (f2 > 1800) return VowelClass.e; // ㅔ
      if (f2 < 1400) return VowelClass.o; // ㅓ
      return VowelClass.mid; // 중모음
    } else {
      if (f2 > 1600) return VowelClass.ae; // ㅐ
      return VowelClass.a; // ㅏ
    }
  }

  /// 모음 안정성 계산
  double _calculateStability(List<double> formants) {
    if (formants.length < 2) return 0.0;
    
    // F2/F1 비율의 안정성을 기준으로 계산
    final f1 = formants[0];
    final f2 = formants[1];
    
    if (f1 <= 0) return 0.0;
    
    final ratio = f2 / f1;
    
    // 이상적인 비율에서의 편차 계산
    double idealRatio = 2.5; // 일반적인 F2/F1 비율
    final deviation = (ratio - idealRatio).abs() / idealRatio;
    
    // 안정성 점수 (0~1)
    return (1.0 - deviation).clamp(0.0, 1.0);
  }

  /// 유성음 확률 추정
  double _estimateVoicing(Float32List frame) {
    // 간단한 에너지 기반 유성음 판단
    double energy = 0.0;
    for (final sample in frame) {
      energy += sample * sample;
    }
    energy /= frame.length;
    
    // 에너지를 유성음 확률로 변환
    final voicing = (log(energy + 1e-10) + 10) / 10;
    return voicing.clamp(0.0, 1.0);
  }
}

/// LPC 분석 결과
class _LPCResult {
  final Float32List coefficients;
  final Float32List reflection_coeffs;
  final double prediction_error;
  
  _LPCResult({
    required this.coefficients,
    required this.reflection_coeffs,
    required this.prediction_error,
  });
}

/// 포먼트 분석 결과
class FormantResult {
  /// 제1 포먼트 (F1) - Hz
  final double f1;
  
  /// 제2 포먼트 (F2) - Hz
  final double f2;
  
  /// 제3 포먼트 (F3) - Hz
  final double f3;
  
  /// 모음 분류
  final VowelClass vowelClass;
  
  /// 모음 안정성 (0.0-1.0)
  final double stability;
  
  /// LPC 예측 오차
  final double lpcError;
  
  /// 유성음 확률 (0.0-1.0)
  final double voicingProbability;

  const FormantResult({
    required this.f1,
    required this.f2,
    required this.f3,
    required this.vowelClass,
    required this.stability,
    required this.lpcError,
    required this.voicingProbability,
  });

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'f1': f1,
      'f2': f2,
      'f3': f3,
      'vowelClass': vowelClass.toString(),
      'stability': stability,
      'lpcError': lpcError,
      'voicingProbability': voicingProbability,
    };
  }

  /// JSON에서 역직렬화
  factory FormantResult.fromJson(Map<String, dynamic> json) {
    return FormantResult(
      f1: (json['f1'] as num).toDouble(),
      f2: (json['f2'] as num).toDouble(),
      f3: (json['f3'] as num).toDouble(),
      vowelClass: VowelClass.values.firstWhere(
        (v) => v.toString() == json['vowelClass'],
        orElse: () => VowelClass.unknown,
      ),
      stability: (json['stability'] as num).toDouble(),
      lpcError: (json['lpcError'] as num).toDouble(),
      voicingProbability: (json['voicingProbability'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'FormantResult(F1: ${f1.toStringAsFixed(1)}Hz, '
           'F2: ${f2.toStringAsFixed(1)}Hz, '
           'F3: ${f3.toStringAsFixed(1)}Hz, '
           'vowel: $vowelClass, '
           'stability: ${(stability * 100).toStringAsFixed(1)}%)';
  }
}

/// 모음 분류
enum VowelClass {
  unknown,
  a,    // ㅏ (low front)
  ae,   // ㅐ (low front)
  e,    // ㅔ (mid front)
  i,    // ㅣ (high front)
  o,    // ㅓ (mid back)
  u,    // ㅜ (high back)
  high_mid, // 고중모음
  mid,      // 중모음
}

/// 복소수 클래스 (간단한 구현)
class Complex {
  final double real;
  final double imaginary;
  
  const Complex(this.real, this.imaginary);
  
  double get magnitude => sqrt(real * real + imaginary * imaginary);
  double get phase => atan2(imaginary, real);
  
  @override
  String toString() => '${real.toStringAsFixed(3)} + ${imaginary.toStringAsFixed(3)}i';
}