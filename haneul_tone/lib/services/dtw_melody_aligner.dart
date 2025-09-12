import 'dart:math' as math;
import '../utils/note_utils.dart';
import '../models/pitch_data.dart';

/// 멜로디 음표 정보
class MelodyNote {
  final double frequency;
  final double startTime;
  final double duration;
  final String noteName;
  final double confidence;
  
  MelodyNote({
    required this.frequency,
    required this.startTime,
    required this.duration,
    required this.noteName,
    required this.confidence,
  });
  
  double get endTime => startTime + duration;
  
  Map<String, dynamic> toMap() {
    return {
      'frequency': frequency,
      'start_time': startTime,
      'duration': duration,
      'note_name': noteName,
      'confidence': confidence,
    };
  }
}

/// DTW 정렬 결과
class DTWAlignment {
  final List<AlignmentPair> alignmentPairs;
  final double totalDistance;
  final double normalizedScore; // 0-1, 1이 완벽한 정렬
  final List<TimingError> timingErrors;
  final List<PitchError> pitchErrors;
  final AlignmentQuality quality;
  final String feedback;
  final List<String> recommendations;
  
  // 전체 정확도 (0-100 스케일)
  double get overallAccuracy => normalizedScore * 100.0;
  
  DTWAlignment({
    required this.alignmentPairs,
    required this.totalDistance,
    required this.normalizedScore,
    required this.timingErrors,
    required this.pitchErrors,
    required this.quality,
    required this.feedback,
    required this.recommendations,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'alignment_pairs': alignmentPairs.map((p) => p.toMap()).toList(),
      'total_distance': totalDistance,
      'normalized_score': normalizedScore,
      'timing_errors': timingErrors.map((e) => e.toMap()).toList(),
      'pitch_errors': pitchErrors.map((e) => e.toMap()).toList(),
      'quality': quality.toString(),
      'feedback': feedback,
      'recommendations': recommendations,
    };
  }
  
  Map<String, dynamic> toJson() => toMap();
}

/// 정렬 쌍 (레퍼런스 인덱스 → 사용자 인덱스)
class AlignmentPair {
  final int referenceIndex;
  final int userIndex;
  final double distance;
  final AlignmentType type;
  
  AlignmentPair({
    required this.referenceIndex,
    required this.userIndex,
    required this.distance,
    required this.type,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'reference_index': referenceIndex,
      'user_index': userIndex,
      'distance': distance,
      'type': type.toString(),
    };
  }
}

/// 정렬 타입
enum AlignmentType {
  match,        // 완벽한 매치
  substitute,   // 음정 차이
  insertion,    // 사용자가 추가한 음표
  deletion,     // 사용자가 놓친 음표
}

/// 타이밍 오류
class TimingError {
  final int noteIndex;
  final double expectedTime;
  final double actualTime;
  final double deviation; // ms 단위
  final TimingErrorType type;
  final String description;
  
  TimingError({
    required this.noteIndex,
    required this.expectedTime,
    required this.actualTime,
    required this.deviation,
    required this.type,
    required this.description,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'note_index': noteIndex,
      'expected_time': expectedTime,
      'actual_time': actualTime,
      'deviation': deviation,
      'type': type.toString(),
      'description': description,
    };
  }
}

/// 타이밍 오류 타입
enum TimingErrorType {
  early,      // 너무 빨리
  late,       // 너무 늦게
  rushed,     // 서두름
  dragged,    // 끌림
}

/// 음정 오류
class PitchError {
  final int noteIndex;
  final double expectedFreq;
  final double actualFreq;
  final double centsDifference;
  final PitchErrorType type;
  final String description;
  
  PitchError({
    required this.noteIndex,
    required this.expectedFreq,
    required this.actualFreq,
    required this.centsDifference,
    required this.type,
    required this.description,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'note_index': noteIndex,
      'expected_freq': expectedFreq,
      'actual_freq': actualFreq,
      'cents_difference': centsDifference,
      'type': type.toString(),
      'description': description,
    };
  }
}

/// 음정 오류 타입
enum PitchErrorType {
  sharp,      // 날카로움 (#)
  flat,       // 흐림 (♭)
  unstable,   // 불안정
  missed,     // 놓친 음표
}

/// 정렬 품질
enum AlignmentQuality {
  excellent,    // 90% 이상
  good,         // 75-89%
  acceptable,   // 60-74%
  needsWork,    // 40-59%
  poor,         // 40% 미만
}

// AlignmentResult alias for compatibility
typedef AlignmentResult = DTWAlignment;

/// DTW(Dynamic Time Warping) 기반 멜로디 정렬 시스템
/// 레퍼런스 멜로디와 사용자 녹음을 시간축에서 최적 정렬하여 정확한 비교 분석
class DTWMelodyAligner {
  static const double maxWarpingDistance = 0.3; // 최대 30% 시간 변형 허용
  static const double frequencyToleranceCents = 50.0; // 주파수 허용 오차 (cents)
  static const int minSequenceLength = 10; // 최소 시퀀스 길이
  static const double pitchWeight = 0.7; // 음정 가중치
  static const double timingWeight = 0.3; // 타이밍 가중치
  static const double maxCentsDeviation = 50.0; // 최대 허용 센트 차이
  static const double maxTimingDeviation = 200.0; // 최대 허용 타이밍 차이 (ms)
  
  /// 멜로디 정렬 분석 수행
  Future<DTWAlignment> alignMelodies(
    List<MelodyNote> reference,
    List<MelodyNote> userSinging,
  ) async {
    if (reference.isEmpty || userSinging.isEmpty) {
      return _createEmptyAlignment();
    }
    
    // DTW 매트릭스 계산
    final dtwMatrix = _calculateDTWMatrix(reference, userSinging);
    
    // 최적 경로 추적
    final alignmentPairs = _traceback(dtwMatrix, reference, userSinging);
    
    // 총 거리 계산
    final totalDistance = dtwMatrix[reference.length][userSinging.length];
    
    // 정규화된 점수 계산 (0-1)
    final normalizedScore = _calculateNormalizedScore(totalDistance, reference, userSinging);
    
    // 오류 분석
    final timingErrors = _analyzeTimingErrors(reference, userSinging, alignmentPairs);
    final pitchErrors = _analyzePitchErrors(reference, userSinging, alignmentPairs);
    
    // 품질 평가
    final quality = _evaluateAlignmentQuality(normalizedScore);
    
    // 피드백 생성
    final feedback = _generateFeedback(normalizedScore, timingErrors, pitchErrors, quality);
    final recommendations = _generateRecommendations(timingErrors, pitchErrors, quality);
    
    return DTWAlignment(
      alignmentPairs: alignmentPairs,
      totalDistance: totalDistance,
      normalizedScore: normalizedScore,
      timingErrors: timingErrors,
      pitchErrors: pitchErrors,
      quality: quality,
      feedback: feedback,
      recommendations: recommendations,
    );
  }
  
  /// DTW 매트릭스 계산
  List<List<double>> _calculateDTWMatrix(
    List<MelodyNote> reference,
    List<MelodyNote> userSinging,
  ) {
    final rows = reference.length + 1;
    final cols = userSinging.length + 1;
    
    // 매트릭스 초기화
    final dtw = List.generate(rows, (i) => List.filled(cols, double.infinity));
    dtw[0][0] = 0.0;
    
    // 첫 행과 첫 열 초기화 (삽입/삭제 비용)
    for (int i = 1; i < rows; i++) {
      dtw[i][0] = dtw[i-1][0] + _getDeletionCost(reference[i-1]);
    }
    
    for (int j = 1; j < cols; j++) {
      dtw[0][j] = dtw[0][j-1] + _getInsertionCost(userSinging[j-1]);
    }
    
    // DTW 매트릭스 채우기
    for (int i = 1; i < rows; i++) {
      for (int j = 1; j < cols; j++) {
        final cost = _calculateNoteCost(reference[i-1], userSinging[j-1]);
        
        dtw[i][j] = cost + math.min(
          math.min(dtw[i-1][j], dtw[i][j-1]), // 삽입/삭제
          dtw[i-1][j-1], // 매치/치환
        );
      }
    }
    
    return dtw;
  }
  
  /// 두 음표간의 비용 계산
  double _calculateNoteCost(MelodyNote reference, MelodyNote userNote) {
    // 음정 차이 (센트 단위)
    final pitchDiff = _calculateCentsDifference(reference.frequency, userNote.frequency);
    final pitchCost = math.min(pitchDiff / maxCentsDeviation, 1.0) * pitchWeight;
    
    // 타이밍 차이
    final timingDiff = (reference.startTime - userNote.startTime).abs();
    final timingCost = math.min(timingDiff / maxTimingDeviation, 1.0) * timingWeight;
    
    return pitchCost + timingCost;
  }
  
  /// 센트 차이 계산
  double _calculateCentsDifference(double freq1, double freq2) {
    if (freq1 <= 0 || freq2 <= 0) return maxCentsDeviation;
    return (1200 * math.log(freq2 / freq1) / math.ln2).abs();
  }
  
  /// 삭제 비용 (레퍼런스 음표를 놓침)
  double _getDeletionCost(MelodyNote note) {
    return 0.5; // 고정 비용
  }
  
  /// 삽입 비용 (추가 음표)
  double _getInsertionCost(MelodyNote note) {
    return 0.3; // 삽입은 삭제보다 덜 심각
  }
  
  /// 최적 경로 추적 (역추적)
  List<AlignmentPair> _traceback(
    List<List<double>> dtw, 
    List<MelodyNote> reference,
    List<MelodyNote> userSinging,
  ) {
    final pairs = <AlignmentPair>[];
    int i = reference.length, j = userSinging.length;
    
    while (i > 0 || j > 0) {
      if (i > 0 && j > 0) {
        final diagonal = dtw[i-1][j-1];
        final left = dtw[i][j-1];
        final up = dtw[i-1][j];
        
        if (diagonal <= left && diagonal <= up) {
          // 매치 또는 치환
          final cost = _calculateNoteCost(reference[i-1], userSinging[j-1]);
          
          pairs.add(AlignmentPair(
            referenceIndex: i-1,
            userIndex: j-1,
            distance: cost,
            type: cost < 0.1 ? AlignmentType.match : AlignmentType.substitute,
          ));
          i--; j--;
        } else if (left < up) {
          // 삽입 (사용자가 추가한 음표)
          pairs.add(AlignmentPair(
            referenceIndex: -1,
            userIndex: j-1,
            distance: 0.3,
            type: AlignmentType.insertion,
          ));
          j--;
        } else {
          // 삭제 (사용자가 놓친 음표)
          pairs.add(AlignmentPair(
            referenceIndex: i-1,
            userIndex: -1,
            distance: 0.5,
            type: AlignmentType.deletion,
          ));
          i--;
        }
      } else if (i > 0) {
        // 나머지 레퍼런스 음표들 (삭제)
        pairs.add(AlignmentPair(
          referenceIndex: i-1,
          userIndex: -1,
          distance: 0.5,
          type: AlignmentType.deletion,
        ));
        i--;
      } else {
        // 나머지 사용자 음표들 (삽입)
        pairs.add(AlignmentPair(
          referenceIndex: -1,
          userIndex: j-1,
          distance: 0.3,
          type: AlignmentType.insertion,
        ));
        j--;
      }
    }
    
    return pairs.reversed.toList();
  }
  
  /// 정규화된 점수 계산
  double _calculateNormalizedScore(
    double totalDistance,
    List<MelodyNote> reference,
    List<MelodyNote> userSinging,
  ) {
    if (reference.isEmpty) return 0.0;
    
    // 최대 가능한 거리 (모든 음표가 완전히 틀렸을 경우)
    final maxPossibleDistance = reference.length * 1.0; // 최대 비용
    
    if (maxPossibleDistance == 0) return 1.0;
    
    // 0-1 스케일로 정규화 (1이 완벽한 매치)
    final normalizedDistance = totalDistance / maxPossibleDistance;
    return math.max(0.0, 1.0 - normalizedDistance);
  }
  
  /// 타이밍 오류 분석
  List<TimingError> _analyzeTimingErrors(
    List<MelodyNote> reference,
    List<MelodyNote> userSinging,
    List<AlignmentPair> alignmentPairs,
  ) {
    final errors = <TimingError>[];
    
    for (final pair in alignmentPairs) {
      if (pair.type == AlignmentType.match || pair.type == AlignmentType.substitute) {
        if (pair.referenceIndex >= 0 && pair.userIndex >= 0 && 
            pair.referenceIndex < reference.length && pair.userIndex < userSinging.length) {
          final refNote = reference[pair.referenceIndex];
          final userNote = userSinging[pair.userIndex];
          
          final timingDiff = userNote.startTime - refNote.startTime;
          
          if (timingDiff.abs() > 50.0) { // 50ms 이상 차이
            final errorType = timingDiff > 0 ? TimingErrorType.late : TimingErrorType.early;
            
            errors.add(TimingError(
              noteIndex: pair.referenceIndex,
              expectedTime: refNote.startTime,
              actualTime: userNote.startTime,
              deviation: timingDiff,
              type: errorType,
              description: _getTimingErrorDescription(timingDiff, errorType),
            ));
          }
        }
      }
    }
    
    return errors;
  }
  
  /// 음정 오류 분석
  List<PitchError> _analyzePitchErrors(
    List<MelodyNote> reference,
    List<MelodyNote> userSinging,
    List<AlignmentPair> alignmentPairs,
  ) {
    final errors = <PitchError>[];
    
    for (final pair in alignmentPairs) {
      if (pair.type == AlignmentType.match || pair.type == AlignmentType.substitute) {
        if (pair.referenceIndex >= 0 && pair.userIndex >= 0 && 
            pair.referenceIndex < reference.length && pair.userIndex < userSinging.length) {
          final refNote = reference[pair.referenceIndex];
          final userNote = userSinging[pair.userIndex];
          
          final centsDiff = _calculateCentsDifference(refNote.frequency, userNote.frequency);
          
          if (centsDiff > 20.0) { // 20센트 이상 차이
            final errorType = _getPitchErrorType(centsDiff, refNote.frequency, userNote.frequency);
            
            errors.add(PitchError(
              noteIndex: pair.referenceIndex,
              expectedFreq: refNote.frequency,
              actualFreq: userNote.frequency,
              centsDifference: centsDiff,
              type: errorType,
              description: _getPitchErrorDescription(centsDiff, errorType),
            ));
          }
        }
      } else if (pair.type == AlignmentType.deletion && pair.referenceIndex >= 0 && pair.referenceIndex < reference.length) {
        // 놓친 음표
        errors.add(PitchError(
          noteIndex: pair.referenceIndex,
          expectedFreq: reference[pair.referenceIndex].frequency,
          actualFreq: 0.0,
          centsDifference: 0.0,
          type: PitchErrorType.missed,
          description: '음표를 놓쳤습니다: ${reference[pair.referenceIndex].noteName}',
        ));
      }
    }
    
    return errors;
  }
  
  /// 타이밍 오류 설명 생성
  String _getTimingErrorDescription(double deviation, TimingErrorType type) {
    final absDeviation = deviation.abs();
    final deviationStr = '${absDeviation.toStringAsFixed(0)}ms';
    
    switch (type) {
      case TimingErrorType.early:
        return '너무 일찍 시작했습니다 ($deviationStr 빠름)';
      case TimingErrorType.late:
        return '너무 늦게 시작했습니다 ($deviationStr 늦음)';
      case TimingErrorType.rushed:
        return '서둘러서 불러졌습니다';
      case TimingErrorType.dragged:
        return '끌려서 불러졌습니다';
    }
  }
  
  /// 음정 오류 타입 결정
  PitchErrorType _getPitchErrorType(double centsDiff, double expectedFreq, double actualFreq) {
    if (actualFreq > expectedFreq) {
      return PitchErrorType.sharp;
    } else {
      return PitchErrorType.flat;
    }
  }
  
  /// 음정 오류 설명 생성
  String _getPitchErrorDescription(double centsDiff, PitchErrorType type) {
    final centsStr = centsDiff.toStringAsFixed(0);
    
    switch (type) {
      case PitchErrorType.sharp:
        return '음정이 높습니다 (+${centsStr} cents)';
      case PitchErrorType.flat:
        return '음정이 낮습니다 (-${centsStr} cents)';
      case PitchErrorType.unstable:
        return '음정이 불안정합니다';
      case PitchErrorType.missed:
        return '음표를 놓쳤습니다';
    }
  }
  
  /// 정렬 품질 평가
  AlignmentQuality _evaluateAlignmentQuality(double normalizedScore) {
    if (normalizedScore >= 0.9) return AlignmentQuality.excellent;
    if (normalizedScore >= 0.75) return AlignmentQuality.good;
    if (normalizedScore >= 0.6) return AlignmentQuality.acceptable;
    if (normalizedScore >= 0.4) return AlignmentQuality.needsWork;
    return AlignmentQuality.poor;
  }
  
  /// 피드백 생성
  String _generateFeedback(
    double normalizedScore,
    List<TimingError> timingErrors,
    List<PitchError> pitchErrors,
    AlignmentQuality quality,
  ) {
    final scorePercent = (normalizedScore * 100).toStringAsFixed(0);
    
    String feedback = '정확도: ${scorePercent}% ';
    
    switch (quality) {
      case AlignmentQuality.excellent:
        feedback += '- 훌륭한 연주입니다!';
        break;
      case AlignmentQuality.good:
        feedback += '- 좋은 연주네요!';
        break;
      case AlignmentQuality.acceptable:
        feedback += '- 괜찮은 연주입니다.';
        break;
      case AlignmentQuality.needsWork:
        feedback += '- 더 연습이 필요해요.';
        break;
      case AlignmentQuality.poor:
        feedback += '- 많은 연습이 필요합니다.';
        break;
    }
    
    if (timingErrors.isNotEmpty) {
      feedback += ' 타이밍 조절에 집중해보세요.';
    }
    
    if (pitchErrors.isNotEmpty) {
      feedback += ' 음정 정확도를 높여보세요.';
    }
    
    return feedback;
  }
  
  /// 개선 권장사항 생성
  List<String> _generateRecommendations(
    List<TimingError> timingErrors,
    List<PitchError> pitchErrors,
    AlignmentQuality quality,
  ) {
    final recommendations = <String>[];
    
    // 타이밍 관련 권장사항
    if (timingErrors.isNotEmpty) {
      final earlyCount = timingErrors.where((e) => e.type == TimingErrorType.early).length;
      final lateCount = timingErrors.where((e) => e.type == TimingErrorType.late).length;
      
      if (earlyCount > lateCount) {
        recommendations.add('전체적으로 서두르는 경향이 있습니다. 메트로놈과 함께 천천히 연습해보세요.');
      } else if (lateCount > earlyCount) {
        recommendations.add('전체적으로 느린 경향이 있습니다. 리듬감을 기르는 연습을 해보세요.');
      } else {
        recommendations.add('타이밍이 일정하지 않습니다. 메트로놈과 함께 꾸준히 연습하세요.');
      }
    }
    
    // 음정 관련 권장사항
    if (pitchErrors.isNotEmpty) {
      final sharpCount = pitchErrors.where((e) => e.type == PitchErrorType.sharp).length;
      final flatCount = pitchErrors.where((e) => e.type == PitchErrorType.flat).length;
      
      if (sharpCount > flatCount) {
        recommendations.add('음정이 높아지는 경향이 있습니다. 좀 더 낮은 음정을 의식해서 불러보세요.');
      } else if (flatCount > sharpCount) {
        recommendations.add('음정이 낮아지는 경향이 있습니다. 지지음과 함께 정확한 음정을 연습하세요.');
      }
      
      if (pitchErrors.any((e) => e.centsDifference > 50)) {
        recommendations.add('큰 음정 오류가 있습니다. 스케일 연습을 통해 음감을 기르세요.');
      }
    }
    
    // 품질별 권장사항
    switch (quality) {
      case AlignmentQuality.poor:
      case AlignmentQuality.needsWork:
        recommendations.addAll([
          '기본 스케일 연습을 더 많이 하세요.',
          '한 구절씩 나누어서 천천히 연습해보세요.',
          '원곡을 충분히 듣고 멜로디를 익히세요.',
        ]);
        break;
      case AlignmentQuality.acceptable:
        recommendations.add('꾸준히 연습하면 더 좋아질 거예요.');
        break;
      case AlignmentQuality.good:
        recommendations.add('디테일한 부분을 조금 더 신경써보세요.');
        break;
      case AlignmentQuality.excellent:
        recommendations.add('훌륭합니다! 이 수준을 유지하세요.');
        break;
    }
    
    return recommendations;
  }
  
  /// 빈 정렬 결과 생성 (오류 케이스용)
  DTWAlignment _createEmptyAlignment() {
    return DTWAlignment(
      alignmentPairs: [],
      totalDistance: 0.0,
      normalizedScore: 0.0,
      timingErrors: [],
      pitchErrors: [],
      quality: AlignmentQuality.poor,
      feedback: '분석할 데이터가 부족합니다.',
      recommendations: ['더 오래 불러서 충분한 데이터를 제공해주세요.'],
    );
  }
  
  /// 통계 정보 제공
  Map<String, dynamic> getAlignmentStatistics(DTWAlignment alignment) {
    final totalPairs = alignment.alignmentPairs.length;
    if (totalPairs == 0) return {};
    
    final matches = alignment.alignmentPairs.where((p) => p.type == AlignmentType.match).length;
    final substitutions = alignment.alignmentPairs.where((p) => p.type == AlignmentType.substitute).length;
    final insertions = alignment.alignmentPairs.where((p) => p.type == AlignmentType.insertion).length;
    final deletions = alignment.alignmentPairs.where((p) => p.type == AlignmentType.deletion).length;
    
    return {
      'total_notes': totalPairs,
      'perfect_matches': matches,
      'pitch_errors': substitutions,
      'extra_notes': insertions,
      'missed_notes': deletions,
      'match_rate': matches / totalPairs,
      'error_rate': (substitutions + insertions + deletions) / totalPairs,
      'average_timing_error': alignment.timingErrors.isEmpty ? 0.0 :
          alignment.timingErrors.map((e) => e.deviation.abs()).reduce((a, b) => a + b) / alignment.timingErrors.length,
      'average_pitch_error': alignment.pitchErrors.isEmpty ? 0.0 :
          alignment.pitchErrors.map((e) => e.centsDifference).reduce((a, b) => a + b) / alignment.pitchErrors.length,
    };
  }
}