import 'dart:math';
import 'package:isar/isar.dart';
import '../models/srs_card.dart';
import '../models/study_progress.dart';
import 'database_service.dart';

/// 고급 SRS 서비스 - 망각 곡선 기반 개인화된 복습 시스템
class AdvancedSRSService {
  static final Isar _isar = DatabaseService.isar;

  // 망각 곡선 매개변수
  static const double _forgettingCurveDecayRate = 0.3; // 망각 속도
  static const double _learningCurveMultiplier = 1.2; // 학습 효율성
  
  // 의료/간호학 특화 매개변수
  static const Map<String, double> _medicalImportanceWeights = {
    'critical': 2.0,    // 생명과 직결되는 중요 개념
    'high': 1.5,        // 임상에서 자주 사용되는 개념
    'medium': 1.0,      // 일반적인 의료 지식
    'basic': 0.8,       // 기초 이론
  };

  // =================
  // 핵심 알고리즘 메서드
  // =================

  /// 망각 곡선 기반 복습 간격 계산
  /// 
  /// 에빙하우스 망각 곡선 공식: R = e^(-t/s)
  /// R: 기억 유지율, t: 시간, s: 기억 강도
  static Duration calculateOptimalInterval({
    required SRSCard card,
    required bool wasCorrect,
    required int responseTime,
    required String questionDifficulty,
  }) {
    // 1. 기본 간격 계산 (현재 간격 기반)
    double baseInterval = card.interval.toDouble();
    
    // 2. 망각 곡선 적용
    double forgettingFactor = _calculateForgettingFactor(card);
    
    // 3. 개인 학습 패턴 적용
    double personalFactor = _calculatePersonalLearningFactor(card);
    
    // 4. 문제 난이도/중요도 적용
    double difficultyFactor = _calculateDifficultyFactor(questionDifficulty);
    
    // 5. 응답 시간 반영
    double responseTimeFactor = _calculateResponseTimeFactor(responseTime);
    
    // 6. 정답/오답에 따른 조정
    double correctnessFactor = wasCorrect ? 1.3 : 0.3;
    
    // 최종 간격 계산
    double newInterval = baseInterval * 
                        forgettingFactor * 
                        personalFactor * 
                        difficultyFactor * 
                        responseTimeFactor * 
                        correctnessFactor;
    
    // 최소/최대 간격 제한
    newInterval = max(1, min(newInterval, 365)); // 1일 ~ 1년
    
    return Duration(days: newInterval.round());
  }

  /// 망각 곡선 팩터 계산
  static double _calculateForgettingFactor(SRSCard card) {
    // 연속 정답 횟수에 따른 기억 강도
    double memoryStrength = 1 + (card.consecutiveCorrect * 0.2);
    
    // 총 복습 횟수에 따른 안정성
    double stability = 1 + (card.totalReviews * 0.1);
    
    // 망각 곡선 적용
    double forgettingRate = _forgettingCurveDecayRate / (memoryStrength * stability);
    
    return exp(-forgettingRate);
  }

  /// 개인 학습 패턴 팩터 계산
  static double _calculatePersonalLearningFactor(SRSCard card) {
    // AI 난이도 점수 반영 (개인의 이해도)
    double comprehensionLevel = 1 - card.aiDifficultyScore;
    
    // 개인 ease factor 반영
    double personalEase = card.easeFactor / 2.5; // 표준 ease factor로 정규화
    
    return (comprehensionLevel + personalEase) / 2;
  }

  /// 문제 난이도/중요도 팩터 계산
  static double _calculateDifficultyFactor(String difficulty) {
    return _medicalImportanceWeights[difficulty.toLowerCase()] ?? 1.0;
  }

  /// 응답 시간 팩터 계산
  static double _calculateResponseTimeFactor(int responseTimeMs) {
    // 빠른 응답 = 확실한 이해 = 간격 증가
    // 느린 응답 = 불확실한 이해 = 간격 감소
    
    const int optimalTime = 3000; // 3초가 최적
    const int maxTime = 30000;    // 30초 이상은 모두 동일하게 처리
    
    if (responseTimeMs <= optimalTime) {
      // 빠른 응답: 1.0 ~ 1.2
      return 1.0 + (0.2 * (optimalTime - responseTimeMs) / optimalTime);
    } else {
      // 느린 응답: 0.7 ~ 1.0
      int adjustedTime = min(responseTimeMs, maxTime);
      return 1.0 - (0.3 * (adjustedTime - optimalTime) / (maxTime - optimalTime));
    }
  }

  // =================
  // 개인화 메서드
  // =================

  /// 사용자별 학습 패턴 분석
  static Future<Map<String, double>> analyzeUserLearningPattern(String userId) async {
    final studyProgresses = await _isar.studyProgresses
        .where()
        .userIdEqualTo(userId)
        .findAll();
    
    if (studyProgresses.isEmpty) {
      return {
        'averageAccuracy': 0.75, // 기본값
        'learningSpeed': 1.0,
        'retentionRate': 0.8,
        'preferredDifficulty': 1.0,
      };
    }
    
    // 전체 정답률 계산
    double totalAccuracy = studyProgresses
        .map((p) => p.accuracyRate)
        .reduce((a, b) => a + b) / studyProgresses.length;
    
    // 학습 속도 (시간당 문제 수)
    double totalQuestions = studyProgresses
        .map((p) => p.attemptedQuestions)
        .reduce((a, b) => a + b).toDouble();
    double totalHours = studyProgresses
        .map((p) => p.studyTimeSeconds)
        .reduce((a, b) => a + b) / 3600.0;
    
    double learningSpeed = totalHours > 0 ? totalQuestions / totalHours : 1.0;
    
    // 기억 유지율 (연속 학습일 기반)
    double averageStreak = studyProgresses
        .map((p) => p.streakDays)
        .reduce((a, b) => a + b) / studyProgresses.length;
    double retentionRate = min(1.0, averageStreak / 30.0); // 30일 기준
    
    return {
      'averageAccuracy': totalAccuracy,
      'learningSpeed': learningSpeed / 10.0, // 정규화 (시간당 10문제 기준)
      'retentionRate': retentionRate,
      'preferredDifficulty': totalAccuracy > 0.8 ? 1.2 : 0.9,
    };
  }

  /// 과목별 복습 우선순위 계산
  static Future<List<String>> calculateSubjectPriorities(String userId) async {
    final studyProgresses = await _isar.studyProgress
        .where()
        .userIdEqualTo(userId)
        .findAll();
    
    // 정답률이 낮은 과목을 우선으로 정렬
    studyProgresses.sort((a, b) => a.accuracyRate.compareTo(b.accuracyRate));
    
    return studyProgresses.map((p) => p.subjectCode).toList();
  }

  // =================
  // 복습 스케줄링 메서드
  // =================

  /// 오늘 복습할 카드들을 중요도순으로 정렬
  static Future<List<SRSCard>> getTodayReviewCardsOrdered(String userId) async {
    // 기존 SRS 서비스에서 오늘 카드들 가져오기
    final cards = await SRSService().getTodayReviewCards();
    if (cards == null || cards.isEmpty) return [];
    
    // 사용자 학습 패턴 분석
    final userPattern = await analyzeUserLearningPattern(userId);
    final subjectPriorities = await calculateSubjectPriorities(userId);
    
    // 카드별 우선순위 점수 계산
    List<Map<String, dynamic>> cardScores = [];
    
    for (var card in cards) {
      double score = _calculateCardPriority(card, userPattern, subjectPriorities);
      cardScores.add({
        'card': card,
        'score': score,
      });
    }
    
    // 점수 기준 내림차순 정렬
    cardScores.sort((a, b) => b['score'].compareTo(a['score']));
    
    return cardScores.map((item) => item['card'] as SRSCard).toList();
  }

  /// 카드 우선순위 점수 계산
  static double _calculateCardPriority(
    SRSCard card, 
    Map<String, double> userPattern,
    List<String> subjectPriorities,
  ) {
    double score = 0.0;
    
    // 1. 지연된 카드 가중치 (늦을수록 높은 우선순위)
    Duration delay = DateTime.now().difference(card.dueDate);
    if (delay.inDays > 0) {
      score += delay.inDays * 2.0;
    }
    
    // 2. AI 난이도 점수 (어려운 것일수록 높은 우선순위)
    score += card.aiDifficultyScore * 3.0;
    
    // 3. 과목 우선순위 (약한 과목일수록 높은 우선순위)
    // 실제로는 itemId에서 과목 정보를 추출해야 함
    // 여기서는 간단히 처리
    score += 1.0;
    
    // 4. 연속 실패 가중치
    if (card.consecutiveCorrect == 0) {
      score += 2.0;
    }
    
    return score;
  }

  // =================
  // 학습 효과 측정 메서드
  // =================

  /// 복습 효과 측정 및 알고리즘 튜닝
  static Future<Map<String, double>> measureReviewEffectiveness(String userId) async {
    // 최근 30일간의 복습 데이터 분석
    final cards = await _isar.srsCards
        .where()
        .userIdEqualTo(userId)
        .filter()
        .updatedAtGreaterThan(DateTime.now().subtract(const Duration(days: 30)))
        .findAll();
    
    if (cards.isEmpty) return {};
    
    // 복습 성공률 계산
    double successRate = cards
        .where((c) => c.consecutiveCorrect > 0)
        .length / cards.length;
    
    // 평균 복습 간격 계산
    double averageInterval = cards
        .map((c) => c.interval)
        .reduce((a, b) => a + b) / cards.length;
    
    // 기억 유지 효율성 (간격 대비 성공률)
    double retentionEfficiency = successRate / (averageInterval / 7.0); // 주 단위
    
    return {
      'successRate': successRate,
      'averageInterval': averageInterval,
      'retentionEfficiency': retentionEfficiency,
      'totalReviews': cards.length.toDouble(),
    };
  }

  /// 알고리즘 매개변수 자동 조정
  static Future<void> autoTuneAlgorithm(String userId) async {
    final effectiveness = await measureReviewEffectiveness(userId);
    
    // 효과성이 낮으면 알고리즘 매개변수 조정
    // 실제 구현에서는 사용자별 매개변수를 데이터베이스에 저장
    
    if (effectiveness['successRate'] != null && effectiveness['successRate']! < 0.7) {
      // 성공률이 낮으면 간격을 줄임
      print('SRS: 사용자 $userId의 성공률이 낮음 - 복습 간격 단축 권장');
    }
    
    if (effectiveness['retentionEfficiency'] != null && effectiveness['retentionEfficiency']! > 1.5) {
      // 효율성이 높으면 간격을 늘림
      print('SRS: 사용자 $userId의 효율성이 높음 - 복습 간격 연장 가능');
    }
  }
}