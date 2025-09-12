import 'dart:typed_data';
import 'dart:math' as math;
import '../core/audio/formant_analyzer.dart';
import '../core/audio/pitch_frame.dart';

/// 포먼트 분석 서비스
/// 
/// HaneulTone v1 고도화 - 모음 안정성 피드백
/// 
/// Features:
/// - 실시간 포먼트 분석
/// - 모음 안정성 모니터링
/// - 발음 개선 피드백
/// - 포먼트 변화 트래킹
class FormantAnalysisService {
  final FormantAnalyzer _analyzer;
  final int _sampleRate;
  
  /// 포먼트 히스토리 (시간별 추적용)
  final List<FormantFrame> _formantHistory = [];
  
  /// 최대 히스토리 길이 (메모리 관리용)
  static const int _maxHistoryLength = 300; // ~30초 (100ms 간격)
  
  /// 안정성 임계값
  static const double _stabilityThreshold = 0.7;

  FormantAnalysisService({required int sampleRate}) 
    : _sampleRate = sampleRate,
      _analyzer = FormantAnalyzer(sampleRate: sampleRate);

  /// 오디오 프레임 분석 및 피드백 생성
  /// 
  /// [audioFrame]: 입력 오디오 프레임
  /// [timeMs]: 현재 시간 (밀리초)
  /// [pitchFrame]: 피치 분석 결과 (옵션)
  /// [returns]: 포먼트 분석 결과 및 피드백
  FormantFeedback? analyzeFrame(
    Float32List audioFrame, 
    double timeMs, {
    PitchFrame? pitchFrame,
  }) {
    final result = _analyzer.analyzeFrame(audioFrame);
    if (result == null) {
      return null;
    }
    
    // 포먼트 프레임 생성
    final formantFrame = FormantFrame(
      timeMs: timeMs,
      result: result,
      f0Hz: pitchFrame?.f0Hz ?? 0.0,
    );
    
    // 히스토리에 추가
    _formantHistory.add(formantFrame);
    if (_formantHistory.length > _maxHistoryLength) {
      _formantHistory.removeAt(0);
    }
    
    // 피드백 생성
    return _generateFeedback(formantFrame);
  }

  /// 현재 세션의 모음 안정성 통계
  VowelStabilityStats getSessionStats() {
    if (_formantHistory.isEmpty) {
      return VowelStabilityStats.empty();
    }
    
    // 모음별 그룹화
    final vowelGroups = <VowelClass, List<FormantFrame>>{};
    for (final frame in _formantHistory) {
      final vowel = frame.result.vowelClass;
      vowelGroups.putIfAbsent(vowel, () => []).add(frame);
    }
    
    // 각 모음의 안정성 계산
    final vowelStats = <VowelClass, double>{};
    double overallStability = 0.0;
    int validVowelCount = 0;
    
    for (final entry in vowelGroups.entries) {
      final vowel = entry.key;
      final frames = entry.value;
      
      if (vowel == VowelClass.unknown || frames.length < 3) continue;
      
      final stability = _calculateVowelStability(frames);
      vowelStats[vowel] = stability;
      overallStability += stability;
      validVowelCount++;
    }
    
    if (validVowelCount > 0) {
      overallStability /= validVowelCount;
    }
    
    return VowelStabilityStats(
      overallStability: overallStability,
      vowelStabilities: vowelStats,
      totalFrames: _formantHistory.length,
      analysisTimeMs: _formantHistory.isNotEmpty 
          ? _formantHistory.last.timeMs - _formantHistory.first.timeMs 
          : 0.0,
    );
  }

  /// 특정 모음의 안정성 계산
  double _calculateVowelStability(List<FormantFrame> frames) {
    if (frames.length < 2) return 0.0;
    
    // F1, F2의 변화량 계산
    final f1Values = frames.map((f) => f.result.f1).toList();
    final f2Values = frames.map((f) => f.result.f2).toList();
    
    final f1Stability = _calculateVariabilityScore(f1Values);
    final f2Stability = _calculateVariabilityScore(f2Values);
    
    // 가중 평균 (F2가 더 중요)
    return (f1Stability * 0.4 + f2Stability * 0.6).clamp(0.0, 1.0);
  }

  /// 값들의 변동성 점수 계산
  double _calculateVariabilityScore(List<double> values) {
    if (values.length < 2) return 0.0;
    
    // 평균 계산
    final mean = values.reduce((a, b) => a + b) / values.length;
    
    // 표준편차 계산
    final variance = values
        .map((v) => (v - mean) * (v - mean))
        .reduce((a, b) => a + b) / values.length;
    final stdDev = math.sqrt(variance);
    
    // 변동계수 (CV) 기반 안정성 점수
    final cv = mean > 0 ? stdDev / mean : 1.0;
    
    // 안정성 점수 (낮은 CV = 높은 안정성)
    return (1.0 - cv).clamp(0.0, 1.0);
  }

  /// 피드백 메시지 생성
  FormantFeedback _generateFeedback(FormantFrame currentFrame) {
    final result = currentFrame.result;
    final suggestions = <String>[];
    var severity = FeedbackSeverity.info;
    
    // 기본 포먼트 정보
    final vowelName = _getVowelName(result.vowelClass);
    
    // 안정성 체크
    if (result.stability < _stabilityThreshold) {
      severity = FeedbackSeverity.warning;
      suggestions.add('모음 "$vowelName" 발음을 더 안정적으로 유지해보세요');
      
      if (result.f1 < 300) {
        suggestions.add('입을 조금 더 벌려보세요 (F1 낮음: ${result.f1.toInt()}Hz)');
      } else if (result.f1 > 800) {
        suggestions.add('입을 조금 덜 벌려보세요 (F1 높음: ${result.f1.toInt()}Hz)');
      }
      
      if (result.f2 < 1000) {
        suggestions.add('혀를 앞쪽으로 더 보내보세요 (F2 낮음: ${result.f2.toInt()}Hz)');
      } else if (result.f2 > 2800) {
        suggestions.add('혀를 뒤쪽으로 조금 보내보세요 (F2 높음: ${result.f2.toInt()}Hz)');
      }
    }
    
    // 유성음 체크
    if (result.voicingProbability < 0.5) {
      severity = FeedbackSeverity.warning;
      suggestions.add('성대 진동을 더 확실하게 해보세요');
    }
    
    // LPC 오차 체크
    if (result.lpcError > 0.5) {
      suggestions.add('발음을 더 명확하게 해보세요');
    }
    
    // 긍정적 피드백
    if (result.stability >= _stabilityThreshold && suggestions.isEmpty) {
      severity = FeedbackSeverity.success;
      suggestions.add('훌륭한 "$vowelName" 발음입니다! 👍');
    }
    
    return FormantFeedback(
      vowelClass: result.vowelClass,
      stability: result.stability,
      suggestions: suggestions,
      severity: severity,
      formantValues: FormantValues(
        f1: result.f1,
        f2: result.f2,
        f3: result.f3,
      ),
      confidence: result.voicingProbability,
    );
  }

  /// 모음 이름 반환 (한국어)
  String _getVowelName(VowelClass vowel) {
    switch (vowel) {
      case VowelClass.a: return 'ㅏ';
      case VowelClass.ae: return 'ㅐ';
      case VowelClass.e: return 'ㅔ';
      case VowelClass.i: return 'ㅣ';
      case VowelClass.o: return 'ㅓ';
      case VowelClass.u: return 'ㅜ';
      case VowelClass.high_mid: return '고모음';
      case VowelClass.mid: return '중모음';
      default: return '미분류';
    }
  }

  /// 히스토리 클리어
  void clearHistory() {
    _formantHistory.clear();
  }

  /// 최근 N초간의 모음 분포
  Map<VowelClass, int> getRecentVowelDistribution({double recentSeconds = 5.0}) {
    final cutoffTime = _formantHistory.isNotEmpty 
        ? _formantHistory.last.timeMs - (recentSeconds * 1000)
        : 0.0;
    
    final recentFrames = _formantHistory
        .where((f) => f.timeMs >= cutoffTime)
        .toList();
    
    final distribution = <VowelClass, int>{};
    for (final frame in recentFrames) {
      final vowel = frame.result.vowelClass;
      distribution[vowel] = (distribution[vowel] ?? 0) + 1;
    }
    
    return distribution;
  }
}

/// 포먼트 프레임 (시간 정보 포함)
class FormantFrame {
  final double timeMs;
  final FormantResult result;
  final double f0Hz; // 기본 주파수 (피치와의 연관성)

  const FormantFrame({
    required this.timeMs,
    required this.result,
    required this.f0Hz,
  });
}

/// 포먼트 피드백
class FormantFeedback {
  final VowelClass vowelClass;
  final double stability;
  final List<String> suggestions;
  final FeedbackSeverity severity;
  final FormantValues formantValues;
  final double confidence;

  const FormantFeedback({
    required this.vowelClass,
    required this.stability,
    required this.suggestions,
    required this.severity,
    required this.formantValues,
    required this.confidence,
  });

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'vowelClass': vowelClass.toString(),
      'stability': stability,
      'suggestions': suggestions,
      'severity': severity.toString(),
      'formantValues': formantValues.toJson(),
      'confidence': confidence,
    };
  }
}

/// 포먼트 값들
class FormantValues {
  final double f1;
  final double f2;
  final double f3;

  const FormantValues({
    required this.f1,
    required this.f2,
    required this.f3,
  });

  Map<String, dynamic> toJson() {
    return {'f1': f1, 'f2': f2, 'f3': f3};
  }
}

/// 모음 안정성 통계
class VowelStabilityStats {
  final double overallStability;
  final Map<VowelClass, double> vowelStabilities;
  final int totalFrames;
  final double analysisTimeMs;

  const VowelStabilityStats({
    required this.overallStability,
    required this.vowelStabilities,
    required this.totalFrames,
    required this.analysisTimeMs,
  });

  factory VowelStabilityStats.empty() {
    return const VowelStabilityStats(
      overallStability: 0.0,
      vowelStabilities: {},
      totalFrames: 0,
      analysisTimeMs: 0.0,
    );
  }

  /// 등급 계산 (S, A, B, C, D)
  String get stabilityGrade {
    if (overallStability >= 0.95) return 'S';
    if (overallStability >= 0.85) return 'A';
    if (overallStability >= 0.75) return 'B';
    if (overallStability >= 0.65) return 'C';
    return 'D';
  }
}

/// 피드백 심각도
enum FeedbackSeverity {
  info,     // 정보
  success,  // 성공
  warning,  // 경고
  error,    // 오류
}