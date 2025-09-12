// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todays_workout_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TodaysWorkoutPlanImpl _$$TodaysWorkoutPlanImplFromJson(
        Map<String, dynamic> json) =>
    _$TodaysWorkoutPlanImpl(
      isRestDay: json['isRestDay'] as bool? ?? false,
      primaryMuscleGroups: (json['primaryMuscleGroups'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) =>
                  ExerciseRecommendation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ExerciseRecommendation>[],
      dailyReasoning: json['dailyReasoning'] as String? ?? '',
      tips:
          (json['tips'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
    );

Map<String, dynamic> _$$TodaysWorkoutPlanImplToJson(
        _$TodaysWorkoutPlanImpl instance) =>
    <String, dynamic>{
      'isRestDay': instance.isRestDay,
      'primaryMuscleGroups': instance.primaryMuscleGroups,
      'exercises': instance.exercises,
      'dailyReasoning': instance.dailyReasoning,
      'tips': instance.tips,
    };
