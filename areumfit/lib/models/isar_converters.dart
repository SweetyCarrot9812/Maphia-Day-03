import 'dart:convert';

import 'package:areumfit/models/isar_models.dart';
import 'package:areumfit/models/workout_log.dart';
import 'package:areumfit/models/base_model.dart';

extension LocalSessionX on LocalSession {
  WorkoutSession toWorkoutSession() {
    // Note: exerciseLogs are not stored directly; keep empty for now.
    final mappedStatus = _mapStatus(status);

    return WorkoutSession(
      id: sessionId,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deviceId: deviceId,
      conflicted: conflicted,
      date: date,
      status: mappedStatus,
      planId: planId,
      exerciseLogs: const [],
      startedAt: startedAt,
      completedAt: completedAt,
      durationMinutes: durationMinutes,
    );
  }

  SessionStatus _mapStatus(String raw) {
    switch (raw) {
      case 'planned':
        return SessionStatus.planned;
      case 'active':
        return SessionStatus.active;
      case 'in_progress':
        return SessionStatus.inProgress;
      case 'paused':
        return SessionStatus.paused;
      case 'completed':
        return SessionStatus.completed;
      case 'done':
        return SessionStatus.done;
      case 'cancelled':
        return SessionStatus.cancelled;
      default:
        return SessionStatus.planned;
    }
  }
}

extension LocalLogX on LocalLog {
  WorkoutLog toWorkoutLog() {
    return WorkoutLog(
      id: logId,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deviceId: deviceId,
      conflicted: conflicted,
      sessionId: sessionId,
      exerciseKey: exerciseKey,
      setIndex: setIndex,
      weight: weight,
      reps: reps,
      rpe: rpe,
      completedAt: completedAt,
      note: note,
      isPR: isPR,
      estimated1RM: estimated1RM,
    );
  }
}

