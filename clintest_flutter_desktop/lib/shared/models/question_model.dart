import 'package:json_annotation/json_annotation.dart';
import '../../core/constants/app_constants.dart';

part 'question_model.g.dart';

@JsonSerializable()
class QuestionModel {
  final String id;
  final String title;
  final String content;
  final QuestionType type;
  final Difficulty difficulty;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuestionModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.difficulty,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.category,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionModelToJson(this);

  QuestionModel copyWith({
    String? id,
    String? title,
    String? content,
    QuestionType? type,
    Difficulty? difficulty,
    List<String>? options,
    String? correctAnswer,
    String? explanation,
    String? category,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}