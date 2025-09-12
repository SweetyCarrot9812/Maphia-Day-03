// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutPlan _$WorkoutPlanFromJson(Map<String, dynamic> json) {
  return _WorkoutPlan.fromJson(json);
}

/// @nodoc
mixin _$WorkoutPlan {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  bool get conflicted =>
      throw _privateConstructorUsedError; // Plan specific fields
  DateTime get startDate => throw _privateConstructorUsedError;
  RRule get rrule => throw _privateConstructorUsedError;
  WorkoutGoal get goal => throw _privateConstructorUsedError;
  PlanSource get source => throw _privateConstructorUsedError;
  String? get cacheKey => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutPlanCopyWith<WorkoutPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutPlanCopyWith<$Res> {
  factory $WorkoutPlanCopyWith(
          WorkoutPlan value, $Res Function(WorkoutPlan) then) =
      _$WorkoutPlanCopyWithImpl<$Res, WorkoutPlan>;
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      DateTime updatedAt,
      String deviceId,
      bool conflicted,
      DateTime startDate,
      RRule rrule,
      WorkoutGoal goal,
      PlanSource source,
      String? cacheKey});

  $RRuleCopyWith<$Res> get rrule;
}

/// @nodoc
class _$WorkoutPlanCopyWithImpl<$Res, $Val extends WorkoutPlan>
    implements $WorkoutPlanCopyWith<$Res> {
  _$WorkoutPlanCopyWithImpl(this._value, this._then);

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
    Object? startDate = null,
    Object? rrule = null,
    Object? goal = null,
    Object? source = null,
    Object? cacheKey = freezed,
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
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      rrule: null == rrule
          ? _value.rrule
          : rrule // ignore: cast_nullable_to_non_nullable
              as RRule,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as WorkoutGoal,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as PlanSource,
      cacheKey: freezed == cacheKey
          ? _value.cacheKey
          : cacheKey // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RRuleCopyWith<$Res> get rrule {
    return $RRuleCopyWith<$Res>(_value.rrule, (value) {
      return _then(_value.copyWith(rrule: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WorkoutPlanImplCopyWith<$Res>
    implements $WorkoutPlanCopyWith<$Res> {
  factory _$$WorkoutPlanImplCopyWith(
          _$WorkoutPlanImpl value, $Res Function(_$WorkoutPlanImpl) then) =
      __$$WorkoutPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      DateTime updatedAt,
      String deviceId,
      bool conflicted,
      DateTime startDate,
      RRule rrule,
      WorkoutGoal goal,
      PlanSource source,
      String? cacheKey});

  @override
  $RRuleCopyWith<$Res> get rrule;
}

/// @nodoc
class __$$WorkoutPlanImplCopyWithImpl<$Res>
    extends _$WorkoutPlanCopyWithImpl<$Res, _$WorkoutPlanImpl>
    implements _$$WorkoutPlanImplCopyWith<$Res> {
  __$$WorkoutPlanImplCopyWithImpl(
      _$WorkoutPlanImpl _value, $Res Function(_$WorkoutPlanImpl) _then)
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
    Object? startDate = null,
    Object? rrule = null,
    Object? goal = null,
    Object? source = null,
    Object? cacheKey = freezed,
  }) {
    return _then(_$WorkoutPlanImpl(
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
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      rrule: null == rrule
          ? _value.rrule
          : rrule // ignore: cast_nullable_to_non_nullable
              as RRule,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as WorkoutGoal,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as PlanSource,
      cacheKey: freezed == cacheKey
          ? _value.cacheKey
          : cacheKey // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutPlanImpl implements _WorkoutPlan {
  const _$WorkoutPlanImpl(
      {required this.id,
      required this.userId,
      required this.createdAt,
      required this.updatedAt,
      required this.deviceId,
      this.conflicted = false,
      required this.startDate,
      required this.rrule,
      required this.goal,
      required this.source,
      this.cacheKey});

  factory _$WorkoutPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutPlanImplFromJson(json);

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
// Plan specific fields
  @override
  final DateTime startDate;
  @override
  final RRule rrule;
  @override
  final WorkoutGoal goal;
  @override
  final PlanSource source;
  @override
  final String? cacheKey;

  @override
  String toString() {
    return 'WorkoutPlan(id: $id, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt, deviceId: $deviceId, conflicted: $conflicted, startDate: $startDate, rrule: $rrule, goal: $goal, source: $source, cacheKey: $cacheKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutPlanImpl &&
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
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.rrule, rrule) || other.rrule == rrule) &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.cacheKey, cacheKey) ||
                other.cacheKey == cacheKey));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, createdAt, updatedAt,
      deviceId, conflicted, startDate, rrule, goal, source, cacheKey);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutPlanImplCopyWith<_$WorkoutPlanImpl> get copyWith =>
      __$$WorkoutPlanImplCopyWithImpl<_$WorkoutPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutPlanImplToJson(
      this,
    );
  }
}

abstract class _WorkoutPlan implements WorkoutPlan {
  const factory _WorkoutPlan(
      {required final String id,
      required final String userId,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final String deviceId,
      final bool conflicted,
      required final DateTime startDate,
      required final RRule rrule,
      required final WorkoutGoal goal,
      required final PlanSource source,
      final String? cacheKey}) = _$WorkoutPlanImpl;

  factory _WorkoutPlan.fromJson(Map<String, dynamic> json) =
      _$WorkoutPlanImpl.fromJson;

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
  @override // Plan specific fields
  DateTime get startDate;
  @override
  RRule get rrule;
  @override
  WorkoutGoal get goal;
  @override
  PlanSource get source;
  @override
  String? get cacheKey;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutPlanImplCopyWith<_$WorkoutPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Exercise _$ExerciseFromJson(Map<String, dynamic> json) {
  return _Exercise.fromJson(json);
}

/// @nodoc
mixin _$Exercise {
  String get key => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  ExerciseType get type => throw _privateConstructorUsedError;
  int get targetSets => throw _privateConstructorUsedError;
  int get restSec => throw _privateConstructorUsedError;
  String? get tempo => throw _privateConstructorUsedError; // e.g., "3-1-2-0"
  String? get notes =>
      throw _privateConstructorUsedError; // AI Prescription data
  ExercisePrescription? get prescription => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseCopyWith<Exercise> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseCopyWith<$Res> {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) then) =
      _$ExerciseCopyWithImpl<$Res, Exercise>;
  @useResult
  $Res call(
      {String key,
      String name,
      ExerciseType type,
      int targetSets,
      int restSec,
      String? tempo,
      String? notes,
      ExercisePrescription? prescription});

  $ExercisePrescriptionCopyWith<$Res>? get prescription;
}

/// @nodoc
class _$ExerciseCopyWithImpl<$Res, $Val extends Exercise>
    implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
    Object? type = null,
    Object? targetSets = null,
    Object? restSec = null,
    Object? tempo = freezed,
    Object? notes = freezed,
    Object? prescription = freezed,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ExerciseType,
      targetSets: null == targetSets
          ? _value.targetSets
          : targetSets // ignore: cast_nullable_to_non_nullable
              as int,
      restSec: null == restSec
          ? _value.restSec
          : restSec // ignore: cast_nullable_to_non_nullable
              as int,
      tempo: freezed == tempo
          ? _value.tempo
          : tempo // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      prescription: freezed == prescription
          ? _value.prescription
          : prescription // ignore: cast_nullable_to_non_nullable
              as ExercisePrescription?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ExercisePrescriptionCopyWith<$Res>? get prescription {
    if (_value.prescription == null) {
      return null;
    }

    return $ExercisePrescriptionCopyWith<$Res>(_value.prescription!, (value) {
      return _then(_value.copyWith(prescription: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExerciseImplCopyWith<$Res>
    implements $ExerciseCopyWith<$Res> {
  factory _$$ExerciseImplCopyWith(
          _$ExerciseImpl value, $Res Function(_$ExerciseImpl) then) =
      __$$ExerciseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String key,
      String name,
      ExerciseType type,
      int targetSets,
      int restSec,
      String? tempo,
      String? notes,
      ExercisePrescription? prescription});

  @override
  $ExercisePrescriptionCopyWith<$Res>? get prescription;
}

/// @nodoc
class __$$ExerciseImplCopyWithImpl<$Res>
    extends _$ExerciseCopyWithImpl<$Res, _$ExerciseImpl>
    implements _$$ExerciseImplCopyWith<$Res> {
  __$$ExerciseImplCopyWithImpl(
      _$ExerciseImpl _value, $Res Function(_$ExerciseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
    Object? type = null,
    Object? targetSets = null,
    Object? restSec = null,
    Object? tempo = freezed,
    Object? notes = freezed,
    Object? prescription = freezed,
  }) {
    return _then(_$ExerciseImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ExerciseType,
      targetSets: null == targetSets
          ? _value.targetSets
          : targetSets // ignore: cast_nullable_to_non_nullable
              as int,
      restSec: null == restSec
          ? _value.restSec
          : restSec // ignore: cast_nullable_to_non_nullable
              as int,
      tempo: freezed == tempo
          ? _value.tempo
          : tempo // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      prescription: freezed == prescription
          ? _value.prescription
          : prescription // ignore: cast_nullable_to_non_nullable
              as ExercisePrescription?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseImpl implements _Exercise {
  const _$ExerciseImpl(
      {required this.key,
      required this.name,
      required this.type,
      required this.targetSets,
      required this.restSec,
      this.tempo,
      this.notes,
      this.prescription});

  factory _$ExerciseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseImplFromJson(json);

  @override
  final String key;
  @override
  final String name;
  @override
  final ExerciseType type;
  @override
  final int targetSets;
  @override
  final int restSec;
  @override
  final String? tempo;
// e.g., "3-1-2-0"
  @override
  final String? notes;
// AI Prescription data
  @override
  final ExercisePrescription? prescription;

  @override
  String toString() {
    return 'Exercise(key: $key, name: $name, type: $type, targetSets: $targetSets, restSec: $restSec, tempo: $tempo, notes: $notes, prescription: $prescription)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.targetSets, targetSets) ||
                other.targetSets == targetSets) &&
            (identical(other.restSec, restSec) || other.restSec == restSec) &&
            (identical(other.tempo, tempo) || other.tempo == tempo) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.prescription, prescription) ||
                other.prescription == prescription));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, key, name, type, targetSets,
      restSec, tempo, notes, prescription);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseImplCopyWith<_$ExerciseImpl> get copyWith =>
      __$$ExerciseImplCopyWithImpl<_$ExerciseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseImplToJson(
      this,
    );
  }
}

abstract class _Exercise implements Exercise {
  const factory _Exercise(
      {required final String key,
      required final String name,
      required final ExerciseType type,
      required final int targetSets,
      required final int restSec,
      final String? tempo,
      final String? notes,
      final ExercisePrescription? prescription}) = _$ExerciseImpl;

  factory _Exercise.fromJson(Map<String, dynamic> json) =
      _$ExerciseImpl.fromJson;

  @override
  String get key;
  @override
  String get name;
  @override
  ExerciseType get type;
  @override
  int get targetSets;
  @override
  int get restSec;
  @override
  String? get tempo;
  @override // e.g., "3-1-2-0"
  String? get notes;
  @override // AI Prescription data
  ExercisePrescription? get prescription;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseImplCopyWith<_$ExerciseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExercisePrescription _$ExercisePrescriptionFromJson(Map<String, dynamic> json) {
  return _ExercisePrescription.fromJson(json);
}

/// @nodoc
mixin _$ExercisePrescription {
  double? get percent1RM =>
      throw _privateConstructorUsedError; // Percentage of 1RM (e.g., 70.0)
  int? get reps => throw _privateConstructorUsedError; // Target reps
  int? get rpe => throw _privateConstructorUsedError; // Target RPE (6-10)
  double? get weight => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExercisePrescriptionCopyWith<ExercisePrescription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExercisePrescriptionCopyWith<$Res> {
  factory $ExercisePrescriptionCopyWith(ExercisePrescription value,
          $Res Function(ExercisePrescription) then) =
      _$ExercisePrescriptionCopyWithImpl<$Res, ExercisePrescription>;
  @useResult
  $Res call({double? percent1RM, int? reps, int? rpe, double? weight});
}

/// @nodoc
class _$ExercisePrescriptionCopyWithImpl<$Res,
        $Val extends ExercisePrescription>
    implements $ExercisePrescriptionCopyWith<$Res> {
  _$ExercisePrescriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? percent1RM = freezed,
    Object? reps = freezed,
    Object? rpe = freezed,
    Object? weight = freezed,
  }) {
    return _then(_value.copyWith(
      percent1RM: freezed == percent1RM
          ? _value.percent1RM
          : percent1RM // ignore: cast_nullable_to_non_nullable
              as double?,
      reps: freezed == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int?,
      rpe: freezed == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as int?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExercisePrescriptionImplCopyWith<$Res>
    implements $ExercisePrescriptionCopyWith<$Res> {
  factory _$$ExercisePrescriptionImplCopyWith(_$ExercisePrescriptionImpl value,
          $Res Function(_$ExercisePrescriptionImpl) then) =
      __$$ExercisePrescriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double? percent1RM, int? reps, int? rpe, double? weight});
}

/// @nodoc
class __$$ExercisePrescriptionImplCopyWithImpl<$Res>
    extends _$ExercisePrescriptionCopyWithImpl<$Res, _$ExercisePrescriptionImpl>
    implements _$$ExercisePrescriptionImplCopyWith<$Res> {
  __$$ExercisePrescriptionImplCopyWithImpl(_$ExercisePrescriptionImpl _value,
      $Res Function(_$ExercisePrescriptionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? percent1RM = freezed,
    Object? reps = freezed,
    Object? rpe = freezed,
    Object? weight = freezed,
  }) {
    return _then(_$ExercisePrescriptionImpl(
      percent1RM: freezed == percent1RM
          ? _value.percent1RM
          : percent1RM // ignore: cast_nullable_to_non_nullable
              as double?,
      reps: freezed == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int?,
      rpe: freezed == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as int?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExercisePrescriptionImpl implements _ExercisePrescription {
  const _$ExercisePrescriptionImpl(
      {this.percent1RM, this.reps, this.rpe, this.weight});

  factory _$ExercisePrescriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExercisePrescriptionImplFromJson(json);

  @override
  final double? percent1RM;
// Percentage of 1RM (e.g., 70.0)
  @override
  final int? reps;
// Target reps
  @override
  final int? rpe;
// Target RPE (6-10)
  @override
  final double? weight;

  @override
  String toString() {
    return 'ExercisePrescription(percent1RM: $percent1RM, reps: $reps, rpe: $rpe, weight: $weight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExercisePrescriptionImpl &&
            (identical(other.percent1RM, percent1RM) ||
                other.percent1RM == percent1RM) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.rpe, rpe) || other.rpe == rpe) &&
            (identical(other.weight, weight) || other.weight == weight));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, percent1RM, reps, rpe, weight);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExercisePrescriptionImplCopyWith<_$ExercisePrescriptionImpl>
      get copyWith =>
          __$$ExercisePrescriptionImplCopyWithImpl<_$ExercisePrescriptionImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExercisePrescriptionImplToJson(
      this,
    );
  }
}

abstract class _ExercisePrescription implements ExercisePrescription {
  const factory _ExercisePrescription(
      {final double? percent1RM,
      final int? reps,
      final int? rpe,
      final double? weight}) = _$ExercisePrescriptionImpl;

  factory _ExercisePrescription.fromJson(Map<String, dynamic> json) =
      _$ExercisePrescriptionImpl.fromJson;

  @override
  double? get percent1RM;
  @override // Percentage of 1RM (e.g., 70.0)
  int? get reps;
  @override // Target reps
  int? get rpe;
  @override // Target RPE (6-10)
  double? get weight;
  @override
  @JsonKey(ignore: true)
  _$$ExercisePrescriptionImplCopyWith<_$ExercisePrescriptionImpl>
      get copyWith => throw _privateConstructorUsedError;
}
