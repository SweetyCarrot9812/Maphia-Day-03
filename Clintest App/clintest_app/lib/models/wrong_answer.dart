import 'package:isar/isar.dart';

part 'wrong_answer.g.dart';

@collection
class WrongAnswer {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String userId;
  
  // 문제 정보
  @Index()
  late String questionId; // 원본 문제 ID (MedicalExam 또는 NursingExam의 id)
  late String questionType; // 'medical' 또는 'nursing'
  @Index()
  late String subjectCode;
  late String question;
  late List<String> choices;
  late String correctAnswer;
  String? explanation;
  List<String> tags = [];
  late String difficulty;
  
  // 오답 정보
  late String userAnswer; // 사용자가 선택한 오답
  DateTime? wrongDate; // 틀린 날짜
  @Index()
  late DateTime createdAt; // 생성 날짜
  String? questionCategory; // 문제 카테고리
  
  // 재학습 정보
  int reviewCount = 0; // 복습 횟수
  DateTime? lastReviewDate; // 마지막 복습 날짜
  DateTime? nextReviewDate; // 다음 복습 예정 날짜
  bool isResolved = false; // 해결됨 (연속 3회 정답 시)
  
  // 통계
  int totalAttempts = 1; // 총 시도 횟수
  int correctAttempts = 0; // 정답 횟수
  
  WrongAnswer();
  
  WrongAnswer.create({
    required this.userId,
    required this.questionId,
    required this.questionType,
    required this.subjectCode,
    required this.question,
    required this.choices,
    required this.correctAnswer,
    required this.userAnswer,
    String? examType,  // Add examType parameter
    this.explanation,
    this.tags = const [],
    required this.difficulty,
    this.questionCategory,
  }) {
    wrongDate = DateTime.now();
    createdAt = DateTime.now();
    nextReviewDate = calculateNextReviewDate();
  }
  
  // 정답률 계산
  double get accuracyRate {
    if (totalAttempts == 0) return 0.0;
    return correctAttempts / totalAttempts;
  }
  
  // 다음 복습 날짜 계산 (간격 반복 학습 - Spaced Repetition)
  DateTime calculateNextReviewDate() {
    final now = DateTime.now();
    
    switch (reviewCount) {
      case 0:
        return now.add(const Duration(days: 1)); // 1일 후
      case 1:
        return now.add(const Duration(days: 3)); // 3일 후  
      case 2:
        return now.add(const Duration(days: 7)); // 1주 후
      case 3:
        return now.add(const Duration(days: 14)); // 2주 후
      default:
        return now.add(const Duration(days: 30)); // 1개월 후
    }
  }
  
  // 복습 완료 처리
  void completeReview(bool wasCorrect) {
    reviewCount++;
    lastReviewDate = DateTime.now();
    totalAttempts++;
    
    if (wasCorrect) {
      correctAttempts++;
      nextReviewDate = calculateNextReviewDate();
      
      // 연속 3회 정답 시 해결로 표시
      if (correctAttempts >= 3) {
        isResolved = true;
      }
    } else {
      // 틀렸으면 복습 주기 리셋
      reviewCount = 0;
      nextReviewDate = calculateNextReviewDate();
    }
  }
  
  // 복습이 필요한지 확인
  bool get needsReview {
    if (isResolved) return false;
    if (nextReviewDate == null) return true;
    return DateTime.now().isAfter(nextReviewDate!);
  }
}