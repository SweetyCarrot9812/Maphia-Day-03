import 'dart:math' as math;
import '../utils/note_utils.dart';

/// 피치 샘플 데이터
class PitchSample {
  final double frequency;
  final double timestamp;
  final double confidence;
  
  PitchSample({
    required this.frequency,
    required this.timestamp,
    required this.confidence,
  });
}

/// 비브라토 품질 평가
enum VibratoQuality {
  excellent,    // 우수 (속도, 깊이, 규칙성 모두 이상적)
  good,         // 양호 (대부분 기준 충족)
  acceptable,   // 보통 (기본 조건 충족)
  needsWork,    // 개선 필요 (일부 문제 있음)
  poor,         // 미흡 (전반적 개선 필요)
}

/// 비브라토 분석 결과
class VibratoAnalysis {
  final bool hasVibrato;
  final double rate; // Hz (진동 속도)
  final double depth; // cents (진폭 깊이)
  final double regularity; // 0-1 (규칙성)
  final double onset; // ms (비브라토 시작 시점)
  final VibratoQuality quality;
  final String feedback;
  final List<String> recommendations;
  
  VibratoAnalysis({
    required this.hasVibrato,
    required this.rate,
    required this.depth,
    required this.regularity,
    required this.onset,
    required this.quality,
    required this.feedback,
    required this.recommendations,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'has_vibrato': hasVibrato,
      'rate': rate,
      'depth': depth,
      'regularity': regularity,
      'onset': onset,
      'quality': quality.toString(),
      'feedback': feedback,
      'recommendations': recommendations,
    };
  }
  
  Map<String, dynamic> toJson() => toMap();
}

// VibratoAnalysisResult alias for compatibility
typedef VibratoAnalysisResult = VibratoAnalysis;

/// 비브라토 분석 및 코칭 시스템
class VibratoAnalyzer {
  static const int minSamples = 100; // 최소 샘플 수 (약 2초)
  static const double vibratoFreqMin = 3.0; // 최소 비브라토 주파수 (Hz)
  static const double vibratoFreqMax = 8.0; // 최대 비브라토 주파수 (Hz)
  static const double minDepthCents = 10.0; // 최소 깊이 (cents)
  static const double maxDepthCents = 200.0; // 최대 깊이 (cents)
  
  final List<PitchSample> _pitchHistory = [];
  
  /// 피치 샘플 추가
  void addPitchSample({
    required double frequency,
    required double timestamp,
    required double confidence,
  }) {
    if (confidence < 0.7) return; // 낮은 신뢰도 샘플 제외
    if (frequency < 80 || frequency > 2000) return; // 보컬 범위 외
    
    _pitchHistory.add(PitchSample(
      frequency: frequency,
      timestamp: timestamp,
      confidence: confidence,
    ));
    
    // 메모리 관리 - 최대 500개 샘플 (약 10초)
    if (_pitchHistory.length > 500) {
      _pitchHistory.removeAt(0);
    }
  }
  
  /// 비브라토 분석 수행
  VibratoAnalysis? analyzeVibrato() {
    if (_pitchHistory.length < minSamples) return null;
    
    // 최근 샘플들만 사용 (3초간)
    final recentSamples = _getRecentSamples(3000); // 3초
    if (recentSamples.length < minSamples) return null;
    
    // 피치를 센트 단위로 변환
    final centerFreq = _calculateCenterFrequency(recentSamples);
    final centsCurve = _convertToCents(recentSamples, centerFreq);
    
    // 주파수 분석으로 비브라토 감지
    final (hasVibrato, rate, depth) = _detectVibrato(centsCurve, recentSamples);
    
    if (!hasVibrato) {
      return VibratoAnalysis(
        hasVibrato: false,
        rate: 0.0,
        depth: 0.0,
        regularity: 0.0,
        onset: 0.0,
        quality: VibratoQuality.poor,
        feedback: '비브라토가 감지되지 않았습니다.',
        recommendations: [
          '일정한 톤을 유지한 후 천천히 진동을 시작해보세요.',
          '4-6Hz 속도로 연습해보세요.',
          '목과 어깨의 긴장을 풀고 자연스럽게 해보세요.',
        ],
      );
    }
    
    // 비브라토 규칙성 계산
    final regularity = _calculateRegularity(centsCurve, rate);
    
    // 비브라토 시작점 감지
    final onset = _detectVibratoOnset(centsCurve, recentSamples);
    
    // 품질 평가
    final quality = _evaluateVibratoQuality(rate, depth, regularity);
    
    // 피드백 생성
    final feedback = _generateFeedback(rate, depth, regularity, quality);
    final recommendations = _generateRecommendations(rate, depth, regularity, quality);
    
    return VibratoAnalysis(
      hasVibrato: true,
      rate: rate,
      depth: depth,
      regularity: regularity,
      onset: onset,
      quality: quality,
      feedback: feedback,
      recommendations: recommendations,
    );
  }
  
  /// 최근 샘플들 가져오기
  List<PitchSample> _getRecentSamples(int durationMs) {
    if (_pitchHistory.isEmpty) return [];
    
    final latestTime = _pitchHistory.last.timestamp;
    final cutoffTime = latestTime - durationMs;
    
    return _pitchHistory
        .where((sample) => sample.timestamp >= cutoffTime)
        .toList();
  }
  
  /// 중심 주파수 계산 (중앙값 사용)
  double _calculateCenterFrequency(List<PitchSample> samples) {
    final frequencies = samples.map((s) => s.frequency).toList()..sort();
    final middle = frequencies.length ~/ 2;
    
    if (frequencies.length % 2 == 0) {
      return (frequencies[middle - 1] + frequencies[middle]) / 2;
    } else {
      return frequencies[middle];
    }
  }
  
  /// 주파수를 센트로 변환
  List<double> _convertToCents(List<PitchSample> samples, double centerFreq) {
    return samples.map((sample) {
      return 1200 * math.log(sample.frequency / centerFreq) / math.ln2;
    }).toList();
  }
  
  /// 비브라토 감지 (FFT 기반 주파수 분석 대신 간단한 피크 감지 사용)
  (bool, double, double) _detectVibrato(List<double> centsCurve, List<PitchSample> samples) {
    if (centsCurve.length < 50) return (false, 0.0, 0.0);
    
    // 피크와 골 감지
    final peaks = <int>[];
    final valleys = <int>[];
    
    for (int i = 1; i < centsCurve.length - 1; i++) {
      if (centsCurve[i] > centsCurve[i-1] && centsCurve[i] > centsCurve[i+1]) {
        // 유의미한 피크만 포함 (최소 5 cents 차이)
        if (centsCurve[i] - math.min(centsCurve[i-1], centsCurve[i+1]) >= 5.0) {
          peaks.add(i);
        }
      } else if (centsCurve[i] < centsCurve[i-1] && centsCurve[i] < centsCurve[i+1]) {
        // 유의미한 골만 포함
        if (math.max(centsCurve[i-1], centsCurve[i+1]) - centsCurve[i] >= 5.0) {
          valleys.add(i);
        }
      }
    }
    
    // 최소 3개의 피크와 골이 있어야 비브라토로 판단
    if (peaks.length < 3 || valleys.length < 3) {
      return (false, 0.0, 0.0);
    }
    
    // 평균 주기 계산 (피크간 거리)
    double totalPeriod = 0.0;
    int periodCount = 0;
    
    for (int i = 1; i < peaks.length; i++) {
      final periodSamples = peaks[i] - peaks[i-1];
      final periodMs = (samples[peaks[i]].timestamp - samples[peaks[i-1]].timestamp);
      if (periodMs > 0) {
        totalPeriod += periodMs;
        periodCount++;
      }
    }
    
    if (periodCount == 0) return (false, 0.0, 0.0);
    
    final avgPeriodMs = totalPeriod / periodCount;
    final rate = 1000.0 / avgPeriodMs; // Hz 변환
    
    // 비브라토 주파수 범위 확인
    if (rate < vibratoFreqMin || rate > vibratoFreqMax) {
      return (false, 0.0, 0.0);
    }
    
    // 평균 깊이 계산
    double totalDepth = 0.0;
    int depthCount = 0;
    
    // 피크-골 쌍의 평균 거리
    final allExtremes = [...peaks, ...valleys]..sort();
    for (int i = 1; i < allExtremes.length; i++) {
      final depth = (centsCurve[allExtremes[i]] - centsCurve[allExtremes[i-1]]).abs();
      totalDepth += depth;
      depthCount++;
    }
    
    final avgDepth = depthCount > 0 ? totalDepth / depthCount : 0.0;
    
    // 최소 깊이 확인
    if (avgDepth < minDepthCents) {
      return (false, 0.0, 0.0);
    }
    
    return (true, rate, avgDepth);
  }
  
  /// 비브라토 규칙성 계산
  double _calculateRegularity(List<double> centsCurve, double targetRate) {
    if (centsCurve.length < 100) return 0.0;
    
    // 이상적인 사인파와의 상관관계 계산
    final sampleRate = 50.0; // 50Hz 샘플링 가정
    final idealWave = <double>[];
    
    for (int i = 0; i < centsCurve.length; i++) {
      final t = i / sampleRate;
      idealWave.add(20.0 * math.sin(2 * math.pi * targetRate * t)); // 20 cents 진폭
    }
    
    // 상관계수 계산 (간소화)
    final correlation = _calculateCorrelation(centsCurve, idealWave);
    return math.max(0.0, correlation);
  }
  
  /// 두 시계열간 상관계수 계산
  double _calculateCorrelation(List<double> signal1, List<double> signal2) {
    final n = math.min(signal1.length, signal2.length);
    if (n < 10) return 0.0;
    
    double sum1 = 0.0, sum2 = 0.0;
    for (int i = 0; i < n; i++) {
      sum1 += signal1[i];
      sum2 += signal2[i];
    }
    
    final mean1 = sum1 / n;
    final mean2 = sum2 / n;
    
    double numerator = 0.0;
    double sum1Sq = 0.0, sum2Sq = 0.0;
    
    for (int i = 0; i < n; i++) {
      final diff1 = signal1[i] - mean1;
      final diff2 = signal2[i] - mean2;
      
      numerator += diff1 * diff2;
      sum1Sq += diff1 * diff1;
      sum2Sq += diff2 * diff2;
    }
    
    final denominator = math.sqrt(sum1Sq * sum2Sq);
    return denominator > 0 ? numerator / denominator : 0.0;
  }
  
  /// 비브라토 시작점 감지
  double _detectVibratoOnset(List<double> centsCurve, List<PitchSample> samples) {
    if (samples.isEmpty) return 0.0;
    
    // 초기 안정구간과 진동구간의 분산 비교
    const windowSize = 20; // 분석 윈도우 크기
    double maxVarianceRatio = 1.0;
    int onsetIndex = 0;
    
    for (int i = windowSize; i < centsCurve.length - windowSize; i++) {
      // 이전 윈도우의 분산 (안정성)
      final prevWindow = centsCurve.sublist(i - windowSize, i);
      final prevVariance = _calculateVariance(prevWindow);
      
      // 이후 윈도우의 분산 (진동성)
      final nextWindow = centsCurve.sublist(i, i + windowSize);
      final nextVariance = _calculateVariance(nextWindow);
      
      if (prevVariance > 0) {
        final ratio = nextVariance / prevVariance;
        if (ratio > maxVarianceRatio) {
          maxVarianceRatio = ratio;
          onsetIndex = i;
        }
      }
    }
    
    return onsetIndex < samples.length ? samples[onsetIndex].timestamp : 0.0;
  }
  
  /// 분산 계산
  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values
        .map((v) => math.pow(v - mean, 2))
        .reduce((a, b) => a + b) / values.length;
    
    return variance.toDouble();
  }
  
  /// 비브라토 품질 평가
  VibratoQuality _evaluateVibratoQuality(double rate, double depth, double regularity) {
    // 이상적인 범위
    const idealRateMin = 4.5, idealRateMax = 6.5; // Hz
    const idealDepthMin = 15.0, idealDepthMax = 50.0; // cents
    const goodRegularity = 0.7;
    
    int score = 0;
    
    // 속도 평가 (0-3점)
    if (rate >= idealRateMin && rate <= idealRateMax) {
      score += 3;
    } else if (rate >= 3.5 && rate <= 7.5) {
      score += 2;
    } else if (rate >= 3.0 && rate <= 8.0) {
      score += 1;
    }
    
    // 깊이 평가 (0-3점)
    if (depth >= idealDepthMin && depth <= idealDepthMax) {
      score += 3;
    } else if (depth >= 10.0 && depth <= 80.0) {
      score += 2;
    } else if (depth >= 5.0 && depth <= 100.0) {
      score += 1;
    }
    
    // 규칙성 평가 (0-3점)
    if (regularity >= 0.8) {
      score += 3;
    } else if (regularity >= goodRegularity) {
      score += 2;
    } else if (regularity >= 0.5) {
      score += 1;
    }
    
    // 총점 기반 품질 결정
    switch (score) {
      case 8 || 9: return VibratoQuality.excellent;
      case 6 || 7: return VibratoQuality.good;
      case 4 || 5: return VibratoQuality.acceptable;
      case 2 || 3: return VibratoQuality.needsWork;
      default: return VibratoQuality.poor;
    }
  }
  
  /// 피드백 생성
  String _generateFeedback(double rate, double depth, double regularity, VibratoQuality quality) {
    switch (quality) {
      case VibratoQuality.excellent:
        return '훌륭한 비브라토입니다! 속도(${rate.toStringAsFixed(1)}Hz)와 깊이(${depth.toStringAsFixed(1)} cents), 규칙성이 모두 이상적입니다.';
      
      case VibratoQuality.good:
        return '좋은 비브라토네요. 속도 ${rate.toStringAsFixed(1)}Hz, 깊이 ${depth.toStringAsFixed(1)} cents로 안정적입니다.';
      
      case VibratoQuality.acceptable:
        return '기본적인 비브라토가 감지되었습니다. 조금 더 연습하면 좋겠어요.';
      
      case VibratoQuality.needsWork:
        return '비브라토가 불안정합니다. 속도나 깊이 조절에 집중해보세요.';
      
      case VibratoQuality.poor:
        return '비브라토 개발이 필요합니다. 기초 연습부터 차근차근 해보세요.';
    }
  }
  
  /// 개선 권장사항 생성
  List<String> _generateRecommendations(double rate, double depth, double regularity, VibratoQuality quality) {
    final recommendations = <String>[];
    
    // 속도 관련 권장사항
    if (rate < 4.0) {
      recommendations.add('비브라토 속도가 너무 느립니다. 4-6Hz로 조금 더 빠르게 해보세요.');
    } else if (rate > 7.0) {
      recommendations.add('비브라토가 너무 빨라요. 천천히 안정적으로 해보세요.');
    }
    
    // 깊이 관련 권장사항
    if (depth < 15.0) {
      recommendations.add('비브라토가 너무 얕습니다. 조금 더 큰 진폭으로 연습해보세요.');
    } else if (depth > 60.0) {
      recommendations.add('비브라토가 너무 깊어요. 좀 더 섬세하게 조절해보세요.');
    }
    
    // 규칙성 관련 권장사항
    if (regularity < 0.6) {
      recommendations.add('비브라토가 불규칙합니다. 일정한 리듬을 유지하는 연습을 해보세요.');
    }
    
    // 일반적인 권장사항
    if (quality == VibratoQuality.poor || quality == VibratoQuality.needsWork) {
      recommendations.addAll([
        '메트로놈과 함께 4-6Hz 속도로 연습해보세요.',
        '목과 어깨의 힘을 빼고 자연스럽게 해보세요.',
        '일정한 톤에서 비브라토를 시작하는 연습을 하세요.',
      ]);
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('현재 상태를 유지하며 꾸준히 연습하세요.');
    }
    
    return recommendations;
  }
  
  /// 데이터 초기화
  void clear() {
    _pitchHistory.clear();
  }
  
  /// 현재 상태 정보
  Map<String, dynamic> getStatus() {
    return {
      'sample_count': _pitchHistory.length,
      'duration_ms': _pitchHistory.isNotEmpty 
          ? (_pitchHistory.last.timestamp - _pitchHistory.first.timestamp)
          : 0.0,
      'ready_for_analysis': _pitchHistory.length >= minSamples,
    };
  }
}