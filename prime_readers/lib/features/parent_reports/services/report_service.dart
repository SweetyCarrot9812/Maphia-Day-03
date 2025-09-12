import 'dart:convert';
import 'dart:math';
import 'package:hive/hive.dart';
import '../models/report_models.dart';
import '../../attendance/models/attendance_model.dart';
import '../../vocabulary/models/vocabulary_model.dart';
import '../../reading/models/reading_models.dart';
import '../../speaking/models/speaking_models.dart';
import '../../writing/models/writing_models.dart';

class ReportService {
  late Box<ParentReport> _reportBox;
  late Box<PushNotification> _notificationBox;
  late Box<ParentProfile> _parentBox;
  late Box<NotificationSettings> _settingsBox;

  // Sample parent profiles for demo
  static final List<ParentProfile> _sampleParents = [
    ParentProfile(
      id: 'parent1',
      name: '김민수',
      email: 'minsu.kim@example.com',
      phoneNumber: '+82-10-1234-5678',
      childrenIds: ['student1', 'student2'],
      notificationSettings: NotificationSettings(
        userId: 'parent1',
        pushEnabled: true,
        emailEnabled: true,
        smsEnabled: false,
        typePreferences: {
          NotificationType.progress: true,
          NotificationType.achievement: true,
          NotificationType.report_ready: true,
          NotificationType.goal_achieved: true,
          NotificationType.streak_milestone: true,
          NotificationType.low_activity: true,
          NotificationType.reminder: false,
          NotificationType.alert: true,
        },
        quietHours: ['22:00-06:00'],
        quietDays: [7], // Sunday
        language: 'ko',
        timezone: 'Asia/Seoul',
        updatedAt: DateTime.now(),
      ),
      preferredLanguage: 'ko',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
      isActive: true,
    ),
    ParentProfile(
      id: 'parent2',
      name: '이영희',
      email: 'younghee.lee@example.com',
      phoneNumber: '+82-10-9876-5432',
      childrenIds: ['student3'],
      notificationSettings: NotificationSettings(
        userId: 'parent2',
        pushEnabled: true,
        emailEnabled: true,
        smsEnabled: true,
        typePreferences: {
          NotificationType.progress: true,
          NotificationType.achievement: true,
          NotificationType.report_ready: true,
          NotificationType.goal_achieved: true,
          NotificationType.streak_milestone: false,
          NotificationType.low_activity: true,
          NotificationType.reminder: true,
          NotificationType.alert: true,
        },
        quietHours: ['23:00-07:00'],
        quietDays: [],
        language: 'ko',
        timezone: 'Asia/Seoul',
        updatedAt: DateTime.now(),
      ),
      preferredLanguage: 'ko',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      lastLoginAt: DateTime.now().subtract(const Duration(minutes: 30)),
      isActive: true,
    ),
  ];

  Future<void> initialize() async {
    _reportBox = await Hive.openBox<ParentReport>('parent_reports');
    _notificationBox = await Hive.openBox<PushNotification>('push_notifications');
    _parentBox = await Hive.openBox<ParentProfile>('parent_profiles');
    _settingsBox = await Hive.openBox<NotificationSettings>('notification_settings');

    // Initialize with sample data if empty
    if (_parentBox.isEmpty) {
      await _addSampleData();
    }
  }

  Future<void> _addSampleData() async {
    for (final parent in _sampleParents) {
      await _parentBox.put(parent.id, parent);
      await _settingsBox.put(parent.id, parent.notificationSettings);
    }

    // Generate sample reports
    await _generateSampleReports();
  }

  Future<void> _generateSampleReports() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));

    // Weekly report for student1
    final weeklyReport = ParentReport(
      id: 'report_weekly_1',
      studentId: 'student1',
      parentId: 'parent1',
      type: ReportType.weekly,
      periodStart: weekAgo,
      periodEnd: now,
      generatedAt: now,
      status: ReportStatus.ready,
      title: '주간 학습 리포트',
      summary: '이번 주 학습 활동이 매우 활발했습니다. 독서량이 지난 주 대비 25% 증가했고, 새로운 성취를 달성했습니다.',
      metrics: [
        ActivityMetric(
          id: 'reading_time_1',
          type: ActivityMetricType.reading_time,
          name: '독서 시간',
          currentValue: 420.0, // minutes
          previousValue: 336.0,
          targetValue: 500.0,
          unit: '분',
          description: '이번 주 총 독서 시간',
          percentageChange: 25.0,
          isImprovement: true,
          dataPoints: [
            DataPoint(date: weekAgo, value: 60.0, label: '월'),
            DataPoint(date: weekAgo.add(Duration(days: 1)), value: 45.0, label: '화'),
            DataPoint(date: weekAgo.add(Duration(days: 2)), value: 75.0, label: '수'),
            DataPoint(date: weekAgo.add(Duration(days: 3)), value: 90.0, label: '목'),
            DataPoint(date: weekAgo.add(Duration(days: 4)), value: 50.0, label: '금'),
            DataPoint(date: weekAgo.add(Duration(days: 5)), value: 65.0, label: '토'),
            DataPoint(date: weekAgo.add(Duration(days: 6)), value: 35.0, label: '일'),
          ],
        ),
        ActivityMetric(
          id: 'books_completed_1',
          type: ActivityMetricType.books_completed,
          name: '완독 도서',
          currentValue: 3.0,
          previousValue: 2.0,
          targetValue: 4.0,
          unit: '권',
          description: '이번 주 완독한 도서 수',
          percentageChange: 50.0,
          isImprovement: true,
          dataPoints: [],
        ),
        ActivityMetric(
          id: 'quiz_scores_1',
          type: ActivityMetricType.quiz_scores,
          name: '퀴즈 평균 점수',
          currentValue: 87.5,
          previousValue: 82.0,
          targetValue: 90.0,
          unit: '점',
          description: '이번 주 퀴즈 평균 점수',
          percentageChange: 6.7,
          isImprovement: true,
          dataPoints: [],
        ),
        ActivityMetric(
          id: 'vocabulary_learned_1',
          type: ActivityMetricType.vocabulary_learned,
          name: '새 단어 학습',
          currentValue: 45.0,
          previousValue: 38.0,
          targetValue: 50.0,
          unit: '개',
          description: '이번 주 새로 학습한 단어 수',
          percentageChange: 18.4,
          isImprovement: true,
          dataPoints: [],
        ),
      ],
      achievements: [
        Achievement(
          id: 'achievement_1',
          title: '독서왕',
          description: '일주일 동안 3권 이상 완독하기',
          iconUrl: 'assets/icons/reading_champion.png',
          achievedAt: now.subtract(const Duration(days: 1)),
          category: '독서',
          points: 100,
          isNew: true,
        ),
        Achievement(
          id: 'achievement_2',
          title: '꾸준한 학습자',
          description: '7일 연속 학습 활동하기',
          iconUrl: 'assets/icons/consistent_learner.png',
          achievedAt: now,
          category: '출석',
          points: 150,
          isNew: true,
        ),
      ],
      recommendations: [
        RecommendationItem(
          id: 'rec_1',
          title: '독서 목표 상향 조정',
          description: '현재 독서 능력이 목표를 초과하고 있어 더 도전적인 목표 설정을 권장합니다.',
          actionText: '목표 조정하기',
          actionUrl: '/goals/reading',
          priority: NotificationPriority.normal,
          category: '학습 계획',
        ),
        RecommendationItem(
          id: 'rec_2',
          title: '고급 독서 자료 추천',
          description: '현재 수준보다 한 단계 높은 AR 레벨의 도서를 추천드립니다.',
          actionText: '도서 둘러보기',
          actionUrl: '/books/recommended',
          priority: NotificationPriority.low,
          category: '독서 자료',
        ),
      ],
      metadata: {
        'total_activities': 28,
        'engagement_score': 92.5,
        'improvement_areas': ['수학', '과학'],
        'strength_areas': ['독서', '어휘'],
      },
      isEmailed: false,
    );

    await _reportBox.put(weeklyReport.id, weeklyReport);

    // Monthly report for student1
    final monthlyReport = ParentReport(
      id: 'report_monthly_1',
      studentId: 'student1',
      parentId: 'parent1',
      type: ReportType.monthly,
      periodStart: monthAgo,
      periodEnd: now,
      generatedAt: now.subtract(const Duration(days: 1)),
      status: ReportStatus.ready,
      title: '월간 학습 리포트',
      summary: '지난 한 달간 전반적으로 우수한 학습 성과를 보였습니다. 특히 독서와 어휘 영역에서 두드러진 향상을 보였습니다.',
      metrics: [
        ActivityMetric(
          id: 'reading_time_monthly',
          type: ActivityMetricType.reading_time,
          name: '독서 시간',
          currentValue: 1680.0, // minutes
          previousValue: 1200.0,
          targetValue: 2000.0,
          unit: '분',
          description: '지난 한 달 총 독서 시간',
          percentageChange: 40.0,
          isImprovement: true,
          dataPoints: [],
        ),
        ActivityMetric(
          id: 'books_completed_monthly',
          type: ActivityMetricType.books_completed,
          name: '완독 도서',
          currentValue: 12.0,
          previousValue: 8.0,
          targetValue: 15.0,
          unit: '권',
          description: '지난 한 달 완독한 도서 수',
          percentageChange: 50.0,
          isImprovement: true,
          dataPoints: [],
        ),
        ActivityMetric(
          id: 'attendance_rate_monthly',
          type: ActivityMetricType.attendance_rate,
          name: '출석률',
          currentValue: 93.3,
          previousValue: 86.7,
          targetValue: 95.0,
          unit: '%',
          description: '지난 한 달 출석률',
          percentageChange: 7.6,
          isImprovement: true,
          dataPoints: [],
        ),
      ],
      achievements: [
        Achievement(
          id: 'achievement_monthly_1',
          title: '월간 독서 마스터',
          description: '한 달 동안 10권 이상 완독하기',
          iconUrl: 'assets/icons/reading_master.png',
          achievedAt: now.subtract(const Duration(days: 3)),
          category: '독서',
          points: 500,
          isNew: false,
        ),
      ],
      recommendations: [
        RecommendationItem(
          id: 'rec_monthly_1',
          title: '도전적인 독서 목표',
          description: '다음 달에는 더 어려운 수준의 도서에 도전해보세요.',
          actionText: '목표 설정하기',
          actionUrl: '/goals/monthly',
          priority: NotificationPriority.normal,
          category: '학습 계획',
        ),
      ],
      metadata: {
        'total_activities': 120,
        'engagement_score': 89.2,
        'grade_trend': 'improving',
        'parent_involvement_score': 85.0,
      },
      isEmailed: true,
    );

    await _reportBox.put(monthlyReport.id, monthlyReport);
  }

  // Report generation methods
  Future<ParentReport> generateWeeklyReport(String studentId, String parentId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final metrics = await _calculateWeeklyMetrics(studentId, weekAgo, now);
    final achievements = await _getRecentAchievements(studentId, weekAgo, now);
    final recommendations = await _generateRecommendations(studentId, metrics);

    final report = ParentReport(
      id: 'report_weekly_${studentId}_${now.millisecondsSinceEpoch}',
      studentId: studentId,
      parentId: parentId,
      type: ReportType.weekly,
      periodStart: weekAgo,
      periodEnd: now,
      generatedAt: now,
      status: ReportStatus.generating,
      title: '주간 학습 리포트',
      summary: _generateSummary(metrics, achievements),
      metrics: metrics,
      achievements: achievements,
      recommendations: recommendations,
      metadata: await _generateMetadata(studentId, weekAgo, now),
      isEmailed: false,
    );

    await _reportBox.put(report.id, report);
    
    // Update status to ready
    final updatedReport = report.copyWith(status: ReportStatus.ready);
    await _reportBox.put(report.id, updatedReport);

    // Send notification
    await _sendReportReadyNotification(report);

    return updatedReport;
  }

  Future<ParentReport> generateMonthlyReport(String studentId, String parentId) async {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    
    final metrics = await _calculateMonthlyMetrics(studentId, monthAgo, now);
    final achievements = await _getRecentAchievements(studentId, monthAgo, now);
    final recommendations = await _generateRecommendations(studentId, metrics);

    final report = ParentReport(
      id: 'report_monthly_${studentId}_${now.millisecondsSinceEpoch}',
      studentId: studentId,
      parentId: parentId,
      type: ReportType.monthly,
      periodStart: monthAgo,
      periodEnd: now,
      generatedAt: now,
      status: ReportStatus.generating,
      title: '월간 학습 리포트',
      summary: _generateSummary(metrics, achievements),
      metrics: metrics,
      achievements: achievements,
      recommendations: recommendations,
      metadata: await _generateMetadata(studentId, monthAgo, now),
      isEmailed: false,
    );

    await _reportBox.put(report.id, report);
    
    // Update status to ready
    final updatedReport = report.copyWith(status: ReportStatus.ready);
    await _reportBox.put(report.id, updatedReport);

    // Send notification
    await _sendReportReadyNotification(report);

    return updatedReport;
  }

  Future<List<ActivityMetric>> _calculateWeeklyMetrics(String studentId, DateTime start, DateTime end) async {
    // In a real app, this would query actual user data
    // For demo purposes, we'll generate realistic sample data
    final random = Random();
    
    return [
      ActivityMetric(
        id: 'reading_time_${DateTime.now().millisecondsSinceEpoch}',
        type: ActivityMetricType.reading_time,
        name: '독서 시간',
        currentValue: 300.0 + random.nextDouble() * 200.0,
        previousValue: 250.0 + random.nextDouble() * 150.0,
        targetValue: 500.0,
        unit: '분',
        description: '주간 총 독서 시간',
        percentageChange: random.nextDouble() * 40.0 - 10.0, // -10% to +30%
        isImprovement: random.nextBool(),
        dataPoints: _generateWeeklyDataPoints(start, end),
      ),
      ActivityMetric(
        id: 'quiz_scores_${DateTime.now().millisecondsSinceEpoch}',
        type: ActivityMetricType.quiz_scores,
        name: '퀴즈 평균 점수',
        currentValue: 75.0 + random.nextDouble() * 20.0,
        previousValue: 70.0 + random.nextDouble() * 20.0,
        targetValue: 90.0,
        unit: '점',
        description: '주간 퀴즈 평균 점수',
        percentageChange: random.nextDouble() * 20.0 - 5.0,
        isImprovement: random.nextBool(),
        dataPoints: [],
      ),
      ActivityMetric(
        id: 'vocabulary_${DateTime.now().millisecondsSinceEpoch}',
        type: ActivityMetricType.vocabulary_learned,
        name: '새 단어 학습',
        currentValue: (20.0 + random.nextDouble() * 30.0).roundToDouble(),
        previousValue: (15.0 + random.nextDouble() * 25.0).roundToDouble(),
        targetValue: 50.0,
        unit: '개',
        description: '주간 새로 학습한 단어 수',
        percentageChange: random.nextDouble() * 30.0,
        isImprovement: true,
        dataPoints: [],
      ),
    ];
  }

  Future<List<ActivityMetric>> _calculateMonthlyMetrics(String studentId, DateTime start, DateTime end) async {
    final random = Random();
    
    return [
      ActivityMetric(
        id: 'reading_time_monthly_${DateTime.now().millisecondsSinceEpoch}',
        type: ActivityMetricType.reading_time,
        name: '독서 시간',
        currentValue: 1200.0 + random.nextDouble() * 800.0,
        previousValue: 1000.0 + random.nextDouble() * 600.0,
        targetValue: 2000.0,
        unit: '분',
        description: '월간 총 독서 시간',
        percentageChange: random.nextDouble() * 50.0,
        isImprovement: true,
        dataPoints: [],
      ),
      ActivityMetric(
        id: 'books_completed_monthly_${DateTime.now().millisecondsSinceEpoch}',
        type: ActivityMetricType.books_completed,
        name: '완독 도서',
        currentValue: (8.0 + random.nextDouble() * 8.0).roundToDouble(),
        previousValue: (5.0 + random.nextDouble() * 6.0).roundToDouble(),
        targetValue: 15.0,
        unit: '권',
        description: '월간 완독한 도서 수',
        percentageChange: random.nextDouble() * 60.0,
        isImprovement: true,
        dataPoints: [],
      ),
      ActivityMetric(
        id: 'engagement_monthly_${DateTime.now().millisecondsSinceEpoch}',
        type: ActivityMetricType.engagement_score,
        name: '참여도 점수',
        currentValue: 80.0 + random.nextDouble() * 15.0,
        previousValue: 75.0 + random.nextDouble() * 15.0,
        targetValue: 95.0,
        unit: '점',
        description: '월간 학습 참여도 점수',
        percentageChange: random.nextDouble() * 15.0,
        isImprovement: true,
        dataPoints: [],
      ),
    ];
  }

  List<DataPoint> _generateWeeklyDataPoints(DateTime start, DateTime end) {
    final points = <DataPoint>[];
    final random = Random();
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    
    for (int i = 0; i < 7; i++) {
      points.add(DataPoint(
        date: start.add(Duration(days: i)),
        value: 20.0 + random.nextDouble() * 80.0,
        label: days[i],
      ));
    }
    
    return points;
  }

  Future<List<Achievement>> _getRecentAchievements(String studentId, DateTime start, DateTime end) async {
    final random = Random();
    final achievements = <Achievement>[];
    
    // Simulate some achievements
    if (random.nextBool()) {
      achievements.add(Achievement(
        id: 'achievement_${DateTime.now().millisecondsSinceEpoch}',
        title: '독서 열정가',
        description: '연속 3일간 독서 목표 달성',
        iconUrl: 'assets/icons/reading_enthusiast.png',
        achievedAt: start.add(Duration(days: random.nextInt(7))),
        category: '독서',
        points: 50 + random.nextInt(100),
        isNew: true,
      ));
    }
    
    if (random.nextBool()) {
      achievements.add(Achievement(
        id: 'achievement_vocab_${DateTime.now().millisecondsSinceEpoch}',
        title: '단어 마스터',
        description: '새 단어 50개 학습 달성',
        iconUrl: 'assets/icons/vocabulary_master.png',
        achievedAt: start.add(Duration(days: random.nextInt(7))),
        category: '어휘',
        points: 75 + random.nextInt(75),
        isNew: true,
      ));
    }
    
    return achievements;
  }

  Future<List<RecommendationItem>> _generateRecommendations(String studentId, List<ActivityMetric> metrics) async {
    final recommendations = <RecommendationItem>[];
    
    // Analyze metrics to generate relevant recommendations
    for (final metric in metrics) {
      if (metric.currentValue < metric.targetValue! * 0.7) {
        // Below 70% of target
        recommendations.add(RecommendationItem(
          id: 'rec_${metric.id}',
          title: '${metric.name} 향상 필요',
          description: '현재 ${metric.name}이 목표치보다 낮습니다. 더 집중적인 학습이 필요합니다.',
          actionText: '학습 계획 보기',
          actionUrl: '/goals/${metric.type.name}',
          priority: NotificationPriority.high,
          category: '학습 개선',
        ));
      } else if (metric.currentValue > metric.targetValue! * 0.9) {
        // Above 90% of target
        recommendations.add(RecommendationItem(
          id: 'rec_${metric.id}',
          title: '${metric.name} 목표 상향 조정',
          description: '목표에 거의 도달했습니다. 더 높은 목표에 도전해보세요.',
          actionText: '목표 수정하기',
          actionUrl: '/goals/${metric.type.name}',
          priority: NotificationPriority.normal,
          category: '목표 설정',
        ));
      }
    }
    
    return recommendations;
  }

  String _generateSummary(List<ActivityMetric> metrics, List<Achievement> achievements) {
    final improvementCount = metrics.where((m) => m.isImprovement).length;
    final achievementCount = achievements.length;
    
    if (improvementCount >= metrics.length * 0.7 && achievementCount > 0) {
      return '이번 기간 동안 전반적으로 우수한 학습 성과를 보였습니다. ${achievementCount}개의 새로운 성취를 달성했고, 대부분 영역에서 향상을 보였습니다.';
    } else if (improvementCount >= metrics.length * 0.5) {
      return '이번 기간 동안 양호한 학습 활동을 보였습니다. 일부 영역에서 개선이 필요하지만 전반적으로 긍정적인 추세입니다.';
    } else {
      return '이번 기간 동안 학습 활동이 다소 저조했습니다. 더 집중적인 학습과 목표 달성을 위한 노력이 필요합니다.';
    }
  }

  Future<Map<String, dynamic>> _generateMetadata(String studentId, DateTime start, DateTime end) async {
    final random = Random();
    
    return {
      'total_activities': 20 + random.nextInt(50),
      'engagement_score': 60.0 + random.nextDouble() * 35.0,
      'improvement_areas': ['수학', '과학', '작문'].where((_) => random.nextBool()).toList(),
      'strength_areas': ['독서', '어휘', '출석'].where((_) => random.nextBool()).toList(),
      'parent_involvement_score': 70.0 + random.nextDouble() * 25.0,
      'recommendation_count': random.nextInt(5) + 1,
    };
  }

  // Notification methods
  Future<void> _sendReportReadyNotification(ParentReport report) async {
    final notification = PushNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: report.studentId,
      parentId: report.parentId,
      type: NotificationType.report_ready,
      title: '새로운 학습 리포트가 준비되었습니다',
      body: '${report.title}이 생성되어 확인하실 수 있습니다.',
      priority: NotificationPriority.normal,
      createdAt: DateTime.now(),
      data: {
        'report_id': report.id,
        'report_type': report.type.name,
        'student_id': report.studentId,
      },
      actionUrl: '/reports/${report.id}',
    );

    await _notificationBox.put(notification.id, notification);
  }

  Future<void> sendAchievementNotification(String studentId, String parentId, Achievement achievement) async {
    final notification = PushNotification(
      id: 'notif_achievement_${DateTime.now().millisecondsSinceEpoch}',
      userId: studentId,
      parentId: parentId,
      type: NotificationType.achievement,
      title: '새로운 성취를 달성했습니다! 🎉',
      body: '${achievement.title}: ${achievement.description}',
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
      data: {
        'achievement_id': achievement.id,
        'student_id': studentId,
        'points': achievement.points.toString(),
      },
      imageUrl: achievement.iconUrl,
      actionUrl: '/achievements/${achievement.id}',
    );

    await _notificationBox.put(notification.id, notification);
  }

  Future<void> sendProgressNotification(String studentId, String parentId, String title, String body, {Map<String, dynamic>? data}) async {
    final notification = PushNotification(
      id: 'notif_progress_${DateTime.now().millisecondsSinceEpoch}',
      userId: studentId,
      parentId: parentId,
      type: NotificationType.progress,
      title: title,
      body: body,
      priority: NotificationPriority.normal,
      createdAt: DateTime.now(),
      data: data ?? {},
    );

    await _notificationBox.put(notification.id, notification);
  }

  Future<void> sendLowActivityAlert(String studentId, String parentId) async {
    final notification = PushNotification(
      id: 'notif_low_activity_${DateTime.now().millisecondsSinceEpoch}',
      userId: studentId,
      parentId: parentId,
      type: NotificationType.low_activity,
      title: '학습 활동 부족 알림',
      body: '최근 3일간 학습 활동이 평소보다 현저히 적습니다. 학습 동기 부여가 필요할 수 있습니다.',
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
      data: {
        'student_id': studentId,
        'alert_type': 'low_activity',
        'days_inactive': '3',
      },
      actionUrl: '/dashboard/student/$studentId',
    );

    await _notificationBox.put(notification.id, notification);
  }

  // Query methods
  Future<List<ParentReport>> getReportsForParent(String parentId) async {
    return _reportBox.values
        .where((report) => report.parentId == parentId)
        .toList()
        ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
  }

  Future<List<ParentReport>> getReportsForStudent(String studentId) async {
    return _reportBox.values
        .where((report) => report.studentId == studentId)
        .toList()
        ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
  }

  Future<ParentReport?> getReport(String reportId) async {
    return _reportBox.get(reportId);
  }

  Future<List<PushNotification>> getNotificationsForUser(String userId) async {
    return _notificationBox.values
        .where((notification) => notification.userId == userId || notification.parentId == userId)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<PushNotification>> getUnreadNotifications(String userId) async {
    return _notificationBox.values
        .where((notification) => 
            (notification.userId == userId || notification.parentId == userId) && 
            !notification.isRead)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<ParentProfile?> getParentProfile(String parentId) async {
    return _parentBox.get(parentId);
  }

  Future<NotificationSettings?> getNotificationSettings(String userId) async {
    return _settingsBox.get(userId);
  }

  // Update methods
  Future<void> markReportAsViewed(String reportId) async {
    final report = _reportBox.get(reportId);
    if (report != null) {
      final updatedReport = report.copyWith(
        status: ReportStatus.viewed,
        viewedAt: DateTime.now(),
      );
      await _reportBox.put(reportId, updatedReport);
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final notification = _notificationBox.get(notificationId);
    if (notification != null) {
      final updatedNotification = notification.copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
      await _notificationBox.put(notificationId, updatedNotification);
    }
  }

  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    await _settingsBox.put(settings.userId, settings);
  }

  // Cleanup methods
  Future<void> cleanupOldReports() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
    final oldReports = _reportBox.values
        .where((report) => report.generatedAt.isBefore(cutoffDate))
        .toList();

    for (final report in oldReports) {
      await _reportBox.delete(report.id);
    }
  }

  Future<void> cleanupOldNotifications() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    final oldNotifications = _notificationBox.values
        .where((notification) => notification.createdAt.isBefore(cutoffDate))
        .toList();

    for (final notification in oldNotifications) {
      await _notificationBox.delete(notification.id);
    }
  }

  // Statistics methods
  Future<Map<String, dynamic>> getReportStats(String parentId) async {
    final reports = await getReportsForParent(parentId);
    
    return {
      'total_reports': reports.length,
      'weekly_reports': reports.where((r) => r.type == ReportType.weekly).length,
      'monthly_reports': reports.where((r) => r.type == ReportType.monthly).length,
      'unviewed_reports': reports.where((r) => r.status != ReportStatus.viewed).length,
      'last_report_date': reports.isNotEmpty ? reports.first.generatedAt : null,
    };
  }

  Future<Map<String, dynamic>> getNotificationStats(String userId) async {
    final notifications = await getNotificationsForUser(userId);
    final unread = await getUnreadNotifications(userId);
    
    return {
      'total_notifications': notifications.length,
      'unread_count': unread.length,
      'achievement_notifications': notifications.where((n) => n.type == NotificationType.achievement).length,
      'report_notifications': notifications.where((n) => n.type == NotificationType.report_ready).length,
      'alert_notifications': notifications.where((n) => n.type == NotificationType.alert).length,
    };
  }
}

// Extension for ParentReport to add copyWith method
extension ParentReportExtension on ParentReport {
  ParentReport copyWith({
    String? id,
    String? studentId,
    String? parentId,
    ReportType? type,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? generatedAt,
    ReportStatus? status,
    String? title,
    String? summary,
    List<ActivityMetric>? metrics,
    List<Achievement>? achievements,
    List<RecommendationItem>? recommendations,
    Map<String, dynamic>? metadata,
    DateTime? viewedAt,
    bool? isEmailed,
  }) {
    return ParentReport(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      parentId: parentId ?? this.parentId,
      type: type ?? this.type,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      generatedAt: generatedAt ?? this.generatedAt,
      status: status ?? this.status,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      metrics: metrics ?? this.metrics,
      achievements: achievements ?? this.achievements,
      recommendations: recommendations ?? this.recommendations,
      metadata: metadata ?? this.metadata,
      viewedAt: viewedAt ?? this.viewedAt,
      isEmailed: isEmailed ?? this.isEmailed,
    );
  }
}

// Extension for PushNotification to add copyWith method
extension PushNotificationExtension on PushNotification {
  PushNotification copyWith({
    String? id,
    String? userId,
    String? parentId,
    NotificationType? type,
    String? title,
    String? body,
    NotificationPriority? priority,
    DateTime? createdAt,
    DateTime? scheduledFor,
    DateTime? sentAt,
    DateTime? readAt,
    bool? isRead,
    bool? isSent,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
  }) {
    return PushNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      parentId: parentId ?? this.parentId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}