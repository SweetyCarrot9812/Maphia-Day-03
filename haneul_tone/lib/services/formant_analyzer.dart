import 'dart:math' as math;
import 'dart:typed_data';

/// 포먼트 정보
class Formant {
  final double frequency; // Hz
  final double bandwidth; // Hz
  final double amplitude; // dB
  final double quality; // Q factor
  
  Formant({
    required this.frequency,
    required this.bandwidth,
    required this.amplitude,
    required this.quality,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'frequency': frequency,
      'bandwidth': bandwidth,
      'amplitude': amplitude,
      'quality': quality,
    };
  }
}

/// 포먼트 분석 결과
class FormantAnalysis {
  final List<Formant> formants;
  final VowelClassification vowelType;
  final ResonanceQuality resonanceQuality;
  final double formantClarity; // 0-1
  final double balance; // F1/F2 비율 기반
  final String feedback;
  final List<String> recommendations;
  final Map<String, dynamic> detailedMetrics;
  
  // 음색 특성 맵
  Map<String, double> get tonalCharacteristics => {
    'brightness': _calculateBrightness(),
    'warmth': _calculateWarmth(),
    'clarity': formantClarity,
    'richness': _calculateRichness(),
  };
  
  // 밝기 계산
  double _calculateBrightness() {
    if (formants.length < 2) return 0.5;
    final f2 = formants[1].frequency;
    return (f2 - 800) / (3500 - 800); // F2 기반 밝기
  }
  
  // 따뜻함 계산
  double _calculateWarmth() {
    if (formants.isEmpty) return 0.5;
    final f1 = formants[0].frequency;
    return (f1 - 200) / (1000 - 200); // F1 기반 따뜻함
  }
  
  // 풍부함 계산
  double _calculateRichness() {
    if (formants.length < 3) return 0.5;
    final f3 = formants[2].frequency;
    return (f3 - 1500) / (5000 - 1500); // F3 기반 풍부함
  }
  
  FormantAnalysis({
    required this.formants,
    required this.vowelType,
    required this.resonanceQuality,
    required this.formantClarity,
    required this.balance,
    required this.feedback,
    required this.recommendations,
    required this.detailedMetrics,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'formants': formants.map((f) => f.toMap()).toList(),
      'vowel_type': vowelType.toString(),
      'resonance_quality': resonanceQuality.toString(),
      'formant_clarity': formantClarity,
      'balance': balance,
      'feedback': feedback,
      'recommendations': recommendations,
      'detailed_metrics': detailedMetrics,
    };
  }
  
  Map<String, dynamic> toJson() => toMap();
}

/// 모음 분류
enum VowelClassification {
  a,  // 아
  e,  // 에
  i,  // 이
  o,  // 오
  u,  // 우
  mixed,  // 혼합
  unclear,  // 불명확
}

/// 공명 품질
enum ResonanceQuality {
  excellent,    // 탁월한 공명
  good,         // 양호한 공명
  acceptable,   // 보통 공명
  weak,         // 약한 공명
  poor,         // 불량한 공명
}

// ResonanceQuality 확장 메서드
extension ResonanceQualityOperations on ResonanceQuality {
  // + 연산자 구현 (숫자값으로 변환해서 연산)
  double operator +(Object other) {
    final thisValue = _toNumericValue();
    if (other is ResonanceQuality) {
      return thisValue + other._toNumericValue();
    } else if (other is num) {
      return thisValue + other.toDouble();
    }
    throw ArgumentError('Cannot add $other to ResonanceQuality');
  }
  
  // 숫자값 변환
  double _toNumericValue() {
    switch (this) {
      case ResonanceQuality.excellent:
        return 100.0;
      case ResonanceQuality.good:
        return 80.0;
      case ResonanceQuality.acceptable:
        return 60.0;
      case ResonanceQuality.weak:
        return 40.0;
      case ResonanceQuality.poor:
        return 20.0;
    }
  }
}

/// 스펙트럼 포인트
class SpectralPoint {
  final double frequency;
  final double magnitude;
  
  SpectralPoint(this.frequency, this.magnitude);
}

// FormantAnalysisResult alias for compatibility
typedef FormantAnalysisResult = FormantAnalysis;

/// 포먼트 분석을 통한 음색/공명 분석 시스템
/// 성도의 공명 주파수(F1, F2, F3)를 분석하여 음색 특성과 발음 품질을 평가
class FormantAnalyzer {
  static const int sampleRate = 44100;
  static const int windowSize = 1024;
  static const int hopSize = 512;
  static const double preEmphasisCoeff = 0.97;
  static const int maxFormants = 5;
  static const double minF1 = 200.0; // Hz
  static const double maxF1 = 1000.0; // Hz
  static const double minF2 = 800.0; // Hz
  static const double maxF2 = 3500.0; // Hz
  static const double minF3 = 1500.0; // Hz
  static const double maxF3 = 5000.0; // Hz
  
  /// 포먼트 분석 수행
  Future<FormantAnalysis> analyzeFormants(Float64List audioSamples) async {
    if (audioSamples.isEmpty) {
      return _createEmptyAnalysis();
    }
    
    // 전처리: 프리엠퍼시스 적용
    final preprocessed = _applyPreEmphasis(audioSamples);
    
    // 윈도우별 분석
    final formantFrames = <List<Formant>>[];
    
    for (int i = 0; i + windowSize <= preprocessed.length; i += hopSize) {
      final frame = preprocessed.sublist(i, i + windowSize);
      final formants = await _analyzeFrame(frame);
      if (formants.isNotEmpty) {
        formantFrames.add(formants);
      }
    }
    
    if (formantFrames.isEmpty) {
      return _createEmptyAnalysis();
    }
    
    // 평균 포먼트 계산
    final avgFormants = _calculateAverageFormants(formantFrames);
    
    // 모음 분류
    final vowelType = _classifyVowel(avgFormants);
    
    // 공명 품질 평가
    final resonanceQuality = _evaluateResonanceQuality(avgFormants, formantFrames);
    
    // 포먼트 명확도 계산
    final formantClarity = _calculateFormantClarity(avgFormants, formantFrames);
    
    // 균형 계산 (F1/F2 비율)
    final balance = _calculateBalance(avgFormants);
    
    // 상세 메트릭스
    final detailedMetrics = _calculateDetailedMetrics(avgFormants, formantFrames);
    
    // 피드백 생성
    final feedback = _generateFeedback(vowelType, resonanceQuality, formantClarity, balance);
    final recommendations = _generateRecommendations(vowelType, resonanceQuality, formantClarity, balance);
    
    return FormantAnalysis(
      formants: avgFormants,
      vowelType: vowelType,
      resonanceQuality: resonanceQuality,
      formantClarity: formantClarity,
      balance: balance,
      feedback: feedback,
      recommendations: recommendations,
      detailedMetrics: detailedMetrics,
    );
  }
  
  /// 프리엠퍼시스 필터 적용
  Float64List _applyPreEmphasis(Float64List input) {
    final output = Float64List(input.length);
    output[0] = input[0];
    
    for (int i = 1; i < input.length; i++) {
      output[i] = input[i] - preEmphasisCoeff * input[i - 1];
    }
    
    return output;
  }
  
  /// 프레임별 포먼트 분석
  Future<List<Formant>> _analyzeFrame(List<double> frame) async {
    // 윈도우 함수 적용 (해밍 윈도우)
    final windowed = _applyHammingWindow(frame);
    
    // FFT 계산 (간소화된 버전)
    final spectrum = _calculateSpectrum(windowed);
    
    // 포먼트 피크 찾기
    final formants = _findFormantPeaks(spectrum);
    
    return formants;
  }
  
  /// 해밍 윈도우 적용
  List<double> _applyHammingWindow(List<double> input) {
    final windowed = <double>[];
    for (int i = 0; i < input.length; i++) {
      final windowValue = 0.54 - 0.46 * math.cos(2 * math.pi * i / (input.length - 1));
      windowed.add(input[i] * windowValue);
    }
    return windowed;
  }
  
  /// 스펙트럼 계산 (간소화된 FFT)
  List<SpectralPoint> _calculateSpectrum(List<double> input) {
    final spectrum = <SpectralPoint>[];
    final n = input.length;
    
    // 간소화된 DFT (실제로는 FFT 라이브러리 사용 권장)
    for (int k = 0; k < n ~/ 2; k++) {
      double real = 0.0;
      double imag = 0.0;
      
      for (int i = 0; i < n; i++) {
        final angle = -2 * math.pi * k * i / n;
        real += input[i] * math.cos(angle);
        imag += input[i] * math.sin(angle);
      }
      
      final magnitude = math.sqrt(real * real + imag * imag);
      final frequency = k * sampleRate / n;
      
      spectrum.add(SpectralPoint(frequency, magnitude));
    }
    
    return spectrum;
  }
  
  /// 포먼트 피크 찾기
  List<Formant> _findFormantPeaks(List<SpectralPoint> spectrum) {
    final formants = <Formant>[];
    final smoothed = _smoothSpectrum(spectrum);
    
    // 피크 감지
    final peaks = _detectPeaks(smoothed);
    
    // 포먼트 후보 필터링 및 정렬
    final formantCandidates = peaks.where((peak) {
      return peak.frequency >= minF1 && peak.frequency <= maxF3;
    }).toList();
    
    formantCandidates.sort((a, b) => a.frequency.compareTo(b.frequency));
    
    // F1, F2, F3 추출
    for (int i = 0; i < math.min(formantCandidates.length, 3); i++) {
      final peak = formantCandidates[i];
      final bandwidth = _estimateBandwidth(peak, smoothed);
      final quality = peak.frequency / bandwidth;
      
      formants.add(Formant(
        frequency: peak.frequency,
        bandwidth: bandwidth,
        amplitude: 20 * math.log(peak.magnitude) / math.ln10, // dB 변환
        quality: quality,
      ));
    }
    
    return formants;
  }
  
  /// 스펙트럼 평활화
  List<SpectralPoint> _smoothSpectrum(List<SpectralPoint> spectrum) {
    const windowSize = 5;
    final smoothed = <SpectralPoint>[];
    
    for (int i = 0; i < spectrum.length; i++) {
      double sum = 0.0;
      int count = 0;
      
      for (int j = math.max(0, i - windowSize ~/ 2); 
           j < math.min(spectrum.length, i + windowSize ~/ 2 + 1); 
           j++) {
        sum += spectrum[j].magnitude;
        count++;
      }
      
      smoothed.add(SpectralPoint(spectrum[i].frequency, sum / count));
    }
    
    return smoothed;
  }
  
  /// 피크 감지
  List<SpectralPoint> _detectPeaks(List<SpectralPoint> spectrum) {
    final peaks = <SpectralPoint>[];
    
    for (int i = 1; i < spectrum.length - 1; i++) {
      final current = spectrum[i];
      final prev = spectrum[i - 1];
      final next = spectrum[i + 1];
      
      if (current.magnitude > prev.magnitude && current.magnitude > next.magnitude) {
        // 최소 임계값 확인
        if (current.magnitude > _calculateThreshold(spectrum)) {
          peaks.add(current);
        }
      }
    }
    
    return peaks;
  }
  
  /// 동적 임계값 계산
  double _calculateThreshold(List<SpectralPoint> spectrum) {
    final magnitudes = spectrum.map((p) => p.magnitude).toList();
    magnitudes.sort();
    
    // 상위 20% 평균의 30%를 임계값으로 사용
    final topIndex = (magnitudes.length * 0.8).round();
    final topMagnitudes = magnitudes.sublist(topIndex);
    final avgTop = topMagnitudes.reduce((a, b) => a + b) / topMagnitudes.length;
    
    return avgTop * 0.3;
  }
  
  /// 대역폭 추정
  double _estimateBandwidth(SpectralPoint peak, List<SpectralPoint> spectrum) {
    const halfPowerRatio = 0.707; // -3dB
    final threshold = peak.magnitude * halfPowerRatio;
    
    // 피크 인덱스 찾기
    final peakIndex = spectrum.indexWhere((p) => p == peak);
    if (peakIndex == -1) return 100.0; // 기본값
    
    // 왼쪽 경계 찾기
    int leftIndex = peakIndex;
    for (int i = peakIndex - 1; i >= 0; i--) {
      if (spectrum[i].magnitude < threshold) break;
      leftIndex = i;
    }
    
    // 오른쪽 경계 찾기
    int rightIndex = peakIndex;
    for (int i = peakIndex + 1; i < spectrum.length; i++) {
      if (spectrum[i].magnitude < threshold) break;
      rightIndex = i;
    }
    
    return spectrum[rightIndex].frequency - spectrum[leftIndex].frequency;
  }
  
  /// 평균 포먼트 계산
  List<Formant> _calculateAverageFormants(List<List<Formant>> formantFrames) {
    if (formantFrames.isEmpty) return [];
    
    final avgFormants = <Formant>[];
    final maxLength = formantFrames.map((f) => f.length).reduce(math.max);
    
    for (int i = 0; i < maxLength; i++) {
      final frequencies = <double>[];
      final bandwidths = <double>[];
      final amplitudes = <double>[];
      final qualities = <double>[];
      
      for (final frame in formantFrames) {
        if (i < frame.length) {
          frequencies.add(frame[i].frequency);
          bandwidths.add(frame[i].bandwidth);
          amplitudes.add(frame[i].amplitude);
          qualities.add(frame[i].quality);
        }
      }
      
      if (frequencies.isNotEmpty) {
        avgFormants.add(Formant(
          frequency: frequencies.reduce((a, b) => a + b) / frequencies.length,
          bandwidth: bandwidths.reduce((a, b) => a + b) / bandwidths.length,
          amplitude: amplitudes.reduce((a, b) => a + b) / amplitudes.length,
          quality: qualities.reduce((a, b) => a + b) / qualities.length,
        ));
      }
    }
    
    return avgFormants;
  }
  
  /// 모음 분류
  VowelClassification _classifyVowel(List<Formant> formants) {
    if (formants.length < 2) return VowelClassification.unclear;
    
    final f1 = formants[0].frequency;
    final f2 = formants[1].frequency;
    
    // 한국어 모음 분류 기준 (대략적)
    if (f1 < 400 && f2 > 2200) return VowelClassification.i; // 이
    if (f1 > 700 && f2 < 1200) return VowelClassification.u; // 우
    if (f1 > 600 && f2 > 1400) return VowelClassification.a; // 아
    if (f1 < 500 && f2 < 1800) return VowelClassification.o; // 오
    if (f1 < 600 && f2 > 1800) return VowelClassification.e; // 에
    
    return VowelClassification.mixed;
  }
  
  /// 공명 품질 평가
  ResonanceQuality _evaluateResonanceQuality(
    List<Formant> avgFormants,
    List<List<Formant>> formantFrames,
  ) {
    if (avgFormants.isEmpty) return ResonanceQuality.poor;
    
    // 평균 Q factor 계산
    final avgQuality = avgFormants.map((f) => f.quality).reduce((a, b) => a + b) / avgFormants.length;
    
    // 일관성 계산
    final consistency = _calculateFormantConsistency(formantFrames);
    
    // 종합 점수
    final score = (avgQuality / 10.0) * 0.6 + consistency * 0.4;
    
    if (score >= 0.8) return ResonanceQuality.excellent;
    if (score >= 0.65) return ResonanceQuality.good;
    if (score >= 0.5) return ResonanceQuality.acceptable;
    if (score >= 0.3) return ResonanceQuality.weak;
    return ResonanceQuality.poor;
  }
  
  /// 포먼트 일관성 계산
  double _calculateFormantConsistency(List<List<Formant>> formantFrames) {
    if (formantFrames.length < 2) return 0.0;
    
    double totalVariance = 0.0;
    int count = 0;
    
    final maxLength = formantFrames.map((f) => f.length).reduce(math.max);
    
    for (int i = 0; i < maxLength; i++) {
      final frequencies = <double>[];
      
      for (final frame in formantFrames) {
        if (i < frame.length) {
          frequencies.add(frame[i].frequency);
        }
      }
      
      if (frequencies.length >= 2) {
        final mean = frequencies.reduce((a, b) => a + b) / frequencies.length;
        final variance = frequencies.map((f) => math.pow(f - mean, 2)).reduce((a, b) => a + b) / frequencies.length;
        totalVariance += variance;
        count++;
      }
    }
    
    if (count == 0) return 0.0;
    
    final avgVariance = totalVariance / count;
    return 1.0 / (1.0 + avgVariance / 10000); // 정규화
  }
  
  /// 포먼트 명확도 계산
  double _calculateFormantClarity(
    List<Formant> avgFormants,
    List<List<Formant>> formantFrames,
  ) {
    if (avgFormants.isEmpty) return 0.0;
    
    // 평균 진폭
    final avgAmplitude = avgFormants.map((f) => f.amplitude).reduce((a, b) => a + b) / avgFormants.length;
    
    // 대역폭 기반 명확도
    final avgBandwidth = avgFormants.map((f) => f.bandwidth).reduce((a, b) => a + b) / avgFormants.length;
    
    // 명확도 계산 (진폭은 높게, 대역폭은 적절히)
    final amplitudeScore = math.min(1.0, avgAmplitude / 60.0); // 60dB 기준
    final bandwidthScore = 1.0 / (1.0 + avgBandwidth / 200.0); // 200Hz 기준
    
    return (amplitudeScore + bandwidthScore) / 2;
  }
  
  /// 균형 계산 (F1/F2 비율)
  double _calculateBalance(List<Formant> formants) {
    if (formants.length < 2) return 0.5; // 기본값
    
    final f1 = formants[0].frequency;
    final f2 = formants[1].frequency;
    
    // F1/F2 비율을 0-1로 정규화
    final ratio = f1 / f2;
    return math.min(1.0, ratio * 2); // 0.5가 이상적
  }
  
  /// 상세 메트릭스 계산
  Map<String, dynamic> _calculateDetailedMetrics(
    List<Formant> avgFormants,
    List<List<Formant>> formantFrames,
  ) {
    final metrics = <String, dynamic>{};
    
    if (avgFormants.isNotEmpty) {
      metrics['f1_frequency'] = avgFormants[0].frequency;
      metrics['f1_bandwidth'] = avgFormants[0].bandwidth;
      metrics['f1_amplitude'] = avgFormants[0].amplitude;
    }
    
    if (avgFormants.length > 1) {
      metrics['f2_frequency'] = avgFormants[1].frequency;
      metrics['f2_bandwidth'] = avgFormants[1].bandwidth;
      metrics['f2_amplitude'] = avgFormants[1].amplitude;
      metrics['f1_f2_ratio'] = avgFormants[0].frequency / avgFormants[1].frequency;
    }
    
    if (avgFormants.length > 2) {
      metrics['f3_frequency'] = avgFormants[2].frequency;
      metrics['f3_bandwidth'] = avgFormants[2].bandwidth;
      metrics['f3_amplitude'] = avgFormants[2].amplitude;
    }
    
    metrics['formant_count'] = avgFormants.length;
    metrics['analysis_frames'] = formantFrames.length;
    metrics['consistency'] = _calculateFormantConsistency(formantFrames);
    
    return metrics;
  }
  
  /// 피드백 생성
  String _generateFeedback(
    VowelClassification vowelType,
    ResonanceQuality resonanceQuality,
    double formantClarity,
    double balance,
  ) {
    String feedback = '';
    
    switch (resonanceQuality) {
      case ResonanceQuality.excellent:
        feedback = '탁월한 공명입니다! ';
        break;
      case ResonanceQuality.good:
        feedback = '좋은 공명이네요. ';
        break;
      case ResonanceQuality.acceptable:
        feedback = '보통 수준의 공명입니다. ';
        break;
      case ResonanceQuality.weak:
        feedback = '공명이 약합니다. ';
        break;
      case ResonanceQuality.poor:
        feedback = '공명 개선이 필요합니다. ';
        break;
    }
    
    if (formantClarity > 0.7) {
      feedback += '포먼트가 명확합니다.';
    } else if (formantClarity > 0.4) {
      feedback += '포먼트가 어느 정도 명확합니다.';
    } else {
      feedback += '포먼트 명확도를 높여보세요.';
    }
    
    return feedback;
  }
  
  /// 개선 권장사항 생성
  List<String> _generateRecommendations(
    VowelClassification vowelType,
    ResonanceQuality resonanceQuality,
    double formantClarity,
    double balance,
  ) {
    final recommendations = <String>[];
    
    // 공명 품질 기반 권장사항
    switch (resonanceQuality) {
      case ResonanceQuality.poor:
      case ResonanceQuality.weak:
        recommendations.addAll([
          '입모양을 더 정확하게 만들어보세요.',
          '목구멍을 열고 깊은 호흡으로 불러보세요.',
          '모음 발성 연습을 집중적으로 해보세요.',
        ]);
        break;
      case ResonanceQuality.acceptable:
        recommendations.add('공명을 더 풍부하게 만들기 위해 구강 공간을 넓혀보세요.');
        break;
      case ResonanceQuality.good:
        recommendations.add('현재 수준을 유지하며 더욱 일관된 공명을 만들어보세요.');
        break;
      case ResonanceQuality.excellent:
        recommendations.add('훌륭합니다! 이 공명을 다양한 음역에서도 유지해보세요.');
        break;
    }
    
    // 명확도 기반 권장사항
    if (formantClarity < 0.5) {
      recommendations.add('더 명확한 발음을 위해 혀의 위치를 정확히 해보세요.');
    }
    
    // 모음별 권장사항
    switch (vowelType) {
      case VowelClassification.unclear:
        recommendations.add('모음을 더 정확하게 발음해보세요.');
        break;
      case VowelClassification.mixed:
        recommendations.add('일관된 모음으로 불러보세요.');
        break;
      default:
        break;
    }
    
    return recommendations;
  }
  
  /// 빈 분석 결과 생성
  FormantAnalysis _createEmptyAnalysis() {
    return FormantAnalysis(
      formants: [],
      vowelType: VowelClassification.unclear,
      resonanceQuality: ResonanceQuality.poor,
      formantClarity: 0.0,
      balance: 0.5,
      feedback: '분석할 음성 데이터가 부족합니다.',
      recommendations: ['더 오래 그리고 안정적으로 불러주세요.'],
      detailedMetrics: {},
    );
  }
}