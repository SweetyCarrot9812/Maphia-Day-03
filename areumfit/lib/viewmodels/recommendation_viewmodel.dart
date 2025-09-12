import 'package:flutter/foundation.dart';
import '../models/todays_workout_plan.dart';
import '../models/exercise_recommendation.dart';
import '../services/recommendation_service.dart';
// import '../db/database.dart';

enum RecommendationState {
  initial,
  loading,
  loaded,
  error,
  offline
}

class RecommendationViewModel extends ChangeNotifier {
  final RecommendationService _recommendationService;
  // final AreumfitDatabase? _database;

  // State
  RecommendationState _state = RecommendationState.initial;
  TodaysWorkoutPlan? _workoutPlan;
  String? _errorMessage;
  DateTime? _lastUpdated;

  // User context
  String _userId = 'demo_user';
  Map<String, dynamic>? _currentCondition;

  RecommendationViewModel(this._recommendationService);

  // Getters
  RecommendationState get state => _state;
  TodaysWorkoutPlan? get workoutPlan => _workoutPlan;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;
  bool get isLoading => _state == RecommendationState.loading;
  bool get hasError => _state == RecommendationState.error;
  bool get hasData => _workoutPlan != null;
  bool get isRestDay => _workoutPlan?.isRestDay ?? false;

  // User context getters/setters
  String get userId => _userId;
  Map<String, dynamic>? get currentCondition => _currentCondition;

  void setUserId(String userId) {
    if (_userId != userId) {
      _userId = userId;
      // Clear previous user's data
      _workoutPlan = null;
      _lastUpdated = null;
      _state = RecommendationState.initial;
      notifyListeners();
    }
  }

  void setCurrentCondition(Map<String, dynamic>? condition) {
    _currentCondition = condition;
  }

  /// Load today's workout recommendation
  Future<void> loadTodaysWorkout({bool forceRefresh = false}) async {
    if (_state == RecommendationState.loading) return;

    // Skip if we have fresh data and not forcing refresh
    if (!forceRefresh && 
        _workoutPlan != null && 
        _lastUpdated != null &&
        _isSameDay(_lastUpdated!, DateTime.now())) {
      return;
    }

    _setState(RecommendationState.loading);

    try {
      final plan = await _recommendationService.getTodaysWorkoutPlan(
        userId: _userId,
        currentCondition: _currentCondition,
        forceRefresh: forceRefresh,
      );

      _workoutPlan = plan;
      _lastUpdated = DateTime.now();
      _errorMessage = null;
      _setState(RecommendationState.loaded);

      // TODO: Save to database when database is enabled

    } catch (e) {
      _errorMessage = _parseError(e);
      _setState(RecommendationState.error);
      
      // Try to load from offline cache or database
      await _loadOfflineData();
    }
  }

  /// Refresh workout plan
  Future<void> refreshWorkout() async {
    await loadTodaysWorkout(forceRefresh: true);
  }

  /// Update current condition and refresh if needed
  Future<void> updateCondition(Map<String, dynamic> condition) async {
    setCurrentCondition(condition);
    
    // Refresh if we have current data (condition changed)
    if (_workoutPlan != null) {
      await refreshWorkout();
    }
  }

  /// Mark exercise as started
  void startExercise(String exerciseName) {
    if (_workoutPlan == null) return;

    // Update exercise status or navigate to workout screen
    // This could trigger navigation or update local state
    _notifyExerciseStarted(exerciseName);
  }

  /// Get exercise by name
  ExerciseRecommendation? getExerciseByName(String name) {
    final exercises = _workoutPlan?.exercises;
    if (exercises == null) return null;
    
    try {
      return exercises.firstWhere((ex) => ex.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Check if plan is fresh (same day)
  bool get isFresh {
    if (_lastUpdated == null) return false;
    return _isSameDay(_lastUpdated!, DateTime.now());
  }

  /// Get formatted date string
  String get todayDateString {
    final now = DateTime.now();
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return '${now.month}월 ${now.day}일 (${weekdays[now.weekday % 7]})';
  }

  // Private methods
  void _setState(RecommendationState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  String _parseError(dynamic error) {
    if (error.toString().contains('Connection') ||
        error.toString().contains('Network') ||
        error.toString().contains('Socket')) {
      return 'NETWORK_ERROR';
    } else if (error.toString().contains('API') || 
               error.toString().contains('401') ||
               error.toString().contains('403')) {
      return 'AI_SERVICE_ERROR';
    } else {
      return 'UNKNOWN_ERROR';
    }
  }

  Future<void> _loadOfflineData() async {
    // Try to load from database or show cached data
    if (_workoutPlan != null && _lastUpdated != null) {
      // We have some cached data, show it with offline indicator
      _setState(RecommendationState.offline);
    }
    // Could also load from database here if we stored previous recommendations
  }

  // TODO: Database methods will be re-enabled when database is fixed

  void _notifyExerciseStarted(String exerciseName) {
    // Could emit events or trigger navigation
    debugPrint('Exercise started: $exerciseName');
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Cleanup resources when needed
}