import 'package:freezed_annotation/freezed_annotation.dart';
import 'base_model.dart';
import 'workout_plan.dart';

part 'ai_coach_models.freezed.dart';
part 'ai_coach_models.g.dart';

// AI Coach Input/Output models
@freezed
class AICoachInput with _$AICoachInput {
  const factory AICoachInput({
    required String date, // YYYY-MM-DD
    required WorkoutGoal goal,
    required int availableMinutes,
    required List<String> equipment,
    @Default(<String>[]) List<String> injuries,
    required int fatigueScore, // 0-10
    required Map<String, double> oneRM,
    required List<String> preferredDays,
    TimeOfDay? timeOfDay,
    RecentLogsSummary? recentLogsSummary,
  }) = _AICoachInput;

  factory AICoachInput.fromJson(Map<String, dynamic> json) =>
      _$AICoachInputFromJson(json);
}

@freezed
class RecentLogsSummary with _$RecentLogsSummary {
  const factory RecentLogsSummary({
    required int last7dSessions,
    required double avgRpe,
    @Default(<String, int>{}) Map<String, int> muscleGroupFrequency,
    DateTime? lastWorkoutDate,
  }) = _RecentLogsSummary;

  factory RecentLogsSummary.fromJson(Map<String, dynamic> json) =>
      _$RecentLogsSummaryFromJson(json);
}

@freezed
class AICoachOutput with _$AICoachOutput {
  const factory AICoachOutput({
    required String planId,
    required WorkoutGoal goal,
    required List<Exercise> exercises,
    String? notes,
    int? estimatedDurationMinutes,
    @Default(<String>[]) List<String> tips,
  }) = _AICoachOutput;

  factory AICoachOutput.fromJson(Map<String, dynamic> json) =>
      _$AICoachOutputFromJson(json);
}