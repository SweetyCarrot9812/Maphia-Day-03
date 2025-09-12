// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_coach_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AICoachInputImpl _$$AICoachInputImplFromJson(Map<String, dynamic> json) =>
    _$AICoachInputImpl(
      date: json['date'] as String,
      goal: $enumDecode(_$WorkoutGoalEnumMap, json['goal']),
      availableMinutes: (json['availableMinutes'] as num).toInt(),
      equipment:
          (json['equipment'] as List<dynamic>).map((e) => e as String).toList(),
      injuries: (json['injuries'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      fatigueScore: (json['fatigueScore'] as num).toInt(),
      oneRM: (json['oneRM'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      preferredDays: (json['preferredDays'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      timeOfDay: $enumDecodeNullable(_$TimeOfDayEnumMap, json['timeOfDay']),
      recentLogsSummary: json['recentLogsSummary'] == null
          ? null
          : RecentLogsSummary.fromJson(
              json['recentLogsSummary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AICoachInputImplToJson(_$AICoachInputImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'goal': _$WorkoutGoalEnumMap[instance.goal]!,
      'availableMinutes': instance.availableMinutes,
      'equipment': instance.equipment,
      'injuries': instance.injuries,
      'fatigueScore': instance.fatigueScore,
      'oneRM': instance.oneRM,
      'preferredDays': instance.preferredDays,
      'timeOfDay': _$TimeOfDayEnumMap[instance.timeOfDay],
      'recentLogsSummary': instance.recentLogsSummary,
    };

const _$WorkoutGoalEnumMap = {
  WorkoutGoal.strength: 'strength',
  WorkoutGoal.hypertrophy: 'hypertrophy',
  WorkoutGoal.fatloss: 'fatloss',
  WorkoutGoal.running: 'running',
  WorkoutGoal.mixed: 'mixed',
};

const _$TimeOfDayEnumMap = {
  TimeOfDay.am: 'AM',
  TimeOfDay.pm: 'PM',
};

_$RecentLogsSummaryImpl _$$RecentLogsSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$RecentLogsSummaryImpl(
      last7dSessions: (json['last7dSessions'] as num).toInt(),
      avgRpe: (json['avgRpe'] as num).toDouble(),
      muscleGroupFrequency:
          (json['muscleGroupFrequency'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const <String, int>{},
      lastWorkoutDate: json['lastWorkoutDate'] == null
          ? null
          : DateTime.parse(json['lastWorkoutDate'] as String),
    );

Map<String, dynamic> _$$RecentLogsSummaryImplToJson(
        _$RecentLogsSummaryImpl instance) =>
    <String, dynamic>{
      'last7dSessions': instance.last7dSessions,
      'avgRpe': instance.avgRpe,
      'muscleGroupFrequency': instance.muscleGroupFrequency,
      'lastWorkoutDate': instance.lastWorkoutDate?.toIso8601String(),
    };

_$AICoachOutputImpl _$$AICoachOutputImplFromJson(Map<String, dynamic> json) =>
    _$AICoachOutputImpl(
      planId: json['planId'] as String,
      goal: $enumDecode(_$WorkoutGoalEnumMap, json['goal']),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      estimatedDurationMinutes:
          (json['estimatedDurationMinutes'] as num?)?.toInt(),
      tips:
          (json['tips'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
    );

Map<String, dynamic> _$$AICoachOutputImplToJson(_$AICoachOutputImpl instance) =>
    <String, dynamic>{
      'planId': instance.planId,
      'goal': _$WorkoutGoalEnumMap[instance.goal]!,
      'exercises': instance.exercises,
      'notes': instance.notes,
      'estimatedDurationMinutes': instance.estimatedDurationMinutes,
      'tips': instance.tips,
    };
