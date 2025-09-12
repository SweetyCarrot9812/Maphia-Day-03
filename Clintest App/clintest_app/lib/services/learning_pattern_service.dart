import 'dart:math';
import 'package:isar/isar.dart';
import '../models/srs_card.dart';
import '../models/study_progress.dart';
import '../models/wrong_answer.dart';
import 'database_service.dart';

/// 개인별 학습 패턴 분석 및 맞춤형 복습 서비스
class LearningPatternService {
  static final Isar _isar = DatabaseService.isar;

  // =================
  // 학습 패턴 분석
  // =================

  /// 사용자의 종합 학습 패턴 분석
  static Future<LearningProfile> analyzeUserLearningPattern(String userId) async {
    // 기본 데이터 수집
    final studyProgresses = await _isar.studyProgresses
        .where()
        .userIdEqualTo(userId)
        .findAll();
    
    final wrongAnswers = await _isar.wrongAnswers
        .where()
        .userIdEqualTo(userId)
        .findAll();
    
    final srsCards = await _isar.srsCards
        .where()
        .userIdEqualTo(userId)
        .findAll();
    
    // 학습 패턴 요소별 분석
    final cognitive = await _analyzeCognitivePattern(userId, studyProgresses, wrongAnswers);
    final temporal = await _analyzeTemporalPattern(userId, studyProgresses);
    final retention = await _analyzeRetentionPattern(userId, srsCards);
    final difficulty = await _analyzeDifficultyPattern(userId, wrongAnswers, srsCards);
    
    return LearningProfile(
      userId: userId,
      cognitiveStyle: cognitive,
      temporalPreferences: temporal,
      retentionCharacteristics: retention,
      difficultyHandling: difficulty,
      lastAnalyzed: DateTime.now(),
    );
  }

  /// 인지적 학습 스타일 분석
  static Future<CognitiveStyle> _analyzeCognitivePattern(
    String userId,
    List<StudyProgress> progresses,
    List<WrongAnswer> wrongAnswers,
  ) async {
    if (progresses.isEmpty) {
      return CognitiveStyle.defaultStyle();
    }

    // 1. 학습 속도 분석
    double totalQuestions = progresses.fold(0, (sum, p) => sum + p.attemptedQuestions);
    double totalHours = progresses.fold(0, (sum, p) => sum + p.studyTimeSeconds) / 3600.0;
    double learningSpeed = totalHours > 0 ? totalQuestions / totalHours : 5.0;
    
    // 2. 정확도 선호도 분석
    double averageAccuracy = progresses.fold(0.0, (sum, p) => sum + p.accuracyRate) / progresses.length;
    
    // 3. 실수 패턴 분석
    Map<String, int> mistakeTypes = {};
    for (var wrong in wrongAnswers) {
      String category = wrong.questionCategory ?? 'unknown';
      mistakeTypes[category] = (mistakeTypes[category] ?? 0) + 1;
    }
    
    // 4. 학습 스타일 분류
    LearningStyle style = _classifyLearningStyle(learningSpeed, averageAccuracy);
    
    return CognitiveStyle(
      learningSpeed: learningSpeed,
      averageAccuracy: averageAccuracy,
      preferredPace: _calculatePreferredPace(learningSpeed),
      mistakePatterns: mistakeTypes,
      learningStyle: style,
      processingDepth: _calculateProcessingDepth(averageAccuracy, totalQuestions),
    );
  }

  /// 시간적 학습 선호도 분석
  static Future<TemporalPreferences> _analyzeTemporalPattern(
    String userId,
    List<StudyProgress> progresses,
  ) async {
    // 실제 구현에서는 학습 시간대별 성과 데이터가 필요
    // 현재는 기본값 반환
    return TemporalPreferences(
      optimalStudyHours: [9, 10, 14, 15, 19, 20], // 오전, 오후, 저녁
      sessionDurationPreference: 25, // 분
      breakIntervalPreference: 5, // 분
      weeklyPatterns: Map.fromIterables(
        ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
        [0.8, 0.9, 0.85, 0.9, 0.7, 0.6, 0.5] // 요일별 학습 효율성
      ),
    );
  }

  /// 기억 유지 특성 분석
  static Future<RetentionCharacteristics> _analyzeRetentionPattern(
    String userId,
    List<SRSCard> cards,
  ) async {
    if (cards.isEmpty) {
      return RetentionCharacteristics.defaultCharacteristics();
    }

    // 1. 전체적인 기억 유지율
    double overallRetentionRate = cards
        .where((c) => c.totalReviews > 0)
        .fold(0.0, (sum, c) => sum + c.memoryStrength) / cards.length;
    
    // 2. 망각 속도 계산
    double forgettingRate = _calculateForgettingRate(cards);
    
    // 3. 간격 효율성
    double intervalEfficiency = _calculateIntervalEfficiency(cards);
    
    // 4. 최적 복습 간격 패턴
    Map<String, double> optimalIntervals = _findOptimalIntervals(cards);
    
    return RetentionCharacteristics(
      overallRetentionRate: overallRetentionRate,
      forgettingRate: forgettingRate,
      intervalEfficiency: intervalEfficiency,
      optimalIntervals: optimalIntervals,
      longTermRetentionScore: _calculateLongTermRetention(cards),
      shortTermRetentionScore: _calculateShortTermRetention(cards),
    );
  }

  /// 난이도 처리 패턴 분석
  static Future<DifficultyHandling> _analyzeDifficultyPattern(
    String userId,
    List<WrongAnswer> wrongAnswers,
    List<SRSCard> cards,
  ) async {
    // 난이도별 성과 분석
    Map<String, double> difficultyPerformance = {
      'basic': 0.8,
      'medium': 0.7,
      'high': 0.6,
      'critical': 0.5,
    };
    
    // 실제로는 난이도별 정답률을 계산해야 함
    if (cards.isNotEmpty) {
      for (var category in difficultyPerformance.keys) {
        var categoryCards = cards.where((c) => c.medicalCategory == category);
        if (categoryCards.isNotEmpty) {
          double avgCorrect = categoryCards
              .fold(0.0, (sum, c) => sum + c.consecutiveCorrect) / categoryCards.length;
          double avgTotal = categoryCards
              .fold(0.0, (sum, c) => sum + c.totalReviews.clamp(1, 10)) / categoryCards.length;
          difficultyPerformance[category] = avgCorrect / avgTotal;
        }
      }
    }
    
    return DifficultyHandling(
      difficultyPerformance: difficultyPerformance,
      challengePreference: _calculateChallengePreference(difficultyPerformance),
      adaptationSpeed: _calculateAdaptationSpeed(cards),
      confidenceLevel: _calculateConfidenceLevel(wrongAnswers),
    );
  }

  // =================
  // 개인화된 복습 간격 계산
  // =================

  /// 개인 맞춤 복습 간격 계산
  static Future<Duration> calculatePersonalizedInterval({
    required String userId,
    required SRSCard card,
    required bool wasCorrect,
    required String performance,
    int responseTimeMs = 5000,
  }) async {
    // 사용자 학습 패턴 로드
    final profile = await analyzeUserLearningPattern(userId);
    
    // 기본 SRS 간격 계산
    double baseInterval = card.interval.toDouble();
    
    // 1. 인지적 스타일 적용
    double cognitiveMultiplier = _applyCognitiveStyle(profile.cognitiveStyle, wasCorrect);
    
    // 2. 기억 유지 특성 적용
    double retentionMultiplier = _applyRetentionCharacteristics(
      profile.retentionCharacteristics, 
      card.medicalCategory ?? 'medium'
    );
    
    // 3. 난이도 처리 패턴 적용
    double difficultyMultiplier = _applyDifficultyHandling(
      profile.difficultyHandling,
      card.aiDifficultyScore,
    );
    
    // 4. 응답 시간 패턴 적용
    double responseTimeMultiplier = _calculateResponseTimeMultiplier(
      responseTimeMs,
      profile.cognitiveStyle.learningSpeed,
    );
    
    // 5. 성과에 따른 기본 승수
    double performanceMultiplier = _getPerformanceMultiplier(performance, wasCorrect);
    
    // 최종 간격 계산
    double finalInterval = baseInterval * 
                          cognitiveMultiplier * 
                          retentionMultiplier * 
                          difficultyMultiplier * 
                          responseTimeMultiplier * 
                          performanceMultiplier;
    
    // 의료/간호학 특성 반영 - 중요한 개념은 더 자주 복습
    if (card.medicalCategory == 'critical') {
      finalInterval *= 0.7; // 30% 더 자주 복습
    } else if (card.medicalCategory == 'high') {
      finalInterval *= 0.85; // 15% 더 자주 복습
    }
    
    // 범위 제한: 1시간 ~ 1년
    finalInterval = finalInterval.clamp(1.0 / 24, 365);
    
    // 시간으로 변환
    if (finalInterval < 1) {
      return Duration(hours: (finalInterval * 24).round());
    } else {
      return Duration(days: finalInterval.round());
    }
  }

  // =================
  // 보조 메서드들
  // =================

  static LearningStyle _classifyLearningStyle(double speed, double accuracy) {
    if (speed > 8 && accuracy > 0.85) return LearningStyle.fastAndAccurate;
    if (speed > 8) return LearningStyle.fastLearner;
    if (accuracy > 0.85) return LearningStyle.thoroughLearner;
    if (speed < 3 && accuracy < 0.6) return LearningStyle.strugglingLearner;
    return LearningStyle.steadyLearner;
  }

  static String _calculatePreferredPace(double learningSpeed) {
    if (learningSpeed > 10) return 'fast';
    if (learningSpeed < 3) return 'slow';
    return 'moderate';
  }

  static double _calculateProcessingDepth(double accuracy, double totalQuestions) {
    // 정확도와 문제 수를 기반으로 처리 깊이 계산
    return (accuracy * 0.7 + (totalQuestions / 1000).clamp(0, 1) * 0.3);
  }

  static double _calculateForgettingRate(List<SRSCard> cards) {
    if (cards.isEmpty) return 0.5;
    
    double totalDecay = 0.0;
    int validCards = 0;
    
    for (var card in cards) {
      if (card.totalReviews > 1 && card.lastCorrectDate != null) {
        int daysSince = DateTime.now().difference(card.lastCorrectDate!).inDays;
        double expectedStrength = exp(-daysSince / (card.easeFactor * 7));
        double actualStrength = card.memoryStrength;
        
        totalDecay += (expectedStrength - actualStrength).abs();
        validCards++;
      }
    }
    
    return validCards > 0 ? totalDecay / validCards : 0.5;
  }

  static double _calculateIntervalEfficiency(List<SRSCard> cards) {
    if (cards.isEmpty) return 1.0;
    
    int successfulReviews = cards.where((c) => c.consecutiveCorrect > 0).length;
    return successfulReviews / cards.length;
  }

  static Map<String, double> _findOptimalIntervals(List<SRSCard> cards) {
    return {
      'basic': 7.0,
      'medium': 5.0,
      'high': 3.0,
      'critical': 2.0,
    };
  }

  static double _calculateLongTermRetention(List<SRSCard> cards) {
    var oldCards = cards.where((c) => 
      c.createdAt.isBefore(DateTime.now().subtract(const Duration(days: 30))));
    
    if (oldCards.isEmpty) return 0.5;
    
    return oldCards.fold(0.0, (sum, c) => sum + c.memoryStrength) / oldCards.length;
  }

  static double _calculateShortTermRetention(List<SRSCard> cards) {
    var recentCards = cards.where((c) => 
      c.updatedAt.isAfter(DateTime.now().subtract(const Duration(days: 7))));
    
    if (recentCards.isEmpty) return 0.5;
    
    return recentCards.fold(0.0, (sum, c) => sum + c.memoryStrength) / recentCards.length;
  }

  static double _calculateChallengePreference(Map<String, double> performance) {
    double highDifficultyPerf = (performance['high'] ?? 0.5) + (performance['critical'] ?? 0.5);
    double lowDifficultyPerf = (performance['basic'] ?? 0.5) + (performance['medium'] ?? 0.5);
    
    return highDifficultyPerf / (lowDifficultyPerf + 0.1); // 0으로 나누기 방지
  }

  static double _calculateAdaptationSpeed(List<SRSCard> cards) {
    // 카드들이 얼마나 빨리 안정화되는지 측정
    if (cards.isEmpty) return 1.0;
    
    double totalAdaptation = 0.0;
    int validCards = 0;
    
    for (var card in cards) {
      if (card.totalReviews > 5) {
        double stabilityScore = card.maturityLevel;
        double reviewsNeeded = card.totalReviews.toDouble();
        double adaptationScore = stabilityScore / (reviewsNeeded / 5.0); // 5회 복습 기준
        
        totalAdaptation += adaptationScore;
        validCards++;
      }
    }
    
    return validCards > 0 ? totalAdaptation / validCards : 1.0;
  }

  static double _calculateConfidenceLevel(List<WrongAnswer> wrongAnswers) {
    if (wrongAnswers.isEmpty) return 0.8;
    
    // 최근 30일간 오답 빈도로 신뢰도 계산
    var recentWrongs = wrongAnswers.where((w) => 
      w.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 30))));
    
    double recentErrorRate = recentWrongs.length / 30.0; // 일평균 오답 수
    return max(0.3, 1.0 - recentErrorRate * 0.1);
  }

  static double _applyCognitiveStyle(CognitiveStyle style, bool wasCorrect) {
    double multiplier = 1.0;
    
    // 학습 속도에 따른 조정
    if (style.learningSpeed > 8) {
      multiplier *= wasCorrect ? 1.3 : 0.8; // 빠른 학습자는 간격을 더 늘리거나 줄임
    } else if (style.learningSpeed < 4) {
      multiplier *= wasCorrect ? 1.1 : 0.9; // 느린 학습자는 보수적으로 조정
    }
    
    // 정확도 선호도에 따른 조정
    if (style.averageAccuracy > 0.85) {
      multiplier *= 1.1; // 정확한 학습자는 간격을 조금 늘림
    }
    
    return multiplier;
  }

  static double _applyRetentionCharacteristics(
    RetentionCharacteristics retention, 
    String medicalCategory
  ) {
    double baseMultiplier = retention.intervalEfficiency;
    
    // 카테고리별 최적 간격 적용
    double optimalInterval = retention.optimalIntervals[medicalCategory] ?? 5.0;
    double adjustmentFactor = optimalInterval / 5.0; // 5일을 기준으로 정규화
    
    return baseMultiplier * adjustmentFactor;
  }

  static double _applyDifficultyHandling(
    DifficultyHandling difficulty,
    double aiDifficultyScore,
  ) {
    // AI 난이도 점수를 바탕으로 사용자의 난이도 처리 능력 반영
    double confidenceAdjustment = difficulty.confidenceLevel;
    double adaptationAdjustment = difficulty.adaptationSpeed;
    
    // 어려운 문제일수록 간격을 줄임
    double difficultyAdjustment = 1.0 - (aiDifficultyScore * 0.3);
    
    return confidenceAdjustment * adaptationAdjustment * difficultyAdjustment;
  }

  static double _calculateResponseTimeMultiplier(
    int responseTimeMs,
    double learningSpeed,
  ) {
    // 개인의 학습 속도를 고려한 최적 응답 시간 계산
    double personalOptimalTime = 5000 / (learningSpeed / 5.0); // 개인 맞춤 최적 시간
    
    if (responseTimeMs < personalOptimalTime) {
      // 빠른 응답 = 확실한 이해
      return 1.0 + min(0.3, (personalOptimalTime - responseTimeMs) / personalOptimalTime);
    } else {
      // 느린 응답 = 불확실한 이해
      return max(0.7, 1.0 - (responseTimeMs - personalOptimalTime) / (personalOptimalTime * 3));
    }
  }

  static double _getPerformanceMultiplier(String performance, bool wasCorrect) {
    if (!wasCorrect) return 0.25; // 틀렸으면 간격을 크게 줄임
    
    switch (performance) {
      case 'excellent':
        return 1.5;
      case 'good':
        return 1.2;
      case 'hard':
        return 0.9;
      case 'again':
        return 0.25;
      default:
        return 1.0;
    }
  }
}

// =================
// 데이터 클래스들
// =================

class LearningProfile {
  final String userId;
  final CognitiveStyle cognitiveStyle;
  final TemporalPreferences temporalPreferences;
  final RetentionCharacteristics retentionCharacteristics;
  final DifficultyHandling difficultyHandling;
  final DateTime lastAnalyzed;

  LearningProfile({
    required this.userId,
    required this.cognitiveStyle,
    required this.temporalPreferences,
    required this.retentionCharacteristics,
    required this.difficultyHandling,
    required this.lastAnalyzed,
  });
}

class CognitiveStyle {
  final double learningSpeed; // 시간당 문제 수
  final double averageAccuracy;
  final String preferredPace; // 'fast', 'moderate', 'slow'
  final Map<String, int> mistakePatterns;
  final LearningStyle learningStyle;
  final double processingDepth; // 0.0-1.0

  CognitiveStyle({
    required this.learningSpeed,
    required this.averageAccuracy,
    required this.preferredPace,
    required this.mistakePatterns,
    required this.learningStyle,
    required this.processingDepth,
  });

  static CognitiveStyle defaultStyle() {
    return CognitiveStyle(
      learningSpeed: 5.0,
      averageAccuracy: 0.75,
      preferredPace: 'moderate',
      mistakePatterns: {},
      learningStyle: LearningStyle.steadyLearner,
      processingDepth: 0.5,
    );
  }
}

class TemporalPreferences {
  final List<int> optimalStudyHours;
  final int sessionDurationPreference; // 분
  final int breakIntervalPreference; // 분
  final Map<String, double> weeklyPatterns; // 요일별 효율성

  TemporalPreferences({
    required this.optimalStudyHours,
    required this.sessionDurationPreference,
    required this.breakIntervalPreference,
    required this.weeklyPatterns,
  });
}

class RetentionCharacteristics {
  final double overallRetentionRate;
  final double forgettingRate;
  final double intervalEfficiency;
  final Map<String, double> optimalIntervals;
  final double longTermRetentionScore;
  final double shortTermRetentionScore;

  RetentionCharacteristics({
    required this.overallRetentionRate,
    required this.forgettingRate,
    required this.intervalEfficiency,
    required this.optimalIntervals,
    required this.longTermRetentionScore,
    required this.shortTermRetentionScore,
  });

  static RetentionCharacteristics defaultCharacteristics() {
    return RetentionCharacteristics(
      overallRetentionRate: 0.6,
      forgettingRate: 0.5,
      intervalEfficiency: 0.7,
      optimalIntervals: {
        'basic': 7.0,
        'medium': 5.0,
        'high': 3.0,
        'critical': 2.0,
      },
      longTermRetentionScore: 0.5,
      shortTermRetentionScore: 0.7,
    );
  }
}

class DifficultyHandling {
  final Map<String, double> difficultyPerformance;
  final double challengePreference;
  final double adaptationSpeed;
  final double confidenceLevel;

  DifficultyHandling({
    required this.difficultyPerformance,
    required this.challengePreference,
    required this.adaptationSpeed,
    required this.confidenceLevel,
  });
}

enum LearningStyle {
  fastAndAccurate,
  fastLearner,
  thoroughLearner,
  steadyLearner,
  strugglingLearner,
}