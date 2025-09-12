import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reading_models.g.dart';

// 독서 관련 열거형 타입들
@HiveType(typeId: 40)
enum BookGenre {
  @HiveField(0) fiction,
  @HiveField(1) nonFiction,
  @HiveField(2) fantasy,
  @HiveField(3) mystery,
  @HiveField(4) romance,
  @HiveField(5) scienceFiction,
  @HiveField(6) biography,
  @HiveField(7) history,
  @HiveField(8) science,
  @HiveField(9) selfHelp,
  @HiveField(10) children,
  @HiveField(11) educational,
}

@HiveType(typeId: 41)
enum ReadingStatus {
  @HiveField(0) notStarted,
  @HiveField(1) reading,
  @HiveField(2) completed,
  @HiveField(3) paused,
  @HiveField(4) abandoned,
}

@HiveType(typeId: 42)
enum QuizType {
  @HiveField(0) multipleChoice,
  @HiveField(1) trueFalse,
  @HiveField(2) shortAnswer,
  @HiveField(3) essay,
  @HiveField(4) comprehension,
  @HiveField(5) vocabulary,
  @HiveField(6) sequencing,
}

@HiveType(typeId: 43)
enum ARLevel {
  @HiveField(0) preschool,    // AR 0.0-0.9
  @HiveField(1) kindergarten,  // AR 1.0-1.9
  @HiveField(2) grade1,       // AR 2.0-2.9
  @HiveField(3) grade2,       // AR 3.0-3.9
  @HiveField(4) grade3,       // AR 4.0-4.9
  @HiveField(5) grade4,       // AR 5.0-5.9
  @HiveField(6) grade5,       // AR 6.0-6.9
  @HiveField(7) grade6,       // AR 7.0-7.9
  @HiveField(8) middleSchool, // AR 8.0-9.9
  @HiveField(9) highSchool,   // AR 10.0+
}

@HiveType(typeId: 44)
enum QuizDifficulty {
  @HiveField(0) easy,
  @HiveField(1) medium,
  @HiveField(2) hard,
}

// 책 모델
@HiveType(typeId: 45)
@JsonSerializable()
class Book {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String author;
  
  @HiveField(3)
  final String isbn;
  
  @HiveField(4)
  final String? description;
  
  @HiveField(5)
  final String? coverImageUrl;
  
  @HiveField(6)
  final BookGenre genre;
  
  @HiveField(7)
  final ARLevel arLevel;
  
  @HiveField(8)
  final double arPoints;
  
  @HiveField(9)
  final int pageCount;
  
  @HiveField(10)
  final int wordCount;
  
  @HiveField(11)
  final DateTime publishedDate;
  
  @HiveField(12)
  final List<String> tags;
  
  @HiveField(13)
  final DateTime createdAt;
  
  @HiveField(14)
  final bool isAvailable;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    this.description,
    this.coverImageUrl,
    required this.genre,
    required this.arLevel,
    required this.arPoints,
    required this.pageCount,
    required this.wordCount,
    required this.publishedDate,
    required this.tags,
    required this.createdAt,
    this.isAvailable = true,
  });

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
  Map<String, dynamic> toJson() => _$BookToJson(this);
}

// 독서 세션 모델
@HiveType(typeId: 46)
@JsonSerializable()
class ReadingSession {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String bookId;
  
  @HiveField(3)
  final DateTime startedAt;
  
  @HiveField(4)
  final DateTime? endedAt;
  
  @HiveField(5)
  final Duration duration;
  
  @HiveField(6)
  final int startPage;
  
  @HiveField(7)
  final int endPage;
  
  @HiveField(8)
  final int wordsRead;
  
  @HiveField(9)
  final ReadingStatus status;
  
  @HiveField(10)
  final double comprehensionScore;
  
  @HiveField(11)
  final String? notes;
  
  @HiveField(12)
  final List<String> vocabularyWords;

  ReadingSession({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.startedAt,
    this.endedAt,
    required this.duration,
    required this.startPage,
    required this.endPage,
    required this.wordsRead,
    required this.status,
    this.comprehensionScore = 0.0,
    this.notes,
    required this.vocabularyWords,
  });

  factory ReadingSession.fromJson(Map<String, dynamic> json) => _$ReadingSessionFromJson(json);
  Map<String, dynamic> toJson() => _$ReadingSessionToJson(this);
}

// 독서 진행 상황 모델
@HiveType(typeId: 47)
@JsonSerializable()
class ReadingProgress {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String bookId;
  
  @HiveField(3)
  final int currentPage;
  
  @HiveField(4)
  final double progressPercentage;
  
  @HiveField(5)
  final DateTime lastReadAt;
  
  @HiveField(6)
  final Duration totalReadingTime;
  
  @HiveField(7)
  final int totalWordsRead;
  
  @HiveField(8)
  final ReadingStatus status;
  
  @HiveField(9)
  final List<String> bookmarks;
  
  @HiveField(10)
  final Map<String, dynamic> metadata;

  ReadingProgress({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.currentPage,
    required this.progressPercentage,
    required this.lastReadAt,
    required this.totalReadingTime,
    required this.totalWordsRead,
    required this.status,
    required this.bookmarks,
    required this.metadata,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) => _$ReadingProgressFromJson(json);
  Map<String, dynamic> toJson() => _$ReadingProgressToJson(this);
}

// 퀴즈 질문 모델
@HiveType(typeId: 48)
@JsonSerializable()
class QuizQuestion {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String bookId;
  
  @HiveField(2)
  final QuizType type;
  
  @HiveField(3)
  final QuizDifficulty difficulty;
  
  @HiveField(4)
  final String question;
  
  @HiveField(5)
  final List<String> options;
  
  @HiveField(6)
  final String correctAnswer;
  
  @HiveField(7)
  final String? explanation;
  
  @HiveField(8)
  final int points;
  
  @HiveField(9)
  final List<String> tags;
  
  @HiveField(10)
  final DateTime createdAt;
  
  @HiveField(11)
  final int chapterNumber;
  
  @HiveField(12)
  final String? referenceText;

  QuizQuestion({
    required this.id,
    required this.bookId,
    required this.type,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.points,
    required this.tags,
    required this.createdAt,
    required this.chapterNumber,
    this.referenceText,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => _$QuizQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuizQuestionToJson(this);
}

// 퀴즈 세션 모델
@HiveType(typeId: 49)
@JsonSerializable()
class QuizSession {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String bookId;
  
  @HiveField(3)
  final List<String> questionIds;
  
  @HiveField(4)
  final DateTime startedAt;
  
  @HiveField(5)
  final DateTime? completedAt;
  
  @HiveField(6)
  final Duration timeSpent;
  
  @HiveField(7)
  final int totalQuestions;
  
  @HiveField(8)
  final int correctAnswers;
  
  @HiveField(9)
  final double score;
  
  @HiveField(10)
  final bool isPassed;
  
  @HiveField(11)
  final Map<String, String> userAnswers;
  
  @HiveField(12)
  final List<QuizAttempt> attempts;

  QuizSession({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.questionIds,
    required this.startedAt,
    this.completedAt,
    required this.timeSpent,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.isPassed,
    required this.userAnswers,
    required this.attempts,
  });

  factory QuizSession.fromJson(Map<String, dynamic> json) => _$QuizSessionFromJson(json);
  Map<String, dynamic> toJson() => _$QuizSessionToJson(this);
}

// 퀴즈 시도 모델
@HiveType(typeId: 50)
@JsonSerializable()
class QuizAttempt {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String questionId;
  
  @HiveField(2)
  final String userAnswer;
  
  @HiveField(3)
  final bool isCorrect;
  
  @HiveField(4)
  final DateTime answeredAt;
  
  @HiveField(5)
  final Duration timeSpent;
  
  @HiveField(6)
  final int attempts;

  QuizAttempt({
    required this.id,
    required this.questionId,
    required this.userAnswer,
    required this.isCorrect,
    required this.answeredAt,
    required this.timeSpent,
    required this.attempts,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) => _$QuizAttemptFromJson(json);
  Map<String, dynamic> toJson() => _$QuizAttemptToJson(this);
}

// AR 성취 기록 모델
@HiveType(typeId: 51)
@JsonSerializable()
class ARRecord {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String bookId;
  
  @HiveField(3)
  final double arPoints;
  
  @HiveField(4)
  final ARLevel arLevel;
  
  @HiveField(5)
  final double quizScore;
  
  @HiveField(6)
  final DateTime completedAt;
  
  @HiveField(7)
  final Duration readingTime;
  
  @HiveField(8)
  final int wordsRead;
  
  @HiveField(9)
  final bool isVerified;
  
  @HiveField(10)
  final Map<String, dynamic> achievements;

  ARRecord({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.arPoints,
    required this.arLevel,
    required this.quizScore,
    required this.completedAt,
    required this.readingTime,
    required this.wordsRead,
    this.isVerified = false,
    required this.achievements,
  });

  factory ARRecord.fromJson(Map<String, dynamic> json) => _$ARRecordFromJson(json);
  Map<String, dynamic> toJson() => _$ARRecordToJson(this);
}

// 독서 통계 모델
@HiveType(typeId: 52)
@JsonSerializable()
class ReadingStats {
  @HiveField(0)
  final String userId;
  
  @HiveField(1)
  final int booksRead;
  
  @HiveField(2)
  final double totalARPoints;
  
  @HiveField(3)
  final ARLevel currentARLevel;
  
  @HiveField(4)
  final Duration totalReadingTime;
  
  @HiveField(5)
  final int totalWordsRead;
  
  @HiveField(6)
  final double averageQuizScore;
  
  @HiveField(7)
  final Map<BookGenre, int> genrePreferences;
  
  @HiveField(8)
  final List<String> achievements;
  
  @HiveField(9)
  final DateTime lastUpdated;
  
  @HiveField(10)
  final int readingStreak;
  
  @HiveField(11)
  final Map<String, dynamic> monthlyProgress;

  ReadingStats({
    required this.userId,
    required this.booksRead,
    required this.totalARPoints,
    required this.currentARLevel,
    required this.totalReadingTime,
    required this.totalWordsRead,
    required this.averageQuizScore,
    required this.genrePreferences,
    required this.achievements,
    required this.lastUpdated,
    required this.readingStreak,
    required this.monthlyProgress,
  });

  factory ReadingStats.fromJson(Map<String, dynamic> json) => _$ReadingStatsFromJson(json);
  Map<String, dynamic> toJson() => _$ReadingStatsToJson(this);
}