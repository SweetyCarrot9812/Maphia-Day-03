import 'package:json_annotation/json_annotation.dart';

part 'srs_card.g.dart';

@JsonSerializable()
class SRSCard {
  final String cardId;
  final String userId;
  final String itemType; // 'problem' 또는 'concept'
  final String itemId;
  final int interval; // 간격 (분 단위)
  final double easeFactor; // 용이성 계수
  final DateTime dueDate; // 다음 복습 일시
  final int totalReviews; // 총 복습 횟수
  final int consecutiveCorrect; // 연속 정답 수
  final double aiDifficultyScore; // AI 난이도 점수 (0.0-1.0)
  final String? lastPerformance; // 마지막 성과 ('again', 'good_weak', 'good_strong')
  final DateTime createdAt;
  final DateTime updatedAt;

  const SRSCard({
    required this.cardId,
    required this.userId,
    required this.itemType,
    required this.itemId,
    required this.interval,
    required this.easeFactor,
    required this.dueDate,
    required this.totalReviews,
    required this.consecutiveCorrect,
    required this.aiDifficultyScore,
    this.lastPerformance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SRSCard.fromJson(Map<String, dynamic> json) =>
      _$SRSCardFromJson(json);

  Map<String, dynamic> toJson() => _$SRSCardToJson(this);

  SRSCard copyWith({
    String? cardId,
    String? userId,
    String? itemType,
    String? itemId,
    int? interval,
    double? easeFactor,
    DateTime? dueDate,
    int? totalReviews,
    int? consecutiveCorrect,
    double? aiDifficultyScore,
    String? lastPerformance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SRSCard(
      cardId: cardId ?? this.cardId,
      userId: userId ?? this.userId,
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
      dueDate: dueDate ?? this.dueDate,
      totalReviews: totalReviews ?? this.totalReviews,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
      aiDifficultyScore: aiDifficultyScore ?? this.aiDifficultyScore,
      lastPerformance: lastPerformance ?? this.lastPerformance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 오늘 복습 대상인지 확인
  bool get isDueToday => dueDate.isBefore(DateTime.now());

  // 다음 복습까지 남은 시간 (분)
  int get minutesUntilDue {
    final now = DateTime.now();
    if (dueDate.isBefore(now)) return 0;
    return dueDate.difference(now).inMinutes;
  }

  // 복습 우선순위 점수 (낮을수록 우선)
  double get priorityScore {
    final overdueDays = DateTime.now().difference(dueDate).inDays.toDouble();
    return overdueDays + (aiDifficultyScore * 10);
  }
}

@JsonSerializable()
class ReviewLog {
  final String reviewId;
  final String cardId;
  final String userId;
  final String userResponse; // 'again' 또는 'good'
  final String internalClassification; // 'again', 'good_weak', 'good_strong'
  final int responseTimeMs; // 응답 시간 (밀리초)
  final int previousInterval;
  final int newInterval;
  final double easeFactorChange;
  final double confidenceScore;
  final Map<String, dynamic> contextData;
  final DateTime reviewedAt;

  const ReviewLog({
    required this.reviewId,
    required this.cardId,
    required this.userId,
    required this.userResponse,
    required this.internalClassification,
    required this.responseTimeMs,
    required this.previousInterval,
    required this.newInterval,
    required this.easeFactorChange,
    required this.confidenceScore,
    required this.contextData,
    required this.reviewedAt,
  });

  factory ReviewLog.fromJson(Map<String, dynamic> json) =>
      _$ReviewLogFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewLogToJson(this);
}

@JsonSerializable()
class SRSStats {
  final int totalCards;
  final int dueToday;
  final int totalReviews;
  final Map<String, ItemTypeStats> byType;
  final SRSAverages averages;

  const SRSStats({
    required this.totalCards,
    required this.dueToday,
    required this.totalReviews,
    required this.byType,
    required this.averages,
  });

  factory SRSStats.fromJson(Map<String, dynamic> json) =>
      _$SRSStatsFromJson(json);

  Map<String, dynamic> toJson() => _$SRSStatsToJson(this);
}

@JsonSerializable()
class ItemTypeStats {
  final String id;
  final int total;
  final int dueToday;
  final double avgEaseFactor;
  final double avgInterval;
  final int totalReviews;

  const ItemTypeStats({
    required this.id,
    required this.total,
    required this.dueToday,
    required this.avgEaseFactor,
    required this.avgInterval,
    required this.totalReviews,
  });

  factory ItemTypeStats.fromJson(Map<String, dynamic> json) =>
      _$ItemTypeStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ItemTypeStatsToJson(this);
}

@JsonSerializable()
class SRSAverages {
  final double easeFactor;
  final double intervalDays;

  const SRSAverages({
    required this.easeFactor,
    required this.intervalDays,
  });

  factory SRSAverages.fromJson(Map<String, dynamic> json) =>
      _$SRSAveragesFromJson(json);

  Map<String, dynamic> toJson() => _$SRSAveragesToJson(this);
}