// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RRule _$RRuleFromJson(Map<String, dynamic> json) {
  return _RRule.fromJson(json);
}

/// @nodoc
mixin _$RRule {
  RRuleFrequency get frequency => throw _privateConstructorUsedError;
  int get interval => throw _privateConstructorUsedError;
  List<Weekday>? get byWeekday => throw _privateConstructorUsedError;
  List<int>? get byMonthDay => throw _privateConstructorUsedError;
  List<int>? get byMonth => throw _privateConstructorUsedError;
  DateTime? get until => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RRuleCopyWith<RRule> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RRuleCopyWith<$Res> {
  factory $RRuleCopyWith(RRule value, $Res Function(RRule) then) =
      _$RRuleCopyWithImpl<$Res, RRule>;
  @useResult
  $Res call(
      {RRuleFrequency frequency,
      int interval,
      List<Weekday>? byWeekday,
      List<int>? byMonthDay,
      List<int>? byMonth,
      DateTime? until,
      int? count});
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
    Object? frequency = null,
    Object? interval = null,
    Object? byWeekday = freezed,
    Object? byMonthDay = freezed,
    Object? byMonth = freezed,
    Object? until = freezed,
    Object? count = freezed,
  }) {
    return _then(_value.copyWith(
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as RRuleFrequency,
      interval: null == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int,
      byWeekday: freezed == byWeekday
          ? _value.byWeekday
          : byWeekday // ignore: cast_nullable_to_non_nullable
              as List<Weekday>?,
      byMonthDay: freezed == byMonthDay
          ? _value.byMonthDay
          : byMonthDay // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      byMonth: freezed == byMonth
          ? _value.byMonth
          : byMonth // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      until: freezed == until
          ? _value.until
          : until // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
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
  $Res call(
      {RRuleFrequency frequency,
      int interval,
      List<Weekday>? byWeekday,
      List<int>? byMonthDay,
      List<int>? byMonth,
      DateTime? until,
      int? count});
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
    Object? frequency = null,
    Object? interval = null,
    Object? byWeekday = freezed,
    Object? byMonthDay = freezed,
    Object? byMonth = freezed,
    Object? until = freezed,
    Object? count = freezed,
  }) {
    return _then(_$RRuleImpl(
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as RRuleFrequency,
      interval: null == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int,
      byWeekday: freezed == byWeekday
          ? _value._byWeekday
          : byWeekday // ignore: cast_nullable_to_non_nullable
              as List<Weekday>?,
      byMonthDay: freezed == byMonthDay
          ? _value._byMonthDay
          : byMonthDay // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      byMonth: freezed == byMonth
          ? _value._byMonth
          : byMonth // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      until: freezed == until
          ? _value.until
          : until // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RRuleImpl extends _RRule {
  const _$RRuleImpl(
      {required this.frequency,
      this.interval = 1,
      final List<Weekday>? byWeekday,
      final List<int>? byMonthDay,
      final List<int>? byMonth,
      this.until,
      this.count})
      : _byWeekday = byWeekday,
        _byMonthDay = byMonthDay,
        _byMonth = byMonth,
        super._();

  factory _$RRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$RRuleImplFromJson(json);

  @override
  final RRuleFrequency frequency;
  @override
  @JsonKey()
  final int interval;
  final List<Weekday>? _byWeekday;
  @override
  List<Weekday>? get byWeekday {
    final value = _byWeekday;
    if (value == null) return null;
    if (_byWeekday is EqualUnmodifiableListView) return _byWeekday;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<int>? _byMonthDay;
  @override
  List<int>? get byMonthDay {
    final value = _byMonthDay;
    if (value == null) return null;
    if (_byMonthDay is EqualUnmodifiableListView) return _byMonthDay;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<int>? _byMonth;
  @override
  List<int>? get byMonth {
    final value = _byMonth;
    if (value == null) return null;
    if (_byMonth is EqualUnmodifiableListView) return _byMonth;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? until;
  @override
  final int? count;

  @override
  String toString() {
    return 'RRule(frequency: $frequency, interval: $interval, byWeekday: $byWeekday, byMonthDay: $byMonthDay, byMonth: $byMonth, until: $until, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RRuleImpl &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            const DeepCollectionEquality()
                .equals(other._byWeekday, _byWeekday) &&
            const DeepCollectionEquality()
                .equals(other._byMonthDay, _byMonthDay) &&
            const DeepCollectionEquality().equals(other._byMonth, _byMonth) &&
            (identical(other.until, until) || other.until == until) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      frequency,
      interval,
      const DeepCollectionEquality().hash(_byWeekday),
      const DeepCollectionEquality().hash(_byMonthDay),
      const DeepCollectionEquality().hash(_byMonth),
      until,
      count);

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

abstract class _RRule extends RRule {
  const factory _RRule(
      {required final RRuleFrequency frequency,
      final int interval,
      final List<Weekday>? byWeekday,
      final List<int>? byMonthDay,
      final List<int>? byMonth,
      final DateTime? until,
      final int? count}) = _$RRuleImpl;
  const _RRule._() : super._();

  factory _RRule.fromJson(Map<String, dynamic> json) = _$RRuleImpl.fromJson;

  @override
  RRuleFrequency get frequency;
  @override
  int get interval;
  @override
  List<Weekday>? get byWeekday;
  @override
  List<int>? get byMonthDay;
  @override
  List<int>? get byMonth;
  @override
  DateTime? get until;
  @override
  int? get count;
  @override
  @JsonKey(ignore: true)
  _$$RRuleImplCopyWith<_$RRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkoutSchedule _$WorkoutScheduleFromJson(Map<String, dynamic> json) {
  return _WorkoutSchedule.fromJson(json);
}

/// @nodoc
mixin _$WorkoutSchedule {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  bool get conflicted => throw _privateConstructorUsedError; // 스케줄 특화 필드
  String get planId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  RRule? get rrule => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  List<String> get completedDates => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutScheduleCopyWith<WorkoutSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutScheduleCopyWith<$Res> {
  factory $WorkoutScheduleCopyWith(
          WorkoutSchedule value, $Res Function(WorkoutSchedule) then) =
      _$WorkoutScheduleCopyWithImpl<$Res, WorkoutSchedule>;
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      DateTime updatedAt,
      String deviceId,
      bool conflicted,
      String planId,
      String title,
      DateTime startDate,
      RRule? rrule,
      bool isActive,
      List<String> completedDates});

  $RRuleCopyWith<$Res>? get rrule;
}

/// @nodoc
class _$WorkoutScheduleCopyWithImpl<$Res, $Val extends WorkoutSchedule>
    implements $WorkoutScheduleCopyWith<$Res> {
  _$WorkoutScheduleCopyWithImpl(this._value, this._then);

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
    Object? planId = null,
    Object? title = null,
    Object? startDate = null,
    Object? rrule = freezed,
    Object? isActive = null,
    Object? completedDates = null,
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
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      rrule: freezed == rrule
          ? _value.rrule
          : rrule // ignore: cast_nullable_to_non_nullable
              as RRule?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      completedDates: null == completedDates
          ? _value.completedDates
          : completedDates // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RRuleCopyWith<$Res>? get rrule {
    if (_value.rrule == null) {
      return null;
    }

    return $RRuleCopyWith<$Res>(_value.rrule!, (value) {
      return _then(_value.copyWith(rrule: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WorkoutScheduleImplCopyWith<$Res>
    implements $WorkoutScheduleCopyWith<$Res> {
  factory _$$WorkoutScheduleImplCopyWith(_$WorkoutScheduleImpl value,
          $Res Function(_$WorkoutScheduleImpl) then) =
      __$$WorkoutScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime createdAt,
      DateTime updatedAt,
      String deviceId,
      bool conflicted,
      String planId,
      String title,
      DateTime startDate,
      RRule? rrule,
      bool isActive,
      List<String> completedDates});

  @override
  $RRuleCopyWith<$Res>? get rrule;
}

/// @nodoc
class __$$WorkoutScheduleImplCopyWithImpl<$Res>
    extends _$WorkoutScheduleCopyWithImpl<$Res, _$WorkoutScheduleImpl>
    implements _$$WorkoutScheduleImplCopyWith<$Res> {
  __$$WorkoutScheduleImplCopyWithImpl(
      _$WorkoutScheduleImpl _value, $Res Function(_$WorkoutScheduleImpl) _then)
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
    Object? planId = null,
    Object? title = null,
    Object? startDate = null,
    Object? rrule = freezed,
    Object? isActive = null,
    Object? completedDates = null,
  }) {
    return _then(_$WorkoutScheduleImpl(
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
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      rrule: freezed == rrule
          ? _value.rrule
          : rrule // ignore: cast_nullable_to_non_nullable
              as RRule?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      completedDates: null == completedDates
          ? _value._completedDates
          : completedDates // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutScheduleImpl extends _WorkoutSchedule {
  const _$WorkoutScheduleImpl(
      {required this.id,
      required this.userId,
      required this.createdAt,
      required this.updatedAt,
      required this.deviceId,
      this.conflicted = false,
      required this.planId,
      required this.title,
      required this.startDate,
      this.rrule,
      this.isActive = true,
      final List<String> completedDates = const []})
      : _completedDates = completedDates,
        super._();

  factory _$WorkoutScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutScheduleImplFromJson(json);

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
// 스케줄 특화 필드
  @override
  final String planId;
  @override
  final String title;
  @override
  final DateTime startDate;
  @override
  final RRule? rrule;
  @override
  @JsonKey()
  final bool isActive;
  final List<String> _completedDates;
  @override
  @JsonKey()
  List<String> get completedDates {
    if (_completedDates is EqualUnmodifiableListView) return _completedDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedDates);
  }

  @override
  String toString() {
    return 'WorkoutSchedule(id: $id, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt, deviceId: $deviceId, conflicted: $conflicted, planId: $planId, title: $title, startDate: $startDate, rrule: $rrule, isActive: $isActive, completedDates: $completedDates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutScheduleImpl &&
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
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.rrule, rrule) || other.rrule == rrule) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality()
                .equals(other._completedDates, _completedDates));
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
      planId,
      title,
      startDate,
      rrule,
      isActive,
      const DeepCollectionEquality().hash(_completedDates));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutScheduleImplCopyWith<_$WorkoutScheduleImpl> get copyWith =>
      __$$WorkoutScheduleImplCopyWithImpl<_$WorkoutScheduleImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutScheduleImplToJson(
      this,
    );
  }
}

abstract class _WorkoutSchedule extends WorkoutSchedule {
  const factory _WorkoutSchedule(
      {required final String id,
      required final String userId,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final String deviceId,
      final bool conflicted,
      required final String planId,
      required final String title,
      required final DateTime startDate,
      final RRule? rrule,
      final bool isActive,
      final List<String> completedDates}) = _$WorkoutScheduleImpl;
  const _WorkoutSchedule._() : super._();

  factory _WorkoutSchedule.fromJson(Map<String, dynamic> json) =
      _$WorkoutScheduleImpl.fromJson;

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
  @override // 스케줄 특화 필드
  String get planId;
  @override
  String get title;
  @override
  DateTime get startDate;
  @override
  RRule? get rrule;
  @override
  bool get isActive;
  @override
  List<String> get completedDates;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutScheduleImplCopyWith<_$WorkoutScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CalendarEvent _$CalendarEventFromJson(Map<String, dynamic> json) {
  return _CalendarEvent.fromJson(json);
}

/// @nodoc
mixin _$CalendarEvent {
  DateTime get date => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  CalendarEventType get type => throw _privateConstructorUsedError;
  String? get sessionId => throw _privateConstructorUsedError;
  String? get scheduleId => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalendarEventCopyWith<CalendarEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarEventCopyWith<$Res> {
  factory $CalendarEventCopyWith(
          CalendarEvent value, $Res Function(CalendarEvent) then) =
      _$CalendarEventCopyWithImpl<$Res, CalendarEvent>;
  @useResult
  $Res call(
      {DateTime date,
      String title,
      CalendarEventType type,
      String? sessionId,
      String? scheduleId,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$CalendarEventCopyWithImpl<$Res, $Val extends CalendarEvent>
    implements $CalendarEventCopyWith<$Res> {
  _$CalendarEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? title = null,
    Object? type = null,
    Object? sessionId = freezed,
    Object? scheduleId = freezed,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CalendarEventType,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleId: freezed == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalendarEventImplCopyWith<$Res>
    implements $CalendarEventCopyWith<$Res> {
  factory _$$CalendarEventImplCopyWith(
          _$CalendarEventImpl value, $Res Function(_$CalendarEventImpl) then) =
      __$$CalendarEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      String title,
      CalendarEventType type,
      String? sessionId,
      String? scheduleId,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$CalendarEventImplCopyWithImpl<$Res>
    extends _$CalendarEventCopyWithImpl<$Res, _$CalendarEventImpl>
    implements _$$CalendarEventImplCopyWith<$Res> {
  __$$CalendarEventImplCopyWithImpl(
      _$CalendarEventImpl _value, $Res Function(_$CalendarEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? title = null,
    Object? type = null,
    Object? sessionId = freezed,
    Object? scheduleId = freezed,
    Object? metadata = null,
  }) {
    return _then(_$CalendarEventImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CalendarEventType,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleId: freezed == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarEventImpl implements _CalendarEvent {
  const _$CalendarEventImpl(
      {required this.date,
      required this.title,
      required this.type,
      this.sessionId,
      this.scheduleId,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  factory _$CalendarEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarEventImplFromJson(json);

  @override
  final DateTime date;
  @override
  final String title;
  @override
  final CalendarEventType type;
  @override
  final String? sessionId;
  @override
  final String? scheduleId;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'CalendarEvent(date: $date, title: $title, type: $type, sessionId: $sessionId, scheduleId: $scheduleId, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarEventImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.scheduleId, scheduleId) ||
                other.scheduleId == scheduleId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, date, title, type, sessionId,
      scheduleId, const DeepCollectionEquality().hash(_metadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarEventImplCopyWith<_$CalendarEventImpl> get copyWith =>
      __$$CalendarEventImplCopyWithImpl<_$CalendarEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarEventImplToJson(
      this,
    );
  }
}

abstract class _CalendarEvent implements CalendarEvent {
  const factory _CalendarEvent(
      {required final DateTime date,
      required final String title,
      required final CalendarEventType type,
      final String? sessionId,
      final String? scheduleId,
      final Map<String, dynamic> metadata}) = _$CalendarEventImpl;

  factory _CalendarEvent.fromJson(Map<String, dynamic> json) =
      _$CalendarEventImpl.fromJson;

  @override
  DateTime get date;
  @override
  String get title;
  @override
  CalendarEventType get type;
  @override
  String? get sessionId;
  @override
  String? get scheduleId;
  @override
  Map<String, dynamic> get metadata;
  @override
  @JsonKey(ignore: true)
  _$$CalendarEventImplCopyWith<_$CalendarEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
