// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RRuleImpl _$$RRuleImplFromJson(Map<String, dynamic> json) => _$RRuleImpl(
      frequency: $enumDecode(_$RRuleFrequencyEnumMap, json['frequency']),
      interval: (json['interval'] as num?)?.toInt() ?? 1,
      byWeekday: (json['byWeekday'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$WeekdayEnumMap, e))
          .toList(),
      byMonthDay: (json['byMonthDay'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      byMonth: (json['byMonth'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      until: json['until'] == null
          ? null
          : DateTime.parse(json['until'] as String),
      count: (json['count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$RRuleImplToJson(_$RRuleImpl instance) =>
    <String, dynamic>{
      'frequency': _$RRuleFrequencyEnumMap[instance.frequency]!,
      'interval': instance.interval,
      'byWeekday':
          instance.byWeekday?.map((e) => _$WeekdayEnumMap[e]!).toList(),
      'byMonthDay': instance.byMonthDay,
      'byMonth': instance.byMonth,
      'until': instance.until?.toIso8601String(),
      'count': instance.count,
    };

const _$RRuleFrequencyEnumMap = {
  RRuleFrequency.daily: 'daily',
  RRuleFrequency.weekly: 'weekly',
  RRuleFrequency.monthly: 'monthly',
  RRuleFrequency.yearly: 'yearly',
};

const _$WeekdayEnumMap = {
  Weekday.monday: 'monday',
  Weekday.tuesday: 'tuesday',
  Weekday.wednesday: 'wednesday',
  Weekday.thursday: 'thursday',
  Weekday.friday: 'friday',
  Weekday.saturday: 'saturday',
  Weekday.sunday: 'sunday',
};

_$WorkoutScheduleImpl _$$WorkoutScheduleImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkoutScheduleImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deviceId: json['deviceId'] as String,
      conflicted: json['conflicted'] as bool? ?? false,
      planId: json['planId'] as String,
      title: json['title'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      rrule: json['rrule'] == null
          ? null
          : RRule.fromJson(json['rrule'] as Map<String, dynamic>),
      isActive: json['isActive'] as bool? ?? true,
      completedDates: (json['completedDates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$WorkoutScheduleImplToJson(
        _$WorkoutScheduleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deviceId': instance.deviceId,
      'conflicted': instance.conflicted,
      'planId': instance.planId,
      'title': instance.title,
      'startDate': instance.startDate.toIso8601String(),
      'rrule': instance.rrule,
      'isActive': instance.isActive,
      'completedDates': instance.completedDates,
    };

_$CalendarEventImpl _$$CalendarEventImplFromJson(Map<String, dynamic> json) =>
    _$CalendarEventImpl(
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      type: $enumDecode(_$CalendarEventTypeEnumMap, json['type']),
      sessionId: json['sessionId'] as String?,
      scheduleId: json['scheduleId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$CalendarEventImplToJson(_$CalendarEventImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'title': instance.title,
      'type': _$CalendarEventTypeEnumMap[instance.type]!,
      'sessionId': instance.sessionId,
      'scheduleId': instance.scheduleId,
      'metadata': instance.metadata,
    };

const _$CalendarEventTypeEnumMap = {
  CalendarEventType.scheduled: 'scheduled',
  CalendarEventType.completed: 'completed',
  CalendarEventType.missed: 'missed',
  CalendarEventType.rest: 'rest',
};
