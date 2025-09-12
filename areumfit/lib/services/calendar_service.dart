import 'dart:convert';
import 'dart:developer';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import '../models/base_model.dart';
import '../models/calendar_models.dart';
import '../models/workout_plan.dart';
import '../models/workout_log.dart';
import '../models/isar_models.dart';
import '../models/isar_converters.dart';
import 'isar_service.dart';
import 'sync_service.dart';

part 'calendar_service.freezed.dart';
part 'calendar_service.g.dart';

/// 캘린더 및 스케줄 관리 서비스
class CalendarService {
  final IsarService _isarService;
  final SyncService _syncService;

  CalendarService(this._isarService, this._syncService);

  // ===== 운동 스케줄 관리 =====

  /// 운동 계획에 대한 스케줄 생성
  Future<WorkoutSchedule> createSchedule({
    required String userId,
    required String planId,
    required String title,
    required DateTime startDate,
    RRule? rrule,
  }) async {
    final schedule = WorkoutSchedule(
      id: 'schedule_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deviceId: await _getDeviceId(),
      planId: planId,
      title: title,
      startDate: startDate,
      rrule: rrule,
    );

    await _saveScheduleLocally(schedule);
    await _scheduleSync(schedule, SyncOperation.upsert);

    log('Created workout schedule: ${schedule.id}');
    return schedule;
  }

  /// 스케줄 목록 조회
  Future<List<WorkoutSchedule>> getSchedules(String userId) async {
    final isar = await _isarService.database;
    
    final localSchedules = await isar.localWorkoutSchedules
        .filter()
        .userIdEqualTo(userId)
        .isActiveEqualTo(true)
        .findAll();

    return localSchedules.map((local) => local.toWorkoutSchedule()).toList();
  }

  /// 특정 날짜의 스케줄 조회
  Future<List<WorkoutSchedule>> getSchedulesForDate(String userId, DateTime date) async {
    final allSchedules = await getSchedules(userId);
    
    return allSchedules
        .where((schedule) => schedule.isScheduledForDate(date))
        .toList();
  }

  /// 스케줄 완료 처리
  Future<WorkoutSchedule> markScheduleCompleted(String scheduleId, DateTime date) async {
    final isar = await _isarService.database;
    
    final localSchedule = await isar.localWorkoutSchedules
        .filter()
        .scheduleIdEqualTo(scheduleId)
        .findFirst();

    if (localSchedule == null) {
      throw Exception('Schedule not found: $scheduleId');
    }

    final updatedSchedule = localSchedule.toWorkoutSchedule().markCompletedForDate(date);
    await _saveScheduleLocally(updatedSchedule);
    await _scheduleSync(updatedSchedule, SyncOperation.upsert);

    log('Marked schedule completed: $scheduleId for ${date.toIso8601String().substring(0, 10)}');
    return updatedSchedule;
  }

  // ===== 캘린더 이벤트 생성 =====

  /// 특정 달의 캘린더 이벤트 생성
  Future<Map<DateTime, List<CalendarEvent>>> getCalendarEventsForMonth(
    String userId,
    DateTime month,
  ) async {
    final events = <DateTime, List<CalendarEvent>>{};
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    // 모든 스케줄 가져오기
    final schedules = await getSchedules(userId);

    // 완료된 세션들 가져오기
    final completedSessions = await _getCompletedSessionsForMonth(userId, month);

    // 월의 모든 날짜에 대해 이벤트 생성
    for (var date = startOfMonth; date.isBefore(endOfMonth.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      final dayEvents = <CalendarEvent>[];

      // 예정된 운동 체크
      for (final schedule in schedules) {
        if (schedule.isScheduledForDate(date)) {
          if (schedule.isCompletedForDate(date)) {
            // 완료된 운동
            dayEvents.add(CalendarEvent(
              date: date,
              title: schedule.title,
              type: CalendarEventType.completed,
              scheduleId: schedule.id,
              metadata: {'schedule': schedule.toJson()},
            ));
          } else if (date.isBefore(DateTime.now())) {
            // 놓친 운동
            dayEvents.add(CalendarEvent(
              date: date,
              title: schedule.title,
              type: CalendarEventType.missed,
              scheduleId: schedule.id,
              metadata: {'schedule': schedule.toJson()},
            ));
          } else {
            // 예정된 운동
            dayEvents.add(CalendarEvent(
              date: date,
              title: schedule.title,
              type: CalendarEventType.scheduled,
              scheduleId: schedule.id,
              metadata: {'schedule': schedule.toJson()},
            ));
          }
        }
      }

      // 완료된 세션 추가 (스케줄에 없는 운동들)
      final dayCompletedSessions = completedSessions
          .where((session) => _isSameDay(session.date, date))
          .toList();

      for (final session in dayCompletedSessions) {
        // 이미 스케줄 이벤트가 있는지 체크
        final hasScheduleEvent = dayEvents.any(
          (event) => event.type == CalendarEventType.completed && event.sessionId == session.id,
        );

        if (!hasScheduleEvent) {
          // 운동 로그 정보를 포함하여 이벤트 생성
          final sessionLogs = await _getSessionLogs(session.id);
          final sessionData = session.toJson();
          sessionData['logs'] = sessionLogs.map((log) => log.toJson()).toList();
          
          dayEvents.add(CalendarEvent(
            date: date,
            title: '자유 운동', // 스케줄 없는 운동
            type: CalendarEventType.completed,
            sessionId: session.id,
            metadata: {'session': sessionData},
          ));
        }
      }

      if (dayEvents.isNotEmpty) {
        events[date] = dayEvents;
      }
    }

    return events;
  }

  /// 운동 통계 조회
  Future<WorkoutCalendarStats> getCalendarStats(String userId, DateTime month) async {
    final events = await getCalendarEventsForMonth(userId, month);
    
    var scheduledCount = 0;
    var completedCount = 0;
    var missedCount = 0;
    var totalWorkouts = 0;

    for (final dayEvents in events.values) {
      for (final event in dayEvents) {
        switch (event.type) {
          case CalendarEventType.scheduled:
            scheduledCount++;
            totalWorkouts++;
            break;
          case CalendarEventType.completed:
            completedCount++;
            totalWorkouts++;
            break;
          case CalendarEventType.missed:
            missedCount++;
            totalWorkouts++;
            break;
          case CalendarEventType.rest:
            break;
        }
      }
    }

    final completionRate = totalWorkouts > 0 ? (completedCount / totalWorkouts) * 100 : 0.0;

    return WorkoutCalendarStats(
      month: month,
      scheduledCount: scheduledCount,
      completedCount: completedCount,
      missedCount: missedCount,
      completionRate: completionRate,
    );
  }

  // ===== 다가오는 운동 조회 =====

  /// 향후 일주일간의 운동 일정 조회
  Future<List<UpcomingWorkout>> getUpcomingWorkouts(String userId, {int days = 7}) async {
    final schedules = await getSchedules(userId);
    final upcomingWorkouts = <UpcomingWorkout>[];

    final startDate = DateTime.now();
    final endDate = startDate.add(Duration(days: days));

    for (final schedule in schedules) {
      final dates = schedule.getUpcomingDates(days: days);
      
      for (final date in dates) {
        if (date.isAfter(startDate) && date.isBefore(endDate) && !schedule.isCompletedForDate(date)) {
          upcomingWorkouts.add(UpcomingWorkout(
            scheduleId: schedule.id,
            title: schedule.title,
            date: date,
            daysUntil: date.difference(DateTime.now()).inDays,
          ));
        }
      }
    }

    // 날짜순 정렬
    upcomingWorkouts.sort((a, b) => a.date.compareTo(b.date));
    return upcomingWorkouts;
  }

  // ===== 내부 헬퍼 메서드 =====

  /// 로컬 스케줄 저장
  Future<void> _saveScheduleLocally(WorkoutSchedule schedule) async {
    final isar = await _isarService.database;
    final localSchedule = LocalWorkoutScheduleExtension.fromWorkoutSchedule(schedule);

    await isar.writeTxn(() async {
      await isar.localWorkoutSchedules.put(localSchedule);
    });
  }

  /// 스케줄 동기화 예약
  Future<void> _scheduleSync(WorkoutSchedule schedule, SyncOperation op) async {
    final isar = await _isarService.database;
    
    final pendingOp = PendingOperationIsar()
      ..operationId = 'schedule_${schedule.id}_${DateTime.now().millisecondsSinceEpoch}'
      ..op = op.name
      ..collection = 'schedules'
      ..payload = jsonEncode(schedule.toJson())
      ..createdAt = DateTime.now()
      ..retryCount = 0
      ..processed = false;

    await isar.writeTxn(() async {
      await isar.pendingOperationIsars.put(pendingOp);
    });
  }

  /// 완료된 세션들 조회
  Future<List<WorkoutSession>> _getCompletedSessionsForMonth(String userId, DateTime month) async {
    final isar = await _isarService.database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final sessions = await isar.localSessions
        .filter()
        .userIdEqualTo(userId)
        .statusEqualTo(SessionStatus.done.name)
        .dateGreaterThan(startOfMonth.subtract(const Duration(days: 1)))
        .dateLessThan(endOfMonth.add(const Duration(days: 1)))
        .findAll();

    return sessions.map((local) => local.toWorkoutSession()).toList();
  }

  /// 특정 세션의 운동 로그들을 조회
  Future<List<WorkoutLog>> _getSessionLogs(String sessionId) async {
    final isar = await _isarService.database;
    
    final logs = await isar.localLogs
        .filter()
        .sessionIdEqualTo(sessionId)
        .findAll();

    return logs.map((local) => local.toWorkoutLog()).toList();
  }

  /// 같은 날짜인지 확인
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 디바이스 ID 생성
  Future<String> _getDeviceId() async {
    return 'device_${DateTime.now().millisecondsSinceEpoch % 10000}';
  }
}

/// 캘린더 통계
@freezed
class WorkoutCalendarStats with _$WorkoutCalendarStats {
  const factory WorkoutCalendarStats({
    required DateTime month,
    required int scheduledCount,
    required int completedCount,
    required int missedCount,
    required double completionRate,
  }) = _WorkoutCalendarStats;

  factory WorkoutCalendarStats.fromJson(Map<String, dynamic> json) => _$WorkoutCalendarStatsFromJson(json);
}

/// 다가오는 운동
@freezed
class UpcomingWorkout with _$UpcomingWorkout {
  const factory UpcomingWorkout({
    required String scheduleId,
    required String title,
    required DateTime date,
    required int daysUntil,
  }) = _UpcomingWorkout;

  factory UpcomingWorkout.fromJson(Map<String, dynamic> json) => _$UpcomingWorkoutFromJson(json);
}
