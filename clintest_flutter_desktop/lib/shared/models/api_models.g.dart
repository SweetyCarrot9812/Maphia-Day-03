// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NursingSubject _$NursingSubjectFromJson(Map<String, dynamic> json) =>
    NursingSubject(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      questionCount: (json['questionCount'] as num).toInt(),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$NursingSubjectToJson(NursingSubject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'questionCount': instance.questionCount,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

StatsModel _$StatsModelFromJson(Map<String, dynamic> json) => StatsModel(
  totalQuestions: (json['totalQuestions'] as num).toInt(),
  totalCategories: (json['totalCategories'] as num).toInt(),
  averageScore: (json['averageScore'] as num).toDouble(),
  activeUsers: (json['activeUsers'] as num).toInt(),
);

Map<String, dynamic> _$StatsModelToJson(StatsModel instance) =>
    <String, dynamic>{
      'totalQuestions': instance.totalQuestions,
      'totalCategories': instance.totalCategories,
      'averageScore': instance.averageScore,
      'activeUsers': instance.activeUsers,
    };

JobsStats _$JobsStatsFromJson(Map<String, dynamic> json) => JobsStats(
  totalJobs: (json['totalJobs'] as num).toInt(),
  completedJobs: (json['completedJobs'] as num).toInt(),
  failedJobs: (json['failedJobs'] as num).toInt(),
  pendingJobs: (json['pendingJobs'] as num).toInt(),
  successRate: (json['successRate'] as num).toDouble(),
);

Map<String, dynamic> _$JobsStatsToJson(JobsStats instance) => <String, dynamic>{
  'totalJobs': instance.totalJobs,
  'completedJobs': instance.completedJobs,
  'failedJobs': instance.failedJobs,
  'pendingJobs': instance.pendingJobs,
  'successRate': instance.successRate,
};

SrsStats _$SrsStatsFromJson(Map<String, dynamic> json) => SrsStats(
  totalCards: (json['totalCards'] as num).toInt(),
  dueCards: (json['dueCards'] as num).toInt(),
  newCards: (json['newCards'] as num).toInt(),
  reviewedToday: (json['reviewedToday'] as num).toInt(),
  retentionRate: (json['retentionRate'] as num).toDouble(),
  lastReview: json['lastReview'] == null
      ? null
      : DateTime.parse(json['lastReview'] as String),
);

Map<String, dynamic> _$SrsStatsToJson(SrsStats instance) => <String, dynamic>{
  'totalCards': instance.totalCards,
  'dueCards': instance.dueCards,
  'newCards': instance.newCards,
  'reviewedToday': instance.reviewedToday,
  'retentionRate': instance.retentionRate,
  'lastReview': instance.lastReview?.toIso8601String(),
};

AiStatus _$AiStatusFromJson(Map<String, dynamic> json) => AiStatus(
  isActive: json['isActive'] as bool,
  model: json['model'] as String,
  requestCount: (json['requestCount'] as num).toInt(),
  averageResponseTime: (json['averageResponseTime'] as num).toDouble(),
  lastRequest: json['lastRequest'] == null
      ? null
      : DateTime.parse(json['lastRequest'] as String),
);

Map<String, dynamic> _$AiStatusToJson(AiStatus instance) => <String, dynamic>{
  'isActive': instance.isActive,
  'model': instance.model,
  'requestCount': instance.requestCount,
  'averageResponseTime': instance.averageResponseTime,
  'lastRequest': instance.lastRequest?.toIso8601String(),
};

CostSummary _$CostSummaryFromJson(Map<String, dynamic> json) => CostSummary(
  totalCost: (json['totalCost'] as num).toDouble(),
  dailyCost: (json['dailyCost'] as num).toDouble(),
  monthlyCost: (json['monthlyCost'] as num).toDouble(),
  costByService: (json['costByService'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  lastUpdated: json['lastUpdated'] == null
      ? null
      : DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$CostSummaryToJson(CostSummary instance) =>
    <String, dynamic>{
      'totalCost': instance.totalCost,
      'dailyCost': instance.dailyCost,
      'monthlyCost': instance.monthlyCost,
      'costByService': instance.costByService,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };

SystemHealth _$SystemHealthFromJson(Map<String, dynamic> json) => SystemHealth(
  status: json['status'] as String,
  version: json['version'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  services: json['services'] as Map<String, dynamic>,
);

Map<String, dynamic> _$SystemHealthToJson(SystemHealth instance) =>
    <String, dynamic>{
      'status': instance.status,
      'version': instance.version,
      'timestamp': instance.timestamp.toIso8601String(),
      'services': instance.services,
    };

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => ApiResponse<T>(
  success: json['success'] as bool,
  message: json['message'] as String?,
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
  error: json['error'] as String?,
);

Map<String, dynamic> _$ApiResponseToJson<T>(
  ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
  'error': instance.error,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);
