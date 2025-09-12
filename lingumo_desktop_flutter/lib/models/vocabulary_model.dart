import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'vocabulary_model.g.dart';

@JsonSerializable()
class VocabularyModel {
  final String? id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int cardCount;

  const VocabularyModel({
    this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
    this.cardCount = 0,
  });

  factory VocabularyModel.create({
    required String name,
    String description = '',
  }) {
    final now = DateTime.now();
    return VocabularyModel(
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
  }

  VocabularyModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? cardCount,
  }) {
    return VocabularyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cardCount: cardCount ?? this.cardCount,
    );
  }

  Map<String, dynamic> toJson() => _$VocabularyModelToJson(this);
  factory VocabularyModel.fromJson(Map<String, dynamic> json) => _$VocabularyModelFromJson(json);

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'cardCount': cardCount,
    };
  }

  factory VocabularyModel.fromFirestore(Map<String, dynamic> data, String id) {
    return VocabularyModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cardCount: data['cardCount'] ?? 0,
    );
  }
}