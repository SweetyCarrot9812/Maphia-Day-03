// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutCalendarStats _$WorkoutCalendarStatsFromJson(Map<String, dynamic> json) {
  return _WorkoutCalendarStats.fromJson(json);
}

/// @nodoc
mixin _$WorkoutCalendarStats {
  DateTime get month => throw _privateConstructorUsedError;
  int get scheduledCount => throw _privateConstructorUsedError;
  int get completedCount => throw _privateConstructorUsedError;
  int get missedCount => throw _privateConstructorUsedError;
  double get completionRate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutCalendarStatsCopyWith<WorkoutCalendarStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutCalendarStatsCopyWith<$Res> {
  factory $WorkoutCalendarStatsCopyWith(WorkoutCalendarStats value,
          $Res Function(WorkoutCalendarStats) then) =
      _$WorkoutCalendarStatsCopyWithImpl<$Res, WorkoutCalendarStats>;
  @useResult
  $Res call(
      {DateTime month,
      int scheduledCount,
      int completedCount,
      int missedCount,
      double completionRate});
}

/// @nodoc
class _$WorkoutCalendarStatsCopyWithImpl<$Res,
        $Val extends WorkoutCalendarStats>
    implements $WorkoutCalendarStatsCopyWith<$Res> {
  _$WorkoutCalendarStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? scheduledCount = null,
    Object? completedCount = null,
    Object? missedCount = null,
    Object? completionRate = null,
  }) {
    return _then(_value.copyWith(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as DateTime,
      scheduledCount: null == scheduledCount
          ? _value.scheduledCount
          : scheduledCount // ignore: cast_nullable_to_non_nullable
              as int,
      completedCount: null == completedCount
          ? _value.completedCount
          : completedCount // ignore: cast_nullable_to_non_nullable
              as int,
      missedCount: null == missedCount
          ? _value.missedCount
          : missedCount // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutCalendarStatsImplCopyWith<$Res>
    implements $WorkoutCalendarStatsCopyWith<$Res> {
  factory _$$WorkoutCalendarStatsImplCopyWith(_$WorkoutCalendarStatsImpl value,
          $Res Function(_$WorkoutCalendarStatsImpl) then) =
      __$$WorkoutCalendarStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime month,
      int scheduledCount,
      int completedCount,
      int missedCount,
      double completionRate});
}

/// @nodoc
class __$$WorkoutCalendarStatsImplCopyWithImpl<$Res>
    extends _$WorkoutCalendarStatsCopyWithImpl<$Res, _$WorkoutCalendarStatsImpl>
    implements _$$WorkoutCalendarStatsImplCopyWith<$Res> {
  __$$WorkoutCalendarStatsImplCopyWithImpl(_$WorkoutCalendarStatsImpl _value,
      $Res Function(_$WorkoutCalendarStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? scheduledCount = null,
    Object? completedCount = null,
    Object? missedCount = null,
    Object? completionRate = null,
  }) {
    return _then(_$WorkoutCalendarStatsImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as DateTime,
      scheduledCount: null == scheduledCount
          ? _value.scheduledCount
          : scheduledCount // ignore: cast_nullable_to_non_nullable
              as int,
      completedCount: null == completedCount
          ? _value.completedCount
          : completedCount // ignore: cast_nullable_to_non_nullable
              as int,
      missedCount: null == missedCount
          ? _value.missedCount
          : missedCount // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutCalendarStatsImpl implements _WorkoutCalendarStats {
  const _$WorkoutCalendarStatsImpl(
      {required this.month,
      required this.scheduledCount,
      required this.completedCount,
      required this.missedCount,
      required this.completionRate});

  factory _$WorkoutCalendarStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutCalendarStatsImplFromJson(json);

  @override
  final DateTime month;
  @override
  final int scheduledCount;
  @override
  final int completedCount;
  @override
  final int missedCount;
  @override
  final double completionRate;

  @override
  String toString() {
    return 'WorkoutCalendarStats(month: $month, scheduledCount: $scheduledCount, completedCount: $completedCount, missedCount: $missedCount, completionRate: $completionRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutCalendarStatsImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.scheduledCount, scheduledCount) ||
                other.scheduledCount == scheduledCount) &&
            (identical(other.completedCount, completedCount) ||
                other.completedCount == completedCount) &&
            (identical(other.missedCount, missedCount) ||
                other.missedCount == missedCount) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, month, scheduledCount,
      completedCount, missedCount, completionRate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutCalendarStatsImplCopyWith<_$WorkoutCalendarStatsImpl>
      get copyWith =>
          __$$WorkoutCalendarStatsImplCopyWithImpl<_$WorkoutCalendarStatsImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutCalendarStatsImplToJson(
      this,
    );
  }
}

abstract class _WorkoutCalendarStats implements WorkoutCalendarStats {
  const factory _WorkoutCalendarStats(
      {required final DateTime month,
      required final int scheduledCount,
      required final int completedCount,
      required final int missedCount,
      required final double completionRate}) = _$WorkoutCalendarStatsImpl;

  factory _WorkoutCalendarStats.fromJson(Map<String, dynamic> json) =
      _$WorkoutCalendarStatsImpl.fromJson;

  @override
  DateTime get month;
  @override
  int get scheduledCount;
  @override
  int get completedCount;
  @override
  int get missedCount;
  @override
  double get completionRate;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutCalendarStatsImplCopyWith<_$WorkoutCalendarStatsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

UpcomingWorkout _$UpcomingWorkoutFromJson(Map<String, dynamic> json) {
  return _UpcomingWorkout.fromJson(json);
}

/// @nodoc
mixin _$UpcomingWorkout {
  String get scheduleId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  int get daysUntil => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpcomingWorkoutCopyWith<UpcomingWorkout> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpcomingWorkoutCopyWith<$Res> {
  factory $UpcomingWorkoutCopyWith(
          UpcomingWorkout value, $Res Function(UpcomingWorkout) then) =
      _$UpcomingWorkoutCopyWithImpl<$Res, UpcomingWorkout>;
  @useResult
  $Res call({String scheduleId, String title, DateTime date, int daysUntil});
}

/// @nodoc
class _$UpcomingWorkoutCopyWithImpl<$Res, $Val extends UpcomingWorkout>
    implements $UpcomingWorkoutCopyWith<$Res> {
  _$UpcomingWorkoutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduleId = null,
    Object? title = null,
    Object? date = null,
    Object? daysUntil = null,
  }) {
    return _then(_value.copyWith(
      scheduleId: null == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      daysUntil: null == daysUntil
          ? _value.daysUntil
          : daysUntil // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpcomingWorkoutImplCopyWith<$Res>
    implements $UpcomingWorkoutCopyWith<$Res> {
  factory _$$UpcomingWorkoutImplCopyWith(_$UpcomingWorkoutImpl value,
          $Res Function(_$UpcomingWorkoutImpl) then) =
      __$$UpcomingWorkoutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String scheduleId, String title, DateTime date, int daysUntil});
}

/// @nodoc
class __$$UpcomingWorkoutImplCopyWithImpl<$Res>
    extends _$UpcomingWorkoutCopyWithImpl<$Res, _$UpcomingWorkoutImpl>
    implements _$$UpcomingWorkoutImplCopyWith<$Res> {
  __$$UpcomingWorkoutImplCopyWithImpl(
      _$UpcomingWorkoutImpl _value, $Res Function(_$UpcomingWorkoutImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduleId = null,
    Object? title = null,
    Object? date = null,
    Object? daysUntil = null,
  }) {
    return _then(_$UpcomingWorkoutImpl(
      scheduleId: null == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      daysUntil: null == daysUntil
          ? _value.daysUntil
          : daysUntil // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpcomingWorkoutImpl implements _UpcomingWorkout {
  const _$UpcomingWorkoutImpl(
      {required this.scheduleId,
      required this.title,
      required this.date,
      required this.daysUntil});

  factory _$UpcomingWorkoutImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpcomingWorkoutImplFromJson(json);

  @override
  final String scheduleId;
  @override
  final String title;
  @override
  final DateTime date;
  @override
  final int daysUntil;

  @override
  String toString() {
    return 'UpcomingWorkout(scheduleId: $scheduleId, title: $title, date: $date, daysUntil: $daysUntil)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpcomingWorkoutImpl &&
            (identical(other.scheduleId, scheduleId) ||
                other.scheduleId == scheduleId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.daysUntil, daysUntil) ||
                other.daysUntil == daysUntil));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, scheduleId, title, date, daysUntil);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpcomingWorkoutImplCopyWith<_$UpcomingWorkoutImpl> get copyWith =>
      __$$UpcomingWorkoutImplCopyWithImpl<_$UpcomingWorkoutImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpcomingWorkoutImplToJson(
      this,
    );
  }
}

abstract class _UpcomingWorkout implements UpcomingWorkout {
  const factory _UpcomingWorkout(
      {required final String scheduleId,
      required final String title,
      required final DateTime date,
      required final int daysUntil}) = _$UpcomingWorkoutImpl;

  factory _UpcomingWorkout.fromJson(Map<String, dynamic> json) =
      _$UpcomingWorkoutImpl.fromJson;

  @override
  String get scheduleId;
  @override
  String get title;
  @override
  DateTime get date;
  @override
  int get daysUntil;
  @override
  @JsonKey(ignore: true)
  _$$UpcomingWorkoutImplCopyWith<_$UpcomingWorkoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
