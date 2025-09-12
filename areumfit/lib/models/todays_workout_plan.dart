import 'package:freezed_annotation/freezed_annotation.dart';
import 'exercise_recommendation.dart';

part 'todays_workout_plan.freezed.dart';
part 'todays_workout_plan.g.dart';

@freezed
class TodaysWorkoutPlan with _$TodaysWorkoutPlan {
  const factory TodaysWorkoutPlan({
    @Default(false) bool isRestDay,
    @Default(<String>[]) List<String> primaryMuscleGroups,
    @Default(<ExerciseRecommendation>[]) List<ExerciseRecommendation> exercises,
    @Default('') String dailyReasoning,
    @Default(<String>[]) List<String> tips,
  }) = _TodaysWorkoutPlan;

  factory TodaysWorkoutPlan.fromJson(Map<String, dynamic> json) =>
      _$TodaysWorkoutPlanFromJson(json);
}

