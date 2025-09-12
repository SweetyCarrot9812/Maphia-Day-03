// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todays_workout_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TodaysWorkoutPlan _$TodaysWorkoutPlanFromJson(Map<String, dynamic> json) {
  return _TodaysWorkoutPlan.fromJson(json);
}

/// @nodoc
mixin _$TodaysWorkoutPlan {
  bool get isRestDay => throw _privateConstructorUsedError;
  List<String> get primaryMuscleGroups => throw _privateConstructorUsedError;
  List<ExerciseRecommendation> get exercises =>
      throw _privateConstructorUsedError;
  String get dailyReasoning => throw _privateConstructorUsedError;
  List<String> get tips => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TodaysWorkoutPlanCopyWith<TodaysWorkoutPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodaysWorkoutPlanCopyWith<$Res> {
  factory $TodaysWorkoutPlanCopyWith(
          TodaysWorkoutPlan value, $Res Function(TodaysWorkoutPlan) then) =
      _$TodaysWorkoutPlanCopyWithImpl<$Res, TodaysWorkoutPlan>;
  @useResult
  $Res call(
      {bool isRestDay,
      List<String> primaryMuscleGroups,
      List<ExerciseRecommendation> exercises,
      String dailyReasoning,
      List<String> tips});
}

/// @nodoc
class _$TodaysWorkoutPlanCopyWithImpl<$Res, $Val extends TodaysWorkoutPlan>
    implements $TodaysWorkoutPlanCopyWith<$Res> {
  _$TodaysWorkoutPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isRestDay = null,
    Object? primaryMuscleGroups = null,
    Object? exercises = null,
    Object? dailyReasoning = null,
    Object? tips = null,
  }) {
    return _then(_value.copyWith(
      isRestDay: null == isRestDay
          ? _value.isRestDay
          : isRestDay // ignore: cast_nullable_to_non_nullable
              as bool,
      primaryMuscleGroups: null == primaryMuscleGroups
          ? _value.primaryMuscleGroups
          : primaryMuscleGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      exercises: null == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<ExerciseRecommendation>,
      dailyReasoning: null == dailyReasoning
          ? _value.dailyReasoning
          : dailyReasoning // ignore: cast_nullable_to_non_nullable
              as String,
      tips: null == tips
          ? _value.tips
          : tips // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TodaysWorkoutPlanImplCopyWith<$Res>
    implements $TodaysWorkoutPlanCopyWith<$Res> {
  factory _$$TodaysWorkoutPlanImplCopyWith(_$TodaysWorkoutPlanImpl value,
          $Res Function(_$TodaysWorkoutPlanImpl) then) =
      __$$TodaysWorkoutPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isRestDay,
      List<String> primaryMuscleGroups,
      List<ExerciseRecommendation> exercises,
      String dailyReasoning,
      List<String> tips});
}

/// @nodoc
class __$$TodaysWorkoutPlanImplCopyWithImpl<$Res>
    extends _$TodaysWorkoutPlanCopyWithImpl<$Res, _$TodaysWorkoutPlanImpl>
    implements _$$TodaysWorkoutPlanImplCopyWith<$Res> {
  __$$TodaysWorkoutPlanImplCopyWithImpl(_$TodaysWorkoutPlanImpl _value,
      $Res Function(_$TodaysWorkoutPlanImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isRestDay = null,
    Object? primaryMuscleGroups = null,
    Object? exercises = null,
    Object? dailyReasoning = null,
    Object? tips = null,
  }) {
    return _then(_$TodaysWorkoutPlanImpl(
      isRestDay: null == isRestDay
          ? _value.isRestDay
          : isRestDay // ignore: cast_nullable_to_non_nullable
              as bool,
      primaryMuscleGroups: null == primaryMuscleGroups
          ? _value._primaryMuscleGroups
          : primaryMuscleGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      exercises: null == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<ExerciseRecommendation>,
      dailyReasoning: null == dailyReasoning
          ? _value.dailyReasoning
          : dailyReasoning // ignore: cast_nullable_to_non_nullable
              as String,
      tips: null == tips
          ? _value._tips
          : tips // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TodaysWorkoutPlanImpl implements _TodaysWorkoutPlan {
  const _$TodaysWorkoutPlanImpl(
      {this.isRestDay = false,
      final List<String> primaryMuscleGroups = const <String>[],
      final List<ExerciseRecommendation> exercises =
          const <ExerciseRecommendation>[],
      this.dailyReasoning = '',
      final List<String> tips = const <String>[]})
      : _primaryMuscleGroups = primaryMuscleGroups,
        _exercises = exercises,
        _tips = tips;

  factory _$TodaysWorkoutPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$TodaysWorkoutPlanImplFromJson(json);

  @override
  @JsonKey()
  final bool isRestDay;
  final List<String> _primaryMuscleGroups;
  @override
  @JsonKey()
  List<String> get primaryMuscleGroups {
    if (_primaryMuscleGroups is EqualUnmodifiableListView)
      return _primaryMuscleGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_primaryMuscleGroups);
  }

  final List<ExerciseRecommendation> _exercises;
  @override
  @JsonKey()
  List<ExerciseRecommendation> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  @JsonKey()
  final String dailyReasoning;
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
    return 'TodaysWorkoutPlan(isRestDay: $isRestDay, primaryMuscleGroups: $primaryMuscleGroups, exercises: $exercises, dailyReasoning: $dailyReasoning, tips: $tips)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodaysWorkoutPlanImpl &&
            (identical(other.isRestDay, isRestDay) ||
                other.isRestDay == isRestDay) &&
            const DeepCollectionEquality()
                .equals(other._primaryMuscleGroups, _primaryMuscleGroups) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises) &&
            (identical(other.dailyReasoning, dailyReasoning) ||
                other.dailyReasoning == dailyReasoning) &&
            const DeepCollectionEquality().equals(other._tips, _tips));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isRestDay,
      const DeepCollectionEquality().hash(_primaryMuscleGroups),
      const DeepCollectionEquality().hash(_exercises),
      dailyReasoning,
      const DeepCollectionEquality().hash(_tips));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TodaysWorkoutPlanImplCopyWith<_$TodaysWorkoutPlanImpl> get copyWith =>
      __$$TodaysWorkoutPlanImplCopyWithImpl<_$TodaysWorkoutPlanImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TodaysWorkoutPlanImplToJson(
      this,
    );
  }
}

abstract class _TodaysWorkoutPlan implements TodaysWorkoutPlan {
  const factory _TodaysWorkoutPlan(
      {final bool isRestDay,
      final List<String> primaryMuscleGroups,
      final List<ExerciseRecommendation> exercises,
      final String dailyReasoning,
      final List<String> tips}) = _$TodaysWorkoutPlanImpl;

  factory _TodaysWorkoutPlan.fromJson(Map<String, dynamic> json) =
      _$TodaysWorkoutPlanImpl.fromJson;

  @override
  bool get isRestDay;
  @override
  List<String> get primaryMuscleGroups;
  @override
  List<ExerciseRecommendation> get exercises;
  @override
  String get dailyReasoning;
  @override
  List<String> get tips;
  @override
  @JsonKey(ignore: true)
  _$$TodaysWorkoutPlanImplCopyWith<_$TodaysWorkoutPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
