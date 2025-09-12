// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_goal.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLearningGoalCollection on Isar {
  IsarCollection<LearningGoal> get learningGoals => this.collection();
}

const LearningGoalSchema = CollectionSchema(
  name: r'LearningGoal',
  id: 5158529453339058284,
  properties: {
    r'badges': PropertySchema(
      id: 0,
      name: r'badges',
      type: IsarType.stringList,
    ),
    r'category': PropertySchema(
      id: 1,
      name: r'category',
      type: IsarType.string,
    ),
    r'competencyAreas': PropertySchema(
      id: 2,
      name: r'competencyAreas',
      type: IsarType.stringList,
    ),
    r'completionDate': PropertySchema(
      id: 3,
      name: r'completionDate',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentValue': PropertySchema(
      id: 5,
      name: r'currentValue',
      type: IsarType.long,
    ),
    r'daysRemaining': PropertySchema(
      id: 6,
      name: r'daysRemaining',
      type: IsarType.long,
    ),
    r'description': PropertySchema(
      id: 7,
      name: r'description',
      type: IsarType.string,
    ),
    r'difficulty': PropertySchema(
      id: 8,
      name: r'difficulty',
      type: IsarType.string,
      enumMap: _LearningGoaldifficultyEnumValueMap,
    ),
    r'isCompleted': PropertySchema(
      id: 9,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'isOverdue': PropertySchema(
      id: 10,
      name: r'isOverdue',
      type: IsarType.bool,
    ),
    r'milestones': PropertySchema(
      id: 11,
      name: r'milestones',
      type: IsarType.objectList,
      target: r'GoalMilestone',
    ),
    r'priority': PropertySchema(
      id: 12,
      name: r'priority',
      type: IsarType.string,
      enumMap: _LearningGoalpriorityEnumValueMap,
    ),
    r'progressPercentage': PropertySchema(
      id: 13,
      name: r'progressPercentage',
      type: IsarType.double,
    ),
    r'startDate': PropertySchema(
      id: 14,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 15,
      name: r'status',
      type: IsarType.string,
      enumMap: _LearningGoalstatusEnumValueMap,
    ),
    r'targetDate': PropertySchema(
      id: 16,
      name: r'targetDate',
      type: IsarType.dateTime,
    ),
    r'targetUnit': PropertySchema(
      id: 17,
      name: r'targetUnit',
      type: IsarType.string,
    ),
    r'targetValue': PropertySchema(
      id: 18,
      name: r'targetValue',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 19,
      name: r'title',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 20,
      name: r'type',
      type: IsarType.string,
      enumMap: _LearningGoaltypeEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 21,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 22,
      name: r'userId',
      type: IsarType.string,
    ),
    r'xpReward': PropertySchema(
      id: 23,
      name: r'xpReward',
      type: IsarType.long,
    )
  },
  estimateSize: _learningGoalEstimateSize,
  serialize: _learningGoalSerialize,
  deserialize: _learningGoalDeserialize,
  deserializeProp: _learningGoalDeserializeProp,
  idName: r'id',
  indexes: {
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'GoalMilestone': GoalMilestoneSchema},
  getId: _learningGoalGetId,
  getLinks: _learningGoalGetLinks,
  attach: _learningGoalAttach,
  version: '3.1.0+1',
);

int _learningGoalEstimateSize(
  LearningGoal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.badges.length * 3;
  {
    for (var i = 0; i < object.badges.length; i++) {
      final value = object.badges[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.category.length * 3;
  bytesCount += 3 + object.competencyAreas.length * 3;
  {
    for (var i = 0; i < object.competencyAreas.length; i++) {
      final value = object.competencyAreas[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.difficulty.name.length * 3;
  bytesCount += 3 + object.milestones.length * 3;
  {
    final offsets = allOffsets[GoalMilestone]!;
    for (var i = 0; i < object.milestones.length; i++) {
      final value = object.milestones[i];
      bytesCount +=
          GoalMilestoneSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.priority.name.length * 3;
  bytesCount += 3 + object.status.name.length * 3;
  bytesCount += 3 + object.targetUnit.length * 3;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.type.name.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _learningGoalSerialize(
  LearningGoal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.badges);
  writer.writeString(offsets[1], object.category);
  writer.writeStringList(offsets[2], object.competencyAreas);
  writer.writeDateTime(offsets[3], object.completionDate);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeLong(offsets[5], object.currentValue);
  writer.writeLong(offsets[6], object.daysRemaining);
  writer.writeString(offsets[7], object.description);
  writer.writeString(offsets[8], object.difficulty.name);
  writer.writeBool(offsets[9], object.isCompleted);
  writer.writeBool(offsets[10], object.isOverdue);
  writer.writeObjectList<GoalMilestone>(
    offsets[11],
    allOffsets,
    GoalMilestoneSchema.serialize,
    object.milestones,
  );
  writer.writeString(offsets[12], object.priority.name);
  writer.writeDouble(offsets[13], object.progressPercentage);
  writer.writeDateTime(offsets[14], object.startDate);
  writer.writeString(offsets[15], object.status.name);
  writer.writeDateTime(offsets[16], object.targetDate);
  writer.writeString(offsets[17], object.targetUnit);
  writer.writeLong(offsets[18], object.targetValue);
  writer.writeString(offsets[19], object.title);
  writer.writeString(offsets[20], object.type.name);
  writer.writeDateTime(offsets[21], object.updatedAt);
  writer.writeString(offsets[22], object.userId);
  writer.writeLong(offsets[23], object.xpReward);
}

LearningGoal _learningGoalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LearningGoal();
  object.badges = reader.readStringList(offsets[0]) ?? [];
  object.category = reader.readString(offsets[1]);
  object.competencyAreas = reader.readStringList(offsets[2]) ?? [];
  object.completionDate = reader.readDateTimeOrNull(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.currentValue = reader.readLong(offsets[5]);
  object.description = reader.readStringOrNull(offsets[7]);
  object.difficulty = _LearningGoaldifficultyValueEnumMap[
          reader.readStringOrNull(offsets[8])] ??
      GoalDifficulty.beginner;
  object.id = id;
  object.milestones = reader.readObjectList<GoalMilestone>(
        offsets[11],
        GoalMilestoneSchema.deserialize,
        allOffsets,
        GoalMilestone(),
      ) ??
      [];
  object.priority =
      _LearningGoalpriorityValueEnumMap[reader.readStringOrNull(offsets[12])] ??
          GoalPriority.low;
  object.startDate = reader.readDateTimeOrNull(offsets[14]);
  object.status =
      _LearningGoalstatusValueEnumMap[reader.readStringOrNull(offsets[15])] ??
          GoalStatus.active;
  object.targetDate = reader.readDateTimeOrNull(offsets[16]);
  object.targetUnit = reader.readString(offsets[17]);
  object.targetValue = reader.readLong(offsets[18]);
  object.title = reader.readString(offsets[19]);
  object.type =
      _LearningGoaltypeValueEnumMap[reader.readStringOrNull(offsets[20])] ??
          GoalType.accuracy;
  object.updatedAt = reader.readDateTimeOrNull(offsets[21]);
  object.userId = reader.readString(offsets[22]);
  object.xpReward = reader.readLong(offsets[23]);
  return object;
}

P _learningGoalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (_LearningGoaldifficultyValueEnumMap[
              reader.readStringOrNull(offset)] ??
          GoalDifficulty.beginner) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readObjectList<GoalMilestone>(
            offset,
            GoalMilestoneSchema.deserialize,
            allOffsets,
            GoalMilestone(),
          ) ??
          []) as P;
    case 12:
      return (_LearningGoalpriorityValueEnumMap[
              reader.readStringOrNull(offset)] ??
          GoalPriority.low) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    case 14:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 15:
      return (_LearningGoalstatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          GoalStatus.active) as P;
    case 16:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (_LearningGoaltypeValueEnumMap[reader.readStringOrNull(offset)] ??
          GoalType.accuracy) as P;
    case 21:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    case 23:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _LearningGoaldifficultyEnumValueMap = {
  r'beginner': r'beginner',
  r'intermediate': r'intermediate',
  r'advanced': r'advanced',
  r'expert': r'expert',
};
const _LearningGoaldifficultyValueEnumMap = {
  r'beginner': GoalDifficulty.beginner,
  r'intermediate': GoalDifficulty.intermediate,
  r'advanced': GoalDifficulty.advanced,
  r'expert': GoalDifficulty.expert,
};
const _LearningGoalpriorityEnumValueMap = {
  r'low': r'low',
  r'medium': r'medium',
  r'high': r'high',
  r'critical': r'critical',
};
const _LearningGoalpriorityValueEnumMap = {
  r'low': GoalPriority.low,
  r'medium': GoalPriority.medium,
  r'high': GoalPriority.high,
  r'critical': GoalPriority.critical,
};
const _LearningGoalstatusEnumValueMap = {
  r'active': r'active',
  r'paused': r'paused',
  r'completed': r'completed',
  r'failed': r'failed',
  r'cancelled': r'cancelled',
};
const _LearningGoalstatusValueEnumMap = {
  r'active': GoalStatus.active,
  r'paused': GoalStatus.paused,
  r'completed': GoalStatus.completed,
  r'failed': GoalStatus.failed,
  r'cancelled': GoalStatus.cancelled,
};
const _LearningGoaltypeEnumValueMap = {
  r'accuracy': r'accuracy',
  r'volume': r'volume',
  r'consistency': r'consistency',
  r'mastery': r'mastery',
  r'speed': r'speed',
  r'comprehensive': r'comprehensive',
};
const _LearningGoaltypeValueEnumMap = {
  r'accuracy': GoalType.accuracy,
  r'volume': GoalType.volume,
  r'consistency': GoalType.consistency,
  r'mastery': GoalType.mastery,
  r'speed': GoalType.speed,
  r'comprehensive': GoalType.comprehensive,
};

Id _learningGoalGetId(LearningGoal object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _learningGoalGetLinks(LearningGoal object) {
  return [];
}

void _learningGoalAttach(
    IsarCollection<dynamic> col, Id id, LearningGoal object) {
  object.id = id;
}

extension LearningGoalQueryWhereSort
    on QueryBuilder<LearningGoal, LearningGoal, QWhere> {
  QueryBuilder<LearningGoal, LearningGoal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }
}

extension LearningGoalQueryWhere
    on QueryBuilder<LearningGoal, LearningGoal, QWhereClause> {
  QueryBuilder<LearningGoal, LearningGoal, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterWhereClause> createdAtEqualTo(
      DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterWhereClause>
      createdAtNotEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterWhereClause>
      createdAtGreaterThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [createdAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterWhereClause> createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [],
        upper: [createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterWhereClause> createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [lowerCreatedAt],
        includeLower: includeLower,
        upper: [upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LearningGoalQueryFilter
    on QueryBuilder<LearningGoal, LearningGoal, QFilterCondition> {
  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      badgesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'badges',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      badgesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'badges',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      badgesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'badges',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      badgesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'badges',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      badgesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'badges',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      badgesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'badges',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      badgesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'badges',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      badgesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'badges',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      badgesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'badges',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      badgesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'badges',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      badgesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'badges',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      badgesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'badges',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      badgesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'badges',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      badgesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'badges',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      badgesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'badges',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      badgesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'badges',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      categoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      competencyAreasElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'competencyAreas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      competencyAreasElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'competencyAreas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      competencyAreasElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'competencyAreas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      competencyAreasElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'competencyAreas',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      competencyAreasElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'competencyAreas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      competencyAreasElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'competencyAreas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      competencyAreasElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'competencyAreas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      competencyAreasElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'competencyAreas',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      competencyAreasElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'competencyAreas',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      competencyAreasElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'competencyAreas',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      competencyAreasLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'competencyAreas',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      competencyAreasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'competencyAreas',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      competencyAreasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'competencyAreas',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      competencyAreasLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'competencyAreas',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      competencyAreasLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'competencyAreas',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      competencyAreasLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'competencyAreas',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      completionDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completionDate',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      completionDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completionDate',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      completionDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      completionDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      completionDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      completionDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completionDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      currentValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentValue',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      currentValueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentValue',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      currentValueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentValue',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      currentValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      daysRemainingEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'daysRemaining',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      daysRemainingGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'daysRemaining',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      daysRemainingLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'daysRemaining',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      daysRemainingBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'daysRemaining',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      difficultyEqualTo(
    GoalDifficulty value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      difficultyGreaterThan(
    GoalDifficulty value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      difficultyLessThan(
    GoalDifficulty value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      difficultyBetween(
    GoalDifficulty lower,
    GoalDifficulty upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'difficulty',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      difficultyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      difficultyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      difficultyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      difficultyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'difficulty',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      difficultyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficulty',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      difficultyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'difficulty',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> idEqualTo(
      Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> idGreaterThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> idLessThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> idBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      isOverdueEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isOverdue',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      milestonesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'milestones',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      milestonesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'milestones',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      milestonesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'milestones',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      milestonesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'milestones',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      milestonesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'milestones',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      milestonesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'milestones',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      priorityEqualTo(
    GoalPriority value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      priorityGreaterThan(
    GoalPriority value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      priorityLessThan(
    GoalPriority value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      priorityBetween(
    GoalPriority lower,
    GoalPriority upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      priorityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      priorityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      priorityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      priorityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'priority',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      priorityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      priorityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'priority',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      progressPercentageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progressPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      progressPercentageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progressPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      progressPercentageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progressPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      progressPercentageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progressPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      startDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      startDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      startDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      startDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      startDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      startDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> statusEqualTo(
    GoalStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      statusGreaterThan(
    GoalStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      statusLessThan(
    GoalStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> statusBetween(
    GoalStatus lower,
    GoalStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetDate',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetDate',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetUnitEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetUnitGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetUnitLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetUnitBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetUnit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetUnitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'targetUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetUnitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'targetUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetUnitContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'targetUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetUnitMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'targetUnit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetUnitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetUnit',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetUnitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'targetUnit',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetValue',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetValueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetValue',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetValueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetValue',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      targetValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> typeEqualTo(
    GoalType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      typeGreaterThan(
    GoalType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> typeLessThan(
    GoalType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> typeBetween(
    GoalType lower,
    GoalType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> typeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition> userIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      xpRewardEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xpReward',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      xpRewardGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'xpReward',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      xpRewardLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'xpReward',
        value: value,
      ));
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      xpRewardBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'xpReward',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LearningGoalQueryObject
    on QueryBuilder<LearningGoal, LearningGoal, QFilterCondition> {
  QueryBuilder<LearningGoal, LearningGoal, QAfterFilterCondition>
      milestonesElement(FilterQuery<GoalMilestone> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'milestones');
    });
  }
}

extension LearningGoalQueryLinks
    on QueryBuilder<LearningGoal, LearningGoal, QFilterCondition> {}

extension LearningGoalQuerySortBy
    on QueryBuilder<LearningGoal, LearningGoal, QSortBy> {
  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      sortByCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionDate', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      sortByCompletionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionDate', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      sortByCurrentValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByDaysRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysRemaining', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      sortByDaysRemainingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysRemaining', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      sortByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByIsOverdue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOverdue', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByIsOverdueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOverdue', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      sortByProgressPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressPercentage', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      sortByProgressPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressPercentage', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      sortByTargetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByTargetUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetUnit', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      sortByTargetUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetUnit', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByTargetValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetValue', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      sortByTargetValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetValue', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByXpReward() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpReward', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> sortByXpRewardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpReward', Sort.desc);
    });
  }
}

extension LearningGoalQuerySortThenBy
    on QueryBuilder<LearningGoal, LearningGoal, QSortThenBy> {
  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      thenByCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionDate', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      thenByCompletionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionDate', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      thenByCurrentValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByDaysRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysRemaining', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      thenByDaysRemainingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysRemaining', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      thenByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByIsOverdue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOverdue', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByIsOverdueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOverdue', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      thenByProgressPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressPercentage', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      thenByProgressPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressPercentage', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      thenByTargetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByTargetUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetUnit', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      thenByTargetUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetUnit', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByTargetValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetValue', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy>
      thenByTargetValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetValue', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByXpReward() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpReward', Sort.asc);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QAfterSortBy> thenByXpRewardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpReward', Sort.desc);
    });
  }
}

extension LearningGoalQueryWhereDistinct
    on QueryBuilder<LearningGoal, LearningGoal, QDistinct> {
  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByBadges() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'badges');
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct>
      distinctByCompetencyAreas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'competencyAreas');
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct>
      distinctByCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completionDate');
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentValue');
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct>
      distinctByDaysRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'daysRemaining');
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByDifficulty(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'difficulty', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByIsOverdue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isOverdue');
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByPriority(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct>
      distinctByProgressPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progressPercentage');
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetDate');
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByTargetUnit(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetUnit', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByTargetValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetValue');
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LearningGoal, LearningGoal, QDistinct> distinctByXpReward() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'xpReward');
    });
  }
}

extension LearningGoalQueryProperty
    on QueryBuilder<LearningGoal, LearningGoal, QQueryProperty> {
  QueryBuilder<LearningGoal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LearningGoal, List<String>, QQueryOperations> badgesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'badges');
    });
  }

  QueryBuilder<LearningGoal, String, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<LearningGoal, List<String>, QQueryOperations>
      competencyAreasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'competencyAreas');
    });
  }

  QueryBuilder<LearningGoal, DateTime?, QQueryOperations>
      completionDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completionDate');
    });
  }

  QueryBuilder<LearningGoal, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<LearningGoal, int, QQueryOperations> currentValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentValue');
    });
  }

  QueryBuilder<LearningGoal, int, QQueryOperations> daysRemainingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'daysRemaining');
    });
  }

  QueryBuilder<LearningGoal, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<LearningGoal, GoalDifficulty, QQueryOperations>
      difficultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'difficulty');
    });
  }

  QueryBuilder<LearningGoal, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<LearningGoal, bool, QQueryOperations> isOverdueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isOverdue');
    });
  }

  QueryBuilder<LearningGoal, List<GoalMilestone>, QQueryOperations>
      milestonesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'milestones');
    });
  }

  QueryBuilder<LearningGoal, GoalPriority, QQueryOperations>
      priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<LearningGoal, double, QQueryOperations>
      progressPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progressPercentage');
    });
  }

  QueryBuilder<LearningGoal, DateTime?, QQueryOperations> startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<LearningGoal, GoalStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<LearningGoal, DateTime?, QQueryOperations> targetDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetDate');
    });
  }

  QueryBuilder<LearningGoal, String, QQueryOperations> targetUnitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetUnit');
    });
  }

  QueryBuilder<LearningGoal, int, QQueryOperations> targetValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetValue');
    });
  }

  QueryBuilder<LearningGoal, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<LearningGoal, GoalType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<LearningGoal, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<LearningGoal, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<LearningGoal, int, QQueryOperations> xpRewardProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'xpReward');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const GoalMilestoneSchema = Schema(
  name: r'GoalMilestone',
  id: 5019064727079214904,
  properties: {
    r'completedAt': PropertySchema(
      id: 0,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'isCompleted': PropertySchema(
      id: 1,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'reward': PropertySchema(
      id: 2,
      name: r'reward',
      type: IsarType.string,
    ),
    r'targetValue': PropertySchema(
      id: 3,
      name: r'targetValue',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 4,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _goalMilestoneEstimateSize,
  serialize: _goalMilestoneSerialize,
  deserialize: _goalMilestoneDeserialize,
  deserializeProp: _goalMilestoneDeserializeProp,
);

int _goalMilestoneEstimateSize(
  GoalMilestone object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.reward;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _goalMilestoneSerialize(
  GoalMilestone object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.completedAt);
  writer.writeBool(offsets[1], object.isCompleted);
  writer.writeString(offsets[2], object.reward);
  writer.writeLong(offsets[3], object.targetValue);
  writer.writeString(offsets[4], object.title);
}

GoalMilestone _goalMilestoneDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GoalMilestone(
    reward: reader.readStringOrNull(offsets[2]),
    targetValue: reader.readLongOrNull(offsets[3]) ?? 0,
    title: reader.readStringOrNull(offsets[4]) ?? '',
  );
  object.completedAt = reader.readDateTimeOrNull(offsets[0]);
  object.isCompleted = reader.readBool(offsets[1]);
  return object;
}

P _goalMilestoneDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 4:
      return (reader.readStringOrNull(offset) ?? '') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension GoalMilestoneQueryFilter
    on QueryBuilder<GoalMilestone, GoalMilestone, QFilterCondition> {
  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      rewardIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reward',
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      rewardIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reward',
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      rewardEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reward',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      rewardGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reward',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      rewardLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reward',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      rewardBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reward',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      rewardStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reward',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      rewardEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reward',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      rewardContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reward',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      rewardMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reward',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      rewardIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reward',
        value: '',
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      rewardIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reward',
        value: '',
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      targetValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetValue',
        value: value,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      targetValueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetValue',
        value: value,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      targetValueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetValue',
        value: value,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      targetValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<GoalMilestone, GoalMilestone, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension GoalMilestoneQueryObject
    on QueryBuilder<GoalMilestone, GoalMilestone, QFilterCondition> {}
