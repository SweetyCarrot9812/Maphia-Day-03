import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_model.freezed.dart';
part 'base_model.g.dart';

/// 모든 Firestore 문서의 공통 필드를 포함하는 기본 모델
@freezed
class BaseModel with _$BaseModel {
  const factory BaseModel({
    required String id,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String deviceId,
    @Default(false) bool conflicted,
  }) = _BaseModel;

  factory BaseModel.fromJson(Map<String, dynamic> json) =>
      _$BaseModelFromJson(json);
}

/// Enum 정의들
@JsonEnum()
enum WorkoutGoal {
  @JsonValue('strength')
  strength,
  @JsonValue('hypertrophy')
  hypertrophy,
  @JsonValue('fatloss')
  fatloss,
  @JsonValue('running')
  running,
  @JsonValue('mixed')
  mixed,
}

@JsonEnum()
enum ExerciseType {
  @JsonValue('strength')
  strength,
  @JsonValue('compound')
  compound,
  @JsonValue('isolation')
  isolation,
  @JsonValue('cardio')
  cardio,
  @JsonValue('accessory')
  accessory,
  @JsonValue('hiit')
  hiit,
  @JsonValue('emom')
  emom,
  @JsonValue('amrap')
  amrap,
}

@JsonEnum()
enum SessionStatus {
  @JsonValue('planned')
  planned,
  @JsonValue('active') 
  active,
  @JsonValue('inProgress')
  inProgress,
  @JsonValue('paused')
  paused,
  @JsonValue('completed')
  completed,
  @JsonValue('done')
  done,
  @JsonValue('cancelled')
  cancelled,
}

@JsonEnum()
enum PlanSource {
  @JsonValue('ai')
  ai,
  @JsonValue('manual')
  manual,
}

@JsonEnum()
enum WeightUnit {
  @JsonValue('kg')
  kg,
  @JsonValue('lbs')
  lbs,
}

@JsonEnum()
enum TimeOfDay {
  @JsonValue('AM')
  am,
  @JsonValue('PM')
  pm,
}

@JsonEnum()
enum Sex {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('other')
  other,
}