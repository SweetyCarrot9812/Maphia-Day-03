import 'package:isar/isar.dart';

part 'medical_subject.g.dart';

@collection
class MedicalSubject {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String code; // BASIC_MEDICINE, INTERNAL_MEDICINE 등
  late String name; // 의학 기초, 내과 등
  late String description; // 과목 설명
  late String category; // clinical, basic 등
  late int order;
  late bool active;
  
  MedicalSubject();
  
  MedicalSubject.create({
    required this.code,
    required this.name,
    required this.description,
    required this.category,
    required this.order,
    this.active = true,
  });
}