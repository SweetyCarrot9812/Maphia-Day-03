// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutPlanImpl _$$WorkoutPlanImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutPlanImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deviceId: json['deviceId'] as String,
      conflicted: json['conflicted'] as bool? ?? false,
      startDate: DateTime.parse(json['startDate'] as String),
      rrule: RRule.fromJson(json['rrule'] as Map<String, dynamic>),
      goal: $enumDecode(_$WorkoutGoalEnumMap, json['goal']),
      source: $enumDecode(_$PlanSourceEnumMap, json['source']),
      cacheKey: json['cacheKey'] as String?,
    );

Map<String, dynamic> _$$WorkoutPlanImplToJson(_$WorkoutPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deviceId': instance.deviceId,
      'conflicted': instance.conflicted,
      'startDate': instance.startDate.toIso8601String(),
      'rrule': instance.rrule,
      'goal': _$WorkoutGoalEnumMap[instance.goal]!,
      'source': _$PlanSourceEnumMap[instance.source]!,
      'cacheKey': instance.cacheKey,
    };

const _$WorkoutGoalEnumMap = {
  WorkoutGoal.strength: 'strength',
  WorkoutGoal.hypertrophy: 'hypertrophy',
  WorkoutGoal.fatloss: 'fatloss',
  WorkoutGoal.running: 'running',
  WorkoutGoal.mixed: 'mixed',
};

const _$PlanSourceEnumMap = {
  PlanSource.ai: 'ai',
  PlanSource.manual: 'manual',
};

_$ExerciseImpl _$$ExerciseImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseImpl(
      key: json['key'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$ExerciseTypeEnumMap, json['type']),
      targetSets: (json['targetSets'] as num).toInt(),
      restSec: (json['restSec'] as num).toInt(),
      tempo: json['tempo'] as String?,
      notes: json['notes'] as String?,
      prescription: json['prescription'] == null
          ? null
          : ExercisePrescription.fromJson(
              json['prescription'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ExerciseImplToJson(_$ExerciseImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'type': _$ExerciseTypeEnumMap[instance.type]!,
      'targetSets': instance.targetSets,
      'restSec': instance.restSec,
      'tempo': instance.tempo,
      'notes': instance.notes,
      'prescription': instance.prescription,
    };

const _$ExerciseTypeEnumMap = {
  ExerciseType.strength: 'strength',
  ExerciseType.compound: 'compound',
  ExerciseType.isolation: 'isolation',
  ExerciseType.cardio: 'cardio',
  ExerciseType.accessory: 'accessory',
  ExerciseType.hiit: 'hiit',
  ExerciseType.emom: 'emom',
  ExerciseType.amrap: 'amrap',
};

_$ExercisePrescriptionImpl _$$ExercisePrescriptionImplFromJson(
        Map<String, dynamic> json) =>
    _$ExercisePrescriptionImpl(
      percent1RM: (json['percent1RM'] as num?)?.toDouble(),
      reps: (json['reps'] as num?)?.toInt(),
      rpe: (json['rpe'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$ExercisePrescriptionImplToJson(
        _$ExercisePrescriptionImpl instance) =>
    <String, dynamic>{
      'percent1RM': instance.percent1RM,
      'reps': instance.reps,
      'rpe': instance.rpe,
      'weight': instance.weight,
    };
