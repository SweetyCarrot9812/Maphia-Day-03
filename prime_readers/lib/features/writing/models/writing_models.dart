import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'writing_models.g.dart';

// 라이팅 열거형 타입들
@HiveType(typeId: 27)
enum WritingTaskType {
  @HiveField(0)
  essay,
  @HiveField(1)
  creative,
  @HiveField(2)
  descriptive,
  @HiveField(3)
  argumentative,
  @HiveField(4)
  summary,
  @HiveField(5)
  review,
  @HiveField(6)
  letter,
  @HiveField(7)
  story,
  @HiveField(8)
  diary,
  @HiveField(9)
  report,
  @HiveField(10)
  description,
  @HiveField(11)
  opinion,
  @HiveField(12)
  instruction,
}

@HiveType(typeId: 3)
enum DifficultyLevel {
  @HiveField(0)
  beginner,
  @HiveField(1)
  intermediate,
  @HiveField(2)
  advanced,
}

@HiveType(typeId: 28)
enum WritingInputMethod {
  @HiveField(0)
  typing,
  @HiveField(1)
  handwriting,
  @HiveField(2)
  mixed,
}

@HiveType(typeId: 29)
enum WritingSessionStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  paused,
  @HiveField(2)
  completed,
  @HiveField(3)
  abandoned,
}

@HiveType(typeId: 30)
enum WritingActionType {
  @HiveField(0)
  typed,
  @HiveField(1)
  deleted,
  @HiveField(2)
  pasted,
  @HiveField(3)
  corrected,
  @HiveField(4)
  submitted,
  @HiveField(5)
  paused,
  @HiveField(6)
  resumed,
  @HiveField(7)
  saved,
}

@HiveType(typeId: 31)
enum WritingErrorType {
  @HiveField(0)
  grammar,
  @HiveField(1)
  spelling,
  @HiveField(2)
  punctuation,
  @HiveField(3)
  vocabulary,
  @HiveField(4)
  structure,
  @HiveField(5)
  style,
}

@HiveType(typeId: 32)
enum WritingSuggestionType {
  @HiveField(0)
  grammar,
  @HiveField(1)
  vocabulary,
  @HiveField(2)
  style,
  @HiveField(3)
  structure,
  @HiveField(4)
  content,
}

@HiveType(typeId: 34)
enum WritingStatus {
  @HiveField(0)
  draft,
  @HiveField(1)
  submitted,
  @HiveField(2)
  evaluating,
  @HiveField(3)
  evaluated,
  @HiveField(4)
  revised,
  @HiveField(5)
  completed,
}

enum OCRMethod {
  googleMLKit,
  googleCloudVision,
  microsoftCognitive,
  awsTextract,
  mock,
}

// 라이팅 과제 모델
@HiveType(typeId: 20)
@JsonSerializable()
class WritingTask {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String prompt;
  
  @HiveField(4)
  final WritingTaskType type;
  
  @HiveField(5)
  final DifficultyLevel difficulty;
  
  @HiveField(6)
  final int maxWords;
  
  @HiveField(7)
  final int minWords;
  
  @HiveField(8)
  final Duration timeLimit;
  
  @HiveField(9)
  final List<String> keyPoints;
  
  @HiveField(10)
  final List<String> vocabularyHints;
  
  @HiveField(11)
  final DateTime createdAt;
  
  @HiveField(12)
  final String? imageUrl;

  WritingTask({
    required this.id,
    required this.title,
    required this.description,
    required this.prompt,
    required this.type,
    required this.difficulty,
    required this.maxWords,
    required this.minWords,
    required this.timeLimit,
    required this.keyPoints,
    required this.vocabularyHints,
    required this.createdAt,
    this.imageUrl,
  });

  factory WritingTask.fromJson(Map<String, dynamic> json) => _$WritingTaskFromJson(json);
  Map<String, dynamic> toJson() => _$WritingTaskToJson(this);
}

// 라이팅 제출물 모델
@HiveType(typeId: 21)
@JsonSerializable()
class WritingSubmission {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String taskId;
  
  @HiveField(2)
  final String userId;
  
  @HiveField(3)
  final String content;
  
  @HiveField(4)
  final WritingInputMethod inputMethod;
  
  @HiveField(5)
  final DateTime submittedAt;
  
  @HiveField(6)
  final int wordCount;
  
  @HiveField(7)
  final Duration timeSpent;
  
  @HiveField(8)
  final String? handwritingImageUrl;
  
  @HiveField(9)
  final String? ocrText;
  
  @HiveField(10)
  final double? ocrConfidence;
  
  @HiveField(11)
  final WritingEvaluation? evaluation;

  @HiveField(12)
  final WritingStatus status;

  WritingSubmission({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.content,
    required this.inputMethod,
    required this.submittedAt,
    required this.wordCount,
    required this.timeSpent,
    required this.status,
    this.handwritingImageUrl,
    this.ocrText,
    this.ocrConfidence,
    this.evaluation,
  });

  factory WritingSubmission.fromJson(Map<String, dynamic> json) => _$WritingSubmissionFromJson(json);
  Map<String, dynamic> toJson() => _$WritingSubmissionToJson(this);
}

// 라이팅 평가 모델
@HiveType(typeId: 22)
@JsonSerializable()
class WritingEvaluation {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String submissionId;
  
  @HiveField(2)
  final double overallScore;
  
  @HiveField(3)
  final double grammarScore;
  
  @HiveField(4)
  final double vocabularyScore;
  
  @HiveField(5)
  final double contentScore;
  
  @HiveField(6)
  final double structureScore;
  
  @HiveField(7)
  final double creativityScore;
  
  @HiveField(8)
  final List<WritingError> errors;
  
  @HiveField(9)
  final List<WritingSuggestion> suggestions;
  
  @HiveField(10)
  final String feedback;
  
  @HiveField(11)
  final DateTime evaluatedAt;

  WritingEvaluation({
    required this.id,
    required this.submissionId,
    required this.overallScore,
    required this.grammarScore,
    required this.vocabularyScore,
    required this.contentScore,
    required this.structureScore,
    required this.creativityScore,
    required this.errors,
    required this.suggestions,
    required this.feedback,
    required this.evaluatedAt,
  });

  factory WritingEvaluation.fromJson(Map<String, dynamic> json) => _$WritingEvaluationFromJson(json);
  Map<String, dynamic> toJson() => _$WritingEvaluationToJson(this);
}

// 라이팅 오류 모델
@HiveType(typeId: 23)
@JsonSerializable()
class WritingError {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final WritingErrorType type;
  
  @HiveField(2)
  final String originalText;
  
  @HiveField(3)
  final String? correctedText;
  
  @HiveField(4)
  final int startPosition;
  
  @HiveField(5)
  final int endPosition;
  
  @HiveField(6)
  final String description;
  
  @HiveField(7)
  final String rule;
  
  @HiveField(8)
  final double confidence;

  WritingError({
    required this.id,
    required this.type,
    required this.originalText,
    this.correctedText,
    required this.startPosition,
    required this.endPosition,
    required this.description,
    required this.rule,
    required this.confidence,
  });

  factory WritingError.fromJson(Map<String, dynamic> json) => _$WritingErrorFromJson(json);
  Map<String, dynamic> toJson() => _$WritingErrorToJson(this);
}

// 라이팅 제안 모델
@HiveType(typeId: 24)
@JsonSerializable()
class WritingSuggestion {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final WritingSuggestionType type;
  
  @HiveField(2)
  final String title;
  
  @HiveField(3)
  final String description;
  
  @HiveField(4)
  final String? example;
  
  @HiveField(5)
  final String? improvement;
  
  @HiveField(6)
  final double priority;

  WritingSuggestion({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.example,
    this.improvement,
    required this.priority,
  });

  factory WritingSuggestion.fromJson(Map<String, dynamic> json) => _$WritingSuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$WritingSuggestionToJson(this);
}

// 라이팅 세션 모델
@HiveType(typeId: 25)
@JsonSerializable()
class WritingSession {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String taskId;
  
  @HiveField(3)
  final DateTime startedAt;
  
  @HiveField(4)
  final DateTime? endedAt;
  
  @HiveField(5)
  final Duration duration;
  
  @HiveField(6)
  final String currentContent;
  
  @HiveField(7)
  final int currentWordCount;
  
  @HiveField(8)
  final List<WritingAction> actions;
  
  @HiveField(9)
  final WritingSessionStatus status;
  
  @HiveField(10)
  final String? submissionId;

  WritingSession({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.startedAt,
    this.endedAt,
    required this.duration,
    required this.currentContent,
    required this.currentWordCount,
    required this.actions,
    required this.status,
    this.submissionId,
  });

  factory WritingSession.fromJson(Map<String, dynamic> json) => _$WritingSessionFromJson(json);
  Map<String, dynamic> toJson() => _$WritingSessionToJson(this);
}

// 라이팅 행동 모델
@HiveType(typeId: 26)
@JsonSerializable()
class WritingAction {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final WritingActionType type;
  
  @HiveField(2)
  final DateTime timestamp;
  
  @HiveField(3)
  final String? content;
  
  @HiveField(4)
  final int? position;
  
  @HiveField(5)
  final Map<String, dynamic>? metadata;

  WritingAction({
    required this.id,
    required this.type,
    required this.timestamp,
    this.content,
    this.position,
    this.metadata,
  });

  factory WritingAction.fromJson(Map<String, dynamic> json) => _$WritingActionFromJson(json);
  Map<String, dynamic> toJson() => _$WritingActionToJson(this);
}