import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import 'base_model.dart';
import 'isar_models.dart';

part 'calendar_models.freezed.dart';
part 'calendar_models.g.dart';

/// RRULE 빈도 enum
enum RRuleFrequency {
  daily,
  weekly,
  monthly,
  yearly;

  String get value {
    switch (this) {
      case RRuleFrequency.daily:
        return 'DAILY';
      case RRuleFrequency.weekly:
        return 'WEEKLY';
      case RRuleFrequency.monthly:
        return 'MONTHLY';
      case RRuleFrequency.yearly:
        return 'YEARLY';
    }
  }

  static RRuleFrequency fromString(String value) {
    switch (value.toUpperCase()) {
      case 'DAILY':
        return RRuleFrequency.daily;
      case 'WEEKLY':
        return RRuleFrequency.weekly;
      case 'MONTHLY':
        return RRuleFrequency.monthly;
      case 'YEARLY':
        return RRuleFrequency.yearly;
      default:
        return RRuleFrequency.weekly;
    }
  }
}

/// 요일 enum (RRULE BYDAY)
enum Weekday {
  monday(1, 'MO'),
  tuesday(2, 'TU'),
  wednesday(3, 'WE'),
  thursday(4, 'TH'),
  friday(5, 'FR'),
  saturday(6, 'SA'),
  sunday(7, 'SU');

  const Weekday(this.number, this.rruleCode);

  final int number;
  final String rruleCode;

  static Weekday fromDateTime(DateTime date) {
    return Weekday.values[date.weekday - 1];
  }

  static Weekday fromRRuleCode(String code) {
    return Weekday.values.firstWhere(
      (day) => day.rruleCode == code.toUpperCase(),
      orElse: () => Weekday.monday,
    );
  }
}

/// RRULE 파서 및 생성기
@freezed
class RRule with _$RRule {
  const factory RRule({
    required RRuleFrequency frequency,
    @Default(1) int interval,
    List<Weekday>? byWeekday,
    List<int>? byMonthDay,
    List<int>? byMonth,
    DateTime? until,
    int? count,
  }) = _RRule;

  factory RRule.fromJson(Map<String, dynamic> json) => _$RRuleFromJson(json);

  const RRule._();

  /// RRULE 문자열로 변환
  String toRRuleString() {
    final parts = <String>[];
    
    parts.add('FREQ=${frequency.value}');
    
    if (interval > 1) {
      parts.add('INTERVAL=$interval');
    }
    
    if (byWeekday != null && byWeekday!.isNotEmpty) {
      final days = byWeekday!.map((day) => day.rruleCode).join(',');
      parts.add('BYDAY=$days');
    }
    
    if (byMonthDay != null && byMonthDay!.isNotEmpty) {
      parts.add('BYMONTHDAY=${byMonthDay!.join(',')}');
    }
    
    if (byMonth != null && byMonth!.isNotEmpty) {
      parts.add('BYMONTH=${byMonth!.join(',')}');
    }
    
    if (until != null) {
      final untilStr = until!.toUtc().toIso8601String().replaceAll(RegExp(r'[:-]'), '').substring(0, 15) + 'Z';
      parts.add('UNTIL=$untilStr');
    }
    
    if (count != null && count! > 0) {
      parts.add('COUNT=$count');
    }
    
    return 'RRULE:${parts.join(';')}';
  }

  /// RRULE 문자열에서 파싱
  static RRule fromRRuleString(String rruleString) {
    if (!rruleString.startsWith('RRULE:')) {
      throw ArgumentError('Invalid RRULE string: must start with "RRULE:"');
    }
    
    final parts = rruleString.substring(6).split(';');
    final rules = <String, String>{};
    
    for (final part in parts) {
      final colonIndex = part.indexOf('=');
      if (colonIndex > 0) {
        rules[part.substring(0, colonIndex)] = part.substring(colonIndex + 1);
      }
    }
    
    final frequency = RRuleFrequency.fromString(rules['FREQ'] ?? 'WEEKLY');
    final interval = int.tryParse(rules['INTERVAL'] ?? '1') ?? 1;
    
    List<Weekday>? byWeekday;
    if (rules.containsKey('BYDAY')) {
      byWeekday = rules['BYDAY']!
          .split(',')
          .map((code) => Weekday.fromRRuleCode(code))
          .toList();
    }
    
    List<int>? byMonthDay;
    if (rules.containsKey('BYMONTHDAY')) {
      byMonthDay = rules['BYMONTHDAY']!
          .split(',')
          .map((day) => int.parse(day))
          .toList();
    }
    
    List<int>? byMonth;
    if (rules.containsKey('BYMONTH')) {
      byMonth = rules['BYMONTH']!
          .split(',')
          .map((month) => int.parse(month))
          .toList();
    }
    
    DateTime? until;
    if (rules.containsKey('UNTIL')) {
      // RRULE 날짜 형식 파싱 (YYYYMMDDTHHMMSSZ)
      final untilStr = rules['UNTIL']!;
      if (untilStr.length >= 8) {
        final year = int.parse(untilStr.substring(0, 4));
        final month = int.parse(untilStr.substring(4, 6));
        final day = int.parse(untilStr.substring(6, 8));
        until = DateTime(year, month, day);
      }
    }
    
    final count = rules.containsKey('COUNT') ? int.tryParse(rules['COUNT']!) : null;
    
    return RRule(
      frequency: frequency,
      interval: interval,
      byWeekday: byWeekday,
      byMonthDay: byMonthDay,
      byMonth: byMonth,
      until: until,
      count: count,
    );
  }

  /// 다음 발생 날짜들 생성 (최대 maxOccurrences개)
  List<DateTime> generateOccurrences(DateTime startDate, {int maxOccurrences = 100}) {
    final occurrences = <DateTime>[];
    var current = startDate;
    var occurrenceCount = 0;
    
    while (occurrences.length < maxOccurrences && occurrenceCount < (count ?? maxOccurrences)) {
      if (until != null && current.isAfter(until!)) {
        break;
      }
      
      if (_shouldIncludeDate(current)) {
        occurrences.add(current);
        occurrenceCount++;
      }
      
      current = _getNextDate(current);
    }
    
    return occurrences;
  }

  /// 특정 날짜가 규칙에 포함되는지 확인
  bool _shouldIncludeDate(DateTime date) {
    // byWeekday 체크
    if (byWeekday != null && byWeekday!.isNotEmpty) {
      final weekday = Weekday.fromDateTime(date);
      if (!byWeekday!.contains(weekday)) {
        return false;
      }
    }
    
    // byMonthDay 체크
    if (byMonthDay != null && byMonthDay!.isNotEmpty) {
      if (!byMonthDay!.contains(date.day)) {
        return false;
      }
    }
    
    // byMonth 체크
    if (byMonth != null && byMonth!.isNotEmpty) {
      if (!byMonth!.contains(date.month)) {
        return false;
      }
    }
    
    return true;
  }

  /// 다음 날짜 계산
  DateTime _getNextDate(DateTime current) {
    switch (frequency) {
      case RRuleFrequency.daily:
        return current.add(Duration(days: interval));
      case RRuleFrequency.weekly:
        return current.add(Duration(days: 7 * interval));
      case RRuleFrequency.monthly:
        return DateTime(current.year, current.month + interval, current.day);
      case RRuleFrequency.yearly:
        return DateTime(current.year + interval, current.month, current.day);
    }
  }
}

/// 운동 계획 스케줄
@freezed
class WorkoutSchedule with _$WorkoutSchedule {
  const factory WorkoutSchedule({
    required String id,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String deviceId,
    @Default(false) bool conflicted,
    // 스케줄 특화 필드
    required String planId,
    required String title,
    required DateTime startDate,
    RRule? rrule,
    @Default(true) bool isActive,
    @Default([]) List<String> completedDates, // ISO 8601 문자열 배열
  }) = _WorkoutSchedule;

  factory WorkoutSchedule.fromJson(Map<String, dynamic> json) => _$WorkoutScheduleFromJson(json);

  const WorkoutSchedule._();

  /// 특정 날짜에 운동이 예정되어 있는지 확인
  bool isScheduledForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly.isBefore(DateTime(startDate.year, startDate.month, startDate.day))) {
      return false;
    }
    
    if (rrule == null) {
      // 일회성 운동
      return dateOnly.isAtSameMomentAs(DateTime(startDate.year, startDate.month, startDate.day));
    }
    
    // RRULE 기반 반복 운동
    final occurrences = rrule!.generateOccurrences(startDate, maxOccurrences: 365);
    return occurrences.any((occurrence) => 
      DateTime(occurrence.year, occurrence.month, occurrence.day).isAtSameMomentAs(dateOnly));
  }

  /// 특정 날짜의 운동이 완료되었는지 확인
  bool isCompletedForDate(DateTime date) {
    final dateString = DateTime(date.year, date.month, date.day).toIso8601String().substring(0, 10);
    return completedDates.contains(dateString);
  }

  /// 특정 날짜의 운동 완료 처리
  WorkoutSchedule markCompletedForDate(DateTime date) {
    final dateString = DateTime(date.year, date.month, date.day).toIso8601String().substring(0, 10);
    if (completedDates.contains(dateString)) {
      return this;
    }
    
    return copyWith(
      completedDates: [...completedDates, dateString],
      updatedAt: DateTime.now(),
    );
  }

  /// 향후 30일간의 예정된 날짜들 가져오기
  List<DateTime> getUpcomingDates({int days = 30}) {
    final startFrom = DateTime.now();
    final endDate = startFrom.add(Duration(days: days));
    
    if (rrule == null) {
      final scheduleDate = DateTime(startDate.year, startDate.month, startDate.day);
      if (scheduleDate.isAfter(startFrom) && scheduleDate.isBefore(endDate)) {
        return [scheduleDate];
      }
      return [];
    }
    
    final occurrences = rrule!.generateOccurrences(startDate);
    return occurrences
        .where((date) => date.isAfter(startFrom) && date.isBefore(endDate))
        .toList();
  }
}

/// LocalWorkoutSchedule 확장 메서드
extension LocalWorkoutScheduleExtension on LocalWorkoutSchedule {
  /// WorkoutSchedule로 변환
  WorkoutSchedule toWorkoutSchedule() {
    return WorkoutSchedule(
      id: scheduleId,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deviceId: deviceId,
      conflicted: conflicted,
      planId: planId,
      title: title,
      startDate: startDate,
      rrule: rruleString != null ? RRule.fromRRuleString(rruleString!) : null,
      isActive: isActive,
      completedDates: completedDates,
    );
  }

  /// WorkoutSchedule에서 변환
  static LocalWorkoutSchedule fromWorkoutSchedule(WorkoutSchedule schedule) {
    return LocalWorkoutSchedule()
      ..scheduleId = schedule.id
      ..userId = schedule.userId
      ..planId = schedule.planId
      ..title = schedule.title
      ..startDate = schedule.startDate
      ..createdAt = schedule.createdAt
      ..updatedAt = schedule.updatedAt
      ..deviceId = schedule.deviceId
      ..conflicted = schedule.conflicted
      ..isActive = schedule.isActive
      ..rruleString = schedule.rrule?.toRRuleString()
      ..completedDates = schedule.completedDates;
  }
}

/// 캘린더 이벤트 (운동 세션 요약)
@freezed
class CalendarEvent with _$CalendarEvent {
  const factory CalendarEvent({
    required DateTime date,
    required String title,
    required CalendarEventType type,
    String? sessionId,
    String? scheduleId,
    @Default({}) Map<String, dynamic> metadata,
  }) = _CalendarEvent;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => _$CalendarEventFromJson(json);
}

/// 캘린더 이벤트 타입
enum CalendarEventType {
  scheduled,    // 예정된 운동
  completed,    // 완료된 운동
  missed,       // 놓친 운동
  rest,         // 휴식일
}