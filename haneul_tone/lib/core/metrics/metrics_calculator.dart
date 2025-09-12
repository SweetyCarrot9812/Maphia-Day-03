import 'dart:math' as math;
import '../alignment/dtw_aligner.dart';

/// HaneulTone 3대 핵심 지표
/// 
/// HaneulTone v1 고도화 - 보컬 연습 성과 측정을 위한 핵심 메트릭
class Metrics {
  /// 정확도 (센트 단위, MAE)
  /// 유성음 구간에서의 평균 절대 오차
  final double accuracyCents;
  
  /// 안정도 (센트 단위, 표준편차)
  /// 정렬된 구간 내에서의 피치 변동성
  final double stabilityCents;
  
  /// 비브라토 속도 (Hz)
  /// 센트 곡선의 4-8Hz 밴드에서의 주기적 변동
  final double vibratoRateHz;
  
  /// 비브라토 폭 (센트)
  /// 같은 밴드에서의 peak-to-peak 진폭의 절반
  final double vibratoExtentCents;
  
  /// 유성음 비율 (0.0-1.0)
  /// 전체 구간 중 유성음이 차지하는 비율
  final double voicedRatio;
  
  /// 전체 점수 (0-100점)
  /// 3대 지표를 종합한 점수
  final double overallScore;

  const Metrics({
    required this.accuracyCents,
    required this.stabilityCents,
    required this.vibratoRateHz,
    required this.vibratoExtentCents,
    required this.voicedRatio,
    required this.overallScore,
  });

  /// 정확도 등급 (S, A, B, C, D)
  String get accuracyGrade {
    if (accuracyCents <= 10) return 'S';
    if (accuracyCents <= 20) return 'A';
    if (accuracyCents <= 35) return 'B';
    if (accuracyCents <= 50) return 'C';
    return 'D';
  }

  /// 안정도 등급
  String get stabilityGrade {
    if (stabilityCents <= 8) return 'S';
    if (stabilityCents <= 15) return 'A';
    if (stabilityCents <= 25) return 'B';
    if (stabilityCents <= 35) return 'C';
    return 'D';
  }

  /// 비브라토 품질 등급
  String get vibratoGrade {
    // 이상적인 비브라토: 4.5-6.5Hz, 20-60센트
    final isGoodRate = vibratoRateHz >= 4.5 && vibratoRateHz <= 6.5;
    final isGoodExtent = vibratoExtentCents >= 20 && vibratoExtentCents <= 60;
    
    if (isGoodRate && isGoodExtent) return 'S';
    if (isGoodRate || isGoodExtent) return 'A';
    if (vibratoRateHz > 0 && vibratoExtentCents > 0) return 'B';
    return 'C';
  }

  @override
  String toString() {
    return 'Metrics('
           'accuracy=${accuracyCents.toStringAsFixed(1)}c($accuracyGrade), '
           'stability=${stabilityCents.toStringAsFixed(1)}c($stabilityGrade), '
           'vibrato=${vibratoRateHz.toStringAsFixed(1)}Hz/${vibratoExtentCents.toStringAsFixed(1)}c($vibratoGrade), '
           'voiced=${(voicedRatio * 100).toStringAsFixed(1)}%, '
           'score=${overallScore.toStringAsFixed(1)})';
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'accuracyCents': accuracyCents,
      'stabilityCents': stabilityCents,
      'vibratoRateHz': vibratoRateHz,
      'vibratoExtentCents': vibratoExtentCents,
      'voicedRatio': voicedRatio,
      'overallScore': overallScore,
      'grades': {
        'accuracy': accuracyGrade,
        'stability': stabilityGrade,
        'vibrato': vibratoGrade,
      },
    };
  }

  /// JSON에서 역직렬화
  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      accuracyCents: (json['accuracyCents'] as num).toDouble(),
      stabilityCents: (json['stabilityCents'] as num).toDouble(),
      vibratoRateHz: (json['vibratoRateHz'] as num).toDouble(),
      vibratoExtentCents: (json['vibratoExtentCents'] as num).toDouble(),
      voicedRatio: (json['voicedRatio'] as num).toDouble(),
      overallScore: (json['overallScore'] as num).toDouble(),
    );
  }
}

/// 메트릭 계산기
/// 
/// HaneulTone v1 고도화 - DTW 정렬 결과를 기반으로 3대 지표 계산
class MetricsCalculator {
  final double _sampleRate;
  final double _frameTimeMs;
  
  /// 메트릭 계산기 생성자
  /// 
  /// [sampleRate]: 오디오 샘플링 레이트 (기본 24000Hz)
  /// [frameTimeMs]: 프레임 간 시간 간격 (기본 10ms)
  MetricsCalculator({
    double sampleRate = 24000.0,
    double frameTimeMs = 10.0,
  }) : _sampleRate = sampleRate,
       _frameTimeMs = frameTimeMs;

  /// DTW 정렬 결과를 기반으로 메트릭 계산
  /// 
  /// [dtwResult]: DTW 정렬 결과
  /// [referenceCents]: 레퍼런스 피치 곡선 (센트)
  /// [userCents]: 사용자 피치 곡선 (센트)
  /// [userVoicing]: 사용자 유성음 확률 (선택사항)
  /// [returns]: 계산된 메트릭
  Metrics calculateMetrics(
    DtwResult dtwResult,
    List<double> referenceCents,
    List<double> userCents, {
    List<double>? userVoicing,
  }) {
    if (!dtwResult.isValidAlignment || dtwResult.segmentErrors.isEmpty) {
      return _createEmptyMetrics();
    }

    // 정확도 계산 (유성음 구간의 MAE)
    final accuracy = _calculateAccuracy(dtwResult.segmentErrors, referenceCents, userCents, dtwResult);
    
    // 안정도 계산 (정렬된 구간의 표준편차)
    final stability = _calculateStability(dtwResult, referenceCents, userCents);
    
    // 비브라토 분석
    final vibratoAnalysis = _analyzeVibrato(dtwResult, userCents, userVoicing);
    
    // 유성음 비율 계산
    final voicedRatio = _calculateVoicedRatio(dtwResult, referenceCents, userCents);
    
    // 전체 점수 계산
    final overallScore = _calculateOverallScore(accuracy, stability, vibratoAnalysis, voicedRatio);

    return Metrics(
      accuracyCents: accuracy,
      stabilityCents: stability,
      vibratoRateHz: vibratoAnalysis.rateHz,
      vibratoExtentCents: vibratoAnalysis.extentCents,
      voicedRatio: voicedRatio,
      overallScore: overallScore,
    );
  }

  /// 정확도 계산 (유성음 구간의 평균 절대 오차)
  double _calculateAccuracy(
    List<double> segmentErrors,
    List<double> referenceCents,
    List<double> userCents,
    DtwResult dtwResult,
  ) {
    final voicedErrors = <double>[];
    
    for (int i = 0; i < dtwResult.pathLength; i++) {
      final refIdx = dtwResult.pathRefIdx[i];
      final userIdx = dtwResult.pathUserIdx[i];
      
      // 둘 다 유성음인 구간만 고려
      if (referenceCents[refIdx] != 0 && userCents[userIdx] != 0) {
        voicedErrors.add(segmentErrors[i]);
      }
    }
    
    if (voicedErrors.isEmpty) return 0.0;
    
    // 평균 절대 오차 (MAE)
    return voicedErrors.reduce((a, b) => a + b) / voicedErrors.length;
  }

  /// 안정도 계산 (정렬된 구간의 피치 변동성)
  double _calculateStability(
    DtwResult dtwResult,
    List<double> referenceCents,
    List<double> userCents,
  ) {
    final alignedUserCents = <double>[];
    
    for (int i = 0; i < dtwResult.pathLength; i++) {
      final userIdx = dtwResult.pathUserIdx[i];
      final refIdx = dtwResult.pathRefIdx[i];
      
      // 둘 다 유성음인 구간만 고려
      if (referenceCents[refIdx] != 0 && userCents[userIdx] != 0) {
        alignedUserCents.add(userCents[userIdx]);
      }
    }
    
    if (alignedUserCents.length < 2) return 0.0;
    
    // 표준편차 계산
    final mean = alignedUserCents.reduce((a, b) => a + b) / alignedUserCents.length;
    final variance = alignedUserCents
        .map((value) => math.pow(value - mean, 2))
        .reduce((a, b) => a + b) / (alignedUserCents.length - 1);
    
    return math.sqrt(variance);
  }

  /// 비브라토 분석
  _VibratoAnalysis _analyzeVibrato(
    DtwResult dtwResult,
    List<double> userCents,
    List<double>? userVoicing,
  ) {
    // 정렬된 사용자 피치 곡선 추출
    final alignedCents = <double>[];
    final alignedVoicing = <double>[];
    
    for (int i = 0; i < dtwResult.pathLength; i++) {
      final userIdx = dtwResult.pathUserIdx[i];
      alignedCents.add(userCents[userIdx]);
      alignedVoicing.add(userVoicing?[userIdx] ?? 1.0);
    }
    
    if (alignedCents.length < 50) { // 최소 0.5초 필요
      return _VibratoAnalysis(rateHz: 0.0, extentCents: 0.0);
    }
    
    // 유성음 구간만 필터링
    final voicedCents = <double>[];
    for (int i = 0; i < alignedCents.length; i++) {
      if (alignedCents[i] != 0 && alignedVoicing[i] > 0.5) {
        voicedCents.add(alignedCents[i]);
      }
    }
    
    if (voicedCents.length < 50) {
      return _VibratoAnalysis(rateHz: 0.0, extentCents: 0.0);
    }
    
    // 트렌드 제거 (선형 디트렌딩)
    final detrended = _linearDetrend(voicedCents);
    
    // 4-8Hz 밴드패스 필터
    final filtered = _bandpassFilter(detrended, 4.0, 8.0);
    
    // 비브라토 속도 추정 (제로 크로싱 기반)
    final vibratoRate = _estimateVibratoRate(filtered);
    
    // 비브라토 폭 추정 (peak-to-peak 분석)
    final vibratoExtent = _estimateVibratoExtent(filtered);
    
    return _VibratoAnalysis(
      rateHz: vibratoRate,
      extentCents: vibratoExtent,
    );
  }

  /// 선형 디트렌딩
  List<double> _linearDetrend(List<double> data) {
    if (data.length < 2) return data;
    
    // 최소자승법으로 기울기와 절편 계산
    final n = data.length;
    double sumX = 0.0;
    double sumY = 0.0;
    double sumXY = 0.0;
    double sumXX = 0.0;
    
    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += data[i];
      sumXY += i * data[i];
      sumXX += i * i;
    }
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;
    
    // 트렌드 제거
    final detrended = <double>[];
    for (int i = 0; i < n; i++) {
      final trend = slope * i + intercept;
      detrended.add(data[i] - trend);
    }
    
    return detrended;
  }

  /// 간단한 밴드패스 필터 (4-8Hz)
  List<double> _bandpassFilter(List<double> data, double lowFreq, double highFreq) {
    // 실제 구현에서는 더 정교한 필터를 사용할 수 있음
    // 여기서는 간단한 차분 기반 고역통과 + 이동평균 기반 저역통과
    
    // 1차 차분으로 고역통과 효과
    final highpassed = <double>[];
    if (data.isEmpty) return highpassed;
    
    highpassed.add(0.0);
    for (int i = 1; i < data.length; i++) {
      highpassed.add(data[i] - data[i - 1]);
    }
    
    // 이동평균으로 저역통과 효과
    final windowSize = (_sampleRate / _frameTimeMs / highFreq).round();
    final filtered = <double>[];
    
    for (int i = 0; i < highpassed.length; i++) {
      final start = math.max(0, i - windowSize ~/ 2);
      final end = math.min(highpassed.length, i + windowSize ~/ 2);
      
      double sum = 0.0;
      for (int j = start; j < end; j++) {
        sum += highpassed[j];
      }
      
      filtered.add(sum / (end - start));
    }
    
    return filtered;
  }

  /// 비브라토 속도 추정 (제로 크로싱 기반)
  double _estimateVibratoRate(List<double> filtered) {
    if (filtered.length < 10) return 0.0;
    
    // 제로 크로싱 검출
    int zeroCrossings = 0;
    for (int i = 1; i < filtered.length; i++) {
      if (filtered[i - 1] * filtered[i] < 0) {
        zeroCrossings++;
      }
    }
    
    if (zeroCrossings < 2) return 0.0;
    
    // 주파수 = (제로 크로싱 수 / 2) / 전체 시간
    final totalTimeSeconds = filtered.length * _frameTimeMs / 1000.0;
    final frequency = (zeroCrossings / 2.0) / totalTimeSeconds;
    
    // 유효한 비브라토 범위인지 확인
    return (frequency >= 3.0 && frequency <= 10.0) ? frequency : 0.0;
  }

  /// 비브라토 폭 추정 (peak-to-peak)
  double _estimateVibratoExtent(List<double> filtered) {
    if (filtered.length < 5) return 0.0;
    
    // 지역 최대값과 최소값 찾기
    final peaks = <double>[];
    final troughs = <double>[];
    
    for (int i = 1; i < filtered.length - 1; i++) {
      if (filtered[i] > filtered[i - 1] && filtered[i] > filtered[i + 1]) {
        peaks.add(filtered[i]);
      } else if (filtered[i] < filtered[i - 1] && filtered[i] < filtered[i + 1]) {
        troughs.add(filtered[i]);
      }
    }
    
    if (peaks.isEmpty || troughs.isEmpty) return 0.0;
    
    // 평균 peak-to-peak 진폭 계산
    final maxPeak = peaks.reduce(math.max);
    final minTrough = troughs.reduce(math.min);
    
    return (maxPeak - minTrough) / 2.0; // 진폭의 절반
  }

  /// 유성음 비율 계산
  double _calculateVoicedRatio(
    DtwResult dtwResult,
    List<double> referenceCents,
    List<double> userCents,
  ) {
    if (dtwResult.pathLength == 0) return 0.0;
    
    int voicedFrames = 0;
    for (int i = 0; i < dtwResult.pathLength; i++) {
      final refIdx = dtwResult.pathRefIdx[i];
      final userIdx = dtwResult.pathUserIdx[i];
      
      if (referenceCents[refIdx] != 0 && userCents[userIdx] != 0) {
        voicedFrames++;
      }
    }
    
    return voicedFrames / dtwResult.pathLength;
  }

  /// 전체 점수 계산 (0-100점)
  double _calculateOverallScore(
    double accuracy,
    double stability,
    _VibratoAnalysis vibrato,
    double voicedRatio,
  ) {
    // 정확도 점수 (50점 만점)
    double accuracyScore = 50.0;
    if (accuracy > 0) {
      accuracyScore = math.max(0.0, 50.0 - accuracy * 1.0);
    }
    
    // 안정도 점수 (30점 만점)
    double stabilityScore = 30.0;
    if (stability > 0) {
      stabilityScore = math.max(0.0, 30.0 - stability * 0.8);
    }
    
    // 비브라토 점수 (10점 만점)
    double vibratoScore = 0.0;
    if (vibrato.rateHz >= 4.5 && vibrato.rateHz <= 6.5) vibratoScore += 5.0;
    if (vibrato.extentCents >= 20 && vibrato.extentCents <= 60) vibratoScore += 5.0;
    
    // 유성음 비율 보너스 (10점 만점)
    final voicedBonus = math.min(10.0, voicedRatio * 10.0);
    
    return math.min(100.0, accuracyScore + stabilityScore + vibratoScore + voicedBonus);
  }

  /// 빈 메트릭 생성 (측정 불가능한 경우)
  Metrics _createEmptyMetrics() {
    return Metrics(
      accuracyCents: 0.0,
      stabilityCents: 0.0,
      vibratoRateHz: 0.0,
      vibratoExtentCents: 0.0,
      voicedRatio: 0.0,
      overallScore: 0.0,
    );
  }
}

/// 비브라토 분석 결과 (내부용)
class _VibratoAnalysis {
  final double rateHz;
  final double extentCents;

  const _VibratoAnalysis({
    required this.rateHz,
    required this.extentCents,
  });
}