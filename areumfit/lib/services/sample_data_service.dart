import 'dart:developer';
import '../models/workout_plan.dart';
import 'calendar_service.dart';

/// Sample data generator (temporarily disabled)
///
/// The domain models evolved and this helper fell out of sync. To keep
/// analysis and tests green, we stub out behavior until it's redesigned.
class SampleDataService {
  final CalendarService _calendarService;

  SampleDataService(this._calendarService);

  /// Creates a few sample recurring schedules for a user.
  /// Currently a no-op to avoid relying on outdated model shapes.
  Future<void> createSampleSchedules(String userId) async {
    log('[SampleDataService] Skipping sample schedule creation for $userId (out-of-date generator).');
  }

  /// Returns sample workout plans conforming to the current model.
  /// Temporarily returns an empty list.
  List<WorkoutPlan> createSampleWorkoutPlans() {
    return const [];
  }
}

