import '../models/workout_log.dart';

extension ExerciseLogExtensions on ExerciseLog {
  bool get completed => true; // Simple implementation for now
}

extension WorkoutSessionExtensions on WorkoutSession {
  List<ExerciseLog> get exerciseLogs => []; // Simple implementation for now
}

class OneRMCalculator {
  static double calculate(double weight, int reps) {
    // Brzycki formula: 1RM = weight / (1.0278 - 0.0278 * reps)
    if (reps == 1) return weight;
    return weight / (1.0278 - 0.0278 * reps);
  }
}