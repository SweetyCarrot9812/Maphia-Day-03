import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// 알림 서비스를 초기화합니다
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
    debugPrint('NotificationService initialized');
  }

  /// 알림 권한을 요청합니다
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();
    
    final result = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    return result ?? false;
  }

  /// 휴식 시간 알림을 설정합니다
  Future<void> scheduleRestNotification({
    required int restSeconds,
    required String exerciseName,
    int? notificationId,
  }) async {
    if (!_initialized) await initialize();

    final id = notificationId ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    const androidDetails = AndroidNotificationDetails(
      'rest_timer',
      'Rest Timer',
      channelDescription: '운동 휴식 시간 알림',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('rest_timer'),
    );

    const iosDetails = DarwinNotificationDetails(
      sound: 'rest_timer.aiff',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      '휴식 시간 완료',
      '$exerciseName 다음 세트를 시작할 시간입니다!',
      tz.TZDateTime.now(tz.local).add(Duration(seconds: restSeconds)),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'rest_complete:$exerciseName',
    );

    debugPrint('Rest notification scheduled for $restSeconds seconds - $exerciseName');
  }

  /// 운동 시작 알림을 표시합니다
  Future<void> showWorkoutStartNotification(String exerciseName) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'workout_status',
      'Workout Status',
      channelDescription: '운동 상태 알림',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      9999,
      '운동 시작',
      '$exerciseName 운동을 시작했습니다.',
      details,
    );
  }

  /// 운동 완료 알림을 표시합니다
  Future<void> showWorkoutCompleteNotification({
    required String exerciseName,
    required int sets,
    required int totalReps,
    required double totalVolume,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'workout_status',
      'Workout Status',
      channelDescription: '운동 상태 알림',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      9998,
      '운동 완료',
      '$exerciseName: ${sets}세트, ${totalReps}회, ${totalVolume.toStringAsFixed(1)}kg',
      details,
    );
  }

  /// 운동 목표 달성 알림을 표시합니다
  Future<void> showPersonalRecordNotification({
    required String exerciseName,
    required String recordType,
    required String newRecord,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'achievements',
      'Achievements',
      channelDescription: '운동 성과 알림',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('achievement'),
    );

    const iosDetails = DarwinNotificationDetails(
      sound: 'achievement.aiff',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🎉 새로운 기록!',
      '$exerciseName $recordType: $newRecord',
      details,
      payload: 'achievement:$exerciseName',
    );
  }

  /// 일일 운동 리마인더를 설정합니다
  Future<void> scheduleDailyWorkoutReminder({
    required int hour,
    required int minute,
    String? customMessage,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Workout Reminder',
      channelDescription: '일일 운동 리마인더',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = _nextInstanceOfTime(hour, minute);
    
    await _notifications.zonedSchedule(
      1000, // Fixed ID for daily reminder
      '운동 시간',
      customMessage ?? '오늘의 운동을 시작해보세요! 💪',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'daily_reminder',
    );

    debugPrint('Daily workout reminder scheduled for ${hour}:${minute}');
  }

  /// 특정 알림을 취소합니다
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// 모든 알림을 취소합니다
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// 휴식 타이머 관련 알림들을 취소합니다
  Future<void> cancelRestTimerNotifications() async {
    // 휴식 타이머는 현재 시각을 기반으로 ID를 생성하므로
    // 최근 생성된 알림들을 찾아서 취소해야 합니다
    final pendingNotifications = await _notifications.pendingNotificationRequests();
    
    for (final notification in pendingNotifications) {
      if (notification.payload?.startsWith('rest_complete:') == true) {
        await _notifications.cancel(notification.id);
      }
    }
  }

  /// 알림 탭 이벤트 처리
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      final payload = response.payload!;
      
      if (payload.startsWith('rest_complete:')) {
        final exerciseName = payload.split(':').last;
        debugPrint('Rest timer completed for: $exerciseName');
        // TODO: Navigate to workout screen or show rest complete dialog
      } else if (payload.startsWith('achievement:')) {
        final exerciseName = payload.split(':').last;
        debugPrint('Achievement notification tapped for: $exerciseName');
        // TODO: Navigate to achievement screen
      } else if (payload == 'daily_reminder') {
        debugPrint('Daily reminder tapped');
        // TODO: Navigate to workout screen
      }
    }
  }

  /// 다음 특정 시간 인스턴스를 계산합니다
  DateTime _nextInstanceOfTime(int hour, int minute) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }
}