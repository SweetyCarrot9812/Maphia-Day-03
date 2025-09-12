// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoryAdapter extends TypeAdapter<Story> {
  @override
  final int typeId = 10;

  @override
  Story read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Story(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      content: fields[3] as String,
      imageUrl: fields[4] as String,
      audioUrl: fields[5] as String?,
      level: fields[6] as StoryLevel,
      keywords: (fields[7] as List).cast<String>(),
      estimatedMinutes: fields[8] as int,
      createdAt: fields[9] as DateTime,
      isCompleted: fields[10] as bool,
      score: fields[11] as int?,
      completedAt: fields[12] as DateTime?,
      scenes: (fields[13] as List).cast<String>(),
      userId: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Story obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.audioUrl)
      ..writeByte(6)
      ..write(obj.level)
      ..writeByte(7)
      ..write(obj.keywords)
      ..writeByte(8)
      ..write(obj.estimatedMinutes)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.isCompleted)
      ..writeByte(11)
      ..write(obj.score)
      ..writeByte(12)
      ..write(obj.completedAt)
      ..writeByte(13)
      ..write(obj.scenes)
      ..writeByte(14)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StoryProgressAdapter extends TypeAdapter<StoryProgress> {
  @override
  final int typeId = 12;

  @override
  StoryProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoryProgress(
      id: fields[0] as String,
      storyId: fields[1] as String,
      userId: fields[2] as String,
      currentScene: fields[3] as int,
      isCompleted: fields[4] as bool,
      score: fields[5] as int?,
      startedAt: fields[6] as DateTime,
      completedAt: fields[7] as DateTime?,
      completedScenes: (fields[8] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, StoryProgress obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.storyId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.currentScene)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.score)
      ..writeByte(6)
      ..write(obj.startedAt)
      ..writeByte(7)
      ..write(obj.completedAt)
      ..writeByte(8)
      ..write(obj.completedScenes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StoryQuizAdapter extends TypeAdapter<StoryQuiz> {
  @override
  final int typeId = 13;

  @override
  StoryQuiz read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoryQuiz(
      id: fields[0] as String,
      storyId: fields[1] as String,
      question: fields[2] as String,
      options: (fields[3] as List).cast<String>(),
      correctAnswer: fields[4] as int,
      explanation: fields[5] as String,
      type: fields[6] as QuizType,
    );
  }

  @override
  void write(BinaryWriter writer, StoryQuiz obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.storyId)
      ..writeByte(2)
      ..write(obj.question)
      ..writeByte(3)
      ..write(obj.options)
      ..writeByte(4)
      ..write(obj.correctAnswer)
      ..writeByte(5)
      ..write(obj.explanation)
      ..writeByte(6)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryQuizAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StoryLevelAdapter extends TypeAdapter<StoryLevel> {
  @override
  final int typeId = 11;

  @override
  StoryLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StoryLevel.beginner;
      case 1:
        return StoryLevel.intermediate;
      case 2:
        return StoryLevel.advanced;
      default:
        return StoryLevel.beginner;
    }
  }

  @override
  void write(BinaryWriter writer, StoryLevel obj) {
    switch (obj) {
      case StoryLevel.beginner:
        writer.writeByte(0);
        break;
      case StoryLevel.intermediate:
        writer.writeByte(1);
        break;
      case StoryLevel.advanced:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuizTypeAdapter extends TypeAdapter<QuizType> {
  @override
  final int typeId = 14;

  @override
  QuizType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuizType.multipleChoice;
      case 1:
        return QuizType.trueFalse;
      case 2:
        return QuizType.shortAnswer;
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
