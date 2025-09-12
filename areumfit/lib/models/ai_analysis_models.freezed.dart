// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_analysis_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PerformanceAnalysis _$PerformanceAnalysisFromJson(Map<String, dynamic> json) {
  return _PerformanceAnalysis.fromJson(json);
}

/// @nodoc
mixin _$PerformanceAnalysis {
  String get userId => throw _privateConstructorUsedError;
  String get exerciseId => throw _privateConstructorUsedError;
  DateTime get analysisDate => throw _privateConstructorUsedError;
  double get progressScore => throw _privateConstructorUsedError; // 0-100점
  ProgressTrend get trend => throw _privateConstructorUsedError;
  List<PerformanceInsight> get insights => throw _privateConstructorUsedError;
  int get oneRMImprovement => throw _privateConstructorUsedError; // 지난 달 대비 %
  double get consistencyScore => throw _privateConstructorUsedError; // 0-100점
  List<String> get recommendations => throw _privateConstructorUsedError;
  Map<String, dynamic>? get additionalMetrics =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PerformanceAnalysisCopyWith<PerformanceAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PerformanceAnalysisCopyWith<$Res> {
  factory $PerformanceAnalysisCopyWith(
          PerformanceAnalysis value, $Res Function(PerformanceAnalysis) then) =
      _$PerformanceAnalysisCopyWithImpl<$Res, PerformanceAnalysis>;
  @useResult
  $Res call(
      {String userId,
      String exerciseId,
      DateTime analysisDate,
      double progressScore,
      ProgressTrend trend,
      List<PerformanceInsight> insights,
      int oneRMImprovement,
      double consistencyScore,
      List<String> recommendations,
      Map<String, dynamic>? additionalMetrics});
}

/// @nodoc
class _$PerformanceAnalysisCopyWithImpl<$Res, $Val extends PerformanceAnalysis>
    implements $PerformanceAnalysisCopyWith<$Res> {
  _$PerformanceAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? exerciseId = null,
    Object? analysisDate = null,
    Object? progressScore = null,
    Object? trend = null,
    Object? insights = null,
    Object? oneRMImprovement = null,
    Object? consistencyScore = null,
    Object? recommendations = null,
    Object? additionalMetrics = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      analysisDate: null == analysisDate
          ? _value.analysisDate
          : analysisDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      progressScore: null == progressScore
          ? _value.progressScore
          : progressScore // ignore: cast_nullable_to_non_nullable
              as double,
      trend: null == trend
          ? _value.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as ProgressTrend,
      insights: null == insights
          ? _value.insights
          : insights // ignore: cast_nullable_to_non_nullable
              as List<PerformanceInsight>,
      oneRMImprovement: null == oneRMImprovement
          ? _value.oneRMImprovement
          : oneRMImprovement // ignore: cast_nullable_to_non_nullable
              as int,
      consistencyScore: null == consistencyScore
          ? _value.consistencyScore
          : consistencyScore // ignore: cast_nullable_to_non_nullable
              as double,
      recommendations: null == recommendations
          ? _value.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      additionalMetrics: freezed == additionalMetrics
          ? _value.additionalMetrics
          : additionalMetrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PerformanceAnalysisImplCopyWith<$Res>
    implements $PerformanceAnalysisCopyWith<$Res> {
  factory _$$PerformanceAnalysisImplCopyWith(_$PerformanceAnalysisImpl value,
          $Res Function(_$PerformanceAnalysisImpl) then) =
      __$$PerformanceAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String exerciseId,
      DateTime analysisDate,
      double progressScore,
      ProgressTrend trend,
      List<PerformanceInsight> insights,
      int oneRMImprovement,
      double consistencyScore,
      List<String> recommendations,
      Map<String, dynamic>? additionalMetrics});
}

/// @nodoc
class __$$PerformanceAnalysisImplCopyWithImpl<$Res>
    extends _$PerformanceAnalysisCopyWithImpl<$Res, _$PerformanceAnalysisImpl>
    implements _$$PerformanceAnalysisImplCopyWith<$Res> {
  __$$PerformanceAnalysisImplCopyWithImpl(_$PerformanceAnalysisImpl _value,
      $Res Function(_$PerformanceAnalysisImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? exerciseId = null,
    Object? analysisDate = null,
    Object? progressScore = null,
    Object? trend = null,
    Object? insights = null,
    Object? oneRMImprovement = null,
    Object? consistencyScore = null,
    Object? recommendations = null,
    Object? additionalMetrics = freezed,
  }) {
    return _then(_$PerformanceAnalysisImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      analysisDate: null == analysisDate
          ? _value.analysisDate
          : analysisDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      progressScore: null == progressScore
          ? _value.progressScore
          : progressScore // ignore: cast_nullable_to_non_nullable
              as double,
      trend: null == trend
          ? _value.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as ProgressTrend,
      insights: null == insights
          ? _value._insights
          : insights // ignore: cast_nullable_to_non_nullable
              as List<PerformanceInsight>,
      oneRMImprovement: null == oneRMImprovement
          ? _value.oneRMImprovement
          : oneRMImprovement // ignore: cast_nullable_to_non_nullable
              as int,
      consistencyScore: null == consistencyScore
          ? _value.consistencyScore
          : consistencyScore // ignore: cast_nullable_to_non_nullable
              as double,
      recommendations: null == recommendations
          ? _value._recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      additionalMetrics: freezed == additionalMetrics
          ? _value._additionalMetrics
          : additionalMetrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PerformanceAnalysisImpl implements _PerformanceAnalysis {
  const _$PerformanceAnalysisImpl(
      {required this.userId,
      required this.exerciseId,
      required this.analysisDate,
      required this.progressScore,
      required this.trend,
      required final List<PerformanceInsight> insights,
      required this.oneRMImprovement,
      required this.consistencyScore,
      required final List<String> recommendations,
      final Map<String, dynamic>? additionalMetrics})
      : _insights = insights,
        _recommendations = recommendations,
        _additionalMetrics = additionalMetrics;

  factory _$PerformanceAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$PerformanceAnalysisImplFromJson(json);

  @override
  final String userId;
  @override
  final String exerciseId;
  @override
  final DateTime analysisDate;
  @override
  final double progressScore;
// 0-100점
  @override
  final ProgressTrend trend;
  final List<PerformanceInsight> _insights;
  @override
  List<PerformanceInsight> get insights {
    if (_insights is EqualUnmodifiableListView) return _insights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_insights);
  }

  @override
  final int oneRMImprovement;
// 지난 달 대비 %
  @override
  final double consistencyScore;
// 0-100점
  final List<String> _recommendations;
// 0-100점
  @override
  List<String> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

  final Map<String, dynamic>? _additionalMetrics;
  @override
  Map<String, dynamic>? get additionalMetrics {
    final value = _additionalMetrics;
    if (value == null) return null;
    if (_additionalMetrics is EqualUnmodifiableMapView)
      return _additionalMetrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'PerformanceAnalysis(userId: $userId, exerciseId: $exerciseId, analysisDate: $analysisDate, progressScore: $progressScore, trend: $trend, insights: $insights, oneRMImprovement: $oneRMImprovement, consistencyScore: $consistencyScore, recommendations: $recommendations, additionalMetrics: $additionalMetrics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PerformanceAnalysisImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.analysisDate, analysisDate) ||
                other.analysisDate == analysisDate) &&
            (identical(other.progressScore, progressScore) ||
                other.progressScore == progressScore) &&
            (identical(other.trend, trend) || other.trend == trend) &&
            const DeepCollectionEquality().equals(other._insights, _insights) &&
            (identical(other.oneRMImprovement, oneRMImprovement) ||
                other.oneRMImprovement == oneRMImprovement) &&
            (identical(other.consistencyScore, consistencyScore) ||
                other.consistencyScore == consistencyScore) &&
            const DeepCollectionEquality()
                .equals(other._recommendations, _recommendations) &&
            const DeepCollectionEquality()
                .equals(other._additionalMetrics, _additionalMetrics));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      exerciseId,
      analysisDate,
      progressScore,
      trend,
      const DeepCollectionEquality().hash(_insights),
      oneRMImprovement,
      consistencyScore,
      const DeepCollectionEquality().hash(_recommendations),
      const DeepCollectionEquality().hash(_additionalMetrics));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PerformanceAnalysisImplCopyWith<_$PerformanceAnalysisImpl> get copyWith =>
      __$$PerformanceAnalysisImplCopyWithImpl<_$PerformanceAnalysisImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PerformanceAnalysisImplToJson(
      this,
    );
  }
}

abstract class _PerformanceAnalysis implements PerformanceAnalysis {
  const factory _PerformanceAnalysis(
          {required final String userId,
          required final String exerciseId,
          required final DateTime analysisDate,
          required final double progressScore,
          required final ProgressTrend trend,
          required final List<PerformanceInsight> insights,
          required final int oneRMImprovement,
          required final double consistencyScore,
          required final List<String> recommendations,
          final Map<String, dynamic>? additionalMetrics}) =
      _$PerformanceAnalysisImpl;

  factory _PerformanceAnalysis.fromJson(Map<String, dynamic> json) =
      _$PerformanceAnalysisImpl.fromJson;

  @override
  String get userId;
  @override
  String get exerciseId;
  @override
  DateTime get analysisDate;
  @override
  double get progressScore;
  @override // 0-100점
  ProgressTrend get trend;
  @override
  List<PerformanceInsight> get insights;
  @override
  int get oneRMImprovement;
  @override // 지난 달 대비 %
  double get consistencyScore;
  @override // 0-100점
  List<String> get recommendations;
  @override
  Map<String, dynamic>? get additionalMetrics;
  @override
  @JsonKey(ignore: true)
  _$$PerformanceAnalysisImplCopyWith<_$PerformanceAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PerformanceInsight _$PerformanceInsightFromJson(Map<String, dynamic> json) {
  return _PerformanceInsight.fromJson(json);
}

/// @nodoc
mixin _$PerformanceInsight {
  InsightType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  InsightSeverity get severity => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError; // 0-1.0
  List<String>? get actionItems => throw _privateConstructorUsedError;
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PerformanceInsightCopyWith<PerformanceInsight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PerformanceInsightCopyWith<$Res> {
  factory $PerformanceInsightCopyWith(
          PerformanceInsight value, $Res Function(PerformanceInsight) then) =
      _$PerformanceInsightCopyWithImpl<$Res, PerformanceInsight>;
  @useResult
  $Res call(
      {InsightType type,
      String title,
      String description,
      InsightSeverity severity,
      double confidence,
      List<String>? actionItems,
      Map<String, dynamic>? data});
}

/// @nodoc
class _$PerformanceInsightCopyWithImpl<$Res, $Val extends PerformanceInsight>
    implements $PerformanceInsightCopyWith<$Res> {
  _$PerformanceInsightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? severity = null,
    Object? confidence = null,
    Object? actionItems = freezed,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InsightType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as InsightSeverity,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      actionItems: freezed == actionItems
          ? _value.actionItems
          : actionItems // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PerformanceInsightImplCopyWith<$Res>
    implements $PerformanceInsightCopyWith<$Res> {
  factory _$$PerformanceInsightImplCopyWith(_$PerformanceInsightImpl value,
          $Res Function(_$PerformanceInsightImpl) then) =
      __$$PerformanceInsightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {InsightType type,
      String title,
      String description,
      InsightSeverity severity,
      double confidence,
      List<String>? actionItems,
      Map<String, dynamic>? data});
}

/// @nodoc
class __$$PerformanceInsightImplCopyWithImpl<$Res>
    extends _$PerformanceInsightCopyWithImpl<$Res, _$PerformanceInsightImpl>
    implements _$$PerformanceInsightImplCopyWith<$Res> {
  __$$PerformanceInsightImplCopyWithImpl(_$PerformanceInsightImpl _value,
      $Res Function(_$PerformanceInsightImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? severity = null,
    Object? confidence = null,
    Object? actionItems = freezed,
    Object? data = freezed,
  }) {
    return _then(_$PerformanceInsightImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InsightType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as InsightSeverity,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      actionItems: freezed == actionItems
          ? _value._actionItems
          : actionItems // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PerformanceInsightImpl implements _PerformanceInsight {
  const _$PerformanceInsightImpl(
      {required this.type,
      required this.title,
      required this.description,
      required this.severity,
      required this.confidence,
      final List<String>? actionItems,
      final Map<String, dynamic>? data})
      : _actionItems = actionItems,
        _data = data;

  factory _$PerformanceInsightImpl.fromJson(Map<String, dynamic> json) =>
      _$$PerformanceInsightImplFromJson(json);

  @override
  final InsightType type;
  @override
  final String title;
  @override
  final String description;
  @override
  final InsightSeverity severity;
  @override
  final double confidence;
// 0-1.0
  final List<String>? _actionItems;
// 0-1.0
  @override
  List<String>? get actionItems {
    final value = _actionItems;
    if (value == null) return null;
    if (_actionItems is EqualUnmodifiableListView) return _actionItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'PerformanceInsight(type: $type, title: $title, description: $description, severity: $severity, confidence: $confidence, actionItems: $actionItems, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PerformanceInsightImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            const DeepCollectionEquality()
                .equals(other._actionItems, _actionItems) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      title,
      description,
      severity,
      confidence,
      const DeepCollectionEquality().hash(_actionItems),
      const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PerformanceInsightImplCopyWith<_$PerformanceInsightImpl> get copyWith =>
      __$$PerformanceInsightImplCopyWithImpl<_$PerformanceInsightImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PerformanceInsightImplToJson(
      this,
    );
  }
}

abstract class _PerformanceInsight implements PerformanceInsight {
  const factory _PerformanceInsight(
      {required final InsightType type,
      required final String title,
      required final String description,
      required final InsightSeverity severity,
      required final double confidence,
      final List<String>? actionItems,
      final Map<String, dynamic>? data}) = _$PerformanceInsightImpl;

  factory _PerformanceInsight.fromJson(Map<String, dynamic> json) =
      _$PerformanceInsightImpl.fromJson;

  @override
  InsightType get type;
  @override
  String get title;
  @override
  String get description;
  @override
  InsightSeverity get severity;
  @override
  double get confidence;
  @override // 0-1.0
  List<String>? get actionItems;
  @override
  Map<String, dynamic>? get data;
  @override
  @JsonKey(ignore: true)
  _$$PerformanceInsightImplCopyWith<_$PerformanceInsightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PersonalizedRecommendation _$PersonalizedRecommendationFromJson(
    Map<String, dynamic> json) {
  return _PersonalizedRecommendation.fromJson(json);
}

/// @nodoc
mixin _$PersonalizedRecommendation {
  String get userId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  RecommendationType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get priority => throw _privateConstructorUsedError; // 0-1.0
  List<RecommendationAction> get actions => throw _privateConstructorUsedError;
  String get reasoning => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  bool? get implemented => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PersonalizedRecommendationCopyWith<PersonalizedRecommendation>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonalizedRecommendationCopyWith<$Res> {
  factory $PersonalizedRecommendationCopyWith(PersonalizedRecommendation value,
          $Res Function(PersonalizedRecommendation) then) =
      _$PersonalizedRecommendationCopyWithImpl<$Res,
          PersonalizedRecommendation>;
  @useResult
  $Res call(
      {String userId,
      DateTime createdAt,
      RecommendationType type,
      String title,
      String description,
      double priority,
      List<RecommendationAction> actions,
      String reasoning,
      DateTime? expiresAt,
      bool? implemented,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$PersonalizedRecommendationCopyWithImpl<$Res,
        $Val extends PersonalizedRecommendation>
    implements $PersonalizedRecommendationCopyWith<$Res> {
  _$PersonalizedRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? createdAt = null,
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? priority = null,
    Object? actions = null,
    Object? reasoning = null,
    Object? expiresAt = freezed,
    Object? implemented = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RecommendationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as double,
      actions: null == actions
          ? _value.actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<RecommendationAction>,
      reasoning: null == reasoning
          ? _value.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      implemented: freezed == implemented
          ? _value.implemented
          : implemented // ignore: cast_nullable_to_non_nullable
              as bool?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PersonalizedRecommendationImplCopyWith<$Res>
    implements $PersonalizedRecommendationCopyWith<$Res> {
  factory _$$PersonalizedRecommendationImplCopyWith(
          _$PersonalizedRecommendationImpl value,
          $Res Function(_$PersonalizedRecommendationImpl) then) =
      __$$PersonalizedRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      DateTime createdAt,
      RecommendationType type,
      String title,
      String description,
      double priority,
      List<RecommendationAction> actions,
      String reasoning,
      DateTime? expiresAt,
      bool? implemented,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$PersonalizedRecommendationImplCopyWithImpl<$Res>
    extends _$PersonalizedRecommendationCopyWithImpl<$Res,
        _$PersonalizedRecommendationImpl>
    implements _$$PersonalizedRecommendationImplCopyWith<$Res> {
  __$$PersonalizedRecommendationImplCopyWithImpl(
      _$PersonalizedRecommendationImpl _value,
      $Res Function(_$PersonalizedRecommendationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? createdAt = null,
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? priority = null,
    Object? actions = null,
    Object? reasoning = null,
    Object? expiresAt = freezed,
    Object? implemented = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$PersonalizedRecommendationImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RecommendationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as double,
      actions: null == actions
          ? _value._actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<RecommendationAction>,
      reasoning: null == reasoning
          ? _value.reasoning
          : reasoning // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      implemented: freezed == implemented
          ? _value.implemented
          : implemented // ignore: cast_nullable_to_non_nullable
              as bool?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonalizedRecommendationImpl implements _PersonalizedRecommendation {
  const _$PersonalizedRecommendationImpl(
      {required this.userId,
      required this.createdAt,
      required this.type,
      required this.title,
      required this.description,
      required this.priority,
      required final List<RecommendationAction> actions,
      required this.reasoning,
      this.expiresAt,
      this.implemented,
      final Map<String, dynamic>? metadata})
      : _actions = actions,
        _metadata = metadata;

  factory _$PersonalizedRecommendationImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$PersonalizedRecommendationImplFromJson(json);

  @override
  final String userId;
  @override
  final DateTime createdAt;
  @override
  final RecommendationType type;
  @override
  final String title;
  @override
  final String description;
  @override
  final double priority;
// 0-1.0
  final List<RecommendationAction> _actions;
// 0-1.0
  @override
  List<RecommendationAction> get actions {
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actions);
  }

  @override
  final String reasoning;
  @override
  final DateTime? expiresAt;
  @override
  final bool? implemented;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'PersonalizedRecommendation(userId: $userId, createdAt: $createdAt, type: $type, title: $title, description: $description, priority: $priority, actions: $actions, reasoning: $reasoning, expiresAt: $expiresAt, implemented: $implemented, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonalizedRecommendationImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            (identical(other.reasoning, reasoning) ||
                other.reasoning == reasoning) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.implemented, implemented) ||
                other.implemented == implemented) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      createdAt,
      type,
      title,
      description,
      priority,
      const DeepCollectionEquality().hash(_actions),
      reasoning,
      expiresAt,
      implemented,
      const DeepCollectionEquality().hash(_metadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonalizedRecommendationImplCopyWith<_$PersonalizedRecommendationImpl>
      get copyWith => __$$PersonalizedRecommendationImplCopyWithImpl<
          _$PersonalizedRecommendationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonalizedRecommendationImplToJson(
      this,
    );
  }
}

abstract class _PersonalizedRecommendation
    implements PersonalizedRecommendation {
  const factory _PersonalizedRecommendation(
      {required final String userId,
      required final DateTime createdAt,
      required final RecommendationType type,
      required final String title,
      required final String description,
      required final double priority,
      required final List<RecommendationAction> actions,
      required final String reasoning,
      final DateTime? expiresAt,
      final bool? implemented,
      final Map<String, dynamic>? metadata}) = _$PersonalizedRecommendationImpl;

  factory _PersonalizedRecommendation.fromJson(Map<String, dynamic> json) =
      _$PersonalizedRecommendationImpl.fromJson;

  @override
  String get userId;
  @override
  DateTime get createdAt;
  @override
  RecommendationType get type;
  @override
  String get title;
  @override
  String get description;
  @override
  double get priority;
  @override // 0-1.0
  List<RecommendationAction> get actions;
  @override
  String get reasoning;
  @override
  DateTime? get expiresAt;
  @override
  bool? get implemented;
  @override
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(ignore: true)
  _$$PersonalizedRecommendationImplCopyWith<_$PersonalizedRecommendationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RecommendationAction _$RecommendationActionFromJson(Map<String, dynamic> json) {
  return _RecommendationAction.fromJson(json);
}

/// @nodoc
mixin _$RecommendationAction {
  String get actionType => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  Map<String, dynamic>? get parameters => throw _privateConstructorUsedError;
  bool? get completed => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecommendationActionCopyWith<RecommendationAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationActionCopyWith<$Res> {
  factory $RecommendationActionCopyWith(RecommendationAction value,
          $Res Function(RecommendationAction) then) =
      _$RecommendationActionCopyWithImpl<$Res, RecommendationAction>;
  @useResult
  $Res call(
      {String actionType,
      String description,
      Map<String, dynamic>? parameters,
      bool? completed});
}

/// @nodoc
class _$RecommendationActionCopyWithImpl<$Res,
        $Val extends RecommendationAction>
    implements $RecommendationActionCopyWith<$Res> {
  _$RecommendationActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actionType = null,
    Object? description = null,
    Object? parameters = freezed,
    Object? completed = freezed,
  }) {
    return _then(_value.copyWith(
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      parameters: freezed == parameters
          ? _value.parameters
          : parameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      completed: freezed == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecommendationActionImplCopyWith<$Res>
    implements $RecommendationActionCopyWith<$Res> {
  factory _$$RecommendationActionImplCopyWith(_$RecommendationActionImpl value,
          $Res Function(_$RecommendationActionImpl) then) =
      __$$RecommendationActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String actionType,
      String description,
      Map<String, dynamic>? parameters,
      bool? completed});
}

/// @nodoc
class __$$RecommendationActionImplCopyWithImpl<$Res>
    extends _$RecommendationActionCopyWithImpl<$Res, _$RecommendationActionImpl>
    implements _$$RecommendationActionImplCopyWith<$Res> {
  __$$RecommendationActionImplCopyWithImpl(_$RecommendationActionImpl _value,
      $Res Function(_$RecommendationActionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actionType = null,
    Object? description = null,
    Object? parameters = freezed,
    Object? completed = freezed,
  }) {
    return _then(_$RecommendationActionImpl(
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      parameters: freezed == parameters
          ? _value._parameters
          : parameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      completed: freezed == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendationActionImpl implements _RecommendationAction {
  const _$RecommendationActionImpl(
      {required this.actionType,
      required this.description,
      final Map<String, dynamic>? parameters,
      this.completed})
      : _parameters = parameters;

  factory _$RecommendationActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendationActionImplFromJson(json);

  @override
  final String actionType;
  @override
  final String description;
  final Map<String, dynamic>? _parameters;
  @override
  Map<String, dynamic>? get parameters {
    final value = _parameters;
    if (value == null) return null;
    if (_parameters is EqualUnmodifiableMapView) return _parameters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final bool? completed;

  @override
  String toString() {
    return 'RecommendationAction(actionType: $actionType, description: $description, parameters: $parameters, completed: $completed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationActionImpl &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._parameters, _parameters) &&
            (identical(other.completed, completed) ||
                other.completed == completed));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, actionType, description,
      const DeepCollectionEquality().hash(_parameters), completed);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationActionImplCopyWith<_$RecommendationActionImpl>
      get copyWith =>
          __$$RecommendationActionImplCopyWithImpl<_$RecommendationActionImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationActionImplToJson(
      this,
    );
  }
}

abstract class _RecommendationAction implements RecommendationAction {
  const factory _RecommendationAction(
      {required final String actionType,
      required final String description,
      final Map<String, dynamic>? parameters,
      final bool? completed}) = _$RecommendationActionImpl;

  factory _RecommendationAction.fromJson(Map<String, dynamic> json) =
      _$RecommendationActionImpl.fromJson;

  @override
  String get actionType;
  @override
  String get description;
  @override
  Map<String, dynamic>? get parameters;
  @override
  bool? get completed;
  @override
  @JsonKey(ignore: true)
  _$$RecommendationActionImplCopyWith<_$RecommendationActionImpl>
      get copyWith => throw _privateConstructorUsedError;
}

InjuryRiskAssessment _$InjuryRiskAssessmentFromJson(Map<String, dynamic> json) {
  return _InjuryRiskAssessment.fromJson(json);
}

/// @nodoc
mixin _$InjuryRiskAssessment {
  String get userId => throw _privateConstructorUsedError;
  DateTime get assessmentDate => throw _privateConstructorUsedError;
  double get overallRiskScore => throw _privateConstructorUsedError; // 0-100
  List<RiskFactor> get riskFactors => throw _privateConstructorUsedError;
  List<PreventionRecommendation> get preventions =>
      throw _privateConstructorUsedError;
  Map<String, double> get bodyPartRisks =>
      throw _privateConstructorUsedError; // 신체 부위별 위험도
  DateTime? get nextAssessmentDue => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InjuryRiskAssessmentCopyWith<InjuryRiskAssessment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InjuryRiskAssessmentCopyWith<$Res> {
  factory $InjuryRiskAssessmentCopyWith(InjuryRiskAssessment value,
          $Res Function(InjuryRiskAssessment) then) =
      _$InjuryRiskAssessmentCopyWithImpl<$Res, InjuryRiskAssessment>;
  @useResult
  $Res call(
      {String userId,
      DateTime assessmentDate,
      double overallRiskScore,
      List<RiskFactor> riskFactors,
      List<PreventionRecommendation> preventions,
      Map<String, double> bodyPartRisks,
      DateTime? nextAssessmentDue});
}

/// @nodoc
class _$InjuryRiskAssessmentCopyWithImpl<$Res,
        $Val extends InjuryRiskAssessment>
    implements $InjuryRiskAssessmentCopyWith<$Res> {
  _$InjuryRiskAssessmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? assessmentDate = null,
    Object? overallRiskScore = null,
    Object? riskFactors = null,
    Object? preventions = null,
    Object? bodyPartRisks = null,
    Object? nextAssessmentDue = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      assessmentDate: null == assessmentDate
          ? _value.assessmentDate
          : assessmentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      overallRiskScore: null == overallRiskScore
          ? _value.overallRiskScore
          : overallRiskScore // ignore: cast_nullable_to_non_nullable
              as double,
      riskFactors: null == riskFactors
          ? _value.riskFactors
          : riskFactors // ignore: cast_nullable_to_non_nullable
              as List<RiskFactor>,
      preventions: null == preventions
          ? _value.preventions
          : preventions // ignore: cast_nullable_to_non_nullable
              as List<PreventionRecommendation>,
      bodyPartRisks: null == bodyPartRisks
          ? _value.bodyPartRisks
          : bodyPartRisks // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      nextAssessmentDue: freezed == nextAssessmentDue
          ? _value.nextAssessmentDue
          : nextAssessmentDue // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InjuryRiskAssessmentImplCopyWith<$Res>
    implements $InjuryRiskAssessmentCopyWith<$Res> {
  factory _$$InjuryRiskAssessmentImplCopyWith(_$InjuryRiskAssessmentImpl value,
          $Res Function(_$InjuryRiskAssessmentImpl) then) =
      __$$InjuryRiskAssessmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      DateTime assessmentDate,
      double overallRiskScore,
      List<RiskFactor> riskFactors,
      List<PreventionRecommendation> preventions,
      Map<String, double> bodyPartRisks,
      DateTime? nextAssessmentDue});
}

/// @nodoc
class __$$InjuryRiskAssessmentImplCopyWithImpl<$Res>
    extends _$InjuryRiskAssessmentCopyWithImpl<$Res, _$InjuryRiskAssessmentImpl>
    implements _$$InjuryRiskAssessmentImplCopyWith<$Res> {
  __$$InjuryRiskAssessmentImplCopyWithImpl(_$InjuryRiskAssessmentImpl _value,
      $Res Function(_$InjuryRiskAssessmentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? assessmentDate = null,
    Object? overallRiskScore = null,
    Object? riskFactors = null,
    Object? preventions = null,
    Object? bodyPartRisks = null,
    Object? nextAssessmentDue = freezed,
  }) {
    return _then(_$InjuryRiskAssessmentImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      assessmentDate: null == assessmentDate
          ? _value.assessmentDate
          : assessmentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      overallRiskScore: null == overallRiskScore
          ? _value.overallRiskScore
          : overallRiskScore // ignore: cast_nullable_to_non_nullable
              as double,
      riskFactors: null == riskFactors
          ? _value._riskFactors
          : riskFactors // ignore: cast_nullable_to_non_nullable
              as List<RiskFactor>,
      preventions: null == preventions
          ? _value._preventions
          : preventions // ignore: cast_nullable_to_non_nullable
              as List<PreventionRecommendation>,
      bodyPartRisks: null == bodyPartRisks
          ? _value._bodyPartRisks
          : bodyPartRisks // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      nextAssessmentDue: freezed == nextAssessmentDue
          ? _value.nextAssessmentDue
          : nextAssessmentDue // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InjuryRiskAssessmentImpl implements _InjuryRiskAssessment {
  const _$InjuryRiskAssessmentImpl(
      {required this.userId,
      required this.assessmentDate,
      required this.overallRiskScore,
      required final List<RiskFactor> riskFactors,
      required final List<PreventionRecommendation> preventions,
      required final Map<String, double> bodyPartRisks,
      this.nextAssessmentDue})
      : _riskFactors = riskFactors,
        _preventions = preventions,
        _bodyPartRisks = bodyPartRisks;

  factory _$InjuryRiskAssessmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$InjuryRiskAssessmentImplFromJson(json);

  @override
  final String userId;
  @override
  final DateTime assessmentDate;
  @override
  final double overallRiskScore;
// 0-100
  final List<RiskFactor> _riskFactors;
// 0-100
  @override
  List<RiskFactor> get riskFactors {
    if (_riskFactors is EqualUnmodifiableListView) return _riskFactors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_riskFactors);
  }

  final List<PreventionRecommendation> _preventions;
  @override
  List<PreventionRecommendation> get preventions {
    if (_preventions is EqualUnmodifiableListView) return _preventions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preventions);
  }

  final Map<String, double> _bodyPartRisks;
  @override
  Map<String, double> get bodyPartRisks {
    if (_bodyPartRisks is EqualUnmodifiableMapView) return _bodyPartRisks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_bodyPartRisks);
  }

// 신체 부위별 위험도
  @override
  final DateTime? nextAssessmentDue;

  @override
  String toString() {
    return 'InjuryRiskAssessment(userId: $userId, assessmentDate: $assessmentDate, overallRiskScore: $overallRiskScore, riskFactors: $riskFactors, preventions: $preventions, bodyPartRisks: $bodyPartRisks, nextAssessmentDue: $nextAssessmentDue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InjuryRiskAssessmentImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.assessmentDate, assessmentDate) ||
                other.assessmentDate == assessmentDate) &&
            (identical(other.overallRiskScore, overallRiskScore) ||
                other.overallRiskScore == overallRiskScore) &&
            const DeepCollectionEquality()
                .equals(other._riskFactors, _riskFactors) &&
            const DeepCollectionEquality()
                .equals(other._preventions, _preventions) &&
            const DeepCollectionEquality()
                .equals(other._bodyPartRisks, _bodyPartRisks) &&
            (identical(other.nextAssessmentDue, nextAssessmentDue) ||
                other.nextAssessmentDue == nextAssessmentDue));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      assessmentDate,
      overallRiskScore,
      const DeepCollectionEquality().hash(_riskFactors),
      const DeepCollectionEquality().hash(_preventions),
      const DeepCollectionEquality().hash(_bodyPartRisks),
      nextAssessmentDue);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InjuryRiskAssessmentImplCopyWith<_$InjuryRiskAssessmentImpl>
      get copyWith =>
          __$$InjuryRiskAssessmentImplCopyWithImpl<_$InjuryRiskAssessmentImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InjuryRiskAssessmentImplToJson(
      this,
    );
  }
}

abstract class _InjuryRiskAssessment implements InjuryRiskAssessment {
  const factory _InjuryRiskAssessment(
      {required final String userId,
      required final DateTime assessmentDate,
      required final double overallRiskScore,
      required final List<RiskFactor> riskFactors,
      required final List<PreventionRecommendation> preventions,
      required final Map<String, double> bodyPartRisks,
      final DateTime? nextAssessmentDue}) = _$InjuryRiskAssessmentImpl;

  factory _InjuryRiskAssessment.fromJson(Map<String, dynamic> json) =
      _$InjuryRiskAssessmentImpl.fromJson;

  @override
  String get userId;
  @override
  DateTime get assessmentDate;
  @override
  double get overallRiskScore;
  @override // 0-100
  List<RiskFactor> get riskFactors;
  @override
  List<PreventionRecommendation> get preventions;
  @override
  Map<String, double> get bodyPartRisks;
  @override // 신체 부위별 위험도
  DateTime? get nextAssessmentDue;
  @override
  @JsonKey(ignore: true)
  _$$InjuryRiskAssessmentImplCopyWith<_$InjuryRiskAssessmentImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RiskFactor _$RiskFactorFromJson(Map<String, dynamic> json) {
  return _RiskFactor.fromJson(json);
}

/// @nodoc
mixin _$RiskFactor {
  String get factor => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError; // 0-10
  String get description => throw _privateConstructorUsedError;
  RiskCategory get category => throw _privateConstructorUsedError;
  List<String>? get mitigationSteps => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RiskFactorCopyWith<RiskFactor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RiskFactorCopyWith<$Res> {
  factory $RiskFactorCopyWith(
          RiskFactor value, $Res Function(RiskFactor) then) =
      _$RiskFactorCopyWithImpl<$Res, RiskFactor>;
  @useResult
  $Res call(
      {String factor,
      double score,
      String description,
      RiskCategory category,
      List<String>? mitigationSteps});
}

/// @nodoc
class _$RiskFactorCopyWithImpl<$Res, $Val extends RiskFactor>
    implements $RiskFactorCopyWith<$Res> {
  _$RiskFactorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? factor = null,
    Object? score = null,
    Object? description = null,
    Object? category = null,
    Object? mitigationSteps = freezed,
  }) {
    return _then(_value.copyWith(
      factor: null == factor
          ? _value.factor
          : factor // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as RiskCategory,
      mitigationSteps: freezed == mitigationSteps
          ? _value.mitigationSteps
          : mitigationSteps // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RiskFactorImplCopyWith<$Res>
    implements $RiskFactorCopyWith<$Res> {
  factory _$$RiskFactorImplCopyWith(
          _$RiskFactorImpl value, $Res Function(_$RiskFactorImpl) then) =
      __$$RiskFactorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String factor,
      double score,
      String description,
      RiskCategory category,
      List<String>? mitigationSteps});
}

/// @nodoc
class __$$RiskFactorImplCopyWithImpl<$Res>
    extends _$RiskFactorCopyWithImpl<$Res, _$RiskFactorImpl>
    implements _$$RiskFactorImplCopyWith<$Res> {
  __$$RiskFactorImplCopyWithImpl(
      _$RiskFactorImpl _value, $Res Function(_$RiskFactorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? factor = null,
    Object? score = null,
    Object? description = null,
    Object? category = null,
    Object? mitigationSteps = freezed,
  }) {
    return _then(_$RiskFactorImpl(
      factor: null == factor
          ? _value.factor
          : factor // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as RiskCategory,
      mitigationSteps: freezed == mitigationSteps
          ? _value._mitigationSteps
          : mitigationSteps // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RiskFactorImpl implements _RiskFactor {
  const _$RiskFactorImpl(
      {required this.factor,
      required this.score,
      required this.description,
      required this.category,
      final List<String>? mitigationSteps})
      : _mitigationSteps = mitigationSteps;

  factory _$RiskFactorImpl.fromJson(Map<String, dynamic> json) =>
      _$$RiskFactorImplFromJson(json);

  @override
  final String factor;
  @override
  final double score;
// 0-10
  @override
  final String description;
  @override
  final RiskCategory category;
  final List<String>? _mitigationSteps;
  @override
  List<String>? get mitigationSteps {
    final value = _mitigationSteps;
    if (value == null) return null;
    if (_mitigationSteps is EqualUnmodifiableListView) return _mitigationSteps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'RiskFactor(factor: $factor, score: $score, description: $description, category: $category, mitigationSteps: $mitigationSteps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RiskFactorImpl &&
            (identical(other.factor, factor) || other.factor == factor) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality()
                .equals(other._mitigationSteps, _mitigationSteps));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, factor, score, description,
      category, const DeepCollectionEquality().hash(_mitigationSteps));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RiskFactorImplCopyWith<_$RiskFactorImpl> get copyWith =>
      __$$RiskFactorImplCopyWithImpl<_$RiskFactorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RiskFactorImplToJson(
      this,
    );
  }
}

abstract class _RiskFactor implements RiskFactor {
  const factory _RiskFactor(
      {required final String factor,
      required final double score,
      required final String description,
      required final RiskCategory category,
      final List<String>? mitigationSteps}) = _$RiskFactorImpl;

  factory _RiskFactor.fromJson(Map<String, dynamic> json) =
      _$RiskFactorImpl.fromJson;

  @override
  String get factor;
  @override
  double get score;
  @override // 0-10
  String get description;
  @override
  RiskCategory get category;
  @override
  List<String>? get mitigationSteps;
  @override
  @JsonKey(ignore: true)
  _$$RiskFactorImplCopyWith<_$RiskFactorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PreventionRecommendation _$PreventionRecommendationFromJson(
    Map<String, dynamic> json) {
  return _PreventionRecommendation.fromJson(json);
}

/// @nodoc
mixin _$PreventionRecommendation {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  PreventionType get type => throw _privateConstructorUsedError;
  int get priorityLevel => throw _privateConstructorUsedError; // 1-5
  List<String>? get exercises => throw _privateConstructorUsedError;
  Map<String, dynamic>? get parameters => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PreventionRecommendationCopyWith<PreventionRecommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreventionRecommendationCopyWith<$Res> {
  factory $PreventionRecommendationCopyWith(PreventionRecommendation value,
          $Res Function(PreventionRecommendation) then) =
      _$PreventionRecommendationCopyWithImpl<$Res, PreventionRecommendation>;
  @useResult
  $Res call(
      {String title,
      String description,
      PreventionType type,
      int priorityLevel,
      List<String>? exercises,
      Map<String, dynamic>? parameters});
}

/// @nodoc
class _$PreventionRecommendationCopyWithImpl<$Res,
        $Val extends PreventionRecommendation>
    implements $PreventionRecommendationCopyWith<$Res> {
  _$PreventionRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? priorityLevel = null,
    Object? exercises = freezed,
    Object? parameters = freezed,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PreventionType,
      priorityLevel: null == priorityLevel
          ? _value.priorityLevel
          : priorityLevel // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: freezed == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      parameters: freezed == parameters
          ? _value.parameters
          : parameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PreventionRecommendationImplCopyWith<$Res>
    implements $PreventionRecommendationCopyWith<$Res> {
  factory _$$PreventionRecommendationImplCopyWith(
          _$PreventionRecommendationImpl value,
          $Res Function(_$PreventionRecommendationImpl) then) =
      __$$PreventionRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String description,
      PreventionType type,
      int priorityLevel,
      List<String>? exercises,
      Map<String, dynamic>? parameters});
}

/// @nodoc
class __$$PreventionRecommendationImplCopyWithImpl<$Res>
    extends _$PreventionRecommendationCopyWithImpl<$Res,
        _$PreventionRecommendationImpl>
    implements _$$PreventionRecommendationImplCopyWith<$Res> {
  __$$PreventionRecommendationImplCopyWithImpl(
      _$PreventionRecommendationImpl _value,
      $Res Function(_$PreventionRecommendationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? priorityLevel = null,
    Object? exercises = freezed,
    Object? parameters = freezed,
  }) {
    return _then(_$PreventionRecommendationImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PreventionType,
      priorityLevel: null == priorityLevel
          ? _value.priorityLevel
          : priorityLevel // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: freezed == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      parameters: freezed == parameters
          ? _value._parameters
          : parameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PreventionRecommendationImpl implements _PreventionRecommendation {
  const _$PreventionRecommendationImpl(
      {required this.title,
      required this.description,
      required this.type,
      required this.priorityLevel,
      final List<String>? exercises,
      final Map<String, dynamic>? parameters})
      : _exercises = exercises,
        _parameters = parameters;

  factory _$PreventionRecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$PreventionRecommendationImplFromJson(json);

  @override
  final String title;
  @override
  final String description;
  @override
  final PreventionType type;
  @override
  final int priorityLevel;
// 1-5
  final List<String>? _exercises;
// 1-5
  @override
  List<String>? get exercises {
    final value = _exercises;
    if (value == null) return null;
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _parameters;
  @override
  Map<String, dynamic>? get parameters {
    final value = _parameters;
    if (value == null) return null;
    if (_parameters is EqualUnmodifiableMapView) return _parameters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'PreventionRecommendation(title: $title, description: $description, type: $type, priorityLevel: $priorityLevel, exercises: $exercises, parameters: $parameters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreventionRecommendationImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.priorityLevel, priorityLevel) ||
                other.priorityLevel == priorityLevel) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises) &&
            const DeepCollectionEquality()
                .equals(other._parameters, _parameters));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      description,
      type,
      priorityLevel,
      const DeepCollectionEquality().hash(_exercises),
      const DeepCollectionEquality().hash(_parameters));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PreventionRecommendationImplCopyWith<_$PreventionRecommendationImpl>
      get copyWith => __$$PreventionRecommendationImplCopyWithImpl<
          _$PreventionRecommendationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PreventionRecommendationImplToJson(
      this,
    );
  }
}

abstract class _PreventionRecommendation implements PreventionRecommendation {
  const factory _PreventionRecommendation(
      {required final String title,
      required final String description,
      required final PreventionType type,
      required final int priorityLevel,
      final List<String>? exercises,
      final Map<String, dynamic>? parameters}) = _$PreventionRecommendationImpl;

  factory _PreventionRecommendation.fromJson(Map<String, dynamic> json) =
      _$PreventionRecommendationImpl.fromJson;

  @override
  String get title;
  @override
  String get description;
  @override
  PreventionType get type;
  @override
  int get priorityLevel;
  @override // 1-5
  List<String>? get exercises;
  @override
  Map<String, dynamic>? get parameters;
  @override
  @JsonKey(ignore: true)
  _$$PreventionRecommendationImplCopyWith<_$PreventionRecommendationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CoachingSession _$CoachingSessionFromJson(Map<String, dynamic> json) {
  return _CoachingSession.fromJson(json);
}

/// @nodoc
mixin _$CoachingSession {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get sessionStart => throw _privateConstructorUsedError;
  DateTime? get sessionEnd => throw _privateConstructorUsedError;
  CoachingType get type => throw _privateConstructorUsedError;
  List<CoachingMessage> get messages => throw _privateConstructorUsedError;
  SessionOutcome get outcome => throw _privateConstructorUsedError;
  Map<String, dynamic>? get context => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CoachingSessionCopyWith<CoachingSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoachingSessionCopyWith<$Res> {
  factory $CoachingSessionCopyWith(
          CoachingSession value, $Res Function(CoachingSession) then) =
      _$CoachingSessionCopyWithImpl<$Res, CoachingSession>;
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime sessionStart,
      DateTime? sessionEnd,
      CoachingType type,
      List<CoachingMessage> messages,
      SessionOutcome outcome,
      Map<String, dynamic>? context,
      List<String>? tags});

  $SessionOutcomeCopyWith<$Res> get outcome;
}

/// @nodoc
class _$CoachingSessionCopyWithImpl<$Res, $Val extends CoachingSession>
    implements $CoachingSessionCopyWith<$Res> {
  _$CoachingSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? sessionStart = null,
    Object? sessionEnd = freezed,
    Object? type = null,
    Object? messages = null,
    Object? outcome = null,
    Object? context = freezed,
    Object? tags = freezed,
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
      sessionStart: null == sessionStart
          ? _value.sessionStart
          : sessionStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sessionEnd: freezed == sessionEnd
          ? _value.sessionEnd
          : sessionEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CoachingType,
      messages: null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<CoachingMessage>,
      outcome: null == outcome
          ? _value.outcome
          : outcome // ignore: cast_nullable_to_non_nullable
              as SessionOutcome,
      context: freezed == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SessionOutcomeCopyWith<$Res> get outcome {
    return $SessionOutcomeCopyWith<$Res>(_value.outcome, (value) {
      return _then(_value.copyWith(outcome: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CoachingSessionImplCopyWith<$Res>
    implements $CoachingSessionCopyWith<$Res> {
  factory _$$CoachingSessionImplCopyWith(_$CoachingSessionImpl value,
          $Res Function(_$CoachingSessionImpl) then) =
      __$$CoachingSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime sessionStart,
      DateTime? sessionEnd,
      CoachingType type,
      List<CoachingMessage> messages,
      SessionOutcome outcome,
      Map<String, dynamic>? context,
      List<String>? tags});

  @override
  $SessionOutcomeCopyWith<$Res> get outcome;
}

/// @nodoc
class __$$CoachingSessionImplCopyWithImpl<$Res>
    extends _$CoachingSessionCopyWithImpl<$Res, _$CoachingSessionImpl>
    implements _$$CoachingSessionImplCopyWith<$Res> {
  __$$CoachingSessionImplCopyWithImpl(
      _$CoachingSessionImpl _value, $Res Function(_$CoachingSessionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? sessionStart = null,
    Object? sessionEnd = freezed,
    Object? type = null,
    Object? messages = null,
    Object? outcome = null,
    Object? context = freezed,
    Object? tags = freezed,
  }) {
    return _then(_$CoachingSessionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      sessionStart: null == sessionStart
          ? _value.sessionStart
          : sessionStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sessionEnd: freezed == sessionEnd
          ? _value.sessionEnd
          : sessionEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CoachingType,
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<CoachingMessage>,
      outcome: null == outcome
          ? _value.outcome
          : outcome // ignore: cast_nullable_to_non_nullable
              as SessionOutcome,
      context: freezed == context
          ? _value._context
          : context // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoachingSessionImpl implements _CoachingSession {
  const _$CoachingSessionImpl(
      {required this.id,
      required this.userId,
      required this.sessionStart,
      this.sessionEnd,
      required this.type,
      required final List<CoachingMessage> messages,
      required this.outcome,
      final Map<String, dynamic>? context,
      final List<String>? tags})
      : _messages = messages,
        _context = context,
        _tags = tags;

  factory _$CoachingSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoachingSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime sessionStart;
  @override
  final DateTime? sessionEnd;
  @override
  final CoachingType type;
  final List<CoachingMessage> _messages;
  @override
  List<CoachingMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final SessionOutcome outcome;
  final Map<String, dynamic>? _context;
  @override
  Map<String, dynamic>? get context {
    final value = _context;
    if (value == null) return null;
    if (_context is EqualUnmodifiableMapView) return _context;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'CoachingSession(id: $id, userId: $userId, sessionStart: $sessionStart, sessionEnd: $sessionEnd, type: $type, messages: $messages, outcome: $outcome, context: $context, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoachingSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.sessionStart, sessionStart) ||
                other.sessionStart == sessionStart) &&
            (identical(other.sessionEnd, sessionEnd) ||
                other.sessionEnd == sessionEnd) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.outcome, outcome) || other.outcome == outcome) &&
            const DeepCollectionEquality().equals(other._context, _context) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      sessionStart,
      sessionEnd,
      type,
      const DeepCollectionEquality().hash(_messages),
      outcome,
      const DeepCollectionEquality().hash(_context),
      const DeepCollectionEquality().hash(_tags));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CoachingSessionImplCopyWith<_$CoachingSessionImpl> get copyWith =>
      __$$CoachingSessionImplCopyWithImpl<_$CoachingSessionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoachingSessionImplToJson(
      this,
    );
  }
}

abstract class _CoachingSession implements CoachingSession {
  const factory _CoachingSession(
      {required final String id,
      required final String userId,
      required final DateTime sessionStart,
      final DateTime? sessionEnd,
      required final CoachingType type,
      required final List<CoachingMessage> messages,
      required final SessionOutcome outcome,
      final Map<String, dynamic>? context,
      final List<String>? tags}) = _$CoachingSessionImpl;

  factory _CoachingSession.fromJson(Map<String, dynamic> json) =
      _$CoachingSessionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  DateTime get sessionStart;
  @override
  DateTime? get sessionEnd;
  @override
  CoachingType get type;
  @override
  List<CoachingMessage> get messages;
  @override
  SessionOutcome get outcome;
  @override
  Map<String, dynamic>? get context;
  @override
  List<String>? get tags;
  @override
  @JsonKey(ignore: true)
  _$$CoachingSessionImplCopyWith<_$CoachingSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CoachingMessage _$CoachingMessageFromJson(Map<String, dynamic> json) {
  return _CoachingMessage.fromJson(json);
}

/// @nodoc
mixin _$CoachingMessage {
  DateTime get timestamp => throw _privateConstructorUsedError;
  MessageRole get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  MessageType? get type => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CoachingMessageCopyWith<CoachingMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoachingMessageCopyWith<$Res> {
  factory $CoachingMessageCopyWith(
          CoachingMessage value, $Res Function(CoachingMessage) then) =
      _$CoachingMessageCopyWithImpl<$Res, CoachingMessage>;
  @useResult
  $Res call(
      {DateTime timestamp,
      MessageRole role,
      String content,
      MessageType? type,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$CoachingMessageCopyWithImpl<$Res, $Val extends CoachingMessage>
    implements $CoachingMessageCopyWith<$Res> {
  _$CoachingMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? role = null,
    Object? content = null,
    Object? type = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as MessageRole,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CoachingMessageImplCopyWith<$Res>
    implements $CoachingMessageCopyWith<$Res> {
  factory _$$CoachingMessageImplCopyWith(_$CoachingMessageImpl value,
          $Res Function(_$CoachingMessageImpl) then) =
      __$$CoachingMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime timestamp,
      MessageRole role,
      String content,
      MessageType? type,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$CoachingMessageImplCopyWithImpl<$Res>
    extends _$CoachingMessageCopyWithImpl<$Res, _$CoachingMessageImpl>
    implements _$$CoachingMessageImplCopyWith<$Res> {
  __$$CoachingMessageImplCopyWithImpl(
      _$CoachingMessageImpl _value, $Res Function(_$CoachingMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? role = null,
    Object? content = null,
    Object? type = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$CoachingMessageImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as MessageRole,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoachingMessageImpl implements _CoachingMessage {
  const _$CoachingMessageImpl(
      {required this.timestamp,
      required this.role,
      required this.content,
      this.type,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$CoachingMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoachingMessageImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final MessageRole role;
  @override
  final String content;
  @override
  final MessageType? type;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'CoachingMessage(timestamp: $timestamp, role: $role, content: $content, type: $type, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoachingMessageImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, timestamp, role, content, type,
      const DeepCollectionEquality().hash(_metadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CoachingMessageImplCopyWith<_$CoachingMessageImpl> get copyWith =>
      __$$CoachingMessageImplCopyWithImpl<_$CoachingMessageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoachingMessageImplToJson(
      this,
    );
  }
}

abstract class _CoachingMessage implements CoachingMessage {
  const factory _CoachingMessage(
      {required final DateTime timestamp,
      required final MessageRole role,
      required final String content,
      final MessageType? type,
      final Map<String, dynamic>? metadata}) = _$CoachingMessageImpl;

  factory _CoachingMessage.fromJson(Map<String, dynamic> json) =
      _$CoachingMessageImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  MessageRole get role;
  @override
  String get content;
  @override
  MessageType? get type;
  @override
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(ignore: true)
  _$$CoachingMessageImplCopyWith<_$CoachingMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionOutcome _$SessionOutcomeFromJson(Map<String, dynamic> json) {
  return _SessionOutcome.fromJson(json);
}

/// @nodoc
mixin _$SessionOutcome {
  OutcomeType get type => throw _privateConstructorUsedError;
  double get satisfactionScore => throw _privateConstructorUsedError; // 0-10
  List<String>? get keyInsights => throw _privateConstructorUsedError;
  List<String>? get actionItems => throw _privateConstructorUsedError;
  DateTime? get followUpDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SessionOutcomeCopyWith<SessionOutcome> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionOutcomeCopyWith<$Res> {
  factory $SessionOutcomeCopyWith(
          SessionOutcome value, $Res Function(SessionOutcome) then) =
      _$SessionOutcomeCopyWithImpl<$Res, SessionOutcome>;
  @useResult
  $Res call(
      {OutcomeType type,
      double satisfactionScore,
      List<String>? keyInsights,
      List<String>? actionItems,
      DateTime? followUpDate});
}

/// @nodoc
class _$SessionOutcomeCopyWithImpl<$Res, $Val extends SessionOutcome>
    implements $SessionOutcomeCopyWith<$Res> {
  _$SessionOutcomeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? satisfactionScore = null,
    Object? keyInsights = freezed,
    Object? actionItems = freezed,
    Object? followUpDate = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as OutcomeType,
      satisfactionScore: null == satisfactionScore
          ? _value.satisfactionScore
          : satisfactionScore // ignore: cast_nullable_to_non_nullable
              as double,
      keyInsights: freezed == keyInsights
          ? _value.keyInsights
          : keyInsights // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      actionItems: freezed == actionItems
          ? _value.actionItems
          : actionItems // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      followUpDate: freezed == followUpDate
          ? _value.followUpDate
          : followUpDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionOutcomeImplCopyWith<$Res>
    implements $SessionOutcomeCopyWith<$Res> {
  factory _$$SessionOutcomeImplCopyWith(_$SessionOutcomeImpl value,
          $Res Function(_$SessionOutcomeImpl) then) =
      __$$SessionOutcomeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {OutcomeType type,
      double satisfactionScore,
      List<String>? keyInsights,
      List<String>? actionItems,
      DateTime? followUpDate});
}

/// @nodoc
class __$$SessionOutcomeImplCopyWithImpl<$Res>
    extends _$SessionOutcomeCopyWithImpl<$Res, _$SessionOutcomeImpl>
    implements _$$SessionOutcomeImplCopyWith<$Res> {
  __$$SessionOutcomeImplCopyWithImpl(
      _$SessionOutcomeImpl _value, $Res Function(_$SessionOutcomeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? satisfactionScore = null,
    Object? keyInsights = freezed,
    Object? actionItems = freezed,
    Object? followUpDate = freezed,
  }) {
    return _then(_$SessionOutcomeImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as OutcomeType,
      satisfactionScore: null == satisfactionScore
          ? _value.satisfactionScore
          : satisfactionScore // ignore: cast_nullable_to_non_nullable
              as double,
      keyInsights: freezed == keyInsights
          ? _value._keyInsights
          : keyInsights // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      actionItems: freezed == actionItems
          ? _value._actionItems
          : actionItems // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      followUpDate: freezed == followUpDate
          ? _value.followUpDate
          : followUpDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionOutcomeImpl implements _SessionOutcome {
  const _$SessionOutcomeImpl(
      {required this.type,
      required this.satisfactionScore,
      final List<String>? keyInsights,
      final List<String>? actionItems,
      this.followUpDate})
      : _keyInsights = keyInsights,
        _actionItems = actionItems;

  factory _$SessionOutcomeImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionOutcomeImplFromJson(json);

  @override
  final OutcomeType type;
  @override
  final double satisfactionScore;
// 0-10
  final List<String>? _keyInsights;
// 0-10
  @override
  List<String>? get keyInsights {
    final value = _keyInsights;
    if (value == null) return null;
    if (_keyInsights is EqualUnmodifiableListView) return _keyInsights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _actionItems;
  @override
  List<String>? get actionItems {
    final value = _actionItems;
    if (value == null) return null;
    if (_actionItems is EqualUnmodifiableListView) return _actionItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? followUpDate;

  @override
  String toString() {
    return 'SessionOutcome(type: $type, satisfactionScore: $satisfactionScore, keyInsights: $keyInsights, actionItems: $actionItems, followUpDate: $followUpDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionOutcomeImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.satisfactionScore, satisfactionScore) ||
                other.satisfactionScore == satisfactionScore) &&
            const DeepCollectionEquality()
                .equals(other._keyInsights, _keyInsights) &&
            const DeepCollectionEquality()
                .equals(other._actionItems, _actionItems) &&
            (identical(other.followUpDate, followUpDate) ||
                other.followUpDate == followUpDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      satisfactionScore,
      const DeepCollectionEquality().hash(_keyInsights),
      const DeepCollectionEquality().hash(_actionItems),
      followUpDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionOutcomeImplCopyWith<_$SessionOutcomeImpl> get copyWith =>
      __$$SessionOutcomeImplCopyWithImpl<_$SessionOutcomeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionOutcomeImplToJson(
      this,
    );
  }
}

abstract class _SessionOutcome implements SessionOutcome {
  const factory _SessionOutcome(
      {required final OutcomeType type,
      required final double satisfactionScore,
      final List<String>? keyInsights,
      final List<String>? actionItems,
      final DateTime? followUpDate}) = _$SessionOutcomeImpl;

  factory _SessionOutcome.fromJson(Map<String, dynamic> json) =
      _$SessionOutcomeImpl.fromJson;

  @override
  OutcomeType get type;
  @override
  double get satisfactionScore;
  @override // 0-10
  List<String>? get keyInsights;
  @override
  List<String>? get actionItems;
  @override
  DateTime? get followUpDate;
  @override
  @JsonKey(ignore: true)
  _$$SessionOutcomeImplCopyWith<_$SessionOutcomeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FormAnalysis _$FormAnalysisFromJson(Map<String, dynamic> json) {
  return _FormAnalysis.fromJson(json);
}

/// @nodoc
mixin _$FormAnalysis {
  String get exerciseId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get analysisDate => throw _privateConstructorUsedError;
  double get overallFormScore => throw _privateConstructorUsedError; // 0-100
  List<FormFeedback> get feedback => throw _privateConstructorUsedError;
  List<FormCorrection> get corrections => throw _privateConstructorUsedError;
  String? get videoPath => throw _privateConstructorUsedError;
  Map<String, dynamic>? get biomechanicsData =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FormAnalysisCopyWith<FormAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FormAnalysisCopyWith<$Res> {
  factory $FormAnalysisCopyWith(
          FormAnalysis value, $Res Function(FormAnalysis) then) =
      _$FormAnalysisCopyWithImpl<$Res, FormAnalysis>;
  @useResult
  $Res call(
      {String exerciseId,
      String userId,
      DateTime analysisDate,
      double overallFormScore,
      List<FormFeedback> feedback,
      List<FormCorrection> corrections,
      String? videoPath,
      Map<String, dynamic>? biomechanicsData});
}

/// @nodoc
class _$FormAnalysisCopyWithImpl<$Res, $Val extends FormAnalysis>
    implements $FormAnalysisCopyWith<$Res> {
  _$FormAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? userId = null,
    Object? analysisDate = null,
    Object? overallFormScore = null,
    Object? feedback = null,
    Object? corrections = null,
    Object? videoPath = freezed,
    Object? biomechanicsData = freezed,
  }) {
    return _then(_value.copyWith(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      analysisDate: null == analysisDate
          ? _value.analysisDate
          : analysisDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      overallFormScore: null == overallFormScore
          ? _value.overallFormScore
          : overallFormScore // ignore: cast_nullable_to_non_nullable
              as double,
      feedback: null == feedback
          ? _value.feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as List<FormFeedback>,
      corrections: null == corrections
          ? _value.corrections
          : corrections // ignore: cast_nullable_to_non_nullable
              as List<FormCorrection>,
      videoPath: freezed == videoPath
          ? _value.videoPath
          : videoPath // ignore: cast_nullable_to_non_nullable
              as String?,
      biomechanicsData: freezed == biomechanicsData
          ? _value.biomechanicsData
          : biomechanicsData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FormAnalysisImplCopyWith<$Res>
    implements $FormAnalysisCopyWith<$Res> {
  factory _$$FormAnalysisImplCopyWith(
          _$FormAnalysisImpl value, $Res Function(_$FormAnalysisImpl) then) =
      __$$FormAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseId,
      String userId,
      DateTime analysisDate,
      double overallFormScore,
      List<FormFeedback> feedback,
      List<FormCorrection> corrections,
      String? videoPath,
      Map<String, dynamic>? biomechanicsData});
}

/// @nodoc
class __$$FormAnalysisImplCopyWithImpl<$Res>
    extends _$FormAnalysisCopyWithImpl<$Res, _$FormAnalysisImpl>
    implements _$$FormAnalysisImplCopyWith<$Res> {
  __$$FormAnalysisImplCopyWithImpl(
      _$FormAnalysisImpl _value, $Res Function(_$FormAnalysisImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? userId = null,
    Object? analysisDate = null,
    Object? overallFormScore = null,
    Object? feedback = null,
    Object? corrections = null,
    Object? videoPath = freezed,
    Object? biomechanicsData = freezed,
  }) {
    return _then(_$FormAnalysisImpl(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      analysisDate: null == analysisDate
          ? _value.analysisDate
          : analysisDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      overallFormScore: null == overallFormScore
          ? _value.overallFormScore
          : overallFormScore // ignore: cast_nullable_to_non_nullable
              as double,
      feedback: null == feedback
          ? _value._feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as List<FormFeedback>,
      corrections: null == corrections
          ? _value._corrections
          : corrections // ignore: cast_nullable_to_non_nullable
              as List<FormCorrection>,
      videoPath: freezed == videoPath
          ? _value.videoPath
          : videoPath // ignore: cast_nullable_to_non_nullable
              as String?,
      biomechanicsData: freezed == biomechanicsData
          ? _value._biomechanicsData
          : biomechanicsData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FormAnalysisImpl implements _FormAnalysis {
  const _$FormAnalysisImpl(
      {required this.exerciseId,
      required this.userId,
      required this.analysisDate,
      required this.overallFormScore,
      required final List<FormFeedback> feedback,
      required final List<FormCorrection> corrections,
      this.videoPath,
      final Map<String, dynamic>? biomechanicsData})
      : _feedback = feedback,
        _corrections = corrections,
        _biomechanicsData = biomechanicsData;

  factory _$FormAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$FormAnalysisImplFromJson(json);

  @override
  final String exerciseId;
  @override
  final String userId;
  @override
  final DateTime analysisDate;
  @override
  final double overallFormScore;
// 0-100
  final List<FormFeedback> _feedback;
// 0-100
  @override
  List<FormFeedback> get feedback {
    if (_feedback is EqualUnmodifiableListView) return _feedback;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_feedback);
  }

  final List<FormCorrection> _corrections;
  @override
  List<FormCorrection> get corrections {
    if (_corrections is EqualUnmodifiableListView) return _corrections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_corrections);
  }

  @override
  final String? videoPath;
  final Map<String, dynamic>? _biomechanicsData;
  @override
  Map<String, dynamic>? get biomechanicsData {
    final value = _biomechanicsData;
    if (value == null) return null;
    if (_biomechanicsData is EqualUnmodifiableMapView) return _biomechanicsData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'FormAnalysis(exerciseId: $exerciseId, userId: $userId, analysisDate: $analysisDate, overallFormScore: $overallFormScore, feedback: $feedback, corrections: $corrections, videoPath: $videoPath, biomechanicsData: $biomechanicsData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FormAnalysisImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.analysisDate, analysisDate) ||
                other.analysisDate == analysisDate) &&
            (identical(other.overallFormScore, overallFormScore) ||
                other.overallFormScore == overallFormScore) &&
            const DeepCollectionEquality().equals(other._feedback, _feedback) &&
            const DeepCollectionEquality()
                .equals(other._corrections, _corrections) &&
            (identical(other.videoPath, videoPath) ||
                other.videoPath == videoPath) &&
            const DeepCollectionEquality()
                .equals(other._biomechanicsData, _biomechanicsData));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      exerciseId,
      userId,
      analysisDate,
      overallFormScore,
      const DeepCollectionEquality().hash(_feedback),
      const DeepCollectionEquality().hash(_corrections),
      videoPath,
      const DeepCollectionEquality().hash(_biomechanicsData));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FormAnalysisImplCopyWith<_$FormAnalysisImpl> get copyWith =>
      __$$FormAnalysisImplCopyWithImpl<_$FormAnalysisImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FormAnalysisImplToJson(
      this,
    );
  }
}

abstract class _FormAnalysis implements FormAnalysis {
  const factory _FormAnalysis(
      {required final String exerciseId,
      required final String userId,
      required final DateTime analysisDate,
      required final double overallFormScore,
      required final List<FormFeedback> feedback,
      required final List<FormCorrection> corrections,
      final String? videoPath,
      final Map<String, dynamic>? biomechanicsData}) = _$FormAnalysisImpl;

  factory _FormAnalysis.fromJson(Map<String, dynamic> json) =
      _$FormAnalysisImpl.fromJson;

  @override
  String get exerciseId;
  @override
  String get userId;
  @override
  DateTime get analysisDate;
  @override
  double get overallFormScore;
  @override // 0-100
  List<FormFeedback> get feedback;
  @override
  List<FormCorrection> get corrections;
  @override
  String? get videoPath;
  @override
  Map<String, dynamic>? get biomechanicsData;
  @override
  @JsonKey(ignore: true)
  _$$FormAnalysisImplCopyWith<_$FormAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FormFeedback _$FormFeedbackFromJson(Map<String, dynamic> json) {
  return _FormFeedback.fromJson(json);
}

/// @nodoc
mixin _$FormFeedback {
  String get aspect =>
      throw _privateConstructorUsedError; // "knee_tracking", "bar_path", etc.
  double get score => throw _privateConstructorUsedError; // 0-10
  String get comment => throw _privateConstructorUsedError;
  FeedbackLevel get level => throw _privateConstructorUsedError;
  List<String>? get improvementTips => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FormFeedbackCopyWith<FormFeedback> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FormFeedbackCopyWith<$Res> {
  factory $FormFeedbackCopyWith(
          FormFeedback value, $Res Function(FormFeedback) then) =
      _$FormFeedbackCopyWithImpl<$Res, FormFeedback>;
  @useResult
  $Res call(
      {String aspect,
      double score,
      String comment,
      FeedbackLevel level,
      List<String>? improvementTips});
}

/// @nodoc
class _$FormFeedbackCopyWithImpl<$Res, $Val extends FormFeedback>
    implements $FormFeedbackCopyWith<$Res> {
  _$FormFeedbackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aspect = null,
    Object? score = null,
    Object? comment = null,
    Object? level = null,
    Object? improvementTips = freezed,
  }) {
    return _then(_value.copyWith(
      aspect: null == aspect
          ? _value.aspect
          : aspect // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as FeedbackLevel,
      improvementTips: freezed == improvementTips
          ? _value.improvementTips
          : improvementTips // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FormFeedbackImplCopyWith<$Res>
    implements $FormFeedbackCopyWith<$Res> {
  factory _$$FormFeedbackImplCopyWith(
          _$FormFeedbackImpl value, $Res Function(_$FormFeedbackImpl) then) =
      __$$FormFeedbackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String aspect,
      double score,
      String comment,
      FeedbackLevel level,
      List<String>? improvementTips});
}

/// @nodoc
class __$$FormFeedbackImplCopyWithImpl<$Res>
    extends _$FormFeedbackCopyWithImpl<$Res, _$FormFeedbackImpl>
    implements _$$FormFeedbackImplCopyWith<$Res> {
  __$$FormFeedbackImplCopyWithImpl(
      _$FormFeedbackImpl _value, $Res Function(_$FormFeedbackImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aspect = null,
    Object? score = null,
    Object? comment = null,
    Object? level = null,
    Object? improvementTips = freezed,
  }) {
    return _then(_$FormFeedbackImpl(
      aspect: null == aspect
          ? _value.aspect
          : aspect // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as FeedbackLevel,
      improvementTips: freezed == improvementTips
          ? _value._improvementTips
          : improvementTips // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FormFeedbackImpl implements _FormFeedback {
  const _$FormFeedbackImpl(
      {required this.aspect,
      required this.score,
      required this.comment,
      required this.level,
      final List<String>? improvementTips})
      : _improvementTips = improvementTips;

  factory _$FormFeedbackImpl.fromJson(Map<String, dynamic> json) =>
      _$$FormFeedbackImplFromJson(json);

  @override
  final String aspect;
// "knee_tracking", "bar_path", etc.
  @override
  final double score;
// 0-10
  @override
  final String comment;
  @override
  final FeedbackLevel level;
  final List<String>? _improvementTips;
  @override
  List<String>? get improvementTips {
    final value = _improvementTips;
    if (value == null) return null;
    if (_improvementTips is EqualUnmodifiableListView) return _improvementTips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'FormFeedback(aspect: $aspect, score: $score, comment: $comment, level: $level, improvementTips: $improvementTips)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FormFeedbackImpl &&
            (identical(other.aspect, aspect) || other.aspect == aspect) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.level, level) || other.level == level) &&
            const DeepCollectionEquality()
                .equals(other._improvementTips, _improvementTips));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, aspect, score, comment, level,
      const DeepCollectionEquality().hash(_improvementTips));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FormFeedbackImplCopyWith<_$FormFeedbackImpl> get copyWith =>
      __$$FormFeedbackImplCopyWithImpl<_$FormFeedbackImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FormFeedbackImplToJson(
      this,
    );
  }
}

abstract class _FormFeedback implements FormFeedback {
  const factory _FormFeedback(
      {required final String aspect,
      required final double score,
      required final String comment,
      required final FeedbackLevel level,
      final List<String>? improvementTips}) = _$FormFeedbackImpl;

  factory _FormFeedback.fromJson(Map<String, dynamic> json) =
      _$FormFeedbackImpl.fromJson;

  @override
  String get aspect;
  @override // "knee_tracking", "bar_path", etc.
  double get score;
  @override // 0-10
  String get comment;
  @override
  FeedbackLevel get level;
  @override
  List<String>? get improvementTips;
  @override
  @JsonKey(ignore: true)
  _$$FormFeedbackImplCopyWith<_$FormFeedbackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FormCorrection _$FormCorrectionFromJson(Map<String, dynamic> json) {
  return _FormCorrection.fromJson(json);
}

/// @nodoc
mixin _$FormCorrection {
  String get issue => throw _privateConstructorUsedError;
  String get correction => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError; // 1-5
  List<String>? get cues => throw _privateConstructorUsedError;
  String? get demonstrationUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FormCorrectionCopyWith<FormCorrection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FormCorrectionCopyWith<$Res> {
  factory $FormCorrectionCopyWith(
          FormCorrection value, $Res Function(FormCorrection) then) =
      _$FormCorrectionCopyWithImpl<$Res, FormCorrection>;
  @useResult
  $Res call(
      {String issue,
      String correction,
      int priority,
      List<String>? cues,
      String? demonstrationUrl});
}

/// @nodoc
class _$FormCorrectionCopyWithImpl<$Res, $Val extends FormCorrection>
    implements $FormCorrectionCopyWith<$Res> {
  _$FormCorrectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? issue = null,
    Object? correction = null,
    Object? priority = null,
    Object? cues = freezed,
    Object? demonstrationUrl = freezed,
  }) {
    return _then(_value.copyWith(
      issue: null == issue
          ? _value.issue
          : issue // ignore: cast_nullable_to_non_nullable
              as String,
      correction: null == correction
          ? _value.correction
          : correction // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      cues: freezed == cues
          ? _value.cues
          : cues // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      demonstrationUrl: freezed == demonstrationUrl
          ? _value.demonstrationUrl
          : demonstrationUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FormCorrectionImplCopyWith<$Res>
    implements $FormCorrectionCopyWith<$Res> {
  factory _$$FormCorrectionImplCopyWith(_$FormCorrectionImpl value,
          $Res Function(_$FormCorrectionImpl) then) =
      __$$FormCorrectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String issue,
      String correction,
      int priority,
      List<String>? cues,
      String? demonstrationUrl});
}

/// @nodoc
class __$$FormCorrectionImplCopyWithImpl<$Res>
    extends _$FormCorrectionCopyWithImpl<$Res, _$FormCorrectionImpl>
    implements _$$FormCorrectionImplCopyWith<$Res> {
  __$$FormCorrectionImplCopyWithImpl(
      _$FormCorrectionImpl _value, $Res Function(_$FormCorrectionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? issue = null,
    Object? correction = null,
    Object? priority = null,
    Object? cues = freezed,
    Object? demonstrationUrl = freezed,
  }) {
    return _then(_$FormCorrectionImpl(
      issue: null == issue
          ? _value.issue
          : issue // ignore: cast_nullable_to_non_nullable
              as String,
      correction: null == correction
          ? _value.correction
          : correction // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      cues: freezed == cues
          ? _value._cues
          : cues // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      demonstrationUrl: freezed == demonstrationUrl
          ? _value.demonstrationUrl
          : demonstrationUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FormCorrectionImpl implements _FormCorrection {
  const _$FormCorrectionImpl(
      {required this.issue,
      required this.correction,
      required this.priority,
      final List<String>? cues,
      this.demonstrationUrl})
      : _cues = cues;

  factory _$FormCorrectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$FormCorrectionImplFromJson(json);

  @override
  final String issue;
  @override
  final String correction;
  @override
  final int priority;
// 1-5
  final List<String>? _cues;
// 1-5
  @override
  List<String>? get cues {
    final value = _cues;
    if (value == null) return null;
    if (_cues is EqualUnmodifiableListView) return _cues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? demonstrationUrl;

  @override
  String toString() {
    return 'FormCorrection(issue: $issue, correction: $correction, priority: $priority, cues: $cues, demonstrationUrl: $demonstrationUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FormCorrectionImpl &&
            (identical(other.issue, issue) || other.issue == issue) &&
            (identical(other.correction, correction) ||
                other.correction == correction) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality().equals(other._cues, _cues) &&
            (identical(other.demonstrationUrl, demonstrationUrl) ||
                other.demonstrationUrl == demonstrationUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, issue, correction, priority,
      const DeepCollectionEquality().hash(_cues), demonstrationUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FormCorrectionImplCopyWith<_$FormCorrectionImpl> get copyWith =>
      __$$FormCorrectionImplCopyWithImpl<_$FormCorrectionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FormCorrectionImplToJson(
      this,
    );
  }
}

abstract class _FormCorrection implements FormCorrection {
  const factory _FormCorrection(
      {required final String issue,
      required final String correction,
      required final int priority,
      final List<String>? cues,
      final String? demonstrationUrl}) = _$FormCorrectionImpl;

  factory _FormCorrection.fromJson(Map<String, dynamic> json) =
      _$FormCorrectionImpl.fromJson;

  @override
  String get issue;
  @override
  String get correction;
  @override
  int get priority;
  @override // 1-5
  List<String>? get cues;
  @override
  String? get demonstrationUrl;
  @override
  @JsonKey(ignore: true)
  _$$FormCorrectionImplCopyWith<_$FormCorrectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
