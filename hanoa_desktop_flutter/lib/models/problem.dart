import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'problem.g.dart';

@JsonEnum()
enum ProblemType {
  nursing,
  essay,
  simulation,
  multiple_choice,
  short_answer,
}

@JsonEnum()
enum Difficulty {
  easy,
  medium,
  hard,
  expert,
  beginner,
  intermediate,
  advanced,
}

@JsonEnum()
enum ProblemStatus {
  draft,
  review,
  published,
  active,
  archived,
  under_review,
  approved,
}

@collection
@JsonSerializable()
class Problem {
  Id id = Isar.autoIncrement;

  @JsonKey(name: 'problem_id')
  @Index(unique: true)
  late String problemId;

  @Index()
  late String title;

  late String content;

  @Enumerated(EnumType.name)
  late ProblemType type;

  @Enumerated(EnumType.name)
  late Difficulty difficulty;

  @Enumerated(EnumType.name)
  late ProblemStatus status;

  /// Multiple choice options (JSON array as string)
  String? options;

  /// Correct answer(s) (JSON array as string for multiple answers)
  String? correctAnswer;

  /// Explanation for the correct answer
  String? explanation;

  /// Tags for categorization (JSON array as string)
  String? tags;

  /// Subject area (e.g., "내과", "외과", "간호학개론")
  @Index()
  String? subject;

  /// Learning objectives
  String? objectives;

  /// Reference materials
  String? references;

  /// Point value for scoring
  @JsonKey(defaultValue: 1)
  int points = 1;

  /// Estimated time to solve in minutes
  @JsonKey(defaultValue: 2)
  int estimatedTimeMinutes = 2;

  /// Number of times this problem was attempted
  @JsonKey(defaultValue: 0)
  int attemptCount = 0;

  /// Number of times this problem was answered correctly
  @JsonKey(defaultValue: 0)
  int correctCount = 0;

  /// Average score for this problem (0-100)
  @JsonKey(defaultValue: 0.0)
  double averageScore = 0.0;

  /// Problem creation metadata
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  /// AI generation metadata
  String? aiModel;
  String? aiPrompt;
  double? aiConfidence;

  /// Media attachments (JSON array as string)
  String? attachments;

  /// Problem status
  @Index()
  @JsonKey(defaultValue: true)
  bool isActive = true;

  /// Version for tracking changes
  @JsonKey(defaultValue: 1)
  int version = 1;

  Problem();

  // Factory constructor for JSON deserialization
  factory Problem.fromJson(Map<String, dynamic> json) => _$ProblemFromJson(json);

  // Method for JSON serialization
  Map<String, dynamic> toJson() => _$ProblemToJson(this);

  /// Convenience getters for JSON fields
  List<String> get optionsList {
    if (options == null) return [];
    try {
      return List<String>.from(jsonDecode(options!) as List);
    } catch (e) {
      return [];
    }
  }

  List<String> get correctAnswerList {
    if (correctAnswer == null) return [];
    try {
      final decoded = jsonDecode(correctAnswer!);
      if (decoded is List) {
        return List<String>.from(decoded);
      } else {
        return [decoded.toString()];
      }
    } catch (e) {
      return correctAnswer != null ? [correctAnswer!] : [];
    }
  }

  List<String> get tagsList {
    if (tags == null) return [];
    try {
      return List<String>.from(jsonDecode(tags!) as List);
    } catch (e) {
      return [];
    }
  }

  List<String> get attachmentsList {
    if (attachments == null) return [];
    try {
      return List<String>.from(jsonDecode(attachments!) as List);
    } catch (e) {
      return [];
    }
  }

  /// Calculate success rate
  double get successRate {
    if (attemptCount == 0) return 0.0;
    return (correctCount / attemptCount) * 100;
  }

  /// Check if problem is new (no attempts)
  bool get isNew => attemptCount == 0;

  /// Check if problem is difficult (success rate < 50%)
  bool get isDifficult => successRate < 50.0 && attemptCount >= 5;

  /// Check if problem is mastered (success rate > 80%)
  bool get isMastered => successRate > 80.0 && attemptCount >= 3;

  /// Update statistics after attempt
  Problem updateStats({required bool isCorrect, required double score}) {
    final updated = copyWith(
      attemptCount: attemptCount + 1,
      correctCount: isCorrect ? correctCount + 1 : correctCount,
      averageScore: (averageScore * attemptCount + score) / (attemptCount + 1),
      updatedAt: DateTime.now(),
    );
    return updated;
  }

  /// Copy with method for updating fields
  Problem copyWith({
    String? problemId,
    String? title,
    String? content,
    ProblemType? type,
    Difficulty? difficulty,
    ProblemStatus? status,
    String? options,
    String? correctAnswer,
    String? explanation,
    String? tags,
    String? subject,
    String? objectives,
    String? references,
    int? points,
    int? estimatedTimeMinutes,
    int? attemptCount,
    int? correctCount,
    double? averageScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? aiModel,
    String? aiPrompt,
    double? aiConfidence,
    String? attachments,
    bool? isActive,
    int? version,
  }) {
    final problem = Problem()
      ..id = id
      ..problemId = problemId ?? this.problemId
      ..title = title ?? this.title
      ..content = content ?? this.content
      ..type = type ?? this.type
      ..difficulty = difficulty ?? this.difficulty
      ..status = status ?? this.status
      ..options = options ?? this.options
      ..correctAnswer = correctAnswer ?? this.correctAnswer
      ..explanation = explanation ?? this.explanation
      ..tags = tags ?? this.tags
      ..subject = subject ?? this.subject
      ..objectives = objectives ?? this.objectives
      ..references = references ?? this.references
      ..points = points ?? this.points
      ..estimatedTimeMinutes = estimatedTimeMinutes ?? this.estimatedTimeMinutes
      ..attemptCount = attemptCount ?? this.attemptCount
      ..correctCount = correctCount ?? this.correctCount
      ..averageScore = averageScore ?? this.averageScore
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt
      ..aiModel = aiModel ?? this.aiModel
      ..aiPrompt = aiPrompt ?? this.aiPrompt
      ..aiConfidence = aiConfidence ?? this.aiConfidence
      ..attachments = attachments ?? this.attachments
      ..isActive = isActive ?? this.isActive
      ..version = version ?? this.version;
    return problem;
  }

  @override
  String toString() {
    return 'Problem{id: $id, problemId: $problemId, title: $title, type: $type, difficulty: $difficulty}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Problem && other.problemId == problemId;
  }

  @override
  int get hashCode => problemId.hashCode;
}

/// Extension for JSON decoding helper
extension JsonHelper on Problem {
  static dynamic jsonDecode(String source) {
    try {
      return json.decode(source);
    } catch (e) {
      return null;
    }
  }
}