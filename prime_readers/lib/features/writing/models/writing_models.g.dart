// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'writing_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WritingTaskAdapter extends TypeAdapter<WritingTask> {
  @override
  final int typeId = 20;

  @override
  WritingTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WritingTask(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      prompt: fields[3] as String,
      type: fields[4] as WritingTaskType,
      difficulty: fields[5] as DifficultyLevel,
      maxWords: fields[6] as int,
      minWords: fields[7] as int,
      timeLimit: fields[8] as Duration,
      keyPoints: (fields[9] as List).cast<String>(),
      vocabularyHints: (fields[10] as List).cast<String>(),
      createdAt: fields[11] as DateTime,
      imageUrl: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WritingTask obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.prompt)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.difficulty)
      ..writeByte(6)
      ..write(obj.maxWords)
      ..writeByte(7)
      ..write(obj.minWords)
      ..writeByte(8)
      ..write(obj.timeLimit)
      ..writeByte(9)
      ..write(obj.keyPoints)
      ..writeByte(10)
      ..write(obj.vocabularyHints)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WritingSubmissionAdapter extends TypeAdapter<WritingSubmission> {
  @override
  final int typeId = 21;

  @override
  WritingSubmission read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WritingSubmission(
      id: fields[0] as String,
      taskId: fields[1] as String,
      userId: fields[2] as String,
      content: fields[3] as String,
      inputMethod: fields[4] as WritingInputMethod,
      submittedAt: fields[5] as DateTime,
      wordCount: fields[6] as int,
      timeSpent: fields[7] as Duration,
      status: fields[12] as WritingStatus,
      handwritingImageUrl: fields[8] as String?,
      ocrText: fields[9] as String?,
      ocrConfidence: fields[10] as double?,
      evaluation: fields[11] as WritingEvaluation?,
    );
  }

  @override
  void write(BinaryWriter writer, WritingSubmission obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.inputMethod)
      ..writeByte(5)
      ..write(obj.submittedAt)
      ..writeByte(6)
      ..write(obj.wordCount)
      ..writeByte(7)
      ..write(obj.timeSpent)
      ..writeByte(8)
      ..write(obj.handwritingImageUrl)
      ..writeByte(9)
      ..write(obj.ocrText)
      ..writeByte(10)
      ..write(obj.ocrConfidence)
      ..writeByte(11)
      ..write(obj.evaluation)
      ..writeByte(12)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingSubmissionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WritingEvaluationAdapter extends TypeAdapter<WritingEvaluation> {
  @override
  final int typeId = 22;

  @override
  WritingEvaluation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WritingEvaluation(
      id: fields[0] as String,
      submissionId: fields[1] as String,
      overallScore: fields[2] as double,
      grammarScore: fields[3] as double,
      vocabularyScore: fields[4] as double,
      contentScore: fields[5] as double,
      structureScore: fields[6] as double,
      creativityScore: fields[7] as double,
      errors: (fields[8] as List).cast<WritingError>(),
      suggestions: (fields[9] as List).cast<WritingSuggestion>(),
      feedback: fields[10] as String,
      evaluatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WritingEvaluation obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.submissionId)
      ..writeByte(2)
      ..write(obj.overallScore)
      ..writeByte(3)
      ..write(obj.grammarScore)
      ..writeByte(4)
      ..write(obj.vocabularyScore)
      ..writeByte(5)
      ..write(obj.contentScore)
      ..writeByte(6)
      ..write(obj.structureScore)
      ..writeByte(7)
      ..write(obj.creativityScore)
      ..writeByte(8)
      ..write(obj.errors)
      ..writeByte(9)
      ..write(obj.suggestions)
      ..writeByte(10)
      ..write(obj.feedback)
      ..writeByte(11)
      ..write(obj.evaluatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingEvaluationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WritingErrorAdapter extends TypeAdapter<WritingError> {
  @override
  final int typeId = 23;

  @override
  WritingError read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WritingError(
      id: fields[0] as String,
      type: fields[1] as WritingErrorType,
      originalText: fields[2] as String,
      correctedText: fields[3] as String?,
      startPosition: fields[4] as int,
      endPosition: fields[5] as int,
      description: fields[6] as String,
      rule: fields[7] as String,
      confidence: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, WritingError obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.originalText)
      ..writeByte(3)
      ..write(obj.correctedText)
      ..writeByte(4)
      ..write(obj.startPosition)
      ..writeByte(5)
      ..write(obj.endPosition)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.rule)
      ..writeByte(8)
      ..write(obj.confidence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingErrorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WritingSuggestionAdapter extends TypeAdapter<WritingSuggestion> {
  @override
  final int typeId = 24;

  @override
  WritingSuggestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WritingSuggestion(
      id: fields[0] as String,
      type: fields[1] as WritingSuggestionType,
      title: fields[2] as String,
      description: fields[3] as String,
      example: fields[4] as String?,
      improvement: fields[5] as String?,
      priority: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, WritingSuggestion obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.example)
      ..writeByte(5)
      ..write(obj.improvement)
      ..writeByte(6)
      ..write(obj.priority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingSuggestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WritingSessionAdapter extends TypeAdapter<WritingSession> {
  @override
  final int typeId = 25;

  @override
  WritingSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WritingSession(
      id: fields[0] as String,
      userId: fields[1] as String,
      taskId: fields[2] as String,
      startedAt: fields[3] as DateTime,
      endedAt: fields[4] as DateTime?,
      duration: fields[5] as Duration,
      currentContent: fields[6] as String,
      currentWordCount: fields[7] as int,
      actions: (fields[8] as List).cast<WritingAction>(),
      status: fields[9] as WritingSessionStatus,
      submissionId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WritingSession obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.taskId)
      ..writeByte(3)
      ..write(obj.startedAt)
      ..writeByte(4)
      ..write(obj.endedAt)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.currentContent)
      ..writeByte(7)
      ..write(obj.currentWordCount)
      ..writeByte(8)
      ..write(obj.actions)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.submissionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WritingActionAdapter extends TypeAdapter<WritingAction> {
  @override
  final int typeId = 26;

  @override
  WritingAction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WritingAction(
      id: fields[0] as String,
      type: fields[1] as WritingActionType,
      timestamp: fields[2] as DateTime,
      content: fields[3] as String?,
      position: fields[4] as int?,
      metadata: (fields[5] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, WritingAction obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.position)
      ..writeByte(5)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingActionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WritingTaskTypeAdapter extends TypeAdapter<WritingTaskType> {
  @override
  final int typeId = 27;

  @override
  WritingTaskType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WritingTaskType.essay;
      case 1:
        return WritingTaskType.creative;
      case 2:
        return WritingTaskType.descriptive;
      case 3:
        return WritingTaskType.argumentative;
      case 4:
        return WritingTaskType.summary;
      case 5:
        return WritingTaskType.review;
      case 6:
        return WritingTaskType.letter;
      case 7:
        return WritingTaskType.story;
      case 8:
        return WritingTaskType.diary;
      case 9:
        return WritingTaskType.report;
      case 10:
        return WritingTaskType.description;
      case 11:
        return WritingTaskType.opinion;
      case 12:
        return WritingTaskType.instruction;
      default:
        return WritingTaskType.essay;
    }
  }

  @override
  void write(BinaryWriter writer, WritingTaskType obj) {
    switch (obj) {
      case WritingTaskType.essay:
        writer.writeByte(0);
        break;
      case WritingTaskType.creative:
        writer.writeByte(1);
        break;
      case WritingTaskType.descriptive:
        writer.writeByte(2);
        break;
      case WritingTaskType.argumentative:
        writer.writeByte(3);
        break;
      case WritingTaskType.summary:
        writer.writeByte(4);
        break;
      case WritingTaskType.review:
        writer.writeByte(5);
        break;
      case WritingTaskType.letter:
        writer.writeByte(6);
        break;
      case WritingTaskType.story:
        writer.writeByte(7);
        break;
      case WritingTaskType.diary:
        writer.writeByte(8);
        break;
      case WritingTaskType.report:
        writer.writeByte(9);
        break;
      case WritingTaskType.description:
        writer.writeByte(10);
        break;
      case WritingTaskType.opinion:
        writer.writeByte(11);
        break;
      case WritingTaskType.instruction:
        writer.writeByte(12);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingTaskTypeAdapter &&
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

class WritingInputMethodAdapter extends TypeAdapter<WritingInputMethod> {
  @override
  final int typeId = 28;

  @override
  WritingInputMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WritingInputMethod.typing;
      case 1:
        return WritingInputMethod.handwriting;
      case 2:
        return WritingInputMethod.mixed;
      default:
        return WritingInputMethod.typing;
    }
  }

  @override
  void write(BinaryWriter writer, WritingInputMethod obj) {
    switch (obj) {
      case WritingInputMethod.typing:
        writer.writeByte(0);
        break;
      case WritingInputMethod.handwriting:
        writer.writeByte(1);
        break;
      case WritingInputMethod.mixed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingInputMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WritingSessionStatusAdapter extends TypeAdapter<WritingSessionStatus> {
  @override
  final int typeId = 29;

  @override
  WritingSessionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WritingSessionStatus.active;
      case 1:
        return WritingSessionStatus.paused;
      case 2:
        return WritingSessionStatus.completed;
      case 3:
        return WritingSessionStatus.abandoned;
      default:
        return WritingSessionStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, WritingSessionStatus obj) {
    switch (obj) {
      case WritingSessionStatus.active:
        writer.writeByte(0);
        break;
      case WritingSessionStatus.paused:
        writer.writeByte(1);
        break;
      case WritingSessionStatus.completed:
        writer.writeByte(2);
        break;
      case WritingSessionStatus.abandoned:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingSessionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WritingActionTypeAdapter extends TypeAdapter<WritingActionType> {
  @override
  final int typeId = 30;

  @override
  WritingActionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WritingActionType.typed;
      case 1:
        return WritingActionType.deleted;
      case 2:
        return WritingActionType.pasted;
      case 3:
        return WritingActionType.corrected;
      case 4:
        return WritingActionType.submitted;
      case 5:
        return WritingActionType.paused;
      case 6:
        return WritingActionType.resumed;
      case 7:
        return WritingActionType.saved;
      default:
        return WritingActionType.typed;
    }
  }

  @override
  void write(BinaryWriter writer, WritingActionType obj) {
    switch (obj) {
      case WritingActionType.typed:
        writer.writeByte(0);
        break;
      case WritingActionType.deleted:
        writer.writeByte(1);
        break;
      case WritingActionType.pasted:
        writer.writeByte(2);
        break;
      case WritingActionType.corrected:
        writer.writeByte(3);
        break;
      case WritingActionType.submitted:
        writer.writeByte(4);
        break;
      case WritingActionType.paused:
        writer.writeByte(5);
        break;
      case WritingActionType.resumed:
        writer.writeByte(6);
        break;
      case WritingActionType.saved:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingActionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WritingErrorTypeAdapter extends TypeAdapter<WritingErrorType> {
  @override
  final int typeId = 31;

  @override
  WritingErrorType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WritingErrorType.grammar;
      case 1:
        return WritingErrorType.spelling;
      case 2:
        return WritingErrorType.punctuation;
      case 3:
        return WritingErrorType.vocabulary;
      case 4:
        return WritingErrorType.structure;
      case 5:
        return WritingErrorType.style;
      default:
        return WritingErrorType.grammar;
    }
  }

  @override
  void write(BinaryWriter writer, WritingErrorType obj) {
    switch (obj) {
      case WritingErrorType.grammar:
        writer.writeByte(0);
        break;
      case WritingErrorType.spelling:
        writer.writeByte(1);
        break;
      case WritingErrorType.punctuation:
        writer.writeByte(2);
        break;
      case WritingErrorType.vocabulary:
        writer.writeByte(3);
        break;
      case WritingErrorType.structure:
        writer.writeByte(4);
        break;
      case WritingErrorType.style:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingErrorTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WritingSuggestionTypeAdapter extends TypeAdapter<WritingSuggestionType> {
  @override
  final int typeId = 32;

  @override
  WritingSuggestionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WritingSuggestionType.grammar;
      case 1:
        return WritingSuggestionType.vocabulary;
      case 2:
        return WritingSuggestionType.style;
      case 3:
        return WritingSuggestionType.structure;
      case 4:
        return WritingSuggestionType.content;
      default:
        return WritingSuggestionType.grammar;
    }
  }

  @override
  void write(BinaryWriter writer, WritingSuggestionType obj) {
    switch (obj) {
      case WritingSuggestionType.grammar:
        writer.writeByte(0);
        break;
      case WritingSuggestionType.vocabulary:
        writer.writeByte(1);
        break;
      case WritingSuggestionType.style:
        writer.writeByte(2);
        break;
      case WritingSuggestionType.structure:
        writer.writeByte(3);
        break;
      case WritingSuggestionType.content:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingSuggestionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WritingStatusAdapter extends TypeAdapter<WritingStatus> {
  @override
  final int typeId = 34;

  @override
  WritingStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WritingStatus.draft;
      case 1:
        return WritingStatus.submitted;
      case 2:
        return WritingStatus.evaluating;
      case 3:
        return WritingStatus.evaluated;
      case 4:
        return WritingStatus.revised;
      case 5:
        return WritingStatus.completed;
      default:
        return WritingStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, WritingStatus obj) {
    switch (obj) {
      case WritingStatus.draft:
        writer.writeByte(0);
        break;
      case WritingStatus.submitted:
        writer.writeByte(1);
        break;
      case WritingStatus.evaluating:
        writer.writeByte(2);
        break;
      case WritingStatus.evaluated:
        writer.writeByte(3);
        break;
      case WritingStatus.revised:
        writer.writeByte(4);
        break;
      case WritingStatus.completed:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WritingTask _$WritingTaskFromJson(Map<String, dynamic> json) => WritingTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      prompt: json['prompt'] as String,
      type: $enumDecode(_$WritingTaskTypeEnumMap, json['type']),
      difficulty: $enumDecode(_$DifficultyLevelEnumMap, json['difficulty']),
      maxWords: (json['maxWords'] as num).toInt(),
      minWords: (json['minWords'] as num).toInt(),
      timeLimit: Duration(microseconds: (json['timeLimit'] as num).toInt()),
      keyPoints:
          (json['keyPoints'] as List<dynamic>).map((e) => e as String).toList(),
      vocabularyHints: (json['vocabularyHints'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$WritingTaskToJson(WritingTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'prompt': instance.prompt,
      'type': _$WritingTaskTypeEnumMap[instance.type]!,
      'difficulty': _$DifficultyLevelEnumMap[instance.difficulty]!,
      'maxWords': instance.maxWords,
      'minWords': instance.minWords,
      'timeLimit': instance.timeLimit.inMicroseconds,
      'keyPoints': instance.keyPoints,
      'vocabularyHints': instance.vocabularyHints,
      'createdAt': instance.createdAt.toIso8601String(),
      'imageUrl': instance.imageUrl,
    };

const _$WritingTaskTypeEnumMap = {
  WritingTaskType.essay: 'essay',
  WritingTaskType.creative: 'creative',
  WritingTaskType.descriptive: 'descriptive',
  WritingTaskType.argumentative: 'argumentative',
  WritingTaskType.summary: 'summary',
  WritingTaskType.review: 'review',
  WritingTaskType.letter: 'letter',
  WritingTaskType.story: 'story',
  WritingTaskType.diary: 'diary',
  WritingTaskType.report: 'report',
  WritingTaskType.description: 'description',
  WritingTaskType.opinion: 'opinion',
  WritingTaskType.instruction: 'instruction',
};

const _$DifficultyLevelEnumMap = {
  DifficultyLevel.beginner: 'beginner',
  DifficultyLevel.intermediate: 'intermediate',
  DifficultyLevel.advanced: 'advanced',
};

WritingSubmission _$WritingSubmissionFromJson(Map<String, dynamic> json) =>
    WritingSubmission(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      inputMethod:
          $enumDecode(_$WritingInputMethodEnumMap, json['inputMethod']),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      wordCount: (json['wordCount'] as num).toInt(),
      timeSpent: Duration(microseconds: (json['timeSpent'] as num).toInt()),
      status: $enumDecode(_$WritingStatusEnumMap, json['status']),
      handwritingImageUrl: json['handwritingImageUrl'] as String?,
      ocrText: json['ocrText'] as String?,
      ocrConfidence: (json['ocrConfidence'] as num?)?.toDouble(),
      evaluation: json['evaluation'] == null
          ? null
          : WritingEvaluation.fromJson(
              json['evaluation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WritingSubmissionToJson(WritingSubmission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'userId': instance.userId,
      'content': instance.content,
      'inputMethod': _$WritingInputMethodEnumMap[instance.inputMethod]!,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'wordCount': instance.wordCount,
      'timeSpent': instance.timeSpent.inMicroseconds,
      'handwritingImageUrl': instance.handwritingImageUrl,
      'ocrText': instance.ocrText,
      'ocrConfidence': instance.ocrConfidence,
      'evaluation': instance.evaluation,
      'status': _$WritingStatusEnumMap[instance.status]!,
    };

const _$WritingInputMethodEnumMap = {
  WritingInputMethod.typing: 'typing',
  WritingInputMethod.handwriting: 'handwriting',
  WritingInputMethod.mixed: 'mixed',
};

const _$WritingStatusEnumMap = {
  WritingStatus.draft: 'draft',
  WritingStatus.submitted: 'submitted',
  WritingStatus.evaluating: 'evaluating',
  WritingStatus.evaluated: 'evaluated',
  WritingStatus.revised: 'revised',
  WritingStatus.completed: 'completed',
};

WritingEvaluation _$WritingEvaluationFromJson(Map<String, dynamic> json) =>
    WritingEvaluation(
      id: json['id'] as String,
      submissionId: json['submissionId'] as String,
      overallScore: (json['overallScore'] as num).toDouble(),
      grammarScore: (json['grammarScore'] as num).toDouble(),
      vocabularyScore: (json['vocabularyScore'] as num).toDouble(),
      contentScore: (json['contentScore'] as num).toDouble(),
      structureScore: (json['structureScore'] as num).toDouble(),
      creativityScore: (json['creativityScore'] as num).toDouble(),
      errors: (json['errors'] as List<dynamic>)
          .map((e) => WritingError.fromJson(e as Map<String, dynamic>))
          .toList(),
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => WritingSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      feedback: json['feedback'] as String,
      evaluatedAt: DateTime.parse(json['evaluatedAt'] as String),
    );

Map<String, dynamic> _$WritingEvaluationToJson(WritingEvaluation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'submissionId': instance.submissionId,
      'overallScore': instance.overallScore,
      'grammarScore': instance.grammarScore,
      'vocabularyScore': instance.vocabularyScore,
      'contentScore': instance.contentScore,
      'structureScore': instance.structureScore,
      'creativityScore': instance.creativityScore,
      'errors': instance.errors,
      'suggestions': instance.suggestions,
      'feedback': instance.feedback,
      'evaluatedAt': instance.evaluatedAt.toIso8601String(),
    };

WritingError _$WritingErrorFromJson(Map<String, dynamic> json) => WritingError(
      id: json['id'] as String,
      type: $enumDecode(_$WritingErrorTypeEnumMap, json['type']),
      originalText: json['originalText'] as String,
      correctedText: json['correctedText'] as String?,
      startPosition: (json['startPosition'] as num).toInt(),
      endPosition: (json['endPosition'] as num).toInt(),
      description: json['description'] as String,
      rule: json['rule'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$WritingErrorToJson(WritingError instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$WritingErrorTypeEnumMap[instance.type]!,
      'originalText': instance.originalText,
      'correctedText': instance.correctedText,
      'startPosition': instance.startPosition,
      'endPosition': instance.endPosition,
      'description': instance.description,
      'rule': instance.rule,
      'confidence': instance.confidence,
    };

const _$WritingErrorTypeEnumMap = {
  WritingErrorType.grammar: 'grammar',
  WritingErrorType.spelling: 'spelling',
  WritingErrorType.punctuation: 'punctuation',
  WritingErrorType.vocabulary: 'vocabulary',
  WritingErrorType.structure: 'structure',
  WritingErrorType.style: 'style',
};

WritingSuggestion _$WritingSuggestionFromJson(Map<String, dynamic> json) =>
    WritingSuggestion(
      id: json['id'] as String,
      type: $enumDecode(_$WritingSuggestionTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      example: json['example'] as String?,
      improvement: json['improvement'] as String?,
      priority: (json['priority'] as num).toDouble(),
    );

Map<String, dynamic> _$WritingSuggestionToJson(WritingSuggestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$WritingSuggestionTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'example': instance.example,
      'improvement': instance.improvement,
      'priority': instance.priority,
    };

const _$WritingSuggestionTypeEnumMap = {
  WritingSuggestionType.grammar: 'grammar',
  WritingSuggestionType.vocabulary: 'vocabulary',
  WritingSuggestionType.style: 'style',
  WritingSuggestionType.structure: 'structure',
  WritingSuggestionType.content: 'content',
};

WritingSession _$WritingSessionFromJson(Map<String, dynamic> json) =>
    WritingSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      taskId: json['taskId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      currentContent: json['currentContent'] as String,
      currentWordCount: (json['currentWordCount'] as num).toInt(),
      actions: (json['actions'] as List<dynamic>)
          .map((e) => WritingAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: $enumDecode(_$WritingSessionStatusEnumMap, json['status']),
      submissionId: json['submissionId'] as String?,
    );

Map<String, dynamic> _$WritingSessionToJson(WritingSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'taskId': instance.taskId,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
      'currentContent': instance.currentContent,
      'currentWordCount': instance.currentWordCount,
      'actions': instance.actions,
      'status': _$WritingSessionStatusEnumMap[instance.status]!,
      'submissionId': instance.submissionId,
    };

const _$WritingSessionStatusEnumMap = {
  WritingSessionStatus.active: 'active',
  WritingSessionStatus.paused: 'paused',
  WritingSessionStatus.completed: 'completed',
  WritingSessionStatus.abandoned: 'abandoned',
};

WritingAction _$WritingActionFromJson(Map<String, dynamic> json) =>
    WritingAction(
      id: json['id'] as String,
      type: $enumDecode(_$WritingActionTypeEnumMap, json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      content: json['content'] as String?,
      position: (json['position'] as num?)?.toInt(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$WritingActionToJson(WritingAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$WritingActionTypeEnumMap[instance.type]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'content': instance.content,
      'position': instance.position,
      'metadata': instance.metadata,
    };

const _$WritingActionTypeEnumMap = {
  WritingActionType.typed: 'typed',
  WritingActionType.deleted: 'deleted',
  WritingActionType.pasted: 'pasted',
  WritingActionType.corrected: 'corrected',
  WritingActionType.submitted: 'submitted',
  WritingActionType.paused: 'paused',
  WritingActionType.resumed: 'resumed',
  WritingActionType.saved: 'saved',
};
