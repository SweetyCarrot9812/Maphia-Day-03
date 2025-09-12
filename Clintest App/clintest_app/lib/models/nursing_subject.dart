import 'package:isar/isar.dart';

part 'nursing_subject.g.dart';

@collection  
class NursingSubject {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String code; // ADULT, PEDIATRIC 등
  late String name; // 성인간호학, 아동간호학 등
  late String description; // 과목 설명
  late String category;
  late int order;
  late bool active;
  
  NursingSubject();
  
  NursingSubject.create({
    required this.code,
    required this.name,
    required this.description,
    required this.category,
    required this.order,
    this.active = true,
  });
}