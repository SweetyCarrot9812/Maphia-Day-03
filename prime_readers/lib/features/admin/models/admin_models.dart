import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_models.g.dart';

// System Analytics Models

@HiveType(typeId: 94)
@JsonSerializable()
class SystemMetrics {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime timestamp;
  
  @HiveField(2)
  final int totalUsers;
  
  @HiveField(3)
  final int activeUsers;
  
  @HiveField(4)
  final int totalSessions;
  
  @HiveField(5)
  final double averageSessionDuration;
  
  @HiveField(6)
  final int totalLessons;
  
  @HiveField(7)
  final int completedLessons;
  
  @HiveField(8)
  final double systemUptime;
  
  @HiveField(9)
  final double memoryUsage;
  
  @HiveField(10)
  final double cpuUsage;
  
  @HiveField(11)
  final double diskUsage;
  
  @HiveField(12)
  final Map<String, dynamic> metadata;

  const SystemMetrics({
    required this.id,
    required this.timestamp,
    required this.totalUsers,
    required this.activeUsers,
    required this.totalSessions,
    required this.averageSessionDuration,
    required this.totalLessons,
    required this.completedLessons,
    required this.systemUptime,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.diskUsage,
    this.metadata = const {},
  });

  factory SystemMetrics.fromJson(Map<String, dynamic> json) => _$SystemMetricsFromJson(json);
  Map<String, dynamic> toJson() => _$SystemMetricsToJson(this);

  SystemMetrics copyWith({
    String? id,
    DateTime? timestamp,
    int? totalUsers,
    int? activeUsers,
    int? totalSessions,
    double? averageSessionDuration,
    int? totalLessons,
    int? completedLessons,
    double? systemUptime,
    double? memoryUsage,
    double? cpuUsage,
    double? diskUsage,
    Map<String, dynamic>? metadata,
  }) {
    return SystemMetrics(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      totalUsers: totalUsers ?? this.totalUsers,
      activeUsers: activeUsers ?? this.activeUsers,
      totalSessions: totalSessions ?? this.totalSessions,
      averageSessionDuration: averageSessionDuration ?? this.averageSessionDuration,
      totalLessons: totalLessons ?? this.totalLessons,
      completedLessons: completedLessons ?? this.completedLessons,
      systemUptime: systemUptime ?? this.systemUptime,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      diskUsage: diskUsage ?? this.diskUsage,
      metadata: metadata ?? this.metadata,
    );
  }
}

@HiveType(typeId: 95)
enum UserRole {
  @HiveField(0)
  student,
  @HiveField(1)
  parent,
  @HiveField(2)
  teacher,
  @HiveField(3)
  admin,
  @HiveField(4)
  super_admin,
}

@HiveType(typeId: 96)
enum UserStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  inactive,
  @HiveField(2)
  suspended,
  @HiveField(3)
  pending,
  @HiveField(4)
  banned,
}

@HiveType(typeId: 97)
@JsonSerializable()
class AdminUser {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String email;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final UserRole role;
  
  @HiveField(4)
  final UserStatus status;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final DateTime? lastLoginAt;
  
  @HiveField(7)
  final String? phoneNumber;
  
  @HiveField(8)
  final String? profileImageUrl;
  
  @HiveField(9)
  final List<String> permissions;
  
  @HiveField(10)
  final Map<String, dynamic> metadata;
  
  @HiveField(11)
  final DateTime updatedAt;

  const AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    required this.createdAt,
    this.lastLoginAt,
    this.phoneNumber,
    this.profileImageUrl,
    this.permissions = const [],
    this.metadata = const {},
    required this.updatedAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => _$AdminUserFromJson(json);
  Map<String, dynamic> toJson() => _$AdminUserToJson(this);

  AdminUser copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? phoneNumber,
    String? profileImageUrl,
    List<String>? permissions,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      permissions: permissions ?? this.permissions,
      metadata: metadata ?? this.metadata,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@HiveType(typeId: 98)
enum SystemLogLevel {
  @HiveField(0)
  debug,
  @HiveField(1)
  info,
  @HiveField(2)
  warning,
  @HiveField(3)
  error,
  @HiveField(4)
  critical,
}

@HiveType(typeId: 99)
@JsonSerializable()
class SystemLog {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime timestamp;
  
  @HiveField(2)
  final SystemLogLevel level;
  
  @HiveField(3)
  final String category;
  
  @HiveField(4)
  final String message;
  
  @HiveField(5)
  final String? userId;
  
  @HiveField(6)
  final String? sessionId;
  
  @HiveField(7)
  final Map<String, dynamic> context;
  
  @HiveField(8)
  final String? stackTrace;

  const SystemLog({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.category,
    required this.message,
    this.userId,
    this.sessionId,
    this.context = const {},
    this.stackTrace,
  });

  factory SystemLog.fromJson(Map<String, dynamic> json) => _$SystemLogFromJson(json);
  Map<String, dynamic> toJson() => _$SystemLogToJson(this);

  SystemLog copyWith({
    String? id,
    DateTime? timestamp,
    SystemLogLevel? level,
    String? category,
    String? message,
    String? userId,
    String? sessionId,
    Map<String, dynamic>? context,
    String? stackTrace,
  }) {
    return SystemLog(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      level: level ?? this.level,
      category: category ?? this.category,
      message: message ?? this.message,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      context: context ?? this.context,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}

@HiveType(typeId: 100)
enum ConfigurationType {
  @HiveField(0)
  system,
  @HiveField(1)
  feature,
  @HiveField(2)
  ui,
  @HiveField(3)
  integration,
  @HiveField(4)
  security,
}

@HiveType(typeId: 101)
@JsonSerializable()
class SystemConfiguration {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String key;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final String description;
  
  @HiveField(4)
  final ConfigurationType type;
  
  @HiveField(5)
  final String value;
  
  @HiveField(6)
  final String defaultValue;
  
  @HiveField(7)
  final bool isEditable;
  
  @HiveField(8)
  final bool requiresRestart;
  
  @HiveField(9)
  final List<String> validValues;
  
  @HiveField(10)
  final Map<String, dynamic> metadata;
  
  @HiveField(11)
  final DateTime createdAt;
  
  @HiveField(12)
  final DateTime updatedAt;

  const SystemConfiguration({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    required this.defaultValue,
    required this.isEditable,
    required this.requiresRestart,
    this.validValues = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory SystemConfiguration.fromJson(Map<String, dynamic> json) => _$SystemConfigurationFromJson(json);
  Map<String, dynamic> toJson() => _$SystemConfigurationToJson(this);

  SystemConfiguration copyWith({
    String? id,
    String? key,
    String? name,
    String? description,
    ConfigurationType? type,
    String? value,
    String? defaultValue,
    bool? isEditable,
    bool? requiresRestart,
    List<String>? validValues,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SystemConfiguration(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      defaultValue: defaultValue ?? this.defaultValue,
      isEditable: isEditable ?? this.isEditable,
      requiresRestart: requiresRestart ?? this.requiresRestart,
      validValues: validValues ?? this.validValues,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@HiveType(typeId: 102)
@JsonSerializable()
class DashboardWidget {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String type; // 'metric', 'chart', 'list', 'alert'
  
  @HiveField(3)
  final int positionX;
  
  @HiveField(4)
  final int positionY;
  
  @HiveField(5)
  final int width;
  
  @HiveField(6)
  final int height;
  
  @HiveField(7)
  final Map<String, dynamic> config;
  
  @HiveField(8)
  final bool isVisible;
  
  @HiveField(9)
  final DateTime createdAt;
  
  @HiveField(10)
  final DateTime updatedAt;

  const DashboardWidget({
    required this.id,
    required this.title,
    required this.type,
    required this.positionX,
    required this.positionY,
    required this.width,
    required this.height,
    this.config = const {},
    required this.isVisible,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DashboardWidget.fromJson(Map<String, dynamic> json) => _$DashboardWidgetFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardWidgetToJson(this);

  DashboardWidget copyWith({
    String? id,
    String? title,
    String? type,
    int? positionX,
    int? positionY,
    int? width,
    int? height,
    Map<String, dynamic>? config,
    bool? isVisible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DashboardWidget(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      width: width ?? this.width,
      height: height ?? this.height,
      config: config ?? this.config,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}