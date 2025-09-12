import 'package:freezed_annotation/freezed_annotation.dart';
import 'base_model.dart';
import 'user_profile.dart';

part 'workout_plan.freezed.dart';
part 'workout_plan.g.dart';

@freezed
class WorkoutPlan with _$WorkoutPlan {
  const factory WorkoutPlan({
    required String id,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String deviceId,
    @Default(false) bool conflicted,
    // Plan specific fields
    required DateTime startDate,
    required RRule rrule,
    required WorkoutGoal goal,
    required PlanSource source,
    String? cacheKey,
  }) = _WorkoutPlan;

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) =>
      _$WorkoutPlanFromJson(json);
}

@freezed
class Exercise with _$Exercise {
  const factory Exercise({
    required String key,
    required String name,
    required ExerciseType type,
    required int targetSets,
    required int restSec,
    String? tempo, // e.g., "3-1-2-0"
    String? notes,
    // AI Prescription data
    ExercisePrescription? prescription,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
}

@freezed
class ExercisePrescription with _$ExercisePrescription {
  const factory ExercisePrescription({
    double? percent1RM, // Percentage of 1RM (e.g., 70.0)
    int? reps, // Target reps
    int? rpe, // Target RPE (6-10)
    double? weight, // Specific weight in kg/lbs
  }) = _ExercisePrescription;

  factory ExercisePrescription.fromJson(Map<String, dynamic> json) =>
      _$ExercisePrescriptionFromJson(json);
}

// WorkoutSession 정의는 workout_log.dart로 이동됨