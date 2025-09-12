// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutLogImpl _$$WorkoutLogImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutLogImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deviceId: json['deviceId'] as String,
      conflicted: json['conflicted'] as bool? ?? false,
      sessionId: json['sessionId'] as String,
      exerciseKey: json['exerciseKey'] as String,
      setIndex: (json['setIndex'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      rpe: (json['rpe'] as num).toInt(),
      completedAt: DateTime.parse(json['completedAt'] as String),
      note: json['note'] as String?,
      isPR: json['isPR'] as bool? ?? false,
      estimated1RM: (json['estimated1RM'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$WorkoutLogImplToJson(_$WorkoutLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deviceId': instance.deviceId,
      'conflicted': instance.conflicted,
      'sessionId': instance.sessionId,
      'exerciseKey': instance.exerciseKey,
      'setIndex': instance.setIndex,
      'weight': instance.weight,
      'reps': instance.reps,
      'rpe': instance.rpe,
      'completedAt': instance.completedAt.toIso8601String(),
      'note': instance.note,
      'isPR': instance.isPR,
      'estimated1RM': instance.estimated1RM,
    };

_$LocalPlanCacheImpl _$$LocalPlanCacheImplFromJson(Map<String, dynamic> json) =>
    _$LocalPlanCacheImpl(
      cacheKey: json['cacheKey'] as String,
      payload: json['payload'] as String,
      ttlEpoch: (json['ttlEpoch'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$LocalPlanCacheImplToJson(
        _$LocalPlanCacheImpl instance) =>
    <String, dynamic>{
      'cacheKey': instance.cacheKey,
      'payload': instance.payload,
      'ttlEpoch': instance.ttlEpoch,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$PendingOperationImpl _$$PendingOperationImplFromJson(
        Map<String, dynamic> json) =>
    _$PendingOperationImpl(
      id: json['id'] as String,
      op: $enumDecode(_$SyncOperationEnumMap, json['op']),
      collection: json['collection'] as String,
      payload: json['payload'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      lastAttemptAt: json['lastAttemptAt'] == null
          ? null
          : DateTime.parse(json['lastAttemptAt'] as String),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$PendingOperationImplToJson(
        _$PendingOperationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'op': _$SyncOperationEnumMap[instance.op]!,
      'collection': instance.collection,
      'payload': instance.payload,
      'createdAt': instance.createdAt.toIso8601String(),
      'retryCount': instance.retryCount,
      'lastAttemptAt': instance.lastAttemptAt?.toIso8601String(),
      'errorMessage': instance.errorMessage,
    };

const _$SyncOperationEnumMap = {
  SyncOperation.upsert: 'UPSERT',
  SyncOperation.delete: 'DELETE',
};

_$ExerciseLogImpl _$$ExerciseLogImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseLogImpl(
      exerciseId: json['exerciseId'] as String,
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      rpe: (json['rpe'] as num).toInt(),
      estimated1RM: (json['estimated1RM'] as num?)?.toDouble(),
      isPR: json['isPR'] as bool?,
      note: json['note'] as String?,
      completed: json['completed'] as bool? ?? true,
    );

Map<String, dynamic> _$$ExerciseLogImplToJson(_$ExerciseLogImpl instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'date': instance.date.toIso8601String(),
      'weight': instance.weight,
      'reps': instance.reps,
      'rpe': instance.rpe,
      'estimated1RM': instance.estimated1RM,
      'isPR': instance.isPR,
      'note': instance.note,
      'completed': instance.completed,
    };

_$WorkoutSessionImpl _$$WorkoutSessionImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutSessionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deviceId: json['deviceId'] as String,
      conflicted: json['conflicted'] as bool? ?? false,
      date: DateTime.parse(json['date'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      planId: json['planId'] as String,
      exerciseLogs: (json['exerciseLogs'] as List<dynamic>?)
              ?.map((e) => ExerciseLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      status: $enumDecode(_$SessionStatusEnumMap, json['status']),
      note: json['note'] as String?,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      synced: json['synced'] as bool? ?? false,
    );

Map<String, dynamic> _$$WorkoutSessionImplToJson(
        _$WorkoutSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deviceId': instance.deviceId,
      'conflicted': instance.conflicted,
      'date': instance.date.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'planId': instance.planId,
      'exerciseLogs': instance.exerciseLogs,
      'status': _$SessionStatusEnumMap[instance.status]!,
      'note': instance.note,
      'durationMinutes': instance.durationMinutes,
      'synced': instance.synced,
    };

const _$SessionStatusEnumMap = {
  SessionStatus.planned: 'planned',
  SessionStatus.active: 'active',
  SessionStatus.inProgress: 'inProgress',
  SessionStatus.paused: 'paused',
  SessionStatus.completed: 'completed',
  SessionStatus.done: 'done',
  SessionStatus.cancelled: 'cancelled',
};
