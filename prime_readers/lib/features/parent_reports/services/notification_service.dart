import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:hive/hive.dart';
import '../models/report_models.dart';

class NotificationService {
  late Box<PushNotification> _notificationBox;
  late Box<NotificationSettings> _settingsBox;
  
  // Simulated push notification service
  final _notificationController = StreamController<PushNotification>.broadcast();
  Timer? _schedulerTimer;
  
  // Stream for real-time notifications
  Stream<PushNotification> get notificationStream => _notificationController.stream;

  Future<void> initialize() async {
    _notificationBox = await Hive.openBox<PushNotification>('push_notifications');
    _settingsBox = await Hive.openBox<NotificationSettings>('notification_settings');
    
    // Start the notification scheduler
    _startNotificationScheduler();
    
    // Process any pending scheduled notifications
    await _processPendingNotifications();
  }

  void dispose() {
    _notificationController.close();
    _schedulerTimer?.cancel();
  }

  // Core notification methods
  Future<String> sendNotification({
    required String userId,
    String? parentId,
    required NotificationType type,
    required String title,
    required String body,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
    DateTime? scheduledFor,
  }) async {
    final notificationId = 'notif_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
    
    final notification = PushNotification(
      id: notificationId,
      userId: userId,
      parentId: parentId,
      type: type,
      title: title,
      body: body,
      priority: priority,
      createdAt: DateTime.now(),
      scheduledFor: scheduledFor,
      data: data ?? {},
      imageUrl: imageUrl,
      actionUrl: actionUrl,
    );

    await _notificationBox.put(notificationId, notification);

    // If not scheduled, send immediately
    if (scheduledFor == null) {
      await _deliverNotification(notification);
    }

    return notificationId;
  }

  Future<void> _deliverNotification(PushNotification notification) async {
    // Check if user wants to receive this type of notification
    final settings = await _settingsBox.get(notification.parentId ?? notification.userId);
    if (settings != null && !_shouldSendNotification(notification, settings)) {
      return;
    }

    // Simulate sending push notification
    final updatedNotification = notification.copyWith(
      isSent: true,
      sentAt: DateTime.now(),
    );
    
    await _notificationBox.put(notification.id, updatedNotification);
    
    // Emit to stream for real-time updates
    _notificationController.add(updatedNotification);
    
    print('🔔 Push notification sent: ${notification.title}');
  }

  bool _shouldSendNotification(PushNotification notification, NotificationSettings settings) {
    // Check if notifications are enabled
    if (!settings.pushEnabled) return false;
    
    // Check type preferences
    if (settings.typePreferences.containsKey(notification.type)) {
      if (!settings.typePreferences[notification.type]!) return false;
    }
    
    // Check quiet hours
    if (_isInQuietHours(DateTime.now(), settings.quietHours)) return false;
    
    // Check quiet days
    if (settings.quietDays.contains(DateTime.now().weekday)) return false;
    
    return true;
  }

  bool _isInQuietHours(DateTime now, List<String> quietHours) {
    for (final quietHour in quietHours) {
      final parts = quietHour.split('-');
      if (parts.length != 2) continue;
      
      final startParts = parts[0].split(':');
      final endParts = parts[1].split(':');
      
      if (startParts.length != 2 || endParts.length != 2) continue;
      
      final startHour = int.tryParse(startParts[0]);
      final startMinute = int.tryParse(startParts[1]);
      final endHour = int.tryParse(endParts[0]);
      final endMinute = int.tryParse(endParts[1]);
      
      if (startHour == null || startMinute == null || endHour == null || endMinute == null) continue;
      
      final currentMinutes = now.hour * 60 + now.minute;
      final startMinutes = startHour * 60 + startMinute;
      final endMinutes = endHour * 60 + endMinute;
      
      // Handle overnight quiet hours (e.g., 22:00-06:00)
      if (startMinutes > endMinutes) {
        if (currentMinutes >= startMinutes || currentMinutes <= endMinutes) {
          return true;
        }
      } else {
        if (currentMinutes >= startMinutes && currentMinutes <= endMinutes) {
          return true;
        }
      }
    }
    
    return false;
  }

  // Notification scheduler
  void _startNotificationScheduler() {
    _schedulerTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _processPendingNotifications();
    });
  }

  Future<void> _processPendingNotifications() async {
    final now = DateTime.now();
    final pendingNotifications = _notificationBox.values
        .where((notification) => 
            notification.scheduledFor != null && 
            notification.scheduledFor!.isBefore(now) && 
            !notification.isSent)
        .toList();

    for (final notification in pendingNotifications) {
      await _deliverNotification(notification);
    }
  }

  // Specialized notification methods
  Future<String> sendProgressNotification({
    required String userId,
    String? parentId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    return await sendNotification(
      userId: userId,
      parentId: parentId,
      type: NotificationType.progress,
      title: title,
      body: body,
      priority: NotificationPriority.normal,
      data: data,
    );
  }

  Future<String> sendAchievementNotification({
    required String userId,
    String? parentId,
    required Achievement achievement,
  }) async {
    return await sendNotification(
      userId: userId,
      parentId: parentId,
      type: NotificationType.achievement,
      title: '🎉 새로운 성취를 달성했습니다!',
      body: '${achievement.title}: ${achievement.description}',
      priority: NotificationPriority.high,
      data: {
        'achievement_id': achievement.id,
        'category': achievement.category,
        'points': achievement.points.toString(),
      },
      imageUrl: achievement.iconUrl,
      actionUrl: '/achievements/${achievement.id}',
    );
  }

  Future<String> sendReportReadyNotification({
    required String userId,
    String? parentId,
    required String reportType,
    required String reportId,
  }) async {
    final typeText = reportType == 'weekly' ? '주간' : '월간';
    
    return await sendNotification(
      userId: userId,
      parentId: parentId,
      type: NotificationType.report_ready,
      title: '📊 새로운 학습 리포트가 준비되었습니다',
      body: '${typeText} 학습 리포트가 생성되어 확인하실 수 있습니다.',
      priority: NotificationPriority.normal,
      data: {
        'report_id': reportId,
        'report_type': reportType,
      },
      actionUrl: '/reports/$reportId',
    );
  }

  Future<String> sendGoalAchievedNotification({
    required String userId,
    String? parentId,
    required String goalTitle,
    required String goalCategory,
  }) async {
    return await sendNotification(
      userId: userId,
      parentId: parentId,
      type: NotificationType.goal_achieved,
      title: '🎯 목표를 달성했습니다!',
      body: '$goalCategory 목표 "$goalTitle"을(를) 성공적으로 달성했습니다.',
      priority: NotificationPriority.high,
      data: {
        'goal_title': goalTitle,
        'goal_category': goalCategory,
      },
    );
  }

  Future<String> sendStreakMilestoneNotification({
    required String userId,
    String? parentId,
    required int streakDays,
    required String activityType,
  }) async {
    return await sendNotification(
      userId: userId,
      parentId: parentId,
      type: NotificationType.streak_milestone,
      title: '🔥 연속 학습 기록 달성!',
      body: '$activityType 연속 ${streakDays}일 달성! 꾸준한 노력이 빛을 발하고 있습니다.',
      priority: NotificationPriority.normal,
      data: {
        'streak_days': streakDays.toString(),
        'activity_type': activityType,
      },
    );
  }

  Future<String> sendLowActivityAlert({
    required String userId,
    String? parentId,
    required int inactiveDays,
  }) async {
    return await sendNotification(
      userId: userId,
      parentId: parentId,
      type: NotificationType.low_activity,
      title: '⚠️ 학습 활동 부족 알림',
      body: '최근 ${inactiveDays}일간 학습 활동이 평소보다 적습니다. 학습 동기 부여가 필요할 수 있습니다.',
      priority: NotificationPriority.high,
      data: {
        'inactive_days': inactiveDays.toString(),
        'alert_type': 'low_activity',
      },
      actionUrl: '/dashboard',
    );
  }

  Future<String> sendReminderNotification({
    required String userId,
    String? parentId,
    required String reminderTitle,
    required String reminderBody,
    DateTime? scheduledFor,
  }) async {
    return await sendNotification(
      userId: userId,
      parentId: parentId,
      type: NotificationType.reminder,
      title: '⏰ $reminderTitle',
      body: reminderBody,
      priority: NotificationPriority.normal,
      scheduledFor: scheduledFor,
    );
  }

  // Scheduled notification methods
  Future<String> scheduleWeeklyReport({
    required String userId,
    String? parentId,
    DateTime? scheduleTime,
  }) async {
    final scheduledTime = scheduleTime ?? _getNextWeeklyReportTime();
    
    return await sendNotification(
      userId: userId,
      parentId: parentId,
      type: NotificationType.reminder,
      title: '📅 주간 리포트 생성 예정',
      body: '곧 주간 학습 리포트가 생성됩니다.',
      priority: NotificationPriority.low,
      scheduledFor: scheduledTime,
    );
  }

  Future<String> scheduleMonthlyReport({
    required String userId,
    String? parentId,
    DateTime? scheduleTime,
  }) async {
    final scheduledTime = scheduleTime ?? _getNextMonthlyReportTime();
    
    return await sendNotification(
      userId: userId,
      parentId: parentId,
      type: NotificationType.reminder,
      title: '📅 월간 리포트 생성 예정',
      body: '곧 월간 학습 리포트가 생성됩니다.',
      priority: NotificationPriority.low,
      scheduledFor: scheduledTime,
    );
  }

  Future<String> scheduleDailyReminder({
    required String userId,
    String? parentId,
    required String reminderText,
    TimeOfDay scheduleTime = const TimeOfDay(hour: 9, minute: 0),
  }) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day + 1, scheduleTime.hour, scheduleTime.minute);
    
    // If the time has passed today, schedule for tomorrow
    if (now.hour > scheduleTime.hour || 
        (now.hour == scheduleTime.hour && now.minute >= scheduleTime.minute)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    return await sendNotification(
      userId: userId,
      parentId: parentId,
      type: NotificationType.reminder,
      title: '🌅 일일 학습 알림',
      body: reminderText,
      priority: NotificationPriority.normal,
      scheduledFor: scheduledTime,
    );
  }

  DateTime _getNextWeeklyReportTime() {
    final now = DateTime.now();
    // Schedule for next Sunday at 20:00
    final daysUntilSunday = 7 - now.weekday;
    return DateTime(now.year, now.month, now.day + daysUntilSunday, 20, 0);
  }

  DateTime _getNextMonthlyReportTime() {
    final now = DateTime.now();
    // Schedule for last day of month at 20:00
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return DateTime(lastDayOfMonth.year, lastDayOfMonth.month, lastDayOfMonth.day, 20, 0);
  }

  // Query methods
  Future<List<PushNotification>> getNotifications(String userId, {int limit = 20}) async {
    return _notificationBox.values
        .where((notification) => notification.userId == userId || notification.parentId == userId)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt))
        ..take(limit).toList();
  }

  Future<List<PushNotification>> getUnreadNotifications(String userId) async {
    return _notificationBox.values
        .where((notification) => 
            (notification.userId == userId || notification.parentId == userId) && 
            !notification.isRead)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<PushNotification>> getNotificationsByType(String userId, NotificationType type) async {
    return _notificationBox.values
        .where((notification) => 
            (notification.userId == userId || notification.parentId == userId) && 
            notification.type == type)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<PushNotification>> getScheduledNotifications(String userId) async {
    final now = DateTime.now();
    return _notificationBox.values
        .where((notification) => 
            (notification.userId == userId || notification.parentId == userId) && 
            notification.scheduledFor != null &&
            notification.scheduledFor!.isAfter(now) &&
            !notification.isSent)
        .toList()
        ..sort((a, b) => a.scheduledFor!.compareTo(b.scheduledFor!));
  }

  Future<int> getUnreadCount(String userId) async {
    return _notificationBox.values
        .where((notification) => 
            (notification.userId == userId || notification.parentId == userId) && 
            !notification.isRead)
        .length;
  }

  // Update methods
  Future<void> markAsRead(String notificationId) async {
    final notification = _notificationBox.get(notificationId);
    if (notification != null && !notification.isRead) {
      final updatedNotification = notification.copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
      await _notificationBox.put(notificationId, updatedNotification);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    final unreadNotifications = await getUnreadNotifications(userId);
    for (final notification in unreadNotifications) {
      await markAsRead(notification.id);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notificationBox.delete(notificationId);
  }

  Future<void> cancelScheduledNotification(String notificationId) async {
    final notification = _notificationBox.get(notificationId);
    if (notification != null && notification.scheduledFor != null && !notification.isSent) {
      await _notificationBox.delete(notificationId);
    }
  }

  // Settings methods
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    await _settingsBox.put(settings.userId, settings);
  }

  Future<NotificationSettings?> getNotificationSettings(String userId) async {
    return _settingsBox.get(userId);
  }

  Future<NotificationSettings> getOrCreateNotificationSettings(String userId) async {
    final settings = await getNotificationSettings(userId);
    if (settings != null) return settings;
    
    // Create default settings
    final defaultSettings = NotificationSettings(
      userId: userId,
      pushEnabled: true,
      emailEnabled: true,
      smsEnabled: false,
      typePreferences: {
        NotificationType.progress: true,
        NotificationType.achievement: true,
        NotificationType.reminder: true,
        NotificationType.alert: true,
        NotificationType.report_ready: true,
        NotificationType.goal_achieved: true,
        NotificationType.streak_milestone: true,
        NotificationType.low_activity: true,
      },
      quietHours: ['22:00-07:00'],
      quietDays: [],
      language: 'ko',
      timezone: 'Asia/Seoul',
      updatedAt: DateTime.now(),
    );
    
    await updateNotificationSettings(defaultSettings);
    return defaultSettings;
  }

  // Bulk operations
  Future<void> sendBulkNotifications(List<Map<String, dynamic>> notifications) async {
    for (final notifData in notifications) {
      await sendNotification(
        userId: notifData['userId'],
        parentId: notifData['parentId'],
        type: notifData['type'],
        title: notifData['title'],
        body: notifData['body'],
        priority: notifData['priority'] ?? NotificationPriority.normal,
        data: notifData['data'],
        imageUrl: notifData['imageUrl'],
        actionUrl: notifData['actionUrl'],
        scheduledFor: notifData['scheduledFor'],
      );
    }
  }

  // Analytics and statistics
  Future<Map<String, dynamic>> getNotificationStats(String userId) async {
    final allNotifications = await getNotifications(userId, limit: 1000);
    final unreadCount = await getUnreadCount(userId);
    
    final typeStats = <NotificationType, int>{};
    for (final notification in allNotifications) {
      typeStats[notification.type] = (typeStats[notification.type] ?? 0) + 1;
    }
    
    final last7Days = DateTime.now().subtract(const Duration(days: 7));
    final recentCount = allNotifications
        .where((n) => n.createdAt.isAfter(last7Days))
        .length;
    
    return {
      'total_notifications': allNotifications.length,
      'unread_count': unreadCount,
      'recent_count_7days': recentCount,
      'type_breakdown': typeStats.map((key, value) => MapEntry(key.name, value)),
      'read_rate': allNotifications.isNotEmpty 
          ? ((allNotifications.length - unreadCount) / allNotifications.length * 100).round()
          : 0,
    };
  }

  // Cleanup methods
  Future<void> cleanupOldNotifications({int daysToKeep = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    final oldNotifications = _notificationBox.values
        .where((notification) => notification.createdAt.isBefore(cutoffDate))
        .toList();

    for (final notification in oldNotifications) {
      await _notificationBox.delete(notification.id);
    }
  }

  // Testing and demo methods
  Future<void> sendTestNotification(String userId, {String? parentId}) async {
    await sendNotification(
      userId: userId,
      parentId: parentId,
      type: NotificationType.progress,
      title: '🧪 테스트 알림',
      body: '알림 시스템이 정상적으로 작동합니다.',
      priority: NotificationPriority.low,
      data: {'test': true},
    );
  }

  Future<void> simulateRandomNotifications(String userId, {String? parentId, int count = 5}) async {
    final random = Random();
    final types = NotificationType.values;
    final titles = [
      '새로운 성취 달성! 🎉',
      '주간 리포트 준비 완료 📊',
      '학습 목표 달성 🎯',
      '연속 학습 기록! 🔥',
      '오늘의 학습 알림 📚',
    ];
    final bodies = [
      '축하합니다! 새로운 뱃지를 획득했습니다.',
      '이번 주 학습 리포트가 생성되었습니다.',
      '설정하신 학습 목표를 달성했습니다.',
      '7일 연속 학습을 완료했습니다!',
      '오늘도 즐거운 학습 시간을 가져보세요.',
    ];

    for (int i = 0; i < count; i++) {
      await Future.delayed(Duration(milliseconds: random.nextInt(1000)));
      
      await sendNotification(
        userId: userId,
        parentId: parentId,
        type: types[random.nextInt(types.length)],
        title: titles[random.nextInt(titles.length)],
        body: bodies[random.nextInt(bodies.length)],
        priority: NotificationPriority.values[random.nextInt(NotificationPriority.values.length)],
        data: {'demo': true, 'sequence': i},
      );
    }
  }
}

// Time of day class for scheduling
class TimeOfDay {
  final int hour;
  final int minute;
  
  const TimeOfDay({required this.hour, required this.minute});
}