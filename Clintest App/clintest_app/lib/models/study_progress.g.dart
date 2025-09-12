// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_progress.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStudyProgressCollection on Isar {
  IsarCollection<StudyProgress> get studyProgress => this.collection();
}

const StudyProgressSchema = CollectionSchema(
  name: r'StudyProgress',
  id: 338383220608238519,
  properties: {
    r'accuracyRate': PropertySchema(
      id: 0,
      name: r'accuracyRate',
      type: IsarType.double,
    ),
    r'attemptedQuestions': PropertySchema(
      id: 1,
      name: r'attemptedQuestions',
      type: IsarType.long,
    ),
    r'correctAnswers': PropertySchema(
      id: 2,
      name: r'correctAnswers',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'formattedStudyTime': PropertySchema(
      id: 4,
      name: r'formattedStudyTime',
      type: IsarType.string,
    ),
    r'lastStudyDate': PropertySchema(
      id: 5,
      name: r'lastStudyDate',
      type: IsarType.dateTime,
    ),
    r'progressRate': PropertySchema(
      id: 6,
      name: r'progressRate',
      type: IsarType.double,
    ),
    r'streakDays': PropertySchema(
      id: 7,
      name: r'streakDays',
      type: IsarType.long,
    ),
    r'studyTimeSeconds': PropertySchema(
      id: 8,
      name: r'studyTimeSeconds',
      type: IsarType.long,
    ),
    r'subjectCode': PropertySchema(
      id: 9,
      name: r'subjectCode',
      type: IsarType.string,
    ),
    r'totalQuestions': PropertySchema(
      id: 10,
      name: r'totalQuestions',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 11,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 12,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _studyProgressEstimateSize,
  serialize: _studyProgressSerialize,
  deserialize: _studyProgressDeserialize,
  deserializeProp: _studyProgressDeserializeProp,
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _studyProgressGetId,
  getLinks: _studyProgressGetLinks,
  attach: _studyProgressAttach,
  version: '3.1.0+1',
);

int _studyProgressEstimateSize(
  StudyProgress object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.formattedStudyTime.length * 3;
  bytesCount += 3 + object.subjectCode.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _studyProgressSerialize(
  StudyProgress object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.accuracyRate);
  writer.writeLong(offsets[1], object.attemptedQuestions);
  writer.writeLong(offsets[2], object.correctAnswers);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeString(offsets[4], object.formattedStudyTime);
  writer.writeDateTime(offsets[5], object.lastStudyDate);
  writer.writeDouble(offsets[6], object.progressRate);
  writer.writeLong(offsets[7], object.streakDays);
  writer.writeLong(offsets[8], object.studyTimeSeconds);
  writer.writeString(offsets[9], object.subjectCode);
  writer.writeLong(offsets[10], object.totalQuestions);
  writer.writeDateTime(offsets[11], object.updatedAt);
  writer.writeString(offsets[12], object.userId);
}

StudyProgress _studyProgressDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StudyProgress();
  object.accuracyRate = reader.readDouble(offsets[0]);
  object.attemptedQuestions = reader.readLong(offsets[1]);
  object.correctAnswers = reader.readLong(offsets[2]);
  object.createdAt = reader.readDateTimeOrNull(offsets[3]);
  object.id = id;
  object.lastStudyDate = reader.readDateTimeOrNull(offsets[5]);
  object.streakDays = reader.readLong(offsets[7]);
  object.studyTimeSeconds = reader.readLong(offsets[8]);
  object.subjectCode = reader.readString(offsets[9]);
  object.totalQuestions = reader.readLong(offsets[10]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[11]);
  object.userId = reader.readString(offsets[12]);
  return object;
}

P _studyProgressDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _studyProgressGetId(StudyProgress object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _studyProgressGetLinks(StudyProgress object) {
  return [];
}

void _studyProgressAttach(
    IsarCollection<dynamic> col, Id id, StudyProgress object) {
  object.id = id;
}

extension StudyProgressQueryWhereSort
    on QueryBuilder<StudyProgress, StudyProgress, QWhere> {
  QueryBuilder<StudyProgress, StudyProgress, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StudyProgressQueryWhere
    on QueryBuilder<StudyProgress, StudyProgress, QWhereClause> {
  QueryBuilder<StudyProgress, StudyProgress, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterWhereClause> idBetween(
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterWhereClause>
      subjectCodeEqualTo(String subjectCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subjectCode',
        value: [subjectCode],
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterWhereClause>
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
}

extension StudyProgressQueryFilter
    on QueryBuilder<StudyProgress, StudyProgress, QFilterCondition> {
  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      attemptedQuestionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attemptedQuestions',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      attemptedQuestionsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'attemptedQuestions',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      attemptedQuestionsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'attemptedQuestions',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      attemptedQuestionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'attemptedQuestions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      correctAnswersEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctAnswers',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime? value, {
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      createdAtLessThan(
    DateTime? value, {
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      formattedStudyTimeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedStudyTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      formattedStudyTimeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'formattedStudyTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      formattedStudyTimeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'formattedStudyTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      formattedStudyTimeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'formattedStudyTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      formattedStudyTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'formattedStudyTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      formattedStudyTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'formattedStudyTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      formattedStudyTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'formattedStudyTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      formattedStudyTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'formattedStudyTime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      formattedStudyTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedStudyTime',
        value: '',
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      formattedStudyTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'formattedStudyTime',
        value: '',
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition> idBetween(
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      lastStudyDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastStudyDate',
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      lastStudyDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastStudyDate',
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      lastStudyDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastStudyDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      lastStudyDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastStudyDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      lastStudyDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastStudyDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      lastStudyDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastStudyDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      progressRateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progressRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      progressRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progressRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      progressRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progressRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      progressRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progressRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      streakDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      streakDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      streakDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      streakDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streakDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      studyTimeSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studyTimeSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      studyTimeSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'studyTimeSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      studyTimeSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'studyTimeSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      studyTimeSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'studyTimeSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      subjectCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      subjectCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      subjectCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectCode',
        value: '',
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      subjectCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectCode',
        value: '',
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      totalQuestionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalQuestions',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      totalQuestionsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalQuestions',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      totalQuestionsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalQuestions',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      totalQuestionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalQuestions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      userIdEqualTo(
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      userIdBetween(
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
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

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension StudyProgressQueryObject
    on QueryBuilder<StudyProgress, StudyProgress, QFilterCondition> {}

extension StudyProgressQueryLinks
    on QueryBuilder<StudyProgress, StudyProgress, QFilterCondition> {}

extension StudyProgressQuerySortBy
    on QueryBuilder<StudyProgress, StudyProgress, QSortBy> {
  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByAccuracyRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracyRate', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByAccuracyRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracyRate', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByAttemptedQuestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptedQuestions', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByAttemptedQuestionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptedQuestions', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByCorrectAnswers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswers', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByCorrectAnswersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswers', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByFormattedStudyTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedStudyTime', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByFormattedStudyTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedStudyTime', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByLastStudyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStudyDate', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByLastStudyDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStudyDate', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByProgressRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressRate', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByProgressRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressRate', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy> sortByStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDays', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDays', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByStudyTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByStudyTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyTimeSeconds', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy> sortBySubjectCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortBySubjectCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByTotalQuestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestions', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByTotalQuestionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestions', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension StudyProgressQuerySortThenBy
    on QueryBuilder<StudyProgress, StudyProgress, QSortThenBy> {
  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByAccuracyRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracyRate', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByAccuracyRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracyRate', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByAttemptedQuestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptedQuestions', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByAttemptedQuestionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptedQuestions', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByCorrectAnswers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswers', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByCorrectAnswersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswers', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByFormattedStudyTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedStudyTime', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByFormattedStudyTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedStudyTime', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByLastStudyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStudyDate', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByLastStudyDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStudyDate', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByProgressRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressRate', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByProgressRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressRate', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy> thenByStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDays', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDays', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByStudyTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByStudyTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyTimeSeconds', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy> thenBySubjectCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenBySubjectCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByTotalQuestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestions', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByTotalQuestionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestions', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension StudyProgressQueryWhereDistinct
    on QueryBuilder<StudyProgress, StudyProgress, QDistinct> {
  QueryBuilder<StudyProgress, StudyProgress, QDistinct>
      distinctByAccuracyRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accuracyRate');
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QDistinct>
      distinctByAttemptedQuestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attemptedQuestions');
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QDistinct>
      distinctByCorrectAnswers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctAnswers');
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QDistinct>
      distinctByFormattedStudyTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'formattedStudyTime',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QDistinct>
      distinctByLastStudyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastStudyDate');
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QDistinct>
      distinctByProgressRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progressRate');
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QDistinct> distinctByStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streakDays');
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QDistinct>
      distinctByStudyTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studyTimeSeconds');
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QDistinct> distinctBySubjectCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QDistinct>
      distinctByTotalQuestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalQuestions');
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<StudyProgress, StudyProgress, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension StudyProgressQueryProperty
    on QueryBuilder<StudyProgress, StudyProgress, QQueryProperty> {
  QueryBuilder<StudyProgress, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StudyProgress, double, QQueryOperations> accuracyRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accuracyRate');
    });
  }

  QueryBuilder<StudyProgress, int, QQueryOperations>
      attemptedQuestionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attemptedQuestions');
    });
  }

  QueryBuilder<StudyProgress, int, QQueryOperations> correctAnswersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctAnswers');
    });
  }

  QueryBuilder<StudyProgress, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<StudyProgress, String, QQueryOperations>
      formattedStudyTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formattedStudyTime');
    });
  }

  QueryBuilder<StudyProgress, DateTime?, QQueryOperations>
      lastStudyDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastStudyDate');
    });
  }

  QueryBuilder<StudyProgress, double, QQueryOperations> progressRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progressRate');
    });
  }

  QueryBuilder<StudyProgress, int, QQueryOperations> streakDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streakDays');
    });
  }

  QueryBuilder<StudyProgress, int, QQueryOperations>
      studyTimeSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studyTimeSeconds');
    });
  }

  QueryBuilder<StudyProgress, String, QQueryOperations> subjectCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectCode');
    });
  }

  QueryBuilder<StudyProgress, int, QQueryOperations> totalQuestionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalQuestions');
    });
  }

  QueryBuilder<StudyProgress, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<StudyProgress, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
