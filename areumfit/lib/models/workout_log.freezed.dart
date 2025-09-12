// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutLog _$WorkoutLogFromJson(Map<String, dynamic> json) {
  return _WorkoutLog.fromJson(json);
}

/// @nodoc
mixin _$WorkoutLog {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  bool get conflicted =>
      throw _privateConstructorUsedError; // Log specific fields
  String get sessionId => throw _privateConstructorUsedError;
  String get exerciseKey => throw _privateConstructorUsedError;
  int get setIndex => throw _privateConstructorUsedError; // 0-based index
  double get weight => throw _privateConstructorUsedError; // in kg or lbs
  int get reps => throw _privateConstructorUsedError;
  int get rpe => throw _privateConstructorUsedError; // 6-10 scale
  DateTime get completedAt => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  bool get isPR => throw _privateConstructorUsedError; // Personal Record
// Calculated fields
  double? get estimated1RM => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutLogCopyWith<WorkoutLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutLogCopyWith<$Res> {
  factory $WorkoutLogCopyWith(
          WorkoutLog value, $Res Function(WorkoutLog) then) =
      _$WorkoutLogCopyWithImpl<$Res, WorkoutLog>;
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      DateTime updatedAt,
      String deviceId,
      bool conflicted,
      String sessionId,
      String exerciseKey,
      int setIndex,
      double weight,
      int reps,
      int rpe,
      DateTime completedAt,
      String? note,
      bool isPR,
      double? estimated1RM});
}

/// @nodoc
class _$WorkoutLogCopyWithImpl<$Res, $Val extends WorkoutLog>
    implements $WorkoutLogCopyWith<$Res> {
  _$WorkoutLogCopyWithImpl(this._value, this._then);

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
    Object? sessionId = null,
    Object? exerciseKey = null,
    Object? setIndex = null,
    Object? weight = null,
    Object? reps = null,
    Object? rpe = null,
    Object? completedAt = null,
    Object? note = freezed,
    Object? isPR = null,
    Object? estimated1RM = freezed,
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
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseKey: null == exerciseKey
          ? _value.exerciseKey
          : exerciseKey // ignore: cast_nullable_to_non_nullable
              as String,
      setIndex: null == setIndex
          ? _value.setIndex
          : setIndex // ignore: cast_nullable_to_non_nullable
              as int,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      rpe: null == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as int,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isPR: null == isPR
          ? _value.isPR
          : isPR // ignore: cast_nullable_to_non_nullable
              as bool,
      estimated1RM: freezed == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutLogImplCopyWith<$Res>
    implements $WorkoutLogCopyWith<$Res> {
  factory _$$WorkoutLogImplCopyWith(
          _$WorkoutLogImpl value, $Res Function(_$WorkoutLogImpl) then) =
      __$$WorkoutLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      DateTime updatedAt,
      String deviceId,
      bool conflicted,
      String sessionId,
      String exerciseKey,
      int setIndex,
      double weight,
      int reps,
      int rpe,
      DateTime completedAt,
      String? note,
      bool isPR,
      double? estimated1RM});
}

/// @nodoc
class __$$WorkoutLogImplCopyWithImpl<$Res>
    extends _$WorkoutLogCopyWithImpl<$Res, _$WorkoutLogImpl>
    implements _$$WorkoutLogImplCopyWith<$Res> {
  __$$WorkoutLogImplCopyWithImpl(
      _$WorkoutLogImpl _value, $Res Function(_$WorkoutLogImpl) _then)
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
    Object? sessionId = null,
    Object? exerciseKey = null,
    Object? setIndex = null,
    Object? weight = null,
    Object? reps = null,
    Object? rpe = null,
    Object? completedAt = null,
    Object? note = freezed,
    Object? isPR = null,
    Object? estimated1RM = freezed,
  }) {
    return _then(_$WorkoutLogImpl(
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
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseKey: null == exerciseKey
          ? _value.exerciseKey
          : exerciseKey // ignore: cast_nullable_to_non_nullable
              as String,
      setIndex: null == setIndex
          ? _value.setIndex
          : setIndex // ignore: cast_nullable_to_non_nullable
              as int,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      rpe: null == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as int,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      isPR: null == isPR
          ? _value.isPR
          : isPR // ignore: cast_nullable_to_non_nullable
              as bool,
      estimated1RM: freezed == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutLogImpl implements _WorkoutLog {
  const _$WorkoutLogImpl(
      {required this.id,
      required this.userId,
      required this.createdAt,
      required this.updatedAt,
      required this.deviceId,
      this.conflicted = false,
      required this.sessionId,
      required this.exerciseKey,
      required this.setIndex,
      required this.weight,
      required this.reps,
      required this.rpe,
      required this.completedAt,
      this.note,
      this.isPR = false,
      this.estimated1RM});

  factory _$WorkoutLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutLogImplFromJson(json);

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
// Log specific fields
  @override
  final String sessionId;
  @override
  final String exerciseKey;
  @override
  final int setIndex;
// 0-based index
  @override
  final double weight;
// in kg or lbs
  @override
  final int reps;
  @override
  final int rpe;
// 6-10 scale
  @override
  final DateTime completedAt;
  @override
  final String? note;
  @override
  @JsonKey()
  final bool isPR;
// Personal Record
// Calculated fields
  @override
  final double? estimated1RM;

  @override
  String toString() {
    return 'WorkoutLog(id: $id, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt, deviceId: $deviceId, conflicted: $conflicted, sessionId: $sessionId, exerciseKey: $exerciseKey, setIndex: $setIndex, weight: $weight, reps: $reps, rpe: $rpe, completedAt: $completedAt, note: $note, isPR: $isPR, estimated1RM: $estimated1RM)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutLogImpl &&
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
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.exerciseKey, exerciseKey) ||
                other.exerciseKey == exerciseKey) &&
            (identical(other.setIndex, setIndex) ||
                other.setIndex == setIndex) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.rpe, rpe) || other.rpe == rpe) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.isPR, isPR) || other.isPR == isPR) &&
            (identical(other.estimated1RM, estimated1RM) ||
                other.estimated1RM == estimated1RM));
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
      sessionId,
      exerciseKey,
      setIndex,
      weight,
      reps,
      rpe,
      completedAt,
      note,
      isPR,
      estimated1RM);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutLogImplCopyWith<_$WorkoutLogImpl> get copyWith =>
      __$$WorkoutLogImplCopyWithImpl<_$WorkoutLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutLogImplToJson(
      this,
    );
  }
}

abstract class _WorkoutLog implements WorkoutLog {
  const factory _WorkoutLog(
      {required final String id,
      required final String userId,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final String deviceId,
      final bool conflicted,
      required final String sessionId,
      required final String exerciseKey,
      required final int setIndex,
      required final double weight,
      required final int reps,
      required final int rpe,
      required final DateTime completedAt,
      final String? note,
      final bool isPR,
      final double? estimated1RM}) = _$WorkoutLogImpl;

  factory _WorkoutLog.fromJson(Map<String, dynamic> json) =
      _$WorkoutLogImpl.fromJson;

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
  @override // Log specific fields
  String get sessionId;
  @override
  String get exerciseKey;
  @override
  int get setIndex;
  @override // 0-based index
  double get weight;
  @override // in kg or lbs
  int get reps;
  @override
  int get rpe;
  @override // 6-10 scale
  DateTime get completedAt;
  @override
  String? get note;
  @override
  bool get isPR;
  @override // Personal Record
// Calculated fields
  double? get estimated1RM;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutLogImplCopyWith<_$WorkoutLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LocalPlanCache _$LocalPlanCacheFromJson(Map<String, dynamic> json) {
  return _LocalPlanCache.fromJson(json);
}

/// @nodoc
mixin _$LocalPlanCache {
  String get cacheKey => throw _privateConstructorUsedError;
  String get payload => throw _privateConstructorUsedError; // JSON string
  int get ttlEpoch =>
      throw _privateConstructorUsedError; // Expiration timestamp
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LocalPlanCacheCopyWith<LocalPlanCache> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalPlanCacheCopyWith<$Res> {
  factory $LocalPlanCacheCopyWith(
          LocalPlanCache value, $Res Function(LocalPlanCache) then) =
      _$LocalPlanCacheCopyWithImpl<$Res, LocalPlanCache>;
  @useResult
  $Res call(
      {String cacheKey, String payload, int ttlEpoch, DateTime createdAt});
}

/// @nodoc
class _$LocalPlanCacheCopyWithImpl<$Res, $Val extends LocalPlanCache>
    implements $LocalPlanCacheCopyWith<$Res> {
  _$LocalPlanCacheCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cacheKey = null,
    Object? payload = null,
    Object? ttlEpoch = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      cacheKey: null == cacheKey
          ? _value.cacheKey
          : cacheKey // ignore: cast_nullable_to_non_nullable
              as String,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as String,
      ttlEpoch: null == ttlEpoch
          ? _value.ttlEpoch
          : ttlEpoch // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocalPlanCacheImplCopyWith<$Res>
    implements $LocalPlanCacheCopyWith<$Res> {
  factory _$$LocalPlanCacheImplCopyWith(_$LocalPlanCacheImpl value,
          $Res Function(_$LocalPlanCacheImpl) then) =
      __$$LocalPlanCacheImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String cacheKey, String payload, int ttlEpoch, DateTime createdAt});
}

/// @nodoc
class __$$LocalPlanCacheImplCopyWithImpl<$Res>
    extends _$LocalPlanCacheCopyWithImpl<$Res, _$LocalPlanCacheImpl>
    implements _$$LocalPlanCacheImplCopyWith<$Res> {
  __$$LocalPlanCacheImplCopyWithImpl(
      _$LocalPlanCacheImpl _value, $Res Function(_$LocalPlanCacheImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cacheKey = null,
    Object? payload = null,
    Object? ttlEpoch = null,
    Object? createdAt = null,
  }) {
    return _then(_$LocalPlanCacheImpl(
      cacheKey: null == cacheKey
          ? _value.cacheKey
          : cacheKey // ignore: cast_nullable_to_non_nullable
              as String,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as String,
      ttlEpoch: null == ttlEpoch
          ? _value.ttlEpoch
          : ttlEpoch // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocalPlanCacheImpl implements _LocalPlanCache {
  const _$LocalPlanCacheImpl(
      {required this.cacheKey,
      required this.payload,
      required this.ttlEpoch,
      required this.createdAt});

  factory _$LocalPlanCacheImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocalPlanCacheImplFromJson(json);

  @override
  final String cacheKey;
  @override
  final String payload;
// JSON string
  @override
  final int ttlEpoch;
// Expiration timestamp
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'LocalPlanCache(cacheKey: $cacheKey, payload: $payload, ttlEpoch: $ttlEpoch, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalPlanCacheImpl &&
            (identical(other.cacheKey, cacheKey) ||
                other.cacheKey == cacheKey) &&
            (identical(other.payload, payload) || other.payload == payload) &&
            (identical(other.ttlEpoch, ttlEpoch) ||
                other.ttlEpoch == ttlEpoch) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, cacheKey, payload, ttlEpoch, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalPlanCacheImplCopyWith<_$LocalPlanCacheImpl> get copyWith =>
      __$$LocalPlanCacheImplCopyWithImpl<_$LocalPlanCacheImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocalPlanCacheImplToJson(
      this,
    );
  }
}

abstract class _LocalPlanCache implements LocalPlanCache {
  const factory _LocalPlanCache(
      {required final String cacheKey,
      required final String payload,
      required final int ttlEpoch,
      required final DateTime createdAt}) = _$LocalPlanCacheImpl;

  factory _LocalPlanCache.fromJson(Map<String, dynamic> json) =
      _$LocalPlanCacheImpl.fromJson;

  @override
  String get cacheKey;
  @override
  String get payload;
  @override // JSON string
  int get ttlEpoch;
  @override // Expiration timestamp
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$LocalPlanCacheImplCopyWith<_$LocalPlanCacheImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PendingOperation _$PendingOperationFromJson(Map<String, dynamic> json) {
  return _PendingOperation.fromJson(json);
}

/// @nodoc
mixin _$PendingOperation {
  String get id => throw _privateConstructorUsedError;
  SyncOperation get op => throw _privateConstructorUsedError;
  String get collection =>
      throw _privateConstructorUsedError; // 'sessions', 'logs', etc.
  String get payload => throw _privateConstructorUsedError; // JSON string
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get retryCount => throw _privateConstructorUsedError;
  DateTime? get lastAttemptAt => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PendingOperationCopyWith<PendingOperation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PendingOperationCopyWith<$Res> {
  factory $PendingOperationCopyWith(
          PendingOperation value, $Res Function(PendingOperation) then) =
      _$PendingOperationCopyWithImpl<$Res, PendingOperation>;
  @useResult
  $Res call(
      {String id,
      SyncOperation op,
      String collection,
      String payload,
      DateTime createdAt,
      int retryCount,
      DateTime? lastAttemptAt,
      String? errorMessage});
}

/// @nodoc
class _$PendingOperationCopyWithImpl<$Res, $Val extends PendingOperation>
    implements $PendingOperationCopyWith<$Res> {
  _$PendingOperationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? op = null,
    Object? collection = null,
    Object? payload = null,
    Object? createdAt = null,
    Object? retryCount = null,
    Object? lastAttemptAt = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      op: null == op
          ? _value.op
          : op // ignore: cast_nullable_to_non_nullable
              as SyncOperation,
      collection: null == collection
          ? _value.collection
          : collection // ignore: cast_nullable_to_non_nullable
              as String,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastAttemptAt: freezed == lastAttemptAt
          ? _value.lastAttemptAt
          : lastAttemptAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PendingOperationImplCopyWith<$Res>
    implements $PendingOperationCopyWith<$Res> {
  factory _$$PendingOperationImplCopyWith(_$PendingOperationImpl value,
          $Res Function(_$PendingOperationImpl) then) =
      __$$PendingOperationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      SyncOperation op,
      String collection,
      String payload,
      DateTime createdAt,
      int retryCount,
      DateTime? lastAttemptAt,
      String? errorMessage});
}

/// @nodoc
class __$$PendingOperationImplCopyWithImpl<$Res>
    extends _$PendingOperationCopyWithImpl<$Res, _$PendingOperationImpl>
    implements _$$PendingOperationImplCopyWith<$Res> {
  __$$PendingOperationImplCopyWithImpl(_$PendingOperationImpl _value,
      $Res Function(_$PendingOperationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? op = null,
    Object? collection = null,
    Object? payload = null,
    Object? createdAt = null,
    Object? retryCount = null,
    Object? lastAttemptAt = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$PendingOperationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      op: null == op
          ? _value.op
          : op // ignore: cast_nullable_to_non_nullable
              as SyncOperation,
      collection: null == collection
          ? _value.collection
          : collection // ignore: cast_nullable_to_non_nullable
              as String,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastAttemptAt: freezed == lastAttemptAt
          ? _value.lastAttemptAt
          : lastAttemptAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PendingOperationImpl implements _PendingOperation {
  const _$PendingOperationImpl(
      {required this.id,
      required this.op,
      required this.collection,
      required this.payload,
      required this.createdAt,
      this.retryCount = 0,
      this.lastAttemptAt,
      this.errorMessage});

  factory _$PendingOperationImpl.fromJson(Map<String, dynamic> json) =>
      _$$PendingOperationImplFromJson(json);

  @override
  final String id;
  @override
  final SyncOperation op;
  @override
  final String collection;
// 'sessions', 'logs', etc.
  @override
  final String payload;
// JSON string
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final int retryCount;
  @override
  final DateTime? lastAttemptAt;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'PendingOperation(id: $id, op: $op, collection: $collection, payload: $payload, createdAt: $createdAt, retryCount: $retryCount, lastAttemptAt: $lastAttemptAt, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PendingOperationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.op, op) || other.op == op) &&
            (identical(other.collection, collection) ||
                other.collection == collection) &&
            (identical(other.payload, payload) || other.payload == payload) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.lastAttemptAt, lastAttemptAt) ||
                other.lastAttemptAt == lastAttemptAt) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, op, collection, payload,
      createdAt, retryCount, lastAttemptAt, errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PendingOperationImplCopyWith<_$PendingOperationImpl> get copyWith =>
      __$$PendingOperationImplCopyWithImpl<_$PendingOperationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PendingOperationImplToJson(
      this,
    );
  }
}

abstract class _PendingOperation implements PendingOperation {
  const factory _PendingOperation(
      {required final String id,
      required final SyncOperation op,
      required final String collection,
      required final String payload,
      required final DateTime createdAt,
      final int retryCount,
      final DateTime? lastAttemptAt,
      final String? errorMessage}) = _$PendingOperationImpl;

  factory _PendingOperation.fromJson(Map<String, dynamic> json) =
      _$PendingOperationImpl.fromJson;

  @override
  String get id;
  @override
  SyncOperation get op;
  @override
  String get collection;
  @override // 'sessions', 'logs', etc.
  String get payload;
  @override // JSON string
  DateTime get createdAt;
  @override
  int get retryCount;
  @override
  DateTime? get lastAttemptAt;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$PendingOperationImplCopyWith<_$PendingOperationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExerciseLog _$ExerciseLogFromJson(Map<String, dynamic> json) {
  return _ExerciseLog.fromJson(json);
}

/// @nodoc
mixin _$ExerciseLog {
  String get exerciseId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  int get reps => throw _privateConstructorUsedError;
  int get rpe => throw _privateConstructorUsedError;
  double? get estimated1RM => throw _privateConstructorUsedError;
  bool? get isPR => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseLogCopyWith<ExerciseLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseLogCopyWith<$Res> {
  factory $ExerciseLogCopyWith(
          ExerciseLog value, $Res Function(ExerciseLog) then) =
      _$ExerciseLogCopyWithImpl<$Res, ExerciseLog>;
  @useResult
  $Res call(
      {String exerciseId,
      DateTime date,
      double weight,
      int reps,
      int rpe,
      double? estimated1RM,
      bool? isPR,
      String? note,
      bool completed});
}

/// @nodoc
class _$ExerciseLogCopyWithImpl<$Res, $Val extends ExerciseLog>
    implements $ExerciseLogCopyWith<$Res> {
  _$ExerciseLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? date = null,
    Object? weight = null,
    Object? reps = null,
    Object? rpe = null,
    Object? estimated1RM = freezed,
    Object? isPR = freezed,
    Object? note = freezed,
    Object? completed = null,
  }) {
    return _then(_value.copyWith(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      rpe: null == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as int,
      estimated1RM: freezed == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double?,
      isPR: freezed == isPR
          ? _value.isPR
          : isPR // ignore: cast_nullable_to_non_nullable
              as bool?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseLogImplCopyWith<$Res>
    implements $ExerciseLogCopyWith<$Res> {
  factory _$$ExerciseLogImplCopyWith(
          _$ExerciseLogImpl value, $Res Function(_$ExerciseLogImpl) then) =
      __$$ExerciseLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseId,
      DateTime date,
      double weight,
      int reps,
      int rpe,
      double? estimated1RM,
      bool? isPR,
      String? note,
      bool completed});
}

/// @nodoc
class __$$ExerciseLogImplCopyWithImpl<$Res>
    extends _$ExerciseLogCopyWithImpl<$Res, _$ExerciseLogImpl>
    implements _$$ExerciseLogImplCopyWith<$Res> {
  __$$ExerciseLogImplCopyWithImpl(
      _$ExerciseLogImpl _value, $Res Function(_$ExerciseLogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? date = null,
    Object? weight = null,
    Object? reps = null,
    Object? rpe = null,
    Object? estimated1RM = freezed,
    Object? isPR = freezed,
    Object? note = freezed,
    Object? completed = null,
  }) {
    return _then(_$ExerciseLogImpl(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      rpe: null == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as int,
      estimated1RM: freezed == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double?,
      isPR: freezed == isPR
          ? _value.isPR
          : isPR // ignore: cast_nullable_to_non_nullable
              as bool?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseLogImpl implements _ExerciseLog {
  const _$ExerciseLogImpl(
      {required this.exerciseId,
      required this.date,
      required this.weight,
      required this.reps,
      required this.rpe,
      this.estimated1RM,
      this.isPR,
      this.note,
      this.completed = true});

  factory _$ExerciseLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseLogImplFromJson(json);

  @override
  final String exerciseId;
  @override
  final DateTime date;
  @override
  final double weight;
  @override
  final int reps;
  @override
  final int rpe;
  @override
  final double? estimated1RM;
  @override
  final bool? isPR;
  @override
  final String? note;
  @override
  @JsonKey()
  final bool completed;

  @override
  String toString() {
    return 'ExerciseLog(exerciseId: $exerciseId, date: $date, weight: $weight, reps: $reps, rpe: $rpe, estimated1RM: $estimated1RM, isPR: $isPR, note: $note, completed: $completed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseLogImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.rpe, rpe) || other.rpe == rpe) &&
            (identical(other.estimated1RM, estimated1RM) ||
                other.estimated1RM == estimated1RM) &&
            (identical(other.isPR, isPR) || other.isPR == isPR) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.completed, completed) ||
                other.completed == completed));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, exerciseId, date, weight, reps,
      rpe, estimated1RM, isPR, note, completed);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseLogImplCopyWith<_$ExerciseLogImpl> get copyWith =>
      __$$ExerciseLogImplCopyWithImpl<_$ExerciseLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseLogImplToJson(
      this,
    );
  }
}

abstract class _ExerciseLog implements ExerciseLog {
  const factory _ExerciseLog(
      {required final String exerciseId,
      required final DateTime date,
      required final double weight,
      required final int reps,
      required final int rpe,
      final double? estimated1RM,
      final bool? isPR,
      final String? note,
      final bool completed}) = _$ExerciseLogImpl;

  factory _ExerciseLog.fromJson(Map<String, dynamic> json) =
      _$ExerciseLogImpl.fromJson;

  @override
  String get exerciseId;
  @override
  DateTime get date;
  @override
  double get weight;
  @override
  int get reps;
  @override
  int get rpe;
  @override
  double? get estimated1RM;
  @override
  bool? get isPR;
  @override
  String? get note;
  @override
  bool get completed;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseLogImplCopyWith<_$ExerciseLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) {
  return _WorkoutSession.fromJson(json);
}

/// @nodoc
mixin _$WorkoutSession {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  bool get conflicted => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  String get planId => throw _privateConstructorUsedError;
  List<ExerciseLog> get exerciseLogs => throw _privateConstructorUsedError;
  SessionStatus get status =>
      throw _privateConstructorUsedError; // Using enum instead of String
  String? get note => throw _privateConstructorUsedError;
  int? get durationMinutes => throw _privateConstructorUsedError;
  bool get synced => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutSessionCopyWith<WorkoutSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutSessionCopyWith<$Res> {
  factory $WorkoutSessionCopyWith(
          WorkoutSession value, $Res Function(WorkoutSession) then) =
      _$WorkoutSessionCopyWithImpl<$Res, WorkoutSession>;
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      DateTime updatedAt,
      String deviceId,
      bool conflicted,
      DateTime date,
      DateTime? startedAt,
      DateTime? endedAt,
      DateTime? completedAt,
      String planId,
      List<ExerciseLog> exerciseLogs,
      SessionStatus status,
      String? note,
      int? durationMinutes,
      bool synced});
}

/// @nodoc
class _$WorkoutSessionCopyWithImpl<$Res, $Val extends WorkoutSession>
    implements $WorkoutSessionCopyWith<$Res> {
  _$WorkoutSessionCopyWithImpl(this._value, this._then);

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
    Object? date = null,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? completedAt = freezed,
    Object? planId = null,
    Object? exerciseLogs = null,
    Object? status = null,
    Object? note = freezed,
    Object? durationMinutes = freezed,
    Object? synced = null,
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
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseLogs: null == exerciseLogs
          ? _value.exerciseLogs
          : exerciseLogs // ignore: cast_nullable_to_non_nullable
              as List<ExerciseLog>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SessionStatus,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      synced: null == synced
          ? _value.synced
          : synced // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutSessionImplCopyWith<$Res>
    implements $WorkoutSessionCopyWith<$Res> {
  factory _$$WorkoutSessionImplCopyWith(_$WorkoutSessionImpl value,
          $Res Function(_$WorkoutSessionImpl) then) =
      __$$WorkoutSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      DateTime updatedAt,
      String deviceId,
      bool conflicted,
      DateTime date,
      DateTime? startedAt,
      DateTime? endedAt,
      DateTime? completedAt,
      String planId,
      List<ExerciseLog> exerciseLogs,
      SessionStatus status,
      String? note,
      int? durationMinutes,
      bool synced});
}

/// @nodoc
class __$$WorkoutSessionImplCopyWithImpl<$Res>
    extends _$WorkoutSessionCopyWithImpl<$Res, _$WorkoutSessionImpl>
    implements _$$WorkoutSessionImplCopyWith<$Res> {
  __$$WorkoutSessionImplCopyWithImpl(
      _$WorkoutSessionImpl _value, $Res Function(_$WorkoutSessionImpl) _then)
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
    Object? date = null,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? completedAt = freezed,
    Object? planId = null,
    Object? exerciseLogs = null,
    Object? status = null,
    Object? note = freezed,
    Object? durationMinutes = freezed,
    Object? synced = null,
  }) {
    return _then(_$WorkoutSessionImpl(
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
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseLogs: null == exerciseLogs
          ? _value._exerciseLogs
          : exerciseLogs // ignore: cast_nullable_to_non_nullable
              as List<ExerciseLog>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SessionStatus,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      synced: null == synced
          ? _value.synced
          : synced // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutSessionImpl implements _WorkoutSession {
  const _$WorkoutSessionImpl(
      {required this.id,
      required this.userId,
      required this.createdAt,
      required this.updatedAt,
      required this.deviceId,
      this.conflicted = false,
      required this.date,
      this.startedAt,
      this.endedAt,
      this.completedAt,
      required this.planId,
      final List<ExerciseLog> exerciseLogs = const [],
      required this.status,
      this.note,
      this.durationMinutes,
      this.synced = false})
      : _exerciseLogs = exerciseLogs;

  factory _$WorkoutSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutSessionImplFromJson(json);

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
  @override
  final DateTime date;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? endedAt;
  @override
  final DateTime? completedAt;
  @override
  final String planId;
  final List<ExerciseLog> _exerciseLogs;
  @override
  @JsonKey()
  List<ExerciseLog> get exerciseLogs {
    if (_exerciseLogs is EqualUnmodifiableListView) return _exerciseLogs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exerciseLogs);
  }

  @override
  final SessionStatus status;
// Using enum instead of String
  @override
  final String? note;
  @override
  final int? durationMinutes;
  @override
  @JsonKey()
  final bool synced;

  @override
  String toString() {
    return 'WorkoutSession(id: $id, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt, deviceId: $deviceId, conflicted: $conflicted, date: $date, startedAt: $startedAt, endedAt: $endedAt, completedAt: $completedAt, planId: $planId, exerciseLogs: $exerciseLogs, status: $status, note: $note, durationMinutes: $durationMinutes, synced: $synced)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutSessionImpl &&
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
            (identical(other.date, date) || other.date == date) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            const DeepCollectionEquality()
                .equals(other._exerciseLogs, _exerciseLogs) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.synced, synced) || other.synced == synced));
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
      date,
      startedAt,
      endedAt,
      completedAt,
      planId,
      const DeepCollectionEquality().hash(_exerciseLogs),
      status,
      note,
      durationMinutes,
      synced);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutSessionImplCopyWith<_$WorkoutSessionImpl> get copyWith =>
      __$$WorkoutSessionImplCopyWithImpl<_$WorkoutSessionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutSessionImplToJson(
      this,
    );
  }
}

abstract class _WorkoutSession implements WorkoutSession {
  const factory _WorkoutSession(
      {required final String id,
      required final String userId,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final String deviceId,
      final bool conflicted,
      required final DateTime date,
      final DateTime? startedAt,
      final DateTime? endedAt,
      final DateTime? completedAt,
      required final String planId,
      final List<ExerciseLog> exerciseLogs,
      required final SessionStatus status,
      final String? note,
      final int? durationMinutes,
      final bool synced}) = _$WorkoutSessionImpl;

  factory _WorkoutSession.fromJson(Map<String, dynamic> json) =
      _$WorkoutSessionImpl.fromJson;

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
  @override
  DateTime get date;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get endedAt;
  @override
  DateTime? get completedAt;
  @override
  String get planId;
  @override
  List<ExerciseLog> get exerciseLogs;
  @override
  SessionStatus get status;
  @override // Using enum instead of String
  String? get note;
  @override
  int? get durationMinutes;
  @override
  bool get synced;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutSessionImplCopyWith<_$WorkoutSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
