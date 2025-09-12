import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;
  
  late String name;
  late String email;
  late String studentId; // 학번
  late String school; // 간호학과 학교
  late int grade; // 학년
  
  DateTime? createdAt;
  DateTime? updatedAt;
  
  // 의학/간호학 분야 선택
  String? selectedField; // 'medicine' or 'nursing'
  
  // 생성자
  User();
  
  User.create({
    required this.name,
    required this.email,
    required this.studentId,
    required this.school,
    required this.grade,
    this.selectedField,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }
}