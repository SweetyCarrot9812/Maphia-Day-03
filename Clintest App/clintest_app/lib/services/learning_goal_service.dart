import '../models/learning_goal.dart';
import '../services/database_service.dart';
import '../services/skill_assessment_service.dart';
import '../services/statistics_service.dart';
import '../models/user_statistics.dart';

class LearningGoalService {
  static final LearningGoalService _instance = LearningGoalService._internal();
  factory LearningGoalService() => _instance;
  LearningGoalService._internal();
  
  static LearningGoalService get instance => _instance;
  
  // 목표 생성
  static Future<LearningGoal> createGoal({
    required String userId,
    required String title,
    String? description,
    required String category,
    required GoalType type,
    required int targetValue,
    required String targetUnit,
    DateTime? targetDate,
    GoalPriority priority = GoalPriority.medium,
    GoalDifficulty difficulty = GoalDifficulty.intermediate,
    List<String> competencyAreas = const [],
  }) async {
    final isar = await DatabaseService.instance.database;
    
    final goal = LearningGoal.create(
      userId: userId,
      title: title,
      description: description,
      category: category,
      type: type,
      targetValue: targetValue,
      targetUnit: targetUnit,
      targetDate: targetDate,
      priority: priority,
      difficulty: difficulty,
      competencyAreas: competencyAreas,
    );
    
    // Add intelligent milestones based on goal type
    _addIntelligentMilestones(goal);
    
    await isar.writeTxn(() async {
      await isar.learningGoals.put(goal);
    });
    
    return goal;
  }
  
  // 지능형 마일스톤 자동 생성
  static void _addIntelligentMilestones(LearningGoal goal) {
    int quarterTarget = (goal.targetValue * 0.25).round();
    int halfTarget = (goal.targetValue * 0.5).round();
    int threeQuarterTarget = (goal.targetValue * 0.75).round();
    
    switch (goal.type) {
      case GoalType.accuracy:
        goal.addMilestone('기초 정확도 달성', quarterTarget, reward: '정확도 뱃지');
        goal.addMilestone('중급 정확도 달성', halfTarget, reward: '꾸준함 뱃지');
        goal.addMilestone('고급 정확도 달성', threeQuarterTarget, reward: '우수함 뱃지');
        break;
      case GoalType.volume:
        goal.addMilestone('워밍업 완료', quarterTarget, reward: '시작 뱃지');
        goal.addMilestone('중간 지점 돌파', halfTarget, reward: '지속력 뱃지');
        goal.addMilestone('목표 근접', threeQuarterTarget, reward: '노력 뱃지');
        break;
      case GoalType.consistency:
        goal.addMilestone('일주일 연속', 7, reward: '습관 형성 뱃지');
        goal.addMilestone('2주 연속', 14, reward: '꾸준함 뱃지');
        goal.addMilestone('한달 연속', 30, reward: '마스터 뱃지');
        break;
      case GoalType.mastery:
        goal.addMilestone('기초 이해', quarterTarget, reward: '학습자 뱃지');
        goal.addMilestone('실력 향상', halfTarget, reward: '발전 뱃지');
        goal.addMilestone('숙련도 달성', threeQuarterTarget, reward: '전문성 뱃지');
        break;
      case GoalType.speed:
        goal.addMilestone('속도 개선 시작', quarterTarget, reward: '빠름 뱃지');
        goal.addMilestone('평균 속도 달성', halfTarget, reward: '효율성 뱃지');
        goal.addMilestone('고속 처리', threeQuarterTarget, reward: '번개 뱃지');
        break;
      case GoalType.comprehensive:
        goal.addMilestone('종합 기초', quarterTarget, reward: '종합력 뱃지');
        goal.addMilestone('균형 발전', halfTarget, reward: '올라운더 뱃지');
        goal.addMilestone('전면 향상', threeQuarterTarget, reward: '완성도 뱃지');
        break;
    }
  }
  
  // 사용자 목표 조회
  static Future<List<LearningGoal>> getUserGoals(String userId, {GoalStatus? status}) async {
    final isar = await DatabaseService.instance.database;
    
    var query = isar.learningGoals
        .where()
        .userIdEqualTo(userId);
    
    if (status != null) {
      query = query.filter().statusEqualTo(status);
    }
    
    return await query.sortByCreatedAtDesc().findAll();
  }
  
  // 활성 목표 조회
  static Future<List<LearningGoal>> getActiveGoals(String userId) async {
    return getUserGoals(userId, status: GoalStatus.active);
  }
  
  // 완료된 목표 조회
  static Future<List<LearningGoal>> getCompletedGoals(String userId) async {
    return getUserGoals(userId, status: GoalStatus.completed);
  }
  
  // 우선순위 목표 조회
  static Future<List<LearningGoal>> getHighPriorityGoals(String userId) async {
    final isar = await DatabaseService.instance.database;
    
    return await isar.learningGoals
        .where()
        .userIdEqualTo(userId)
        .filter()
        .statusEqualTo(GoalStatus.active)
        .and()
        .group((q) => q
            .priorityEqualTo(GoalPriority.high)
            .or()
            .priorityEqualTo(GoalPriority.critical))
        .sortByPriority()
        .findAll();
  }
  
  // 마감 임박 목표 조회
  static Future<List<LearningGoal>> getUpcomingDeadlineGoals(String userId, {int daysAhead = 7}) async {
    final isar = await DatabaseService.instance.database;
    final cutoffDate = DateTime.now().add(Duration(days: daysAhead));
    
    final goals = await isar.learningGoals
        .where()
        .userIdEqualTo(userId)
        .filter()
        .statusEqualTo(GoalStatus.active)
        .findAll();
    
    return goals.where((goal) {
      return goal.targetDate != null && 
             goal.targetDate!.isBefore(cutoffDate) && 
             goal.targetDate!.isAfter(DateTime.now());
    }).toList();
  }
  
  // 목표 진도 업데이트
  static Future<void> updateGoalProgress(String userId, int goalId, int newValue) async {
    final isar = await DatabaseService.instance.database;
    
    final goal = await isar.learningGoals.get(goalId);
    if (goal == null || goal.userId != userId) return;
    
    await isar.writeTxn(() async {
      goal.updateProgress(newValue);
      await isar.learningGoals.put(goal);
    });
    
    // Check for achievements
    await _checkAchievements(userId, goal);
  }
  
  // 자동 진도 업데이트 (통계 기반)
  static Future<void> updateGoalsFromStatistics(String userId) async {
    final goals = await getActiveGoals(userId);
    final stats = await StatisticsService.getUserStatistics(userId);
    
    for (final goal in goals) {
      int newValue = _calculateProgressFromStats(goal, stats);
      if (newValue > goal.currentValue) {
        await updateGoalProgress(userId, goal.id!, newValue);
      }
    }
  }
  
  static int _calculateProgressFromStats(LearningGoal goal, UserStatistics stats) {
    switch (goal.type) {
      case GoalType.accuracy:
        return ((stats.overallAccuracy ?? 0.0) * 100).round();
      case GoalType.volume:
        return stats.totalProblemsAttempted ?? 0;
      case GoalType.consistency:
        return stats.studyStreak ?? 0;
      case GoalType.mastery:
        // Calculate based on category-specific accuracy
        return ((stats.overallAccuracy ?? 0.0) * 100).round();
      case GoalType.speed:
        // Calculate based on average response time improvement
        return (stats.averageStudyTimePerSession?.inMinutes ?? 0);
      case GoalType.comprehensive:
        // Overall progress score
        double overallScore = (stats.overallAccuracy ?? 0.0) * 0.4 + 
                             ((stats.totalProblemsAttempted ?? 0) / 10) * 0.3 +
                             ((stats.studyStreak ?? 0) / 30) * 0.3;
        return (overallScore * 100).round().clamp(0, 100);
    }
  }
  
  // 목표 달성 확인 및 보상
  static Future<void> _checkAchievements(String userId, LearningGoal goal) async {
    if (goal.isCompleted) {
      await _awardGoalCompletion(userId, goal);
    }
    
    // Check milestone achievements
    for (final milestone in goal.milestones) {
      if (milestone.isCompleted && milestone.reward != null) {
        await _awardMilestone(userId, goal, milestone);
      }
    }
  }
  
  static Future<void> _awardGoalCompletion(String userId, LearningGoal goal) async {
    // Award XP
    // await UserService.addXP(userId, goal.xpReward);
    
    // Award badges
    for (final badge in goal.badges) {
      // await BadgeService.awardBadge(userId, badge);
    }
    
    // Log achievement
    print('🎉 목표 달성: ${goal.title} - ${goal.xpReward} XP 획득!');
  }
  
  static Future<void> _awardMilestone(String userId, LearningGoal goal, GoalMilestone milestone) async {
    // Award milestone reward
    if (milestone.reward != null) {
      // await BadgeService.awardBadge(userId, milestone.reward!);
    }
    
    print('🏆 마일스톤 달성: ${milestone.title} in ${goal.title}');
  }
  
  // 목표 삭제
  static Future<void> deleteGoal(String userId, int goalId) async {
    final isar = await DatabaseService.instance.database;
    
    final goal = await isar.learningGoals.get(goalId);
    if (goal == null || goal.userId != userId) return;
    
    await isar.writeTxn(() async {
      await isar.learningGoals.delete(goalId);
    });
  }
  
  // 목표 상태 변경
  static Future<void> updateGoalStatus(String userId, int goalId, GoalStatus newStatus) async {
    final isar = await DatabaseService.instance.database;
    
    final goal = await isar.learningGoals.get(goalId);
    if (goal == null || goal.userId != userId) return;
    
    await isar.writeTxn(() async {
      goal.status = newStatus;
      goal.updatedAt = DateTime.now();
      
      if (newStatus == GoalStatus.completed) {
        goal.completionDate = DateTime.now();
      }
      
      await isar.learningGoals.put(goal);
    });
    
    if (newStatus == GoalStatus.completed) {
      await _checkAchievements(userId, goal);
    }
  }
  
  // 지능형 목표 추천
  static Future<List<GoalRecommendation>> recommendGoals(String userId) async {
    final stats = await StatisticsService.getUserStatistics(userId);
    final skillAssessment = await SkillAssessmentService.assessUserSkills(userId);
    final recommendations = <GoalRecommendation>[];
    
    // 정확도 목표 추천
    if ((stats.overallAccuracy ?? 0.0) < 0.8) {
      recommendations.add(GoalRecommendation(
        type: GoalType.accuracy,
        title: '정확도 80% 달성하기',
        description: '문제 풀이 정확도를 80%까지 향상시켜보세요',
        targetValue: 80,
        targetUnit: 'percentage',
        priority: GoalPriority.high,
        difficulty: _getDifficultyForAccuracy(stats.overallAccuracy ?? 0.0),
        estimatedDays: 14,
        category: 'overall',
      ));
    }
    
    // 문제량 목표 추천
    int dailyAverage = (stats.totalProblemsAttempted ?? 0) ~/ (stats.totalStudyDays ?? 1);
    if (dailyAverage < 20) {
      recommendations.add(GoalRecommendation(
        type: GoalType.volume,
        title: '매일 20문제 풀기',
        description: '꾸준한 학습을 위해 하루에 20문제씩 풀어보세요',
        targetValue: 20 * 30, // 30일 목표
        targetUnit: 'questions',
        priority: GoalPriority.medium,
        difficulty: GoalDifficulty.intermediate,
        estimatedDays: 30,
        category: 'overall',
      ));
    }
    
    // 일관성 목표 추천
    if ((stats.studyStreak ?? 0) < 7) {
      recommendations.add(GoalRecommendation(
        type: GoalType.consistency,
        title: '7일 연속 학습하기',
        description: '학습 습관을 형성하기 위해 7일간 연속으로 학습해보세요',
        targetValue: 7,
        targetUnit: 'days',
        priority: GoalPriority.high,
        difficulty: GoalDifficulty.intermediate,
        estimatedDays: 7,
        category: 'overall',
      ));
    }
    
    // 약점 영역 마스터리 목표
    for (final area in skillAssessment.entries) {
      if (area.value.skillLevel.index < 3) { // Below intermediate
        recommendations.add(GoalRecommendation(
          type: GoalType.mastery,
          title: '${area.key} 영역 마스터하기',
          description: '${area.key} 영역의 실력을 향상시켜보세요',
          targetValue: 85,
          targetUnit: 'percentage',
          priority: GoalPriority.medium,
          difficulty: GoalDifficulty.advanced,
          estimatedDays: 21,
          category: area.key,
        ));
      }
    }
    
    return recommendations;
  }
  
  static GoalDifficulty _getDifficultyForAccuracy(double currentAccuracy) {
    if (currentAccuracy < 0.5) return GoalDifficulty.expert;
    if (currentAccuracy < 0.65) return GoalDifficulty.advanced;
    if (currentAccuracy < 0.75) return GoalDifficulty.intermediate;
    return GoalDifficulty.beginner;
  }
  
  // 목표 달성률 통계
  static Future<GoalAchievementStats> getGoalAchievementStats(String userId) async {
    final allGoals = await getUserGoals(userId);
    final completedGoals = allGoals.where((g) => g.isCompleted).toList();
    final activeGoals = allGoals.where((g) => g.status == GoalStatus.active).toList();
    final overdueGoals = allGoals.where((g) => g.isOverdue).toList();
    
    double completionRate = allGoals.isEmpty ? 0.0 : completedGoals.length / allGoals.length;
    
    // Calculate average progress of active goals
    double avgProgress = 0.0;
    if (activeGoals.isNotEmpty) {
      avgProgress = activeGoals.map((g) => g.progressPercentage).reduce((a, b) => a + b) / activeGoals.length;
    }
    
    return GoalAchievementStats(
      totalGoals: allGoals.length,
      completedGoals: completedGoals.length,
      activeGoals: activeGoals.length,
      overdueGoals: overdueGoals.length,
      completionRate: completionRate,
      averageProgress: avgProgress,
      totalXpEarned: completedGoals.fold(0, (sum, goal) => sum + goal.xpReward),
      streakDays: _calculateGoalStreak(completedGoals),
    );
  }
  
  static int _calculateGoalStreak(List<LearningGoal> completedGoals) {
    if (completedGoals.isEmpty) return 0;
    
    completedGoals.sort((a, b) => (b.completionDate ?? DateTime.now()).compareTo(a.completionDate ?? DateTime.now()));
    
    int streak = 0;
    DateTime? lastDate;
    
    for (final goal in completedGoals) {
      if (goal.completionDate == null) continue;
      
      if (lastDate == null) {
        lastDate = goal.completionDate;
        streak = 1;
        continue;
      }
      
      final daysDiff = lastDate.difference(goal.completionDate!).inDays;
      if (daysDiff <= 7) { // Within a week
        streak++;
        lastDate = goal.completionDate;
      } else {
        break;
      }
    }
    
    return streak;
  }
}

// 목표 추천 데이터 클래스
class GoalRecommendation {
  final GoalType type;
  final String title;
  final String description;
  final int targetValue;
  final String targetUnit;
  final GoalPriority priority;
  final GoalDifficulty difficulty;
  final int estimatedDays;
  final String category;
  
  GoalRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.targetUnit,
    required this.priority,
    required this.difficulty,
    required this.estimatedDays,
    required this.category,
  });
}

// 목표 달성 통계 클래스
class GoalAchievementStats {
  final int totalGoals;
  final int completedGoals;
  final int activeGoals;
  final int overdueGoals;
  final double completionRate;
  final double averageProgress;
  final int totalXpEarned;
  final int streakDays;
  
  GoalAchievementStats({
    required this.totalGoals,
    required this.completedGoals,
    required this.activeGoals,
    required this.overdueGoals,
    required this.completionRate,
    required this.averageProgress,
    required this.totalXpEarned,
    required this.streakDays,
  });
}