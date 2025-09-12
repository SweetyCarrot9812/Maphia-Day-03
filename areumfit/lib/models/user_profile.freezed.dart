// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  bool get conflicted =>
      throw _privateConstructorUsedError; // Profile specific fields
  String get name => throw _privateConstructorUsedError;
  Sex get sex => throw _privateConstructorUsedError;
  int get heightCm => throw _privateConstructorUsedError;
  double get weightKg => throw _privateConstructorUsedError;
  WeightUnit get unit => throw _privateConstructorUsedError;
  List<String> get injuries => throw _privateConstructorUsedError;
  List<String> get preferredDays => throw _privateConstructorUsedError;
  List<String> get equipment => throw _privateConstructorUsedError;
  int get rpeMin => throw _privateConstructorUsedError;
  int get rpeMax => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      DateTime updatedAt,
      String deviceId,
      bool conflicted,
      String name,
      Sex sex,
      int heightCm,
      double weightKg,
      WeightUnit unit,
      List<String> injuries,
      List<String> preferredDays,
      List<String> equipment,
      int rpeMin,
      int rpeMax});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deviceId = null,
    Object? conflicted = null,
    Object? name = null,
    Object? sex = null,
    Object? heightCm = null,
    Object? weightKg = null,
    Object? unit = null,
    Object? injuries = null,
    Object? preferredDays = null,
    Object? equipment = null,
    Object? rpeMin = null,
    Object? rpeMax = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      conflicted: null == conflicted
          ? _value.conflicted
          : conflicted // ignore: cast_nullable_to_non_nullable
              as bool,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sex: null == sex
          ? _value.sex
          : sex // ignore: cast_nullable_to_non_nullable
              as Sex,
      heightCm: null == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as int,
      weightKg: null == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as WeightUnit,
      injuries: null == injuries
          ? _value.injuries
          : injuries // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredDays: null == preferredDays
          ? _value.preferredDays
          : preferredDays // ignore: cast_nullable_to_non_nullable
              as List<String>,
      equipment: null == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rpeMin: null == rpeMin
          ? _value.rpeMin
          : rpeMin // ignore: cast_nullable_to_non_nullable
              as int,
      rpeMax: null == rpeMax
          ? _value.rpeMax
          : rpeMax // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      DateTime updatedAt,
      String deviceId,
      bool conflicted,
      String name,
      Sex sex,
      int heightCm,
      double weightKg,
      WeightUnit unit,
      List<String> injuries,
      List<String> preferredDays,
      List<String> equipment,
      int rpeMin,
      int rpeMax});
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deviceId = null,
    Object? conflicted = null,
    Object? name = null,
    Object? sex = null,
    Object? heightCm = null,
    Object? weightKg = null,
    Object? unit = null,
    Object? injuries = null,
    Object? preferredDays = null,
    Object? equipment = null,
    Object? rpeMin = null,
    Object? rpeMax = null,
  }) {
    return _then(_$UserProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      conflicted: null == conflicted
          ? _value.conflicted
          : conflicted // ignore: cast_nullable_to_non_nullable
              as bool,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sex: null == sex
          ? _value.sex
          : sex // ignore: cast_nullable_to_non_nullable
              as Sex,
      heightCm: null == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as int,
      weightKg: null == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as WeightUnit,
      injuries: null == injuries
          ? _value._injuries
          : injuries // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredDays: null == preferredDays
          ? _value._preferredDays
          : preferredDays // ignore: cast_nullable_to_non_nullable
              as List<String>,
      equipment: null == equipment
          ? _value._equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rpeMin: null == rpeMin
          ? _value.rpeMin
          : rpeMin // ignore: cast_nullable_to_non_nullable
              as int,
      rpeMax: null == rpeMax
          ? _value.rpeMax
          : rpeMax // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {required this.id,
      required this.userId,
      required this.createdAt,
      required this.updatedAt,
      required this.deviceId,
      this.conflicted = false,
      required this.name,
      required this.sex,
      required this.heightCm,
      required this.weightKg,
      this.unit = WeightUnit.kg,
      final List<String> injuries = const <String>[],
      final List<String> preferredDays = const <String>[],
      final List<String> equipment = const <String>[],
      this.rpeMin = 6,
      this.rpeMax = 9})
      : _injuries = injuries,
        _preferredDays = preferredDays,
        _equipment = equipment;

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String deviceId;
  @override
  @JsonKey()
  final bool conflicted;
// Profile specific fields
  @override
  final String name;
  @override
  final Sex sex;
  @override
  final int heightCm;
  @override
  final double weightKg;
  @override
  @JsonKey()
  final WeightUnit unit;
  final List<String> _injuries;
  @override
  @JsonKey()
  List<String> get injuries {
    if (_injuries is EqualUnmodifiableListView) return _injuries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_injuries);
  }

  final List<String> _preferredDays;
  @override
  @JsonKey()
  List<String> get preferredDays {
    if (_preferredDays is EqualUnmodifiableListView) return _preferredDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredDays);
  }

  final List<String> _equipment;
  @override
  @JsonKey()
  List<String> get equipment {
    if (_equipment is EqualUnmodifiableListView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipment);
  }

  @override
  @JsonKey()
  final int rpeMin;
  @override
  @JsonKey()
  final int rpeMax;

  @override
  String toString() {
    return 'UserProfile(id: $id, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt, deviceId: $deviceId, conflicted: $conflicted, name: $name, sex: $sex, heightCm: $heightCm, weightKg: $weightKg, unit: $unit, injuries: $injuries, preferredDays: $preferredDays, equipment: $equipment, rpeMin: $rpeMin, rpeMax: $rpeMax)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.conflicted, conflicted) ||
                other.conflicted == conflicted) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sex, sex) || other.sex == sex) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            const DeepCollectionEquality().equals(other._injuries, _injuries) &&
            const DeepCollectionEquality()
                .equals(other._preferredDays, _preferredDays) &&
            const DeepCollectionEquality()
                .equals(other._equipment, _equipment) &&
            (identical(other.rpeMin, rpeMin) || other.rpeMin == rpeMin) &&
            (identical(other.rpeMax, rpeMax) || other.rpeMax == rpeMax));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      createdAt,
      updatedAt,
      deviceId,
      conflicted,
      name,
      sex,
      heightCm,
      weightKg,
      unit,
      const DeepCollectionEquality().hash(_injuries),
      const DeepCollectionEquality().hash(_preferredDays),
      const DeepCollectionEquality().hash(_equipment),
      rpeMin,
      rpeMax);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {required final String id,
      required final String userId,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final String deviceId,
      final bool conflicted,
      required final String name,
      required final Sex sex,
      required final int heightCm,
      required final double weightKg,
      final WeightUnit unit,
      final List<String> injuries,
      final List<String> preferredDays,
      final List<String> equipment,
      final int rpeMin,
      final int rpeMax}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get deviceId;
  @override
  bool get conflicted;
  @override // Profile specific fields
  String get name;
  @override
  Sex get sex;
  @override
  int get heightCm;
  @override
  double get weightKg;
  @override
  WeightUnit get unit;
  @override
  List<String> get injuries;
  @override
  List<String> get preferredDays;
  @override
  List<String> get equipment;
  @override
  int get rpeMin;
  @override
  int get rpeMax;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserMetrics _$UserMetricsFromJson(Map<String, dynamic> json) {
  return _UserMetrics.fromJson(json);
}

/// @nodoc
mixin _$UserMetrics {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  bool get conflicted =>
      throw _privateConstructorUsedError; // Metrics specific fields
  Map<String, double> get oneRM => throw _privateConstructorUsedError;
  int get fatigueScore => throw _privateConstructorUsedError; // 0-10 scale
  double get sleepHours => throw _privateConstructorUsedError;
  DateTime? get lastPRAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserMetricsCopyWith<UserMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserMetricsCopyWith<$Res> {
  factory $UserMetricsCopyWith(
          UserMetrics value, $Res Function(UserMetrics) then) =
      _$UserMetricsCopyWithImpl<$Res, UserMetrics>;
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      DateTime updatedAt,
      String deviceId,
      bool conflicted,
      Map<String, double> oneRM,
      int fatigueScore,
      double sleepHours,
      DateTime? lastPRAt});
}

/// @nodoc
class _$UserMetricsCopyWithImpl<$Res, $Val extends UserMetrics>
    implements $UserMetricsCopyWith<$Res> {
  _$UserMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deviceId = null,
    Object? conflicted = null,
    Object? oneRM = null,
    Object? fatigueScore = null,
    Object? sleepHours = null,
    Object? lastPRAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      conflicted: null == conflicted
          ? _value.conflicted
          : conflicted // ignore: cast_nullable_to_non_nullable
              as bool,
      oneRM: null == oneRM
          ? _value.oneRM
          : oneRM // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      fatigueScore: null == fatigueScore
          ? _value.fatigueScore
          : fatigueScore // ignore: cast_nullable_to_non_nullable
              as int,
      sleepHours: null == sleepHours
          ? _value.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as double,
      lastPRAt: freezed == lastPRAt
          ? _value.lastPRAt
          : lastPRAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserMetricsImplCopyWith<$Res>
    implements $UserMetricsCopyWith<$Res> {
  factory _$$UserMetricsImplCopyWith(
          _$UserMetricsImpl value, $Res Function(_$UserMetricsImpl) then) =
      __$$UserMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      DateTime updatedAt,
      String deviceId,
      bool conflicted,
      Map<String, double> oneRM,
      int fatigueScore,
      double sleepHours,
      DateTime? lastPRAt});
}

/// @nodoc
class __$$UserMetricsImplCopyWithImpl<$Res>
    extends _$UserMetricsCopyWithImpl<$Res, _$UserMetricsImpl>
    implements _$$UserMetricsImplCopyWith<$Res> {
  __$$UserMetricsImplCopyWithImpl(
      _$UserMetricsImpl _value, $Res Function(_$UserMetricsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deviceId = null,
    Object? conflicted = null,
    Object? oneRM = null,
    Object? fatigueScore = null,
    Object? sleepHours = null,
    Object? lastPRAt = freezed,
  }) {
    return _then(_$UserMetricsImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      conflicted: null == conflicted
          ? _value.conflicted
          : conflicted // ignore: cast_nullable_to_non_nullable
              as bool,
      oneRM: null == oneRM
          ? _value._oneRM
          : oneRM // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      fatigueScore: null == fatigueScore
          ? _value.fatigueScore
          : fatigueScore // ignore: cast_nullable_to_non_nullable
              as int,
      sleepHours: null == sleepHours
          ? _value.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as double,
      lastPRAt: freezed == lastPRAt
          ? _value.lastPRAt
          : lastPRAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserMetricsImpl implements _UserMetrics {
  const _$UserMetricsImpl(
      {required this.id,
      required this.userId,
      required this.createdAt,
      required this.updatedAt,
      required this.deviceId,
      this.conflicted = false,
      final Map<String, double> oneRM = const <String, double>{},
      this.fatigueScore = 5,
      this.sleepHours = 8.0,
      this.lastPRAt})
      : _oneRM = oneRM;

  factory _$UserMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserMetricsImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String deviceId;
  @override
  @JsonKey()
  final bool conflicted;
// Metrics specific fields
  final Map<String, double> _oneRM;
// Metrics specific fields
  @override
  @JsonKey()
  Map<String, double> get oneRM {
    if (_oneRM is EqualUnmodifiableMapView) return _oneRM;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_oneRM);
  }

  @override
  @JsonKey()
  final int fatigueScore;
// 0-10 scale
  @override
  @JsonKey()
  final double sleepHours;
  @override
  final DateTime? lastPRAt;

  @override
  String toString() {
    return 'UserMetrics(id: $id, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt, deviceId: $deviceId, conflicted: $conflicted, oneRM: $oneRM, fatigueScore: $fatigueScore, sleepHours: $sleepHours, lastPRAt: $lastPRAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserMetricsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.conflicted, conflicted) ||
                other.conflicted == conflicted) &&
            const DeepCollectionEquality().equals(other._oneRM, _oneRM) &&
            (identical(other.fatigueScore, fatigueScore) ||
                other.fatigueScore == fatigueScore) &&
            (identical(other.sleepHours, sleepHours) ||
                other.sleepHours == sleepHours) &&
            (identical(other.lastPRAt, lastPRAt) ||
                other.lastPRAt == lastPRAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      createdAt,
      updatedAt,
      deviceId,
      conflicted,
      const DeepCollectionEquality().hash(_oneRM),
      fatigueScore,
      sleepHours,
      lastPRAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserMetricsImplCopyWith<_$UserMetricsImpl> get copyWith =>
      __$$UserMetricsImplCopyWithImpl<_$UserMetricsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserMetricsImplToJson(
      this,
    );
  }
}

abstract class _UserMetrics implements UserMetrics {
  const factory _UserMetrics(
      {required final String id,
      required final String userId,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final String deviceId,
      final bool conflicted,
      final Map<String, double> oneRM,
      final int fatigueScore,
      final double sleepHours,
      final DateTime? lastPRAt}) = _$UserMetricsImpl;

  factory _UserMetrics.fromJson(Map<String, dynamic> json) =
      _$UserMetricsImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get deviceId;
  @override
  bool get conflicted;
  @override // Metrics specific fields
  Map<String, double> get oneRM;
  @override
  int get fatigueScore;
  @override // 0-10 scale
  double get sleepHours;
  @override
  DateTime? get lastPRAt;
  @override
  @JsonKey(ignore: true)
  _$$UserMetricsImplCopyWith<_$UserMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserWorkoutStats _$UserWorkoutStatsFromJson(Map<String, dynamic> json) {
  return _UserWorkoutStats.fromJson(json);
}

/// @nodoc
mixin _$UserWorkoutStats {
  String get userId => throw _privateConstructorUsedError;
  int get totalSessions => throw _privateConstructorUsedError;
  int get completedSessions => throw _privateConstructorUsedError;
  int get thisWeekSessions => throw _privateConstructorUsedError;
  int get thisMonthSessions => throw _privateConstructorUsedError;
  double get averageRPE => throw _privateConstructorUsedError;
  int get totalMinutes => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  DateTime? get lastSessionAt => throw _privateConstructorUsedError;
  Map<String, double> get bestLifts => throw _privateConstructorUsedError;
  List<String> get achievements => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserWorkoutStatsCopyWith<UserWorkoutStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserWorkoutStatsCopyWith<$Res> {
  factory $UserWorkoutStatsCopyWith(
          UserWorkoutStats value, $Res Function(UserWorkoutStats) then) =
      _$UserWorkoutStatsCopyWithImpl<$Res, UserWorkoutStats>;
  @useResult
  $Res call(
      {String userId,
      int totalSessions,
      int completedSessions,
      int thisWeekSessions,
      int thisMonthSessions,
      double averageRPE,
      int totalMinutes,
      int longestStreak,
      int currentStreak,
      DateTime? lastSessionAt,
      Map<String, double> bestLifts,
      List<String> achievements});
}

/// @nodoc
class _$UserWorkoutStatsCopyWithImpl<$Res, $Val extends UserWorkoutStats>
    implements $UserWorkoutStatsCopyWith<$Res> {
  _$UserWorkoutStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? totalSessions = null,
    Object? completedSessions = null,
    Object? thisWeekSessions = null,
    Object? thisMonthSessions = null,
    Object? averageRPE = null,
    Object? totalMinutes = null,
    Object? longestStreak = null,
    Object? currentStreak = null,
    Object? lastSessionAt = freezed,
    Object? bestLifts = null,
    Object? achievements = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      totalSessions: null == totalSessions
          ? _value.totalSessions
          : totalSessions // ignore: cast_nullable_to_non_nullable
              as int,
      completedSessions: null == completedSessions
          ? _value.completedSessions
          : completedSessions // ignore: cast_nullable_to_non_nullable
              as int,
      thisWeekSessions: null == thisWeekSessions
          ? _value.thisWeekSessions
          : thisWeekSessions // ignore: cast_nullable_to_non_nullable
              as int,
      thisMonthSessions: null == thisMonthSessions
          ? _value.thisMonthSessions
          : thisMonthSessions // ignore: cast_nullable_to_non_nullable
              as int,
      averageRPE: null == averageRPE
          ? _value.averageRPE
          : averageRPE // ignore: cast_nullable_to_non_nullable
              as double,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      lastSessionAt: freezed == lastSessionAt
          ? _value.lastSessionAt
          : lastSessionAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      bestLifts: null == bestLifts
          ? _value.bestLifts
          : bestLifts // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      achievements: null == achievements
          ? _value.achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserWorkoutStatsImplCopyWith<$Res>
    implements $UserWorkoutStatsCopyWith<$Res> {
  factory _$$UserWorkoutStatsImplCopyWith(_$UserWorkoutStatsImpl value,
          $Res Function(_$UserWorkoutStatsImpl) then) =
      __$$UserWorkoutStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      int totalSessions,
      int completedSessions,
      int thisWeekSessions,
      int thisMonthSessions,
      double averageRPE,
      int totalMinutes,
      int longestStreak,
      int currentStreak,
      DateTime? lastSessionAt,
      Map<String, double> bestLifts,
      List<String> achievements});
}

/// @nodoc
class __$$UserWorkoutStatsImplCopyWithImpl<$Res>
    extends _$UserWorkoutStatsCopyWithImpl<$Res, _$UserWorkoutStatsImpl>
    implements _$$UserWorkoutStatsImplCopyWith<$Res> {
  __$$UserWorkoutStatsImplCopyWithImpl(_$UserWorkoutStatsImpl _value,
      $Res Function(_$UserWorkoutStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? totalSessions = null,
    Object? completedSessions = null,
    Object? thisWeekSessions = null,
    Object? thisMonthSessions = null,
    Object? averageRPE = null,
    Object? totalMinutes = null,
    Object? longestStreak = null,
    Object? currentStreak = null,
    Object? lastSessionAt = freezed,
    Object? bestLifts = null,
    Object? achievements = null,
  }) {
    return _then(_$UserWorkoutStatsImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      totalSessions: null == totalSessions
          ? _value.totalSessions
          : totalSessions // ignore: cast_nullable_to_non_nullable
              as int,
      completedSessions: null == completedSessions
          ? _value.completedSessions
          : completedSessions // ignore: cast_nullable_to_non_nullable
              as int,
      thisWeekSessions: null == thisWeekSessions
          ? _value.thisWeekSessions
          : thisWeekSessions // ignore: cast_nullable_to_non_nullable
              as int,
      thisMonthSessions: null == thisMonthSessions
          ? _value.thisMonthSessions
          : thisMonthSessions // ignore: cast_nullable_to_non_nullable
              as int,
      averageRPE: null == averageRPE
          ? _value.averageRPE
          : averageRPE // ignore: cast_nullable_to_non_nullable
              as double,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      lastSessionAt: freezed == lastSessionAt
          ? _value.lastSessionAt
          : lastSessionAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      bestLifts: null == bestLifts
          ? _value._bestLifts
          : bestLifts // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      achievements: null == achievements
          ? _value._achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserWorkoutStatsImpl implements _UserWorkoutStats {
  const _$UserWorkoutStatsImpl(
      {required this.userId,
      this.totalSessions = 0,
      this.completedSessions = 0,
      this.thisWeekSessions = 0,
      this.thisMonthSessions = 0,
      this.averageRPE = 0.0,
      this.totalMinutes = 0,
      this.longestStreak = 0,
      this.currentStreak = 0,
      this.lastSessionAt,
      final Map<String, double> bestLifts = const <String, double>{},
      final List<String> achievements = const <String>[]})
      : _bestLifts = bestLifts,
        _achievements = achievements;

  factory _$UserWorkoutStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserWorkoutStatsImplFromJson(json);

  @override
  final String userId;
  @override
  @JsonKey()
  final int totalSessions;
  @override
  @JsonKey()
  final int completedSessions;
  @override
  @JsonKey()
  final int thisWeekSessions;
  @override
  @JsonKey()
  final int thisMonthSessions;
  @override
  @JsonKey()
  final double averageRPE;
  @override
  @JsonKey()
  final int totalMinutes;
  @override
  @JsonKey()
  final int longestStreak;
  @override
  @JsonKey()
  final int currentStreak;
  @override
  final DateTime? lastSessionAt;
  final Map<String, double> _bestLifts;
  @override
  @JsonKey()
  Map<String, double> get bestLifts {
    if (_bestLifts is EqualUnmodifiableMapView) return _bestLifts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_bestLifts);
  }

  final List<String> _achievements;
  @override
  @JsonKey()
  List<String> get achievements {
    if (_achievements is EqualUnmodifiableListView) return _achievements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_achievements);
  }

  @override
  String toString() {
    return 'UserWorkoutStats(userId: $userId, totalSessions: $totalSessions, completedSessions: $completedSessions, thisWeekSessions: $thisWeekSessions, thisMonthSessions: $thisMonthSessions, averageRPE: $averageRPE, totalMinutes: $totalMinutes, longestStreak: $longestStreak, currentStreak: $currentStreak, lastSessionAt: $lastSessionAt, bestLifts: $bestLifts, achievements: $achievements)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserWorkoutStatsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.totalSessions, totalSessions) ||
                other.totalSessions == totalSessions) &&
            (identical(other.completedSessions, completedSessions) ||
                other.completedSessions == completedSessions) &&
            (identical(other.thisWeekSessions, thisWeekSessions) ||
                other.thisWeekSessions == thisWeekSessions) &&
            (identical(other.thisMonthSessions, thisMonthSessions) ||
                other.thisMonthSessions == thisMonthSessions) &&
            (identical(other.averageRPE, averageRPE) ||
                other.averageRPE == averageRPE) &&
            (identical(other.totalMinutes, totalMinutes) ||
                other.totalMinutes == totalMinutes) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.lastSessionAt, lastSessionAt) ||
                other.lastSessionAt == lastSessionAt) &&
            const DeepCollectionEquality()
                .equals(other._bestLifts, _bestLifts) &&
            const DeepCollectionEquality()
                .equals(other._achievements, _achievements));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      totalSessions,
      completedSessions,
      thisWeekSessions,
      thisMonthSessions,
      averageRPE,
      totalMinutes,
      longestStreak,
      currentStreak,
      lastSessionAt,
      const DeepCollectionEquality().hash(_bestLifts),
      const DeepCollectionEquality().hash(_achievements));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserWorkoutStatsImplCopyWith<_$UserWorkoutStatsImpl> get copyWith =>
      __$$UserWorkoutStatsImplCopyWithImpl<_$UserWorkoutStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserWorkoutStatsImplToJson(
      this,
    );
  }
}

abstract class _UserWorkoutStats implements UserWorkoutStats {
  const factory _UserWorkoutStats(
      {required final String userId,
      final int totalSessions,
      final int completedSessions,
      final int thisWeekSessions,
      final int thisMonthSessions,
      final double averageRPE,
      final int totalMinutes,
      final int longestStreak,
      final int currentStreak,
      final DateTime? lastSessionAt,
      final Map<String, double> bestLifts,
      final List<String> achievements}) = _$UserWorkoutStatsImpl;

  factory _UserWorkoutStats.fromJson(Map<String, dynamic> json) =
      _$UserWorkoutStatsImpl.fromJson;

  @override
  String get userId;
  @override
  int get totalSessions;
  @override
  int get completedSessions;
  @override
  int get thisWeekSessions;
  @override
  int get thisMonthSessions;
  @override
  double get averageRPE;
  @override
  int get totalMinutes;
  @override
  int get longestStreak;
  @override
  int get currentStreak;
  @override
  DateTime? get lastSessionAt;
  @override
  Map<String, double> get bestLifts;
  @override
  List<String> get achievements;
  @override
  @JsonKey(ignore: true)
  _$$UserWorkoutStatsImplCopyWith<_$UserWorkoutStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RRule _$RRuleFromJson(Map<String, dynamic> json) {
  return _RRule.fromJson(json);
}

/// @nodoc
mixin _$RRule {
  List<String> get byWeekday =>
      throw _privateConstructorUsedError; // ['Mon', 'Wed', 'Fri']
  int get weeks =>
      throw _privateConstructorUsedError; // Number of weeks to repeat
  TimeOfDay? get timeOfDay => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RRuleCopyWith<RRule> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RRuleCopyWith<$Res> {
  factory $RRuleCopyWith(RRule value, $Res Function(RRule) then) =
      _$RRuleCopyWithImpl<$Res, RRule>;
  @useResult
  $Res call({List<String> byWeekday, int weeks, TimeOfDay? timeOfDay});
}

/// @nodoc
class _$RRuleCopyWithImpl<$Res, $Val extends RRule>
    implements $RRuleCopyWith<$Res> {
  _$RRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? byWeekday = null,
    Object? weeks = null,
    Object? timeOfDay = freezed,
  }) {
    return _then(_value.copyWith(
      byWeekday: null == byWeekday
          ? _value.byWeekday
          : byWeekday // ignore: cast_nullable_to_non_nullable
              as List<String>,
      weeks: null == weeks
          ? _value.weeks
          : weeks // ignore: cast_nullable_to_non_nullable
              as int,
      timeOfDay: freezed == timeOfDay
          ? _value.timeOfDay
          : timeOfDay // ignore: cast_nullable_to_non_nullable
              as TimeOfDay?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RRuleImplCopyWith<$Res> implements $RRuleCopyWith<$Res> {
  factory _$$RRuleImplCopyWith(
          _$RRuleImpl value, $Res Function(_$RRuleImpl) then) =
      __$$RRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> byWeekday, int weeks, TimeOfDay? timeOfDay});
}

/// @nodoc
class __$$RRuleImplCopyWithImpl<$Res>
    extends _$RRuleCopyWithImpl<$Res, _$RRuleImpl>
    implements _$$RRuleImplCopyWith<$Res> {
  __$$RRuleImplCopyWithImpl(
      _$RRuleImpl _value, $Res Function(_$RRuleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? byWeekday = null,
    Object? weeks = null,
    Object? timeOfDay = freezed,
  }) {
    return _then(_$RRuleImpl(
      byWeekday: null == byWeekday
          ? _value._byWeekday
          : byWeekday // ignore: cast_nullable_to_non_nullable
              as List<String>,
      weeks: null == weeks
          ? _value.weeks
          : weeks // ignore: cast_nullable_to_non_nullable
              as int,
      timeOfDay: freezed == timeOfDay
          ? _value.timeOfDay
          : timeOfDay // ignore: cast_nullable_to_non_nullable
              as TimeOfDay?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RRuleImpl implements _RRule {
  const _$RRuleImpl(
      {final List<String> byWeekday = const <String>[],
      this.weeks = 4,
      this.timeOfDay})
      : _byWeekday = byWeekday;

  factory _$RRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$RRuleImplFromJson(json);

  final List<String> _byWeekday;
  @override
  @JsonKey()
  List<String> get byWeekday {
    if (_byWeekday is EqualUnmodifiableListView) return _byWeekday;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_byWeekday);
  }

// ['Mon', 'Wed', 'Fri']
  @override
  @JsonKey()
  final int weeks;
// Number of weeks to repeat
  @override
  final TimeOfDay? timeOfDay;

  @override
  String toString() {
    return 'RRule(byWeekday: $byWeekday, weeks: $weeks, timeOfDay: $timeOfDay)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RRuleImpl &&
            const DeepCollectionEquality()
                .equals(other._byWeekday, _byWeekday) &&
            (identical(other.weeks, weeks) || other.weeks == weeks) &&
            (identical(other.timeOfDay, timeOfDay) ||
                other.timeOfDay == timeOfDay));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_byWeekday), weeks, timeOfDay);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RRuleImplCopyWith<_$RRuleImpl> get copyWith =>
      __$$RRuleImplCopyWithImpl<_$RRuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RRuleImplToJson(
      this,
    );
  }
}

abstract class _RRule implements RRule {
  const factory _RRule(
      {final List<String> byWeekday,
      final int weeks,
      final TimeOfDay? timeOfDay}) = _$RRuleImpl;

  factory _RRule.fromJson(Map<String, dynamic> json) = _$RRuleImpl.fromJson;

  @override
  List<String> get byWeekday;
  @override // ['Mon', 'Wed', 'Fri']
  int get weeks;
  @override // Number of weeks to repeat
  TimeOfDay? get timeOfDay;
  @override
  @JsonKey(ignore: true)
  _$$RRuleImplCopyWith<_$RRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
