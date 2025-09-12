// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutCalendarStatsImpl _$$WorkoutCalendarStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkoutCalendarStatsImpl(
      month: DateTime.parse(json['month'] as String),
      scheduledCount: (json['scheduledCount'] as num).toInt(),
      completedCount: (json['completedCount'] as num).toInt(),
      missedCount: (json['missedCount'] as num).toInt(),
      completionRate: (json['completionRate'] as num).toDouble(),
    );

Map<String, dynamic> _$$WorkoutCalendarStatsImplToJson(
        _$WorkoutCalendarStatsImpl instance) =>
    <String, dynamic>{
      'month': instance.month.toIso8601String(),
      'scheduledCount': instance.scheduledCount,
      'completedCount': instance.completedCount,
      'missedCount': instance.missedCount,
      'completionRate': instance.completionRate,
    };

_$UpcomingWorkoutImpl _$$UpcomingWorkoutImplFromJson(
        Map<String, dynamic> json) =>
    _$UpcomingWorkoutImpl(
      scheduleId: json['scheduleId'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      daysUntil: (json['daysUntil'] as num).toInt(),
    );

Map<String, dynamic> _$$UpcomingWorkoutImplToJson(
        _$UpcomingWorkoutImpl instance) =>
    <String, dynamic>{
      'scheduleId': instance.scheduleId,
      'title': instance.title,
      'date': instance.date.toIso8601String(),
      'daysUntil': instance.daysUntil,
    };
