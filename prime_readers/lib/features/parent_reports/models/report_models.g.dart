// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParentReportAdapter extends TypeAdapter<ParentReport> {
  @override
  final int typeId = 65;

  @override
  ParentReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParentReport(
      id: fields[0] as String,
      studentId: fields[1] as String,
      parentId: fields[2] as String,
      type: fields[3] as ReportType,
      periodStart: fields[4] as DateTime,
      periodEnd: fields[5] as DateTime,
      generatedAt: fields[6] as DateTime,
      status: fields[7] as ReportStatus,
      title: fields[8] as String,
      summary: fields[9] as String,
      metrics: (fields[10] as List).cast<ActivityMetric>(),
      achievements: (fields[11] as List).cast<Achievement>(),
      recommendations: (fields[12] as List).cast<RecommendationItem>(),
      metadata: (fields[13] as Map).cast<String, dynamic>(),
      viewedAt: fields[14] as DateTime?,
      isEmailed: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ParentReport obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.parentId)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.periodStart)
      ..writeByte(5)
      ..write(obj.periodEnd)
      ..writeByte(6)
      ..write(obj.generatedAt)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.title)
      ..writeByte(9)
      ..write(obj.summary)
      ..writeByte(10)
      ..write(obj.metrics)
      ..writeByte(11)
      ..write(obj.achievements)
      ..writeByte(12)
      ..write(obj.recommendations)
      ..writeByte(13)
      ..write(obj.metadata)
      ..writeByte(14)
      ..write(obj.viewedAt)
      ..writeByte(15)
      ..write(obj.isEmailed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParentReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityMetricAdapter extends TypeAdapter<ActivityMetric> {
  @override
  final int typeId = 66;

  @override
  ActivityMetric read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityMetric(
      id: fields[0] as String,
      type: fields[1] as ActivityMetricType,
      name: fields[2] as String,
      currentValue: fields[3] as double,
      previousValue: fields[4] as double?,
      targetValue: fields[5] as double?,
      unit: fields[6] as String,
      description: fields[7] as String,
      percentageChange: fields[8] as double?,
      isImprovement: fields[9] as bool,
      dataPoints: (fields[10] as List).cast<DataPoint>(),
    );
  }

  @override
  void write(BinaryWriter writer, ActivityMetric obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.currentValue)
      ..writeByte(4)
      ..write(obj.previousValue)
      ..writeByte(5)
      ..write(obj.targetValue)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.percentageChange)
      ..writeByte(9)
      ..write(obj.isImprovement)
      ..writeByte(10)
      ..write(obj.dataPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityMetricAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DataPointAdapter extends TypeAdapter<DataPoint> {
  @override
  final int typeId = 67;

  @override
  DataPoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataPoint(
      date: fields[0] as DateTime,
      value: fields[1] as double,
      label: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DataPoint obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.label);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataPointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AchievementAdapter extends TypeAdapter<Achievement> {
  @override
  final int typeId = 68;

  @override
  Achievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Achievement(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      iconUrl: fields[3] as String,
      achievedAt: fields[4] as DateTime,
      category: fields[5] as String,
      points: fields[6] as int,
      isNew: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Achievement obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconUrl)
      ..writeByte(4)
      ..write(obj.achievedAt)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.points)
      ..writeByte(7)
      ..write(obj.isNew);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecommendationItemAdapter extends TypeAdapter<RecommendationItem> {
  @override
  final int typeId = 69;

  @override
  RecommendationItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecommendationItem(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      actionText: fields[3] as String,
      actionUrl: fields[4] as String?,
      priority: fields[5] as NotificationPriority,
      category: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RecommendationItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.actionText)
      ..writeByte(4)
      ..write(obj.actionUrl)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendationItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PushNotificationAdapter extends TypeAdapter<PushNotification> {
  @override
  final int typeId = 70;

  @override
  PushNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PushNotification(
      id: fields[0] as String,
      userId: fields[1] as String,
      parentId: fields[2] as String?,
      type: fields[3] as NotificationType,
      title: fields[4] as String,
      body: fields[5] as String,
      priority: fields[6] as NotificationPriority,
      createdAt: fields[7] as DateTime,
      scheduledFor: fields[8] as DateTime?,
      sentAt: fields[9] as DateTime?,
      readAt: fields[10] as DateTime?,
      isRead: fields[11] as bool,
      isSent: fields[12] as bool,
      data: (fields[13] as Map).cast<String, dynamic>(),
      imageUrl: fields[14] as String?,
      actionUrl: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PushNotification obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.parentId)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.body)
      ..writeByte(6)
      ..write(obj.priority)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.scheduledFor)
      ..writeByte(9)
      ..write(obj.sentAt)
      ..writeByte(10)
      ..write(obj.readAt)
      ..writeByte(11)
      ..write(obj.isRead)
      ..writeByte(12)
      ..write(obj.isSent)
      ..writeByte(13)
      ..write(obj.data)
      ..writeByte(14)
      ..write(obj.imageUrl)
      ..writeByte(15)
      ..write(obj.actionUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PushNotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationSettingsAdapter extends TypeAdapter<NotificationSettings> {
  @override
  final int typeId = 71;

  @override
  NotificationSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSettings(
      userId: fields[0] as String,
      pushEnabled: fields[1] as bool,
      emailEnabled: fields[2] as bool,
      smsEnabled: fields[3] as bool,
      typePreferences: (fields[4] as Map).cast<NotificationType, bool>(),
      quietHours: (fields[5] as List).cast<String>(),
      quietDays: (fields[6] as List).cast<int>(),
      language: fields[7] as String,
      timezone: fields[8] as String,
      updatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSettings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.pushEnabled)
      ..writeByte(2)
      ..write(obj.emailEnabled)
      ..writeByte(3)
      ..write(obj.smsEnabled)
      ..writeByte(4)
      ..write(obj.typePreferences)
      ..writeByte(5)
      ..write(obj.quietHours)
      ..writeByte(6)
      ..write(obj.quietDays)
      ..writeByte(7)
      ..write(obj.language)
      ..writeByte(8)
      ..write(obj.timezone)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ParentProfileAdapter extends TypeAdapter<ParentProfile> {
  @override
  final int typeId = 72;

  @override
  ParentProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParentProfile(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      phoneNumber: fields[3] as String?,
      childrenIds: (fields[4] as List).cast<String>(),
      notificationSettings: fields[5] as NotificationSettings,
      preferredLanguage: fields[6] as String,
      createdAt: fields[7] as DateTime,
      lastLoginAt: fields[8] as DateTime,
      isActive: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ParentProfile obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.childrenIds)
      ..writeByte(5)
      ..write(obj.notificationSettings)
      ..writeByte(6)
      ..write(obj.preferredLanguage)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.lastLoginAt)
      ..writeByte(9)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParentProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReportTypeAdapter extends TypeAdapter<ReportType> {
  @override
  final int typeId = 60;

  @override
  ReportType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReportType.weekly;
      case 1:
        return ReportType.monthly;
      case 2:
        return ReportType.progress;
      case 3:
        return ReportType.achievement;
      case 4:
        return ReportType.alert;
      default:
        return ReportType.weekly;
    }
  }

  @override
  void write(BinaryWriter writer, ReportType obj) {
    switch (obj) {
      case ReportType.weekly:
        writer.writeByte(0);
        break;
      case ReportType.monthly:
        writer.writeByte(1);
        break;
      case ReportType.progress:
        writer.writeByte(2);
        break;
      case ReportType.achievement:
        writer.writeByte(3);
        break;
      case ReportType.alert:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationPriorityAdapter extends TypeAdapter<NotificationPriority> {
  @override
  final int typeId = 61;

  @override
  NotificationPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationPriority.low;
      case 1:
        return NotificationPriority.normal;
      case 2:
        return NotificationPriority.high;
      case 3:
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationPriority obj) {
    switch (obj) {
      case NotificationPriority.low:
        writer.writeByte(0);
        break;
      case NotificationPriority.normal:
        writer.writeByte(1);
        break;
      case NotificationPriority.high:
        writer.writeByte(2);
        break;
      case NotificationPriority.urgent:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationTypeAdapter extends TypeAdapter<NotificationType> {
  @override
  final int typeId = 62;

  @override
  NotificationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationType.progress;
      case 1:
        return NotificationType.achievement;
      case 2:
        return NotificationType.reminder;
      case 3:
        return NotificationType.alert;
      case 4:
        return NotificationType.report_ready;
      case 5:
        return NotificationType.goal_achieved;
      case 6:
        return NotificationType.streak_milestone;
      case 7:
        return NotificationType.low_activity;
      default:
        return NotificationType.progress;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationType obj) {
    switch (obj) {
      case NotificationType.progress:
        writer.writeByte(0);
        break;
      case NotificationType.achievement:
        writer.writeByte(1);
        break;
      case NotificationType.reminder:
        writer.writeByte(2);
        break;
      case NotificationType.alert:
        writer.writeByte(3);
        break;
      case NotificationType.report_ready:
        writer.writeByte(4);
        break;
      case NotificationType.goal_achieved:
        writer.writeByte(5);
        break;
      case NotificationType.streak_milestone:
        writer.writeByte(6);
        break;
      case NotificationType.low_activity:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReportStatusAdapter extends TypeAdapter<ReportStatus> {
  @override
  final int typeId = 63;

  @override
  ReportStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReportStatus.generating;
      case 1:
        return ReportStatus.ready;
      case 2:
        return ReportStatus.sent;
      case 3:
        return ReportStatus.viewed;
      case 4:
        return ReportStatus.archived;
      default:
        return ReportStatus.generating;
    }
  }

  @override
  void write(BinaryWriter writer, ReportStatus obj) {
    switch (obj) {
      case ReportStatus.generating:
        writer.writeByte(0);
        break;
      case ReportStatus.ready:
        writer.writeByte(1);
        break;
      case ReportStatus.sent:
        writer.writeByte(2);
        break;
      case ReportStatus.viewed:
        writer.writeByte(3);
        break;
      case ReportStatus.archived:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityMetricTypeAdapter extends TypeAdapter<ActivityMetricType> {
  @override
  final int typeId = 64;

  @override
  ActivityMetricType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityMetricType.reading_time;
      case 1:
        return ActivityMetricType.books_completed;
      case 2:
        return ActivityMetricType.quiz_scores;
      case 3:
        return ActivityMetricType.vocabulary_learned;
      case 4:
        return ActivityMetricType.speaking_practice;
      case 5:
        return ActivityMetricType.writing_exercises;
      case 6:
        return ActivityMetricType.attendance_rate;
      case 7:
        return ActivityMetricType.engagement_score;
      default:
        return ActivityMetricType.reading_time;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityMetricType obj) {
    switch (obj) {
      case ActivityMetricType.reading_time:
        writer.writeByte(0);
        break;
      case ActivityMetricType.books_completed:
        writer.writeByte(1);
        break;
      case ActivityMetricType.quiz_scores:
        writer.writeByte(2);
        break;
      case ActivityMetricType.vocabulary_learned:
        writer.writeByte(3);
        break;
      case ActivityMetricType.speaking_practice:
        writer.writeByte(4);
        break;
      case ActivityMetricType.writing_exercises:
        writer.writeByte(5);
        break;
      case ActivityMetricType.attendance_rate:
        writer.writeByte(6);
        break;
      case ActivityMetricType.engagement_score:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityMetricTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParentReport _$ParentReportFromJson(Map<String, dynamic> json) => ParentReport(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      parentId: json['parentId'] as String,
      type: $enumDecode(_$ReportTypeEnumMap, json['type']),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      status: $enumDecode(_$ReportStatusEnumMap, json['status']),
      title: json['title'] as String,
      summary: json['summary'] as String,
      metrics: (json['metrics'] as List<dynamic>)
          .map((e) => ActivityMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
      achievements: (json['achievements'] as List<dynamic>)
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => RecommendationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      viewedAt: json['viewedAt'] == null
          ? null
          : DateTime.parse(json['viewedAt'] as String),
      isEmailed: json['isEmailed'] as bool? ?? false,
    );

Map<String, dynamic> _$ParentReportToJson(ParentReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'parentId': instance.parentId,
      'type': _$ReportTypeEnumMap[instance.type]!,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'generatedAt': instance.generatedAt.toIso8601String(),
      'status': _$ReportStatusEnumMap[instance.status]!,
      'title': instance.title,
      'summary': instance.summary,
      'metrics': instance.metrics,
      'achievements': instance.achievements,
      'recommendations': instance.recommendations,
      'metadata': instance.metadata,
      'viewedAt': instance.viewedAt?.toIso8601String(),
      'isEmailed': instance.isEmailed,
    };

const _$ReportTypeEnumMap = {
  ReportType.weekly: 'weekly',
  ReportType.monthly: 'monthly',
  ReportType.progress: 'progress',
  ReportType.achievement: 'achievement',
  ReportType.alert: 'alert',
};

const _$ReportStatusEnumMap = {
  ReportStatus.generating: 'generating',
  ReportStatus.ready: 'ready',
  ReportStatus.sent: 'sent',
  ReportStatus.viewed: 'viewed',
  ReportStatus.archived: 'archived',
};

ActivityMetric _$ActivityMetricFromJson(Map<String, dynamic> json) =>
    ActivityMetric(
      id: json['id'] as String,
      type: $enumDecode(_$ActivityMetricTypeEnumMap, json['type']),
      name: json['name'] as String,
      currentValue: (json['currentValue'] as num).toDouble(),
      previousValue: (json['previousValue'] as num?)?.toDouble(),
      targetValue: (json['targetValue'] as num?)?.toDouble(),
      unit: json['unit'] as String,
      description: json['description'] as String,
      percentageChange: (json['percentageChange'] as num?)?.toDouble(),
      isImprovement: json['isImprovement'] as bool,
      dataPoints: (json['dataPoints'] as List<dynamic>?)
              ?.map((e) => DataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ActivityMetricToJson(ActivityMetric instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ActivityMetricTypeEnumMap[instance.type]!,
      'name': instance.name,
      'currentValue': instance.currentValue,
      'previousValue': instance.previousValue,
      'targetValue': instance.targetValue,
      'unit': instance.unit,
      'description': instance.description,
      'percentageChange': instance.percentageChange,
      'isImprovement': instance.isImprovement,
      'dataPoints': instance.dataPoints,
    };

const _$ActivityMetricTypeEnumMap = {
  ActivityMetricType.reading_time: 'reading_time',
  ActivityMetricType.books_completed: 'books_completed',
  ActivityMetricType.quiz_scores: 'quiz_scores',
  ActivityMetricType.vocabulary_learned: 'vocabulary_learned',
  ActivityMetricType.speaking_practice: 'speaking_practice',
  ActivityMetricType.writing_exercises: 'writing_exercises',
  ActivityMetricType.attendance_rate: 'attendance_rate',
  ActivityMetricType.engagement_score: 'engagement_score',
};

DataPoint _$DataPointFromJson(Map<String, dynamic> json) => DataPoint(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
      label: json['label'] as String?,
    );

Map<String, dynamic> _$DataPointToJson(DataPoint instance) => <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'value': instance.value,
      'label': instance.label,
    };

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      achievedAt: DateTime.parse(json['achievedAt'] as String),
      category: json['category'] as String,
      points: (json['points'] as num).toInt(),
      isNew: json['isNew'] as bool? ?? true,
    );

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'achievedAt': instance.achievedAt.toIso8601String(),
      'category': instance.category,
      'points': instance.points,
      'isNew': instance.isNew,
    };

RecommendationItem _$RecommendationItemFromJson(Map<String, dynamic> json) =>
    RecommendationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      actionText: json['actionText'] as String,
      actionUrl: json['actionUrl'] as String?,
      priority: $enumDecode(_$NotificationPriorityEnumMap, json['priority']),
      category: json['category'] as String,
    );

Map<String, dynamic> _$RecommendationItemToJson(RecommendationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'actionText': instance.actionText,
      'actionUrl': instance.actionUrl,
      'priority': _$NotificationPriorityEnumMap[instance.priority]!,
      'category': instance.category,
    };

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.normal: 'normal',
  NotificationPriority.high: 'high',
  NotificationPriority.urgent: 'urgent',
};

PushNotification _$PushNotificationFromJson(Map<String, dynamic> json) =>
    PushNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      parentId: json['parentId'] as String?,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      title: json['title'] as String,
      body: json['body'] as String,
      priority: $enumDecode(_$NotificationPriorityEnumMap, json['priority']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledFor: json['scheduledFor'] == null
          ? null
          : DateTime.parse(json['scheduledFor'] as String),
      sentAt: json['sentAt'] == null
          ? null
          : DateTime.parse(json['sentAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      isSent: json['isSent'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>? ?? const {},
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
    );

Map<String, dynamic> _$PushNotificationToJson(PushNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'parentId': instance.parentId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'body': instance.body,
      'priority': _$NotificationPriorityEnumMap[instance.priority]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'scheduledFor': instance.scheduledFor?.toIso8601String(),
      'sentAt': instance.sentAt?.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
      'isRead': instance.isRead,
      'isSent': instance.isSent,
      'data': instance.data,
      'imageUrl': instance.imageUrl,
      'actionUrl': instance.actionUrl,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.progress: 'progress',
  NotificationType.achievement: 'achievement',
  NotificationType.reminder: 'reminder',
  NotificationType.alert: 'alert',
  NotificationType.report_ready: 'report_ready',
  NotificationType.goal_achieved: 'goal_achieved',
  NotificationType.streak_milestone: 'streak_milestone',
  NotificationType.low_activity: 'low_activity',
};

NotificationSettings _$NotificationSettingsFromJson(
        Map<String, dynamic> json) =>
    NotificationSettings(
      userId: json['userId'] as String,
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      emailEnabled: json['emailEnabled'] as bool? ?? true,
      smsEnabled: json['smsEnabled'] as bool? ?? false,
      typePreferences: (json['typePreferences'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry($enumDecode(_$NotificationTypeEnumMap, k), e as bool),
          ) ??
          const {},
      quietHours: (json['quietHours'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      quietDays: (json['quietDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      language: json['language'] as String? ?? 'ko',
      timezone: json['timezone'] as String? ?? 'Asia/Seoul',
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$NotificationSettingsToJson(
        NotificationSettings instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'pushEnabled': instance.pushEnabled,
      'emailEnabled': instance.emailEnabled,
      'smsEnabled': instance.smsEnabled,
      'typePreferences': instance.typePreferences
          .map((k, e) => MapEntry(_$NotificationTypeEnumMap[k]!, e)),
      'quietHours': instance.quietHours,
      'quietDays': instance.quietDays,
      'language': instance.language,
      'timezone': instance.timezone,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

ParentProfile _$ParentProfileFromJson(Map<String, dynamic> json) =>
    ParentProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      childrenIds: (json['childrenIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      notificationSettings: NotificationSettings.fromJson(
          json['notificationSettings'] as Map<String, dynamic>),
      preferredLanguage: json['preferredLanguage'] as String? ?? 'ko',
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$ParentProfileToJson(ParentProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'childrenIds': instance.childrenIds,
      'notificationSettings': instance.notificationSettings,
      'preferredLanguage': instance.preferredLanguage,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt.toIso8601String(),
      'isActive': instance.isActive,
    };
