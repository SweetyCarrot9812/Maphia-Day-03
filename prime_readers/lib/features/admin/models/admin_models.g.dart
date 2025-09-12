// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SystemMetricsAdapter extends TypeAdapter<SystemMetrics> {
  @override
  final int typeId = 94;

  @override
  SystemMetrics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SystemMetrics(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      totalUsers: fields[2] as int,
      activeUsers: fields[3] as int,
      totalSessions: fields[4] as int,
      averageSessionDuration: fields[5] as double,
      totalLessons: fields[6] as int,
      completedLessons: fields[7] as int,
      systemUptime: fields[8] as double,
      memoryUsage: fields[9] as double,
      cpuUsage: fields[10] as double,
      diskUsage: fields[11] as double,
      metadata: (fields[12] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, SystemMetrics obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.totalUsers)
      ..writeByte(3)
      ..write(obj.activeUsers)
      ..writeByte(4)
      ..write(obj.totalSessions)
      ..writeByte(5)
      ..write(obj.averageSessionDuration)
      ..writeByte(6)
      ..write(obj.totalLessons)
      ..writeByte(7)
      ..write(obj.completedLessons)
      ..writeByte(8)
      ..write(obj.systemUptime)
      ..writeByte(9)
      ..write(obj.memoryUsage)
      ..writeByte(10)
      ..write(obj.cpuUsage)
      ..writeByte(11)
      ..write(obj.diskUsage)
      ..writeByte(12)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemMetricsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdminUserAdapter extends TypeAdapter<AdminUser> {
  @override
  final int typeId = 97;

  @override
  AdminUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdminUser(
      id: fields[0] as String,
      email: fields[1] as String,
      name: fields[2] as String,
      role: fields[3] as UserRole,
      status: fields[4] as UserStatus,
      createdAt: fields[5] as DateTime,
      lastLoginAt: fields[6] as DateTime?,
      phoneNumber: fields[7] as String?,
      profileImageUrl: fields[8] as String?,
      permissions: (fields[9] as List).cast<String>(),
      metadata: (fields[10] as Map).cast<String, dynamic>(),
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AdminUser obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.lastLoginAt)
      ..writeByte(7)
      ..write(obj.phoneNumber)
      ..writeByte(8)
      ..write(obj.profileImageUrl)
      ..writeByte(9)
      ..write(obj.permissions)
      ..writeByte(10)
      ..write(obj.metadata)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SystemLogAdapter extends TypeAdapter<SystemLog> {
  @override
  final int typeId = 99;

  @override
  SystemLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SystemLog(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      level: fields[2] as SystemLogLevel,
      category: fields[3] as String,
      message: fields[4] as String,
      userId: fields[5] as String?,
      sessionId: fields[6] as String?,
      context: (fields[7] as Map).cast<String, dynamic>(),
      stackTrace: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SystemLog obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.message)
      ..writeByte(5)
      ..write(obj.userId)
      ..writeByte(6)
      ..write(obj.sessionId)
      ..writeByte(7)
      ..write(obj.context)
      ..writeByte(8)
      ..write(obj.stackTrace);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SystemConfigurationAdapter extends TypeAdapter<SystemConfiguration> {
  @override
  final int typeId = 101;

  @override
  SystemConfiguration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SystemConfiguration(
      id: fields[0] as String,
      key: fields[1] as String,
      name: fields[2] as String,
      description: fields[3] as String,
      type: fields[4] as ConfigurationType,
      value: fields[5] as String,
      defaultValue: fields[6] as String,
      isEditable: fields[7] as bool,
      requiresRestart: fields[8] as bool,
      validValues: (fields[9] as List).cast<String>(),
      metadata: (fields[10] as Map).cast<String, dynamic>(),
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SystemConfiguration obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.key)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.value)
      ..writeByte(6)
      ..write(obj.defaultValue)
      ..writeByte(7)
      ..write(obj.isEditable)
      ..writeByte(8)
      ..write(obj.requiresRestart)
      ..writeByte(9)
      ..write(obj.validValues)
      ..writeByte(10)
      ..write(obj.metadata)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemConfigurationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DashboardWidgetAdapter extends TypeAdapter<DashboardWidget> {
  @override
  final int typeId = 102;

  @override
  DashboardWidget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DashboardWidget(
      id: fields[0] as String,
      title: fields[1] as String,
      type: fields[2] as String,
      positionX: fields[3] as int,
      positionY: fields[4] as int,
      width: fields[5] as int,
      height: fields[6] as int,
      config: (fields[7] as Map).cast<String, dynamic>(),
      isVisible: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DashboardWidget obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.positionX)
      ..writeByte(4)
      ..write(obj.positionY)
      ..writeByte(5)
      ..write(obj.width)
      ..writeByte(6)
      ..write(obj.height)
      ..writeByte(7)
      ..write(obj.config)
      ..writeByte(8)
      ..write(obj.isVisible)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardWidgetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserRoleAdapter extends TypeAdapter<UserRole> {
  @override
  final int typeId = 95;

  @override
  UserRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserRole.student;
      case 1:
        return UserRole.parent;
      case 2:
        return UserRole.teacher;
      case 3:
        return UserRole.admin;
      case 4:
        return UserRole.super_admin;
      default:
        return UserRole.student;
    }
  }

  @override
  void write(BinaryWriter writer, UserRole obj) {
    switch (obj) {
      case UserRole.student:
        writer.writeByte(0);
        break;
      case UserRole.parent:
        writer.writeByte(1);
        break;
      case UserRole.teacher:
        writer.writeByte(2);
        break;
      case UserRole.admin:
        writer.writeByte(3);
        break;
      case UserRole.super_admin:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserStatusAdapter extends TypeAdapter<UserStatus> {
  @override
  final int typeId = 96;

  @override
  UserStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserStatus.active;
      case 1:
        return UserStatus.inactive;
      case 2:
        return UserStatus.suspended;
      case 3:
        return UserStatus.pending;
      case 4:
        return UserStatus.banned;
      default:
        return UserStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, UserStatus obj) {
    switch (obj) {
      case UserStatus.active:
        writer.writeByte(0);
        break;
      case UserStatus.inactive:
        writer.writeByte(1);
        break;
      case UserStatus.suspended:
        writer.writeByte(2);
        break;
      case UserStatus.pending:
        writer.writeByte(3);
        break;
      case UserStatus.banned:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SystemLogLevelAdapter extends TypeAdapter<SystemLogLevel> {
  @override
  final int typeId = 98;

  @override
  SystemLogLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SystemLogLevel.debug;
      case 1:
        return SystemLogLevel.info;
      case 2:
        return SystemLogLevel.warning;
      case 3:
        return SystemLogLevel.error;
      case 4:
        return SystemLogLevel.critical;
      default:
        return SystemLogLevel.debug;
    }
  }

  @override
  void write(BinaryWriter writer, SystemLogLevel obj) {
    switch (obj) {
      case SystemLogLevel.debug:
        writer.writeByte(0);
        break;
      case SystemLogLevel.info:
        writer.writeByte(1);
        break;
      case SystemLogLevel.warning:
        writer.writeByte(2);
        break;
      case SystemLogLevel.error:
        writer.writeByte(3);
        break;
      case SystemLogLevel.critical:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemLogLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConfigurationTypeAdapter extends TypeAdapter<ConfigurationType> {
  @override
  final int typeId = 100;

  @override
  ConfigurationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ConfigurationType.system;
      case 1:
        return ConfigurationType.feature;
      case 2:
        return ConfigurationType.ui;
      case 3:
        return ConfigurationType.integration;
      case 4:
        return ConfigurationType.security;
      default:
        return ConfigurationType.system;
    }
  }

  @override
  void write(BinaryWriter writer, ConfigurationType obj) {
    switch (obj) {
      case ConfigurationType.system:
        writer.writeByte(0);
        break;
      case ConfigurationType.feature:
        writer.writeByte(1);
        break;
      case ConfigurationType.ui:
        writer.writeByte(2);
        break;
      case ConfigurationType.integration:
        writer.writeByte(3);
        break;
      case ConfigurationType.security:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigurationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemMetrics _$SystemMetricsFromJson(Map<String, dynamic> json) =>
    SystemMetrics(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      totalUsers: (json['totalUsers'] as num).toInt(),
      activeUsers: (json['activeUsers'] as num).toInt(),
      totalSessions: (json['totalSessions'] as num).toInt(),
      averageSessionDuration:
          (json['averageSessionDuration'] as num).toDouble(),
      totalLessons: (json['totalLessons'] as num).toInt(),
      completedLessons: (json['completedLessons'] as num).toInt(),
      systemUptime: (json['systemUptime'] as num).toDouble(),
      memoryUsage: (json['memoryUsage'] as num).toDouble(),
      cpuUsage: (json['cpuUsage'] as num).toDouble(),
      diskUsage: (json['diskUsage'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$SystemMetricsToJson(SystemMetrics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'totalUsers': instance.totalUsers,
      'activeUsers': instance.activeUsers,
      'totalSessions': instance.totalSessions,
      'averageSessionDuration': instance.averageSessionDuration,
      'totalLessons': instance.totalLessons,
      'completedLessons': instance.completedLessons,
      'systemUptime': instance.systemUptime,
      'memoryUsage': instance.memoryUsage,
      'cpuUsage': instance.cpuUsage,
      'diskUsage': instance.diskUsage,
      'metadata': instance.metadata,
    };

AdminUser _$AdminUserFromJson(Map<String, dynamic> json) => AdminUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      status: $enumDecode(_$UserStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      phoneNumber: json['phoneNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AdminUserToJson(AdminUser instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'role': _$UserRoleEnumMap[instance.role]!,
      'status': _$UserStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'phoneNumber': instance.phoneNumber,
      'profileImageUrl': instance.profileImageUrl,
      'permissions': instance.permissions,
      'metadata': instance.metadata,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.student: 'student',
  UserRole.parent: 'parent',
  UserRole.teacher: 'teacher',
  UserRole.admin: 'admin',
  UserRole.super_admin: 'super_admin',
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.inactive: 'inactive',
  UserStatus.suspended: 'suspended',
  UserStatus.pending: 'pending',
  UserStatus.banned: 'banned',
};

SystemLog _$SystemLogFromJson(Map<String, dynamic> json) => SystemLog(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: $enumDecode(_$SystemLogLevelEnumMap, json['level']),
      category: json['category'] as String,
      message: json['message'] as String,
      userId: json['userId'] as String?,
      sessionId: json['sessionId'] as String?,
      context: json['context'] as Map<String, dynamic>? ?? const {},
      stackTrace: json['stackTrace'] as String?,
    );

Map<String, dynamic> _$SystemLogToJson(SystemLog instance) => <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'level': _$SystemLogLevelEnumMap[instance.level]!,
      'category': instance.category,
      'message': instance.message,
      'userId': instance.userId,
      'sessionId': instance.sessionId,
      'context': instance.context,
      'stackTrace': instance.stackTrace,
    };

const _$SystemLogLevelEnumMap = {
  SystemLogLevel.debug: 'debug',
  SystemLogLevel.info: 'info',
  SystemLogLevel.warning: 'warning',
  SystemLogLevel.error: 'error',
  SystemLogLevel.critical: 'critical',
};

SystemConfiguration _$SystemConfigurationFromJson(Map<String, dynamic> json) =>
    SystemConfiguration(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$ConfigurationTypeEnumMap, json['type']),
      value: json['value'] as String,
      defaultValue: json['defaultValue'] as String,
      isEditable: json['isEditable'] as bool,
      requiresRestart: json['requiresRestart'] as bool,
      validValues: (json['validValues'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SystemConfigurationToJson(
        SystemConfiguration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'name': instance.name,
      'description': instance.description,
      'type': _$ConfigurationTypeEnumMap[instance.type]!,
      'value': instance.value,
      'defaultValue': instance.defaultValue,
      'isEditable': instance.isEditable,
      'requiresRestart': instance.requiresRestart,
      'validValues': instance.validValues,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ConfigurationTypeEnumMap = {
  ConfigurationType.system: 'system',
  ConfigurationType.feature: 'feature',
  ConfigurationType.ui: 'ui',
  ConfigurationType.integration: 'integration',
  ConfigurationType.security: 'security',
};

DashboardWidget _$DashboardWidgetFromJson(Map<String, dynamic> json) =>
    DashboardWidget(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      positionX: (json['positionX'] as num).toInt(),
      positionY: (json['positionY'] as num).toInt(),
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      config: json['config'] as Map<String, dynamic>? ?? const {},
      isVisible: json['isVisible'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DashboardWidgetToJson(DashboardWidget instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': instance.type,
      'positionX': instance.positionX,
      'positionY': instance.positionY,
      'width': instance.width,
      'height': instance.height,
      'config': instance.config,
      'isVisible': instance.isVisible,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
