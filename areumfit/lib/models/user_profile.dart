import 'package:freezed_annotation/freezed_annotation.dart';
import 'base_model.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String deviceId,
    @Default(false) bool conflicted,
    // Profile specific fields
    required String name,
    required Sex sex,
    required int heightCm,
    required double weightKg,
    @Default(WeightUnit.kg) WeightUnit unit,
    @Default(<String>[]) List<String> injuries,
    @Default(<String>[]) List<String> preferredDays,
    @Default(<String>[]) List<String> equipment,
    @Default(6) int rpeMin,
    @Default(9) int rpeMax,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
class UserMetrics with _$UserMetrics {
  const factory UserMetrics({
    required String id,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String deviceId,
    @Default(false) bool conflicted,
    // Metrics specific fields
    @Default(<String, double>{}) Map<String, double> oneRM,
    @Default(5) int fatigueScore, // 0-10 scale
    @Default(8.0) double sleepHours,
    DateTime? lastPRAt,
  }) = _UserMetrics;

  factory UserMetrics.fromJson(Map<String, dynamic> json) =>
      _$UserMetricsFromJson(json);
}

@freezed
class UserWorkoutStats with _$UserWorkoutStats {
  const factory UserWorkoutStats({
    required String userId,
    @Default(0) int totalSessions,
    @Default(0) int completedSessions,
    @Default(0) int thisWeekSessions,
    @Default(0) int thisMonthSessions,
    @Default(0.0) double averageRPE,
    @Default(0) int totalMinutes,
    @Default(0) int longestStreak,
    @Default(0) int currentStreak,
    DateTime? lastSessionAt,
    @Default(<String, double>{}) Map<String, double> bestLifts,
    @Default(<String>[]) List<String> achievements,
  }) = _UserWorkoutStats;

  factory UserWorkoutStats.fromJson(Map<String, dynamic> json) =>
      _$UserWorkoutStatsFromJson(json);
}

@freezed
class RRule with _$RRule {
  const factory RRule({
    @Default(<String>[]) List<String> byWeekday, // ['Mon', 'Wed', 'Fri']
    @Default(4) int weeks, // Number of weeks to repeat
    TimeOfDay? timeOfDay, // AM, PM, or null for any time
  }) = _RRule;

  factory RRule.fromJson(Map<String, dynamic> json) =>
      _$RRuleFromJson(json);
}