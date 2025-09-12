import 'package:hive/hive.dart';

part 'word_model.g.dart';

@HiveType(typeId: 0)
class WordModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String english;

  @HiveField(2)
  final String korean;

  @HiveField(3)
  final String createdAt;

  @HiveField(4)
  final String status; // 'new', 'learning', 'mastered'

  @HiveField(5)
  String? pronunciation; // 발음

  @HiveField(6)
  List<String>? examples; // 예문

  @HiveField(7)
  DateTime? lastReviewed; // 마지막 복습 날짜

  WordModel({
    required this.id,
    required this.english,
    required this.korean,
    required this.createdAt,
    required this.status,
    this.pronunciation,
    this.examples,
    this.lastReviewed,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'],
      english: json['english'],
      korean: json['korean'],
      createdAt: json['createdAt'],
      status: json['status'],
      pronunciation: json['pronunciation'],
      examples: json['examples']?.cast<String>(),
      lastReviewed: json['lastReviewed'] != null 
          ? DateTime.parse(json['lastReviewed']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'english': english,
      'korean': korean,
      'createdAt': createdAt,
      'status': status,
      'pronunciation': pronunciation,
      'examples': examples,
      'lastReviewed': lastReviewed?.toIso8601String(),
    };
  }
}