// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseRecommendationImpl _$$ExerciseRecommendationImplFromJson(
        Map<String, dynamic> json) =>
    _$ExerciseRecommendationImpl(
      name: json['name'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      sets: (json['sets'] as num?)?.toInt() ?? 0,
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 0,
      rpe: (json['rpe'] as num?)?.toDouble() ?? 8.0,
      priority: json['priority'] as String? ?? 'medium',
      reasoning: json['reasoning'] as String? ?? '',
    );

Map<String, dynamic> _$$ExerciseRecommendationImplToJson(
        _$ExerciseRecommendationImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'weight': instance.weight,
      'reps': instance.reps,
      'sets': instance.sets,
      'restSeconds': instance.restSeconds,
      'rpe': instance.rpe,
      'priority': instance.priority,
      'reasoning': instance.reasoning,
    };
