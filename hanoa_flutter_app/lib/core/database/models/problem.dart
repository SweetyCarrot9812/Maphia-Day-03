import 'package:isar/isar.dart';

part 'problem.g.dart';

@collection
class Problem {
  Id id = Isar.autoIncrement;
  
  late String stem;
  
  List<String> choices = [];
  
  int answerIndex = 0;
  
  List<String> tags = [];
  
  DateTime updatedAt = DateTime.now();

  // Helper methods
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stem': stem,
      'choices': choices,
      'answerIndex': answerIndex,
      'tags': tags,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Problem fromJson(Map<String, dynamic> json) {
    final problem = Problem()
      ..id = json['id'] ?? Isar.autoIncrement
      ..stem = json['stem'] ?? ''
      ..choices = List<String>.from(json['choices'] ?? [])
      ..answerIndex = json['answerIndex'] ?? 0
      ..tags = List<String>.from(json['tags'] ?? [])
      ..updatedAt = json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now();
    
    return problem;
  }

  // Create a copy with updated fields
  Problem copyWith({
    String? stem,
    List<String>? choices,
    int? answerIndex,
    List<String>? tags,
    DateTime? updatedAt,
  }) {
    return Problem()
      ..id = id
      ..stem = stem ?? this.stem
      ..choices = choices ?? List.from(this.choices)
      ..answerIndex = answerIndex ?? this.answerIndex
      ..tags = tags ?? List.from(this.tags)
      ..updatedAt = updatedAt ?? DateTime.now();
  }

  // Get correct answer text
  String get correctAnswer {
    if (answerIndex >= 0 && answerIndex < choices.length) {
      return choices[answerIndex];
    }
    return '';
  }

  @override
  String toString() {
    return 'Problem{id: $id, stem: ${stem.length > 50 ? '${stem.substring(0, 50)}...' : stem}, choices: ${choices.length} choices, answerIndex: $answerIndex, tags: $tags, updatedAt: $updatedAt}';
  }
}