// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_coach_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AICoachInput _$AICoachInputFromJson(Map<String, dynamic> json) {
  return _AICoachInput.fromJson(json);
}

/// @nodoc
mixin _$AICoachInput {
  String get date => throw _privateConstructorUsedError; // YYYY-MM-DD
  WorkoutGoal get goal => throw _privateConstructorUsedError;
  int get availableMinutes => throw _privateConstructorUsedError;
  List<String> get equipment => throw _privateConstructorUsedError;
  List<String> get injuries => throw _privateConstructorUsedError;
  int get fatigueScore => throw _privateConstructorUsedError; // 0-10
  Map<String, double> get oneRM => throw _privateConstructorUsedError;
  List<String> get preferredDays => throw _privateConstructorUsedError;
  TimeOfDay? get timeOfDay => throw _privateConstructorUsedError;
  RecentLogsSummary? get recentLogsSummary =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AICoachInputCopyWith<AICoachInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AICoachInputCopyWith<$Res> {
  factory $AICoachInputCopyWith(
          AICoachInput value, $Res Function(AICoachInput) then) =
      _$AICoachInputCopyWithImpl<$Res, AICoachInput>;
  @useResult
  $Res call(
      {String date,
      WorkoutGoal goal,
      int availableMinutes,
      List<String> equipment,
      List<String> injuries,
      int fatigueScore,
      Map<String, double> oneRM,
      List<String> preferredDays,
      TimeOfDay? timeOfDay,
      RecentLogsSummary? recentLogsSummary});

  $RecentLogsSummaryCopyWith<$Res>? get recentLogsSummary;
}

/// @nodoc
class _$AICoachInputCopyWithImpl<$Res, $Val extends AICoachInput>
    implements $AICoachInputCopyWith<$Res> {
  _$AICoachInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? goal = null,
    Object? availableMinutes = null,
    Object? equipment = null,
    Object? injuries = null,
    Object? fatigueScore = null,
    Object? oneRM = null,
    Object? preferredDays = null,
    Object? timeOfDay = freezed,
    Object? recentLogsSummary = freezed,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as WorkoutGoal,
      availableMinutes: null == availableMinutes
          ? _value.availableMinutes
          : availableMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      equipment: null == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      injuries: null == injuries
          ? _value.injuries
          : injuries // ignore: cast_nullable_to_non_nullable
              as List<String>,
      fatigueScore: null == fatigueScore
          ? _value.fatigueScore
          : fatigueScore // ignore: cast_nullable_to_non_nullable
              as int,
      oneRM: null == oneRM
          ? _value.oneRM
          : oneRM // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      preferredDays: null == preferredDays
          ? _value.preferredDays
          : preferredDays // ignore: cast_nullable_to_non_nullable
              as List<String>,
      timeOfDay: freezed == timeOfDay
          ? _value.timeOfDay
          : timeOfDay // ignore: cast_nullable_to_non_nullable
              as TimeOfDay?,
      recentLogsSummary: freezed == recentLogsSummary
          ? _value.recentLogsSummary
          : recentLogsSummary // ignore: cast_nullable_to_non_nullable
              as RecentLogsSummary?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RecentLogsSummaryCopyWith<$Res>? get recentLogsSummary {
    if (_value.recentLogsSummary == null) {
      return null;
    }

    return $RecentLogsSummaryCopyWith<$Res>(_value.recentLogsSummary!, (value) {
      return _then(_value.copyWith(recentLogsSummary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AICoachInputImplCopyWith<$Res>
    implements $AICoachInputCopyWith<$Res> {
  factory _$$AICoachInputImplCopyWith(
          _$AICoachInputImpl value, $Res Function(_$AICoachInputImpl) then) =
      __$$AICoachInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String date,
      WorkoutGoal goal,
      int availableMinutes,
      List<String> equipment,
      List<String> injuries,
      int fatigueScore,
      Map<String, double> oneRM,
      List<String> preferredDays,
      TimeOfDay? timeOfDay,
      RecentLogsSummary? recentLogsSummary});

  @override
  $RecentLogsSummaryCopyWith<$Res>? get recentLogsSummary;
}

/// @nodoc
class __$$AICoachInputImplCopyWithImpl<$Res>
    extends _$AICoachInputCopyWithImpl<$Res, _$AICoachInputImpl>
    implements _$$AICoachInputImplCopyWith<$Res> {
  __$$AICoachInputImplCopyWithImpl(
      _$AICoachInputImpl _value, $Res Function(_$AICoachInputImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? goal = null,
    Object? availableMinutes = null,
    Object? equipment = null,
    Object? injuries = null,
    Object? fatigueScore = null,
    Object? oneRM = null,
    Object? preferredDays = null,
    Object? timeOfDay = freezed,
    Object? recentLogsSummary = freezed,
  }) {
    return _then(_$AICoachInputImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as WorkoutGoal,
      availableMinutes: null == availableMinutes
          ? _value.availableMinutes
          : availableMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      equipment: null == equipment
          ? _value._equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      injuries: null == injuries
          ? _value._injuries
          : injuries // ignore: cast_nullable_to_non_nullable
              as List<String>,
      fatigueScore: null == fatigueScore
          ? _value.fatigueScore
          : fatigueScore // ignore: cast_nullable_to_non_nullable
              as int,
      oneRM: null == oneRM
          ? _value._oneRM
          : oneRM // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      preferredDays: null == preferredDays
          ? _value._preferredDays
          : preferredDays // ignore: cast_nullable_to_non_nullable
              as List<String>,
      timeOfDay: freezed == timeOfDay
          ? _value.timeOfDay
          : timeOfDay // ignore: cast_nullable_to_non_nullable
              as TimeOfDay?,
      recentLogsSummary: freezed == recentLogsSummary
          ? _value.recentLogsSummary
          : recentLogsSummary // ignore: cast_nullable_to_non_nullable
              as RecentLogsSummary?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AICoachInputImpl implements _AICoachInput {
  const _$AICoachInputImpl(
      {required this.date,
      required this.goal,
      required this.availableMinutes,
      required final List<String> equipment,
      final List<String> injuries = const <String>[],
      required this.fatigueScore,
      required final Map<String, double> oneRM,
      required final List<String> preferredDays,
      this.timeOfDay,
      this.recentLogsSummary})
      : _equipment = equipment,
        _injuries = injuries,
        _oneRM = oneRM,
        _preferredDays = preferredDays;

  factory _$AICoachInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$AICoachInputImplFromJson(json);

  @override
  final String date;
// YYYY-MM-DD
  @override
  final WorkoutGoal goal;
  @override
  final int availableMinutes;
  final List<String> _equipment;
  @override
  List<String> get equipment {
    if (_equipment is EqualUnmodifiableListView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipment);
  }

  final List<String> _injuries;
  @override
  @JsonKey()
  List<String> get injuries {
    if (_injuries is EqualUnmodifiableListView) return _injuries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_injuries);
  }

  @override
  final int fatigueScore;
// 0-10
  final Map<String, double> _oneRM;
// 0-10
  @override
  Map<String, double> get oneRM {
    if (_oneRM is EqualUnmodifiableMapView) return _oneRM;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_oneRM);
  }

  final List<String> _preferredDays;
  @override
  List<String> get preferredDays {
    if (_preferredDays is EqualUnmodifiableListView) return _preferredDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredDays);
  }

  @override
  final TimeOfDay? timeOfDay;
  @override
  final RecentLogsSummary? recentLogsSummary;

  @override
  String toString() {
    return 'AICoachInput(date: $date, goal: $goal, availableMinutes: $availableMinutes, equipment: $equipment, injuries: $injuries, fatigueScore: $fatigueScore, oneRM: $oneRM, preferredDays: $preferredDays, timeOfDay: $timeOfDay, recentLogsSummary: $recentLogsSummary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AICoachInputImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.availableMinutes, availableMinutes) ||
                other.availableMinutes == availableMinutes) &&
            const DeepCollectionEquality()
                .equals(other._equipment, _equipment) &&
            const DeepCollectionEquality().equals(other._injuries, _injuries) &&
            (identical(other.fatigueScore, fatigueScore) ||
                other.fatigueScore == fatigueScore) &&
            const DeepCollectionEquality().equals(other._oneRM, _oneRM) &&
            const DeepCollectionEquality()
                .equals(other._preferredDays, _preferredDays) &&
            (identical(other.timeOfDay, timeOfDay) ||
                other.timeOfDay == timeOfDay) &&
            (identical(other.recentLogsSummary, recentLogsSummary) ||
                other.recentLogsSummary == recentLogsSummary));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      goal,
      availableMinutes,
      const DeepCollectionEquality().hash(_equipment),
      const DeepCollectionEquality().hash(_injuries),
      fatigueScore,
      const DeepCollectionEquality().hash(_oneRM),
      const DeepCollectionEquality().hash(_preferredDays),
      timeOfDay,
      recentLogsSummary);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AICoachInputImplCopyWith<_$AICoachInputImpl> get copyWith =>
      __$$AICoachInputImplCopyWithImpl<_$AICoachInputImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AICoachInputImplToJson(
      this,
    );
  }
}

abstract class _AICoachInput implements AICoachInput {
  const factory _AICoachInput(
      {required final String date,
      required final WorkoutGoal goal,
      required final int availableMinutes,
      required final List<String> equipment,
      final List<String> injuries,
      required final int fatigueScore,
      required final Map<String, double> oneRM,
      required final List<String> preferredDays,
      final TimeOfDay? timeOfDay,
      final RecentLogsSummary? recentLogsSummary}) = _$AICoachInputImpl;

  factory _AICoachInput.fromJson(Map<String, dynamic> json) =
      _$AICoachInputImpl.fromJson;

  @override
  String get date;
  @override // YYYY-MM-DD
  WorkoutGoal get goal;
  @override
  int get availableMinutes;
  @override
  List<String> get equipment;
  @override
  List<String> get injuries;
  @override
  int get fatigueScore;
  @override // 0-10
  Map<String, double> get oneRM;
  @override
  List<String> get preferredDays;
  @override
  TimeOfDay? get timeOfDay;
  @override
  RecentLogsSummary? get recentLogsSummary;
  @override
  @JsonKey(ignore: true)
  _$$AICoachInputImplCopyWith<_$AICoachInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecentLogsSummary _$RecentLogsSummaryFromJson(Map<String, dynamic> json) {
  return _RecentLogsSummary.fromJson(json);
}

/// @nodoc
mixin _$RecentLogsSummary {
  int get last7dSessions => throw _privateConstructorUsedError;
  double get avgRpe => throw _privateConstructorUsedError;
  Map<String, int> get muscleGroupFrequency =>
      throw _privateConstructorUsedError;
  DateTime? get lastWorkoutDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecentLogsSummaryCopyWith<RecentLogsSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecentLogsSummaryCopyWith<$Res> {
  factory $RecentLogsSummaryCopyWith(
          RecentLogsSummary value, $Res Function(RecentLogsSummary) then) =
      _$RecentLogsSummaryCopyWithImpl<$Res, RecentLogsSummary>;
  @useResult
  $Res call(
      {int last7dSessions,
      double avgRpe,
      Map<String, int> muscleGroupFrequency,
      DateTime? lastWorkoutDate});
}

/// @nodoc
class _$RecentLogsSummaryCopyWithImpl<$Res, $Val extends RecentLogsSummary>
    implements $RecentLogsSummaryCopyWith<$Res> {
  _$RecentLogsSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? last7dSessions = null,
    Object? avgRpe = null,
    Object? muscleGroupFrequency = null,
    Object? lastWorkoutDate = freezed,
  }) {
    return _then(_value.copyWith(
      last7dSessions: null == last7dSessions
          ? _value.last7dSessions
          : last7dSessions // ignore: cast_nullable_to_non_nullable
              as int,
      avgRpe: null == avgRpe
          ? _value.avgRpe
          : avgRpe // ignore: cast_nullable_to_non_nullable
              as double,
      muscleGroupFrequency: null == muscleGroupFrequency
          ? _value.muscleGroupFrequency
          : muscleGroupFrequency // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      lastWorkoutDate: freezed == lastWorkoutDate
          ? _value.lastWorkoutDate
          : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecentLogsSummaryImplCopyWith<$Res>
    implements $RecentLogsSummaryCopyWith<$Res> {
  factory _$$RecentLogsSummaryImplCopyWith(_$RecentLogsSummaryImpl value,
          $Res Function(_$RecentLogsSummaryImpl) then) =
      __$$RecentLogsSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int last7dSessions,
      double avgRpe,
      Map<String, int> muscleGroupFrequency,
      DateTime? lastWorkoutDate});
}

/// @nodoc
class __$$RecentLogsSummaryImplCopyWithImpl<$Res>
    extends _$RecentLogsSummaryCopyWithImpl<$Res, _$RecentLogsSummaryImpl>
    implements _$$RecentLogsSummaryImplCopyWith<$Res> {
  __$$RecentLogsSummaryImplCopyWithImpl(_$RecentLogsSummaryImpl _value,
      $Res Function(_$RecentLogsSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? last7dSessions = null,
    Object? avgRpe = null,
    Object? muscleGroupFrequency = null,
    Object? lastWorkoutDate = freezed,
  }) {
    return _then(_$RecentLogsSummaryImpl(
      last7dSessions: null == last7dSessions
          ? _value.last7dSessions
          : last7dSessions // ignore: cast_nullable_to_non_nullable
              as int,
      avgRpe: null == avgRpe
          ? _value.avgRpe
          : avgRpe // ignore: cast_nullable_to_non_nullable
              as double,
      muscleGroupFrequency: null == muscleGroupFrequency
          ? _value._muscleGroupFrequency
          : muscleGroupFrequency // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      lastWorkoutDate: freezed == lastWorkoutDate
          ? _value.lastWorkoutDate
          : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecentLogsSummaryImpl implements _RecentLogsSummary {
  const _$RecentLogsSummaryImpl(
      {required this.last7dSessions,
      required this.avgRpe,
      final Map<String, int> muscleGroupFrequency = const <String, int>{},
      this.lastWorkoutDate})
      : _muscleGroupFrequency = muscleGroupFrequency;

  factory _$RecentLogsSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecentLogsSummaryImplFromJson(json);

  @override
  final int last7dSessions;
  @override
  final double avgRpe;
  final Map<String, int> _muscleGroupFrequency;
  @override
  @JsonKey()
  Map<String, int> get muscleGroupFrequency {
    if (_muscleGroupFrequency is EqualUnmodifiableMapView)
      return _muscleGroupFrequency;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_muscleGroupFrequency);
  }

  @override
  final DateTime? lastWorkoutDate;

  @override
  String toString() {
    return 'RecentLogsSummary(last7dSessions: $last7dSessions, avgRpe: $avgRpe, muscleGroupFrequency: $muscleGroupFrequency, lastWorkoutDate: $lastWorkoutDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecentLogsSummaryImpl &&
            (identical(other.last7dSessions, last7dSessions) ||
                other.last7dSessions == last7dSessions) &&
            (identical(other.avgRpe, avgRpe) || other.avgRpe == avgRpe) &&
            const DeepCollectionEquality()
                .equals(other._muscleGroupFrequency, _muscleGroupFrequency) &&
            (identical(other.lastWorkoutDate, lastWorkoutDate) ||
                other.lastWorkoutDate == lastWorkoutDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      last7dSessions,
      avgRpe,
      const DeepCollectionEquality().hash(_muscleGroupFrequency),
      lastWorkoutDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecentLogsSummaryImplCopyWith<_$RecentLogsSummaryImpl> get copyWith =>
      __$$RecentLogsSummaryImplCopyWithImpl<_$RecentLogsSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecentLogsSummaryImplToJson(
      this,
    );
  }
}

abstract class _RecentLogsSummary implements RecentLogsSummary {
  const factory _RecentLogsSummary(
      {required final int last7dSessions,
      required final double avgRpe,
      final Map<String, int> muscleGroupFrequency,
      final DateTime? lastWorkoutDate}) = _$RecentLogsSummaryImpl;

  factory _RecentLogsSummary.fromJson(Map<String, dynamic> json) =
      _$RecentLogsSummaryImpl.fromJson;

  @override
  int get last7dSessions;
  @override
  double get avgRpe;
  @override
  Map<String, int> get muscleGroupFrequency;
  @override
  DateTime? get lastWorkoutDate;
  @override
  @JsonKey(ignore: true)
  _$$RecentLogsSummaryImplCopyWith<_$RecentLogsSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AICoachOutput _$AICoachOutputFromJson(Map<String, dynamic> json) {
  return _AICoachOutput.fromJson(json);
}

/// @nodoc
mixin _$AICoachOutput {
  String get planId => throw _privateConstructorUsedError;
  WorkoutGoal get goal => throw _privateConstructorUsedError;
  List<Exercise> get exercises => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  int? get estimatedDurationMinutes => throw _privateConstructorUsedError;
  List<String> get tips => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AICoachOutputCopyWith<AICoachOutput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AICoachOutputCopyWith<$Res> {
  factory $AICoachOutputCopyWith(
          AICoachOutput value, $Res Function(AICoachOutput) then) =
      _$AICoachOutputCopyWithImpl<$Res, AICoachOutput>;
  @useResult
  $Res call(
      {String planId,
      WorkoutGoal goal,
      List<Exercise> exercises,
      String? notes,
      int? estimatedDurationMinutes,
      List<String> tips});
}

/// @nodoc
class _$AICoachOutputCopyWithImpl<$Res, $Val extends AICoachOutput>
    implements $AICoachOutputCopyWith<$Res> {
  _$AICoachOutputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planId = null,
    Object? goal = null,
    Object? exercises = null,
    Object? notes = freezed,
    Object? estimatedDurationMinutes = freezed,
    Object? tips = null,
  }) {
    return _then(_value.copyWith(
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as WorkoutGoal,
      exercises: null == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<Exercise>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedDurationMinutes: freezed == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      tips: null == tips
          ? _value.tips
          : tips // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AICoachOutputImplCopyWith<$Res>
    implements $AICoachOutputCopyWith<$Res> {
  factory _$$AICoachOutputImplCopyWith(
          _$AICoachOutputImpl value, $Res Function(_$AICoachOutputImpl) then) =
      __$$AICoachOutputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String planId,
      WorkoutGoal goal,
      List<Exercise> exercises,
      String? notes,
      int? estimatedDurationMinutes,
      List<String> tips});
}

/// @nodoc
class __$$AICoachOutputImplCopyWithImpl<$Res>
    extends _$AICoachOutputCopyWithImpl<$Res, _$AICoachOutputImpl>
    implements _$$AICoachOutputImplCopyWith<$Res> {
  __$$AICoachOutputImplCopyWithImpl(
      _$AICoachOutputImpl _value, $Res Function(_$AICoachOutputImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planId = null,
    Object? goal = null,
    Object? exercises = null,
    Object? notes = freezed,
    Object? estimatedDurationMinutes = freezed,
    Object? tips = null,
  }) {
    return _then(_$AICoachOutputImpl(
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as WorkoutGoal,
      exercises: null == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<Exercise>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedDurationMinutes: freezed == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      tips: null == tips
          ? _value._tips
          : tips // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AICoachOutputImpl implements _AICoachOutput {
  const _$AICoachOutputImpl(
      {required this.planId,
      required this.goal,
      required final List<Exercise> exercises,
      this.notes,
      this.estimatedDurationMinutes,
      final List<String> tips = const <String>[]})
      : _exercises = exercises,
        _tips = tips;

  factory _$AICoachOutputImpl.fromJson(Map<String, dynamic> json) =>
      _$$AICoachOutputImplFromJson(json);

  @override
  final String planId;
  @override
  final WorkoutGoal goal;
  final List<Exercise> _exercises;
  @override
  List<Exercise> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  final String? notes;
  @override
  final int? estimatedDurationMinutes;
  final List<String> _tips;
  @override
  @JsonKey()
  List<String> get tips {
    if (_tips is EqualUnmodifiableListView) return _tips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tips);
  }

  @override
  String toString() {
    return 'AICoachOutput(planId: $planId, goal: $goal, exercises: $exercises, notes: $notes, estimatedDurationMinutes: $estimatedDurationMinutes, tips: $tips)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AICoachOutputImpl &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.goal, goal) || other.goal == goal) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(
                    other.estimatedDurationMinutes, estimatedDurationMinutes) ||
                other.estimatedDurationMinutes == estimatedDurationMinutes) &&
            const DeepCollectionEquality().equals(other._tips, _tips));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      planId,
      goal,
      const DeepCollectionEquality().hash(_exercises),
      notes,
      estimatedDurationMinutes,
      const DeepCollectionEquality().hash(_tips));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AICoachOutputImplCopyWith<_$AICoachOutputImpl> get copyWith =>
      __$$AICoachOutputImplCopyWithImpl<_$AICoachOutputImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AICoachOutputImplToJson(
      this,
    );
  }
}

abstract class _AICoachOutput implements AICoachOutput {
  const factory _AICoachOutput(
      {required final String planId,
      required final WorkoutGoal goal,
      required final List<Exercise> exercises,
      final String? notes,
      final int? estimatedDurationMinutes,
      final List<String> tips}) = _$AICoachOutputImpl;

  factory _AICoachOutput.fromJson(Map<String, dynamic> json) =
      _$AICoachOutputImpl.fromJson;

  @override
  String get planId;
  @override
  WorkoutGoal get goal;
  @override
  List<Exercise> get exercises;
  @override
  String? get notes;
  @override
  int? get estimatedDurationMinutes;
  @override
  List<String> get tips;
  @override
  @JsonKey(ignore: true)
  _$$AICoachOutputImplCopyWith<_$AICoachOutputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
