// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_session.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetQuizSessionCollection on Isar {
  IsarCollection<QuizSession> get quizSessions => this.collection();
}

const QuizSessionSchema = CollectionSchema(
  name: r'QuizSession',
  id: 1455044083199775799,
  properties: {
    r'accuracy': PropertySchema(
      id: 0,
      name: r'accuracy',
      type: IsarType.double,
    ),
    r'averageTimePerProblem': PropertySchema(
      id: 1,
      name: r'averageTimePerProblem',
      type: IsarType.double,
    ),
    r'completedAt': PropertySchema(
      id: 2,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'completionPercentage': PropertySchema(
      id: 3,
      name: r'completionPercentage',
      type: IsarType.double,
    ),
    r'correctAnswers': PropertySchema(
      id: 4,
      name: r'correctAnswers',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 5,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentProblemIndex': PropertySchema(
      id: 6,
      name: r'currentProblemIndex',
      type: IsarType.long,
    ),
    r'difficulties': PropertySchema(
      id: 7,
      name: r'difficulties',
      type: IsarType.string,
    ),
    r'difficultiesList': PropertySchema(
      id: 8,
      name: r'difficultiesList',
      type: IsarType.stringList,
    ),
    r'finalScore': PropertySchema(
      id: 9,
      name: r'finalScore',
      type: IsarType.double,
    ),
    r'hashCode': PropertySchema(
      id: 10,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'incorrectAnswers': PropertySchema(
      id: 11,
      name: r'incorrectAnswers',
      type: IsarType.long,
    ),
    r'isActive': PropertySchema(
      id: 12,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isCompleted': PropertySchema(
      id: 13,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'isPaused': PropertySchema(
      id: 14,
      name: r'isPaused',
      type: IsarType.bool,
    ),
    r'notes': PropertySchema(
      id: 15,
      name: r'notes',
      type: IsarType.string,
    ),
    r'pausedAt': PropertySchema(
      id: 16,
      name: r'pausedAt',
      type: IsarType.dateTime,
    ),
    r'problemIds': PropertySchema(
      id: 17,
      name: r'problemIds',
      type: IsarType.string,
    ),
    r'problemIdsList': PropertySchema(
      id: 18,
      name: r'problemIdsList',
      type: IsarType.stringList,
    ),
    r'reviewData': PropertySchema(
      id: 19,
      name: r'reviewData',
      type: IsarType.string,
    ),
    r'sessionId': PropertySchema(
      id: 20,
      name: r'sessionId',
      type: IsarType.string,
    ),
    r'settings': PropertySchema(
      id: 21,
      name: r'settings',
      type: IsarType.string,
    ),
    r'skippedProblems': PropertySchema(
      id: 22,
      name: r'skippedProblems',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 23,
      name: r'status',
      type: IsarType.string,
      enumMap: _QuizSessionstatusEnumValueMap,
    ),
    r'subjects': PropertySchema(
      id: 24,
      name: r'subjects',
      type: IsarType.string,
    ),
    r'subjectsList': PropertySchema(
      id: 25,
      name: r'subjectsList',
      type: IsarType.stringList,
    ),
    r'title': PropertySchema(
      id: 26,
      name: r'title',
      type: IsarType.string,
    ),
    r'totalProblems': PropertySchema(
      id: 27,
      name: r'totalProblems',
      type: IsarType.long,
    ),
    r'totalTimeMs': PropertySchema(
      id: 28,
      name: r'totalTimeMs',
      type: IsarType.long,
    ),
    r'type': PropertySchema(
      id: 29,
      name: r'type',
      type: IsarType.string,
      enumMap: _QuizSessiontypeEnumValueMap,
    ),
    r'userAnswers': PropertySchema(
      id: 30,
      name: r'userAnswers',
      type: IsarType.string,
    )
  },
  estimateSize: _quizSessionEstimateSize,
  serialize: _quizSessionSerialize,
  deserialize: _quizSessionDeserialize,
  deserializeProp: _quizSessionDeserializeProp,
  idName: r'id',
  indexes: {
    r'sessionId': IndexSchema(
      id: 6949518585047923839,
      name: r'sessionId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'title': IndexSchema(
      id: -7636685945352118059,
      name: r'title',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'title',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _quizSessionGetId,
  getLinks: _quizSessionGetLinks,
  attach: _quizSessionAttach,
  version: '3.1.0+1',
);

int _quizSessionEstimateSize(
  QuizSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.difficulties;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.difficultiesList.length * 3;
  {
    for (var i = 0; i < object.difficultiesList.length; i++) {
      final value = object.difficultiesList[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.problemIds.length * 3;
  bytesCount += 3 + object.problemIdsList.length * 3;
  {
    for (var i = 0; i < object.problemIdsList.length; i++) {
      final value = object.problemIdsList[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.reviewData;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sessionId.length * 3;
  {
    final value = object.settings;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.name.length * 3;
  {
    final value = object.subjects;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.subjectsList.length * 3;
  {
    for (var i = 0; i < object.subjectsList.length; i++) {
      final value = object.subjectsList[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.type.name.length * 3;
  {
    final value = object.userAnswers;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _quizSessionSerialize(
  QuizSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.accuracy);
  writer.writeDouble(offsets[1], object.averageTimePerProblem);
  writer.writeDateTime(offsets[2], object.completedAt);
  writer.writeDouble(offsets[3], object.completionPercentage);
  writer.writeLong(offsets[4], object.correctAnswers);
  writer.writeDateTime(offsets[5], object.createdAt);
  writer.writeLong(offsets[6], object.currentProblemIndex);
  writer.writeString(offsets[7], object.difficulties);
  writer.writeStringList(offsets[8], object.difficultiesList);
  writer.writeDouble(offsets[9], object.finalScore);
  writer.writeLong(offsets[10], object.hashCode);
  writer.writeLong(offsets[11], object.incorrectAnswers);
  writer.writeBool(offsets[12], object.isActive);
  writer.writeBool(offsets[13], object.isCompleted);
  writer.writeBool(offsets[14], object.isPaused);
  writer.writeString(offsets[15], object.notes);
  writer.writeDateTime(offsets[16], object.pausedAt);
  writer.writeString(offsets[17], object.problemIds);
  writer.writeStringList(offsets[18], object.problemIdsList);
  writer.writeString(offsets[19], object.reviewData);
  writer.writeString(offsets[20], object.sessionId);
  writer.writeString(offsets[21], object.settings);
  writer.writeLong(offsets[22], object.skippedProblems);
  writer.writeString(offsets[23], object.status.name);
  writer.writeString(offsets[24], object.subjects);
  writer.writeStringList(offsets[25], object.subjectsList);
  writer.writeString(offsets[26], object.title);
  writer.writeLong(offsets[27], object.totalProblems);
  writer.writeLong(offsets[28], object.totalTimeMs);
  writer.writeString(offsets[29], object.type.name);
  writer.writeString(offsets[30], object.userAnswers);
}

QuizSession _quizSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = QuizSession();
  object.completedAt = reader.readDateTimeOrNull(offsets[2]);
  object.correctAnswers = reader.readLong(offsets[4]);
  object.createdAt = reader.readDateTime(offsets[5]);
  object.currentProblemIndex = reader.readLong(offsets[6]);
  object.difficulties = reader.readStringOrNull(offsets[7]);
  object.finalScore = reader.readDouble(offsets[9]);
  object.id = id;
  object.incorrectAnswers = reader.readLong(offsets[11]);
  object.notes = reader.readStringOrNull(offsets[15]);
  object.pausedAt = reader.readDateTimeOrNull(offsets[16]);
  object.problemIds = reader.readString(offsets[17]);
  object.reviewData = reader.readStringOrNull(offsets[19]);
  object.sessionId = reader.readString(offsets[20]);
  object.settings = reader.readStringOrNull(offsets[21]);
  object.skippedProblems = reader.readLong(offsets[22]);
  object.status =
      _QuizSessionstatusValueEnumMap[reader.readStringOrNull(offsets[23])] ??
          SessionStatus.active;
  object.subjects = reader.readStringOrNull(offsets[24]);
  object.title = reader.readString(offsets[26]);
  object.totalProblems = reader.readLong(offsets[27]);
  object.totalTimeMs = reader.readLong(offsets[28]);
  object.type =
      _QuizSessiontypeValueEnumMap[reader.readStringOrNull(offsets[29])] ??
          SessionType.practice;
  object.userAnswers = reader.readStringOrNull(offsets[30]);
  return object;
}

P _quizSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringList(offset) ?? []) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readStringList(offset) ?? []) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readLong(offset)) as P;
    case 23:
      return (_QuizSessionstatusValueEnumMap[reader.readStringOrNull(offset)] ??
          SessionStatus.active) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readStringList(offset) ?? []) as P;
    case 26:
      return (reader.readString(offset)) as P;
    case 27:
      return (reader.readLong(offset)) as P;
    case 28:
      return (reader.readLong(offset)) as P;
    case 29:
      return (_QuizSessiontypeValueEnumMap[reader.readStringOrNull(offset)] ??
          SessionType.practice) as P;
    case 30:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _QuizSessionstatusEnumValueMap = {
  r'active': r'active',
  r'completed': r'completed',
  r'paused': r'paused',
  r'abandoned': r'abandoned',
};
const _QuizSessionstatusValueEnumMap = {
  r'active': SessionStatus.active,
  r'completed': SessionStatus.completed,
  r'paused': SessionStatus.paused,
  r'abandoned': SessionStatus.abandoned,
};
const _QuizSessiontypeEnumValueMap = {
  r'practice': r'practice',
  r'exam': r'exam',
  r'review': r'review',
  r'challenge': r'challenge',
};
const _QuizSessiontypeValueEnumMap = {
  r'practice': SessionType.practice,
  r'exam': SessionType.exam,
  r'review': SessionType.review,
  r'challenge': SessionType.challenge,
};

Id _quizSessionGetId(QuizSession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _quizSessionGetLinks(QuizSession object) {
  return [];
}

void _quizSessionAttach(
    IsarCollection<dynamic> col, Id id, QuizSession object) {
  object.id = id;
}

extension QuizSessionByIndex on IsarCollection<QuizSession> {
  Future<QuizSession?> getBySessionId(String sessionId) {
    return getByIndex(r'sessionId', [sessionId]);
  }

  QuizSession? getBySessionIdSync(String sessionId) {
    return getByIndexSync(r'sessionId', [sessionId]);
  }

  Future<bool> deleteBySessionId(String sessionId) {
    return deleteByIndex(r'sessionId', [sessionId]);
  }

  bool deleteBySessionIdSync(String sessionId) {
    return deleteByIndexSync(r'sessionId', [sessionId]);
  }

  Future<List<QuizSession?>> getAllBySessionId(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'sessionId', values);
  }

  List<QuizSession?> getAllBySessionIdSync(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'sessionId', values);
  }

  Future<int> deleteAllBySessionId(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'sessionId', values);
  }

  int deleteAllBySessionIdSync(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'sessionId', values);
  }

  Future<Id> putBySessionId(QuizSession object) {
    return putByIndex(r'sessionId', object);
  }

  Id putBySessionIdSync(QuizSession object, {bool saveLinks = true}) {
    return putByIndexSync(r'sessionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySessionId(List<QuizSession> objects) {
    return putAllByIndex(r'sessionId', objects);
  }

  List<Id> putAllBySessionIdSync(List<QuizSession> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'sessionId', objects, saveLinks: saveLinks);
  }
}

extension QuizSessionQueryWhereSort
    on QueryBuilder<QuizSession, QuizSession, QWhere> {
  QueryBuilder<QuizSession, QuizSession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension QuizSessionQueryWhere
    on QueryBuilder<QuizSession, QuizSession, QWhereClause> {
  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> idBetween(
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

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> sessionIdEqualTo(
      String sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionId',
        value: [sessionId],
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> sessionIdNotEqualTo(
      String sessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> titleEqualTo(
      String title) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'title',
        value: [title],
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterWhereClause> titleNotEqualTo(
      String title) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [],
              upper: [title],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [title],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [title],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [],
              upper: [title],
              includeUpper: false,
            ));
      }
    });
  }
}

extension QuizSessionQueryFilter
    on QueryBuilder<QuizSession, QuizSession, QFilterCondition> {
  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> accuracyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      accuracyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      accuracyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> accuracyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accuracy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      averageTimePerProblemEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'averageTimePerProblem',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      averageTimePerProblemGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'averageTimePerProblem',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      averageTimePerProblemLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'averageTimePerProblem',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      averageTimePerProblemBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'averageTimePerProblem',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      completionPercentageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completionPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      completionPercentageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completionPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      completionPercentageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completionPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      completionPercentageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completionPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      correctAnswersEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctAnswers',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      correctAnswersGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correctAnswers',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      correctAnswersLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correctAnswers',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      correctAnswersBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correctAnswers',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      currentProblemIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentProblemIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      currentProblemIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentProblemIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      currentProblemIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentProblemIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      currentProblemIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentProblemIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'difficulties',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'difficulties',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficulties',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'difficulties',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'difficulties',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'difficulties',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'difficulties',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'difficulties',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'difficulties',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'difficulties',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficulties',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'difficulties',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesListElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficultiesList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesListElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'difficultiesList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesListElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'difficultiesList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesListElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'difficultiesList',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesListElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'difficultiesList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesListElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'difficultiesList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesListElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'difficultiesList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesListElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'difficultiesList',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesListElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficultiesList',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesListElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'difficultiesList',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'difficultiesList',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'difficultiesList',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'difficultiesList',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesListLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'difficultiesList',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesListLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'difficultiesList',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      difficultiesListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'difficultiesList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      finalScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'finalScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      finalScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'finalScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      finalScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'finalScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      finalScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'finalScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> hashCodeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> idGreaterThan(
    Id value, {
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> idLessThan(
    Id value, {
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      incorrectAnswersEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'incorrectAnswers',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      incorrectAnswersGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'incorrectAnswers',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      incorrectAnswersLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'incorrectAnswers',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      incorrectAnswersBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'incorrectAnswers',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> isActiveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> isPausedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPaused',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      pausedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pausedAt',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      pausedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pausedAt',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> pausedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pausedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      pausedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pausedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      pausedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pausedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> pausedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pausedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'problemIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'problemIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'problemIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'problemIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'problemIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'problemIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'problemIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'problemIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'problemIds',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'problemIds',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsListElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'problemIdsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsListElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'problemIdsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsListElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'problemIdsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsListElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'problemIdsList',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsListElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'problemIdsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsListElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'problemIdsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsListElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'problemIdsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsListElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'problemIdsList',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsListElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'problemIdsList',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsListElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'problemIdsList',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'problemIdsList',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'problemIdsList',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'problemIdsList',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsListLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'problemIdsList',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsListLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'problemIdsList',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      problemIdsListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'problemIdsList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      reviewDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reviewData',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      reviewDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reviewData',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      reviewDataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      reviewDataGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reviewData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      reviewDataLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reviewData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      reviewDataBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reviewData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      reviewDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reviewData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      reviewDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reviewData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      reviewDataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reviewData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      reviewDataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reviewData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      reviewDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewData',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      reviewDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reviewData',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      sessionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      sessionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      sessionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      sessionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      sessionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      sessionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      sessionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      sessionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sessionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      sessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      sessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      settingsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'settings',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      settingsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'settings',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> settingsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      settingsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      settingsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> settingsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settings',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      settingsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      settingsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      settingsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'settings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> settingsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'settings',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      settingsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settings',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      settingsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'settings',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      skippedProblemsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'skippedProblems',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      skippedProblemsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'skippedProblems',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      skippedProblemsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'skippedProblems',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      skippedProblemsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'skippedProblems',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> statusEqualTo(
    SessionStatus value, {
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      statusGreaterThan(
    SessionStatus value, {
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> statusLessThan(
    SessionStatus value, {
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> statusBetween(
    SessionStatus lower,
    SessionStatus upper, {
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> statusEndsWith(
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> statusContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> statusMatches(
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subjects',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subjects',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> subjectsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> subjectsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjects',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subjects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subjects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> subjectsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjects',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjects',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjects',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsListElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsListElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsListElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsListElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectsList',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsListElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subjectsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsListElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subjectsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsListElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsListElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectsList',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsListElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectsList',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsListElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectsList',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subjectsList',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subjectsList',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subjectsList',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsListLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subjectsList',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsListLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subjectsList',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      subjectsListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subjectsList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> titleEqualTo(
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> titleStartsWith(
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> titleEndsWith(
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> titleContains(
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> titleMatches(
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      totalProblemsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalProblems',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      totalProblemsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalProblems',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      totalProblemsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalProblems',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      totalProblemsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalProblems',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      totalTimeMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      totalTimeMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      totalTimeMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      totalTimeMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalTimeMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> typeEqualTo(
    SessionType value, {
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> typeGreaterThan(
    SessionType value, {
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> typeLessThan(
    SessionType value, {
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> typeBetween(
    SessionType lower,
    SessionType upper, {
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> typeStartsWith(
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> typeEndsWith(
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> typeContains(
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> typeMatches(
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

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      userAnswersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'userAnswers',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      userAnswersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'userAnswers',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      userAnswersEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userAnswers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      userAnswersGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userAnswers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      userAnswersLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userAnswers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      userAnswersBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userAnswers',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      userAnswersStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userAnswers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      userAnswersEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userAnswers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      userAnswersContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userAnswers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      userAnswersMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userAnswers',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      userAnswersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userAnswers',
        value: '',
      ));
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterFilterCondition>
      userAnswersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userAnswers',
        value: '',
      ));
    });
  }
}

extension QuizSessionQueryObject
    on QueryBuilder<QuizSession, QuizSession, QFilterCondition> {}

extension QuizSessionQueryLinks
    on QueryBuilder<QuizSession, QuizSession, QFilterCondition> {}

extension QuizSessionQuerySortBy
    on QueryBuilder<QuizSession, QuizSession, QSortBy> {
  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      sortByAverageTimePerProblem() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageTimePerProblem', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      sortByAverageTimePerProblemDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageTimePerProblem', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      sortByCompletionPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionPercentage', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      sortByCompletionPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionPercentage', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByCorrectAnswers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswers', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      sortByCorrectAnswersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswers', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      sortByCurrentProblemIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentProblemIndex', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      sortByCurrentProblemIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentProblemIndex', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByDifficulties() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulties', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      sortByDifficultiesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulties', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByFinalScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalScore', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByFinalScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalScore', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      sortByIncorrectAnswers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incorrectAnswers', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      sortByIncorrectAnswersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incorrectAnswers', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByIsPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByPausedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pausedAt', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByPausedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pausedAt', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByProblemIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'problemIds', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByProblemIdsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'problemIds', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByReviewData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewData', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByReviewDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewData', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortBySettings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settings', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortBySettingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settings', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortBySkippedProblems() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skippedProblems', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      sortBySkippedProblemsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skippedProblems', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortBySubjects() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjects', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortBySubjectsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjects', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByTotalProblems() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalProblems', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      sortByTotalProblemsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalProblems', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByTotalTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTimeMs', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByTotalTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTimeMs', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByUserAnswers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAnswers', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> sortByUserAnswersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAnswers', Sort.desc);
    });
  }
}

extension QuizSessionQuerySortThenBy
    on QueryBuilder<QuizSession, QuizSession, QSortThenBy> {
  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      thenByAverageTimePerProblem() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageTimePerProblem', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      thenByAverageTimePerProblemDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageTimePerProblem', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      thenByCompletionPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionPercentage', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      thenByCompletionPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionPercentage', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByCorrectAnswers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswers', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      thenByCorrectAnswersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswers', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      thenByCurrentProblemIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentProblemIndex', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      thenByCurrentProblemIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentProblemIndex', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByDifficulties() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulties', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      thenByDifficultiesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulties', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByFinalScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalScore', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByFinalScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalScore', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      thenByIncorrectAnswers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incorrectAnswers', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      thenByIncorrectAnswersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incorrectAnswers', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByIsPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByPausedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pausedAt', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByPausedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pausedAt', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByProblemIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'problemIds', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByProblemIdsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'problemIds', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByReviewData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewData', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByReviewDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewData', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenBySettings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settings', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenBySettingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settings', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenBySkippedProblems() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skippedProblems', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      thenBySkippedProblemsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skippedProblems', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenBySubjects() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjects', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenBySubjectsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjects', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByTotalProblems() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalProblems', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy>
      thenByTotalProblemsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalProblems', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByTotalTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTimeMs', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByTotalTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTimeMs', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByUserAnswers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAnswers', Sort.asc);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QAfterSortBy> thenByUserAnswersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAnswers', Sort.desc);
    });
  }
}

extension QuizSessionQueryWhereDistinct
    on QueryBuilder<QuizSession, QuizSession, QDistinct> {
  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accuracy');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct>
      distinctByAverageTimePerProblem() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'averageTimePerProblem');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct>
      distinctByCompletionPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completionPercentage');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByCorrectAnswers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctAnswers');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct>
      distinctByCurrentProblemIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentProblemIndex');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByDifficulties(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'difficulties', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct>
      distinctByDifficultiesList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'difficultiesList');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByFinalScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'finalScore');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct>
      distinctByIncorrectAnswers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'incorrectAnswers');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPaused');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByPausedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pausedAt');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByProblemIds(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'problemIds', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByProblemIdsList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'problemIdsList');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByReviewData(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewData', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctBySessionId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctBySettings(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settings', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct>
      distinctBySkippedProblems() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skippedProblems');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctBySubjects(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjects', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctBySubjectsList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectsList');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByTotalProblems() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalProblems');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByTotalTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalTimeMs');
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuizSession, QuizSession, QDistinct> distinctByUserAnswers(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userAnswers', caseSensitive: caseSensitive);
    });
  }
}

extension QuizSessionQueryProperty
    on QueryBuilder<QuizSession, QuizSession, QQueryProperty> {
  QueryBuilder<QuizSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<QuizSession, double, QQueryOperations> accuracyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accuracy');
    });
  }

  QueryBuilder<QuizSession, double, QQueryOperations>
      averageTimePerProblemProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'averageTimePerProblem');
    });
  }

  QueryBuilder<QuizSession, DateTime?, QQueryOperations> completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<QuizSession, double, QQueryOperations>
      completionPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completionPercentage');
    });
  }

  QueryBuilder<QuizSession, int, QQueryOperations> correctAnswersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctAnswers');
    });
  }

  QueryBuilder<QuizSession, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<QuizSession, int, QQueryOperations>
      currentProblemIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentProblemIndex');
    });
  }

  QueryBuilder<QuizSession, String?, QQueryOperations> difficultiesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'difficulties');
    });
  }

  QueryBuilder<QuizSession, List<String>, QQueryOperations>
      difficultiesListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'difficultiesList');
    });
  }

  QueryBuilder<QuizSession, double, QQueryOperations> finalScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'finalScore');
    });
  }

  QueryBuilder<QuizSession, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<QuizSession, int, QQueryOperations> incorrectAnswersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'incorrectAnswers');
    });
  }

  QueryBuilder<QuizSession, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<QuizSession, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<QuizSession, bool, QQueryOperations> isPausedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPaused');
    });
  }

  QueryBuilder<QuizSession, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<QuizSession, DateTime?, QQueryOperations> pausedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pausedAt');
    });
  }

  QueryBuilder<QuizSession, String, QQueryOperations> problemIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'problemIds');
    });
  }

  QueryBuilder<QuizSession, List<String>, QQueryOperations>
      problemIdsListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'problemIdsList');
    });
  }

  QueryBuilder<QuizSession, String?, QQueryOperations> reviewDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewData');
    });
  }

  QueryBuilder<QuizSession, String, QQueryOperations> sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<QuizSession, String?, QQueryOperations> settingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settings');
    });
  }

  QueryBuilder<QuizSession, int, QQueryOperations> skippedProblemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skippedProblems');
    });
  }

  QueryBuilder<QuizSession, SessionStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<QuizSession, String?, QQueryOperations> subjectsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjects');
    });
  }

  QueryBuilder<QuizSession, List<String>, QQueryOperations>
      subjectsListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectsList');
    });
  }

  QueryBuilder<QuizSession, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<QuizSession, int, QQueryOperations> totalProblemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalProblems');
    });
  }

  QueryBuilder<QuizSession, int, QQueryOperations> totalTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalTimeMs');
    });
  }

  QueryBuilder<QuizSession, SessionType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<QuizSession, String?, QQueryOperations> userAnswersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userAnswers');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizSession _$QuizSessionFromJson(Map<String, dynamic> json) => QuizSession()
  ..id = (json['id'] as num).toInt()
  ..sessionId = json['session_id'] as String
  ..title = json['title'] as String
  ..type = $enumDecode(_$SessionTypeEnumMap, json['type'])
  ..status = $enumDecode(_$SessionStatusEnumMap, json['status'])
  ..problemIds = json['problemIds'] as String
  ..userAnswers = json['userAnswers'] as String?
  ..createdAt = DateTime.parse(json['createdAt'] as String)
  ..completedAt = json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String)
  ..pausedAt = json['pausedAt'] == null
      ? null
      : DateTime.parse(json['pausedAt'] as String)
  ..totalTimeMs = (json['totalTimeMs'] as num?)?.toInt() ?? 0
  ..currentProblemIndex = (json['currentProblemIndex'] as num?)?.toInt() ?? 0
  ..totalProblems = (json['totalProblems'] as num?)?.toInt() ?? 0
  ..correctAnswers = (json['correctAnswers'] as num?)?.toInt() ?? 0
  ..incorrectAnswers = (json['incorrectAnswers'] as num?)?.toInt() ?? 0
  ..skippedProblems = (json['skippedProblems'] as num?)?.toInt() ?? 0
  ..finalScore = (json['finalScore'] as num?)?.toDouble() ?? 0.0
  ..settings = json['settings'] as String?
  ..notes = json['notes'] as String?
  ..subjects = json['subjects'] as String?
  ..difficulties = json['difficulties'] as String?
  ..reviewData = json['reviewData'] as String?;

Map<String, dynamic> _$QuizSessionToJson(QuizSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session_id': instance.sessionId,
      'title': instance.title,
      'type': _$SessionTypeEnumMap[instance.type]!,
      'status': _$SessionStatusEnumMap[instance.status]!,
      'problemIds': instance.problemIds,
      'userAnswers': instance.userAnswers,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'pausedAt': instance.pausedAt?.toIso8601String(),
      'totalTimeMs': instance.totalTimeMs,
      'currentProblemIndex': instance.currentProblemIndex,
      'totalProblems': instance.totalProblems,
      'correctAnswers': instance.correctAnswers,
      'incorrectAnswers': instance.incorrectAnswers,
      'skippedProblems': instance.skippedProblems,
      'finalScore': instance.finalScore,
      'settings': instance.settings,
      'notes': instance.notes,
      'subjects': instance.subjects,
      'difficulties': instance.difficulties,
      'reviewData': instance.reviewData,
    };

const _$SessionTypeEnumMap = {
  SessionType.practice: 'practice',
  SessionType.exam: 'exam',
  SessionType.review: 'review',
  SessionType.challenge: 'challenge',
};

const _$SessionStatusEnumMap = {
  SessionStatus.active: 'active',
  SessionStatus.completed: 'completed',
  SessionStatus.paused: 'paused',
  SessionStatus.abandoned: 'abandoned',
};
