import 'package:hive/hive.dart';

part 'vocabulary_model.g.dart';

@HiveType(typeId: 2)
class VocabularyWord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String word;

  @HiveField(2)
  String meaning;

  @HiveField(3)
  String? pronunciation;

  @HiveField(4)
  String? example;

  @HiveField(5)
  String? exampleTranslation;

  @HiveField(6)
  DifficultyLevel difficulty;

  @HiveField(7)
  String category;

  @HiveField(8)
  List<String> tags;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime lastReviewed;

  @HiveField(11)
  int reviewCount;

  @HiveField(12)
  int correctCount;

  @HiveField(13)
  double easeFactor;

  @HiveField(14)
  int interval;

  @HiveField(15)
  DateTime nextReview;

  @HiveField(16)
  LearningStatus status;

  @HiveField(17)
  String? imageUrl;

  @HiveField(18)
  String? audioUrl;

  @HiveField(19)
  String userId;

  VocabularyWord({
    required this.id,
    required this.word,
    required this.meaning,
    this.pronunciation,
    this.example,
    this.exampleTranslation,
    this.difficulty = DifficultyLevel.beginner,
    this.category = '일반',
    this.tags = const [],
    required this.createdAt,
    DateTime? lastReviewed,
    this.reviewCount = 0,
    this.correctCount = 0,
    this.easeFactor = 2.5,
    this.interval = 1,
    DateTime? nextReview,
    this.status = LearningStatus.newWord,
    this.imageUrl,
    this.audioUrl,
    required this.userId,
  }) : lastReviewed = lastReviewed ?? createdAt,
       nextReview = nextReview ?? createdAt.add(const Duration(days: 1));

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id'] as String,
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      pronunciation: json['pronunciation'] as String?,
      example: json['example'] as String?,
      exampleTranslation: json['exampleTranslation'] as String?,
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.toString() == 'DifficultyLevel.${json['difficulty']}',
        orElse: () => DifficultyLevel.beginner,
      ),
      category: json['category'] as String? ?? '일반',
      tags: List<String>.from(json['tags'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastReviewed: json['lastReviewed'] != null
          ? DateTime.parse(json['lastReviewed'] as String)
          : null,
      reviewCount: json['reviewCount'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      interval: json['interval'] as int? ?? 1,
      nextReview: json['nextReview'] != null
          ? DateTime.parse(json['nextReview'] as String)
          : null,
      status: LearningStatus.values.firstWhere(
        (e) => e.toString() == 'LearningStatus.${json['status']}',
        orElse: () => LearningStatus.newWord,
      ),
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      userId: json['userId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'pronunciation': pronunciation,
      'example': example,
      'exampleTranslation': exampleTranslation,
      'difficulty': difficulty.toString().split('.').last,
      'category': category,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'lastReviewed': lastReviewed.toIso8601String(),
      'reviewCount': reviewCount,
      'correctCount': correctCount,
      'easeFactor': easeFactor,
      'interval': interval,
      'nextReview': nextReview.toIso8601String(),
      'status': status.toString().split('.').last,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'userId': userId,
    };
  }

  // SRS (Spaced Repetition System) 계산
  void updateSRS(ReviewResult result) {
    final now = DateTime.now();
    reviewCount++;
    lastReviewed = now;

    switch (result) {
      case ReviewResult.perfect:
        correctCount++;
        easeFactor = (easeFactor + 0.1).clamp(1.3, 2.5);
        interval = (interval * easeFactor).round();
        status = interval >= 21 ? LearningStatus.mastered : LearningStatus.learning;
        break;
      
      case ReviewResult.correct:
        correctCount++;
        interval = (interval * easeFactor).round();
        status = LearningStatus.learning;
        break;
      
      case ReviewResult.hard:
        easeFactor = (easeFactor - 0.15).clamp(1.3, 2.5);
        interval = (interval * 1.2).round();
        status = LearningStatus.learning;
        break;
      
      case ReviewResult.wrong:
        easeFactor = (easeFactor - 0.2).clamp(1.3, 2.5);
        interval = 1;
        status = LearningStatus.review;
        break;
    }

    nextReview = now.add(Duration(days: interval));
  }

  // 정답률 계산
  double get accuracyRate {
    if (reviewCount == 0) return 0.0;
    return correctCount / reviewCount;
  }

  // 복습 필요 여부
  bool get needsReview {
    return DateTime.now().isAfter(nextReview);
  }

  // 학습 진도율 (0.0 ~ 1.0)
  double get masteryProgress {
    if (status == LearningStatus.mastered) return 1.0;
    return (accuracyRate * 0.7) + ((interval / 30) * 0.3);
  }

  // 단어 길이 기반 난이도 자동 판정
  static DifficultyLevel estimateDifficulty(String word) {
    final length = word.length;
    if (length <= 4) return DifficultyLevel.beginner;
    if (length <= 8) return DifficultyLevel.intermediate;
    return DifficultyLevel.advanced;
  }
}

@HiveType(typeId: 3)
enum DifficultyLevel {
  @HiveField(0)
  beginner,    // 초급

  @HiveField(1)
  intermediate, // 중급

  @HiveField(2)
  advanced,    // 고급
}

@HiveType(typeId: 4)
enum LearningStatus {
  @HiveField(0)
  newWord,     // 새 단어

  @HiveField(1)
  learning,    // 학습 중

  @HiveField(2)
  review,      // 복습 필요

  @HiveField(3)
  mastered,    // 숙달됨
}

@HiveType(typeId: 5)
enum ReviewResult {
  @HiveField(0)
  perfect,     // 완벽 (즉시 기억)

  @HiveField(1)
  correct,     // 정답 (약간 생각)

  @HiveField(2)
  hard,        // 어려움 (오래 생각)

  @HiveField(3)
  wrong,       // 틀림
}

// Extensions
extension DifficultyLevelExtension on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.beginner:
        return '초급';
      case DifficultyLevel.intermediate:
        return '중급';
      case DifficultyLevel.advanced:
        return '고급';
    }
  }

  String get emoji {
    switch (this) {
      case DifficultyLevel.beginner:
        return '🟢';
      case DifficultyLevel.intermediate:
        return '🟡';
      case DifficultyLevel.advanced:
        return '🔴';
    }
  }
}

extension LearningStatusExtension on LearningStatus {
  String get displayName {
    switch (this) {
      case LearningStatus.newWord:
        return '새 단어';
      case LearningStatus.learning:
        return '학습 중';
      case LearningStatus.review:
        return '복습 필요';
      case LearningStatus.mastered:
        return '숙달됨';
    }
  }

  String get emoji {
    switch (this) {
      case LearningStatus.newWord:
        return '✨';
      case LearningStatus.learning:
        return '📚';
      case LearningStatus.review:
        return '🔄';
      case LearningStatus.mastered:
        return '🏆';
    }
  }
}

extension ReviewResultExtension on ReviewResult {
  String get displayName {
    switch (this) {
      case ReviewResult.perfect:
        return '완벽';
      case ReviewResult.correct:
        return '정답';
      case ReviewResult.hard:
        return '어려움';
      case ReviewResult.wrong:
        return '틀림';
    }
  }

  String get emoji {
    switch (this) {
      case ReviewResult.perfect:
        return '🎯';
      case ReviewResult.correct:
        return '✅';
      case ReviewResult.hard:
        return '😅';
      case ReviewResult.wrong:
        return '❌';
    }
  }
}