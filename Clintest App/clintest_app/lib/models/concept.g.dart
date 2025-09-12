// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concept.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetConceptCollection on Isar {
  IsarCollection<Concept> get concepts => this.collection();
}

const ConceptSchema = CollectionSchema(
  name: r'Concept',
  id: 7875213883234436571,
  properties: {
    r'aiExplanation': PropertySchema(
      id: 0,
      name: r'aiExplanation',
      type: IsarType.string,
    ),
    r'aiGeneratedDate': PropertySchema(
      id: 1,
      name: r'aiGeneratedDate',
      type: IsarType.dateTime,
    ),
    r'category': PropertySchema(
      id: 2,
      name: r'category',
      type: IsarType.string,
    ),
    r'conceptCode': PropertySchema(
      id: 3,
      name: r'conceptCode',
      type: IsarType.string,
    ),
    r'conceptName': PropertySchema(
      id: 4,
      name: r'conceptName',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 5,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 6,
      name: r'description',
      type: IsarType.string,
    ),
    r'difficulty': PropertySchema(
      id: 7,
      name: r'difficulty',
      type: IsarType.string,
    ),
    r'followUps': PropertySchema(
      id: 8,
      name: r'followUps',
      type: IsarType.stringList,
    ),
    r'importance': PropertySchema(
      id: 9,
      name: r'importance',
      type: IsarType.long,
    ),
    r'isLearned': PropertySchema(
      id: 10,
      name: r'isLearned',
      type: IsarType.bool,
    ),
    r'keywords': PropertySchema(
      id: 11,
      name: r'keywords',
      type: IsarType.stringList,
    ),
    r'learnedDate': PropertySchema(
      id: 12,
      name: r'learnedDate',
      type: IsarType.dateTime,
    ),
    r'learningOrder': PropertySchema(
      id: 13,
      name: r'learningOrder',
      type: IsarType.long,
    ),
    r'needsReview': PropertySchema(
      id: 14,
      name: r'needsReview',
      type: IsarType.bool,
    ),
    r'nextReviewDate': PropertySchema(
      id: 15,
      name: r'nextReviewDate',
      type: IsarType.dateTime,
    ),
    r'prerequisites': PropertySchema(
      id: 16,
      name: r'prerequisites',
      type: IsarType.stringList,
    ),
    r'shouldReview': PropertySchema(
      id: 17,
      name: r'shouldReview',
      type: IsarType.bool,
    ),
    r'subjectCode': PropertySchema(
      id: 18,
      name: r'subjectCode',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 19,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _conceptEstimateSize,
  serialize: _conceptSerialize,
  deserialize: _conceptDeserialize,
  deserializeProp: _conceptDeserializeProp,
  idName: r'id',
  indexes: {
    r'conceptCode': IndexSchema(
      id: 7460213576520163597,
      name: r'conceptCode',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'conceptCode',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isLearned': IndexSchema(
      id: 1626199868823320107,
      name: r'isLearned',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isLearned',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _conceptGetId,
  getLinks: _conceptGetLinks,
  attach: _conceptAttach,
  version: '3.1.0+1',
);

int _conceptEstimateSize(
  Concept object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.aiExplanation;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.category.length * 3;
  bytesCount += 3 + object.conceptCode.length * 3;
  bytesCount += 3 + object.conceptName.length * 3;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.difficulty.length * 3;
  bytesCount += 3 + object.followUps.length * 3;
  {
    for (var i = 0; i < object.followUps.length; i++) {
      final value = object.followUps[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.keywords.length * 3;
  {
    for (var i = 0; i < object.keywords.length; i++) {
      final value = object.keywords[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.prerequisites.length * 3;
  {
    for (var i = 0; i < object.prerequisites.length; i++) {
      final value = object.prerequisites[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.subjectCode.length * 3;
  return bytesCount;
}

void _conceptSerialize(
  Concept object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aiExplanation);
  writer.writeDateTime(offsets[1], object.aiGeneratedDate);
  writer.writeString(offsets[2], object.category);
  writer.writeString(offsets[3], object.conceptCode);
  writer.writeString(offsets[4], object.conceptName);
  writer.writeDateTime(offsets[5], object.createdAt);
  writer.writeString(offsets[6], object.description);
  writer.writeString(offsets[7], object.difficulty);
  writer.writeStringList(offsets[8], object.followUps);
  writer.writeLong(offsets[9], object.importance);
  writer.writeBool(offsets[10], object.isLearned);
  writer.writeStringList(offsets[11], object.keywords);
  writer.writeDateTime(offsets[12], object.learnedDate);
  writer.writeLong(offsets[13], object.learningOrder);
  writer.writeBool(offsets[14], object.needsReview);
  writer.writeDateTime(offsets[15], object.nextReviewDate);
  writer.writeStringList(offsets[16], object.prerequisites);
  writer.writeBool(offsets[17], object.shouldReview);
  writer.writeString(offsets[18], object.subjectCode);
  writer.writeDateTime(offsets[19], object.updatedAt);
}

Concept _conceptDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Concept();
  object.aiExplanation = reader.readStringOrNull(offsets[0]);
  object.aiGeneratedDate = reader.readDateTimeOrNull(offsets[1]);
  object.category = reader.readString(offsets[2]);
  object.conceptCode = reader.readString(offsets[3]);
  object.conceptName = reader.readString(offsets[4]);
  object.createdAt = reader.readDateTime(offsets[5]);
  object.description = reader.readString(offsets[6]);
  object.difficulty = reader.readString(offsets[7]);
  object.followUps = reader.readStringList(offsets[8]) ?? [];
  object.id = id;
  object.importance = reader.readLong(offsets[9]);
  object.isLearned = reader.readBool(offsets[10]);
  object.keywords = reader.readStringList(offsets[11]) ?? [];
  object.learnedDate = reader.readDateTimeOrNull(offsets[12]);
  object.learningOrder = reader.readLong(offsets[13]);
  object.needsReview = reader.readBool(offsets[14]);
  object.nextReviewDate = reader.readDateTimeOrNull(offsets[15]);
  object.prerequisites = reader.readStringList(offsets[16]) ?? [];
  object.subjectCode = reader.readString(offsets[18]);
  object.updatedAt = reader.readDateTime(offsets[19]);
  return object;
}

P _conceptDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringList(offset) ?? []) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readStringList(offset) ?? []) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readStringList(offset) ?? []) as P;
    case 17:
      return (reader.readBool(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _conceptGetId(Concept object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _conceptGetLinks(Concept object) {
  return [];
}

void _conceptAttach(IsarCollection<dynamic> col, Id id, Concept object) {
  object.id = id;
}

extension ConceptByIndex on IsarCollection<Concept> {
  Future<Concept?> getByConceptCode(String conceptCode) {
    return getByIndex(r'conceptCode', [conceptCode]);
  }

  Concept? getByConceptCodeSync(String conceptCode) {
    return getByIndexSync(r'conceptCode', [conceptCode]);
  }

  Future<bool> deleteByConceptCode(String conceptCode) {
    return deleteByIndex(r'conceptCode', [conceptCode]);
  }

  bool deleteByConceptCodeSync(String conceptCode) {
    return deleteByIndexSync(r'conceptCode', [conceptCode]);
  }

  Future<List<Concept?>> getAllByConceptCode(List<String> conceptCodeValues) {
    final values = conceptCodeValues.map((e) => [e]).toList();
    return getAllByIndex(r'conceptCode', values);
  }

  List<Concept?> getAllByConceptCodeSync(List<String> conceptCodeValues) {
    final values = conceptCodeValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'conceptCode', values);
  }

  Future<int> deleteAllByConceptCode(List<String> conceptCodeValues) {
    final values = conceptCodeValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'conceptCode', values);
  }

  int deleteAllByConceptCodeSync(List<String> conceptCodeValues) {
    final values = conceptCodeValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'conceptCode', values);
  }

  Future<Id> putByConceptCode(Concept object) {
    return putByIndex(r'conceptCode', object);
  }

  Id putByConceptCodeSync(Concept object, {bool saveLinks = true}) {
    return putByIndexSync(r'conceptCode', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByConceptCode(List<Concept> objects) {
    return putAllByIndex(r'conceptCode', objects);
  }

  List<Id> putAllByConceptCodeSync(List<Concept> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'conceptCode', objects, saveLinks: saveLinks);
  }
}

extension ConceptQueryWhereSort on QueryBuilder<Concept, Concept, QWhere> {
  QueryBuilder<Concept, Concept, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Concept, Concept, QAfterWhere> anyIsLearned() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isLearned'),
      );
    });
  }
}

extension ConceptQueryWhere on QueryBuilder<Concept, Concept, QWhereClause> {
  QueryBuilder<Concept, Concept, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Concept, Concept, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterWhereClause> idBetween(
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

  QueryBuilder<Concept, Concept, QAfterWhereClause> conceptCodeEqualTo(
      String conceptCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'conceptCode',
        value: [conceptCode],
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterWhereClause> conceptCodeNotEqualTo(
      String conceptCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conceptCode',
              lower: [],
              upper: [conceptCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conceptCode',
              lower: [conceptCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conceptCode',
              lower: [conceptCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conceptCode',
              lower: [],
              upper: [conceptCode],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Concept, Concept, QAfterWhereClause> isLearnedEqualTo(
      bool isLearned) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isLearned',
        value: [isLearned],
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterWhereClause> isLearnedNotEqualTo(
      bool isLearned) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isLearned',
              lower: [],
              upper: [isLearned],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isLearned',
              lower: [isLearned],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isLearned',
              lower: [isLearned],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isLearned',
              lower: [],
              upper: [isLearned],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ConceptQueryFilter
    on QueryBuilder<Concept, Concept, QFilterCondition> {
  QueryBuilder<Concept, Concept, QAfterFilterCondition> aiExplanationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiExplanation',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      aiExplanationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiExplanation',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> aiExplanationEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiExplanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      aiExplanationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiExplanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> aiExplanationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiExplanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> aiExplanationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiExplanation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> aiExplanationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiExplanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> aiExplanationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiExplanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> aiExplanationContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiExplanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> aiExplanationMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiExplanation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> aiExplanationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiExplanation',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      aiExplanationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiExplanation',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      aiGeneratedDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiGeneratedDate',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      aiGeneratedDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiGeneratedDate',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> aiGeneratedDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiGeneratedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      aiGeneratedDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiGeneratedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> aiGeneratedDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiGeneratedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> aiGeneratedDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiGeneratedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> categoryEqualTo(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> categoryGreaterThan(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> categoryLessThan(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> categoryBetween(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> categoryStartsWith(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> categoryEndsWith(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> categoryContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> categoryMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conceptCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'conceptCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'conceptCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'conceptCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'conceptCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'conceptCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptCodeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'conceptCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptCodeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'conceptCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conceptCode',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      conceptCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'conceptCode',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conceptName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'conceptName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'conceptName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'conceptName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'conceptName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'conceptName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'conceptName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'conceptName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> conceptNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conceptName',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      conceptNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'conceptName',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> descriptionEqualTo(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> descriptionGreaterThan(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> descriptionLessThan(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> descriptionBetween(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> descriptionStartsWith(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> descriptionEndsWith(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> descriptionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> descriptionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> difficultyEqualTo(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> difficultyGreaterThan(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> difficultyLessThan(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> difficultyBetween(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> difficultyStartsWith(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> difficultyEndsWith(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> difficultyContains(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> difficultyMatches(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> difficultyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficulty',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> difficultyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'difficulty',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> followUpsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'followUps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      followUpsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'followUps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      followUpsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'followUps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> followUpsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'followUps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      followUpsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'followUps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      followUpsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'followUps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      followUpsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'followUps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> followUpsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'followUps',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      followUpsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'followUps',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      followUpsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'followUps',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> followUpsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followUps',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> followUpsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followUps',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> followUpsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followUps',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> followUpsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followUps',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      followUpsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followUps',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> followUpsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followUps',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> importanceEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'importance',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> importanceGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'importance',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> importanceLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'importance',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> importanceBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'importance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> isLearnedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isLearned',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> keywordsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      keywordsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'keywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> keywordsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'keywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> keywordsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'keywords',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      keywordsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'keywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> keywordsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'keywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> keywordsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'keywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> keywordsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'keywords',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      keywordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keywords',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      keywordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'keywords',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> keywordsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keywords',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> keywordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keywords',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> keywordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keywords',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> keywordsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keywords',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      keywordsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keywords',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> keywordsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keywords',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> learnedDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'learnedDate',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> learnedDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'learnedDate',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> learnedDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'learnedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> learnedDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'learnedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> learnedDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'learnedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> learnedDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'learnedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> learningOrderEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'learningOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      learningOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'learningOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> learningOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'learningOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> learningOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'learningOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> needsReviewEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'needsReview',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> nextReviewDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextReviewDate',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      nextReviewDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextReviewDate',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> nextReviewDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextReviewDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> nextReviewDateLessThan(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> nextReviewDateBetween(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      prerequisitesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prerequisites',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      prerequisitesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'prerequisites',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      prerequisitesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'prerequisites',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      prerequisitesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'prerequisites',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      prerequisitesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'prerequisites',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      prerequisitesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'prerequisites',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      prerequisitesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'prerequisites',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      prerequisitesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'prerequisites',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      prerequisitesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prerequisites',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      prerequisitesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'prerequisites',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      prerequisitesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'prerequisites',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> prerequisitesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'prerequisites',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      prerequisitesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'prerequisites',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      prerequisitesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'prerequisites',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      prerequisitesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'prerequisites',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      prerequisitesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'prerequisites',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> shouldReviewEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shouldReview',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> subjectCodeEqualTo(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> subjectCodeGreaterThan(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> subjectCodeLessThan(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> subjectCodeBetween(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> subjectCodeStartsWith(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> subjectCodeEndsWith(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> subjectCodeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> subjectCodeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> subjectCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectCode',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition>
      subjectCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectCode',
        value: '',
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Concept, Concept, QAfterFilterCondition> updatedAtGreaterThan(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<Concept, Concept, QAfterFilterCondition> updatedAtBetween(
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

extension ConceptQueryObject
    on QueryBuilder<Concept, Concept, QFilterCondition> {}

extension ConceptQueryLinks
    on QueryBuilder<Concept, Concept, QFilterCondition> {}

extension ConceptQuerySortBy on QueryBuilder<Concept, Concept, QSortBy> {
  QueryBuilder<Concept, Concept, QAfterSortBy> sortByAiExplanation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiExplanation', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByAiExplanationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiExplanation', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByAiGeneratedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiGeneratedDate', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByAiGeneratedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiGeneratedDate', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByConceptCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conceptCode', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByConceptCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conceptCode', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByConceptName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conceptName', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByConceptNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conceptName', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByImportance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importance', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByImportanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importance', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByIsLearned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLearned', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByIsLearnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLearned', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByLearnedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnedDate', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByLearnedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnedDate', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByLearningOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningOrder', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByLearningOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningOrder', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByNeedsReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsReview', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByNeedsReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsReview', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByNextReviewDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReviewDate', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByNextReviewDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReviewDate', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByShouldReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shouldReview', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByShouldReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shouldReview', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortBySubjectCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortBySubjectCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ConceptQuerySortThenBy
    on QueryBuilder<Concept, Concept, QSortThenBy> {
  QueryBuilder<Concept, Concept, QAfterSortBy> thenByAiExplanation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiExplanation', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByAiExplanationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiExplanation', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByAiGeneratedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiGeneratedDate', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByAiGeneratedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiGeneratedDate', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByConceptCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conceptCode', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByConceptCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conceptCode', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByConceptName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conceptName', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByConceptNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conceptName', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByImportance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importance', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByImportanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importance', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByIsLearned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLearned', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByIsLearnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLearned', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByLearnedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnedDate', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByLearnedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnedDate', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByLearningOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningOrder', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByLearningOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningOrder', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByNeedsReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsReview', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByNeedsReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsReview', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByNextReviewDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReviewDate', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByNextReviewDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReviewDate', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByShouldReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shouldReview', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByShouldReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shouldReview', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenBySubjectCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenBySubjectCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.desc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Concept, Concept, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ConceptQueryWhereDistinct
    on QueryBuilder<Concept, Concept, QDistinct> {
  QueryBuilder<Concept, Concept, QDistinct> distinctByAiExplanation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiExplanation',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByAiGeneratedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiGeneratedDate');
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByConceptCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conceptCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByConceptName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conceptName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByDifficulty(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'difficulty', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByFollowUps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'followUps');
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByImportance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importance');
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByIsLearned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLearned');
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByKeywords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'keywords');
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByLearnedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'learnedDate');
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByLearningOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'learningOrder');
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByNeedsReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needsReview');
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByNextReviewDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextReviewDate');
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByPrerequisites() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'prerequisites');
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByShouldReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shouldReview');
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctBySubjectCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Concept, Concept, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ConceptQueryProperty
    on QueryBuilder<Concept, Concept, QQueryProperty> {
  QueryBuilder<Concept, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Concept, String?, QQueryOperations> aiExplanationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiExplanation');
    });
  }

  QueryBuilder<Concept, DateTime?, QQueryOperations> aiGeneratedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiGeneratedDate');
    });
  }

  QueryBuilder<Concept, String, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<Concept, String, QQueryOperations> conceptCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conceptCode');
    });
  }

  QueryBuilder<Concept, String, QQueryOperations> conceptNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conceptName');
    });
  }

  QueryBuilder<Concept, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Concept, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<Concept, String, QQueryOperations> difficultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'difficulty');
    });
  }

  QueryBuilder<Concept, List<String>, QQueryOperations> followUpsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'followUps');
    });
  }

  QueryBuilder<Concept, int, QQueryOperations> importanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importance');
    });
  }

  QueryBuilder<Concept, bool, QQueryOperations> isLearnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLearned');
    });
  }

  QueryBuilder<Concept, List<String>, QQueryOperations> keywordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'keywords');
    });
  }

  QueryBuilder<Concept, DateTime?, QQueryOperations> learnedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'learnedDate');
    });
  }

  QueryBuilder<Concept, int, QQueryOperations> learningOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'learningOrder');
    });
  }

  QueryBuilder<Concept, bool, QQueryOperations> needsReviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needsReview');
    });
  }

  QueryBuilder<Concept, DateTime?, QQueryOperations> nextReviewDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextReviewDate');
    });
  }

  QueryBuilder<Concept, List<String>, QQueryOperations>
      prerequisitesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'prerequisites');
    });
  }

  QueryBuilder<Concept, bool, QQueryOperations> shouldReviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shouldReview');
    });
  }

  QueryBuilder<Concept, String, QQueryOperations> subjectCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectCode');
    });
  }

  QueryBuilder<Concept, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
