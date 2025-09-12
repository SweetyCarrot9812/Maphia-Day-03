// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nursing_exam.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNursingExamCollection on Isar {
  IsarCollection<NursingExam> get nursingExams => this.collection();
}

const NursingExamSchema = CollectionSchema(
  name: r'NursingExam',
  id: 985807395142298288,
  properties: {
    r'answer': PropertySchema(
      id: 0,
      name: r'answer',
      type: IsarType.string,
    ),
    r'attempts': PropertySchema(
      id: 1,
      name: r'attempts',
      type: IsarType.long,
    ),
    r'choices': PropertySchema(
      id: 2,
      name: r'choices',
      type: IsarType.stringList,
    ),
    r'correctAnswer': PropertySchema(
      id: 3,
      name: r'correctAnswer',
      type: IsarType.long,
    ),
    r'correctCount': PropertySchema(
      id: 4,
      name: r'correctCount',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 5,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'difficulty': PropertySchema(
      id: 6,
      name: r'difficulty',
      type: IsarType.string,
    ),
    r'explanation': PropertySchema(
      id: 7,
      name: r'explanation',
      type: IsarType.string,
    ),
    r'lastAttempted': PropertySchema(
      id: 8,
      name: r'lastAttempted',
      type: IsarType.dateTime,
    ),
    r'question': PropertySchema(
      id: 9,
      name: r'question',
      type: IsarType.string,
    ),
    r'subject': PropertySchema(
      id: 10,
      name: r'subject',
      type: IsarType.string,
    ),
    r'subjectCode': PropertySchema(
      id: 11,
      name: r'subjectCode',
      type: IsarType.string,
    ),
    r'tags': PropertySchema(
      id: 12,
      name: r'tags',
      type: IsarType.stringList,
    ),
    r'updatedAt': PropertySchema(
      id: 13,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _nursingExamEstimateSize,
  serialize: _nursingExamSerialize,
  deserialize: _nursingExamDeserialize,
  deserializeProp: _nursingExamDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _nursingExamGetId,
  getLinks: _nursingExamGetLinks,
  attach: _nursingExamAttach,
  version: '3.1.0+1',
);

int _nursingExamEstimateSize(
  NursingExam object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.answer;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.choices.length * 3;
  {
    for (var i = 0; i < object.choices.length; i++) {
      final value = object.choices[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.difficulty.length * 3;
  bytesCount += 3 + object.explanation.length * 3;
  bytesCount += 3 + object.question.length * 3;
  bytesCount += 3 + object.subject.length * 3;
  bytesCount += 3 + object.subjectCode.length * 3;
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _nursingExamSerialize(
  NursingExam object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.answer);
  writer.writeLong(offsets[1], object.attempts);
  writer.writeStringList(offsets[2], object.choices);
  writer.writeLong(offsets[3], object.correctAnswer);
  writer.writeLong(offsets[4], object.correctCount);
  writer.writeDateTime(offsets[5], object.createdAt);
  writer.writeString(offsets[6], object.difficulty);
  writer.writeString(offsets[7], object.explanation);
  writer.writeDateTime(offsets[8], object.lastAttempted);
  writer.writeString(offsets[9], object.question);
  writer.writeString(offsets[10], object.subject);
  writer.writeString(offsets[11], object.subjectCode);
  writer.writeStringList(offsets[12], object.tags);
  writer.writeDateTime(offsets[13], object.updatedAt);
}

NursingExam _nursingExamDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NursingExam();
  object.answer = reader.readStringOrNull(offsets[0]);
  object.attempts = reader.readLong(offsets[1]);
  object.choices = reader.readStringList(offsets[2]) ?? [];
  object.correctAnswer = reader.readLong(offsets[3]);
  object.correctCount = reader.readLong(offsets[4]);
  object.createdAt = reader.readDateTime(offsets[5]);
  object.difficulty = reader.readString(offsets[6]);
  object.explanation = reader.readString(offsets[7]);
  object.id = id;
  object.lastAttempted = reader.readDateTimeOrNull(offsets[8]);
  object.question = reader.readString(offsets[9]);
  object.subject = reader.readString(offsets[10]);
  object.subjectCode = reader.readString(offsets[11]);
  object.tags = reader.readStringList(offsets[12]) ?? [];
  object.updatedAt = reader.readDateTime(offsets[13]);
  return object;
}

P _nursingExamDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringList(offset) ?? []) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _nursingExamGetId(NursingExam object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _nursingExamGetLinks(NursingExam object) {
  return [];
}

void _nursingExamAttach(
    IsarCollection<dynamic> col, Id id, NursingExam object) {
  object.id = id;
}

extension NursingExamQueryWhereSort
    on QueryBuilder<NursingExam, NursingExam, QWhere> {
  QueryBuilder<NursingExam, NursingExam, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NursingExamQueryWhere
    on QueryBuilder<NursingExam, NursingExam, QWhereClause> {
  QueryBuilder<NursingExam, NursingExam, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<NursingExam, NursingExam, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterWhereClause> idBetween(
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
}

extension NursingExamQueryFilter
    on QueryBuilder<NursingExam, NursingExam, QFilterCondition> {
  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> answerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'answer',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      answerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'answer',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> answerEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      answerGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> answerLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> answerBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'answer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      answerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> answerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> answerContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> answerMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'answer',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      answerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'answer',
        value: '',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      answerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'answer',
        value: '',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> attemptsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attempts',
        value: value,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      attemptsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'attempts',
        value: value,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      attemptsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'attempts',
        value: value,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> attemptsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'attempts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      choicesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'choices',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      choicesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'choices',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      choicesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'choices',
        value: '',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      choicesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'choices',
        value: '',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      correctAnswerEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctAnswer',
        value: value,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      correctAnswerGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correctAnswer',
        value: value,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      correctAnswerLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correctAnswer',
        value: value,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      correctAnswerBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correctAnswer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      correctCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctCount',
        value: value,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      correctCountGreaterThan(
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      correctCountLessThan(
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      correctCountBetween(
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      difficultyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      difficultyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'difficulty',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      difficultyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficulty',
        value: '',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      difficultyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'difficulty',
        value: '',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      explanationEqualTo(
    String value, {
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      explanationGreaterThan(
    String value, {
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      explanationLessThan(
    String value, {
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      explanationBetween(
    String lower,
    String upper, {
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      explanationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'explanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      explanationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'explanation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      explanationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'explanation',
        value: '',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      explanationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'explanation',
        value: '',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> idBetween(
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      lastAttemptedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastAttempted',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      lastAttemptedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastAttempted',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      lastAttemptedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastAttempted',
        value: value,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      lastAttemptedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastAttempted',
        value: value,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      lastAttemptedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastAttempted',
        value: value,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      lastAttemptedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastAttempted',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> questionEqualTo(
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> questionBetween(
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      questionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> questionMatches(
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      questionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'question',
        value: '',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      questionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'question',
        value: '',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> subjectEqualTo(
    String value, {
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      subjectGreaterThan(
    String value, {
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> subjectLessThan(
    String value, {
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> subjectBetween(
    String lower,
    String upper, {
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      subjectStartsWith(
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> subjectEndsWith(
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> subjectContains(
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> subjectMatches(
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      subjectIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subject',
        value: '',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      subjectIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subject',
        value: '',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      subjectCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      subjectCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      subjectCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectCode',
        value: '',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      subjectCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectCode',
        value: '',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      tagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      tagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition> tagsIsEmpty() {
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      updatedAtGreaterThan(
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      updatedAtLessThan(
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

  QueryBuilder<NursingExam, NursingExam, QAfterFilterCondition>
      updatedAtBetween(
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
}

extension NursingExamQueryObject
    on QueryBuilder<NursingExam, NursingExam, QFilterCondition> {}

extension NursingExamQueryLinks
    on QueryBuilder<NursingExam, NursingExam, QFilterCondition> {}

extension NursingExamQuerySortBy
    on QueryBuilder<NursingExam, NursingExam, QSortBy> {
  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortByAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answer', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortByAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answer', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortByAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortByCorrectAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswer', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy>
      sortByCorrectAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswer', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy>
      sortByCorrectCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortByExplanation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explanation', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortByExplanationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explanation', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortByLastAttempted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAttempted', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy>
      sortByLastAttemptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAttempted', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortByQuestion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortByQuestionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortBySubjectCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortBySubjectCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension NursingExamQuerySortThenBy
    on QueryBuilder<NursingExam, NursingExam, QSortThenBy> {
  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answer', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answer', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByCorrectAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswer', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy>
      thenByCorrectAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswer', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy>
      thenByCorrectCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByExplanation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explanation', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByExplanationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explanation', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByLastAttempted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAttempted', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy>
      thenByLastAttemptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAttempted', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByQuestion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByQuestionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenBySubjectCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenBySubjectCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.desc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension NursingExamQueryWhereDistinct
    on QueryBuilder<NursingExam, NursingExam, QDistinct> {
  QueryBuilder<NursingExam, NursingExam, QDistinct> distinctByAnswer(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'answer', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QDistinct> distinctByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attempts');
    });
  }

  QueryBuilder<NursingExam, NursingExam, QDistinct> distinctByChoices() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'choices');
    });
  }

  QueryBuilder<NursingExam, NursingExam, QDistinct> distinctByCorrectAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctAnswer');
    });
  }

  QueryBuilder<NursingExam, NursingExam, QDistinct> distinctByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctCount');
    });
  }

  QueryBuilder<NursingExam, NursingExam, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<NursingExam, NursingExam, QDistinct> distinctByDifficulty(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'difficulty', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QDistinct> distinctByExplanation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'explanation', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QDistinct> distinctByLastAttempted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAttempted');
    });
  }

  QueryBuilder<NursingExam, NursingExam, QDistinct> distinctByQuestion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'question', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QDistinct> distinctBySubject(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subject', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QDistinct> distinctBySubjectCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NursingExam, NursingExam, QDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<NursingExam, NursingExam, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension NursingExamQueryProperty
    on QueryBuilder<NursingExam, NursingExam, QQueryProperty> {
  QueryBuilder<NursingExam, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NursingExam, String?, QQueryOperations> answerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'answer');
    });
  }

  QueryBuilder<NursingExam, int, QQueryOperations> attemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attempts');
    });
  }

  QueryBuilder<NursingExam, List<String>, QQueryOperations> choicesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'choices');
    });
  }

  QueryBuilder<NursingExam, int, QQueryOperations> correctAnswerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctAnswer');
    });
  }

  QueryBuilder<NursingExam, int, QQueryOperations> correctCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctCount');
    });
  }

  QueryBuilder<NursingExam, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<NursingExam, String, QQueryOperations> difficultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'difficulty');
    });
  }

  QueryBuilder<NursingExam, String, QQueryOperations> explanationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'explanation');
    });
  }

  QueryBuilder<NursingExam, DateTime?, QQueryOperations>
      lastAttemptedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAttempted');
    });
  }

  QueryBuilder<NursingExam, String, QQueryOperations> questionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'question');
    });
  }

  QueryBuilder<NursingExam, String, QQueryOperations> subjectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subject');
    });
  }

  QueryBuilder<NursingExam, String, QQueryOperations> subjectCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectCode');
    });
  }

  QueryBuilder<NursingExam, List<String>, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<NursingExam, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
