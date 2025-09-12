import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quiz_session.g.dart';

@JsonEnum()
enum SessionStatus {
  active,
  completed,
  paused,
  abandoned,
}

@JsonEnum()
enum SessionType {
  practice,
  exam,
  review,
  challenge,
}

@collection
@JsonSerializable()
class QuizSession {
  Id id = Isar.autoIncrement;

  @JsonKey(name: 'session_id')
  @Index(unique: true)
  late String sessionId;

  @Index()
  late String title;

  @Enumerated(EnumType.name)
  late SessionType type;

  @Enumerated(EnumType.name)
  late SessionStatus status;

  /// Problems included in this session (JSON array of problem IDs)
  late String problemIds;

  /// User answers (JSON array of answer objects)
  String? userAnswers;

  /// Start time
  DateTime createdAt = DateTime.now();

  /// End time (null if not completed)
  DateTime? completedAt;

  /// Pause time (null if not paused)
  DateTime? pausedAt;

  /// Total time spent in milliseconds
  @JsonKey(defaultValue: 0)
  int totalTimeMs = 0;

  /// Current problem index (0-based)
  @JsonKey(defaultValue: 0)
  int currentProblemIndex = 0;

  /// Score statistics
  @JsonKey(defaultValue: 0)
  int totalProblems = 0;

  @JsonKey(defaultValue: 0)
  int correctAnswers = 0;

  @JsonKey(defaultValue: 0)
  int incorrectAnswers = 0;

  @JsonKey(defaultValue: 0)
  int skippedProblems = 0;

  /// Final score (0-100)
  @JsonKey(defaultValue: 0.0)
  double finalScore = 0.0;

  /// Session settings (JSON object as string)
  String? settings;

  /// Notes or comments
  String? notes;

  /// Subject areas covered (JSON array as string)
  String? subjects;

  /// Difficulty levels included (JSON array as string)  
  String? difficulties;

  /// Review mode data (JSON object as string)
  String? reviewData;

  QuizSession();

  // Factory constructor for JSON deserialization
  factory QuizSession.fromJson(Map<String, dynamic> json) => _$QuizSessionFromJson(json);

  // Method for JSON serialization
  Map<String, dynamic> toJson() => _$QuizSessionToJson(this);

  /// Convenience getters for JSON fields
  List<String> get problemIdsList {
    try {
      return List<String>.from(jsonDecode(problemIds) as List);
    } catch (e) {
      return [];
    }
  }

  @ignore
  List<Map<String, dynamic>> get userAnswersList {
    if (userAnswers == null) return [];
    try {
      final decoded = jsonDecode(userAnswers!) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      return [];
    }
  }

  List<String> get subjectsList {
    if (subjects == null) return [];
    try {
      return List<String>.from(jsonDecode(subjects!) as List);
    } catch (e) {
      return [];
    }
  }

  List<String> get difficultiesList {
    if (difficulties == null) return [];
    try {
      return List<String>.from(jsonDecode(difficulties!) as List);
    } catch (e) {
      return [];
    }
  }

  @ignore
  Map<String, dynamic> get settingsMap {
    if (settings == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(settings!) as Map);
    } catch (e) {
      return {};
    }
  }

  @ignore
  Map<String, dynamic> get reviewDataMap {
    if (reviewData == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(reviewData!) as Map);
    } catch (e) {
      return {};
    }
  }

  /// Calculate completion percentage
  double get completionPercentage {
    if (totalProblems == 0) return 0.0;
    final answeredProblems = correctAnswers + incorrectAnswers + skippedProblems;
    return (answeredProblems / totalProblems) * 100;
  }

  /// Calculate accuracy percentage
  double get accuracy {
    final answeredProblems = correctAnswers + incorrectAnswers;
    if (answeredProblems == 0) return 0.0;
    return (correctAnswers / answeredProblems) * 100;
  }

  /// Get time spent as Duration
  @ignore
  Duration get timeSpent => Duration(milliseconds: totalTimeMs);

  /// Get average time per problem in seconds
  double get averageTimePerProblem {
    final answeredProblems = correctAnswers + incorrectAnswers + skippedProblems;
    if (answeredProblems == 0) return 0.0;
    return totalTimeMs / 1000.0 / answeredProblems;
  }

  /// Check if session is active
  bool get isActive => status == SessionStatus.active;

  /// Check if session is completed
  bool get isCompleted => status == SessionStatus.completed;

  /// Check if session is paused
  bool get isPaused => status == SessionStatus.paused;

  /// Add user answer
  QuizSession addAnswer({
    required String problemId,
    required String answer,
    required bool isCorrect,
    required int timeSpentMs,
    String? explanation,
  }) {
    final answers = userAnswersList;
    answers.add({
      'problemId': problemId,
      'answer': answer,
      'isCorrect': isCorrect,
      'timeSpentMs': timeSpentMs,
      'timestamp': DateTime.now().toIso8601String(),
      'explanation': explanation,
    });

    return copyWith(
      userAnswers: jsonEncode(answers),
      correctAnswers: isCorrect ? correctAnswers + 1 : correctAnswers,
      incorrectAnswers: isCorrect ? incorrectAnswers : incorrectAnswers + 1,
      totalTimeMs: totalTimeMs + timeSpentMs,
      currentProblemIndex: currentProblemIndex + 1,
    );
  }

  /// Complete the session
  QuizSession complete({double? score}) {
    final finalScoreCalculated = score ?? accuracy;
    return copyWith(
      status: SessionStatus.completed,
      completedAt: DateTime.now(),
      finalScore: finalScoreCalculated,
    );
  }

  /// Pause the session
  QuizSession pause() {
    return copyWith(
      status: SessionStatus.paused,
      pausedAt: DateTime.now(),
    );
  }

  /// Resume the session
  QuizSession resume() {
    return copyWith(
      status: SessionStatus.active,
      pausedAt: null,
    );
  }

  /// Copy with method for updating fields
  QuizSession copyWith({
    String? sessionId,
    String? title,
    SessionType? type,
    SessionStatus? status,
    String? problemIds,
    String? userAnswers,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? pausedAt,
    int? totalTimeMs,
    int? currentProblemIndex,
    int? totalProblems,
    int? correctAnswers,
    int? incorrectAnswers,
    int? skippedProblems,
    double? finalScore,
    String? settings,
    String? notes,
    String? subjects,
    String? difficulties,
    String? reviewData,
  }) {
    final session = QuizSession()
      ..id = id
      ..sessionId = sessionId ?? this.sessionId
      ..title = title ?? this.title
      ..type = type ?? this.type
      ..status = status ?? this.status
      ..problemIds = problemIds ?? this.problemIds
      ..userAnswers = userAnswers ?? this.userAnswers
      ..createdAt = createdAt ?? this.createdAt
      ..completedAt = completedAt ?? this.completedAt
      ..pausedAt = pausedAt ?? this.pausedAt
      ..totalTimeMs = totalTimeMs ?? this.totalTimeMs
      ..currentProblemIndex = currentProblemIndex ?? this.currentProblemIndex
      ..totalProblems = totalProblems ?? this.totalProblems
      ..correctAnswers = correctAnswers ?? this.correctAnswers
      ..incorrectAnswers = incorrectAnswers ?? this.incorrectAnswers
      ..skippedProblems = skippedProblems ?? this.skippedProblems
      ..finalScore = finalScore ?? this.finalScore
      ..settings = settings ?? this.settings
      ..notes = notes ?? this.notes
      ..subjects = subjects ?? this.subjects
      ..difficulties = difficulties ?? this.difficulties
      ..reviewData = reviewData ?? this.reviewData;
    return session;
  }

  @override
  String toString() {
    return 'QuizSession{id: $id, sessionId: $sessionId, title: $title, type: $type, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizSession && other.sessionId == sessionId;
  }

  @override
  int get hashCode => sessionId.hashCode;
}