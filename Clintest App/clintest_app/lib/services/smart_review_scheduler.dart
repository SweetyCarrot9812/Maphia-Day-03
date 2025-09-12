import 'package:isar/isar.dart';
import '../models/srs_card.dart';
import '../models/wrong_answer.dart';
import 'database_service.dart';
import 'learning_pattern_service.dart';

/// 스마트 복습 스케줄러 - 문제 유형별 맞춤 복습 시스템
class SmartReviewScheduler {
  static final Isar _isar = DatabaseService.isar;

  // 의료/간호학 문제 유형별 중요도 가중치
  static const Map<String, ReviewTypeConfig> _reviewTypeConfigs = {
    // 임상 핵심 영역
    'emergency_care': ReviewTypeConfig(
      importance: 10.0,
      baseInterval: 1,
      maxInterval: 14,
      difficultyMultiplier: 0.7,
      category: 'critical'
    ),
    'medication_administration': ReviewTypeConfig(
      importance: 9.0,
      baseInterval: 1,
      maxInterval: 21,
      difficultyMultiplier: 0.8,
      category: 'critical'
    ),
    'infection_control': ReviewTypeConfig(
      importance: 9.0,
      baseInterval: 2,
      maxInterval: 30,
      difficultyMultiplier: 0.8,
      category: 'critical'
    ),
    'patient_safety': ReviewTypeConfig(
      importance: 9.0,
      baseInterval: 1,
      maxInterval: 21,
      difficultyMultiplier: 0.7,
      category: 'critical'
    ),

    // 기본 간호 업무
    'vital_signs': ReviewTypeConfig(
      importance: 8.0,
      baseInterval: 3,
      maxInterval: 45,
      difficultyMultiplier: 1.0,
      category: 'high'
    ),
    'nursing_procedures': ReviewTypeConfig(
      importance: 8.0,
      baseInterval: 3,
      maxInterval: 45,
      difficultyMultiplier: 0.9,
      category: 'high'
    ),
    'patient_assessment': ReviewTypeConfig(
      importance: 8.0,
      baseInterval: 2,
      maxInterval: 30,
      difficultyMultiplier: 0.9,
      category: 'high'
    ),
    'wound_care': ReviewTypeConfig(
      importance: 7.5,
      baseInterval: 3,
      maxInterval: 60,
      difficultyMultiplier: 1.0,
      category: 'high'
    ),

    // 전문 영역
    'pharmacology': ReviewTypeConfig(
      importance: 7.0,
      baseInterval: 4,
      maxInterval: 60,
      difficultyMultiplier: 1.1,
      category: 'medium'
    ),
    'pathophysiology': ReviewTypeConfig(
      importance: 6.5,
      baseInterval: 5,
      maxInterval: 90,
      difficultyMultiplier: 1.2,
      category: 'medium'
    ),
    'nursing_theory': ReviewTypeConfig(
      importance: 6.0,
      baseInterval: 7,
      maxInterval: 120,
      difficultyMultiplier: 1.0,
      category: 'medium'
    ),

    // 기초 지식
    'anatomy_physiology': ReviewTypeConfig(
      importance: 5.5,
      baseInterval: 7,
      maxInterval: 180,
      difficultyMultiplier: 1.0,
      category: 'basic'
    ),
    'medical_terminology': ReviewTypeConfig(
      importance: 5.0,
      baseInterval: 10,
      maxInterval: 180,
      difficultyMultiplier: 0.9,
      category: 'basic'
    ),
    'ethics_legal': ReviewTypeConfig(
      importance: 5.0,
      baseInterval: 14,
      maxInterval: 365,
      difficultyMultiplier: 1.0,
      category: 'basic'
    ),
  };

  // =================
  // 메인 스케줄링 메서드
  // =================

  /// 개인 맞춤형 복습 스케줄 생성
  static Future<ReviewSchedule> generatePersonalizedSchedule(
    String userId, {
    int daysAhead = 7,
    int maxReviewsPerDay = 50,
  }) async {
    // 1. 사용자 학습 패턴 분석
    final learningProfile = await LearningPatternService.analyzeUserLearningPattern(userId);
    
    // 2. 현재 복습 대상 카드들 조회
    final allCards = await _getAllUserSRSCards(userId);
    final dueCards = _filterDueCards(allCards, daysAhead);
    
    // 3. 문제 유형별로 분류
    final cardsByType = _categorizeCardsByType(dueCards);
    
    // 4. 각 유형별 우선순위 계산
    final prioritizedCards = await _calculateTypePriorities(
      cardsByType, 
      learningProfile,
      userId
    );
    
    // 5. 일별 스케줄 생성
    final dailySchedules = _generateDailySchedules(
      prioritizedCards,
      daysAhead,
      maxReviewsPerDay,
      learningProfile,
    );
    
    return ReviewSchedule(
      userId: userId,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: daysAhead)),
      dailySchedules: dailySchedules,
      totalCards: dueCards.length,
      averageCardsPerDay: (dueCards.length / daysAhead).round(),
      generatedAt: DateTime.now(),
    );
  }

  /// 실시간 복습 우선순위 재계산
  static Future<List<SRSCard>> getNextReviewCards(
    String userId, {
    int limit = 10,
    String? focusType,
  }) async {
    final allCards = await _getAllUserSRSCards(userId);
    final dueCards = allCards.where((card) => 
      card.dueDate.isBefore(DateTime.now().add(const Duration(hours: 1)))
    ).toList();
    
    if (dueCards.isEmpty) return [];
    
    // 카드별 우선순위 점수 계산
    final cardScores = <CardScore>[];
    final now = DateTime.now();
    
    for (var card in dueCards) {
      final questionType = _detectQuestionType(card);
      final config = _reviewTypeConfigs[questionType] ?? _getDefaultConfig();
      
      double score = await _calculateCardUrgencyScore(card, config);
      
      // 특정 유형에 집중하는 경우 가중치 적용
      if (focusType != null && questionType == focusType) {
        score *= 1.5;
      }
      
      cardScores.add(CardScore(card: card, score: score, questionType: questionType));
    }
    
    // 점수 기준 정렬하여 상위 카드들 반환
    cardScores.sort((a, b) => b.score.compareTo(a.score));
    return cardScores.take(limit).map((cs) => cs.card).toList();
  }

  /// 약점 영역 집중 복습 스케줄
  static Future<List<SRSCard>> getWeaknessAreaReview(
    String userId, {
    int limit = 20,
  }) async {
    // 1. 사용자의 약점 영역 분석
    final weaknessAreas = await _analyzeWeaknessAreas(userId);
    
    // 2. 약점 영역의 카드들 조회
    final weaknessCards = <SRSCard>[];
    
    for (var area in weaknessAreas.keys) {
      final cards = await _getCardsByType(userId, area);
      weaknessCards.addAll(cards);
    }
    
    // 3. 약점 정도와 복습 긴급도를 기반으로 정렬
    final prioritizedCards = <CardScore>[];
    
    for (var card in weaknessCards) {
      final questionType = _detectQuestionType(card);
      final weaknessLevel = weaknessAreas[questionType] ?? 0.5;
      
      double score = card.urgencyScore * weaknessLevel * 2.0;
      prioritizedCards.add(CardScore(
        card: card, 
        score: score, 
        questionType: questionType
      ));
    }
    
    prioritizedCards.sort((a, b) => b.score.compareTo(a.score));
    return prioritizedCards.take(limit).map((cs) => cs.card).toList();
  }

  /// 시험 대비 집중 복습 모드
  static Future<List<SRSCard>> getExamPreparationReview(
    String userId,
    String examType, // 'nclex', 'nursing_board', 'specialty'
    DateTime examDate, {
    int limit = 100,
  }) async {
    final daysUntilExam = examDate.difference(DateTime.now()).inDays;
    
    if (daysUntilExam <= 0) return [];
    
    // 시험 유형별 중요 영역 정의
    final criticalAreas = _getCriticalAreasForExam(examType);
    
    // 중요 영역의 모든 카드 조회
    final examCards = <SRSCard>[];
    for (var area in criticalAreas) {
      final cards = await _getCardsByType(userId, area);
      examCards.addAll(cards);
    }
    
    // 시험일까지의 복습 계획 고려
    final intensityFactor = _calculateExamIntensityFactor(daysUntilExam);
    
    final prioritizedCards = <CardScore>[];
    for (var card in examCards) {
      final questionType = _detectQuestionType(card);
      final config = _reviewTypeConfigs[questionType] ?? _getDefaultConfig();
      
      double score = config.importance * intensityFactor;
      
      // 최근 틀린 문제에 가중치
      if (card.lastWrongDate != null) {
        int daysSinceWrong = DateTime.now().difference(card.lastWrongDate!).inDays;
        if (daysSinceWrong < 7) {
          score *= 1.5;
        }
      }
      
      // 연체된 카드에 가중치
      if (card.isOverdue) {
        score *= 1.3;
      }
      
      prioritizedCards.add(CardScore(
        card: card,
        score: score,
        questionType: questionType
      ));
    }
    
    prioritizedCards.sort((a, b) => b.score.compareTo(a.score));
    return prioritizedCards.take(limit).map((cs) => cs.card).toList();
  }

  // =================
  // 보조 메서드들
  // =================

  static Future<List<SRSCard>> _getAllUserSRSCards(String userId) async {
    return await _isar.srsCards
        .where()
        .userIdEqualTo(userId)
        .findAll();
  }

  static List<SRSCard> _filterDueCards(List<SRSCard> cards, int daysAhead) {
    final cutoffDate = DateTime.now().add(Duration(days: daysAhead));
    return cards.where((card) => card.dueDate.isBefore(cutoffDate)).toList();
  }

  static Map<String, List<SRSCard>> _categorizeCardsByType(List<SRSCard> cards) {
    final Map<String, List<SRSCard>> categorized = {};
    
    for (var card in cards) {
      final type = _detectQuestionType(card);
      categorized.putIfAbsent(type, () => []).add(card);
    }
    
    return categorized;
  }

  static String _detectQuestionType(SRSCard card) {
    // 실제로는 itemId나 관련 데이터를 통해 문제 유형을 분석해야 함
    // 여기서는 간단한 예시로 처리
    
    // clinicalContext가 있는 경우 활용
    if (card.clinicalContext != null) {
      switch (card.clinicalContext!) {
        case 'emergency':
          return 'emergency_care';
        case 'medication':
          return 'medication_administration';
        case 'infection':
          return 'infection_control';
        case 'safety':
          return 'patient_safety';
        default:
          break;
      }
    }
    
    // medicalCategory 기반 추정
    switch (card.medicalCategory) {
      case 'critical':
        return 'patient_safety';
      case 'high':
        return 'nursing_procedures';
      case 'medium':
        return 'pharmacology';
      default:
        return 'nursing_theory';
    }
  }

  static Future<Map<String, List<CardScore>>> _calculateTypePriorities(
    Map<String, List<SRSCard>> cardsByType,
    LearningProfile learningProfile,
    String userId,
  ) async {
    final Map<String, List<CardScore>> prioritized = {};
    
    for (var entry in cardsByType.entries) {
      final type = entry.key;
      final cards = entry.value;
      final config = _reviewTypeConfigs[type] ?? _getDefaultConfig();
      
      final cardScores = <CardScore>[];
      
      for (var card in cards) {
        double score = await _calculateCardUrgencyScore(card, config);
        
        // 개인 학습 패턴 반영
        score *= _getPersonalTypeBias(type, learningProfile);
        
        cardScores.add(CardScore(
          card: card,
          score: score,
          questionType: type,
        ));
      }
      
      cardScores.sort((a, b) => b.score.compareTo(a.score));
      prioritized[type] = cardScores;
    }
    
    return prioritized;
  }

  static List<DailyReviewSchedule> _generateDailySchedules(
    Map<String, List<CardScore>> prioritizedCards,
    int daysAhead,
    int maxReviewsPerDay,
    LearningProfile learningProfile,
  ) {
    final schedules = <DailyReviewSchedule>[];
    final allCardScores = prioritizedCards.values.expand((list) => list).toList();
    allCardScores.sort((a, b) => b.score.compareTo(a.score));
    
    // 일별로 카드 분배
    for (int day = 0; day < daysAhead; day++) {
      final date = DateTime.now().add(Duration(days: day));
      final dailyCards = <SRSCard>[];
      
      // 해당 날짜의 카드들 선별
      int cardCount = 0;
      for (var cardScore in allCardScores) {
        if (cardCount >= maxReviewsPerDay) break;
        
        final card = cardScore.card;
        if (_shouldScheduleForDate(card, date, day)) {
          dailyCards.add(card);
          cardCount++;
        }
      }
      
      // 난이도 균형 조정
      final balancedCards = _balanceDifficultyDistribution(dailyCards);
      
      schedules.add(DailyReviewSchedule(
        date: date,
        cards: balancedCards,
        estimatedDuration: _estimateReviewDuration(balancedCards),
        difficultyDistribution: _calculateDifficultyDistribution(balancedCards),
      ));
    }
    
    return schedules;
  }

  static Future<double> _calculateCardUrgencyScore(SRSCard card, ReviewTypeConfig config) async {
    double score = 0.0;
    
    // 1. 기본 중요도
    score += config.importance;
    
    // 2. 연체 가중치
    if (card.isOverdue) {
      score += card.daysOverdue * 2.0;
    }
    
    // 3. 지연 가중치 (곧 연체될 카드)
    int daysUntilDue = card.daysUntilDue;
    if (daysUntilDue <= 0) {
      score += 5.0; // 오늘 또는 이미 지난 카드
    } else if (daysUntilDue == 1) {
      score += 3.0; // 내일 복습 예정
    }
    
    // 4. 난이도 가중치
    score += card.aiDifficultyScore * 3.0;
    score += card.personalDifficultyRating * 2.0;
    
    // 5. 실패 이력 가중치
    if (card.consecutiveCorrect == 0) {
      score += 2.0;
    }
    
    // 6. 기억 강도 반영 (약할수록 높은 점수)
    score += (1.0 - card.memoryStrength) * 2.0;
    
    return score;
  }

  static double _getPersonalTypeBias(String type, LearningProfile profile) {
    // 개인의 약점 영역에 가중치 적용
    final difficultyPerformance = profile.difficultyHandling.difficultyPerformance;
    
    // 해당 유형의 성과가 낮으면 더 자주 복습
    for (var entry in difficultyPerformance.entries) {
      if (type.contains(entry.key)) {
        return 2.0 - entry.value; // 성과가 낮을수록 높은 가중치
      }
    }
    
    return 1.0; // 기본값
  }

  static bool _shouldScheduleForDate(SRSCard card, DateTime date, int dayOffset) {
    // 연체된 카드는 즉시 스케줄
    if (card.isOverdue && dayOffset == 0) return true;
    
    // 복습 예정일과 가까운 날짜에 스케줄
    int daysFromDue = date.difference(card.dueDate).inDays;
    return daysFromDue.abs() <= 1;
  }

  static List<SRSCard> _balanceDifficultyDistribution(List<SRSCard> cards) {
    if (cards.length <= 5) return cards;
    
    // 난이도별로 정렬
    cards.sort((a, b) => a.aiDifficultyScore.compareTo(b.aiDifficultyScore));
    
    // 쉬운 것과 어려운 것을 섞어서 배치
    final balanced = <SRSCard>[];
    int easy = 0;
    int hard = cards.length - 1;
    
    while (easy <= hard) {
      if (balanced.length % 3 == 0) {
        balanced.add(cards[easy++]); // 쉬운 것
      } else {
        balanced.add(cards[hard--]); // 어려운 것
      }
    }
    
    return balanced;
  }

  static int _estimateReviewDuration(List<SRSCard> cards) {
    // 카드당 평균 2분으로 추정
    return cards.length * 2;
  }

  static Map<String, int> _calculateDifficultyDistribution(List<SRSCard> cards) {
    final distribution = <String, int>{'easy': 0, 'medium': 0, 'hard': 0};
    
    for (var card in cards) {
      if (card.aiDifficultyScore < 0.4) {
        distribution['easy'] = (distribution['easy'] ?? 0) + 1;
      } else if (card.aiDifficultyScore < 0.7) {
        distribution['medium'] = (distribution['medium'] ?? 0) + 1;
      } else {
        distribution['hard'] = (distribution['hard'] ?? 0) + 1;
      }
    }
    
    return distribution;
  }

  static Future<Map<String, double>> _analyzeWeaknessAreas(String userId) async {
    final wrongAnswers = await _isar.wrongAnswers
        .where()
        .userIdEqualTo(userId)
        .findAll();
    
    final Map<String, int> mistakeCount = {};
    final Map<String, int> totalCount = {};
    
    for (var wrong in wrongAnswers) {
      String category = wrong.questionCategory ?? 'unknown';
      mistakeCount[category] = (mistakeCount[category] ?? 0) + 1;
      totalCount[category] = (totalCount[category] ?? 0) + 1;
    }
    
    final Map<String, double> weakness = {};
    for (var entry in mistakeCount.entries) {
      String category = entry.key;
      int mistakes = entry.value;
      int total = totalCount[category] ?? 1;
      
      // 실수율이 높을수록 약점으로 판단
      weakness[category] = mistakes / total;
    }
    
    return weakness;
  }

  static Future<List<SRSCard>> _getCardsByType(String userId, String type) async {
    // 실제로는 더 정교한 필터링 필요
    final allCards = await _getAllUserSRSCards(userId);
    return allCards.where((card) => _detectQuestionType(card) == type).toList();
  }

  static List<String> _getCriticalAreasForExam(String examType) {
    switch (examType) {
      case 'nclex':
        return [
          'patient_safety',
          'medication_administration',
          'infection_control',
          'emergency_care',
          'nursing_procedures'
        ];
      case 'nursing_board':
        return [
          'nursing_theory',
          'patient_assessment',
          'pharmacology',
          'pathophysiology'
        ];
      case 'specialty':
        return [
          'emergency_care',
          'critical_care',
          'medication_administration'
        ];
      default:
        return ['patient_safety', 'nursing_procedures'];
    }
  }

  static double _calculateExamIntensityFactor(int daysUntilExam) {
    if (daysUntilExam <= 7) return 3.0;   // 1주일 이내
    if (daysUntilExam <= 30) return 2.0;  // 1개월 이내
    if (daysUntilExam <= 90) return 1.5;  // 3개월 이내
    return 1.0;                           // 그 외
  }

  static ReviewTypeConfig _getDefaultConfig() {
    return const ReviewTypeConfig(
      importance: 5.0,
      baseInterval: 5,
      maxInterval: 60,
      difficultyMultiplier: 1.0,
      category: 'medium'
    );
  }
}

// =================
// 데이터 클래스들
// =================

class ReviewTypeConfig {
  final double importance;          // 중요도 (0-10)
  final int baseInterval;          // 기본 복습 간격 (일)
  final int maxInterval;           // 최대 복습 간격 (일)
  final double difficultyMultiplier; // 난이도 승수
  final String category;           // 카테고리

  const ReviewTypeConfig({
    required this.importance,
    required this.baseInterval,
    required this.maxInterval,
    required this.difficultyMultiplier,
    required this.category,
  });
}

class ReviewSchedule {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyReviewSchedule> dailySchedules;
  final int totalCards;
  final int averageCardsPerDay;
  final DateTime generatedAt;

  ReviewSchedule({
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.dailySchedules,
    required this.totalCards,
    required this.averageCardsPerDay,
    required this.generatedAt,
  });
}

class DailyReviewSchedule {
  final DateTime date;
  final List<SRSCard> cards;
  final int estimatedDuration; // 분
  final Map<String, int> difficultyDistribution;

  DailyReviewSchedule({
    required this.date,
    required this.cards,
    required this.estimatedDuration,
    required this.difficultyDistribution,
  });
}

class CardScore {
  final SRSCard card;
  final double score;
  final String questionType;

  CardScore({
    required this.card,
    required this.score,
    required this.questionType,
  });
}