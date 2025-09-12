import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_models.g.dart';

// Enums for parent report system
@HiveType(typeId: 60)
enum ReportType {
  @HiveField(0)
  weekly,
  @HiveField(1)
  monthly,
  @HiveField(2)
  progress,
  @HiveField(3)
  achievement,
  @HiveField(4)
  alert
}

@HiveType(typeId: 61)
enum NotificationPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  normal,
  @HiveField(2)
  high,
  @HiveField(3)
  urgent
}

@HiveType(typeId: 62)
enum NotificationType {
  @HiveField(0)
  progress,
  @HiveField(1)
  achievement,
  @HiveField(2)
  reminder,
  @HiveField(3)
  alert,
  @HiveField(4)
  report_ready,
  @HiveField(5)
  goal_achieved,
  @HiveField(6)
  streak_milestone,
  @HiveField(7)
  low_activity
}

@HiveType(typeId: 63)
enum ReportStatus {
  @HiveField(0)
  generating,
  @HiveField(1)
  ready,
  @HiveField(2)
  sent,
  @HiveField(3)
  viewed,
  @HiveField(4)
  archived
}

@HiveType(typeId: 64)
enum ActivityMetricType {
  @HiveField(0)
  reading_time,
  @HiveField(1)
  books_completed,
  @HiveField(2)
  quiz_scores,
  @HiveField(3)
  vocabulary_learned,
  @HiveField(4)
  speaking_practice,
  @HiveField(5)
  writing_exercises,
  @HiveField(6)
  attendance_rate,
  @HiveField(7)
  engagement_score
}

// Core data models
@HiveType(typeId: 65)
@JsonSerializable()
class ParentReport {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String studentId;
  
  @HiveField(2)
  final String parentId;
  
  @HiveField(3)
  final ReportType type;
  
  @HiveField(4)
  final DateTime periodStart;
  
  @HiveField(5)
  final DateTime periodEnd;
  
  @HiveField(6)
  final DateTime generatedAt;
  
  @HiveField(7)
  final ReportStatus status;
  
  @HiveField(8)
  final String title;
  
  @HiveField(9)
  final String summary;
  
  @HiveField(10)
  final List<ActivityMetric> metrics;
  
  @HiveField(11)
  final List<Achievement> achievements;
  
  @HiveField(12)
  final List<RecommendationItem> recommendations;
  
  @HiveField(13)
  final Map<String, dynamic> metadata;
  
  @HiveField(14)
  final DateTime? viewedAt;
  
  @HiveField(15)
  final bool isEmailed;

  const ParentReport({
    required this.id,
    required this.studentId,
    required this.parentId,
    required this.type,
    required this.periodStart,
    required this.periodEnd,
    required this.generatedAt,
    required this.status,
    required this.title,
    required this.summary,
    required this.metrics,
    required this.achievements,
    required this.recommendations,
    this.metadata = const {},
    this.viewedAt,
    this.isEmailed = false,
  });

  factory ParentReport.fromJson(Map<String, dynamic> json) => _$ParentReportFromJson(json);
  Map<String, dynamic> toJson() => _$ParentReportToJson(this);

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

@HiveType(typeId: 66)
@JsonSerializable()
class ActivityMetric {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final ActivityMetricType type;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final double currentValue;
  
  @HiveField(4)
  final double? previousValue;
  
  @HiveField(5)
  final double? targetValue;
  
  @HiveField(6)
  final String unit;
  
  @HiveField(7)
  final String description;
  
  @HiveField(8)
  final double? percentageChange;
  
  @HiveField(9)
  final bool isImprovement;
  
  @HiveField(10)
  final List<DataPoint> dataPoints;

  const ActivityMetric({
    required this.id,
    required this.type,
    required this.name,
    required this.currentValue,
    this.previousValue,
    this.targetValue,
    required this.unit,
    required this.description,
    this.percentageChange,
    required this.isImprovement,
    this.dataPoints = const [],
  });

  factory ActivityMetric.fromJson(Map<String, dynamic> json) => _$ActivityMetricFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityMetricToJson(this);
}

@HiveType(typeId: 67)
@JsonSerializable()
class DataPoint {
  @HiveField(0)
  final DateTime date;
  
  @HiveField(1)
  final double value;
  
  @HiveField(2)
  final String? label;

  const DataPoint({
    required this.date,
    required this.value,
    this.label,
  });

  factory DataPoint.fromJson(Map<String, dynamic> json) => _$DataPointFromJson(json);
  Map<String, dynamic> toJson() => _$DataPointToJson(this);
}

@HiveType(typeId: 68)
@JsonSerializable()
class Achievement {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String iconUrl;
  
  @HiveField(4)
  final DateTime achievedAt;
  
  @HiveField(5)
  final String category;
  
  @HiveField(6)
  final int points;
  
  @HiveField(7)
  final bool isNew;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.achievedAt,
    required this.category,
    required this.points,
    this.isNew = true,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementToJson(this);
}

@HiveType(typeId: 69)
@JsonSerializable()
class RecommendationItem {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String actionText;
  
  @HiveField(4)
  final String? actionUrl;
  
  @HiveField(5)
  final NotificationPriority priority;
  
  @HiveField(6)
  final String category;

  const RecommendationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.actionText,
    this.actionUrl,
    required this.priority,
    required this.category,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) => _$RecommendationItemFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationItemToJson(this);
}

@HiveType(typeId: 70)
@JsonSerializable()
class PushNotification {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String? parentId;
  
  @HiveField(3)
  final NotificationType type;
  
  @HiveField(4)
  final String title;
  
  @HiveField(5)
  final String body;
  
  @HiveField(6)
  final NotificationPriority priority;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final DateTime? scheduledFor;
  
  @HiveField(9)
  final DateTime? sentAt;
  
  @HiveField(10)
  final DateTime? readAt;
  
  @HiveField(11)
  final bool isRead;
  
  @HiveField(12)
  final bool isSent;
  
  @HiveField(13)
  final Map<String, dynamic> data;
  
  @HiveField(14)
  final String? imageUrl;
  
  @HiveField(15)
  final String? actionUrl;

  const PushNotification({
    required this.id,
    required this.userId,
    this.parentId,
    required this.type,
    required this.title,
    required this.body,
    required this.priority,
    required this.createdAt,
    this.scheduledFor,
    this.sentAt,
    this.readAt,
    this.isRead = false,
    this.isSent = false,
    this.data = const {},
    this.imageUrl,
    this.actionUrl,
  });

  factory PushNotification.fromJson(Map<String, dynamic> json) => _$PushNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$PushNotificationToJson(this);

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

@HiveType(typeId: 71)
@JsonSerializable()
class NotificationSettings {
  @HiveField(0)
  final String userId;
  
  @HiveField(1)
  final bool pushEnabled;
  
  @HiveField(2)
  final bool emailEnabled;
  
  @HiveField(3)
  final bool smsEnabled;
  
  @HiveField(4)
  final Map<NotificationType, bool> typePreferences;
  
  @HiveField(5)
  final List<String> quietHours; // Format: "HH:MM-HH:MM"
  
  @HiveField(6)
  final List<int> quietDays; // 1-7 for Monday-Sunday
  
  @HiveField(7)
  final String language;
  
  @HiveField(8)
  final String timezone;
  
  @HiveField(9)
  final DateTime updatedAt;

  const NotificationSettings({
    required this.userId,
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.smsEnabled = false,
    this.typePreferences = const {},
    this.quietHours = const [],
    this.quietDays = const [],
    this.language = 'ko',
    this.timezone = 'Asia/Seoul',
    required this.updatedAt,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) => _$NotificationSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationSettingsToJson(this);
}

@HiveType(typeId: 72)
@JsonSerializable()
class ParentProfile {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String email;
  
  @HiveField(3)
  final String? phoneNumber;
  
  @HiveField(4)
  final List<String> childrenIds;
  
  @HiveField(5)
  final NotificationSettings notificationSettings;
  
  @HiveField(6)
  final String preferredLanguage;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final DateTime lastLoginAt;
  
  @HiveField(9)
  final bool isActive;

  const ParentProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.childrenIds,
    required this.notificationSettings,
    this.preferredLanguage = 'ko',
    required this.createdAt,
    required this.lastLoginAt,
    this.isActive = true,
  });

  factory ParentProfile.fromJson(Map<String, dynamic> json) => _$ParentProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ParentProfileToJson(this);
}

