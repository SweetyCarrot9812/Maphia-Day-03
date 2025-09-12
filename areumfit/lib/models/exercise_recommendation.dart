import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_recommendation.freezed.dart';
part 'exercise_recommendation.g.dart';

@freezed
class ExerciseRecommendation with _$ExerciseRecommendation {
  const factory ExerciseRecommendation({
    @Default('') String name,
    @Default(0.0) double weight,
    @Default(0) int reps,
    @Default(0) int sets,
    @Default(0) int restSeconds,
    @Default(8.0) double rpe,
    @Default('medium') String priority,
    @Default('') String reasoning,
  }) = _ExerciseRecommendation;

  factory ExerciseRecommendation.fromJson(Map<String, dynamic> json) =>
      _$ExerciseRecommendationFromJson(json);
}

