import 'package:json_annotation/json_annotation.dart';

part 'api_models.g.dart';

// 간호사 과목 모델
@JsonSerializable()
class NursingSubject {
  final String id;
  final String name;
  final String description;
  final int questionCount;
  final DateTime? updatedAt;

  const NursingSubject({
    required this.id,
    required this.name,
    required this.description,
    required this.questionCount,
    this.updatedAt,
  });

  factory NursingSubject.fromJson(Map<String, dynamic> json) =>
      _$NursingSubjectFromJson(json);
  Map<String, dynamic> toJson() => _$NursingSubjectToJson(this);
}

// 통계 모델
@JsonSerializable()
class StatsModel {
  final int totalQuestions;
  final int totalCategories;
  final double averageScore;
  final int activeUsers;

  const StatsModel({
    required this.totalQuestions,
    required this.totalCategories,
    required this.averageScore,
    required this.activeUsers,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) =>
      _$StatsModelFromJson(json);
  Map<String, dynamic> toJson() => _$StatsModelToJson(this);
}

// Jobs 통계 모델
@JsonSerializable()
class JobsStats {
  final int totalJobs;
  final int completedJobs;
  final int failedJobs;
  final int pendingJobs;
  final double successRate;

  const JobsStats({
    required this.totalJobs,
    required this.completedJobs,
    required this.failedJobs,
    required this.pendingJobs,
    required this.successRate,
  });

  factory JobsStats.fromJson(Map<String, dynamic> json) =>
      _$JobsStatsFromJson(json);
  Map<String, dynamic> toJson() => _$JobsStatsToJson(this);
}

// SRS 통계 모델
@JsonSerializable()
class SrsStats {
  final int totalCards;
  final int dueCards;
  final int newCards;
  final int reviewedToday;
  final double retentionRate;
  final DateTime? lastReview;

  const SrsStats({
    required this.totalCards,
    required this.dueCards,
    required this.newCards,
    required this.reviewedToday,
    required this.retentionRate,
    this.lastReview,
  });

  factory SrsStats.fromJson(Map<String, dynamic> json) =>
      _$SrsStatsFromJson(json);
  Map<String, dynamic> toJson() => _$SrsStatsToJson(this);
}

// AI 상태 모델
@JsonSerializable()
class AiStatus {
  final bool isActive;
  final String model;
  final int requestCount;
  final double averageResponseTime;
  final DateTime? lastRequest;

  const AiStatus({
    required this.isActive,
    required this.model,
    required this.requestCount,
    required this.averageResponseTime,
    this.lastRequest,
  });

  factory AiStatus.fromJson(Map<String, dynamic> json) =>
      _$AiStatusFromJson(json);
  Map<String, dynamic> toJson() => _$AiStatusToJson(this);
}

// 비용 요약 모델
@JsonSerializable()
class CostSummary {
  final double totalCost;
  final double dailyCost;
  final double monthlyCost;
  final Map<String, double> costByService;
  final DateTime? lastUpdated;

  const CostSummary({
    required this.totalCost,
    required this.dailyCost,
    required this.monthlyCost,
    required this.costByService,
    this.lastUpdated,
  });

  factory CostSummary.fromJson(Map<String, dynamic> json) =>
      _$CostSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$CostSummaryToJson(this);
}

// 시스템 헬스 모델
@JsonSerializable()
class SystemHealth {
  final String status;
  final String version;
  final DateTime timestamp;
  final Map<String, dynamic> services;

  const SystemHealth({
    required this.status,
    required this.version,
    required this.timestamp,
    required this.services,
  });

  factory SystemHealth.fromJson(Map<String, dynamic> json) =>
      _$SystemHealthFromJson(json);
  Map<String, dynamic> toJson() => _$SystemHealthToJson(this);
}

// API 응답 래퍼
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}