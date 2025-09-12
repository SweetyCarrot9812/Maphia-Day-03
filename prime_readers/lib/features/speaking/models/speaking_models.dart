import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'speaking_models.g.dart';

enum SpeakingLevel {
  @HiveField(0)
  beginner,
  @HiveField(1)
  intermediate,
  @HiveField(2)
  advanced,
}

extension SpeakingLevelExtension on SpeakingLevel {
  String get displayName {
    switch (this) {
      case SpeakingLevel.beginner:
        return '초급';
      case SpeakingLevel.intermediate:
        return '중급';
      case SpeakingLevel.advanced:
        return '고급';
    }
  }

  String get emoji {
    switch (this) {
      case SpeakingLevel.beginner:
        return '🟢';
      case SpeakingLevel.intermediate:
        return '🟡';
      case SpeakingLevel.advanced:
        return '🔴';
    }
  }
}

@HiveType(typeId: 10)
@JsonSerializable()
class SpeakingLesson {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final SpeakingLevel level;

  @HiveField(4)
  final List<SpeakingExercise> exercises;

  @HiveField(5)
  final int estimatedMinutes;

  @HiveField(6)
  final String? thumbnailUrl;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final bool isCompleted;

  @HiveField(10)
  final double? averageScore;

  const SpeakingLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.exercises,
    required this.estimatedMinutes,
    this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.averageScore,
  });

  factory SpeakingLesson.fromJson(Map<String, dynamic> json) =>
      _$SpeakingLessonFromJson(json);

  Map<String, dynamic> toJson() => _$SpeakingLessonToJson(this);

  SpeakingLesson copyWith({
    String? id,
    String? title,
    String? description,
    SpeakingLevel? level,
    List<SpeakingExercise>? exercises,
    int? estimatedMinutes,
    String? thumbnailUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    double? averageScore,
  }) {
    return SpeakingLesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      exercises: exercises ?? this.exercises,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      averageScore: averageScore ?? this.averageScore,
    );
  }
}

@HiveType(typeId: 11)
@JsonSerializable()
class SpeakingExercise {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String phoneticTranscription;

  @HiveField(3)
  final String audioUrl;

  @HiveField(4)
  final int order;

  @HiveField(5)
  final String? hint;

  @HiveField(6)
  final List<String> keyWords;

  @HiveField(7)
  final double targetScore;

  const SpeakingExercise({
    required this.id,
    required this.text,
    required this.phoneticTranscription,
    required this.audioUrl,
    required this.order,
    this.hint,
    required this.keyWords,
    this.targetScore = 80.0,
  });

  factory SpeakingExercise.fromJson(Map<String, dynamic> json) =>
      _$SpeakingExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$SpeakingExerciseToJson(this);
}

@HiveType(typeId: 12)
@JsonSerializable()
class SpeakingSession {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String lessonId;

  @HiveField(3)
  final DateTime startTime;

  @HiveField(4)
  final DateTime? endTime;

  @HiveField(5)
  final List<SpeakingAttempt> attempts;

  @HiveField(6)
  final double? overallScore;

  @HiveField(7)
  final bool isCompleted;

  const SpeakingSession({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.startTime,
    this.endTime,
    required this.attempts,
    this.overallScore,
    this.isCompleted = false,
  });

  factory SpeakingSession.fromJson(Map<String, dynamic> json) =>
      _$SpeakingSessionFromJson(json);

  Map<String, dynamic> toJson() => _$SpeakingSessionToJson(this);

  SpeakingSession copyWith({
    String? id,
    String? userId,
    String? lessonId,
    DateTime? startTime,
    DateTime? endTime,
    List<SpeakingAttempt>? attempts,
    double? overallScore,
    bool? isCompleted,
  }) {
    return SpeakingSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      attempts: attempts ?? this.attempts,
      overallScore: overallScore ?? this.overallScore,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Duration? get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }
}

@HiveType(typeId: 13)
@JsonSerializable()
class SpeakingAttempt {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exerciseId;

  @HiveField(2)
  final String recordingPath;

  @HiveField(3)
  final DateTime recordedAt;

  @HiveField(4)
  final Duration recordingDuration;

  @HiveField(5)
  final SpeakingEvaluation? evaluation;

  @HiveField(6)
  final int attemptNumber;

  const SpeakingAttempt({
    required this.id,
    required this.exerciseId,
    required this.recordingPath,
    required this.recordedAt,
    required this.recordingDuration,
    this.evaluation,
    required this.attemptNumber,
  });

  factory SpeakingAttempt.fromJson(Map<String, dynamic> json) =>
      _$SpeakingAttemptFromJson(json);

  Map<String, dynamic> toJson() => _$SpeakingAttemptToJson(this);

  SpeakingAttempt copyWith({
    String? id,
    String? exerciseId,
    String? recordingPath,
    DateTime? recordedAt,
    Duration? recordingDuration,
    SpeakingEvaluation? evaluation,
    int? attemptNumber,
  }) {
    return SpeakingAttempt(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      recordingPath: recordingPath ?? this.recordingPath,
      recordedAt: recordedAt ?? this.recordedAt,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      evaluation: evaluation ?? this.evaluation,
      attemptNumber: attemptNumber ?? this.attemptNumber,
    );
  }
}

@HiveType(typeId: 14)
@JsonSerializable()
class SpeakingEvaluation {
  @HiveField(0)
  final double overallScore;

  @HiveField(1)
  final double pronunciationScore;

  @HiveField(2)
  final double fluencyScore;

  @HiveField(3)
  final double accuracyScore;

  @HiveField(4)
  final String transcribedText;

  @HiveField(5)
  final List<PronunciationFeedback> feedback;

  @HiveField(6)
  final DateTime evaluatedAt;

  @HiveField(7)
  final String aiModel;

  const SpeakingEvaluation({
    required this.overallScore,
    required this.pronunciationScore,
    required this.fluencyScore,
    required this.accuracyScore,
    required this.transcribedText,
    required this.feedback,
    required this.evaluatedAt,
    required this.aiModel,
  });

  factory SpeakingEvaluation.fromJson(Map<String, dynamic> json) =>
      _$SpeakingEvaluationFromJson(json);

  Map<String, dynamic> toJson() => _$SpeakingEvaluationToJson(this);
}

@HiveType(typeId: 15)
@JsonSerializable()
class PronunciationFeedback {
  @HiveField(0)
  final String word;

  @HiveField(1)
  final double score;

  @HiveField(2)
  final String suggestion;

  @HiveField(3)
  final String phoneticCorrection;

  @HiveField(4)
  final bool isCorrect;

  const PronunciationFeedback({
    required this.word,
    required this.score,
    required this.suggestion,
    required this.phoneticCorrection,
    required this.isCorrect,
  });

  factory PronunciationFeedback.fromJson(Map<String, dynamic> json) =>
      _$PronunciationFeedbackFromJson(json);

  Map<String, dynamic> toJson() => _$PronunciationFeedbackToJson(this);
}

@HiveType(typeId: 16)
@JsonSerializable()
class SpeakingStats {
  @HiveField(0)
  final int totalLessons;

  @HiveField(1)
  final int completedLessons;

  @HiveField(2)
  final int totalAttempts;

  @HiveField(3)
  final double averageScore;

  @HiveField(4)
  final Duration totalPracticeTime;

  @HiveField(5)
  final DateTime lastPracticeDate;

  @HiveField(6)
  final Map<SpeakingLevel, int> lessonsByLevel;

  @HiveField(7)
  final List<double> recentScores;

  const SpeakingStats({
    required this.totalLessons,
    required this.completedLessons,
    required this.totalAttempts,
    required this.averageScore,
    required this.totalPracticeTime,
    required this.lastPracticeDate,
    required this.lessonsByLevel,
    required this.recentScores,
  });

  factory SpeakingStats.fromJson(Map<String, dynamic> json) =>
      _$SpeakingStatsFromJson(json);

  Map<String, dynamic> toJson() => _$SpeakingStatsToJson(this);

  double get completionRate {
    if (totalLessons == 0) return 0.0;
    return (completedLessons / totalLessons) * 100;
  }

  int get inProgressLessons => totalLessons - completedLessons;
}