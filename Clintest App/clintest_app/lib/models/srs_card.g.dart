// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'srs_card.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSRSCardCollection on Isar {
  IsarCollection<SRSCard> get sRSCards => this.collection();
}

const SRSCardSchema = CollectionSchema(
  name: r'SRSCard',
  id: 6304684104168042909,
  properties: {
    r'aiDifficultyScore': PropertySchema(
      id: 0,
      name: r'aiDifficultyScore',
      type: IsarType.double,
    ),
    r'clinicalContext': PropertySchema(
      id: 1,
      name: r'clinicalContext',
      type: IsarType.string,
    ),
    r'consecutiveCorrect': PropertySchema(
      id: 2,
      name: r'consecutiveCorrect',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'daysOverdue': PropertySchema(
      id: 4,
      name: r'daysOverdue',
      type: IsarType.long,
    ),
    r'daysUntilDue': PropertySchema(
      id: 5,
      name: r'daysUntilDue',
      type: IsarType.long,
    ),
    r'dueDate': PropertySchema(
      id: 6,
      name: r'dueDate',
      type: IsarType.dateTime,
    ),
    r'easeFactor': PropertySchema(
      id: 7,
      name: r'easeFactor',
      type: IsarType.double,
    ),
    r'interval': PropertySchema(
      id: 8,
      name: r'interval',
      type: IsarType.long,
    ),
    r'isOverdue': PropertySchema(
      id: 9,
      name: r'isOverdue',
      type: IsarType.bool,
    ),
    r'itemId': PropertySchema(
      id: 10,
      name: r'itemId',
      type: IsarType.string,
    ),
    r'itemType': PropertySchema(
      id: 11,
      name: r'itemType',
      type: IsarType.string,
    ),
    r'lastCorrectDate': PropertySchema(
      id: 12,
      name: r'lastCorrectDate',
      type: IsarType.dateTime,
    ),
    r'lastPerformance': PropertySchema(
      id: 13,
      name: r'lastPerformance',
      type: IsarType.string,
    ),
    r'lastResponseTimeMs': PropertySchema(
      id: 14,
      name: r'lastResponseTimeMs',
      type: IsarType.long,
    ),
    r'lastWrongDate': PropertySchema(
      id: 15,
      name: r'lastWrongDate',
      type: IsarType.dateTime,
    ),
    r'maturityLevel': PropertySchema(
      id: 16,
      name: r'maturityLevel',
      type: IsarType.double,
    ),
    r'medicalCategory': PropertySchema(
      id: 17,
      name: r'medicalCategory',
      type: IsarType.string,
    ),
    r'memoryStrength': PropertySchema(
      id: 18,
      name: r'memoryStrength',
      type: IsarType.double,
    ),
    r'personalDifficultyRating': PropertySchema(
      id: 19,
      name: r'personalDifficultyRating',
      type: IsarType.double,
    ),
    r'priority': PropertySchema(
      id: 20,
      name: r'priority',
      type: IsarType.long,
    ),
    r'relatedConcepts': PropertySchema(
      id: 21,
      name: r'relatedConcepts',
      type: IsarType.stringList,
    ),
    r'streakCount': PropertySchema(
      id: 22,
      name: r'streakCount',
      type: IsarType.long,
    ),
    r'totalReviews': PropertySchema(
      id: 23,
      name: r'totalReviews',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 24,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'urgencyScore': PropertySchema(
      id: 25,
      name: r'urgencyScore',
      type: IsarType.double,
    ),
    r'userId': PropertySchema(
      id: 26,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _sRSCardEstimateSize,
  serialize: _sRSCardSerialize,
  deserialize: _sRSCardDeserialize,
  deserializeProp: _sRSCardDeserializeProp,
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
    r'itemId': IndexSchema(
      id: -5342806140158601489,
      name: r'itemId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'itemId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _sRSCardGetId,
  getLinks: _sRSCardGetLinks,
  attach: _sRSCardAttach,
  version: '3.1.0+1',
);

int _sRSCardEstimateSize(
  SRSCard object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.clinicalContext;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.itemId.length * 3;
  bytesCount += 3 + object.itemType.length * 3;
  {
    final value = object.lastPerformance;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.medicalCategory;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.relatedConcepts.length * 3;
  {
    for (var i = 0; i < object.relatedConcepts.length; i++) {
      final value = object.relatedConcepts[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _sRSCardSerialize(
  SRSCard object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.aiDifficultyScore);
  writer.writeString(offsets[1], object.clinicalContext);
  writer.writeLong(offsets[2], object.consecutiveCorrect);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeLong(offsets[4], object.daysOverdue);
  writer.writeLong(offsets[5], object.daysUntilDue);
  writer.writeDateTime(offsets[6], object.dueDate);
  writer.writeDouble(offsets[7], object.easeFactor);
  writer.writeLong(offsets[8], object.interval);
  writer.writeBool(offsets[9], object.isOverdue);
  writer.writeString(offsets[10], object.itemId);
  writer.writeString(offsets[11], object.itemType);
  writer.writeDateTime(offsets[12], object.lastCorrectDate);
  writer.writeString(offsets[13], object.lastPerformance);
  writer.writeLong(offsets[14], object.lastResponseTimeMs);
  writer.writeDateTime(offsets[15], object.lastWrongDate);
  writer.writeDouble(offsets[16], object.maturityLevel);
  writer.writeString(offsets[17], object.medicalCategory);
  writer.writeDouble(offsets[18], object.memoryStrength);
  writer.writeDouble(offsets[19], object.personalDifficultyRating);
  writer.writeLong(offsets[20], object.priority);
  writer.writeStringList(offsets[21], object.relatedConcepts);
  writer.writeLong(offsets[22], object.streakCount);
  writer.writeLong(offsets[23], object.totalReviews);
  writer.writeDateTime(offsets[24], object.updatedAt);
  writer.writeDouble(offsets[25], object.urgencyScore);
  writer.writeString(offsets[26], object.userId);
}

SRSCard _sRSCardDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SRSCard();
  object.aiDifficultyScore = reader.readDouble(offsets[0]);
  object.clinicalContext = reader.readStringOrNull(offsets[1]);
  object.consecutiveCorrect = reader.readLong(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.dueDate = reader.readDateTime(offsets[6]);
  object.easeFactor = reader.readDouble(offsets[7]);
  object.id = id;
  object.interval = reader.readLong(offsets[8]);
  object.isOverdue = reader.readBool(offsets[9]);
  object.itemId = reader.readString(offsets[10]);
  object.itemType = reader.readString(offsets[11]);
  object.lastCorrectDate = reader.readDateTimeOrNull(offsets[12]);
  object.lastPerformance = reader.readStringOrNull(offsets[13]);
  object.lastResponseTimeMs = reader.readLongOrNull(offsets[14]);
  object.lastWrongDate = reader.readDateTimeOrNull(offsets[15]);
  object.medicalCategory = reader.readStringOrNull(offsets[17]);
  object.personalDifficultyRating = reader.readDouble(offsets[19]);
  object.priority = reader.readLong(offsets[20]);
  object.relatedConcepts = reader.readStringList(offsets[21]) ?? [];
  object.streakCount = reader.readLong(offsets[22]);
  object.totalReviews = reader.readLong(offsets[23]);
  object.updatedAt = reader.readDateTime(offsets[24]);
  object.userId = reader.readString(offsets[26]);
  return object;
}

P _sRSCardDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readLongOrNull(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readDouble(offset)) as P;
    case 19:
      return (reader.readDouble(offset)) as P;
    case 20:
      return (reader.readLong(offset)) as P;
    case 21:
      return (reader.readStringList(offset) ?? []) as P;
    case 22:
      return (reader.readLong(offset)) as P;
    case 23:
      return (reader.readLong(offset)) as P;
    case 24:
      return (reader.readDateTime(offset)) as P;
    case 25:
      return (reader.readDouble(offset)) as P;
    case 26:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sRSCardGetId(SRSCard object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sRSCardGetLinks(SRSCard object) {
  return [];
}

void _sRSCardAttach(IsarCollection<dynamic> col, Id id, SRSCard object) {
  object.id = id;
}

extension SRSCardQueryWhereSort on QueryBuilder<SRSCard, SRSCard, QWhere> {
  QueryBuilder<SRSCard, SRSCard, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SRSCardQueryWhere on QueryBuilder<SRSCard, SRSCard, QWhereClause> {
  QueryBuilder<SRSCard, SRSCard, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<SRSCard, SRSCard, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterWhereClause> idBetween(
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

  QueryBuilder<SRSCard, SRSCard, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterWhereClause> userIdNotEqualTo(
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

  QueryBuilder<SRSCard, SRSCard, QAfterWhereClause> itemIdEqualTo(
      String itemId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'itemId',
        value: [itemId],
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterWhereClause> itemIdNotEqualTo(
      String itemId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [],
              upper: [itemId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [itemId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [itemId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [],
              upper: [itemId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SRSCardQueryFilter
    on QueryBuilder<SRSCard, SRSCard, QFilterCondition> {
  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      aiDifficultyScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiDifficultyScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      aiDifficultyScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiDifficultyScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      aiDifficultyScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiDifficultyScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      aiDifficultyScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiDifficultyScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      clinicalContextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clinicalContext',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      clinicalContextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clinicalContext',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> clinicalContextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clinicalContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      clinicalContextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clinicalContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> clinicalContextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clinicalContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> clinicalContextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clinicalContext',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      clinicalContextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'clinicalContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> clinicalContextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'clinicalContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> clinicalContextContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clinicalContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> clinicalContextMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clinicalContext',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      clinicalContextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clinicalContext',
        value: '',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      clinicalContextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clinicalContext',
        value: '',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      consecutiveCorrectEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consecutiveCorrect',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      consecutiveCorrectGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'consecutiveCorrect',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      consecutiveCorrectLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'consecutiveCorrect',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      consecutiveCorrectBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'consecutiveCorrect',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> daysOverdueEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'daysOverdue',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> daysOverdueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'daysOverdue',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> daysOverdueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'daysOverdue',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> daysOverdueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'daysOverdue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> daysUntilDueEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'daysUntilDue',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> daysUntilDueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'daysUntilDue',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> daysUntilDueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'daysUntilDue',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> daysUntilDueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'daysUntilDue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> dueDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> dueDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> dueDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> dueDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dueDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> easeFactorEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'easeFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> easeFactorGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'easeFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> easeFactorLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'easeFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> easeFactorBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'easeFactor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> intervalEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'interval',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> intervalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'interval',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> intervalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'interval',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> intervalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'interval',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> isOverdueEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isOverdue',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemId',
        value: '',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemId',
        value: '',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemType',
        value: '',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> itemTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemType',
        value: '',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      lastCorrectDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCorrectDate',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      lastCorrectDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCorrectDate',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> lastCorrectDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCorrectDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      lastCorrectDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCorrectDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> lastCorrectDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCorrectDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> lastCorrectDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCorrectDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      lastPerformanceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPerformance',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      lastPerformanceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPerformance',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> lastPerformanceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPerformance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      lastPerformanceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPerformance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> lastPerformanceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPerformance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> lastPerformanceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPerformance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      lastPerformanceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastPerformance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> lastPerformanceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastPerformance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> lastPerformanceContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastPerformance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> lastPerformanceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastPerformance',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      lastPerformanceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPerformance',
        value: '',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      lastPerformanceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastPerformance',
        value: '',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      lastResponseTimeMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastResponseTimeMs',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      lastResponseTimeMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastResponseTimeMs',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      lastResponseTimeMsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastResponseTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      lastResponseTimeMsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastResponseTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      lastResponseTimeMsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastResponseTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      lastResponseTimeMsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastResponseTimeMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> lastWrongDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastWrongDate',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      lastWrongDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastWrongDate',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> lastWrongDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastWrongDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      lastWrongDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastWrongDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> lastWrongDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastWrongDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> lastWrongDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastWrongDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> maturityLevelEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maturityLevel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      maturityLevelGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maturityLevel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> maturityLevelLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maturityLevel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> maturityLevelBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maturityLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      medicalCategoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'medicalCategory',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      medicalCategoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'medicalCategory',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> medicalCategoryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medicalCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      medicalCategoryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'medicalCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> medicalCategoryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'medicalCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> medicalCategoryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'medicalCategory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      medicalCategoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'medicalCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> medicalCategoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'medicalCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> medicalCategoryContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'medicalCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> medicalCategoryMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'medicalCategory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      medicalCategoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medicalCategory',
        value: '',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      medicalCategoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'medicalCategory',
        value: '',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> memoryStrengthEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memoryStrength',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      memoryStrengthGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'memoryStrength',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> memoryStrengthLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'memoryStrength',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> memoryStrengthBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'memoryStrength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      personalDifficultyRatingEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personalDifficultyRating',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      personalDifficultyRatingGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'personalDifficultyRating',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      personalDifficultyRatingLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'personalDifficultyRating',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      personalDifficultyRatingBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'personalDifficultyRating',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> priorityEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> priorityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> priorityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> priorityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      relatedConceptsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedConcepts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      relatedConceptsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relatedConcepts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      relatedConceptsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relatedConcepts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      relatedConceptsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relatedConcepts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      relatedConceptsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relatedConcepts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      relatedConceptsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relatedConcepts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      relatedConceptsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relatedConcepts',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      relatedConceptsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relatedConcepts',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      relatedConceptsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedConcepts',
        value: '',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      relatedConceptsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relatedConcepts',
        value: '',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      relatedConceptsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relatedConcepts',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      relatedConceptsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relatedConcepts',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      relatedConceptsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relatedConcepts',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      relatedConceptsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relatedConcepts',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      relatedConceptsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relatedConcepts',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition>
      relatedConceptsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relatedConcepts',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> streakCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streakCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> streakCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streakCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> streakCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streakCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> streakCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streakCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> totalReviewsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalReviews',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> totalReviewsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalReviews',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> totalReviewsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalReviews',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> totalReviewsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalReviews',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> updatedAtGreaterThan(
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

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> updatedAtBetween(
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

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> urgencyScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'urgencyScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> urgencyScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'urgencyScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> urgencyScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'urgencyScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> urgencyScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'urgencyScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> userIdEqualTo(
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

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> userIdGreaterThan(
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

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> userIdLessThan(
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

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> userIdBetween(
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

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> userIdStartsWith(
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

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> userIdEndsWith(
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

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> userIdContains(
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

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> userIdMatches(
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

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension SRSCardQueryObject
    on QueryBuilder<SRSCard, SRSCard, QFilterCondition> {}

extension SRSCardQueryLinks
    on QueryBuilder<SRSCard, SRSCard, QFilterCondition> {}

extension SRSCardQuerySortBy on QueryBuilder<SRSCard, SRSCard, QSortBy> {
  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByAiDifficultyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiDifficultyScore', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByAiDifficultyScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiDifficultyScore', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByClinicalContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clinicalContext', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByClinicalContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clinicalContext', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByConsecutiveCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveCorrect', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByConsecutiveCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveCorrect', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByDaysOverdue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysOverdue', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByDaysOverdueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysOverdue', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByDaysUntilDue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysUntilDue', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByDaysUntilDueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysUntilDue', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByEaseFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easeFactor', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByEaseFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easeFactor', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interval', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByIntervalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interval', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByIsOverdue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOverdue', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByIsOverdueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOverdue', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByItemType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemType', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByItemTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemType', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByLastCorrectDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCorrectDate', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByLastCorrectDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCorrectDate', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByLastPerformance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPerformance', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByLastPerformanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPerformance', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByLastResponseTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastResponseTimeMs', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByLastResponseTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastResponseTimeMs', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByLastWrongDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWrongDate', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByLastWrongDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWrongDate', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByMaturityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturityLevel', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByMaturityLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturityLevel', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByMedicalCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicalCategory', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByMedicalCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicalCategory', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByMemoryStrength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memoryStrength', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByMemoryStrengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memoryStrength', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy>
      sortByPersonalDifficultyRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personalDifficultyRating', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy>
      sortByPersonalDifficultyRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personalDifficultyRating', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByStreakCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakCount', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByStreakCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakCount', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByTotalReviews() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReviews', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByTotalReviewsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReviews', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByUrgencyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urgencyScore', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByUrgencyScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urgencyScore', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension SRSCardQuerySortThenBy
    on QueryBuilder<SRSCard, SRSCard, QSortThenBy> {
  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByAiDifficultyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiDifficultyScore', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByAiDifficultyScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiDifficultyScore', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByClinicalContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clinicalContext', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByClinicalContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clinicalContext', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByConsecutiveCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveCorrect', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByConsecutiveCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveCorrect', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByDaysOverdue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysOverdue', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByDaysOverdueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysOverdue', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByDaysUntilDue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysUntilDue', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByDaysUntilDueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysUntilDue', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByEaseFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easeFactor', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByEaseFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easeFactor', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interval', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByIntervalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interval', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByIsOverdue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOverdue', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByIsOverdueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOverdue', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByItemType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemType', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByItemTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemType', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByLastCorrectDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCorrectDate', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByLastCorrectDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCorrectDate', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByLastPerformance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPerformance', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByLastPerformanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPerformance', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByLastResponseTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastResponseTimeMs', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByLastResponseTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastResponseTimeMs', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByLastWrongDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWrongDate', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByLastWrongDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWrongDate', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByMaturityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturityLevel', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByMaturityLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturityLevel', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByMedicalCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicalCategory', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByMedicalCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicalCategory', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByMemoryStrength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memoryStrength', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByMemoryStrengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memoryStrength', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy>
      thenByPersonalDifficultyRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personalDifficultyRating', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy>
      thenByPersonalDifficultyRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personalDifficultyRating', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByStreakCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakCount', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByStreakCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakCount', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByTotalReviews() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReviews', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByTotalReviewsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReviews', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByUrgencyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urgencyScore', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByUrgencyScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urgencyScore', Sort.desc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension SRSCardQueryWhereDistinct
    on QueryBuilder<SRSCard, SRSCard, QDistinct> {
  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByAiDifficultyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiDifficultyScore');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByClinicalContext(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clinicalContext',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByConsecutiveCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consecutiveCorrect');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByDaysOverdue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'daysOverdue');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByDaysUntilDue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'daysUntilDue');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueDate');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByEaseFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'easeFactor');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'interval');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByIsOverdue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isOverdue');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByItemId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByItemType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByLastCorrectDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCorrectDate');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByLastPerformance(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPerformance',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByLastResponseTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastResponseTimeMs');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByLastWrongDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastWrongDate');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByMaturityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maturityLevel');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByMedicalCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'medicalCategory',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByMemoryStrength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'memoryStrength');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct>
      distinctByPersonalDifficultyRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'personalDifficultyRating');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByRelatedConcepts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relatedConcepts');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByStreakCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streakCount');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByTotalReviews() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalReviews');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByUrgencyScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'urgencyScore');
    });
  }

  QueryBuilder<SRSCard, SRSCard, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension SRSCardQueryProperty
    on QueryBuilder<SRSCard, SRSCard, QQueryProperty> {
  QueryBuilder<SRSCard, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SRSCard, double, QQueryOperations> aiDifficultyScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiDifficultyScore');
    });
  }

  QueryBuilder<SRSCard, String?, QQueryOperations> clinicalContextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clinicalContext');
    });
  }

  QueryBuilder<SRSCard, int, QQueryOperations> consecutiveCorrectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consecutiveCorrect');
    });
  }

  QueryBuilder<SRSCard, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SRSCard, int, QQueryOperations> daysOverdueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'daysOverdue');
    });
  }

  QueryBuilder<SRSCard, int, QQueryOperations> daysUntilDueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'daysUntilDue');
    });
  }

  QueryBuilder<SRSCard, DateTime, QQueryOperations> dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueDate');
    });
  }

  QueryBuilder<SRSCard, double, QQueryOperations> easeFactorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'easeFactor');
    });
  }

  QueryBuilder<SRSCard, int, QQueryOperations> intervalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'interval');
    });
  }

  QueryBuilder<SRSCard, bool, QQueryOperations> isOverdueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isOverdue');
    });
  }

  QueryBuilder<SRSCard, String, QQueryOperations> itemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemId');
    });
  }

  QueryBuilder<SRSCard, String, QQueryOperations> itemTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemType');
    });
  }

  QueryBuilder<SRSCard, DateTime?, QQueryOperations> lastCorrectDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCorrectDate');
    });
  }

  QueryBuilder<SRSCard, String?, QQueryOperations> lastPerformanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPerformance');
    });
  }

  QueryBuilder<SRSCard, int?, QQueryOperations> lastResponseTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastResponseTimeMs');
    });
  }

  QueryBuilder<SRSCard, DateTime?, QQueryOperations> lastWrongDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastWrongDate');
    });
  }

  QueryBuilder<SRSCard, double, QQueryOperations> maturityLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maturityLevel');
    });
  }

  QueryBuilder<SRSCard, String?, QQueryOperations> medicalCategoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'medicalCategory');
    });
  }

  QueryBuilder<SRSCard, double, QQueryOperations> memoryStrengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'memoryStrength');
    });
  }

  QueryBuilder<SRSCard, double, QQueryOperations>
      personalDifficultyRatingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'personalDifficultyRating');
    });
  }

  QueryBuilder<SRSCard, int, QQueryOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<SRSCard, List<String>, QQueryOperations>
      relatedConceptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relatedConcepts');
    });
  }

  QueryBuilder<SRSCard, int, QQueryOperations> streakCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streakCount');
    });
  }

  QueryBuilder<SRSCard, int, QQueryOperations> totalReviewsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalReviews');
    });
  }

  QueryBuilder<SRSCard, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<SRSCard, double, QQueryOperations> urgencyScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'urgencyScore');
    });
  }

  QueryBuilder<SRSCard, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
