// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricing_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPricingModelCollection on Isar {
  IsarCollection<PricingModel> get pricingModels => this.collection();
}

const PricingModelSchema = CollectionSchema(
  name: r'PricingModel',
  id: 1302983238606358763,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'displayName': PropertySchema(
      id: 2,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'inputPricePerMToken': PropertySchema(
      id: 3,
      name: r'inputPricePerMToken',
      type: IsarType.double,
    ),
    r'isActive': PropertySchema(
      id: 4,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'maxContextLength': PropertySchema(
      id: 5,
      name: r'maxContextLength',
      type: IsarType.long,
    ),
    r'maxOutputLength': PropertySchema(
      id: 6,
      name: r'maxOutputLength',
      type: IsarType.long,
    ),
    r'minimumCost': PropertySchema(
      id: 7,
      name: r'minimumCost',
      type: IsarType.double,
    ),
    r'model': PropertySchema(
      id: 8,
      name: r'model',
      type: IsarType.string,
    ),
    r'outputPricePerMToken': PropertySchema(
      id: 9,
      name: r'outputPricePerMToken',
      type: IsarType.double,
    ),
    r'provider': PropertySchema(
      id: 10,
      name: r'provider',
      type: IsarType.string,
    ),
    r'supportedFeatures': PropertySchema(
      id: 11,
      name: r'supportedFeatures',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 12,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _pricingModelEstimateSize,
  serialize: _pricingModelSerialize,
  deserialize: _pricingModelDeserialize,
  deserializeProp: _pricingModelDeserializeProp,
  idName: r'id',
  indexes: {
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
      unique: true,
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
  getId: _pricingModelGetId,
  getLinks: _pricingModelGetLinks,
  attach: _pricingModelAttach,
  version: '3.1.0+1',
);

int _pricingModelEstimateSize(
  PricingModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.displayName.length * 3;
  bytesCount += 3 + object.model.length * 3;
  bytesCount += 3 + object.provider.length * 3;
  bytesCount += 3 + object.supportedFeatures.length * 3;
  return bytesCount;
}

void _pricingModelSerialize(
  PricingModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.description);
  writer.writeString(offsets[2], object.displayName);
  writer.writeDouble(offsets[3], object.inputPricePerMToken);
  writer.writeBool(offsets[4], object.isActive);
  writer.writeLong(offsets[5], object.maxContextLength);
  writer.writeLong(offsets[6], object.maxOutputLength);
  writer.writeDouble(offsets[7], object.minimumCost);
  writer.writeString(offsets[8], object.model);
  writer.writeDouble(offsets[9], object.outputPricePerMToken);
  writer.writeString(offsets[10], object.provider);
  writer.writeString(offsets[11], object.supportedFeatures);
  writer.writeDateTime(offsets[12], object.updatedAt);
}

PricingModel _pricingModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PricingModel();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.description = reader.readString(offsets[1]);
  object.displayName = reader.readString(offsets[2]);
  object.id = id;
  object.inputPricePerMToken = reader.readDouble(offsets[3]);
  object.isActive = reader.readBool(offsets[4]);
  object.maxContextLength = reader.readLong(offsets[5]);
  object.maxOutputLength = reader.readLong(offsets[6]);
  object.minimumCost = reader.readDouble(offsets[7]);
  object.model = reader.readString(offsets[8]);
  object.outputPricePerMToken = reader.readDouble(offsets[9]);
  object.provider = reader.readString(offsets[10]);
  object.supportedFeatures = reader.readString(offsets[11]);
  object.updatedAt = reader.readDateTime(offsets[12]);
  return object;
}

P _pricingModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pricingModelGetId(PricingModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pricingModelGetLinks(PricingModel object) {
  return [];
}

void _pricingModelAttach(
    IsarCollection<dynamic> col, Id id, PricingModel object) {
  object.id = id;
}

extension PricingModelByIndex on IsarCollection<PricingModel> {
  Future<PricingModel?> getByModel(String model) {
    return getByIndex(r'model', [model]);
  }

  PricingModel? getByModelSync(String model) {
    return getByIndexSync(r'model', [model]);
  }

  Future<bool> deleteByModel(String model) {
    return deleteByIndex(r'model', [model]);
  }

  bool deleteByModelSync(String model) {
    return deleteByIndexSync(r'model', [model]);
  }

  Future<List<PricingModel?>> getAllByModel(List<String> modelValues) {
    final values = modelValues.map((e) => [e]).toList();
    return getAllByIndex(r'model', values);
  }

  List<PricingModel?> getAllByModelSync(List<String> modelValues) {
    final values = modelValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'model', values);
  }

  Future<int> deleteAllByModel(List<String> modelValues) {
    final values = modelValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'model', values);
  }

  int deleteAllByModelSync(List<String> modelValues) {
    final values = modelValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'model', values);
  }

  Future<Id> putByModel(PricingModel object) {
    return putByIndex(r'model', object);
  }

  Id putByModelSync(PricingModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'model', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByModel(List<PricingModel> objects) {
    return putAllByIndex(r'model', objects);
  }

  List<Id> putAllByModelSync(List<PricingModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'model', objects, saveLinks: saveLinks);
  }
}

extension PricingModelQueryWhereSort
    on QueryBuilder<PricingModel, PricingModel, QWhere> {
  QueryBuilder<PricingModel, PricingModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PricingModelQueryWhere
    on QueryBuilder<PricingModel, PricingModel, QWhereClause> {
  QueryBuilder<PricingModel, PricingModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PricingModel, PricingModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<PricingModel, PricingModel, QAfterWhereClause> providerEqualTo(
      String provider) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'provider',
        value: [provider],
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterWhereClause>
      providerNotEqualTo(String provider) {
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

  QueryBuilder<PricingModel, PricingModel, QAfterWhereClause> modelEqualTo(
      String model) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'model',
        value: [model],
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterWhereClause> modelNotEqualTo(
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

extension PricingModelQueryFilter
    on QueryBuilder<PricingModel, PricingModel, QFilterCondition> {
  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      displayNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      displayNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      displayNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      displayNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      displayNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      displayNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      displayNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      displayNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      inputPricePerMTokenEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inputPricePerMToken',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      inputPricePerMTokenGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'inputPricePerMToken',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      inputPricePerMTokenLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'inputPricePerMToken',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      inputPricePerMTokenBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'inputPricePerMToken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      maxContextLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxContextLength',
        value: value,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      maxContextLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxContextLength',
        value: value,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      maxContextLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxContextLength',
        value: value,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      maxContextLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxContextLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      maxOutputLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxOutputLength',
        value: value,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      maxOutputLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxOutputLength',
        value: value,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      maxOutputLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxOutputLength',
        value: value,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      maxOutputLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxOutputLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      minimumCostEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minimumCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      minimumCostGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minimumCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      minimumCostLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minimumCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      minimumCostBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minimumCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition> modelEqualTo(
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      modelGreaterThan(
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition> modelLessThan(
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition> modelBetween(
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      modelStartsWith(
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition> modelEndsWith(
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition> modelContains(
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition> modelMatches(
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      modelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'model',
        value: '',
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      modelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'model',
        value: '',
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      outputPricePerMTokenEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'outputPricePerMToken',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      outputPricePerMTokenGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'outputPricePerMToken',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      outputPricePerMTokenLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'outputPricePerMToken',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      outputPricePerMTokenBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'outputPricePerMToken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      providerEqualTo(
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      providerLessThan(
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      providerBetween(
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      providerEndsWith(
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      providerContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'provider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      providerMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'provider',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      providerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'provider',
        value: '',
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      providerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'provider',
        value: '',
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      supportedFeaturesEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supportedFeatures',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      supportedFeaturesGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supportedFeatures',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      supportedFeaturesLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supportedFeatures',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      supportedFeaturesBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supportedFeatures',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      supportedFeaturesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supportedFeatures',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      supportedFeaturesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supportedFeatures',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      supportedFeaturesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supportedFeatures',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      supportedFeaturesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supportedFeatures',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      supportedFeaturesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supportedFeatures',
        value: '',
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      supportedFeaturesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supportedFeatures',
        value: '',
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
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

  QueryBuilder<PricingModel, PricingModel, QAfterFilterCondition>
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

extension PricingModelQueryObject
    on QueryBuilder<PricingModel, PricingModel, QFilterCondition> {}

extension PricingModelQueryLinks
    on QueryBuilder<PricingModel, PricingModel, QFilterCondition> {}

extension PricingModelQuerySortBy
    on QueryBuilder<PricingModel, PricingModel, QSortBy> {
  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> sortByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      sortByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      sortByInputPricePerMToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputPricePerMToken', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      sortByInputPricePerMTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputPricePerMToken', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      sortByMaxContextLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxContextLength', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      sortByMaxContextLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxContextLength', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      sortByMaxOutputLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxOutputLength', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      sortByMaxOutputLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxOutputLength', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> sortByMinimumCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimumCost', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      sortByMinimumCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimumCost', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> sortByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> sortByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      sortByOutputPricePerMToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputPricePerMToken', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      sortByOutputPricePerMTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputPricePerMToken', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> sortByProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provider', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> sortByProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provider', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      sortBySupportedFeatures() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supportedFeatures', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      sortBySupportedFeaturesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supportedFeatures', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PricingModelQuerySortThenBy
    on QueryBuilder<PricingModel, PricingModel, QSortThenBy> {
  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> thenByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      thenByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      thenByInputPricePerMToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputPricePerMToken', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      thenByInputPricePerMTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputPricePerMToken', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      thenByMaxContextLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxContextLength', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      thenByMaxContextLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxContextLength', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      thenByMaxOutputLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxOutputLength', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      thenByMaxOutputLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxOutputLength', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> thenByMinimumCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimumCost', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      thenByMinimumCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimumCost', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> thenByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> thenByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      thenByOutputPricePerMToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputPricePerMToken', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      thenByOutputPricePerMTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputPricePerMToken', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> thenByProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provider', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> thenByProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provider', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      thenBySupportedFeatures() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supportedFeatures', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy>
      thenBySupportedFeaturesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supportedFeatures', Sort.desc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PricingModelQueryWhereDistinct
    on QueryBuilder<PricingModel, PricingModel, QDistinct> {
  QueryBuilder<PricingModel, PricingModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PricingModel, PricingModel, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QDistinct> distinctByDisplayName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QDistinct>
      distinctByInputPricePerMToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inputPricePerMToken');
    });
  }

  QueryBuilder<PricingModel, PricingModel, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<PricingModel, PricingModel, QDistinct>
      distinctByMaxContextLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxContextLength');
    });
  }

  QueryBuilder<PricingModel, PricingModel, QDistinct>
      distinctByMaxOutputLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxOutputLength');
    });
  }

  QueryBuilder<PricingModel, PricingModel, QDistinct> distinctByMinimumCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minimumCost');
    });
  }

  QueryBuilder<PricingModel, PricingModel, QDistinct> distinctByModel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'model', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QDistinct>
      distinctByOutputPricePerMToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outputPricePerMToken');
    });
  }

  QueryBuilder<PricingModel, PricingModel, QDistinct> distinctByProvider(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'provider', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QDistinct>
      distinctBySupportedFeatures({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supportedFeatures',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PricingModel, PricingModel, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension PricingModelQueryProperty
    on QueryBuilder<PricingModel, PricingModel, QQueryProperty> {
  QueryBuilder<PricingModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PricingModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PricingModel, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<PricingModel, String, QQueryOperations> displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<PricingModel, double, QQueryOperations>
      inputPricePerMTokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inputPricePerMToken');
    });
  }

  QueryBuilder<PricingModel, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<PricingModel, int, QQueryOperations> maxContextLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxContextLength');
    });
  }

  QueryBuilder<PricingModel, int, QQueryOperations> maxOutputLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxOutputLength');
    });
  }

  QueryBuilder<PricingModel, double, QQueryOperations> minimumCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minimumCost');
    });
  }

  QueryBuilder<PricingModel, String, QQueryOperations> modelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'model');
    });
  }

  QueryBuilder<PricingModel, double, QQueryOperations>
      outputPricePerMTokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outputPricePerMToken');
    });
  }

  QueryBuilder<PricingModel, String, QQueryOperations> providerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'provider');
    });
  }

  QueryBuilder<PricingModel, String, QQueryOperations>
      supportedFeaturesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supportedFeatures');
    });
  }

  QueryBuilder<PricingModel, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PricingModel _$PricingModelFromJson(Map<String, dynamic> json) => PricingModel()
  ..id = (json['id'] as num).toInt()
  ..provider = json['provider'] as String? ?? ''
  ..model = json['model'] as String? ?? ''
  ..displayName = json['displayName'] as String? ?? ''
  ..inputPricePerMToken =
      (json['inputPricePerMToken'] as num?)?.toDouble() ?? 0.0
  ..outputPricePerMToken =
      (json['outputPricePerMToken'] as num?)?.toDouble() ?? 0.0
  ..minimumCost = (json['minimumCost'] as num?)?.toDouble() ?? 0.0
  ..maxContextLength = (json['maxContextLength'] as num?)?.toInt() ?? 0
  ..maxOutputLength = (json['maxOutputLength'] as num?)?.toInt() ?? 0
  ..supportedFeatures = json['supportedFeatures'] as String? ?? '[]'
  ..description = json['description'] as String? ?? ''
  ..isActive = json['isActive'] as bool? ?? true
  ..createdAt = DateTime.parse(json['created_at'] as String)
  ..updatedAt = DateTime.parse(json['updated_at'] as String);

Map<String, dynamic> _$PricingModelToJson(PricingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'provider': instance.provider,
      'model': instance.model,
      'displayName': instance.displayName,
      'inputPricePerMToken': instance.inputPricePerMToken,
      'outputPricePerMToken': instance.outputPricePerMToken,
      'minimumCost': instance.minimumCost,
      'maxContextLength': instance.maxContextLength,
      'maxOutputLength': instance.maxOutputLength,
      'supportedFeatures': instance.supportedFeatures,
      'description': instance.description,
      'isActive': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
