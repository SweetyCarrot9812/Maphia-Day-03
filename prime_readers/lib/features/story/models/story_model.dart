import 'package:hive/hive.dart';

part 'story_model.g.dart';

@HiveType(typeId: 10)
class Story extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String content;

  @HiveField(4)
  String imageUrl;

  @HiveField(5)
  String? audioUrl;

  @HiveField(6)
  StoryLevel level;

  @HiveField(7)
  List<String> keywords;

  @HiveField(8)
  int estimatedMinutes;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  bool isCompleted;

  @HiveField(11)
  int? score;

  @HiveField(12)
  DateTime? completedAt;

  @HiveField(13)
  List<String> scenes;

  @HiveField(14)
  String userId;

  Story({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    this.audioUrl,
    this.level = StoryLevel.beginner,
    this.keywords = const [],
    this.estimatedMinutes = 5,
    required this.createdAt,
    this.isCompleted = false,
    this.score,
    this.completedAt,
    this.scenes = const [],
    required this.userId,
  });

  double get completionRate {
    // 스토리 완료율 계산 (향후 챕터 단위로 확장 가능)
    return isCompleted ? 1.0 : 0.0;
  }
}

@HiveType(typeId: 11)
enum StoryLevel {
  @HiveField(0)
  beginner,    // 초급

  @HiveField(1)
  intermediate, // 중급

  @HiveField(2)
  advanced,    // 고급
}

@HiveType(typeId: 12)
class StoryProgress extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String storyId;

  @HiveField(2)
  String userId;

  @HiveField(3)
  int currentScene;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  int? score;

  @HiveField(6)
  DateTime startedAt;

  @HiveField(7)
  DateTime? completedAt;

  @HiveField(8)
  List<String> completedScenes;

  StoryProgress({
    required this.id,
    required this.storyId,
    required this.userId,
    this.currentScene = 0,
    this.isCompleted = false,
    this.score,
    required this.startedAt,
    this.completedAt,
    this.completedScenes = const [],
  });

  double get progressPercentage {
    if (completedScenes.isEmpty) return 0.0;
    // 향후 총 씬 개수를 기반으로 계산
    return currentScene / 10.0; // 기본적으로 10개 씬 가정
  }
}

@HiveType(typeId: 13)
class StoryQuiz extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String storyId;

  @HiveField(2)
  String question;

  @HiveField(3)
  List<String> options;

  @HiveField(4)
  int correctAnswer;

  @HiveField(5)
  String explanation;

  @HiveField(6)
  QuizType type;

  StoryQuiz({
    required this.id,
    required this.storyId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation = '',
    this.type = QuizType.multipleChoice,
  });
}

@HiveType(typeId: 14)
enum QuizType {
  @HiveField(0)
  multipleChoice,  // 객관식

  @HiveField(1)
  trueFalse,       // O/X

  @HiveField(2)
  shortAnswer,     // 단답형
}

// Extensions
extension StoryLevelExtension on StoryLevel {
  String get displayName {
    switch (this) {
      case StoryLevel.beginner:
        return '초급';
      case StoryLevel.intermediate:
        return '중급';
      case StoryLevel.advanced:
        return '고급';
    }
  }

  String get emoji {
    switch (this) {
      case StoryLevel.beginner:
        return '🟢';
      case StoryLevel.intermediate:
        return '🟡';
      case StoryLevel.advanced:
        return '🔴';
    }
  }
}

extension QuizTypeExtension on QuizType {
  String get displayName {
    switch (this) {
      case QuizType.multipleChoice:
        return '객관식';
      case QuizType.trueFalse:
        return 'O/X';
      case QuizType.shortAnswer:
        return '단답형';
    }
  }
}