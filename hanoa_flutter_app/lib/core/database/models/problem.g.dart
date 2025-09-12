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
    r'answerIndex': PropertySchema(
      id: 0,
      name: r'answerIndex',
      type: IsarType.long,
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
    r'stem': PropertySchema(
      id: 3,
      name: r'stem',
      type: IsarType.string,
    ),
    r'tags': PropertySchema(
      id: 4,
      name: r'tags',
      type: IsarType.stringList,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _problemEstimateSize,
  serialize: _problemSerialize,
  deserialize: _problemDeserialize,
  deserializeProp: _problemDeserializeProp,
  idName: r'id',
  indexes: {},
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
  bytesCount += 3 + object.choices.length * 3;
  {
    for (var i = 0; i < object.choices.length; i++) {
      final value = object.choices[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.correctAnswer.length * 3;
  bytesCount += 3 + object.stem.length * 3;
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _problemSerialize(
  Problem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.answerIndex);
  writer.writeStringList(offsets[1], object.choices);
  writer.writeString(offsets[2], object.correctAnswer);
  writer.writeString(offsets[3], object.stem);
  writer.writeStringList(offsets[4], object.tags);
  writer.writeDateTime(offsets[5], object.updatedAt);
}

Problem _problemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Problem();
  object.answerIndex = reader.readLong(offsets[0]);
  object.choices = reader.readStringList(offsets[1]) ?? [];
  object.id = id;
  object.stem = reader.readString(offsets[3]);
  object.tags = reader.readStringList(offsets[4]) ?? [];
  object.updatedAt = reader.readDateTime(offsets[5]);
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
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _problemGetId(Problem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _problemGetLinks(Problem object) {
  return [];
}

void _problemAttach(IsarCollection<dynamic> col, Id id, Problem object) {
  object.id = id;
}

extension ProblemQueryWhereSort on QueryBuilder<Problem, Problem, QWhere> {
  QueryBuilder<Problem, Problem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
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
}

extension ProblemQueryFilter
    on QueryBuilder<Problem, Problem, QFilterCondition> {
  QueryBuilder<Problem, Problem, QAfterFilterCondition> answerIndexEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'answerIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> answerIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'answerIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> answerIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'answerIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> answerIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'answerIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> choicesElementEqualTo(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> choicesElementLessThan(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> choicesElementBetween(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> choicesElementEndsWith(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> choicesElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'choices',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> choicesElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'choices',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      choicesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'choices',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      choicesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'choices',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> choicesLengthEqualTo(
      int length) {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> choicesIsEmpty() {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> choicesIsNotEmpty() {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> choicesLengthLessThan(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> choicesLengthBetween(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> correctAnswerEqualTo(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> correctAnswerLessThan(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> correctAnswerBetween(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> stemEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> stemGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> stemLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> stemBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stem',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> stemStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> stemEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> stemContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> stemMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stem',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> stemIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stem',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> stemIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stem',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsElementEqualTo(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsElementGreaterThan(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsElementLessThan(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsElementBetween(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsElementStartsWith(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsElementEndsWith(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsElementContains(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsElementMatches(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition>
      tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsLengthEqualTo(
      int length) {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsIsEmpty() {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsIsNotEmpty() {
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsLengthLessThan(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsLengthGreaterThan(
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

  QueryBuilder<Problem, Problem, QAfterFilterCondition> tagsLengthBetween(
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
}

extension ProblemQueryObject
    on QueryBuilder<Problem, Problem, QFilterCondition> {}

extension ProblemQueryLinks
    on QueryBuilder<Problem, Problem, QFilterCondition> {}

extension ProblemQuerySortBy on QueryBuilder<Problem, Problem, QSortBy> {
  QueryBuilder<Problem, Problem, QAfterSortBy> sortByAnswerIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answerIndex', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByAnswerIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answerIndex', Sort.desc);
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

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByStem() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stem', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> sortByStemDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stem', Sort.desc);
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
}

extension ProblemQuerySortThenBy
    on QueryBuilder<Problem, Problem, QSortThenBy> {
  QueryBuilder<Problem, Problem, QAfterSortBy> thenByAnswerIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answerIndex', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByAnswerIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answerIndex', Sort.desc);
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

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByStem() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stem', Sort.asc);
    });
  }

  QueryBuilder<Problem, Problem, QAfterSortBy> thenByStemDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stem', Sort.desc);
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
}

extension ProblemQueryWhereDistinct
    on QueryBuilder<Problem, Problem, QDistinct> {
  QueryBuilder<Problem, Problem, QDistinct> distinctByAnswerIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'answerIndex');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByChoices() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'choices');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByCorrectAnswer(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctAnswer',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByStem(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stem', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<Problem, Problem, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
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

  QueryBuilder<Problem, int, QQueryOperations> answerIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'answerIndex');
    });
  }

  QueryBuilder<Problem, List<String>, QQueryOperations> choicesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'choices');
    });
  }

  QueryBuilder<Problem, String, QQueryOperations> correctAnswerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctAnswer');
    });
  }

  QueryBuilder<Problem, String, QQueryOperations> stemProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stem');
    });
  }

  QueryBuilder<Problem, List<String>, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<Problem, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
