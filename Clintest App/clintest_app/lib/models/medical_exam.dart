import 'package:isar/isar.dart';

part 'medical_exam.g.dart';

@collection
class MedicalExam {
  Id id = Isar.autoIncrement;
  
  late String question;
  late List<String> choices;
  late int correctAnswer;
  late String? answer;  // Optional answer field
  late String subject;
  late String subjectCode;  // Added missing field
  late String difficulty;
  late String explanation;
  late List<String> tags;   // Added missing field
  late int attempts;        // Added missing field
  late int correctCount;    // Added missing field
  late DateTime? lastAttempted;  // Added missing field
  late DateTime createdAt;
  late DateTime updatedAt;
  
  // Constructor
  MedicalExam();
  
  // Named constructor
  MedicalExam.create({
    required this.question,
    required this.choices,
    required this.correctAnswer,
    this.answer,  // Optional parameter
    required this.subject,
    this.subjectCode = '',
    required this.difficulty,
    required this.explanation,
    this.tags = const [],
    this.attempts = 0,
    this.correctCount = 0,
    this.lastAttempted,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }
}