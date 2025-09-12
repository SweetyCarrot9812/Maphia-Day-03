import 'dart:math';
import 'package:uuid/uuid.dart';
import '../shared/models/srs_card.dart';

/// SuperMemo-2 기반 간격 반복 학습 시스템 엔진
class SRSEngine {
  static const _uuid = Uuid();
  
  // SuperMemo-2 알고리즘 상수
  static const Map<String, int> _initialIntervals = {
    'again': 1,           // 1분 (틀린 경우)
    'good_weak': 1440,    // 1일 (맞았지만 어려웠던 경우)
    'good_strong': 5760   // 4일 (쉽게 맞춘 경우)
  };
  
  static const Map<String, double> _intervalMultipliers = {
    'again': 0.2,         // 20% 감소
    'good_weak': 1.3,     // 30% 증가  
    'good_strong': 2.5    // 150% 증가
  };
  
  static const Map<String, double> _easeFactorChanges = {
    'again': -0.2,
    'good_weak': -0.1,
    'good_strong': 0.1
  };
  
  // 제한값
  static const int _minInterval = 1;         // 최소 1분
  static const int _maxInterval = 525600;    // 최대 365일 (분)
  static const double _minEaseFactor = 1.3;  // 최소 용이성 계수
  static const double _maxEaseFactor = 2.5;  // 최대 용이성 계수

  /// UUID 생성 (카드 ID용)
  static String generateUUID() {
    return _uuid.v4();
  }

  /// 새 SRS 카드 생성
  static SRSCard createCard({
    required String userId,
    required String itemType,
    required String itemId,
    double initialDifficulty = 0.5,
  }) {
    final now = DateTime.now();
    final cardId = generateUUID();
    
    // 난이도 보정 (0.0-1.0 범위)
    final difficulty = max(0.0, min(1.0, initialDifficulty));
    
    return SRSCard(
      cardId: cardId,
      userId: userId,
      itemType: itemType,
      itemId: itemId,
      interval: _initialIntervals['good_weak']!,
      easeFactor: 2.5, // SuperMemo-2 초기값
      dueDate: now.add(Duration(minutes: _initialIntervals['good_weak']!)),
      totalReviews: 0,
      consecutiveCorrect: 0,
      aiDifficultyScore: difficulty,
      lastPerformance: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 사용자 응답 분류 (Good 버튼을 세분화)
  static String classifyGoodResponse({
    required int responseTimeMs,
    int avgResponseTimeMs = 5000,
    double confidence = 0.7,
  }) {
    final timeRatio = responseTimeMs / avgResponseTimeMs;
    
    // 빠른 응답 (평균의 60% 이하) + 높은 확신도 = Good-Strong
    if (timeRatio < 0.6 && confidence > 0.8) {
      return 'good_strong';
    }
    
    // 보통 응답 시간 또는 중간 확신도 = Good-Weak
    return 'good_weak';
  }

  /// 다음 복습 간격 계산 (SuperMemo-2 변형)
  static int calculateNextInterval({
    required int currentInterval,
    required String performance,
    required double easeFactor,
    double aiDifficultyScore = 0.5,
  }) {
    final baseMultiplier = _intervalMultipliers[performance] ?? 1.3;
    
    // AI 난이도 보정 (0.5 ~ 2.0 범위)
    final difficultyModifier = 0.5 + (aiDifficultyScore * 1.5);
    
    double nextInterval = currentInterval * baseMultiplier * difficultyModifier;
    
    // 용이성 계수 적용 (good_strong만)
    if (performance == 'good_strong') {
      nextInterval *= easeFactor;
    }
    
    // 간격 제한 적용
    nextInterval = max(_minInterval.toDouble(), 
                     min(_maxInterval.toDouble(), nextInterval));
    
    return nextInterval.round();
  }

  /// 용이성 계수 업데이트
  static double updateEaseFactor({
    required double currentEaseFactor,
    required String performance,
  }) {
    final change = _easeFactorChanges[performance] ?? 0.0;
    double newEaseFactor = currentEaseFactor + change;
    
    // 용이성 계수 범위 제한
    newEaseFactor = max(_minEaseFactor, min(_maxEaseFactor, newEaseFactor));
    
    return (newEaseFactor * 100).round() / 100; // 소수점 2자리
  }

  /// 카드 복습 처리
  static ReviewResult reviewCard({
    required SRSCard card,
    required String userResponse, // 'again' 또는 'good'
    int responseTimeMs = 5000,
    double confidence = 0.7,
  }) {
    final now = DateTime.now();
    final isCorrect = userResponse == 'good';
    
    // 내부 분류
    String internalClassification;
    if (userResponse == 'again') {
      internalClassification = 'again';
    } else {
      // Good 버튼 세분화
      internalClassification = classifyGoodResponse(
        responseTimeMs: responseTimeMs,
        confidence: confidence,
      );
    }
    
    // 새 간격 계산
    final newInterval = calculateNextInterval(
      currentInterval: card.interval,
      performance: internalClassification,
      easeFactor: card.easeFactor,
      aiDifficultyScore: card.aiDifficultyScore,
    );
    
    // 용이성 계수 업데이트
    final newEaseFactor = updateEaseFactor(
      currentEaseFactor: card.easeFactor,
      performance: internalClassification,
    );
    
    // 연속 정답 횟수 업데이트
    final consecutiveCorrect = internalClassification == 'again' ? 
        0 : card.consecutiveCorrect + 1;
    
    // 다음 복습 일자 계산
    final dueDate = now.add(Duration(minutes: newInterval));
    
    // 카드 업데이트
    final updatedCard = card.copyWith(
      interval: newInterval,
      easeFactor: newEaseFactor,
      dueDate: dueDate,
      totalReviews: card.totalReviews + 1,
      consecutiveCorrect: consecutiveCorrect,
      lastPerformance: internalClassification,
      updatedAt: now,
    );
    
    // 복습 로그 생성
    final reviewLog = ReviewLog(
      reviewId: generateUUID(),
      cardId: card.cardId,
      userId: card.userId,
      userResponse: userResponse,
      internalClassification: internalClassification,
      responseTimeMs: responseTimeMs,
      previousInterval: card.interval,
      newInterval: newInterval,
      easeFactorChange: newEaseFactor - card.easeFactor,
      confidenceScore: confidence,
      contextData: {
        'itemType': card.itemType,
        'itemId': card.itemId,
        'totalReviews': updatedCard.totalReviews,
      },
      reviewedAt: now,
    );
    
    return ReviewResult(
      updatedCard: updatedCard,
      reviewLog: reviewLog,
      nextReviewInMinutes: newInterval,
      classification: internalClassification,
    );
  }

  /// 복습 우선순위로 카드 정렬
  static List<SRSCard> sortCardsByPriority(List<SRSCard> cards) {
    final sortedCards = [...cards];
    sortedCards.sort((a, b) => a.priorityScore.compareTo(b.priorityScore));
    return sortedCards;
  }

  /// 오늘 복습 대상 카드 필터링
  static List<SRSCard> getTodayDueCards(List<SRSCard> allCards) {
    return allCards.where((card) => card.isDueToday).toList();
  }

  /// SRS 통계 계산
  static SRSStats calculateStats(List<SRSCard> allCards) {
    final now = DateTime.now();
    
    // 타입별 통계 집계
    final Map<String, _TypeStatAccumulator> typeStats = {};
    int totalReviews = 0;
    int dueToday = 0;
    
    for (final card in allCards) {
      final type = card.itemType;
      
      if (!typeStats.containsKey(type)) {
        typeStats[type] = _TypeStatAccumulator(type);
      }
      
      typeStats[type]!.add(card);
      totalReviews += card.totalReviews;
      
      if (card.dueDate.isBefore(now)) {
        dueToday++;
      }
    }
    
    // 타입별 통계 완료
    final byType = <String, ItemTypeStats>{};
    for (final entry in typeStats.entries) {
      byType[entry.key] = entry.value.toStats();
    }
    
    // 전체 평균 계산
    double avgEaseFactor = 2.5;
    double avgIntervalDays = 1.0;
    
    if (allCards.isNotEmpty) {
      avgEaseFactor = allCards.map((c) => c.easeFactor).reduce((a, b) => a + b) / allCards.length;
      avgIntervalDays = allCards.map((c) => c.interval / 1440.0).reduce((a, b) => a + b) / allCards.length;
    }
    
    return SRSStats(
      totalCards: allCards.length,
      dueToday: dueToday,
      totalReviews: totalReviews,
      byType: byType,
      averages: SRSAverages(
        easeFactor: (avgEaseFactor * 100).round() / 100,
        intervalDays: (avgIntervalDays * 10).round() / 10,
      ),
    );
  }
}

/// 복습 결과
class ReviewResult {
  final SRSCard updatedCard;
  final ReviewLog reviewLog;
  final int nextReviewInMinutes;
  final String classification;

  const ReviewResult({
    required this.updatedCard,
    required this.reviewLog,
    required this.nextReviewInMinutes,
    required this.classification,
  });
}

/// 타입별 통계 누적기 (내부 사용)
class _TypeStatAccumulator {
  final String type;
  int total = 0;
  int dueToday = 0;
  double easeFactorSum = 0.0;
  double intervalSum = 0.0;
  int totalReviews = 0;

  _TypeStatAccumulator(this.type);

  void add(SRSCard card) {
    total++;
    if (card.isDueToday) dueToday++;
    easeFactorSum += card.easeFactor;
    intervalSum += card.interval.toDouble();
    totalReviews += card.totalReviews;
  }

  ItemTypeStats toStats() {
    return ItemTypeStats(
      id: type,
      total: total,
      dueToday: dueToday,
      avgEaseFactor: total > 0 ? (easeFactorSum / total * 100).round() / 100 : 2.5,
      avgInterval: total > 0 ? (intervalSum / total).round().toDouble() : 1440.0,
      totalReviews: totalReviews,
    );
  }
}