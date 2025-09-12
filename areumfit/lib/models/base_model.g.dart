// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BaseModelImpl _$$BaseModelImplFromJson(Map<String, dynamic> json) =>
    _$BaseModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deviceId: json['deviceId'] as String,
      conflicted: json['conflicted'] as bool? ?? false,
    );

Map<String, dynamic> _$$BaseModelImplToJson(_$BaseModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deviceId': instance.deviceId,
      'conflicted': instance.conflicted,
    };
