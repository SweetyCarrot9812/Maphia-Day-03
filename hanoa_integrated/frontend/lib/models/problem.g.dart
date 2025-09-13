// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProblemCollection on Isar {
  IsarCollection<Problem> get problems => this.collection();
}

const ProblemSchema = CollectionSchema(
  name: r'Problem',
  id: -6990160055201196463,
  properties: {
    r'aiConfidence': PropertySchema(
      id: 0,
      name: r'aiConfidence',
      type: IsarType.double,
    ),
    r'aiModel': PropertySchema(
      id: 1,
      name: r'aiModel',
      type: IsarType.string,
    ),
    r'aiPrompt': PropertySchema(
      id: 2,
      name: r'aiPrompt',
      type: IsarType.string,
    ),
    r'attachments': PropertySchema(
      id: 3,
      name: r'attachments',
      type: IsarType.string,
    ),
    r'attachmentsList': PropertySchema(
      id: 4,
      name: r'attachmentsList',
      type: IsarType.stringList,
    ),
    r'attemptCount': PropertySchema(
      id: 5,
      name: r'attemptCount',
      type: IsarType.long,
    ),
    r'averageScore': PropertySchema(
      id: 6,
      name: r'averageScore',
      type: IsarType.double,
    ),
    r'content': PropertySchema(
      id: 7,
      name: r'content',
      type: IsarType.string,
    ),
    r'correctAnswer': PropertySchema(
      id: 8,
      name: r'correctAnswer',
      type: IsarType.string,
    ),
    r'correctAnswerList': PropertySchema(
      id: 9,
      name: r'correctAnswerList',
      type: IsarType.stringList,
    ),
    r'correctCount': PropertySchema(
      id: 10,
      name: r'correctCount',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 11,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'difficulty': PropertySchema(
      id: 12,
      name: r'difficulty',
      type: IsarType.string,
      enumMap: _ProblemdifficultyEnumValueMap,
    ),
    r'estimatedTimeMinutes': PropertySchema(
      id: 13,
      name: r'estimatedTimeMinutes',
      type: IsarType.long,
    ),
    r'explanation': PropertySchema(
      id: 14,
      name: r'explanation',
      type: IsarType.string,
    ),
    r'hashCode': PropertySchema(
      id: 15,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'isActive': PropertySchema(
      id: 16,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isDifficult': PropertySchema(
      id: 17,
      name: r'isDifficult',
      type: IsarType.bool,
    ),
    r'isMastered': PropertySchema(
      id: 18,
      name: r'isMastered',
      type: IsarType.bool,
    ),
    r'isNew': PropertySchema(
      id: 19,
      name: r'isNew',
      type: IsarType.bool,
    ),
    r'objectives': PropertySchema(
      id: 20,
      name: r'objectives',
      type: IsarType.string,
    ),
    r'options': PropertySchema(
      id: 21,
      name: r'options',
      type: IsarType.string,
    ),
    r'optionsList': PropertySchema(
      id: 22,
      name: r'optionsList',
      type: IsarType.stringList,
    ),
    r'points': PropertySchema(
      id: 23,
      name: r'points',
      type: IsarType.long,
    ),
    r'problemId': PropertySchema(
      id: 24,
      name: r'problemId',
      type: IsarType.string,
    ),
    r'references': PropertySchema(
      id: 25,
      name: r'references',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 26,
      name: r'status',
      type: IsarType.string,
      enumMap: _ProblemstatusEnumValueMap,
    ),
    r'subject': PropertySchema(
      id: 27,
      name: r'subject',
      type: IsarType.string,
    ),
    r'successRate': PropertySchema(
      id: 28,
      name: r'successRate',
      type: IsarType.double,
    ),
    r'tags': PropertySchema(
      id: 29,
      name: r'tags',
      type: IsarType.string,
    ),
    r'tagsList': PropertySchema(
      id: 30,
      name: r'tagsList',
      type: IsarType.stringList,
    ),
    r'title': PropertySchema(
      id: 31,
      name: r'title',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 32,
      name: r'type',
      type: IsarType.string,
      enumMap: _ProblemtypeEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 33,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'version': PropertySchema(
      id: 34,
      name: r'version',
      type: IsarType.long,
    )
  },
  estimateSize: _problemEstimateSize,
  serialize: _problemSerialize,
  deserialize: _problemDeserialize,
  deserializeProp: _problemDeserializeProp,
  idName: r'id',
  indexes: {
    r'problemId': IndexSchema(
      id: -837936693795967971,
      name: r'problemId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'problemId',
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
    ),
    r'subject': IndexSchema(
      id: 3257156273020483090,
      name: r'subject',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'subject',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isActive': IndexSchema(
      id: 8092228061260947457,
      name: r'isActive',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isActive',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _problemGetId,
  getLinks: _problemGetLinks,
  attach: _problemAttach,
  version: '3.1.0+1',
);

int _problemEstimateSize(
  Problem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.aiModel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.aiPrompt;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.attachments;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.attachmentsList.length * 3;
  {
    for (var i = 0; i < object.attachmentsList.length; i++) {
      final value = object.attachmentsList[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.content.length * 3;
  {
    final value = object.correctAnswer;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.correctAnswerList.length * 3;
  {
    for (var i = 0; i < object.correctAnswerList.length; i++) {
      final value = object.correctAnswerList[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.difficulty.name.length * 3;
  {
    final value = object.explanation;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.objectives;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.options;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.optionsList.length * 3;
  {
    for (var i = 0; i < object.optionsList.length; i++) {
      final value = object.optionsList[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.problemId.length * 3;
  {
    final value = object.references;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.name.length * 3;
  {
    final value = object.subject;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tags;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.tagsList.length * 3;
  {
    for (var i = 0; i < object.tagsList.length; i++) {
      final value = object.tagsList[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.type.name.length * 3;
  return bytesCount;
}

void _problemSerialize(
  Problem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.aiConfidence);
  writer.writeString(offsets[1], object.aiModel);
  writer.writeString(offsets[2], object.aiPrompt);
  writer.writeString(offsets[3], object.attachments);
  writer.writeStringList(offsets[4], object.attachmentsList);
  writer.writeLong(offsets[5], object.attemptCount);
  writer.writeDouble(offsets[6], object.averageScore);
  writer.writeString(offsets[7], object.content);
  writer.writeString(offsets[8], object.correctAnswer);
  writer.writeStringList(offsets[9], object.correctAnswerList);
  writer.writeLong(offsets[10], object.correctCount);
  writer.writeDateTime(offsets[11], object.createdAt);
  writer.writeString(offsets[12], object.difficulty.name);
  writer.writeLong(offsets[13], object.estimatedTimeMinutes);
  writer.writeString(offsets[14], object.explanation);
  writer.writeLong(offsets[15], object.hashCode);
  writer.writeBool(offsets[16], object.isActive);
  writer.writeBool(offsets[17], object.isDifficult);
  writer.writeBool(offsets[18], object.isMastered);
  writer.writeBool(offsets[19], object.isNew);
  writer.writeString(offsets[20], object.objectives);
  writer.writeString(offsets[21], object.options);
  writer.writeStringList(offsets[22], object.optionsList);
  writer.writeLong(offsets[23], object.points);
  writer.writeString(offsets[24], object.problemId);
  writer.writeString(offsets[25], object.references);
  writer.writeString(offsets[26], object.status.name);
  writer.writeString(offsets[27], object.subject);
  writer.writeDouble(offsets[28], object.successRate);
  writer.writeString(offsets[29], object.tags);
  writer.writeStringList(offsets[30], object.tagsList);
  writer.writeString(offsets[31], object.title);
  writer.writeString(offsets[32], object.type.name);
  writer.writeDateTime(offsets[33], object.updatedAt);
  writer.writeLong(offsets[34], object.version);
}

Problem _problemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Problem();
  object.aiConfidence = reader.readDoubleOrNull(offsets[0]);
  object.aiModel = reader.readStringOrNull(offsets[1]);
  object.aiPrompt = reader.readStringOrNull(offsets[2]);
  object.attachments = reader.readStringOrNull(offsets[3]);
  object.attemptCount = reader.readLong(offsets[5]);
  object.averageScore = reader.readDouble(offsets[6]);
  object.content = reader.readString(offsets[7]);
  object.correctAnswer = reader.readStringOrNull(offsets[8]);
  object.correctCount = reader.readLong(offsets[10]);
  object.createdAt = reader.readDateTime(offsets[11]);
  object.difficulty =
      _ProblemdifficultyValueEnumMap[reader.readStringOrNull(offsets[12])] ??
          Difficulty.easy;
  object.estimatedTimeMinutes = reader.readLong(offsets[13]);
  object.explanation = reader.readStringOrNull(offsets[14]);
  object.id = id;
  object.isActive = reader.readBool(offsets[16]);
  object.objectives = reader.readStringOrNull(offsets[20]);
  object.options = reader.readStringOrNull(offsets[21]);
  object.points = reader.readLong(offsets[23]);
  object.problemId = reader.readString(offsets[24]);
  object.references = reader.readStringOrNull(offsets[25]);
  object.status =
      _ProblemstatusValueEnumMap[reader.readStringOrNull(offsets[26])] ??
          ProblemStatus.draft;
  object.subject = reader.readStringOrNull(offsets[27]);
  object.tags = reader.readStringOrNull(offsets[29]);
  object.title = reader.readString(offsets[31]);
  object.type =
      _ProblemtypeValueEnumMap[reader.readStringOrNull(offsets[32])] ??
          ProblemType.nursing;
  object.updatedAt = reader.readDateTime(offsets[33]);
  object.version = reader.readLong(offsets[34]);
  return object;
}

P _problemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringList(offset) ?? []) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    case 12:
      return (_ProblemdifficultyValueEnumMap[reader.readStringOrNull(offset)] ??
          Difficulty.easy) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readBool(offset)) as P;
    case 18:
      return (reader.readBool(offset)) as P;
    case 19:
      return (reader.readBool(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readStringList(offset) ?? []) as P;
    case 23:
      return (reader.readLong(offset)) as P;
    case 24:
      return (reader.readString(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (_ProblemstatusValueEnumMap[reader.readStringOrNull(offset)] ??
          ProblemStatus.draft) as P;
    case 27:
      return (reader.readStringOrNull(offset)) as P;
    case 28:
      return (reader.readDouble(offset)) as P;
    case 29:
      return (reader.readStringOrNull(offset)) as P;
    case 30:
      return (reader.readStringList(offset) ?? []) as P;
    case 31:
      return (reader.readString(offset)) as P;
    case 32:
      return (_ProblemtypeValueEnumMap[reader.readStringOrNull(offset)] ??
          ProblemType.nursing) as P;
    case 33:
      return (reader.readDateTime(offset)) as P;
    case 34:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ProblemdifficultyEnumValueMap = {
  r'easy': r'easy',
  r'medium': r'medium',
  r'hard': r'hard',
  r'expert': r'expert',
  r'beginner': r'beginner',
  r'intermediate': r'intermediate',
  r'advanced': r'advanced',
};
const _ProblemdifficultyValueEnumMap = {
  r'easy': Difficulty.easy,
  r'medium': Difficulty.medium,
  r'hard': Difficulty.hard,
  r'expert': Difficulty.expert,
  r'beginner': Difficulty.beginner,
  r'intermediate': Difficulty.intermediate,
  r'advanced': Difficulty.advanced,
};
const _ProblemstatusEnumValueMap = {
  r'draft': r'draft',
  r'review': r'review',
  r'published': r'published',
  r'active': r'active',
  r'archived': r'archived',
  r'under_review': r'under_review',
  r'approved': r'approved',
};
const _ProblemstatusValueEnumMap = {
  r'draft': ProblemStatus.draft,
  r'review': ProblemStatus.review,
  r'published': ProblemStatus.published,
  r'active': ProblemStatus.active,
  r'archived': ProblemStatus.archived,
  r'under_review': ProblemStatus.under_review,
  r'approved': ProblemStatus.approved,
};
const _ProblemtypeEnumValueMap = {
  r'nursing': r'nursing',
  r'essay': r'essay',
  r'simulation': r'simulation',
  r'multiple_choice': r'multiple_choice',
  r'short_answer': r'short_answer',
};
const _ProblemtypeValueEnumMap = {
  r'nursing': ProblemType.nursing,
  r'essay': ProblemType.essay,
  r'simulation': ProblemType.simulation,
  r'multiple_choice': ProblemType.multiple_choice,
  r'short_answer': ProblemType.short_answer,
};

Id _problemGetId(Problem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _problemGetLinks(Problem object) {
  return [];
}

void _problemAttach(IsarCollection<dynamic> col, Id id, Problem object) {
  object.id = id;
}

extension ProblemByIndex on IsarCollection<Problem> {
  Future<Problem?> getByProblemId(String problemId) {
    return getByIndex(r'problemId', [problemId]);
  }

  Problem? getByProblemIdSync(String problemId) {
    return getByIndexSync(r'problemId', [problemId]);
  }

  Future<bool> deleteByProblemId(String problemId) {
    return deleteByIndex(r'problemId', [problemId]);
  }

  bool deleteByProblemIdSync(String problemId) {
    return deleteByIndexSync(r'problemId', [problemId]);
  }

  Future<List<Problem?>> getAllByProblemId(List<String> problemIdValues) {
    final values = problemIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'problemId', values);
  }

  List<Problem?> getAllByProblemIdSync(List<String> problemIdValues) {
    final values = problemIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'problemId', values);
  }

  Future<int> deleteAllByProblemId(List<String> problemIdValues) {
    final values = problemIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'problemId', values);
  }

  int deleteAllByProblemIdSync(List<String> problemIdValues) {
    final values = problemIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'problemId', values);
  }

  Future<Id> putByProblemId(Problem object) {
    return putByIndex(r'problemId', object);
  }

  Id putByProblemIdSync(Problem object, {bool saveLinks = true}) {
    return putByIndexSync(r'problemId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByProblemId(List<Problem> objects) {
    return putAllByIndex(r'problemId', objects);
  }

  List<Id> putAllByProblemIdSync(List<Problem> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'problemId', objects, saveLinks: saveLinks);
  }
}

extension ProblemQueryWhereSort on QueryBuilder<Problem, Problem, QWhere> {
  QueryBuilder<Problem, Problem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Problem, Problem, QAfterWhere> anyIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isActive'),
      );
    });
  }
}

extension ProblemQueryWhere on QueryBuilder<Problem, Problem, QWhereClause> {
  QueryBuilder<Problem, Problem, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Problem, Problem, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterWhereClause> idBetween(
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

  QueryBuilder<Problem, Problem, QAfterWhereClause> problemIdEqualTo(
      String problemId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'problemId',
        value: [problemId],
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterWhereClause> problemIdNotEqualTo(
      String problemId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'problemId',
              lower: [],
              upper: [problemId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'problemId',
              lower: [problemId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'problemId',
              lower: [problemId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'problemId',
              lower: [],
              upper: [problemId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Problem, Problem, QAfterWhereClause> titleEqualTo(String title) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'title',
        value: [title],
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterWhereClause> titleNotEqualTo(
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

  QueryBuilder<Problem, Problem, QAfterWhereClause> subjectIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subject',
        value: [null],
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterWhereClause> subjectIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'subject',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterWhereClause> subjectEqualTo(
      String? subject) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subject',
        value: [subject],
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterWhereClause> subjectNotEqualTo(
      String? subject) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subject',
              lower: [],
              upper: [subject],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subject',
              lower: [subject],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subject',
              lower: [subject],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subject',
              lower: [],
              upper: [subject],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Problem, Problem, QAfterWhereClause> isActiveEqualTo(
      bool isActive) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isActive',
        value: [isActive],
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterWhereClause> isActiveNotEqualTo(
      bool isActive) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [],
              upper: [isActive],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [isActive],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [isActive],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [],
              upper: [isActive],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ProblemQueryFilter
    on QueryBuilder<Problem, Problem, QFilterCondition> {
  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiConfidenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiConfidence',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      aiConfidenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiConfidence',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiConfidenceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiConfidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiConfidenceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiConfidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiConfidenceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiConfidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiConfidenceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiConfidence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiModelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiModel',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiModelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiModel',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiModelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiModelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiModelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiModelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiModel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiModelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiModelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiModelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiModelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiModel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiModelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiModel',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiModelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiModel',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiPromptIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiPrompt',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiPromptIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiPrompt',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiPromptEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiPromptGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiPromptLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiPromptBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiPrompt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiPromptStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiPromptEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiPromptContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiPromptMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiPrompt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiPromptIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiPrompt',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> aiPromptIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiPrompt',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> attachmentsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'attachments',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> attachmentsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'attachments',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> attachmentsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attachments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> attachmentsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'attachments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> attachmentsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'attachments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> attachmentsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'attachments',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> attachmentsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'attachments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> attachmentsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'attachments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> attachmentsContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'attachments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> attachmentsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'attachments',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> attachmentsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attachments',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      attachmentsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'attachments',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      attachmentsListElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attachmentsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      attachmentsListElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'attachmentsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      attachmentsListElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'attachmentsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      attachmentsListElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'attachmentsList',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      attachmentsListElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'attachmentsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      attachmentsListElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'attachmentsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      attachmentsListElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'attachmentsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      attachmentsListElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'attachmentsList',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      attachmentsListElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attachmentsList',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      attachmentsListElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'attachmentsList',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      attachmentsListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachmentsList',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      attachmentsListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachmentsList',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      attachmentsListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachmentsList',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      attachmentsListLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachmentsList',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      attachmentsListLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachmentsList',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      attachmentsListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachmentsList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> attemptCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attemptCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> attemptCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'attemptCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> attemptCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'attemptCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> attemptCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'attemptCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> averageScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'averageScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> averageScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'averageScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> averageScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'averageScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> averageScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'averageScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> contentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> contentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> contentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> contentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> contentContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> contentMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> correctAnswerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'correctAnswer',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'correctAnswer',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> correctAnswerEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correctAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> correctAnswerLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correctAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> correctAnswerBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correctAnswer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> correctAnswerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'correctAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> correctAnswerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'correctAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> correctAnswerContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'correctAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> correctAnswerMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'correctAnswer',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> correctAnswerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctAnswer',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'correctAnswer',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerListElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctAnswerList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerListElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correctAnswerList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerListElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correctAnswerList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerListElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correctAnswerList',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerListElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'correctAnswerList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerListElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'correctAnswerList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerListElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'correctAnswerList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerListElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'correctAnswerList',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerListElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctAnswerList',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerListElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'correctAnswerList',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'correctAnswerList',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'correctAnswerList',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'correctAnswerList',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerListLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'correctAnswerList',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerListLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'correctAnswerList',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      correctAnswerListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'correctAnswerList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> correctCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> correctCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correctCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> correctCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correctCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> correctCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correctCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> difficultyEqualTo(
    Difficulty value, {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> difficultyGreaterThan(
    Difficulty value, {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> difficultyLessThan(
    Difficulty value, {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> difficultyBetween(
    Difficulty lower,
    Difficulty upper, {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> difficultyStartsWith(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> difficultyEndsWith(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> difficultyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> difficultyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'difficulty',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> difficultyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficulty',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> difficultyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'difficulty',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      estimatedTimeMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estimatedTimeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      estimatedTimeMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estimatedTimeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      estimatedTimeMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estimatedTimeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      estimatedTimeMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estimatedTimeMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> explanationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'explanation',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> explanationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'explanation',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> explanationEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'explanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> explanationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'explanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> explanationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'explanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> explanationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'explanation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> explanationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'explanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> explanationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'explanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> explanationContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'explanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> explanationMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'explanation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> explanationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'explanation',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      explanationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'explanation',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> hashCodeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> hashCodeGreaterThan(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> hashCodeLessThan(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> hashCodeBetween(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> isActiveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> isDifficultEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDifficult',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> isMasteredEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMastered',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> isNewEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isNew',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> objectivesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'objectives',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> objectivesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'objectives',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> objectivesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'objectives',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> objectivesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'objectives',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> objectivesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'objectives',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> objectivesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'objectives',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> objectivesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'objectives',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> objectivesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'objectives',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> objectivesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'objectives',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> objectivesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'objectives',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> objectivesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'objectives',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> objectivesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'objectives',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> optionsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'options',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> optionsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'options',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> optionsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'options',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> optionsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'options',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> optionsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'options',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> optionsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'options',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> optionsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'options',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> optionsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'options',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> optionsContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'options',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> optionsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'options',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> optionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'options',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> optionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'options',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      optionsListElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'optionsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      optionsListElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'optionsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      optionsListElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'optionsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      optionsListElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'optionsList',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      optionsListElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'optionsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      optionsListElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'optionsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      optionsListElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'optionsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      optionsListElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'optionsList',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      optionsListElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'optionsList',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      optionsListElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'optionsList',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      optionsListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'optionsList',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> optionsListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'optionsList',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      optionsListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'optionsList',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      optionsListLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'optionsList',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      optionsListLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'optionsList',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      optionsListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'optionsList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> pointsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'points',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> pointsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'points',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> pointsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'points',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> pointsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'points',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> problemIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'problemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> problemIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'problemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> problemIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'problemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> problemIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'problemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> problemIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'problemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> problemIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'problemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> problemIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'problemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> problemIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'problemId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> problemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'problemId',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> problemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'problemId',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> referencesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'references',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> referencesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'references',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> referencesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'references',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> referencesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'references',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> referencesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'references',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> referencesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'references',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> referencesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'references',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> referencesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'references',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> referencesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'references',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> referencesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'references',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> referencesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'references',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> referencesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'references',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> statusEqualTo(
    ProblemStatus value, {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> statusGreaterThan(
    ProblemStatus value, {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> statusLessThan(
    ProblemStatus value, {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> statusBetween(
    ProblemStatus lower,
    ProblemStatus upper, {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> statusStartsWith(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> statusEndsWith(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> statusContains(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> statusMatches(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> subjectIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subject',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> subjectIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subject',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> subjectEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> subjectGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> subjectLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> subjectBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subject',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> subjectStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> subjectEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> subjectContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> subjectMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subject',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> subjectIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subject',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> subjectIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subject',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> successRateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'successRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> successRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'successRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> successRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'successRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> successRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'successRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tags',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tags',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsListElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tagsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      tagsListElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tagsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsListElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tagsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsListElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tagsList',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      tagsListElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tagsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsListElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tagsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsListElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tagsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsListElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tagsList',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      tagsListElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tagsList',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      tagsListElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tagsList',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsListLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagsList',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagsList',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagsList',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsListLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagsList',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      tagsListLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagsList',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagsList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> titleEqualTo(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> titleGreaterThan(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> titleStartsWith(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> titleEndsWith(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> titleContains(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> titleMatches(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> typeEqualTo(
    ProblemType value, {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> typeGreaterThan(
    ProblemType value, {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> typeLessThan(
    ProblemType value, {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> typeBetween(
    ProblemType lower,
    ProblemType upper, {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> typeStartsWith(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> typeEndsWith(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> typeContains(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> typeMatches(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> versionEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> versionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> versionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> versionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'version',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProblemQueryObject
    on QueryBuilder<Problem, Problem, QFilterCondition> {}

extension ProblemQueryLinks
    on QueryBuilder<Problem, Problem, QFilterCondition> {}

extension ProblemQuerySortBy on QueryBuilder<Problem, Problem, QSortBy> {
  QueryBuilder<Problem, Problem, QAfterSortBy> sortByAiConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidence', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByAiConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidence', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByAiModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModel', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByAiModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModel', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByAiPrompt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiPrompt', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByAiPromptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiPrompt', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByAttachments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachments', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByAttachmentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachments', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByAttemptCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByAverageScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageScore', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByAverageScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageScore', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByCorrectAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswer', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByCorrectAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswer', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByCorrectCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByEstimatedTimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedTimeMinutes', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy>
      sortByEstimatedTimeMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedTimeMinutes', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByExplanation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explanation', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByExplanationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explanation', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByIsDifficult() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDifficult', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByIsDifficultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDifficult', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByIsMastered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMastered', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByIsMasteredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMastered', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByIsNew() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNew', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByIsNewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNew', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByObjectives() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectives', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByObjectivesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectives', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByOptions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'options', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByOptionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'options', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'points', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'points', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByProblemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'problemId', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByProblemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'problemId', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByReferences() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'references', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByReferencesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'references', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortBySuccessRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successRate', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortBySuccessRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successRate', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tags', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByTagsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tags', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension ProblemQuerySortThenBy
    on QueryBuilder<Problem, Problem, QSortThenBy> {
  QueryBuilder<Problem, Problem, QAfterSortBy> thenByAiConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidence', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByAiConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidence', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByAiModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModel', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByAiModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModel', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByAiPrompt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiPrompt', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByAiPromptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiPrompt', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByAttachments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachments', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByAttachmentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachments', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByAttemptCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByAverageScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageScore', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByAverageScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageScore', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByCorrectAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswer', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByCorrectAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswer', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByCorrectCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByEstimatedTimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedTimeMinutes', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy>
      thenByEstimatedTimeMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedTimeMinutes', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByExplanation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explanation', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByExplanationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explanation', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByIsDifficult() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDifficult', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByIsDifficultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDifficult', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByIsMastered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMastered', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByIsMasteredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMastered', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByIsNew() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNew', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByIsNewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNew', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByObjectives() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectives', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByObjectivesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectives', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByOptions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'options', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByOptionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'options', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'points', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'points', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByProblemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'problemId', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByProblemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'problemId', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByReferences() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'references', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByReferencesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'references', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenBySuccessRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successRate', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenBySuccessRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successRate', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tags', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByTagsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tags', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension ProblemQueryWhereDistinct
    on QueryBuilder<Problem, Problem, QDistinct> {
  QueryBuilder<Problem, Problem, QDistinct> distinctByAiConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiConfidence');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByAiModel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiModel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByAiPrompt(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiPrompt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByAttachments(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attachments', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByAttachmentsList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attachmentsList');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attemptCount');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByAverageScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'averageScore');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByCorrectAnswer(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctAnswer',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByCorrectAnswerList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctAnswerList');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctCount');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByDifficulty(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'difficulty', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByEstimatedTimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estimatedTimeMinutes');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByExplanation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'explanation', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByIsDifficult() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDifficult');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByIsMastered() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMastered');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByIsNew() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isNew');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByObjectives(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'objectives', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByOptions(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'options', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByOptionsList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'optionsList');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'points');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByProblemId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'problemId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByReferences(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'references', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctBySubject(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subject', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctBySuccessRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'successRate');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByTags(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByTagsList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tagsList');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }
}

extension ProblemQueryProperty
    on QueryBuilder<Problem, Problem, QQueryProperty> {
  QueryBuilder<Problem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Problem, double?, QQueryOperations> aiConfidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiConfidence');
    });
  }

  QueryBuilder<Problem, String?, QQueryOperations> aiModelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiModel');
    });
  }

  QueryBuilder<Problem, String?, QQueryOperations> aiPromptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiPrompt');
    });
  }

  QueryBuilder<Problem, String?, QQueryOperations> attachmentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attachments');
    });
  }

  QueryBuilder<Problem, List<String>, QQueryOperations>
      attachmentsListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attachmentsList');
    });
  }

  QueryBuilder<Problem, int, QQueryOperations> attemptCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attemptCount');
    });
  }

  QueryBuilder<Problem, double, QQueryOperations> averageScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'averageScore');
    });
  }

  QueryBuilder<Problem, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<Problem, String?, QQueryOperations> correctAnswerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctAnswer');
    });
  }

  QueryBuilder<Problem, List<String>, QQueryOperations>
      correctAnswerListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctAnswerList');
    });
  }

  QueryBuilder<Problem, int, QQueryOperations> correctCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctCount');
    });
  }

  QueryBuilder<Problem, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Problem, Difficulty, QQueryOperations> difficultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'difficulty');
    });
  }

  QueryBuilder<Problem, int, QQueryOperations> estimatedTimeMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estimatedTimeMinutes');
    });
  }

  QueryBuilder<Problem, String?, QQueryOperations> explanationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'explanation');
    });
  }

  QueryBuilder<Problem, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<Problem, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<Problem, bool, QQueryOperations> isDifficultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDifficult');
    });
  }

  QueryBuilder<Problem, bool, QQueryOperations> isMasteredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMastered');
    });
  }

  QueryBuilder<Problem, bool, QQueryOperations> isNewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isNew');
    });
  }

  QueryBuilder<Problem, String?, QQueryOperations> objectivesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'objectives');
    });
  }

  QueryBuilder<Problem, String?, QQueryOperations> optionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'options');
    });
  }

  QueryBuilder<Problem, List<String>, QQueryOperations> optionsListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'optionsList');
    });
  }

  QueryBuilder<Problem, int, QQueryOperations> pointsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'points');
    });
  }

  QueryBuilder<Problem, String, QQueryOperations> problemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'problemId');
    });
  }

  QueryBuilder<Problem, String?, QQueryOperations> referencesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'references');
    });
  }

  QueryBuilder<Problem, ProblemStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<Problem, String?, QQueryOperations> subjectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subject');
    });
  }

  QueryBuilder<Problem, double, QQueryOperations> successRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'successRate');
    });
  }

  QueryBuilder<Problem, String?, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<Problem, List<String>, QQueryOperations> tagsListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tagsList');
    });
  }

  QueryBuilder<Problem, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Problem, ProblemType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<Problem, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<Problem, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Problem _$ProblemFromJson(Map<String, dynamic> json) => Problem()
  ..id = (json['id'] as num).toInt()
  ..problemId = json['problem_id'] as String
  ..title = json['title'] as String
  ..content = json['content'] as String
  ..type = $enumDecode(_$ProblemTypeEnumMap, json['type'])
  ..difficulty = $enumDecode(_$DifficultyEnumMap, json['difficulty'])
  ..status = $enumDecode(_$ProblemStatusEnumMap, json['status'])
  ..options = json['options'] as String?
  ..correctAnswer = json['correctAnswer'] as String?
  ..explanation = json['explanation'] as String?
  ..tags = json['tags'] as String?
  ..subject = json['subject'] as String?
  ..objectives = json['objectives'] as String?
  ..references = json['references'] as String?
  ..points = (json['points'] as num?)?.toInt() ?? 1
  ..estimatedTimeMinutes = (json['estimatedTimeMinutes'] as num?)?.toInt() ?? 2
  ..attemptCount = (json['attemptCount'] as num?)?.toInt() ?? 0
  ..correctCount = (json['correctCount'] as num?)?.toInt() ?? 0
  ..averageScore = (json['averageScore'] as num?)?.toDouble() ?? 0.0
  ..createdAt = DateTime.parse(json['createdAt'] as String)
  ..updatedAt = DateTime.parse(json['updatedAt'] as String)
  ..aiModel = json['aiModel'] as String?
  ..aiPrompt = json['aiPrompt'] as String?
  ..aiConfidence = (json['aiConfidence'] as num?)?.toDouble()
  ..attachments = json['attachments'] as String?
  ..isActive = json['isActive'] as bool? ?? true
  ..version = (json['version'] as num?)?.toInt() ?? 1;

Map<String, dynamic> _$ProblemToJson(Problem instance) => <String, dynamic>{
      'id': instance.id,
      'problem_id': instance.problemId,
      'title': instance.title,
      'content': instance.content,
      'type': _$ProblemTypeEnumMap[instance.type]!,
      'difficulty': _$DifficultyEnumMap[instance.difficulty]!,
      'status': _$ProblemStatusEnumMap[instance.status]!,
      'options': instance.options,
      'correctAnswer': instance.correctAnswer,
      'explanation': instance.explanation,
      'tags': instance.tags,
      'subject': instance.subject,
      'objectives': instance.objectives,
      'references': instance.references,
      'points': instance.points,
      'estimatedTimeMinutes': instance.estimatedTimeMinutes,
      'attemptCount': instance.attemptCount,
      'correctCount': instance.correctCount,
      'averageScore': instance.averageScore,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'aiModel': instance.aiModel,
      'aiPrompt': instance.aiPrompt,
      'aiConfidence': instance.aiConfidence,
      'attachments': instance.attachments,
      'isActive': instance.isActive,
      'version': instance.version,
    };

const _$ProblemTypeEnumMap = {
  ProblemType.nursing: 'nursing',
  ProblemType.essay: 'essay',
  ProblemType.simulation: 'simulation',
  ProblemType.multiple_choice: 'multiple_choice',
  ProblemType.short_answer: 'short_answer',
};

const _$DifficultyEnumMap = {
  Difficulty.easy: 'easy',
  Difficulty.medium: 'medium',
  Difficulty.hard: 'hard',
  Difficulty.expert: 'expert',
  Difficulty.beginner: 'beginner',
  Difficulty.intermediate: 'intermediate',
  Difficulty.advanced: 'advanced',
};

const _$ProblemStatusEnumMap = {
  ProblemStatus.draft: 'draft',
  ProblemStatus.review: 'review',
  ProblemStatus.published: 'published',
  ProblemStatus.active: 'active',
  ProblemStatus.archived: 'archived',
  ProblemStatus.under_review: 'under_review',
  ProblemStatus.approved: 'approved',
};
