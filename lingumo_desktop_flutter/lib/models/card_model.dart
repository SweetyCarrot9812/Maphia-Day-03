import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'card_model.g.dart';

@JsonSerializable()
class CardModel {
  final String? id;
  final String front;
  final String back;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String vocabularyId;

  const CardModel({
    this.id,
    required this.front,
    required this.back,
    this.note = '',
    required this.createdAt,
    required this.updatedAt,
    this.vocabularyId = 'default',
  });

  factory CardModel.create({
    required String front,
    required String back,
    String note = '',
    String vocabularyId = 'default',
  }) {
    final now = DateTime.now();
    return CardModel(
      front: front,
      back: back,
      note: note,
      vocabularyId: vocabularyId,
      createdAt: now,
      updatedAt: now,
    );
  }

  CardModel copyWith({
    String? id,
    String? front,
    String? back,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? vocabularyId,
  }) {
    return CardModel(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      vocabularyId: vocabularyId ?? this.vocabularyId,
    );
  }

  Map<String, dynamic> toJson() => _$CardModelToJson(this);
  factory CardModel.fromJson(Map<String, dynamic> json) => _$CardModelFromJson(json);

  Map<String, dynamic> toFirestore() {
    return {
      'front': front,
      'back': back,
      'note': note,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'vocabularyId': vocabularyId,
    };
  }

  factory CardModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CardModel(
      id: id,
      front: data['front'] ?? '',
      back: data['back'] ?? '',
      note: data['note'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      vocabularyId: data['vocabularyId'] ?? 'default',
    );
  }
}