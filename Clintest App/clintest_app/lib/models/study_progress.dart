import 'package:isar/isar.dart';

part 'study_progress.g.dart';

@collection
class StudyProgress {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String userId;
  @Index()
  late String subjectCode;
  
  int totalQuestions = 0;
  int attemptedQuestions = 0;
  int correctAnswers = 0;
  double accuracyRate = 0.0;
  int studyTimeSeconds = 0;
  int streakDays = 0;
  
  DateTime? lastStudyDate;
  DateTime? createdAt;
  DateTime? updatedAt;
  
  StudyProgress();
  
  StudyProgress.create({
    required this.userId,
    required this.subjectCode,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }
  
  // 진도율 계산
  double get progressRate {
    if (totalQuestions == 0) return 0.0;
    return attemptedQuestions / totalQuestions;
  }
  
  // 학습 시간을 시간/분/초로 포맷팅
  String get formattedStudyTime {
    final hours = studyTimeSeconds ~/ 3600;
    final minutes = (studyTimeSeconds % 3600) ~/ 60;
    final seconds = studyTimeSeconds % 60;
    
    if (hours > 0) {
      return '$hours시간 $minutes분';
    } else if (minutes > 0) {
      return '$minutes분 $seconds초';
    } else {
      return '$seconds초';
    }
  }
}