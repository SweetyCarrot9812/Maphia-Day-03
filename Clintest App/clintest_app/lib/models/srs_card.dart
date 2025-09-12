import 'dart:math' as math;
import 'package:isar/isar.dart';

part 'srs_card.g.dart';

/// SRS (간격 반복 시스템) 카드 모델
@collection
class SRSCard {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String userId;
  
  @Index()
  late String itemId; // 문제 ID 또는 개념 ID
  
  late String itemType; // 'problem', 'concept', 'procedure' 등
  
  // SRS 핵심 데이터
  int interval = 1; // 복습 간격 (일)
  double easeFactor = 2.5; // 난이도 인수
  int consecutiveCorrect = 0; // 연속 정답 횟수
  int totalReviews = 0; // 총 복습 횟수
  
  // 고급 SRS 데이터
  double aiDifficultyScore = 0.5; // AI가 평가한 난이도 (0.0-1.0)
  String? lastPerformance; // 'excellent', 'good', 'hard', 'again'
  int? lastResponseTimeMs; // 마지막 응답 시간 (밀리초)
  
  // 의료/간호학 특화 데이터
  String? medicalCategory; // 'critical', 'high', 'medium', 'basic'
  String? clinicalContext; // 'emergency', 'routine', 'diagnostic' 등
  List<String> relatedConcepts = []; // 연관 개념들
  
  // 개인화 데이터
  double personalDifficultyRating = 0.5; // 개인별 체감 난이도
  int streakCount = 0; // 연속 성공 스트릭
  DateTime? lastCorrectDate; // 마지막 정답 날짜
  DateTime? lastWrongDate; // 마지막 오답 날짜
  
  // 복습 스케줄링
  DateTime dueDate = DateTime.now();
  int priority = 0; // 복습 우선순위 (0-10)
  bool isOverdue = false; // 연체 여부
  
  // 메타데이터
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  
  SRSCard();
  
  /// 새 카드 생성
  SRSCard.create({
    required this.userId,
    required this.itemId,
    required this.itemType,
    this.aiDifficultyScore = 0.5,
    this.medicalCategory,
    this.clinicalContext,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
    dueDate = DateTime.now().add(Duration(days: interval));
  }
  
  // =================
  // 계산된 속성들
  // =================
  
  /// 다음 복습까지 남은 일수
  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }
  
  /// 연체된 일수
  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }
  
  /// 학습 성숙도 (0.0-1.0)
  double get maturityLevel {
    // 연속 정답 횟수와 총 복습 횟수를 기반으로 계산
    if (totalReviews == 0) return 0.0;
    
    double consistencyScore = consecutiveCorrect / totalReviews.clamp(1, 10);
    double experienceScore = (totalReviews / 20.0).clamp(0.0, 1.0);
    
    return (consistencyScore * 0.7 + experienceScore * 0.3).clamp(0.0, 1.0);
  }
  
  /// 기억 강도 추정 (0.0-1.0)
  double get memoryStrength {
    if (lastCorrectDate == null) return 0.1;
    
    // 마지막 정답 후 경과 시간
    int daysSinceCorrect = DateTime.now().difference(lastCorrectDate!).inDays;
    
    // 망각 곡선 적용: R = e^(-t/s)
    // s는 기억 강도 (ease factor와 연속 정답 횟수 기반)
    double memoryDecay = easeFactor * (1 + consecutiveCorrect * 0.1);
    double strength = math.exp(-daysSinceCorrect / memoryDecay);
    
    return strength.clamp(0.0, 1.0);
  }
  
  /// 복습 긴급도 (0.0-10.0)
  double get urgencyScore {
    double score = 0.0;
    
    // 연체 가중치
    if (isOverdue) {
      score += daysOverdue * 0.5;
    }
    
    // 난이도 가중치
    score += aiDifficultyScore * 2.0;
    score += personalDifficultyRating * 2.0;
    
    // 의료 중요도 가중치
    switch (medicalCategory) {
      case 'critical':
        score += 3.0;
        break;
      case 'high':
        score += 2.0;
        break;
      case 'medium':
        score += 1.0;
        break;
      default:
        score += 0.5;
    }
    
    // 최근 실패 가중치
    if (lastWrongDate != null) {
      int daysSinceWrong = DateTime.now().difference(lastWrongDate!).inDays;
      if (daysSinceWrong < 7) {
        score += (7 - daysSinceWrong) * 0.3;
      }
    }
    
    return score.clamp(0.0, 10.0);
  }
  
  // =================
  // SRS 로직 메서드들
  // =================
  
  /// 복습 결과 처리
  void processReviewResult({
    required bool isCorrect,
    required String performance, // 'excellent', 'good', 'hard', 'again'
    int? responseTimeMs,
  }) {
    updatedAt = DateTime.now();
    totalReviews++;
    lastPerformance = performance;
    lastResponseTimeMs = responseTimeMs;
    
    if (isCorrect) {
      consecutiveCorrect++;
      streakCount++;
      lastCorrectDate = DateTime.now();
      
      // 정답일 때 간격 증가
      _updateIntervalForCorrect(performance);
    } else {
      consecutiveCorrect = 0;
      streakCount = 0;
      lastWrongDate = DateTime.now();
      
      // 오답일 때 간격 감소
      _updateIntervalForIncorrect();
    }
    
    // 다음 복습 날짜 설정
    dueDate = DateTime.now().add(Duration(days: interval));
    isOverdue = false;
    
    // 우선순위 재계산
    priority = urgencyScore.round().clamp(0, 10);
  }
  
  /// 정답일 때 간격 업데이트
  void _updateIntervalForCorrect(String performance) {
    switch (performance) {
      case 'excellent': // 매우 쉬웠음
        interval = (interval * easeFactor * 1.3).round();
        easeFactor = (easeFactor + 0.15).clamp(1.3, 3.0);
        break;
      case 'good': // 적당했음
        interval = (interval * easeFactor).round();
        easeFactor = (easeFactor + 0.1).clamp(1.3, 3.0);
        break;
      case 'hard': // 어려웠지만 맞춤
        interval = (interval * easeFactor * 0.8).round();
        easeFactor = (easeFactor - 0.15).clamp(1.3, 3.0);
        break;
      default:
        interval = (interval * easeFactor).round();
    }
    
    // 최소 1일, 최대 365일 제한
    interval = interval.clamp(1, 365);
  }
  
  /// 오답일 때 간격 업데이트
  void _updateIntervalForIncorrect() {
    interval = 1; // 내일 다시 복습
    easeFactor = (easeFactor - 0.2).clamp(1.3, 3.0);
  }
  
  /// 개인 난이도 평가 업데이트
  void updatePersonalDifficulty(double userRating) {
    // 0.0 (매우 쉬움) ~ 1.0 (매우 어려움)
    personalDifficultyRating = userRating.clamp(0.0, 1.0);
    updatedAt = DateTime.now();
  }
  
  /// 의료 카테고리 설정
  void setMedicalCategory(String category) {
    medicalCategory = category;
    updatedAt = DateTime.now();
  }
  
  /// 연관 개념 추가
  void addRelatedConcept(String conceptId) {
    if (!relatedConcepts.contains(conceptId)) {
      relatedConcepts.add(conceptId);
      updatedAt = DateTime.now();
    }
  }
  
  /// 연체 상태 확인 및 업데이트
  void checkOverdueStatus() {
    isOverdue = DateTime.now().isAfter(dueDate);
    if (isOverdue) {
      priority = (priority + 1).clamp(0, 10);
    }
  }
}