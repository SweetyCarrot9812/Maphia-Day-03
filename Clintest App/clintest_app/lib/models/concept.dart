import 'package:isar/isar.dart';

part 'concept.g.dart';

/// 의료/간호 개념 모델
@collection
class Concept {
  Id id = Isar.autoIncrement;

  /// 개념 코드 (고유 식별자)
  @Index(unique: true)
  late String conceptCode;

  /// 개념명
  late String conceptName;

  /// 개념 설명
  late String description;

  /// 소속 과목 코드
  late String subjectCode;

  /// 개념 카테고리 (기본, 심화, 응용 등)
  late String category;

  /// 난이도 (easy, medium, hard)
  late String difficulty;

  /// 중요도 (1-5)
  late int importance;

  /// 학습 순서
  late int learningOrder;

  /// 선수 개념들 (conceptCode 리스트)
  late List<String> prerequisites;

  /// 후속 개념들 (conceptCode 리스트)  
  late List<String> followUps;

  /// 관련 키워드/태그
  late List<String> keywords;

  /// AI 생성 설명 (GPT-5 Standard)
  String? aiExplanation;

  /// AI 설명 생성 날짜
  DateTime? aiGeneratedDate;

  /// 학습 완료 여부
  @Index()
  bool isLearned = false;

  /// 학습 완료 날짜
  DateTime? learnedDate;

  /// 복습 필요 여부
  bool needsReview = false;

  /// 다음 복습 예정일
  DateTime? nextReviewDate;

  /// 생성 날짜
  late DateTime createdAt;

  /// 수정 날짜
  late DateTime updatedAt;

  Concept();

  /// 생성자
  Concept.create({
    required this.conceptCode,
    required this.conceptName,
    required this.description,
    required this.subjectCode,
    required this.category,
    required this.difficulty,
    required this.importance,
    required this.learningOrder,
    this.prerequisites = const [],
    this.followUps = const [],
    this.keywords = const [],
    this.aiExplanation,
    this.isLearned = false,
    this.needsReview = false,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// 학습 완료 처리
  void markAsLearned() {
    isLearned = true;
    learnedDate = DateTime.now();
    needsReview = true;
    nextReviewDate = DateTime.now().add(const Duration(days: 1)); // 1일 후 첫 복습
    updatedAt = DateTime.now();
  }

  /// 복습 완료 처리
  void completeReview(bool wasSuccessful) {
    if (wasSuccessful) {
      // 성공적 복습: 다음 복습 간격 연장 (SRS 알고리즘)
      final daysSinceLastReview = nextReviewDate != null 
          ? DateTime.now().difference(nextReviewDate!).inDays 
          : 1;
      final nextInterval = (daysSinceLastReview * 2).clamp(1, 30);
      nextReviewDate = DateTime.now().add(Duration(days: nextInterval));
      needsReview = false;
    } else {
      // 실패: 1일 후 다시 복습
      nextReviewDate = DateTime.now().add(const Duration(days: 1));
      needsReview = true;
    }
    updatedAt = DateTime.now();
  }

  /// AI 설명 업데이트
  void updateAIExplanation(String explanation) {
    aiExplanation = explanation;
    aiGeneratedDate = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// 복습이 필요한지 확인
  bool get shouldReview {
    if (!isLearned || !needsReview) return false;
    if (nextReviewDate == null) return true;
    return DateTime.now().isAfter(nextReviewDate!);
  }

  /// 학습 준비가 되었는지 확인 (선수 개념 학습 완료)
  bool isReadyToLearn(List<Concept> allConcepts) {
    if (prerequisites.isEmpty) return true;
    
    final learnedConcepts = allConcepts
        .where((c) => c.isLearned)
        .map((c) => c.conceptCode)
        .toSet();
    
    return prerequisites.every((prereq) => learnedConcepts.contains(prereq));
  }
}