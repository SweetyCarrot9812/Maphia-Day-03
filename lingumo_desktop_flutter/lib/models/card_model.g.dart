// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardModel _$CardModelFromJson(Map<String, dynamic> json) => CardModel(
      id: json['id'] as String?,
      front: json['front'] as String,
      back: json['back'] as String,
      note: json['note'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      vocabularyId: json['vocabularyId'] as String? ?? 'default',
    );

Map<String, dynamic> _$CardModelToJson(CardModel instance) => <String, dynamic>{
      'id': instance.id,
      'front': instance.front,
      'back': instance.back,
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'vocabularyId': instance.vocabularyId,
    };
