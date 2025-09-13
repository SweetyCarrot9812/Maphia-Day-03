// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_daily.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUsageDailyCollection on Isar {
  IsarCollection<UsageDaily> get usageDailys => this.collection();
}

const UsageDailySchema = CollectionSchema(
  name: r'UsageDaily',
  id: -6463442708295518293,
  properties: {
    r'appId': PropertySchema(
      id: 0,
      name: r'appId',
      type: IsarType.string,
    ),
    r'avgResponseTimeMs': PropertySchema(
      id: 1,
      name: r'avgResponseTimeMs',
      type: IsarType.double,
    ),
    r'compositeKey': PropertySchema(
      id: 2,
      name: r'compositeKey',
      type: IsarType.string,
    ),
    r'costPerRequest': PropertySchema(
      id: 3,
      name: r'costPerRequest',
      type: IsarType.double,
    ),
    r'costPerToken': PropertySchema(
      id: 4,
      name: r'costPerToken',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 5,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'date': PropertySchema(
      id: 6,
      name: r'date',
      type: IsarType.string,
    ),
    r'errorRate': PropertySchema(
      id: 7,
      name: r'errorRate',
      type: IsarType.double,
    ),
    r'failedRequests': PropertySchema(
      id: 8,
      name: r'failedRequests',
      type: IsarType.long,
    ),
    r'maxResponseTimeMs': PropertySchema(
      id: 9,
      name: r'maxResponseTimeMs',
      type: IsarType.long,
    ),
    r'minResponseTimeMs': PropertySchema(
      id: 10,
      name: r'minResponseTimeMs',
      type: IsarType.long,
    ),
    r'model': PropertySchema(
      id: 11,
      name: r'model',
      type: IsarType.string,
    ),
    r'provider': PropertySchema(
      id: 12,
      name: r'provider',
      type: IsarType.string,
    ),
    r'successRate': PropertySchema(
      id: 13,
      name: r'successRate',
      type: IsarType.double,
    ),
    r'successfulRequests': PropertySchema(
      id: 14,
      name: r'successfulRequests',
      type: IsarType.long,
    ),
    r'tokensPerRequest': PropertySchema(
      id: 15,
      name: r'tokensPerRequest',
      type: IsarType.double,
    ),
    r'totalCost': PropertySchema(
      id: 16,
      name: r'totalCost',
      type: IsarType.double,
    ),
    r'totalInputTokens': PropertySchema(
      id: 17,
      name: r'totalInputTokens',
      type: IsarType.long,
    ),
    r'totalOutputTokens': PropertySchema(
      id: 18,
      name: r'totalOutputTokens',
      type: IsarType.long,
    ),
    r'totalRequests': PropertySchema(
      id: 19,
      name: r'totalRequests',
      type: IsarType.long,
    ),
    r'totalTokens': PropertySchema(
      id: 20,
      name: r'totalTokens',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 21,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _usageDailyEstimateSize,
  serialize: _usageDailySerialize,
  deserialize: _usageDailyDeserialize,
  deserializeProp: _usageDailyDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'appId': IndexSchema(
      id: -6867569882656943350,
      name: r'appId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'appId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'provider': IndexSchema(
      id: -6343122774420421053,
      name: r'provider',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'provider',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'model': IndexSchema(
      id: 8229337662361542422,
      name: r'model',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'model',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _usageDailyGetId,
  getLinks: _usageDailyGetLinks,
  attach: _usageDailyAttach,
  version: '3.1.0+1',
);

int _usageDailyEstimateSize(
  UsageDaily object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.appId.length * 3;
  bytesCount += 3 + object.compositeKey.length * 3;
  bytesCount += 3 + object.date.length * 3;
  bytesCount += 3 + object.model.length * 3;
  bytesCount += 3 + object.provider.length * 3;
  return bytesCount;
}

void _usageDailySerialize(
  UsageDaily object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.appId);
  writer.writeDouble(offsets[1], object.avgResponseTimeMs);
  writer.writeString(offsets[2], object.compositeKey);
  writer.writeDouble(offsets[3], object.costPerRequest);
  writer.writeDouble(offsets[4], object.costPerToken);
  writer.writeDateTime(offsets[5], object.createdAt);
  writer.writeString(offsets[6], object.date);
  writer.writeDouble(offsets[7], object.errorRate);
  writer.writeLong(offsets[8], object.failedRequests);
  writer.writeLong(offsets[9], object.maxResponseTimeMs);
  writer.writeLong(offsets[10], object.minResponseTimeMs);
  writer.writeString(offsets[11], object.model);
  writer.writeString(offsets[12], object.provider);
  writer.writeDouble(offsets[13], object.successRate);
  writer.writeLong(offsets[14], object.successfulRequests);
  writer.writeDouble(offsets[15], object.tokensPerRequest);
  writer.writeDouble(offsets[16], object.totalCost);
  writer.writeLong(offsets[17], object.totalInputTokens);
  writer.writeLong(offsets[18], object.totalOutputTokens);
  writer.writeLong(offsets[19], object.totalRequests);
  writer.writeLong(offsets[20], object.totalTokens);
  writer.writeDateTime(offsets[21], object.updatedAt);
}

UsageDaily _usageDailyDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UsageDaily();
  object.appId = reader.readString(offsets[0]);
  object.avgResponseTimeMs = reader.readDouble(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[5]);
  object.date = reader.readString(offsets[6]);
  object.errorRate = reader.readDouble(offsets[7]);
  object.failedRequests = reader.readLong(offsets[8]);
  object.id = id;
  object.maxResponseTimeMs = reader.readLong(offsets[9]);
  object.minResponseTimeMs = reader.readLong(offsets[10]);
  object.model = reader.readString(offsets[11]);
  object.provider = reader.readString(offsets[12]);
  object.successfulRequests = reader.readLong(offsets[14]);
  object.totalCost = reader.readDouble(offsets[16]);
  object.totalInputTokens = reader.readLong(offsets[17]);
  object.totalOutputTokens = reader.readLong(offsets[18]);
  object.totalRequests = reader.readLong(offsets[19]);
  object.totalTokens = reader.readLong(offsets[20]);
  object.updatedAt = reader.readDateTime(offsets[21]);
  return object;
}

P _usageDailyDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readDouble(offset)) as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readLong(offset)) as P;
    case 20:
      return (reader.readLong(offset)) as P;
    case 21:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _usageDailyGetId(UsageDaily object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _usageDailyGetLinks(UsageDaily object) {
  return [];
}

void _usageDailyAttach(IsarCollection<dynamic> col, Id id, UsageDaily object) {
  object.id = id;
}

extension UsageDailyQueryWhereSort
    on QueryBuilder<UsageDaily, UsageDaily, QWhere> {
  QueryBuilder<UsageDaily, UsageDaily, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UsageDailyQueryWhere
    on QueryBuilder<UsageDaily, UsageDaily, QWhereClause> {
  QueryBuilder<UsageDaily, UsageDaily, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<UsageDaily, UsageDaily, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterWhereClause> idBetween(
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

  QueryBuilder<UsageDaily, UsageDaily, QAfterWhereClause> dateEqualTo(
      String date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterWhereClause> dateNotEqualTo(
      String date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterWhereClause> appIdEqualTo(
      String appId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'appId',
        value: [appId],
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterWhereClause> appIdNotEqualTo(
      String appId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'appId',
              lower: [],
              upper: [appId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'appId',
              lower: [appId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'appId',
              lower: [appId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'appId',
              lower: [],
              upper: [appId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterWhereClause> providerEqualTo(
      String provider) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'provider',
        value: [provider],
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterWhereClause> providerNotEqualTo(
      String provider) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'provider',
              lower: [],
              upper: [provider],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'provider',
              lower: [provider],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'provider',
              lower: [provider],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'provider',
              lower: [],
              upper: [provider],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterWhereClause> modelEqualTo(
      String model) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'model',
        value: [model],
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterWhereClause> modelNotEqualTo(
      String model) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'model',
              lower: [],
              upper: [model],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'model',
              lower: [model],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'model',
              lower: [model],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'model',
              lower: [],
              upper: [model],
              includeUpper: false,
            ));
      }
    });
  }
}

extension UsageDailyQueryFilter
    on QueryBuilder<UsageDaily, UsageDaily, QFilterCondition> {
  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> appIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> appIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'appId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> appIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'appId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> appIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'appId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> appIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'appId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> appIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'appId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> appIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'appId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> appIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'appId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> appIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appId',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      appIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'appId',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      avgResponseTimeMsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgResponseTimeMs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      avgResponseTimeMsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgResponseTimeMs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      avgResponseTimeMsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgResponseTimeMs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      avgResponseTimeMsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgResponseTimeMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      compositeKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'compositeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      compositeKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'compositeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      compositeKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'compositeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      compositeKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'compositeKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      compositeKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'compositeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      compositeKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'compositeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      compositeKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'compositeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      compositeKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'compositeKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      compositeKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'compositeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      compositeKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'compositeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      costPerRequestEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'costPerRequest',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      costPerRequestGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'costPerRequest',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      costPerRequestLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'costPerRequest',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      costPerRequestBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'costPerRequest',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      costPerTokenEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'costPerToken',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      costPerTokenGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'costPerToken',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      costPerTokenLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'costPerToken',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      costPerTokenBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'costPerToken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
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

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> dateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> dateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> dateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> dateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> dateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> dateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> dateContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> dateMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'date',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> dateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> dateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> errorRateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      errorRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> errorRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> errorRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      failedRequestsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'failedRequests',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      failedRequestsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'failedRequests',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      failedRequestsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'failedRequests',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      failedRequestsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'failedRequests',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      maxResponseTimeMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxResponseTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      maxResponseTimeMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxResponseTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      maxResponseTimeMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxResponseTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      maxResponseTimeMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxResponseTimeMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      minResponseTimeMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minResponseTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      minResponseTimeMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minResponseTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      minResponseTimeMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minResponseTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      minResponseTimeMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minResponseTimeMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> modelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> modelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> modelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> modelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'model',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> modelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> modelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> modelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> modelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'model',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> modelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'model',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      modelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'model',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> providerEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      providerGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> providerLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> providerBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'provider',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      providerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> providerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> providerContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> providerMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'provider',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      providerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'provider',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      providerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'provider',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      successRateEqualTo(
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

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      successRateGreaterThan(
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

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      successRateLessThan(
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

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      successRateBetween(
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

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      successfulRequestsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'successfulRequests',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      successfulRequestsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'successfulRequests',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      successfulRequestsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'successfulRequests',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      successfulRequestsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'successfulRequests',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      tokensPerRequestEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tokensPerRequest',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      tokensPerRequestGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tokensPerRequest',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      tokensPerRequestLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tokensPerRequest',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      tokensPerRequestBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tokensPerRequest',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> totalCostEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      totalCostGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> totalCostLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> totalCostBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      totalInputTokensEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalInputTokens',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      totalInputTokensGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalInputTokens',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      totalInputTokensLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalInputTokens',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      totalInputTokensBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalInputTokens',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      totalOutputTokensEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalOutputTokens',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      totalOutputTokensGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalOutputTokens',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      totalOutputTokensLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalOutputTokens',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      totalOutputTokensBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalOutputTokens',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      totalRequestsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalRequests',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      totalRequestsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalRequests',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      totalRequestsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalRequests',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      totalRequestsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalRequests',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      totalTokensEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalTokens',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      totalTokensGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalTokens',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      totalTokensLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalTokens',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
      totalTokensBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalTokens',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition>
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

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<UsageDaily, UsageDaily, QAfterFilterCondition> updatedAtBetween(
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

extension UsageDailyQueryObject
    on QueryBuilder<UsageDaily, UsageDaily, QFilterCondition> {}

extension UsageDailyQueryLinks
    on QueryBuilder<UsageDaily, UsageDaily, QFilterCondition> {}

extension UsageDailyQuerySortBy
    on QueryBuilder<UsageDaily, UsageDaily, QSortBy> {
  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByAppId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appId', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByAppIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appId', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByAvgResponseTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgResponseTimeMs', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      sortByAvgResponseTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgResponseTimeMs', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByCompositeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compositeKey', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByCompositeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compositeKey', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByCostPerRequest() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerRequest', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      sortByCostPerRequestDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerRequest', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByCostPerToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerToken', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByCostPerTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerToken', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByErrorRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorRate', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByErrorRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorRate', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByFailedRequests() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedRequests', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      sortByFailedRequestsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedRequests', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByMaxResponseTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxResponseTimeMs', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      sortByMaxResponseTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxResponseTimeMs', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByMinResponseTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minResponseTimeMs', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      sortByMinResponseTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minResponseTimeMs', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provider', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provider', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortBySuccessRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successRate', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortBySuccessRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successRate', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      sortBySuccessfulRequests() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successfulRequests', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      sortBySuccessfulRequestsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successfulRequests', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByTokensPerRequest() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokensPerRequest', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      sortByTokensPerRequestDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokensPerRequest', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByTotalCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByTotalInputTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInputTokens', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      sortByTotalInputTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInputTokens', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByTotalOutputTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalOutputTokens', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      sortByTotalOutputTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalOutputTokens', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByTotalRequests() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRequests', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByTotalRequestsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRequests', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByTotalTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTokens', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByTotalTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTokens', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension UsageDailyQuerySortThenBy
    on QueryBuilder<UsageDaily, UsageDaily, QSortThenBy> {
  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByAppId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appId', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByAppIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appId', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByAvgResponseTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgResponseTimeMs', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      thenByAvgResponseTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgResponseTimeMs', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByCompositeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compositeKey', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByCompositeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compositeKey', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByCostPerRequest() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerRequest', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      thenByCostPerRequestDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerRequest', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByCostPerToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerToken', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByCostPerTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costPerToken', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByErrorRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorRate', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByErrorRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorRate', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByFailedRequests() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedRequests', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      thenByFailedRequestsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedRequests', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByMaxResponseTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxResponseTimeMs', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      thenByMaxResponseTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxResponseTimeMs', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByMinResponseTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minResponseTimeMs', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      thenByMinResponseTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minResponseTimeMs', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provider', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provider', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenBySuccessRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successRate', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenBySuccessRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successRate', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      thenBySuccessfulRequests() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successfulRequests', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      thenBySuccessfulRequestsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successfulRequests', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByTokensPerRequest() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokensPerRequest', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      thenByTokensPerRequestDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokensPerRequest', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByTotalCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByTotalInputTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInputTokens', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      thenByTotalInputTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalInputTokens', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByTotalOutputTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalOutputTokens', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy>
      thenByTotalOutputTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalOutputTokens', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByTotalRequests() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRequests', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByTotalRequestsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRequests', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByTotalTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTokens', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByTotalTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTokens', Sort.desc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension UsageDailyQueryWhereDistinct
    on QueryBuilder<UsageDaily, UsageDaily, QDistinct> {
  QueryBuilder<UsageDaily, UsageDaily, QDistinct> distinctByAppId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct>
      distinctByAvgResponseTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgResponseTimeMs');
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct> distinctByCompositeKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'compositeKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct> distinctByCostPerRequest() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'costPerRequest');
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct> distinctByCostPerToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'costPerToken');
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct> distinctByDate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct> distinctByErrorRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorRate');
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct> distinctByFailedRequests() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failedRequests');
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct>
      distinctByMaxResponseTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxResponseTimeMs');
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct>
      distinctByMinResponseTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minResponseTimeMs');
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct> distinctByModel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'model', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct> distinctByProvider(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'provider', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct> distinctBySuccessRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'successRate');
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct>
      distinctBySuccessfulRequests() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'successfulRequests');
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct> distinctByTokensPerRequest() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tokensPerRequest');
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct> distinctByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCost');
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct> distinctByTotalInputTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalInputTokens');
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct>
      distinctByTotalOutputTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalOutputTokens');
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct> distinctByTotalRequests() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalRequests');
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct> distinctByTotalTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalTokens');
    });
  }

  QueryBuilder<UsageDaily, UsageDaily, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension UsageDailyQueryProperty
    on QueryBuilder<UsageDaily, UsageDaily, QQueryProperty> {
  QueryBuilder<UsageDaily, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UsageDaily, String, QQueryOperations> appIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appId');
    });
  }

  QueryBuilder<UsageDaily, double, QQueryOperations>
      avgResponseTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgResponseTimeMs');
    });
  }

  QueryBuilder<UsageDaily, String, QQueryOperations> compositeKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'compositeKey');
    });
  }

  QueryBuilder<UsageDaily, double, QQueryOperations> costPerRequestProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'costPerRequest');
    });
  }

  QueryBuilder<UsageDaily, double, QQueryOperations> costPerTokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'costPerToken');
    });
  }

  QueryBuilder<UsageDaily, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<UsageDaily, String, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<UsageDaily, double, QQueryOperations> errorRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorRate');
    });
  }

  QueryBuilder<UsageDaily, int, QQueryOperations> failedRequestsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failedRequests');
    });
  }

  QueryBuilder<UsageDaily, int, QQueryOperations> maxResponseTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxResponseTimeMs');
    });
  }

  QueryBuilder<UsageDaily, int, QQueryOperations> minResponseTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minResponseTimeMs');
    });
  }

  QueryBuilder<UsageDaily, String, QQueryOperations> modelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'model');
    });
  }

  QueryBuilder<UsageDaily, String, QQueryOperations> providerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'provider');
    });
  }

  QueryBuilder<UsageDaily, double, QQueryOperations> successRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'successRate');
    });
  }

  QueryBuilder<UsageDaily, int, QQueryOperations> successfulRequestsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'successfulRequests');
    });
  }

  QueryBuilder<UsageDaily, double, QQueryOperations>
      tokensPerRequestProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tokensPerRequest');
    });
  }

  QueryBuilder<UsageDaily, double, QQueryOperations> totalCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCost');
    });
  }

  QueryBuilder<UsageDaily, int, QQueryOperations> totalInputTokensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalInputTokens');
    });
  }

  QueryBuilder<UsageDaily, int, QQueryOperations> totalOutputTokensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalOutputTokens');
    });
  }

  QueryBuilder<UsageDaily, int, QQueryOperations> totalRequestsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalRequests');
    });
  }

  QueryBuilder<UsageDaily, int, QQueryOperations> totalTokensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalTokens');
    });
  }

  QueryBuilder<UsageDaily, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsageDaily _$UsageDailyFromJson(Map<String, dynamic> json) => UsageDaily()
  ..id = (json['id'] as num).toInt()
  ..date = json['date'] as String? ?? ''
  ..appId = json['appId'] as String? ?? ''
  ..provider = json['provider'] as String? ?? ''
  ..model = json['model'] as String? ?? ''
  ..totalRequests = (json['totalRequests'] as num?)?.toInt() ?? 0
  ..successfulRequests = (json['successfulRequests'] as num?)?.toInt() ?? 0
  ..failedRequests = (json['failedRequests'] as num?)?.toInt() ?? 0
  ..totalInputTokens = (json['totalInputTokens'] as num?)?.toInt() ?? 0
  ..totalOutputTokens = (json['totalOutputTokens'] as num?)?.toInt() ?? 0
  ..totalTokens = (json['totalTokens'] as num?)?.toInt() ?? 0
  ..totalCost = (json['totalCost'] as num?)?.toDouble() ?? 0.0
  ..avgResponseTimeMs = (json['avgResponseTimeMs'] as num?)?.toDouble() ?? 0.0
  ..errorRate = (json['errorRate'] as num?)?.toDouble() ?? 0.0
  ..maxResponseTimeMs = (json['maxResponseTimeMs'] as num?)?.toInt() ?? 0
  ..minResponseTimeMs = (json['minResponseTimeMs'] as num?)?.toInt() ?? 0
  ..createdAt = DateTime.parse(json['created_at'] as String)
  ..updatedAt = DateTime.parse(json['updated_at'] as String);

Map<String, dynamic> _$UsageDailyToJson(UsageDaily instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'appId': instance.appId,
      'provider': instance.provider,
      'model': instance.model,
      'totalRequests': instance.totalRequests,
      'successfulRequests': instance.successfulRequests,
      'failedRequests': instance.failedRequests,
      'totalInputTokens': instance.totalInputTokens,
      'totalOutputTokens': instance.totalOutputTokens,
      'totalTokens': instance.totalTokens,
      'totalCost': instance.totalCost,
      'avgResponseTimeMs': instance.avgResponseTimeMs,
      'errorRate': instance.errorRate,
      'maxResponseTimeMs': instance.maxResponseTimeMs,
      'minResponseTimeMs': instance.minResponseTimeMs,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
