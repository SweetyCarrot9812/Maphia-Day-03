import 'package:isar/isar.dart';

part 'concept.g.dart';

@collection
class Concept {
  Id id = Isar.autoIncrement;
  
  late String title;
  
  String body = '';
  
  List<String> tags = [];
  
  DateTime updatedAt = DateTime.now();

  // Helper methods
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'tags': tags,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Concept fromJson(Map<String, dynamic> json) {
    final concept = Concept()
      ..id = json['id'] ?? Isar.autoIncrement
      ..title = json['title'] ?? ''
      ..body = json['body'] ?? ''
      ..tags = List<String>.from(json['tags'] ?? [])
      ..updatedAt = json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now();
    
    return concept;
  }

  // Create a copy with updated fields
  Concept copyWith({
    String? title,
    String? body,
    List<String>? tags,
    DateTime? updatedAt,
  }) {
    return Concept()
      ..id = id
      ..title = title ?? this.title
      ..body = body ?? this.body
      ..tags = tags ?? List.from(this.tags)
      ..updatedAt = updatedAt ?? DateTime.now();
  }

  @override
  String toString() {
    return 'Concept{id: $id, title: $title, body: ${body.length > 50 ? '${body.substring(0, 50)}...' : body}, tags: $tags, updatedAt: $updatedAt}';
  }
}