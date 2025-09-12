// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 45;

  @override
  Book read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Book(
      id: fields[0] as String,
      title: fields[1] as String,
      author: fields[2] as String,
      isbn: fields[3] as String,
      description: fields[4] as String?,
      coverImageUrl: fields[5] as String?,
      genre: fields[6] as BookGenre,
      arLevel: fields[7] as ARLevel,
      arPoints: fields[8] as double,
      pageCount: fields[9] as int,
      wordCount: fields[10] as int,
      publishedDate: fields[11] as DateTime,
      tags: (fields[12] as List).cast<String>(),
      createdAt: fields[13] as DateTime,
      isAvailable: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.isbn)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.coverImageUrl)
      ..writeByte(6)
      ..write(obj.genre)
      ..writeByte(7)
      ..write(obj.arLevel)
      ..writeByte(8)
      ..write(obj.arPoints)
      ..writeByte(9)
      ..write(obj.pageCount)
      ..writeByte(10)
      ..write(obj.wordCount)
      ..writeByte(11)
      ..write(obj.publishedDate)
      ..writeByte(12)
      ..write(obj.tags)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.isAvailable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReadingSessionAdapter extends TypeAdapter<ReadingSession> {
  @override
  final int typeId = 46;

  @override
  ReadingSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingSession(
      id: fields[0] as String,
      userId: fields[1] as String,
      bookId: fields[2] as String,
      startedAt: fields[3] as DateTime,
      endedAt: fields[4] as DateTime?,
      duration: fields[5] as Duration,
      startPage: fields[6] as int,
      endPage: fields[7] as int,
      wordsRead: fields[8] as int,
      status: fields[9] as ReadingStatus,
      comprehensionScore: fields[10] as double,
      notes: fields[11] as String?,
      vocabularyWords: (fields[12] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ReadingSession obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.bookId)
      ..writeByte(3)
      ..write(obj.startedAt)
      ..writeByte(4)
      ..write(obj.endedAt)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.startPage)
      ..writeByte(7)
      ..write(obj.endPage)
      ..writeByte(8)
      ..write(obj.wordsRead)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.comprehensionScore)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.vocabularyWords);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReadingProgressAdapter extends TypeAdapter<ReadingProgress> {
  @override
  final int typeId = 47;

  @override
  ReadingProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingProgress(
      id: fields[0] as String,
      userId: fields[1] as String,
      bookId: fields[2] as String,
      currentPage: fields[3] as int,
      progressPercentage: fields[4] as double,
      lastReadAt: fields[5] as DateTime,
      totalReadingTime: fields[6] as Duration,
      totalWordsRead: fields[7] as int,
      status: fields[8] as ReadingStatus,
      bookmarks: (fields[9] as List).cast<String>(),
      metadata: (fields[10] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ReadingProgress obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.bookId)
      ..writeByte(3)
      ..write(obj.currentPage)
      ..writeByte(4)
      ..write(obj.progressPercentage)
      ..writeByte(5)
      ..write(obj.lastReadAt)
      ..writeByte(6)
      ..write(obj.totalReadingTime)
      ..writeByte(7)
      ..write(obj.totalWordsRead)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.bookmarks)
      ..writeByte(10)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuizQuestionAdapter extends TypeAdapter<QuizQuestion> {
  @override
  final int typeId = 48;

  @override
  QuizQuestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizQuestion(
      id: fields[0] as String,
      bookId: fields[1] as String,
      type: fields[2] as QuizType,
      difficulty: fields[3] as QuizDifficulty,
      question: fields[4] as String,
      options: (fields[5] as List).cast<String>(),
      correctAnswer: fields[6] as String,
      explanation: fields[7] as String?,
      points: fields[8] as int,
      tags: (fields[9] as List).cast<String>(),
      createdAt: fields[10] as DateTime,
      chapterNumber: fields[11] as int,
      referenceText: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QuizQuestion obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bookId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.difficulty)
      ..writeByte(4)
      ..write(obj.question)
      ..writeByte(5)
      ..write(obj.options)
      ..writeByte(6)
      ..write(obj.correctAnswer)
      ..writeByte(7)
      ..write(obj.explanation)
      ..writeByte(8)
      ..write(obj.points)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.chapterNumber)
      ..writeByte(12)
      ..write(obj.referenceText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizQuestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuizSessionAdapter extends TypeAdapter<QuizSession> {
  @override
  final int typeId = 49;

  @override
  QuizSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizSession(
      id: fields[0] as String,
      userId: fields[1] as String,
      bookId: fields[2] as String,
      questionIds: (fields[3] as List).cast<String>(),
      startedAt: fields[4] as DateTime,
      completedAt: fields[5] as DateTime?,
      timeSpent: fields[6] as Duration,
      totalQuestions: fields[7] as int,
      correctAnswers: fields[8] as int,
      score: fields[9] as double,
      isPassed: fields[10] as bool,
      userAnswers: (fields[11] as Map).cast<String, String>(),
      attempts: (fields[12] as List).cast<QuizAttempt>(),
    );
  }

  @override
  void write(BinaryWriter writer, QuizSession obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.bookId)
      ..writeByte(3)
      ..write(obj.questionIds)
      ..writeByte(4)
      ..write(obj.startedAt)
      ..writeByte(5)
      ..write(obj.completedAt)
      ..writeByte(6)
      ..write(obj.timeSpent)
      ..writeByte(7)
      ..write(obj.totalQuestions)
      ..writeByte(8)
      ..write(obj.correctAnswers)
      ..writeByte(9)
      ..write(obj.score)
      ..writeByte(10)
      ..write(obj.isPassed)
      ..writeByte(11)
      ..write(obj.userAnswers)
      ..writeByte(12)
      ..write(obj.attempts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuizAttemptAdapter extends TypeAdapter<QuizAttempt> {
  @override
  final int typeId = 50;

  @override
  QuizAttempt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizAttempt(
      id: fields[0] as String,
      questionId: fields[1] as String,
      userAnswer: fields[2] as String,
      isCorrect: fields[3] as bool,
      answeredAt: fields[4] as DateTime,
      timeSpent: fields[5] as Duration,
      attempts: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QuizAttempt obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.questionId)
      ..writeByte(2)
      ..write(obj.userAnswer)
      ..writeByte(3)
      ..write(obj.isCorrect)
      ..writeByte(4)
      ..write(obj.answeredAt)
      ..writeByte(5)
      ..write(obj.timeSpent)
      ..writeByte(6)
      ..write(obj.attempts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizAttemptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ARRecordAdapter extends TypeAdapter<ARRecord> {
  @override
  final int typeId = 51;

  @override
  ARRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ARRecord(
      id: fields[0] as String,
      userId: fields[1] as String,
      bookId: fields[2] as String,
      arPoints: fields[3] as double,
      arLevel: fields[4] as ARLevel,
      quizScore: fields[5] as double,
      completedAt: fields[6] as DateTime,
      readingTime: fields[7] as Duration,
      wordsRead: fields[8] as int,
      isVerified: fields[9] as bool,
      achievements: (fields[10] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ARRecord obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.bookId)
      ..writeByte(3)
      ..write(obj.arPoints)
      ..writeByte(4)
      ..write(obj.arLevel)
      ..writeByte(5)
      ..write(obj.quizScore)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.readingTime)
      ..writeByte(8)
      ..write(obj.wordsRead)
      ..writeByte(9)
      ..write(obj.isVerified)
      ..writeByte(10)
      ..write(obj.achievements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ARRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReadingStatsAdapter extends TypeAdapter<ReadingStats> {
  @override
  final int typeId = 52;

  @override
  ReadingStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingStats(
      userId: fields[0] as String,
      booksRead: fields[1] as int,
      totalARPoints: fields[2] as double,
      currentARLevel: fields[3] as ARLevel,
      totalReadingTime: fields[4] as Duration,
      totalWordsRead: fields[5] as int,
      averageQuizScore: fields[6] as double,
      genrePreferences: (fields[7] as Map).cast<BookGenre, int>(),
      achievements: (fields[8] as List).cast<String>(),
      lastUpdated: fields[9] as DateTime,
      readingStreak: fields[10] as int,
      monthlyProgress: (fields[11] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ReadingStats obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.booksRead)
      ..writeByte(2)
      ..write(obj.totalARPoints)
      ..writeByte(3)
      ..write(obj.currentARLevel)
      ..writeByte(4)
      ..write(obj.totalReadingTime)
      ..writeByte(5)
      ..write(obj.totalWordsRead)
      ..writeByte(6)
      ..write(obj.averageQuizScore)
      ..writeByte(7)
      ..write(obj.genrePreferences)
      ..writeByte(8)
      ..write(obj.achievements)
      ..writeByte(9)
      ..write(obj.lastUpdated)
      ..writeByte(10)
      ..write(obj.readingStreak)
      ..writeByte(11)
      ..write(obj.monthlyProgress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookGenreAdapter extends TypeAdapter<BookGenre> {
  @override
  final int typeId = 40;

  @override
  BookGenre read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BookGenre.fiction;
      case 1:
        return BookGenre.nonFiction;
      case 2:
        return BookGenre.fantasy;
      case 3:
        return BookGenre.mystery;
      case 4:
        return BookGenre.romance;
      case 5:
        return BookGenre.scienceFiction;
      case 6:
        return BookGenre.biography;
      case 7:
        return BookGenre.history;
      case 8:
        return BookGenre.science;
      case 9:
        return BookGenre.selfHelp;
      case 10:
        return BookGenre.children;
      case 11:
        return BookGenre.educational;
      default:
        return BookGenre.fiction;
    }
  }

  @override
  void write(BinaryWriter writer, BookGenre obj) {
    switch (obj) {
      case BookGenre.fiction:
        writer.writeByte(0);
        break;
      case BookGenre.nonFiction:
        writer.writeByte(1);
        break;
      case BookGenre.fantasy:
        writer.writeByte(2);
        break;
      case BookGenre.mystery:
        writer.writeByte(3);
        break;
      case BookGenre.romance:
        writer.writeByte(4);
        break;
      case BookGenre.scienceFiction:
        writer.writeByte(5);
        break;
      case BookGenre.biography:
        writer.writeByte(6);
        break;
      case BookGenre.history:
        writer.writeByte(7);
        break;
      case BookGenre.science:
        writer.writeByte(8);
        break;
      case BookGenre.selfHelp:
        writer.writeByte(9);
        break;
      case BookGenre.children:
        writer.writeByte(10);
        break;
      case BookGenre.educational:
        writer.writeByte(11);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookGenreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReadingStatusAdapter extends TypeAdapter<ReadingStatus> {
  @override
  final int typeId = 41;

  @override
  ReadingStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReadingStatus.notStarted;
      case 1:
        return ReadingStatus.reading;
      case 2:
        return ReadingStatus.completed;
      case 3:
        return ReadingStatus.paused;
      case 4:
        return ReadingStatus.abandoned;
      default:
        return ReadingStatus.notStarted;
    }
  }

  @override
  void write(BinaryWriter writer, ReadingStatus obj) {
    switch (obj) {
      case ReadingStatus.notStarted:
        writer.writeByte(0);
        break;
      case ReadingStatus.reading:
        writer.writeByte(1);
        break;
      case ReadingStatus.completed:
        writer.writeByte(2);
        break;
      case ReadingStatus.paused:
        writer.writeByte(3);
        break;
      case ReadingStatus.abandoned:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuizTypeAdapter extends TypeAdapter<QuizType> {
  @override
  final int typeId = 42;

  @override
  QuizType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuizType.multipleChoice;
      case 1:
        return QuizType.trueFalse;
      case 2:
        return QuizType.shortAnswer;
      case 3:
        return QuizType.essay;
      case 4:
        return QuizType.comprehension;
      case 5:
        return QuizType.vocabulary;
      case 6:
        return QuizType.sequencing;
      default:
        return QuizType.multipleChoice;
    }
  }

  @override
  void write(BinaryWriter writer, QuizType obj) {
    switch (obj) {
      case QuizType.multipleChoice:
        writer.writeByte(0);
        break;
      case QuizType.trueFalse:
        writer.writeByte(1);
        break;
      case QuizType.shortAnswer:
        writer.writeByte(2);
        break;
      case QuizType.essay:
        writer.writeByte(3);
        break;
      case QuizType.comprehension:
        writer.writeByte(4);
        break;
      case QuizType.vocabulary:
        writer.writeByte(5);
        break;
      case QuizType.sequencing:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ARLevelAdapter extends TypeAdapter<ARLevel> {
  @override
  final int typeId = 43;

  @override
  ARLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ARLevel.preschool;
      case 1:
        return ARLevel.kindergarten;
      case 2:
        return ARLevel.grade1;
      case 3:
        return ARLevel.grade2;
      case 4:
        return ARLevel.grade3;
      case 5:
        return ARLevel.grade4;
      case 6:
        return ARLevel.grade5;
      case 7:
        return ARLevel.grade6;
      case 8:
        return ARLevel.middleSchool;
      case 9:
        return ARLevel.highSchool;
      default:
        return ARLevel.preschool;
    }
  }

  @override
  void write(BinaryWriter writer, ARLevel obj) {
    switch (obj) {
      case ARLevel.preschool:
        writer.writeByte(0);
        break;
      case ARLevel.kindergarten:
        writer.writeByte(1);
        break;
      case ARLevel.grade1:
        writer.writeByte(2);
        break;
      case ARLevel.grade2:
        writer.writeByte(3);
        break;
      case ARLevel.grade3:
        writer.writeByte(4);
        break;
      case ARLevel.grade4:
        writer.writeByte(5);
        break;
      case ARLevel.grade5:
        writer.writeByte(6);
        break;
      case ARLevel.grade6:
        writer.writeByte(7);
        break;
      case ARLevel.middleSchool:
        writer.writeByte(8);
        break;
      case ARLevel.highSchool:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ARLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuizDifficultyAdapter extends TypeAdapter<QuizDifficulty> {
  @override
  final int typeId = 44;

  @override
  QuizDifficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuizDifficulty.easy;
      case 1:
        return QuizDifficulty.medium;
      case 2:
        return QuizDifficulty.hard;
      default:
        return QuizDifficulty.easy;
    }
  }

  @override
  void write(BinaryWriter writer, QuizDifficulty obj) {
    switch (obj) {
      case QuizDifficulty.easy:
        writer.writeByte(0);
        break;
      case QuizDifficulty.medium:
        writer.writeByte(1);
        break;
      case QuizDifficulty.hard:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizDifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      isbn: json['isbn'] as String,
      description: json['description'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      genre: $enumDecode(_$BookGenreEnumMap, json['genre']),
      arLevel: $enumDecode(_$ARLevelEnumMap, json['arLevel']),
      arPoints: (json['arPoints'] as num).toDouble(),
      pageCount: (json['pageCount'] as num).toInt(),
      wordCount: (json['wordCount'] as num).toInt(),
      publishedDate: DateTime.parse(json['publishedDate'] as String),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isAvailable: json['isAvailable'] as bool? ?? true,
    );

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'author': instance.author,
      'isbn': instance.isbn,
      'description': instance.description,
      'coverImageUrl': instance.coverImageUrl,
      'genre': _$BookGenreEnumMap[instance.genre]!,
      'arLevel': _$ARLevelEnumMap[instance.arLevel]!,
      'arPoints': instance.arPoints,
      'pageCount': instance.pageCount,
      'wordCount': instance.wordCount,
      'publishedDate': instance.publishedDate.toIso8601String(),
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'isAvailable': instance.isAvailable,
    };

const _$BookGenreEnumMap = {
  BookGenre.fiction: 'fiction',
  BookGenre.nonFiction: 'nonFiction',
  BookGenre.fantasy: 'fantasy',
  BookGenre.mystery: 'mystery',
  BookGenre.romance: 'romance',
  BookGenre.scienceFiction: 'scienceFiction',
  BookGenre.biography: 'biography',
  BookGenre.history: 'history',
  BookGenre.science: 'science',
  BookGenre.selfHelp: 'selfHelp',
  BookGenre.children: 'children',
  BookGenre.educational: 'educational',
};

const _$ARLevelEnumMap = {
  ARLevel.preschool: 'preschool',
  ARLevel.kindergarten: 'kindergarten',
  ARLevel.grade1: 'grade1',
  ARLevel.grade2: 'grade2',
  ARLevel.grade3: 'grade3',
  ARLevel.grade4: 'grade4',
  ARLevel.grade5: 'grade5',
  ARLevel.grade6: 'grade6',
  ARLevel.middleSchool: 'middleSchool',
  ARLevel.highSchool: 'highSchool',
};

ReadingSession _$ReadingSessionFromJson(Map<String, dynamic> json) =>
    ReadingSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bookId: json['bookId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      startPage: (json['startPage'] as num).toInt(),
      endPage: (json['endPage'] as num).toInt(),
      wordsRead: (json['wordsRead'] as num).toInt(),
      status: $enumDecode(_$ReadingStatusEnumMap, json['status']),
      comprehensionScore:
          (json['comprehensionScore'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      vocabularyWords: (json['vocabularyWords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ReadingSessionToJson(ReadingSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'bookId': instance.bookId,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
      'startPage': instance.startPage,
      'endPage': instance.endPage,
      'wordsRead': instance.wordsRead,
      'status': _$ReadingStatusEnumMap[instance.status]!,
      'comprehensionScore': instance.comprehensionScore,
      'notes': instance.notes,
      'vocabularyWords': instance.vocabularyWords,
    };

const _$ReadingStatusEnumMap = {
  ReadingStatus.notStarted: 'notStarted',
  ReadingStatus.reading: 'reading',
  ReadingStatus.completed: 'completed',
  ReadingStatus.paused: 'paused',
  ReadingStatus.abandoned: 'abandoned',
};

ReadingProgress _$ReadingProgressFromJson(Map<String, dynamic> json) =>
    ReadingProgress(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bookId: json['bookId'] as String,
      currentPage: (json['currentPage'] as num).toInt(),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      lastReadAt: DateTime.parse(json['lastReadAt'] as String),
      totalReadingTime:
          Duration(microseconds: (json['totalReadingTime'] as num).toInt()),
      totalWordsRead: (json['totalWordsRead'] as num).toInt(),
      status: $enumDecode(_$ReadingStatusEnumMap, json['status']),
      bookmarks:
          (json['bookmarks'] as List<dynamic>).map((e) => e as String).toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ReadingProgressToJson(ReadingProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'bookId': instance.bookId,
      'currentPage': instance.currentPage,
      'progressPercentage': instance.progressPercentage,
      'lastReadAt': instance.lastReadAt.toIso8601String(),
      'totalReadingTime': instance.totalReadingTime.inMicroseconds,
      'totalWordsRead': instance.totalWordsRead,
      'status': _$ReadingStatusEnumMap[instance.status]!,
      'bookmarks': instance.bookmarks,
      'metadata': instance.metadata,
    };

QuizQuestion _$QuizQuestionFromJson(Map<String, dynamic> json) => QuizQuestion(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      type: $enumDecode(_$QuizTypeEnumMap, json['type']),
      difficulty: $enumDecode(_$QuizDifficultyEnumMap, json['difficulty']),
      question: json['question'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String?,
      points: (json['points'] as num).toInt(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      chapterNumber: (json['chapterNumber'] as num).toInt(),
      referenceText: json['referenceText'] as String?,
    );

Map<String, dynamic> _$QuizQuestionToJson(QuizQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookId': instance.bookId,
      'type': _$QuizTypeEnumMap[instance.type]!,
      'difficulty': _$QuizDifficultyEnumMap[instance.difficulty]!,
      'question': instance.question,
      'options': instance.options,
      'correctAnswer': instance.correctAnswer,
      'explanation': instance.explanation,
      'points': instance.points,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'chapterNumber': instance.chapterNumber,
      'referenceText': instance.referenceText,
    };

const _$QuizTypeEnumMap = {
  QuizType.multipleChoice: 'multipleChoice',
  QuizType.trueFalse: 'trueFalse',
  QuizType.shortAnswer: 'shortAnswer',
  QuizType.essay: 'essay',
  QuizType.comprehension: 'comprehension',
  QuizType.vocabulary: 'vocabulary',
  QuizType.sequencing: 'sequencing',
};

const _$QuizDifficultyEnumMap = {
  QuizDifficulty.easy: 'easy',
  QuizDifficulty.medium: 'medium',
  QuizDifficulty.hard: 'hard',
};

QuizSession _$QuizSessionFromJson(Map<String, dynamic> json) => QuizSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bookId: json['bookId'] as String,
      questionIds: (json['questionIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      timeSpent: Duration(microseconds: (json['timeSpent'] as num).toInt()),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      correctAnswers: (json['correctAnswers'] as num).toInt(),
      score: (json['score'] as num).toDouble(),
      isPassed: json['isPassed'] as bool,
      userAnswers: Map<String, String>.from(json['userAnswers'] as Map),
      attempts: (json['attempts'] as List<dynamic>)
          .map((e) => QuizAttempt.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuizSessionToJson(QuizSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'bookId': instance.bookId,
      'questionIds': instance.questionIds,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'timeSpent': instance.timeSpent.inMicroseconds,
      'totalQuestions': instance.totalQuestions,
      'correctAnswers': instance.correctAnswers,
      'score': instance.score,
      'isPassed': instance.isPassed,
      'userAnswers': instance.userAnswers,
      'attempts': instance.attempts,
    };

QuizAttempt _$QuizAttemptFromJson(Map<String, dynamic> json) => QuizAttempt(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      userAnswer: json['userAnswer'] as String,
      isCorrect: json['isCorrect'] as bool,
      answeredAt: DateTime.parse(json['answeredAt'] as String),
      timeSpent: Duration(microseconds: (json['timeSpent'] as num).toInt()),
      attempts: (json['attempts'] as num).toInt(),
    );

Map<String, dynamic> _$QuizAttemptToJson(QuizAttempt instance) =>
    <String, dynamic>{
      'id': instance.id,
      'questionId': instance.questionId,
      'userAnswer': instance.userAnswer,
      'isCorrect': instance.isCorrect,
      'answeredAt': instance.answeredAt.toIso8601String(),
      'timeSpent': instance.timeSpent.inMicroseconds,
      'attempts': instance.attempts,
    };

ARRecord _$ARRecordFromJson(Map<String, dynamic> json) => ARRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bookId: json['bookId'] as String,
      arPoints: (json['arPoints'] as num).toDouble(),
      arLevel: $enumDecode(_$ARLevelEnumMap, json['arLevel']),
      quizScore: (json['quizScore'] as num).toDouble(),
      completedAt: DateTime.parse(json['completedAt'] as String),
      readingTime: Duration(microseconds: (json['readingTime'] as num).toInt()),
      wordsRead: (json['wordsRead'] as num).toInt(),
      isVerified: json['isVerified'] as bool? ?? false,
      achievements: json['achievements'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ARRecordToJson(ARRecord instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'bookId': instance.bookId,
      'arPoints': instance.arPoints,
      'arLevel': _$ARLevelEnumMap[instance.arLevel]!,
      'quizScore': instance.quizScore,
      'completedAt': instance.completedAt.toIso8601String(),
      'readingTime': instance.readingTime.inMicroseconds,
      'wordsRead': instance.wordsRead,
      'isVerified': instance.isVerified,
      'achievements': instance.achievements,
    };

ReadingStats _$ReadingStatsFromJson(Map<String, dynamic> json) => ReadingStats(
      userId: json['userId'] as String,
      booksRead: (json['booksRead'] as num).toInt(),
      totalARPoints: (json['totalARPoints'] as num).toDouble(),
      currentARLevel: $enumDecode(_$ARLevelEnumMap, json['currentARLevel']),
      totalReadingTime:
          Duration(microseconds: (json['totalReadingTime'] as num).toInt()),
      totalWordsRead: (json['totalWordsRead'] as num).toInt(),
      averageQuizScore: (json['averageQuizScore'] as num).toDouble(),
      genrePreferences: (json['genrePreferences'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry($enumDecode(_$BookGenreEnumMap, k), (e as num).toInt()),
      ),
      achievements: (json['achievements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      readingStreak: (json['readingStreak'] as num).toInt(),
      monthlyProgress: json['monthlyProgress'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ReadingStatsToJson(ReadingStats instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'booksRead': instance.booksRead,
      'totalARPoints': instance.totalARPoints,
      'currentARLevel': _$ARLevelEnumMap[instance.currentARLevel]!,
      'totalReadingTime': instance.totalReadingTime.inMicroseconds,
      'totalWordsRead': instance.totalWordsRead,
      'averageQuizScore': instance.averageQuizScore,
      'genrePreferences': instance.genrePreferences
          .map((k, e) => MapEntry(_$BookGenreEnumMap[k]!, e)),
      'achievements': instance.achievements,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'readingStreak': instance.readingStreak,
      'monthlyProgress': instance.monthlyProgress,
    };
