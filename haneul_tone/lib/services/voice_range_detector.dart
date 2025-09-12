import 'dart:math' as math;
import '../utils/note_utils.dart';
import '../models/session.dart';
import '../models/vocal_types.dart';

/// 음역대 샘플 데이터
class VoiceRangeSample {
  final double frequency;
  final double confidence;
  final DateTime timestamp;
  final String note;
  
  VoiceRangeSample({
    required this.frequency,
    required this.confidence,
    required this.timestamp,
    required this.note,
  });
}

/// 음역대 분석 결과
class VoiceRangeAnalysis {
  final double lowestFreq;
  final double highestFreq;
  final String lowestNote;
  final String highestNote;
  final double comfortableRangeStart;
  final double comfortableRangeEnd;
  final String suggestedKey;
  final double confidence;
  final int octaveRange;
  final VoiceType voiceType;
  
  VoiceRangeAnalysis({
    required this.lowestFreq,
    required this.highestFreq,
    required this.lowestNote,
    required this.highestNote,
    required this.comfortableRangeStart,
    required this.comfortableRangeEnd,
    required this.suggestedKey,
    required this.confidence,
    required this.octaveRange,
    required this.voiceType,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'lowest_freq': lowestFreq,
      'highest_freq': highestFreq,
      'lowest_note': lowestNote,
      'highest_note': highestNote,
      'comfortable_range_start': comfortableRangeStart,
      'comfortable_range_end': comfortableRangeStart,
      'suggested_key': suggestedKey,
      'confidence': confidence,
      'octave_range': octaveRange,
      'voice_type': voiceType.toString(),
    };
  }
  
  Map<String, dynamic> toJson() => toMap();
}

// Backward compatibility typedef
typedef VoiceRangeAnalysisResult = VoiceRangeAnalysis;

/// 사용자 음역대 자동 감지 시스템
class VoiceRangeDetector {
  static const int minSamples = 50; // 최소 샘플 수
  static const double confidenceThreshold = 0.7; // 신뢰도 임계값
  static const double stabilityThreshold = 5.0; // 안정성 임계값 (cents)
  
  final List<VoiceRangeSample> _samples = [];

  /// 피치 샘플 추가
  void addSample({
    required double frequency,
    required double confidence,
    required String note,
  }) {
    if (frequency < 80 || frequency > 2000) return; // 보컬 범위 외
    if (confidence < confidenceThreshold) return; // 신뢰도 부족
    
    final sample = VoiceRangeSample(
      frequency: frequency,
      confidence: confidence,
      timestamp: DateTime.now(),
      note: note,
    );
    
    _samples.add(sample);
    
    // 메모리 관리 - 최대 1000개 샘플 유지
    if (_samples.length > 1000) {
      _samples.removeAt(0);
    }
  }

  /// 음역대 분석 수행
  VoiceRangeAnalysis? analyzeVoiceRange() {
    if (_samples.length < minSamples) return null;
    
    // 신뢰할 수 있는 샘플만 사용
    final reliableSamples = _samples
        .where((s) => s.confidence >= confidenceThreshold)
        .toList();
    
    if (reliableSamples.length < minSamples) return null;
    
    // 주파수 정렬
    reliableSamples.sort((a, b) => a.frequency.compareTo(b.frequency));
    
    // 기본 범위 계산
    final lowestFreq = reliableSamples.first.frequency;
    final highestFreq = reliableSamples.last.frequency;
    
    // 안정적인 범위 계산 (5%-95% 백분위수)
    final lowerIndex = (reliableSamples.length * 0.05).floor();
    final upperIndex = (reliableSamples.length * 0.95).ceil() - 1;
    
    final stableLowFreq = reliableSamples[lowerIndex].frequency;
    final stableHighFreq = reliableSamples[upperIndex].frequency;
    
    // 편안한 범위 계산 (25%-75% 백분위수)
    final comfortLowerIndex = (reliableSamples.length * 0.25).floor();
    final comfortUpperIndex = (reliableSamples.length * 0.75).ceil() - 1;
    
    final comfortableRangeStart = reliableSamples[comfortLowerIndex].frequency;
    final comfortableRangeEnd = reliableSamples[comfortUpperIndex].frequency;
    
    // 음표 변환
    final lowestNote = NoteUtils.frequencyToNote(stableLowFreq);
    final highestNote = NoteUtils.frequencyToNote(stableHighFreq);
    
    // 음성 타입 분류
    final voiceType = _classifyVoiceType(stableLowFreq, stableHighFreq);
    
    // 옥타브 범위 계산
    final octaveRange = _calculateOctaveRange(stableLowFreq, stableHighFreq);
    
    // 권장 키 계산
    final suggestedKey = _calculateSuggestedKey(comfortableRangeStart, comfortableRangeEnd);
    
    // 분석 신뢰도 계산
    final confidence = _calculateAnalysisConfidence(reliableSamples);
    
    return VoiceRangeAnalysis(
      lowestFreq: stableLowFreq,
      highestFreq: stableHighFreq,
      lowestNote: lowestNote,
      highestNote: highestNote,
      comfortableRangeStart: comfortableRangeStart,
      comfortableRangeEnd: comfortableRangeEnd,
      suggestedKey: suggestedKey,
      confidence: confidence,
      octaveRange: octaveRange,
      voiceType: voiceType,
    );
  }

  /// 음성 타입 분류
  VoiceType _classifyVoiceType(double lowFreq, double highFreq) {
    // MIDI 노트 번호로 변환 (A4 = 440Hz = MIDI 69)
    final lowMidi = _frequencyToMidi(lowFreq);
    final highMidi = _frequencyToMidi(highFreq);
    
    // 각 음성 타입의 일반적인 범위 (MIDI 번호)
    const voiceRanges = {
      VoiceType.soprano: {'low': 60, 'high': 84},      // C4-C6
      VoiceType.mezzSoprano: {'low': 57, 'high': 81},  // A3-A5
      VoiceType.alto: {'low': 55, 'high': 79},         // G3-G5
      VoiceType.tenor: {'low': 48, 'high': 72},        // C3-C5
      VoiceType.baritone: {'low': 45, 'high': 69},     // A2-A4
      VoiceType.bass: {'low': 40, 'high': 64},         // E2-E4
    };
    
    // 가장 잘 맞는 음성 타입 찾기
    double bestMatch = double.infinity;
    VoiceType bestType = VoiceType.unknown;
    
    for (final entry in voiceRanges.entries) {
      final rangeLow = entry.value['low']!.toDouble();
      final rangeHigh = entry.value['high']!.toDouble();
      
      // 범위 중앙값과의 거리 계산
      final userCenter = (lowMidi + highMidi) / 2;
      final typeCenter = (rangeLow + rangeHigh) / 2;
      final distance = (userCenter - typeCenter).abs();
      
      // 범위 겹침 확인
      final overlapStart = math.max(lowMidi, rangeLow);
      final overlapEnd = math.min(highMidi, rangeHigh);
      final overlapRatio = math.max(0, overlapEnd - overlapStart) / (highMidi - lowMidi);
      
      // 점수 계산 (겹침 비율이 높고 중심 거리가 가까울수록 좋음)
      final score = distance - (overlapRatio * 20);
      
      if (score < bestMatch && overlapRatio > 0.3) {
        bestMatch = score;
        bestType = entry.key;
      }
    }
    
    return bestType;
  }

  /// 옥타브 범위 계산
  int _calculateOctaveRange(double lowFreq, double highFreq) {
    final lowMidi = _frequencyToMidi(lowFreq);
    final highMidi = _frequencyToMidi(highFreq);
    
    return ((highMidi - lowMidi) / 12).ceil();
  }

  /// 권장 키 계산
  String _calculateSuggestedKey(double comfortLowFreq, double comfortHighFreq) {
    // 편안한 범위의 중앙값 계산
    final centerFreq = math.sqrt(comfortLowFreq * comfortHighFreq);
    final centerNote = NoteUtils.frequencyToNote(centerFreq);
    
    // 메이저 키로 변환 (단순화)
    final noteOnly = centerNote.replaceAll(RegExp(r'\d'), '');
    return '${noteOnly} Major';
  }

  /// 분석 신뢰도 계산
  double _calculateAnalysisConfidence(List<VoiceRangeSample> samples) {
    if (samples.isEmpty) return 0.0;
    
    // 샘플 수 기반 신뢰도
    final sampleConfidence = math.min(samples.length / 200.0, 1.0);
    
    // 평균 신뢰도
    final avgConfidence = samples
        .map((s) => s.confidence)
        .reduce((a, b) => a + b) / samples.length;
    
    // 주파수 안정성 (변산성이 낮을수록 신뢰도 높음)
    final frequencies = samples.map((s) => s.frequency).toList();
    final mean = frequencies.reduce((a, b) => a + b) / frequencies.length;
    final variance = frequencies
        .map((f) => math.pow(f - mean, 2))
        .reduce((a, b) => a + b) / frequencies.length;
    final stabilityConfidence = 1.0 - math.min(variance / (mean * mean), 1.0);
    
    // 최종 신뢰도 (가중 평균)
    return (sampleConfidence * 0.3 + avgConfidence * 0.4 + stabilityConfidence * 0.3)
        .clamp(0.0, 1.0);
  }

  /// 주파수를 MIDI 번호로 변환
  double _frequencyToMidi(double frequency) {
    return 69 + 12 * math.log(frequency / 440) / math.ln2;
  }

  /// 개인화된 연습 추천
  List<String> getPersonalizedRecommendations(VoiceRangeAnalysis analysis) {
    final recommendations = <String>[];
    
    // 음성 타입별 추천
    switch (analysis.voiceType) {
      case VoiceType.soprano:
        recommendations.add('고음 연습에 집중하세요. 헤드 보이스 개발이 중요합니다.');
        recommendations.add('브레스 컨트롤 연습으로 긴 프레이즈를 안정적으로 불러보세요.');
        break;
      case VoiceType.tenor:
        recommendations.add('중고음 전환(패시지오) 연습이 도움될 것입니다.');
        recommendations.add('믹스 보이스 개발로 자연스러운 고음을 만들어보세요.');
        break;
      case VoiceType.alto:
      case VoiceType.mezzSoprano:
        recommendations.add('중음역대의 풍부한 톤을 개발해보세요.');
        recommendations.add('저음과 고음의 연결 연습이 중요합니다.');
        break;
      case VoiceType.baritone:
      case VoiceType.bass:
        recommendations.add('깊고 풍부한 저음을 개발해보세요.');
        recommendations.add('중음역대로의 스무스한 전환 연습이 필요합니다.');
        break;
      case VoiceType.unknown:
        recommendations.add('더 많은 연습을 통해 음역대를 파악해보세요.');
        break;
    }
    
    // 음역대 범위별 추천
    if (analysis.octaveRange < 2) {
      recommendations.add('음역대 확장 연습이 필요합니다. 스케일 연습부터 시작해보세요.');
    } else if (analysis.octaveRange >= 3) {
      recommendations.add('훌륭한 음역대를 가지고 있습니다! 표현력 개발에 집중해보세요.');
    }
    
    // 신뢰도별 추천
    if (analysis.confidence < 0.7) {
      recommendations.add('더 많은 연습을 통해 안정적인 발성을 개발해보세요.');
    }
    
    return recommendations;
  }

  /// 현재 샘플 수
  int get sampleCount => _samples.length;
  
  /// 분석 준비 여부
  bool get isReadyForAnalysis => _samples.length >= minSamples;
  
  /// 샘플 초기화
  void clearSamples() {
    _samples.clear();
  }
  
  /// 최근 샘플들의 통계
  Map<String, dynamic> getRecentStats() {
    if (_samples.isEmpty) return {};
    
    final recent = _samples.length >= 20 
        ? _samples.sublist(_samples.length - 20)
        : _samples;
    
    final frequencies = recent.map((s) => s.frequency).toList();
    final avgFreq = frequencies.reduce((a, b) => a + b) / frequencies.length;
    final avgConfidence = recent
        .map((s) => s.confidence)
        .reduce((a, b) => a + b) / recent.length;
    
    return {
      'recent_samples': recent.length,
      'avg_frequency': avgFreq,
      'avg_confidence': avgConfidence,
      'current_note': NoteUtils.frequencyToNote(avgFreq),
    };
  }
}