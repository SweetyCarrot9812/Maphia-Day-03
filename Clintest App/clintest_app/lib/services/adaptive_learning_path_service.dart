import 'dart:math';
import '../models/learning_goal.dart';
import '../services/skill_assessment_service.dart';
import '../services/weakness_recommendation_engine.dart';
import '../services/learning_goal_service.dart';
import '../services/statistics_service.dart';

class AdaptiveLearningPathService {
  static final AdaptiveLearningPathService _instance = AdaptiveLearningPathService._internal();
  factory AdaptiveLearningPathService() => _instance;
  AdaptiveLearningPathService._internal();
  
  static AdaptiveLearningPathService get instance => _instance;
  
  // 적응형 학습 경로 생성
  static Future<AdaptiveLearningPath> generateLearningPath({
    required String userId,
    required LearningPathType pathType,
    int? targetDays,
    List<String>? focusAreas,
    LearningPathIntensity intensity = LearningPathIntensity.moderate,
  }) async {
    // 1. 사용자 현재 상태 분석
    final currentState = await _analyzeUserCurrentState(userId);
    
    // 2. 목표 분석
    final goals = await LearningGoalService.getActiveGoals(userId);
    final primaryGoal = _identifyPrimaryGoal(goals, pathType);
    
    // 3. 학습 경로 전략 결정
    final strategy = _determineLearningStrategy(currentState, primaryGoal, pathType);
    
    // 4. 구체적인 학습 단계 생성
    final phases = await _generateLearningPhases(
      userId: userId,
      strategy: strategy,
      currentState: currentState,
      targetDays: targetDays ?? _calculateDefaultDuration(pathType, intensity),
      intensity: intensity,
      focusAreas: focusAreas,
    );
    
    // 5. 일일 학습 계획 생성
    final dailyPlans = _generateDailyLearningPlans(phases, intensity);
    
    return AdaptiveLearningPath(
      userId: userId,
      pathType: pathType,
      intensity: intensity,
      strategy: strategy,
      currentState: currentState,
      phases: phases,
      dailyPlans: dailyPlans,
      createdAt: DateTime.now(),
      estimatedCompletionDate: DateTime.now().add(Duration(days: targetDays ?? 30)),
    );
  }
  
  // 사용자 현재 상태 분석
  static Future<UserLearningState> _analyzeUserCurrentState(String userId) async {
    final skillAssessment = await SkillAssessmentService.assessUserSkills(userId);
    final weaknesses = await WeaknessRecommendationEngine.analyzeWeaknesses(userId);
    final stats = await StatisticsService.getUserStatistics(userId);
    
    // 전반적인 실력 수준 계산
    double overallSkillLevel = 0.0;
    for (final assessment in skillAssessment.values) {
      overallSkillLevel += assessment.skillLevel.index;
    }
    overallSkillLevel /= skillAssessment.length;
    
    // 학습 스타일 분석
    final learningStyle = _analyzeLearningStyle(stats);
    
    // 약점 영역 우선순위
    final priorityWeaknesses = weaknesses.take(3).toList();
    
    return UserLearningState(
      overallSkillLevel: overallSkillLevel,
      skillAssessments: skillAssessment,
      weaknesses: priorityWeaknesses,
      learningStyle: learningStyle,
      studyConsistency: _calculateStudyConsistency(stats),
      preferredDifficulty: _calculatePreferredDifficulty(stats),
      averageAccuracy: stats.overallAccuracy ?? 0.0,
      studyHabits: _analyzeStudyHabits(stats),
    );
  }
  
  static LearningStyle _analyzeLearningStyle(dynamic stats) {
    // 통계를 기반으로 학습 스타일 분석
    final accuracy = stats.overallAccuracy ?? 0.0;
    final volume = stats.totalProblemsAttempted ?? 0;
    final consistency = stats.studyStreak ?? 0;
    
    if (accuracy > 0.85 && volume > 200) {
      return LearningStyle.fastAndAccurate;
    } else if (volume > 300) {
      return LearningStyle.volumeLearner;
    } else if (consistency > 14) {
      return LearningStyle.steadyLearner;
    } else if (accuracy < 0.6) {
      return LearningStyle.strugglingLearner;
    } else {
      return LearningStyle.balancedLearner;
    }
  }
  
  static double _calculateStudyConsistency(dynamic stats) {
    final streak = stats.studyStreak ?? 0;
    final totalDays = stats.totalStudyDays ?? 1;
    return (streak / totalDays).clamp(0.0, 1.0);
  }
  
  static double _calculatePreferredDifficulty(dynamic stats) {
    final accuracy = stats.overallAccuracy ?? 0.0;
    if (accuracy > 0.85) return 0.8; // 높은 난이도 선호
    if (accuracy > 0.7) return 0.6;  // 중간 난이도
    if (accuracy > 0.5) return 0.4;  // 낮은 난이도
    return 0.2; // 매우 낮은 난이도
  }
  
  static StudyHabits _analyzeStudyHabits(dynamic stats) {
    final avgSessionTime = stats.averageStudyTimePerSession?.inMinutes ?? 30;
    final totalSessions = stats.totalStudyDays ?? 1;
    
    return StudyHabits(
      preferredSessionLength: avgSessionTime,
      preferredTimeOfDay: TimeOfDay.evening, // 기본값
      breakFrequency: avgSessionTime > 60 ? 15 : 0,
      motivationLevel: _calculateMotivationLevel(stats),
    );
  }
  
  static double _calculateMotivationLevel(dynamic stats) {
    final consistency = stats.studyStreak ?? 0;
    final accuracy = stats.overallAccuracy ?? 0.0;
    final volume = stats.totalProblemsAttempted ?? 0;
    
    double score = 0.0;
    score += (consistency / 30.0) * 0.4; // 일관성
    score += accuracy * 0.3; // 정확도
    score += (volume / 500.0) * 0.3; // 문제량
    
    return score.clamp(0.0, 1.0);
  }
  
  // 주요 목표 식별
  static LearningGoal? _identifyPrimaryGoal(List<LearningGoal> goals, LearningPathType pathType) {
    if (goals.isEmpty) return null;
    
    // 경로 타입에 맞는 목표 우선 선택
    final relevantGoals = goals.where((goal) {
      switch (pathType) {
        case LearningPathType.examPreparation:
          return goal.type == GoalType.comprehensive || goal.type == GoalType.accuracy;
        case LearningPathType.skillImprovement:
          return goal.type == GoalType.mastery || goal.type == GoalType.accuracy;
        case LearningPathType.weaknessRemedy:
          return goal.category != 'overall';
        case LearningPathType.consistencyBuilding:
          return goal.type == GoalType.consistency || goal.type == GoalType.volume;
        case LearningPathType.comprehensive:
          return true;
      }
    }).toList();
    
    if (relevantGoals.isNotEmpty) {
      // 우선순위가 높고 진행률이 낮은 목표 선택
      relevantGoals.sort((a, b) {
        final priorityComparison = b.priority.index.compareTo(a.priority.index);
        if (priorityComparison != 0) return priorityComparison;
        return a.progressPercentage.compareTo(b.progressPercentage);
      });
      return relevantGoals.first;
    }
    
    // 관련 목표가 없으면 가장 우선순위 높은 목표
    goals.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return goals.first;
  }
  
  // 학습 전략 결정
  static LearningStrategy _determineLearningStrategy(
    UserLearningState currentState,
    LearningGoal? primaryGoal,
    LearningPathType pathType,
  ) {
    switch (pathType) {
      case LearningPathType.examPreparation:
        return LearningStrategy.examFocused;
      case LearningPathType.skillImprovement:
        if (currentState.overallSkillLevel < 2.0) {
          return LearningStrategy.foundationBuilding;
        } else {
          return LearningStrategy.skillSpecific;
        }
      case LearningPathType.weaknessRemedy:
        return LearningStrategy.targeted;
      case LearningPathType.consistencyBuilding:
        return LearningStrategy.habitForming;
      case LearningPathType.comprehensive:
        if (currentState.overallSkillLevel < 1.5) {
          return LearningStrategy.foundationBuilding;
        } else if (currentState.overallSkillLevel < 3.0) {
          return LearningStrategy.balanced;
        } else {
          return LearningStrategy.advanced;
        }
    }
  }
  
  // 학습 단계 생성
  static Future<List<LearningPhase>> _generateLearningPhases({
    required String userId,
    required LearningStrategy strategy,
    required UserLearningState currentState,
    required int targetDays,
    required LearningPathIntensity intensity,
    List<String>? focusAreas,
  }) async {
    final phases = <LearningPhase>[];
    final phaseCount = _calculatePhaseCount(strategy, targetDays);
    final daysPerPhase = targetDays ~/ phaseCount;
    
    for (int i = 0; i < phaseCount; i++) {
      final phase = await _generateSinglePhase(
        phaseNumber: i + 1,
        totalPhases: phaseCount,
        strategy: strategy,
        currentState: currentState,
        daysInPhase: daysPerPhase,
        intensity: intensity,
        focusAreas: focusAreas,
        startDate: DateTime.now().add(Duration(days: i * daysPerPhase)),
      );
      phases.add(phase);
    }
    
    return phases;
  }
  
  static int _calculatePhaseCount(LearningStrategy strategy, int targetDays) {
    switch (strategy) {
      case LearningStrategy.foundationBuilding:
        return min(4, (targetDays / 7).ceil());
      case LearningStrategy.examFocused:
        return min(5, (targetDays / 6).ceil());
      case LearningStrategy.targeted:
        return min(3, (targetDays / 10).ceil());
      case LearningStrategy.habitForming:
        return min(4, (targetDays / 7).ceil());
      case LearningStrategy.skillSpecific:
        return min(3, (targetDays / 10).ceil());
      case LearningStrategy.balanced:
        return min(4, (targetDays / 8).ceil());
      case LearningStrategy.advanced:
        return min(5, (targetDays / 6).ceil());
    }
  }
  
  static Future<LearningPhase> _generateSinglePhase({
    required int phaseNumber,
    required int totalPhases,
    required LearningStrategy strategy,
    required UserLearningState currentState,
    required int daysInPhase,
    required LearningPathIntensity intensity,
    List<String>? focusAreas,
    required DateTime startDate,
  }) async {
    final phaseTitle = _generatePhaseTitle(phaseNumber, totalPhases, strategy);
    final objectives = _generatePhaseObjectives(phaseNumber, totalPhases, strategy, currentState);
    final activities = _generatePhaseActivities(strategy, currentState, intensity, focusAreas);
    
    return LearningPhase(
      phaseNumber: phaseNumber,
      title: phaseTitle,
      description: _generatePhaseDescription(phaseNumber, strategy),
      startDate: startDate,
      endDate: startDate.add(Duration(days: daysInPhase)),
      objectives: objectives,
      activities: activities,
      targetMetrics: _generatePhaseMetrics(phaseNumber, strategy),
      isCompleted: false,
    );
  }
  
  static String _generatePhaseTitle(int phaseNumber, int totalPhases, LearningStrategy strategy) {
    switch (strategy) {
      case LearningStrategy.foundationBuilding:
        final phases = ['기초 다지기', '핵심 개념 학습', '실력 향상', '완성도 높이기'];
        return phases[min(phaseNumber - 1, phases.length - 1)];
      case LearningStrategy.examFocused:
        final phases = ['시험 범위 파악', '핵심 영역 집중', '약점 보완', '실전 모의고사', '최종 점검'];
        return phases[min(phaseNumber - 1, phases.length - 1)];
      case LearningStrategy.targeted:
        final phases = ['약점 파악', '집중 학습', '실력 검증'];
        return phases[min(phaseNumber - 1, phases.length - 1)];
      case LearningStrategy.habitForming:
        final phases = ['습관 형성', '꾸준함 유지', '실력 향상', '완성'];
        return phases[min(phaseNumber - 1, phases.length - 1)];
      case LearningStrategy.skillSpecific:
        final phases = ['현재 실력 측정', '목표 스킬 학습', '실전 적용'];
        return phases[min(phaseNumber - 1, phases.length - 1)];
      case LearningStrategy.balanced:
        final phases = ['전반적 실력 향상', '균형잡힌 학습', '심화 학습', '완성도 높이기'];
        return phases[min(phaseNumber - 1, phases.length - 1)];
      case LearningStrategy.advanced:
        final phases = ['고급 개념 학습', '전문성 강화', '실전 응용', '마스터 수준', '완성'];
        return phases[min(phaseNumber - 1, phases.length - 1)];
    }
  }
  
  static String _generatePhaseDescription(int phaseNumber, LearningStrategy strategy) {
    // 각 전략과 단계에 맞는 설명 생성
    return '${strategy.name} 전략의 $phaseNumber단계입니다.';
  }
  
  static List<String> _generatePhaseObjectives(
    int phaseNumber,
    int totalPhases,
    LearningStrategy strategy,
    UserLearningState currentState,
  ) {
    switch (strategy) {
      case LearningStrategy.foundationBuilding:
        if (phaseNumber == 1) {
          return ['기본 개념 이해하기', '학습 습관 형성하기', '기초 문제 정확도 70% 달성'];
        } else if (phaseNumber == 2) {
          return ['핵심 개념 마스터하기', '중급 난이도 문제 도전', '정확도 75% 달성'];
        } else {
          return ['고급 개념 학습', '실전 문제 해결', '정확도 80% 달성'];
        }
      case LearningStrategy.examFocused:
        if (phaseNumber == 1) {
          return ['시험 출제 경향 파악', '기본 범위 점검', '취약 영역 식별'];
        } else if (phaseNumber <= 3) {
          return ['핵심 영역 집중 학습', '문제 유형별 접근법 학습', '실전 감각 기르기'];
        } else {
          return ['최종 점검', '실수 줄이기', '시간 관리 완성'];
        }
      default:
        return ['단계별 목표 달성', '꾸준한 학습', '실력 향상'];
    }
  }
  
  static List<LearningActivity> _generatePhaseActivities(
    LearningStrategy strategy,
    UserLearningState currentState,
    LearningPathIntensity intensity,
    List<String>? focusAreas,
  ) {
    final activities = <LearningActivity>[];
    
    // 기본 문제 풀이 활동
    activities.add(LearningActivity(
      type: ActivityType.problemSolving,
      title: '일일 문제 풀이',
      description: '매일 정해진 양의 문제를 풀어보세요',
      targetAmount: _calculateDailyProblemTarget(intensity),
      estimatedMinutes: _calculateEstimatedTime(intensity),
      priority: ActivityPriority.high,
    ));
    
    // 복습 활동
    activities.add(LearningActivity(
      type: ActivityType.review,
      title: '오답 복습',
      description: '틀린 문제를 다시 풀고 이해하기',
      targetAmount: 10,
      estimatedMinutes: 20,
      priority: ActivityPriority.medium,
    ));
    
    // 약점 보완 활동 (약점이 있는 경우)
    if (currentState.weaknesses.isNotEmpty) {
      activities.add(LearningActivity(
        type: ActivityType.weakness,
        title: '약점 영역 집중',
        description: '약점 영역에 집중해서 학습하기',
        targetAmount: 15,
        estimatedMinutes: 30,
        priority: ActivityPriority.high,
      ));
    }
    
    // 개념 학습 (기초 수준인 경우)
    if (currentState.overallSkillLevel < 2.0) {
      activities.add(LearningActivity(
        type: ActivityType.concept,
        title: '기본 개념 학습',
        description: '기본 개념과 원리를 학습하세요',
        targetAmount: 3,
        estimatedMinutes: 25,
        priority: ActivityPriority.medium,
      ));
    }
    
    return activities;
  }
  
  static int _calculateDailyProblemTarget(LearningPathIntensity intensity) {
    switch (intensity) {
      case LearningPathIntensity.light:
        return 10;
      case LearningPathIntensity.moderate:
        return 20;
      case LearningPathIntensity.intensive:
        return 35;
      case LearningPathIntensity.extreme:
        return 50;
    }
  }
  
  static int _calculateEstimatedTime(LearningPathIntensity intensity) {
    switch (intensity) {
      case LearningPathIntensity.light:
        return 30;
      case LearningPathIntensity.moderate:
        return 60;
      case LearningPathIntensity.intensive:
        return 90;
      case LearningPathIntensity.extreme:
        return 120;
    }
  }
  
  static Map<String, double> _generatePhaseMetrics(int phaseNumber, LearningStrategy strategy) {
    final baseAccuracy = 0.6 + (phaseNumber * 0.05);
    return {
      'target_accuracy': baseAccuracy.clamp(0.6, 0.9),
      'min_problems': 100.0,
      'consistency_days': 7.0,
    };
  }
  
  // 일일 학습 계획 생성
  static List<DailyLearningPlan> _generateDailyLearningPlans(
    List<LearningPhase> phases,
    LearningPathIntensity intensity,
  ) {
    final dailyPlans = <DailyLearningPlan>[];
    
    for (final phase in phases) {
      final phaseDays = phase.endDate.difference(phase.startDate).inDays;
      
      for (int day = 0; day < phaseDays; day++) {
        final planDate = phase.startDate.add(Duration(days: day));
        final dailyPlan = DailyLearningPlan(
          date: planDate,
          phaseNumber: phase.phaseNumber,
          activities: phase.activities,
          estimatedMinutes: phase.activities
              .map((a) => a.estimatedMinutes)
              .reduce((a, b) => a + b),
          isCompleted: false,
        );
        dailyPlans.add(dailyPlan);
      }
    }
    
    return dailyPlans;
  }
  
  static int _calculateDefaultDuration(LearningPathType pathType, LearningPathIntensity intensity) {
    final baseMultiplier = switch (intensity) {
      LearningPathIntensity.light => 1.5,
      LearningPathIntensity.moderate => 1.0,
      LearningPathIntensity.intensive => 0.75,
      LearningPathIntensity.extreme => 0.5,
    };
    
    final baseDays = switch (pathType) {
      LearningPathType.examPreparation => 60,
      LearningPathType.skillImprovement => 30,
      LearningPathType.weaknessRemedy => 21,
      LearningPathType.consistencyBuilding => 30,
      LearningPathType.comprehensive => 90,
    };
    
    return (baseDays * baseMultiplier).round();
  }
  
  // 학습 경로 진도 업데이트
  static Future<void> updateLearningProgress(
    String userId,
    int pathId,
    DateTime date,
    Map<String, dynamic> progressData,
  ) async {
    // 실제 구현에서는 데이터베이스에 진도 저장
    // 여기서는 로깅만 수행
    print('Learning progress updated for user $userId on $date');
  }
  
  // 학습 경로 추천
  static Future<List<LearningPathRecommendation>> recommendLearningPaths(String userId) async {
    final currentState = await _analyzeUserCurrentState(userId);
    final recommendations = <LearningPathRecommendation>[];
    
    // 시험 준비 경로 (정확도가 낮거나 종합적 실력 향상 필요한 경우)
    if (currentState.averageAccuracy < 0.8 || currentState.overallSkillLevel < 3.0) {
      recommendations.add(LearningPathRecommendation(
        pathType: LearningPathType.examPreparation,
        title: 'NCLEX 시험 준비 경로',
        description: '체계적인 시험 준비로 합격률을 높이세요',
        estimatedDays: 60,
        intensity: LearningPathIntensity.moderate,
        suitabilityScore: 0.9,
      ));
    }
    
    // 약점 보완 경로 (약점이 명확한 경우)
    if (currentState.weaknesses.isNotEmpty) {
      recommendations.add(LearningPathRecommendation(
        pathType: LearningPathType.weaknessRemedy,
        title: '약점 집중 보완 경로',
        description: '개인별 약점을 집중적으로 보완하는 맞춤형 경로',
        estimatedDays: 21,
        intensity: LearningPathIntensity.intensive,
        suitabilityScore: 0.85,
      ));
    }
    
    // 일관성 구축 경로 (학습 일관성이 낮은 경우)
    if (currentState.studyConsistency < 0.5) {
      recommendations.add(LearningPathRecommendation(
        pathType: LearningPathType.consistencyBuilding,
        title: '꾸준한 학습 습관 만들기',
        description: '매일 조금씩 꾸준히 학습하는 습관을 형성하세요',
        estimatedDays: 30,
        intensity: LearningPathIntensity.light,
        suitabilityScore: 0.8,
      ));
    }
    
    return recommendations;
  }
}

// 데이터 모델들
class AdaptiveLearningPath {
  final String userId;
  final LearningPathType pathType;
  final LearningPathIntensity intensity;
  final LearningStrategy strategy;
  final UserLearningState currentState;
  final List<LearningPhase> phases;
  final List<DailyLearningPlan> dailyPlans;
  final DateTime createdAt;
  final DateTime estimatedCompletionDate;
  
  AdaptiveLearningPath({
    required this.userId,
    required this.pathType,
    required this.intensity,
    required this.strategy,
    required this.currentState,
    required this.phases,
    required this.dailyPlans,
    required this.createdAt,
    required this.estimatedCompletionDate,
  });
}

class UserLearningState {
  final double overallSkillLevel;
  final Map<String, dynamic> skillAssessments;
  final List<dynamic> weaknesses;
  final LearningStyle learningStyle;
  final double studyConsistency;
  final double preferredDifficulty;
  final double averageAccuracy;
  final StudyHabits studyHabits;
  
  UserLearningState({
    required this.overallSkillLevel,
    required this.skillAssessments,
    required this.weaknesses,
    required this.learningStyle,
    required this.studyConsistency,
    required this.preferredDifficulty,
    required this.averageAccuracy,
    required this.studyHabits,
  });
}

class StudyHabits {
  final int preferredSessionLength;
  final TimeOfDay preferredTimeOfDay;
  final int breakFrequency;
  final double motivationLevel;
  
  StudyHabits({
    required this.preferredSessionLength,
    required this.preferredTimeOfDay,
    required this.breakFrequency,
    required this.motivationLevel,
  });
}

class LearningPhase {
  final int phaseNumber;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> objectives;
  final List<LearningActivity> activities;
  final Map<String, double> targetMetrics;
  bool isCompleted;
  
  LearningPhase({
    required this.phaseNumber,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.objectives,
    required this.activities,
    required this.targetMetrics,
    required this.isCompleted,
  });
}

class LearningActivity {
  final ActivityType type;
  final String title;
  final String description;
  final int targetAmount;
  final int estimatedMinutes;
  final ActivityPriority priority;
  
  LearningActivity({
    required this.type,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.estimatedMinutes,
    required this.priority,
  });
}

class DailyLearningPlan {
  final DateTime date;
  final int phaseNumber;
  final List<LearningActivity> activities;
  final int estimatedMinutes;
  bool isCompleted;
  
  DailyLearningPlan({
    required this.date,
    required this.phaseNumber,
    required this.activities,
    required this.estimatedMinutes,
    required this.isCompleted,
  });
}

class LearningPathRecommendation {
  final LearningPathType pathType;
  final String title;
  final String description;
  final int estimatedDays;
  final LearningPathIntensity intensity;
  final double suitabilityScore;
  
  LearningPathRecommendation({
    required this.pathType,
    required this.title,
    required this.description,
    required this.estimatedDays,
    required this.intensity,
    required this.suitabilityScore,
  });
}

// 열거형들
enum LearningPathType {
  examPreparation,      // 시험 준비
  skillImprovement,     // 실력 향상  
  weaknessRemedy,       // 약점 보완
  consistencyBuilding,  // 일관성 구축
  comprehensive,        // 종합적 학습
}

enum LearningPathIntensity {
  light,      // 가볍게 (일일 30분)
  moderate,   // 보통 (일일 1시간)  
  intensive,  // 집중적 (일일 1.5시간)
  extreme,    // 극한 (일일 2시간+)
}

enum LearningStrategy {
  foundationBuilding, // 기초 다지기
  examFocused,       // 시험 중심
  targeted,          // 집중 공략
  habitForming,      // 습관 형성
  skillSpecific,     // 특정 스킬
  balanced,          // 균형적
  advanced,          // 고급 수준
}

enum LearningStyle {
  fastAndAccurate,   // 빠르고 정확한 학습자
  volumeLearner,     // 양 중심 학습자
  steadyLearner,     // 꾸준한 학습자
  strugglingLearner, // 어려움을 겪는 학습자
  balancedLearner,   // 균형잡힌 학습자
}

enum ActivityType {
  problemSolving, // 문제 풀이
  review,         // 복습
  weakness,       // 약점 보완
  concept,        // 개념 학습
  practice,       // 실전 연습
  assessment,     // 평가
}

enum ActivityPriority {
  low,    // 낮음
  medium, // 보통
  high,   // 높음
}

enum TimeOfDay {
  morning,   // 오전
  afternoon, // 오후
  evening,   // 저녁
  night,     // 밤
}