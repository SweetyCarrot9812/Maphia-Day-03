import 'package:isar/isar.dart';

part 'learning_goal.g.dart';

@Collection()
class LearningGoal {
  Id? id = Isar.autoIncrement;
  
  late String userId;
  late String title;
  String? description;
  late String category; // subject area
  @Enumerated(EnumType.name)
  late GoalType type;
  @Enumerated(EnumType.name)
  late GoalStatus status;
  
  // Target parameters
  late int targetValue; // target number (questions, accuracy percentage, etc.)
  late String targetUnit; // 'questions', 'percentage', 'days', 'hours'
  int currentValue = 0;
  
  // Time-based targets
  DateTime? targetDate;
  DateTime? startDate;
  DateTime? completionDate;
  
  // Priority and difficulty
  @Enumerated(EnumType.name)
  late GoalPriority priority;
  @Enumerated(EnumType.name)
  late GoalDifficulty difficulty;
  
  // Progress tracking
  double get progressPercentage {
    if (targetValue == 0) return 0.0;
    return (currentValue / targetValue * 100).clamp(0.0, 100.0);
  }
  
  bool get isCompleted => status == GoalStatus.completed;
  bool get isOverdue {
    if (targetDate == null) return false;
    return DateTime.now().isAfter(targetDate!) && !isCompleted;
  }
  
  int get daysRemaining {
    if (targetDate == null) return -1;
    return targetDate!.difference(DateTime.now()).inDays;
  }
  
  // Milestones
  List<GoalMilestone> milestones = [];
  
  // Creation and update timestamps
  @Index()
  late DateTime createdAt;
  DateTime? updatedAt;
  
  // Related competency areas
  List<String> competencyAreas = [];
  
  // Achievement rewards
  int xpReward = 0;
  List<String> badges = [];
  
  LearningGoal();
  
  LearningGoal.create({
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    required this.type,
    required this.targetValue,
    required this.targetUnit,
    this.targetDate,
    this.priority = GoalPriority.medium,
    this.difficulty = GoalDifficulty.intermediate,
    this.competencyAreas = const [],
  }) {
    status = GoalStatus.active;
    startDate = DateTime.now();
    createdAt = DateTime.now();
    _calculateXpReward();
  }
  
  void _calculateXpReward() {
    int baseXp = 100;
    
    // Difficulty multiplier
    double difficultyMultiplier = switch (difficulty) {
      GoalDifficulty.beginner => 1.0,
      GoalDifficulty.intermediate => 1.5,
      GoalDifficulty.advanced => 2.0,
      GoalDifficulty.expert => 3.0,
    };
    
    // Type multiplier
    double typeMultiplier = switch (type) {
      GoalType.accuracy => 1.2,
      GoalType.volume => 1.0,
      GoalType.consistency => 1.3,
      GoalType.mastery => 2.0,
      GoalType.speed => 1.1,
      GoalType.comprehensive => 2.5,
    };
    
    // Priority multiplier
    double priorityMultiplier = switch (priority) {
      GoalPriority.low => 0.8,
      GoalPriority.medium => 1.0,
      GoalPriority.high => 1.3,
      GoalPriority.critical => 1.5,
    };
    
    xpReward = (baseXp * difficultyMultiplier * typeMultiplier * priorityMultiplier).round();
  }
  
  void updateProgress(int newValue) {
    currentValue = newValue.clamp(0, targetValue);
    updatedAt = DateTime.now();
    
    // Check if goal is completed
    if (currentValue >= targetValue && status != GoalStatus.completed) {
      status = GoalStatus.completed;
      completionDate = DateTime.now();
    }
    
    // Update milestone progress
    _updateMilestoneProgress();
  }
  
  void _updateMilestoneProgress() {
    for (var milestone in milestones) {
      if (!milestone.isCompleted && currentValue >= milestone.targetValue) {
        milestone.completedAt = DateTime.now();
        milestone.isCompleted = true;
      }
    }
  }
  
  void addMilestone(String title, int targetValue, {String? reward}) {
    milestones.add(GoalMilestone(
      title: title,
      targetValue: targetValue,
      reward: reward,
    ));
  }
}

@embedded
class GoalMilestone {
  late String title;
  late int targetValue;
  String? reward;
  bool isCompleted = false;
  DateTime? completedAt;
  
  GoalMilestone({
    this.title = '',
    this.targetValue = 0,
    this.reward,
  });
  
  GoalMilestone.empty();
}

enum GoalType {
  accuracy,      // 정확도 목표
  volume,        // 문제 수량 목표  
  consistency,   // 일관성 목표 (연속 학습일)
  mastery,       // 특정 주제 마스터리
  speed,         // 문제 풀이 속도 개선
  comprehensive, // 종합적 실력 향상
}

enum GoalStatus {
  active,        // 활성 진행중
  paused,        // 일시정지
  completed,     // 완료
  failed,        // 실패 (기한 초과)
  cancelled,     // 취소
}

enum GoalPriority {
  low,           // 낮음
  medium,        // 보통
  high,          // 높음
  critical,      // 긴급
}

enum GoalDifficulty {
  beginner,      // 초급
  intermediate,  // 중급
  advanced,      // 고급
  expert,        // 전문가
}