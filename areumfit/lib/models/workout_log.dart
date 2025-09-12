import 'package:freezed_annotation/freezed_annotation.dart';
import 'base_model.dart';

part 'workout_log.freezed.dart';
part 'workout_log.g.dart';

@freezed
class WorkoutLog with _$WorkoutLog {
  const factory WorkoutLog({
    required String id,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String deviceId,
    @Default(false) bool conflicted,
    // Log specific fields
    required String sessionId,
    required String exerciseKey,
    required int setIndex, // 0-based index
    required double weight, // in kg or lbs
    required int reps,
    required int rpe, // 6-10 scale
    required DateTime completedAt,
    String? note,
    @Default(false) bool isPR, // Personal Record
    // Calculated fields
    double? estimated1RM, // Epley: weight * (1 + reps/30)
  }) = _WorkoutLog;

  factory WorkoutLog.fromJson(Map<String, dynamic> json) =>
      _$WorkoutLogFromJson(json);
}

// Local cache models for offline-first approach
@freezed
class LocalPlanCache with _$LocalPlanCache {
  const factory LocalPlanCache({
    required String cacheKey,
    required String payload, // JSON string
    required int ttlEpoch, // Expiration timestamp
    required DateTime createdAt,
  }) = _LocalPlanCache;

  factory LocalPlanCache.fromJson(Map<String, dynamic> json) =>
      _$LocalPlanCacheFromJson(json);
}

// Outbox for offline sync
@JsonEnum()
enum SyncOperation {
  @JsonValue('UPSERT')
  upsert,
  @JsonValue('DELETE')
  delete,
}

@freezed
class PendingOperation with _$PendingOperation {
  const factory PendingOperation({
    required String id,
    required SyncOperation op,
    required String collection, // 'sessions', 'logs', etc.
    required String payload, // JSON string
    required DateTime createdAt,
    @Default(0) int retryCount,
    DateTime? lastAttemptAt,
    String? errorMessage,
  }) = _PendingOperation;

  factory PendingOperation.fromJson(Map<String, dynamic> json) =>
      _$PendingOperationFromJson(json);
}

/// ExerciseLog 모델 - 운동별 기록 집계
@freezed
class ExerciseLog with _$ExerciseLog {
  const factory ExerciseLog({
    required String exerciseId,
    required DateTime date,
    required double weight,
    required int reps,
    required int rpe,
    double? estimated1RM,
    bool? isPR,
    String? note,
    @Default(true) bool completed,
  }) = _ExerciseLog;

  factory ExerciseLog.fromJson(Map<String, dynamic> json) =>
      _$ExerciseLogFromJson(json);
}

/// WorkoutSession 모델 - 운동 세션 관리
@freezed
class WorkoutSession with _$WorkoutSession {
  const factory WorkoutSession({
    required String id,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String deviceId,
    @Default(false) bool conflicted,
    required DateTime date,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? completedAt,
    required String planId,
    @Default([]) List<ExerciseLog> exerciseLogs,
    required SessionStatus status, // Using enum instead of String
    String? note,
    int? durationMinutes,
    @Default(false) bool synced,
  }) = _WorkoutSession;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionFromJson(json);
}

// SessionStatus and ExerciseType enums are now imported from base_model.dart

// AI Coach Input/Output models - moved to separate file to avoid circular dependency