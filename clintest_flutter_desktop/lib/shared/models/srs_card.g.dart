// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'srs_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SRSCard _$SRSCardFromJson(Map<String, dynamic> json) => SRSCard(
  cardId: json['cardId'] as String,
  userId: json['userId'] as String,
  itemType: json['itemType'] as String,
  itemId: json['itemId'] as String,
  interval: (json['interval'] as num).toInt(),
  easeFactor: (json['easeFactor'] as num).toDouble(),
  dueDate: DateTime.parse(json['dueDate'] as String),
  totalReviews: (json['totalReviews'] as num).toInt(),
  consecutiveCorrect: (json['consecutiveCorrect'] as num).toInt(),
  aiDifficultyScore: (json['aiDifficultyScore'] as num).toDouble(),
  lastPerformance: json['lastPerformance'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SRSCardToJson(SRSCard instance) => <String, dynamic>{
  'cardId': instance.cardId,
  'userId': instance.userId,
  'itemType': instance.itemType,
  'itemId': instance.itemId,
  'interval': instance.interval,
  'easeFactor': instance.easeFactor,
  'dueDate': instance.dueDate.toIso8601String(),
  'totalReviews': instance.totalReviews,
  'consecutiveCorrect': instance.consecutiveCorrect,
  'aiDifficultyScore': instance.aiDifficultyScore,
  'lastPerformance': instance.lastPerformance,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

ReviewLog _$ReviewLogFromJson(Map<String, dynamic> json) => ReviewLog(
  reviewId: json['reviewId'] as String,
  cardId: json['cardId'] as String,
  userId: json['userId'] as String,
  userResponse: json['userResponse'] as String,
  internalClassification: json['internalClassification'] as String,
  responseTimeMs: (json['responseTimeMs'] as num).toInt(),
  previousInterval: (json['previousInterval'] as num).toInt(),
  newInterval: (json['newInterval'] as num).toInt(),
  easeFactorChange: (json['easeFactorChange'] as num).toDouble(),
  confidenceScore: (json['confidenceScore'] as num).toDouble(),
  contextData: json['contextData'] as Map<String, dynamic>,
  reviewedAt: DateTime.parse(json['reviewedAt'] as String),
);

Map<String, dynamic> _$ReviewLogToJson(ReviewLog instance) => <String, dynamic>{
  'reviewId': instance.reviewId,
  'cardId': instance.cardId,
  'userId': instance.userId,
  'userResponse': instance.userResponse,
  'internalClassification': instance.internalClassification,
  'responseTimeMs': instance.responseTimeMs,
  'previousInterval': instance.previousInterval,
  'newInterval': instance.newInterval,
  'easeFactorChange': instance.easeFactorChange,
  'confidenceScore': instance.confidenceScore,
  'contextData': instance.contextData,
  'reviewedAt': instance.reviewedAt.toIso8601String(),
};

SRSStats _$SRSStatsFromJson(Map<String, dynamic> json) => SRSStats(
  totalCards: (json['totalCards'] as num).toInt(),
  dueToday: (json['dueToday'] as num).toInt(),
  totalReviews: (json['totalReviews'] as num).toInt(),
  byType: (json['byType'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, ItemTypeStats.fromJson(e as Map<String, dynamic>)),
  ),
  averages: SRSAverages.fromJson(json['averages'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SRSStatsToJson(SRSStats instance) => <String, dynamic>{
  'totalCards': instance.totalCards,
  'dueToday': instance.dueToday,
  'totalReviews': instance.totalReviews,
  'byType': instance.byType,
  'averages': instance.averages,
};

ItemTypeStats _$ItemTypeStatsFromJson(Map<String, dynamic> json) =>
    ItemTypeStats(
      id: json['id'] as String,
      total: (json['total'] as num).toInt(),
      dueToday: (json['dueToday'] as num).toInt(),
      avgEaseFactor: (json['avgEaseFactor'] as num).toDouble(),
      avgInterval: (json['avgInterval'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
    );

Map<String, dynamic> _$ItemTypeStatsToJson(ItemTypeStats instance) =>
    <String, dynamic>{
      'id': instance.id,
      'total': instance.total,
      'dueToday': instance.dueToday,
      'avgEaseFactor': instance.avgEaseFactor,
      'avgInterval': instance.avgInterval,
      'totalReviews': instance.totalReviews,
    };

SRSAverages _$SRSAveragesFromJson(Map<String, dynamic> json) => SRSAverages(
  easeFactor: (json['easeFactor'] as num).toDouble(),
  intervalDays: (json['intervalDays'] as num).toDouble(),
);

Map<String, dynamic> _$SRSAveragesToJson(SRSAverages instance) =>
    <String, dynamic>{
      'easeFactor': instance.easeFactor,
      'intervalDays': instance.intervalDays,
    };
