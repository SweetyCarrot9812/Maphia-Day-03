// import 'dart:convert';
// import 'package:drift/drift.dart';
// import '../db/database.dart';
import '../models/todays_workout_plan.dart';
// import '../models/exercise_recommendation.dart';
import 'ai_coach_service.dart';

class RecommendationService {
  // final AreumfitDatabase _database;
  final AICoachService _aiService;

  RecommendationService(this._aiService);

  /// 오늘의 추천 운동을 가져오거나 생성합니다
  Future<TodaysWorkoutPlan> getTodaysWorkoutPlan({
    required String userId,
    Map<String, dynamic>? currentCondition,
    bool forceRefresh = false,
  }) async {
    // 데이터베이스가 비활성화된 상태에서는 항상 AI 서비스를 직접 호출합니다
    final aiRecommendation = await _aiService.generateTodaysWorkout(
      userId: userId,
      currentCondition: currentCondition ?? _getDefaultCondition(),
    );

    return aiRecommendation;
  }

  /// 기본 컨디션 반환
  Map<String, dynamic> _getDefaultCondition() {
    return {
      'energy': 'good',
      'soreness': 'none',
      'sleep': 8,
      'stress': 'low',
      'motivation': 'high',
    };
  }

  /// 운동 성과를 업데이트합니다 (데이터베이스 비활성화로 인해 로깅만 함)
  Future<void> updateExercisePerformance({
    required String userId,
    required String exerciseId,
    required String exerciseName,
    required double weight,
    required int reps,
    required double rpe,
  }) async {
    // TODO: 데이터베이스 활성화 시 실제 저장 구현
    // Debug: Exercise performance updated: $exerciseName - ${weight}kg x $reps @ RPE $rpe
  }
}