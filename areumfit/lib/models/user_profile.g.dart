// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deviceId: json['deviceId'] as String,
      conflicted: json['conflicted'] as bool? ?? false,
      name: json['name'] as String,
      sex: $enumDecode(_$SexEnumMap, json['sex']),
      heightCm: (json['heightCm'] as num).toInt(),
      weightKg: (json['weightKg'] as num).toDouble(),
      unit: $enumDecodeNullable(_$WeightUnitEnumMap, json['unit']) ??
          WeightUnit.kg,
      injuries: (json['injuries'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      preferredDays: (json['preferredDays'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      equipment: (json['equipment'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      rpeMin: (json['rpeMin'] as num?)?.toInt() ?? 6,
      rpeMax: (json['rpeMax'] as num?)?.toInt() ?? 9,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deviceId': instance.deviceId,
      'conflicted': instance.conflicted,
      'name': instance.name,
      'sex': _$SexEnumMap[instance.sex]!,
      'heightCm': instance.heightCm,
      'weightKg': instance.weightKg,
      'unit': _$WeightUnitEnumMap[instance.unit]!,
      'injuries': instance.injuries,
      'preferredDays': instance.preferredDays,
      'equipment': instance.equipment,
      'rpeMin': instance.rpeMin,
      'rpeMax': instance.rpeMax,
    };

const _$SexEnumMap = {
  Sex.male: 'male',
  Sex.female: 'female',
  Sex.other: 'other',
};

const _$WeightUnitEnumMap = {
  WeightUnit.kg: 'kg',
  WeightUnit.lbs: 'lbs',
};

_$UserMetricsImpl _$$UserMetricsImplFromJson(Map<String, dynamic> json) =>
    _$UserMetricsImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deviceId: json['deviceId'] as String,
      conflicted: json['conflicted'] as bool? ?? false,
      oneRM: (json['oneRM'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const <String, double>{},
      fatigueScore: (json['fatigueScore'] as num?)?.toInt() ?? 5,
      sleepHours: (json['sleepHours'] as num?)?.toDouble() ?? 8.0,
      lastPRAt: json['lastPRAt'] == null
          ? null
          : DateTime.parse(json['lastPRAt'] as String),
    );

Map<String, dynamic> _$$UserMetricsImplToJson(_$UserMetricsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deviceId': instance.deviceId,
      'conflicted': instance.conflicted,
      'oneRM': instance.oneRM,
      'fatigueScore': instance.fatigueScore,
      'sleepHours': instance.sleepHours,
      'lastPRAt': instance.lastPRAt?.toIso8601String(),
    };

_$UserWorkoutStatsImpl _$$UserWorkoutStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$UserWorkoutStatsImpl(
      userId: json['userId'] as String,
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      completedSessions: (json['completedSessions'] as num?)?.toInt() ?? 0,
      thisWeekSessions: (json['thisWeekSessions'] as num?)?.toInt() ?? 0,
      thisMonthSessions: (json['thisMonthSessions'] as num?)?.toInt() ?? 0,
      averageRPE: (json['averageRPE'] as num?)?.toDouble() ?? 0.0,
      totalMinutes: (json['totalMinutes'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      lastSessionAt: json['lastSessionAt'] == null
          ? null
          : DateTime.parse(json['lastSessionAt'] as String),
      bestLifts: (json['bestLifts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const <String, double>{},
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$$UserWorkoutStatsImplToJson(
        _$UserWorkoutStatsImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'totalSessions': instance.totalSessions,
      'completedSessions': instance.completedSessions,
      'thisWeekSessions': instance.thisWeekSessions,
      'thisMonthSessions': instance.thisMonthSessions,
      'averageRPE': instance.averageRPE,
      'totalMinutes': instance.totalMinutes,
      'longestStreak': instance.longestStreak,
      'currentStreak': instance.currentStreak,
      'lastSessionAt': instance.lastSessionAt?.toIso8601String(),
      'bestLifts': instance.bestLifts,
      'achievements': instance.achievements,
    };

_$RRuleImpl _$$RRuleImplFromJson(Map<String, dynamic> json) => _$RRuleImpl(
      byWeekday: (json['byWeekday'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      weeks: (json['weeks'] as num?)?.toInt() ?? 4,
      timeOfDay: $enumDecodeNullable(_$TimeOfDayEnumMap, json['timeOfDay']),
    );

Map<String, dynamic> _$$RRuleImplToJson(_$RRuleImpl instance) =>
    <String, dynamic>{
      'byWeekday': instance.byWeekday,
      'weeks': instance.weeks,
      'timeOfDay': _$TimeOfDayEnumMap[instance.timeOfDay],
    };

const _$TimeOfDayEnumMap = {
  TimeOfDay.am: 'AM',
  TimeOfDay.pm: 'PM',
};
