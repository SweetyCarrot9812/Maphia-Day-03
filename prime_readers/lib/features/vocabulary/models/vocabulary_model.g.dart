// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VocabularyWordAdapter extends TypeAdapter<VocabularyWord> {
  @override
  final int typeId = 2;

  @override
  VocabularyWord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VocabularyWord(
      id: fields[0] as String,
      word: fields[1] as String,
      meaning: fields[2] as String,
      pronunciation: fields[3] as String?,
      example: fields[4] as String?,
      exampleTranslation: fields[5] as String?,
      difficulty: fields[6] as DifficultyLevel,
      category: fields[7] as String,
      tags: (fields[8] as List).cast<String>(),
      createdAt: fields[9] as DateTime,
      lastReviewed: fields[10] as DateTime?,
      reviewCount: fields[11] as int,
      correctCount: fields[12] as int,
      easeFactor: fields[13] as double,
      interval: fields[14] as int,
      nextReview: fields[15] as DateTime?,
      status: fields[16] as LearningStatus,
      imageUrl: fields[17] as String?,
      audioUrl: fields[18] as String?,
      userId: fields[19] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VocabularyWord obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.word)
      ..writeByte(2)
      ..write(obj.meaning)
      ..writeByte(3)
      ..write(obj.pronunciation)
      ..writeByte(4)
      ..write(obj.example)
      ..writeByte(5)
      ..write(obj.exampleTranslation)
      ..writeByte(6)
      ..write(obj.difficulty)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.tags)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.lastReviewed)
      ..writeByte(11)
      ..write(obj.reviewCount)
      ..writeByte(12)
      ..write(obj.correctCount)
      ..writeByte(13)
      ..write(obj.easeFactor)
      ..writeByte(14)
      ..write(obj.interval)
      ..writeByte(15)
      ..write(obj.nextReview)
      ..writeByte(16)
      ..write(obj.status)
      ..writeByte(17)
      ..write(obj.imageUrl)
      ..writeByte(18)
      ..write(obj.audioUrl)
      ..writeByte(19)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabularyWordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DifficultyLevelAdapter extends TypeAdapter<DifficultyLevel> {
  @override
  final int typeId = 3;

  @override
  DifficultyLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DifficultyLevel.beginner;
      case 1:
        return DifficultyLevel.intermediate;
      case 2:
        return DifficultyLevel.advanced;
      default:
        return DifficultyLevel.beginner;
    }
  }

  @override
  void write(BinaryWriter writer, DifficultyLevel obj) {
    switch (obj) {
      case DifficultyLevel.beginner:
        writer.writeByte(0);
        break;
      case DifficultyLevel.intermediate:
        writer.writeByte(1);
        break;
      case DifficultyLevel.advanced:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DifficultyLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LearningStatusAdapter extends TypeAdapter<LearningStatus> {
  @override
  final int typeId = 4;

  @override
  LearningStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LearningStatus.newWord;
      case 1:
        return LearningStatus.learning;
      case 2:
        return LearningStatus.review;
      case 3:
        return LearningStatus.mastered;
      default:
        return LearningStatus.newWord;
    }
  }

  @override
  void write(BinaryWriter writer, LearningStatus obj) {
    switch (obj) {
      case LearningStatus.newWord:
        writer.writeByte(0);
        break;
      case LearningStatus.learning:
        writer.writeByte(1);
        break;
      case LearningStatus.review:
        writer.writeByte(2);
        break;
      case LearningStatus.mastered:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReviewResultAdapter extends TypeAdapter<ReviewResult> {
  @override
  final int typeId = 5;

  @override
  ReviewResult read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReviewResult.perfect;
      case 1:
        return ReviewResult.correct;
      case 2:
        return ReviewResult.hard;
      case 3:
        return ReviewResult.wrong;
      default:
        return ReviewResult.perfect;
    }
  }

  @override
  void write(BinaryWriter writer, ReviewResult obj) {
    switch (obj) {
      case ReviewResult.perfect:
        writer.writeByte(0);
        break;
      case ReviewResult.correct:
        writer.writeByte(1);
        break;
      case ReviewResult.hard:
        writer.writeByte(2);
        break;
      case ReviewResult.wrong:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
