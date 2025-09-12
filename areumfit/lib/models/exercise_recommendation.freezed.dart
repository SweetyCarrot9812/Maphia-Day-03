// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExerciseRecommendation _$ExerciseRecommendationFromJson(
    Map<String, dynamic> json) {
  return _ExerciseRecommendation.fromJson(json);
}

/// @nodoc
mixin _$ExerciseRecommendation {
  String get name => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  int get reps => throw _privateConstructorUsedError;
  int get sets => throw _privateConstructorUsedError;
  int get restSeconds => throw _privateConstructorUsedError;
  double get rpe => throw _privateConstructorUsedError;
  String get priority => throw _privateConstructorUsedError;
  String get reasoning => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseRecommendationCopyWith<ExerciseRecommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseRecommendationCopyWith<$Res> {
  factory $ExerciseRecommendationCopyWith(ExerciseRecommendation value,
          $Res Function(ExerciseRecommendation) then) =
      _$ExerciseRecommendationCopyWithImpl<$Res, ExerciseRecommendation>;
  @useResult
  $Res call(
      {String name,
      double weight,
      int reps,
      int sets,
      int restSeconds,
      double rpe,
      String priority,
      String reasoning});
}

/// @nodoc
class _$ExerciseRecommendationCopyWithImpl<$Res,
        $Val extends ExerciseRecommendation>
    implements $ExerciseRecommendationCopyWith<$Res> {
  _$ExerciseRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? weight = null,
    Object? reps = null,
    Object? sets = null,
    Object? restSeconds = null,
    Object? rpe = null,
    Object? priority = null,
    Object? reasoning = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int,
      restSeconds: null == restSeconds
          ? _value.restSeconds
          : restSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      rpe: null == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as double,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      reasoning: null == reasoning
          ? _value.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseRecommendationImplCopyWith<$Res>
    implements $ExerciseRecommendationCopyWith<$Res> {
  factory _$$ExerciseRecommendationImplCopyWith(
          _$ExerciseRecommendationImpl value,
          $Res Function(_$ExerciseRecommendationImpl) then) =
      __$$ExerciseRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      double weight,
      int reps,
      int sets,
      int restSeconds,
      double rpe,
      String priority,
      String reasoning});
}

/// @nodoc
class __$$ExerciseRecommendationImplCopyWithImpl<$Res>
    extends _$ExerciseRecommendationCopyWithImpl<$Res,
        _$ExerciseRecommendationImpl>
    implements _$$ExerciseRecommendationImplCopyWith<$Res> {
  __$$ExerciseRecommendationImplCopyWithImpl(
      _$ExerciseRecommendationImpl _value,
      $Res Function(_$ExerciseRecommendationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? weight = null,
    Object? reps = null,
    Object? sets = null,
    Object? restSeconds = null,
    Object? rpe = null,
    Object? priority = null,
    Object? reasoning = null,
  }) {
    return _then(_$ExerciseRecommendationImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int,
      restSeconds: null == restSeconds
          ? _value.restSeconds
          : restSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      rpe: null == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as double,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      reasoning: null == reasoning
          ? _value.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseRecommendationImpl implements _ExerciseRecommendation {
  const _$ExerciseRecommendationImpl(
      {this.name = '',
      this.weight = 0.0,
      this.reps = 0,
      this.sets = 0,
      this.restSeconds = 0,
      this.rpe = 8.0,
      this.priority = 'medium',
      this.reasoning = ''});

  factory _$ExerciseRecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseRecommendationImplFromJson(json);

  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final double weight;
  @override
  @JsonKey()
  final int reps;
  @override
  @JsonKey()
  final int sets;
  @override
  @JsonKey()
  final int restSeconds;
  @override
  @JsonKey()
  final double rpe;
  @override
  @JsonKey()
  final String priority;
  @override
  @JsonKey()
  final String reasoning;

  @override
  String toString() {
    return 'ExerciseRecommendation(name: $name, weight: $weight, reps: $reps, sets: $sets, restSeconds: $restSeconds, rpe: $rpe, priority: $priority, reasoning: $reasoning)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseRecommendationImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.sets, sets) || other.sets == sets) &&
            (identical(other.restSeconds, restSeconds) ||
                other.restSeconds == restSeconds) &&
            (identical(other.rpe, rpe) || other.rpe == rpe) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.reasoning, reasoning) ||
                other.reasoning == reasoning));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, weight, reps, sets,
      restSeconds, rpe, priority, reasoning);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseRecommendationImplCopyWith<_$ExerciseRecommendationImpl>
      get copyWith => __$$ExerciseRecommendationImplCopyWithImpl<
          _$ExerciseRecommendationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseRecommendationImplToJson(
      this,
    );
  }
}

abstract class _ExerciseRecommendation implements ExerciseRecommendation {
  const factory _ExerciseRecommendation(
      {final String name,
      final double weight,
      final int reps,
      final int sets,
      final int restSeconds,
      final double rpe,
      final String priority,
      final String reasoning}) = _$ExerciseRecommendationImpl;

  factory _ExerciseRecommendation.fromJson(Map<String, dynamic> json) =
      _$ExerciseRecommendationImpl.fromJson;

  @override
  String get name;
  @override
  double get weight;
  @override
  int get reps;
  @override
  int get sets;
  @override
  int get restSeconds;
  @override
  double get rpe;
  @override
  String get priority;
  @override
  String get reasoning;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseRecommendationImplCopyWith<_$ExerciseRecommendationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
