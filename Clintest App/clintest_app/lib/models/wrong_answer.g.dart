// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wrong_answer.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWrongAnswerCollection on Isar {
  IsarCollection<WrongAnswer> get wrongAnswers => this.collection();
}

const WrongAnswerSchema = CollectionSchema(
  name: r'WrongAnswer',
  id: -8234494299943173966,
  properties: {
    r'accuracyRate': PropertySchema(
      id: 0,
      name: r'accuracyRate',
      type: IsarType.double,
    ),
    r'choices': PropertySchema(
      id: 1,
      name: r'choices',
      type: IsarType.stringList,
    ),
    r'correctAnswer': PropertySchema(
      id: 2,
      name: r'correctAnswer',
      type: IsarType.string,
    ),
    r'correctAttempts': PropertySchema(
      id: 3,
      name: r'correctAttempts',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'difficulty': PropertySchema(
      id: 5,
      name: r'difficulty',
      type: IsarType.string,
    ),
    r'explanation': PropertySchema(
      id: 6,
      name: r'explanation',
      type: IsarType.string,
    ),
    r'isResolved': PropertySchema(
      id: 7,
      name: r'isResolved',
      type: IsarType.bool,
    ),
    r'lastReviewDate': PropertySchema(
      id: 8,
      name: r'lastReviewDate',
      type: IsarType.dateTime,
    ),
    r'needsReview': PropertySchema(
      id: 9,
      name: r'needsReview',
      type: IsarType.bool,
    ),
    r'nextReviewDate': PropertySchema(
      id: 10,
      name: r'nextReviewDate',
      type: IsarType.dateTime,
    ),
    r'question': PropertySchema(
      id: 11,
      name: r'question',
      type: IsarType.string,
    ),
    r'questionCategory': PropertySchema(
      id: 12,
      name: r'questionCategory',
      type: IsarType.string,
    ),
    r'questionId': PropertySchema(
      id: 13,
      name: r'questionId',
      type: IsarType.string,
    ),
    r'questionType': PropertySchema(
      id: 14,
      name: r'questionType',
      type: IsarType.string,
    ),
    r'reviewCount': PropertySchema(
      id: 15,
      name: r'reviewCount',
      type: IsarType.long,
    ),
    r'subjectCode': PropertySchema(
      id: 16,
      name: r'subjectCode',
      type: IsarType.string,
    ),
    r'tags': PropertySchema(
      id: 17,
      name: r'tags',
      type: IsarType.stringList,
    ),
    r'totalAttempts': PropertySchema(
      id: 18,
      name: r'totalAttempts',
      type: IsarType.long,
    ),
    r'userAnswer': PropertySchema(
      id: 19,
      name: r'userAnswer',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 20,
      name: r'userId',
      type: IsarType.string,
    ),
    r'wrongDate': PropertySchema(
      id: 21,
      name: r'wrongDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _wrongAnswerEstimateSize,
  serialize: _wrongAnswerSerialize,
  deserialize: _wrongAnswerDeserialize,
  deserializeProp: _wrongAnswerDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'questionId': IndexSchema(
      id: 5032123391997384121,
      name: r'questionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'questionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'subjectCode': IndexSchema(
      id: 6870012681451542085,
      name: r'subjectCode',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'subjectCode',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
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
  embeddedSchemas: {},
  getId: _wrongAnswerGetId,
  getLinks: _wrongAnswerGetLinks,
  attach: _wrongAnswerAttach,
  version: '3.1.0+1',
);

int _wrongAnswerEstimateSize(
  WrongAnswer object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.choices.length * 3;
  {
    for (var i = 0; i < object.choices.length; i++) {
      final value = object.choices[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.correctAnswer.length * 3;
  bytesCount += 3 + object.difficulty.length * 3;
  {
    final value = object.explanation;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.question.length * 3;
  {
    final value = object.questionCategory;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.questionId.length * 3;
  bytesCount += 3 + object.questionType.length * 3;
  bytesCount += 3 + object.subjectCode.length * 3;
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.userAnswer.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _wrongAnswerSerialize(
  WrongAnswer object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.accuracyRate);
  writer.writeStringList(offsets[1], object.choices);
  writer.writeString(offsets[2], object.correctAnswer);
  writer.writeLong(offsets[3], object.correctAttempts);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeString(offsets[5], object.difficulty);
  writer.writeString(offsets[6], object.explanation);
  writer.writeBool(offsets[7], object.isResolved);
  writer.writeDateTime(offsets[8], object.lastReviewDate);
  writer.writeBool(offsets[9], object.needsReview);
  writer.writeDateTime(offsets[10], object.nextReviewDate);
  writer.writeString(offsets[11], object.question);
  writer.writeString(offsets[12], object.questionCategory);
  writer.writeString(offsets[13], object.questionId);
  writer.writeString(offsets[14], object.questionType);
  writer.writeLong(offsets[15], object.reviewCount);
  writer.writeString(offsets[16], object.subjectCode);
  writer.writeStringList(offsets[17], object.tags);
  writer.writeLong(offsets[18], object.totalAttempts);
  writer.writeString(offsets[19], object.userAnswer);
  writer.writeString(offsets[20], object.userId);
  writer.writeDateTime(offsets[21], object.wrongDate);
}

WrongAnswer _wrongAnswerDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WrongAnswer();
  object.choices = reader.readStringList(offsets[1]) ?? [];
  object.correctAnswer = reader.readString(offsets[2]);
  object.correctAttempts = reader.readLong(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.difficulty = reader.readString(offsets[5]);
  object.explanation = reader.readStringOrNull(offsets[6]);
  object.id = id;
  object.isResolved = reader.readBool(offsets[7]);
  object.lastReviewDate = reader.readDateTimeOrNull(offsets[8]);
  object.nextReviewDate = reader.readDateTimeOrNull(offsets[10]);
  object.question = reader.readString(offsets[11]);
  object.questionCategory = reader.readStringOrNull(offsets[12]);
  object.questionId = reader.readString(offsets[13]);
  object.questionType = reader.readString(offsets[14]);
  object.reviewCount = reader.readLong(offsets[15]);
  object.subjectCode = reader.readString(offsets[16]);
  object.tags = reader.readStringList(offsets[17]) ?? [];
  object.totalAttempts = reader.readLong(offsets[18]);
  object.userAnswer = reader.readString(offsets[19]);
  object.userId = reader.readString(offsets[20]);
  object.wrongDate = reader.readDateTimeOrNull(offsets[21]);
  return object;
}

P _wrongAnswerDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readStringList(offset) ?? []) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _wrongAnswerGetId(WrongAnswer object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _wrongAnswerGetLinks(WrongAnswer object) {
  return [];
}

void _wrongAnswerAttach(
    IsarCollection<dynamic> col, Id id, WrongAnswer object) {
  object.id = id;
}

extension WrongAnswerQueryWhereSort
    on QueryBuilder<WrongAnswer, WrongAnswer, QWhere> {
  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }
}

extension WrongAnswerQueryWhere
    on QueryBuilder<WrongAnswer, WrongAnswer, QWhereClause> {
  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhereClause> idBetween(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhereClause> userIdNotEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhereClause> questionIdEqualTo(
      String questionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'questionId',
        value: [questionId],
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhereClause>
      questionIdNotEqualTo(String questionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'questionId',
              lower: [],
              upper: [questionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'questionId',
              lower: [questionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'questionId',
              lower: [questionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'questionId',
              lower: [],
              upper: [questionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhereClause> subjectCodeEqualTo(
      String subjectCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subjectCode',
        value: [subjectCode],
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhereClause>
      subjectCodeNotEqualTo(String subjectCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectCode',
              lower: [],
              upper: [subjectCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectCode',
              lower: [subjectCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectCode',
              lower: [subjectCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectCode',
              lower: [],
              upper: [subjectCode],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhereClause> createdAtEqualTo(
      DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhereClause> createdAtNotEqualTo(
      DateTime createdAt) {
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhereClause>
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhereClause> createdAtLessThan(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterWhereClause> createdAtBetween(
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

extension WrongAnswerQueryFilter
    on QueryBuilder<WrongAnswer, WrongAnswer, QFilterCondition> {
  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      accuracyRateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accuracyRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      accuracyRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accuracyRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      accuracyRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accuracyRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      accuracyRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accuracyRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      choicesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'choices',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      choicesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'choices',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      choicesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'choices',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      choicesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'choices',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      choicesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'choices',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      choicesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'choices',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      choicesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'choices',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      choicesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'choices',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      choicesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'choices',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      choicesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'choices',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      choicesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'choices',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      choicesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'choices',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      choicesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'choices',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      choicesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'choices',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      choicesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'choices',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      choicesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'choices',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      correctAnswerEqualTo(
    String value, {
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      correctAnswerGreaterThan(
    String value, {
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      correctAnswerLessThan(
    String value, {
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      correctAnswerBetween(
    String lower,
    String upper, {
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      correctAnswerStartsWith(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      correctAnswerEndsWith(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      correctAnswerContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'correctAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      correctAnswerMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'correctAnswer',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      correctAnswerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctAnswer',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      correctAnswerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'correctAnswer',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      correctAttemptsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      correctAttemptsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correctAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      correctAttemptsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correctAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      correctAttemptsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correctAttempts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      difficultyEqualTo(
    String value, {
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      difficultyGreaterThan(
    String value, {
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      difficultyLessThan(
    String value, {
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      difficultyBetween(
    String lower,
    String upper, {
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      difficultyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      difficultyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'difficulty',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      difficultyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficulty',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      difficultyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'difficulty',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      explanationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'explanation',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      explanationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'explanation',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      explanationEqualTo(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      explanationGreaterThan(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      explanationLessThan(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      explanationBetween(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      explanationStartsWith(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      explanationEndsWith(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      explanationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'explanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      explanationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'explanation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      explanationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'explanation',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      explanationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'explanation',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition> idBetween(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      isResolvedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isResolved',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      lastReviewDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastReviewDate',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      lastReviewDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastReviewDate',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      lastReviewDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReviewDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      lastReviewDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReviewDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      lastReviewDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReviewDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      lastReviewDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReviewDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      needsReviewEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'needsReview',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      nextReviewDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextReviewDate',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      nextReviewDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextReviewDate',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      nextReviewDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextReviewDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      nextReviewDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextReviewDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      nextReviewDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextReviewDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      nextReviewDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextReviewDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition> questionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition> questionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'question',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition> questionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'question',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'question',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'question',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionCategoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'questionCategory',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionCategoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'questionCategory',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionCategoryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questionCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionCategoryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'questionCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionCategoryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'questionCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionCategoryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'questionCategory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionCategoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'questionCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionCategoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'questionCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionCategoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'questionCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionCategoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'questionCategory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionCategoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questionCategory',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionCategoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'questionCategory',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'questionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'questionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'questionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'questionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'questionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'questionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'questionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questionId',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'questionId',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'questionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'questionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'questionType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'questionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'questionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'questionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'questionType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questionType',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      questionTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'questionType',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      reviewCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      reviewCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      reviewCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      reviewCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reviewCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      subjectCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      subjectCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      subjectCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      subjectCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      subjectCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subjectCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      subjectCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subjectCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      subjectCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      subjectCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      subjectCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectCode',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      subjectCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectCode',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      tagsElementEqualTo(
    String value, {
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      tagsElementGreaterThan(
    String value, {
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      tagsElementLessThan(
    String value, {
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      tagsElementBetween(
    String lower,
    String upper, {
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      tagsElementStartsWith(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      tagsElementEndsWith(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      tagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      tagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition> tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      totalAttemptsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      totalAttemptsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      totalAttemptsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      totalAttemptsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalAttempts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      userAnswerEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      userAnswerGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      userAnswerLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      userAnswerBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userAnswer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      userAnswerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      userAnswerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      userAnswerContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      userAnswerMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userAnswer',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      userAnswerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userAnswer',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      userAnswerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userAnswer',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition> userIdEqualTo(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition> userIdLessThan(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition> userIdBetween(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition> userIdEndsWith(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition> userIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition> userIdMatches(
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

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      wrongDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'wrongDate',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      wrongDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'wrongDate',
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      wrongDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wrongDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      wrongDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wrongDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      wrongDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wrongDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterFilterCondition>
      wrongDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wrongDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WrongAnswerQueryObject
    on QueryBuilder<WrongAnswer, WrongAnswer, QFilterCondition> {}

extension WrongAnswerQueryLinks
    on QueryBuilder<WrongAnswer, WrongAnswer, QFilterCondition> {}

extension WrongAnswerQuerySortBy
    on QueryBuilder<WrongAnswer, WrongAnswer, QSortBy> {
  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByAccuracyRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracyRate', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      sortByAccuracyRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracyRate', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByCorrectAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswer', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      sortByCorrectAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswer', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByCorrectAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAttempts', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      sortByCorrectAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAttempts', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByExplanation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explanation', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByExplanationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explanation', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByIsResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByIsResolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByLastReviewDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReviewDate', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      sortByLastReviewDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReviewDate', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByNeedsReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsReview', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByNeedsReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsReview', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByNextReviewDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReviewDate', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      sortByNextReviewDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReviewDate', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByQuestion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByQuestionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      sortByQuestionCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionCategory', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      sortByQuestionCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionCategory', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByQuestionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionId', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByQuestionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionId', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByQuestionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionType', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      sortByQuestionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionType', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewCount', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByReviewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewCount', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortBySubjectCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortBySubjectCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByTotalAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAttempts', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      sortByTotalAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAttempts', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByUserAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAnswer', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByUserAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAnswer', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByWrongDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongDate', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> sortByWrongDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongDate', Sort.desc);
    });
  }
}

extension WrongAnswerQuerySortThenBy
    on QueryBuilder<WrongAnswer, WrongAnswer, QSortThenBy> {
  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByAccuracyRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracyRate', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      thenByAccuracyRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracyRate', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByCorrectAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswer', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      thenByCorrectAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswer', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByCorrectAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAttempts', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      thenByCorrectAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAttempts', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByExplanation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explanation', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByExplanationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explanation', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByIsResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByIsResolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByLastReviewDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReviewDate', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      thenByLastReviewDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReviewDate', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByNeedsReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsReview', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByNeedsReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsReview', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByNextReviewDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReviewDate', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      thenByNextReviewDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReviewDate', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByQuestion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByQuestionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      thenByQuestionCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionCategory', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      thenByQuestionCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionCategory', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByQuestionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionId', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByQuestionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionId', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByQuestionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionType', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      thenByQuestionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionType', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewCount', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByReviewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewCount', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenBySubjectCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenBySubjectCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByTotalAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAttempts', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy>
      thenByTotalAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAttempts', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByUserAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAnswer', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByUserAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAnswer', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByWrongDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongDate', Sort.asc);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QAfterSortBy> thenByWrongDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongDate', Sort.desc);
    });
  }
}

extension WrongAnswerQueryWhereDistinct
    on QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> {
  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByAccuracyRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accuracyRate');
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByChoices() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'choices');
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByCorrectAnswer(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctAnswer',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct>
      distinctByCorrectAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctAttempts');
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByDifficulty(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'difficulty', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByExplanation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'explanation', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByIsResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isResolved');
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByLastReviewDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReviewDate');
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByNeedsReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needsReview');
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByNextReviewDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextReviewDate');
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByQuestion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'question', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByQuestionCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'questionCategory',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByQuestionId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'questionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByQuestionType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'questionType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewCount');
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctBySubjectCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByTotalAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAttempts');
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByUserAnswer(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userAnswer', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WrongAnswer, WrongAnswer, QDistinct> distinctByWrongDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wrongDate');
    });
  }
}

extension WrongAnswerQueryProperty
    on QueryBuilder<WrongAnswer, WrongAnswer, QQueryProperty> {
  QueryBuilder<WrongAnswer, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WrongAnswer, double, QQueryOperations> accuracyRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accuracyRate');
    });
  }

  QueryBuilder<WrongAnswer, List<String>, QQueryOperations> choicesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'choices');
    });
  }

  QueryBuilder<WrongAnswer, String, QQueryOperations> correctAnswerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctAnswer');
    });
  }

  QueryBuilder<WrongAnswer, int, QQueryOperations> correctAttemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctAttempts');
    });
  }

  QueryBuilder<WrongAnswer, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<WrongAnswer, String, QQueryOperations> difficultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'difficulty');
    });
  }

  QueryBuilder<WrongAnswer, String?, QQueryOperations> explanationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'explanation');
    });
  }

  QueryBuilder<WrongAnswer, bool, QQueryOperations> isResolvedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isResolved');
    });
  }

  QueryBuilder<WrongAnswer, DateTime?, QQueryOperations>
      lastReviewDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReviewDate');
    });
  }

  QueryBuilder<WrongAnswer, bool, QQueryOperations> needsReviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needsReview');
    });
  }

  QueryBuilder<WrongAnswer, DateTime?, QQueryOperations>
      nextReviewDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextReviewDate');
    });
  }

  QueryBuilder<WrongAnswer, String, QQueryOperations> questionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'question');
    });
  }

  QueryBuilder<WrongAnswer, String?, QQueryOperations>
      questionCategoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'questionCategory');
    });
  }

  QueryBuilder<WrongAnswer, String, QQueryOperations> questionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'questionId');
    });
  }

  QueryBuilder<WrongAnswer, String, QQueryOperations> questionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'questionType');
    });
  }

  QueryBuilder<WrongAnswer, int, QQueryOperations> reviewCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewCount');
    });
  }

  QueryBuilder<WrongAnswer, String, QQueryOperations> subjectCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectCode');
    });
  }

  QueryBuilder<WrongAnswer, List<String>, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<WrongAnswer, int, QQueryOperations> totalAttemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAttempts');
    });
  }

  QueryBuilder<WrongAnswer, String, QQueryOperations> userAnswerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userAnswer');
    });
  }

  QueryBuilder<WrongAnswer, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<WrongAnswer, DateTime?, QQueryOperations> wrongDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wrongDate');
    });
  }
}
