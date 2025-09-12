import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todays_workout_plan.dart';

class RecommendationCache {
  String _key(String userId, DateTime date) =>
      'workoutPlan:$userId:${date.toIso8601String().substring(0, 10)}';

  Future<void> save(
    String userId,
    TodaysWorkoutPlan plan, {
    DateTime? date,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(userId, date ?? DateTime.now());
    await prefs.setString(key, jsonEncode(plan.toJson()));
  }

  Future<TodaysWorkoutPlan?> load(
    String userId, {
    DateTime? date,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(userId, date ?? DateTime.now());
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return TodaysWorkoutPlan.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear(String userId, {DateTime? date}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(userId, date ?? DateTime.now());
    await prefs.remove(key);
  }
}

