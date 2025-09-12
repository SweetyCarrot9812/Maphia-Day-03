// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speaking_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpeakingLessonAdapter extends TypeAdapter<SpeakingLesson> {
  @override
  final int typeId = 10;

  @override
  SpeakingLesson read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpeakingLesson(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      level: fields[3] as SpeakingLevel,
      exercises: (fields[4] as List).cast<SpeakingExercise>(),
      estimatedMinutes: fields[5] as int,
      thumbnailUrl: fields[6] as String?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      isCompleted: fields[9] as bool,
      averageScore: fields[10] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, SpeakingLesson obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.exercises)
      ..writeByte(5)
      ..write(obj.estimatedMinutes)
      ..writeByte(6)
      ..write(obj.thumbnailUrl)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.isCompleted)
      ..writeByte(10)
      ..write(obj.averageScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeakingLessonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SpeakingExerciseAdapter extends TypeAdapter<SpeakingExercise> {
  @override
  final int typeId = 11;

  @override
  SpeakingExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpeakingExercise(
      id: fields[0] as String,
      text: fields[1] as String,
      phoneticTranscription: fields[2] as String,
      audioUrl: fields[3] as String,
      order: fields[4] as int,
      hint: fields[5] as String?,
      keyWords: (fields[6] as List).cast<String>(),
      targetScore: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SpeakingExercise obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.phoneticTranscription)
      ..writeByte(3)
      ..write(obj.audioUrl)
      ..writeByte(4)
      ..write(obj.order)
      ..writeByte(5)
      ..write(obj.hint)
      ..writeByte(6)
      ..write(obj.keyWords)
      ..writeByte(7)
      ..write(obj.targetScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeakingExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SpeakingSessionAdapter extends TypeAdapter<SpeakingSession> {
  @override
  final int typeId = 12;

  @override
  SpeakingSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpeakingSession(
      id: fields[0] as String,
      userId: fields[1] as String,
      lessonId: fields[2] as String,
      startTime: fields[3] as DateTime,
      endTime: fields[4] as DateTime?,
      attempts: (fields[5] as List).cast<SpeakingAttempt>(),
      overallScore: fields[6] as double?,
      isCompleted: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SpeakingSession obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.lessonId)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.attempts)
      ..writeByte(6)
      ..write(obj.overallScore)
      ..writeByte(7)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeakingSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SpeakingAttemptAdapter extends TypeAdapter<SpeakingAttempt> {
  @override
  final int typeId = 13;

  @override
  SpeakingAttempt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpeakingAttempt(
      id: fields[0] as String,
      exerciseId: fields[1] as String,
      recordingPath: fields[2] as String,
      recordedAt: fields[3] as DateTime,
      recordingDuration: fields[4] as Duration,
      evaluation: fields[5] as SpeakingEvaluation?,
      attemptNumber: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SpeakingAttempt obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exerciseId)
      ..writeByte(2)
      ..write(obj.recordingPath)
      ..writeByte(3)
      ..write(obj.recordedAt)
      ..writeByte(4)
      ..write(obj.recordingDuration)
      ..writeByte(5)
      ..write(obj.evaluation)
      ..writeByte(6)
      ..write(obj.attemptNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeakingAttemptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SpeakingEvaluationAdapter extends TypeAdapter<SpeakingEvaluation> {
  @override
  final int typeId = 14;

  @override
  SpeakingEvaluation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpeakingEvaluation(
      overallScore: fields[0] as double,
      pronunciationScore: fields[1] as double,
      fluencyScore: fields[2] as double,
      accuracyScore: fields[3] as double,
      transcribedText: fields[4] as String,
      feedback: (fields[5] as List).cast<PronunciationFeedback>(),
      evaluatedAt: fields[6] as DateTime,
      aiModel: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SpeakingEvaluation obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.overallScore)
      ..writeByte(1)
      ..write(obj.pronunciationScore)
      ..writeByte(2)
      ..write(obj.fluencyScore)
      ..writeByte(3)
      ..write(obj.accuracyScore)
      ..writeByte(4)
      ..write(obj.transcribedText)
      ..writeByte(5)
      ..write(obj.feedback)
      ..writeByte(6)
      ..write(obj.evaluatedAt)
      ..writeByte(7)
      ..write(obj.aiModel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeakingEvaluationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PronunciationFeedbackAdapter extends TypeAdapter<PronunciationFeedback> {
  @override
  final int typeId = 15;

  @override
  PronunciationFeedback read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PronunciationFeedback(
      word: fields[0] as String,
      score: fields[1] as double,
      suggestion: fields[2] as String,
      phoneticCorrection: fields[3] as String,
      isCorrect: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PronunciationFeedback obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.word)
      ..writeByte(1)
      ..write(obj.score)
      ..writeByte(2)
      ..write(obj.suggestion)
      ..writeByte(3)
      ..write(obj.phoneticCorrection)
      ..writeByte(4)
      ..write(obj.isCorrect);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PronunciationFeedbackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SpeakingStatsAdapter extends TypeAdapter<SpeakingStats> {
  @override
  final int typeId = 16;

  @override
  SpeakingStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpeakingStats(
      totalLessons: fields[0] as int,
      completedLessons: fields[1] as int,
      totalAttempts: fields[2] as int,
      averageScore: fields[3] as double,
      totalPracticeTime: fields[4] as Duration,
      lastPracticeDate: fields[5] as DateTime,
      lessonsByLevel: (fields[6] as Map).cast<SpeakingLevel, int>(),
      recentScores: (fields[7] as List).cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, SpeakingStats obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.totalLessons)
      ..writeByte(1)
      ..write(obj.completedLessons)
      ..writeByte(2)
      ..write(obj.totalAttempts)
      ..writeByte(3)
      ..write(obj.averageScore)
      ..writeByte(4)
      ..write(obj.totalPracticeTime)
      ..writeByte(5)
      ..write(obj.lastPracticeDate)
      ..writeByte(6)
      ..write(obj.lessonsByLevel)
      ..writeByte(7)
      ..write(obj.recentScores);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeakingStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpeakingLesson _$SpeakingLessonFromJson(Map<String, dynamic> json) =>
    SpeakingLesson(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      level: $enumDecode(_$SpeakingLevelEnumMap, json['level']),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => SpeakingExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      estimatedMinutes: (json['estimatedMinutes'] as num).toInt(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      averageScore: (json['averageScore'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SpeakingLessonToJson(SpeakingLesson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'level': _$SpeakingLevelEnumMap[instance.level]!,
      'exercises': instance.exercises,
      'estimatedMinutes': instance.estimatedMinutes,
      'thumbnailUrl': instance.thumbnailUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'averageScore': instance.averageScore,
    };

const _$SpeakingLevelEnumMap = {
  SpeakingLevel.beginner: 'beginner',
  SpeakingLevel.intermediate: 'intermediate',
  SpeakingLevel.advanced: 'advanced',
};

SpeakingExercise _$SpeakingExerciseFromJson(Map<String, dynamic> json) =>
    SpeakingExercise(
      id: json['id'] as String,
      text: json['text'] as String,
      phoneticTranscription: json['phoneticTranscription'] as String,
      audioUrl: json['audioUrl'] as String,
      order: (json['order'] as num).toInt(),
      hint: json['hint'] as String?,
      keyWords:
          (json['keyWords'] as List<dynamic>).map((e) => e as String).toList(),
      targetScore: (json['targetScore'] as num?)?.toDouble() ?? 80.0,
    );

Map<String, dynamic> _$SpeakingExerciseToJson(SpeakingExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'phoneticTranscription': instance.phoneticTranscription,
      'audioUrl': instance.audioUrl,
      'order': instance.order,
      'hint': instance.hint,
      'keyWords': instance.keyWords,
      'targetScore': instance.targetScore,
    };

SpeakingSession _$SpeakingSessionFromJson(Map<String, dynamic> json) =>
    SpeakingSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      lessonId: json['lessonId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      attempts: (json['attempts'] as List<dynamic>)
          .map((e) => SpeakingAttempt.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallScore: (json['overallScore'] as num?)?.toDouble(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$SpeakingSessionToJson(SpeakingSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'lessonId': instance.lessonId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'attempts': instance.attempts,
      'overallScore': instance.overallScore,
      'isCompleted': instance.isCompleted,
    };

SpeakingAttempt _$SpeakingAttemptFromJson(Map<String, dynamic> json) =>
    SpeakingAttempt(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      recordingPath: json['recordingPath'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      recordingDuration:
          Duration(microseconds: (json['recordingDuration'] as num).toInt()),
      evaluation: json['evaluation'] == null
          ? null
          : SpeakingEvaluation.fromJson(
              json['evaluation'] as Map<String, dynamic>),
      attemptNumber: (json['attemptNumber'] as num).toInt(),
    );

Map<String, dynamic> _$SpeakingAttemptToJson(SpeakingAttempt instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'recordingPath': instance.recordingPath,
      'recordedAt': instance.recordedAt.toIso8601String(),
      'recordingDuration': instance.recordingDuration.inMicroseconds,
      'evaluation': instance.evaluation,
      'attemptNumber': instance.attemptNumber,
    };

SpeakingEvaluation _$SpeakingEvaluationFromJson(Map<String, dynamic> json) =>
    SpeakingEvaluation(
      overallScore: (json['overallScore'] as num).toDouble(),
      pronunciationScore: (json['pronunciationScore'] as num).toDouble(),
      fluencyScore: (json['fluencyScore'] as num).toDouble(),
      accuracyScore: (json['accuracyScore'] as num).toDouble(),
      transcribedText: json['transcribedText'] as String,
      feedback: (json['feedback'] as List<dynamic>)
          .map((e) => PronunciationFeedback.fromJson(e as Map<String, dynamic>))
          .toList(),
      evaluatedAt: DateTime.parse(json['evaluatedAt'] as String),
      aiModel: json['aiModel'] as String,
    );

Map<String, dynamic> _$SpeakingEvaluationToJson(SpeakingEvaluation instance) =>
    <String, dynamic>{
      'overallScore': instance.overallScore,
      'pronunciationScore': instance.pronunciationScore,
      'fluencyScore': instance.fluencyScore,
      'accuracyScore': instance.accuracyScore,
      'transcribedText': instance.transcribedText,
      'feedback': instance.feedback,
      'evaluatedAt': instance.evaluatedAt.toIso8601String(),
      'aiModel': instance.aiModel,
    };

PronunciationFeedback _$PronunciationFeedbackFromJson(
        Map<String, dynamic> json) =>
    PronunciationFeedback(
      word: json['word'] as String,
      score: (json['score'] as num).toDouble(),
      suggestion: json['suggestion'] as String,
      phoneticCorrection: json['phoneticCorrection'] as String,
      isCorrect: json['isCorrect'] as bool,
    );

Map<String, dynamic> _$PronunciationFeedbackToJson(
        PronunciationFeedback instance) =>
    <String, dynamic>{
      'word': instance.word,
      'score': instance.score,
      'suggestion': instance.suggestion,
      'phoneticCorrection': instance.phoneticCorrection,
      'isCorrect': instance.isCorrect,
    };

SpeakingStats _$SpeakingStatsFromJson(Map<String, dynamic> json) =>
    SpeakingStats(
      totalLessons: (json['totalLessons'] as num).toInt(),
      completedLessons: (json['completedLessons'] as num).toInt(),
      totalAttempts: (json['totalAttempts'] as num).toInt(),
      averageScore: (json['averageScore'] as num).toDouble(),
      totalPracticeTime:
          Duration(microseconds: (json['totalPracticeTime'] as num).toInt()),
      lastPracticeDate: DateTime.parse(json['lastPracticeDate'] as String),
      lessonsByLevel: (json['lessonsByLevel'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$SpeakingLevelEnumMap, k), (e as num).toInt()),
      ),
      recentScores: (json['recentScores'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$SpeakingStatsToJson(SpeakingStats instance) =>
    <String, dynamic>{
      'totalLessons': instance.totalLessons,
      'completedLessons': instance.completedLessons,
      'totalAttempts': instance.totalAttempts,
      'averageScore': instance.averageScore,
      'totalPracticeTime': instance.totalPracticeTime.inMicroseconds,
      'lastPracticeDate': instance.lastPracticeDate.toIso8601String(),
      'lessonsByLevel': instance.lessonsByLevel
          .map((k, e) => MapEntry(_$SpeakingLevelEnumMap[k]!, e)),
      'recentScores': instance.recentScores,
    };
