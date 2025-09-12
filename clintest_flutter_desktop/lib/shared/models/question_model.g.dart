// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) =>
    QuestionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: $enumDecode(_$QuestionTypeEnumMap, json['type']),
      difficulty: $enumDecode(_$DifficultyEnumMap, json['difficulty']),
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$QuestionModelToJson(QuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'type': _$QuestionTypeEnumMap[instance.type]!,
      'difficulty': _$DifficultyEnumMap[instance.difficulty]!,
      'options': instance.options,
      'correctAnswer': instance.correctAnswer,
      'explanation': instance.explanation,
      'category': instance.category,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$QuestionTypeEnumMap = {
  QuestionType.multipleChoice: 'multipleChoice',
  QuestionType.trueFalse: 'trueFalse',
  QuestionType.shortAnswer: 'shortAnswer',
  QuestionType.essay: 'essay',
};

const _$DifficultyEnumMap = {
  Difficulty.easy: 'easy',
  Difficulty.medium: 'medium',
  Difficulty.hard: 'hard',
};
