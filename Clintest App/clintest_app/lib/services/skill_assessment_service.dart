import 'dart:math';
import 'package:isar/isar.dart';
import '../models/study_progress.dart';
import '../models/wrong_answer.dart';
import '../models/srs_card.dart';
import 'database_service.dart';

/// 사용자 실력 수준 평가 및 분석 서비스
class SkillAssessmentService {
  static final Isar _isar = DatabaseService.isar;

  // 의료/간호학 핵심 역량 영역
  static const Map<String, CompetencyArea> _competencyAreas = {
    'basic_nursing': CompetencyArea(
      name: '기본간호학',
      weight: 1.0,
      subAreas: ['vital_signs', 'nursing_procedures', 'patient_care', 'hygiene_care'],
      importance: CompetencyImportance.foundation,
    ),
    'adult_nursing': CompetencyArea(
      name: '성인간호학',
      weight: 1.2,
      subAreas: ['medical_surgical', 'critical_care', 'rehabilitation', 'chronic_disease'],
      importance: CompetencyImportance.core,
    ),
    'pediatric_nursing': CompetencyArea(
      name: '아동간호학',
      weight: 1.0,
      subAreas: ['child_development', 'pediatric_care', 'family_nursing', 'pediatric_emergency'],
      importance: CompetencyImportance.specialized,
    ),
    'maternal_nursing': CompetencyArea(
      name: '모성간호학',
      weight: 1.0,
      subAreas: ['pregnancy_care', 'labor_delivery', 'postpartum_care', 'newborn_care'],
      importance: CompetencyImportance.specialized,
    ),
    'psychiatric_nursing': CompetencyArea(
      name: '정신간호학',
      weight: 0.9,
      subAreas: ['mental_health', 'therapeutic_communication', 'crisis_intervention', 'psychiatric_disorders'],
      importance: CompetencyImportance.specialized,
    ),
    'community_nursing': CompetencyArea(
      name: '지역사회간호학',
      weight: 0.8,
      subAreas: ['public_health', 'health_promotion', 'community_assessment', 'epidemiology'],
      importance: CompetencyImportance.specialized,
    ),
    'nursing_management': CompetencyArea(
      name: '간호관리학',
      weight: 0.8,
      subAreas: ['leadership', 'quality_management', 'resource_management', 'team_coordination'],
      importance: CompetencyImportance.advanced,
    ),
    'pharmacology': CompetencyArea(
      name: '약리학',
      weight: 1.3,
      subAreas: ['drug_administration', 'medication_safety', 'pharmacokinetics', 'drug_interactions'],
      importance: CompetencyImportance.critical,
    ),
    'pathophysiology': CompetencyArea(
      name: '병태생리학',
      weight: 1.1,
      subAreas: ['disease_processes', 'body_systems', 'pathological_changes', 'clinical_manifestations'],
      importance: CompetencyImportance.foundation,
    ),
    'emergency_care': CompetencyArea(
      name: '응급간호',
      weight: 1.5,
      subAreas: ['emergency_assessment', 'life_support', 'trauma_care', 'disaster_nursing'],
      importance: CompetencyImportance.critical,
    ),
  };

  // =================
  // 실력 수준 종합 평가
  // =================

  /// 사용자의 종합 실력 수준 평가
  static Future<SkillAssessment> assessOverallSkillLevel(String userId) async {
    try {
      // 기본 데이터 수집
      final studyProgresses = await _isar.studyProgresses
          .where()
          .userIdEqualTo(userId)
          .findAll();
      
      final wrongAnswers = await _isar.wrongAnswers
          .where()
          .userIdEqualTo(userId)
          .findAll();
      
      final srsCards = await _isar.srsCards
          .where()
          .userIdEqualTo(userId)
          .findAll();

      // 영역별 실력 평가
      final areaAssessments = <String, AreaSkillLevel>{};
      for (var entry in _competencyAreas.entries) {
        final areaAssessment = await _assessCompetencyArea(
          userId, entry.key, entry.value, studyProgresses, wrongAnswers, srsCards
        );
        areaAssessments[entry.key] = areaAssessment;
      }

      // 종합 점수 계산
      final overallScore = _calculateOverallScore(areaAssessments);
      final skillLevel = _determineSkillLevel(overallScore, areaAssessments);

      // 강점/약점 분석
      final strengths = _identifyStrengths(areaAssessments);
      final weaknesses = _identifyWeaknesses(areaAssessments);

      // 학습 단계 결정
      final learningPhase = _determineLearningPhase(skillLevel, areaAssessments);

      // 추천 학습 전략
      final recommendedStrategies = _generateLearningStrategies(
        skillLevel, areaAssessments, learningPhase
      );

      return SkillAssessment(
        userId: userId,
        overallScore: overallScore,
        skillLevel: skillLevel,
        learningPhase: learningPhase,
        areaAssessments: areaAssessments,
        strengths: strengths,
        weaknesses: weaknesses,
        recommendedStrategies: recommendedStrategies,
        confidenceInterval: _calculateConfidenceInterval(areaAssessments),
        assessmentDate: DateTime.now(),
        dataPoints: studyProgresses.length + wrongAnswers.length,
      );

    } catch (e) {
      print('SkillAssessment: 평가 오류 - $e');
      return _createDefaultAssessment(userId);
    }
  }

  /// 특정 역량 영역 평가
  static Future<AreaSkillLevel> _assessCompetencyArea(
    String userId,
    String areaKey,
    CompetencyArea area,
    List<StudyProgress> allProgresses,
    List<WrongAnswer> allWrongAnswers,
    List<SRSCard> allCards,
  ) async {
    // 해당 영역의 데이터 필터링
    final areaProgresses = allProgresses.where((p) => 
      _isRelatedToArea(p.subjectCode, areaKey)
    ).toList();

    final areaWrongAnswers = allWrongAnswers.where((w) => 
      _isRelatedToArea(w.questionCategory ?? '', areaKey)
    ).toList();

    final areaCards = allCards.where((c) => 
      _isRelatedToArea(c.itemType, areaKey)
    ).toList();

    if (areaProgresses.isEmpty) {
      return AreaSkillLevel(
        areaName: area.name,
        score: 0.0,
        level: SkillLevel.beginner,
        confidence: 0.0,
        dataPoints: 0,
        subAreaScores: {},
        lastAssessed: DateTime.now(),
      );
    }

    // 성과 지표 계산
    final accuracyScore = _calculateAreaAccuracy(areaProgresses);
    final consistencyScore = _calculateConsistency(areaProgresses, areaCards);
    final progressionScore = _calculateProgression(areaProgresses);
    final retentionScore = _calculateRetention(areaCards);
    final difficultyScore = _calculateDifficultyHandling(areaWrongAnswers, areaCards);

    // 가중 평균 계산
    final weightedScore = (
      accuracyScore * 0.25 +
      consistencyScore * 0.20 +
      progressionScore * 0.20 +
      retentionScore * 0.20 +
      difficultyScore * 0.15
    ) * area.weight;

    // 하위 영역별 점수 계산
    final subAreaScores = <String, double>{};
    for (var subArea in area.subAreas) {
      subAreaScores[subArea] = _calculateSubAreaScore(subArea, areaProgresses, areaWrongAnswers);
    }

    return AreaSkillLevel(
      areaName: area.name,
      score: weightedScore.clamp(0.0, 100.0),
      level: _scoreToSkillLevel(weightedScore),
      confidence: _calculateAreaConfidence(areaProgresses.length, areaCards.length),
      dataPoints: areaProgresses.length + areaWrongAnswers.length,
      subAreaScores: subAreaScores,
      lastAssessed: DateTime.now(),
    );
  }

  // =================
  // 성과 지표 계산 메서드들
  // =================

  static double _calculateAreaAccuracy(List<StudyProgress> progresses) {
    if (progresses.isEmpty) return 0.0;
    
    final totalAccuracy = progresses
        .map((p) => p.accuracyRate)
        .reduce((a, b) => a + b);
    
    return (totalAccuracy / progresses.length) * 100;
  }

  static double _calculateConsistency(List<StudyProgress> progresses, List<SRSCard> cards) {
    if (progresses.isEmpty) return 0.0;
    
    // 정답률의 표준편차 계산 (낮을수록 일관성이 높음)
    final accuracies = progresses.map((p) => p.accuracyRate).toList();
    final mean = accuracies.reduce((a, b) => a + b) / accuracies.length;
    final variance = accuracies
        .map((acc) => pow(acc - mean, 2))
        .reduce((a, b) => a + b) / accuracies.length;
    final standardDeviation = sqrt(variance);
    
    // 일관성 점수: 표준편차가 낮을수록 높은 점수
    return max(0, (1 - standardDeviation * 2)) * 100;
  }

  static double _calculateProgression(List<StudyProgress> progresses) {
    if (progresses.length < 2) return 50.0; // 중간값 반환
    
    // 시간순 정렬
    progresses.sort((a, b) => (a.updatedAt ?? DateTime.now())
        .compareTo(b.updatedAt ?? DateTime.now()));
    
    // 초기와 최근 성과 비교
    final initialPerformance = progresses.take(progresses.length ~/ 3)
        .map((p) => p.accuracyRate)
        .reduce((a, b) => a + b) / (progresses.length ~/ 3);
    
    final recentPerformance = progresses.skip(progresses.length * 2 ~/ 3)
        .map((p) => p.accuracyRate)
        .reduce((a, b) => a + b) / (progresses.length - progresses.length * 2 ~/ 3);
    
    final improvement = (recentPerformance - initialPerformance) * 100;
    
    // -20% ~ +20% 범위를 0~100 점수로 변환
    return ((improvement + 20) / 40 * 100).clamp(0, 100);
  }

  static double _calculateRetention(List<SRSCard> cards) {
    if (cards.isEmpty) return 0.0;
    
    final totalRetention = cards
        .map((c) => c.memoryStrength)
        .reduce((a, b) => a + b);
    
    return (totalRetention / cards.length) * 100;
  }

  static double _calculateDifficultyHandling(List<WrongAnswer> wrongAnswers, List<SRSCard> cards) {
    if (cards.isEmpty) return 50.0;
    
    // 어려운 문제에서의 성과 분석
    final hardCards = cards.where((c) => c.aiDifficultyScore > 0.7).toList();
    if (hardCards.isEmpty) return 70.0; // 어려운 문제가 없으면 평균 점수
    
    final hardCardSuccess = hardCards
        .where((c) => c.consecutiveCorrect > 0)
        .length / hardCards.length;
    
    return hardCardSuccess * 100;
  }

  static double _calculateSubAreaScore(
    String subArea, 
    List<StudyProgress> progresses,
    List<WrongAnswer> wrongAnswers,
  ) {
    // 하위 영역별 성과 분석
    // 실제로는 더 정교한 분류 로직 필요
    final relatedProgresses = progresses.where((p) => 
      p.subjectCode.toLowerCase().contains(subArea.toLowerCase())).toList();
    
    if (relatedProgresses.isEmpty) return 50.0;
    
    return relatedProgresses
        .map((p) => p.accuracyRate * 100)
        .reduce((a, b) => a + b) / relatedProgresses.length;
  }

  // =================
  // 분석 및 분류 메서드들
  // =================

  static double _calculateOverallScore(Map<String, AreaSkillLevel> areaAssessments) {
    if (areaAssessments.isEmpty) return 0.0;
    
    double totalWeightedScore = 0.0;
    double totalWeight = 0.0;
    
    for (var entry in areaAssessments.entries) {
      final areaKey = entry.key;
      final assessment = entry.value;
      final area = _competencyAreas[areaKey]!;
      
      totalWeightedScore += assessment.score * area.weight;
      totalWeight += area.weight;
    }
    
    return totalWeight > 0 ? totalWeightedScore / totalWeight : 0.0;
  }

  static SkillLevel _determineSkillLevel(double overallScore, Map<String, AreaSkillLevel> areaAssessments) {
    // 기본 점수 기준
    if (overallScore >= 90) return SkillLevel.expert;
    if (overallScore >= 80) return SkillLevel.advanced;
    if (overallScore >= 70) return SkillLevel.competent;
    if (overallScore >= 60) return SkillLevel.intermediate;
    if (overallScore >= 40) return SkillLevel.novice;
    return SkillLevel.beginner;
  }

  static SkillLevel _scoreToSkillLevel(double score) {
    if (score >= 90) return SkillLevel.expert;
    if (score >= 80) return SkillLevel.advanced;
    if (score >= 70) return SkillLevel.competent;
    if (score >= 60) return SkillLevel.intermediate;
    if (score >= 40) return SkillLevel.novice;
    return SkillLevel.beginner;
  }

  static LearningPhase _determineLearningPhase(SkillLevel skillLevel, Map<String, AreaSkillLevel> areaAssessments) {
    final criticalAreas = areaAssessments.entries
        .where((e) => _competencyAreas[e.key]?.importance == CompetencyImportance.critical)
        .toList();
    
    final foundationAreas = areaAssessments.entries
        .where((e) => _competencyAreas[e.key]?.importance == CompetencyImportance.foundation)
        .toList();
    
    // 기초가 부족한 경우
    if (foundationAreas.any((e) => e.value.level == SkillLevel.beginner)) {
      return LearningPhase.foundation;
    }
    
    // 핵심 영역이 부족한 경우
    if (criticalAreas.any((e) => e.value.level.index < SkillLevel.competent.index)) {
      return LearningPhase.development;
    }
    
    // 전문화 단계
    if (skillLevel.index >= SkillLevel.competent.index) {
      return LearningPhase.specialization;
    }
    
    // 숙련 단계
    if (skillLevel.index >= SkillLevel.advanced.index) {
      return LearningPhase.mastery;
    }
    
    return LearningPhase.development;
  }

  static List<String> _identifyStrengths(Map<String, AreaSkillLevel> areaAssessments) {
    return areaAssessments.entries
        .where((e) => e.value.score >= 80.0)
        .map((e) => e.value.areaName)
        .toList();
  }

  static List<String> _identifyWeaknesses(Map<String, AreaSkillLevel> areaAssessments) {
    return areaAssessments.entries
        .where((e) => e.value.score < 60.0)
        .map((e) => e.value.areaName)
        .toList();
  }

  static List<LearningStrategy> _generateLearningStrategies(
    SkillLevel skillLevel,
    Map<String, AreaSkillLevel> areaAssessments,
    LearningPhase phase,
  ) {
    final strategies = <LearningStrategy>[];
    
    // 학습 단계별 전략
    switch (phase) {
      case LearningPhase.foundation:
        strategies.addAll([
          LearningStrategy(
            type: StrategyType.foundation,
            priority: StrategyPriority.high,
            description: '기본간호학과 병태생리학 집중 학습',
            targetAreas: ['basic_nursing', 'pathophysiology'],
            estimatedDuration: 30, // 일
          ),
          LearningStrategy(
            type: StrategyType.structured,
            priority: StrategyPriority.high,
            description: '순서대로 체계적인 학습 진행',
            targetAreas: ['basic_nursing'],
            estimatedDuration: 21,
          ),
        ]);
        break;
        
      case LearningPhase.development:
        strategies.addAll([
          LearningStrategy(
            type: StrategyType.weakness,
            priority: StrategyPriority.high,
            description: '약점 영역 집중 보강',
            targetAreas: _identifyWeaknesses(areaAssessments),
            estimatedDuration: 14,
          ),
          LearningStrategy(
            type: StrategyType.balanced,
            priority: StrategyPriority.medium,
            description: '균형잡힌 전 영역 학습',
            targetAreas: areaAssessments.keys.toList(),
            estimatedDuration: 45,
          ),
        ]);
        break;
        
      case LearningPhase.specialization:
        strategies.addAll([
          LearningStrategy(
            type: StrategyType.advanced,
            priority: StrategyPriority.high,
            description: '전문 영역 심화 학습',
            targetAreas: ['emergency_care', 'pharmacology'],
            estimatedDuration: 30,
          ),
          LearningStrategy(
            type: StrategyType.case_based,
            priority: StrategyPriority.medium,
            description: '사례 중심 문제 해결 학습',
            targetAreas: ['adult_nursing', 'pediatric_nursing'],
            estimatedDuration: 21,
          ),
        ]);
        break;
        
      case LearningPhase.mastery:
        strategies.addAll([
          LearningStrategy(
            type: StrategyType.maintenance,
            priority: StrategyPriority.medium,
            description: '수준 유지를 위한 정기 복습',
            targetAreas: _identifyStrengths(areaAssessments),
            estimatedDuration: 14,
          ),
          LearningStrategy(
            type: StrategyType.teaching,
            priority: StrategyPriority.low,
            description: '다른 사람 가르치기를 통한 학습',
            targetAreas: [],
            estimatedDuration: 30,
          ),
        ]);
        break;
    }
    
    return strategies;
  }

  static double _calculateAreaConfidence(int progressCount, int cardCount) {
    final totalData = progressCount + cardCount;
    if (totalData == 0) return 0.0;
    
    // 데이터 포인트가 많을수록 높은 신뢰도
    final dataConfidence = min(totalData / 50.0, 1.0); // 50개 데이터 포인트를 100%로 설정
    return dataConfidence * 100;
  }

  static ConfidenceInterval _calculateConfidenceInterval(Map<String, AreaSkillLevel> areaAssessments) {
    if (areaAssessments.isEmpty) {
      return ConfidenceInterval(lower: 0.0, upper: 100.0, level: 0.5);
    }
    
    final scores = areaAssessments.values.map((a) => a.score).toList();
    final mean = scores.reduce((a, b) => a + b) / scores.length;
    
    if (scores.length == 1) {
      return ConfidenceInterval(lower: mean - 15, upper: mean + 15, level: 0.7);
    }
    
    final variance = scores
        .map((score) => pow(score - mean, 2))
        .reduce((a, b) => a + b) / (scores.length - 1);
    final standardError = sqrt(variance / scores.length);
    
    // 95% 신뢰구간 (t-분포 근사)
    final marginOfError = standardError * 1.96;
    
    return ConfidenceInterval(
      lower: (mean - marginOfError).clamp(0.0, 100.0),
      upper: (mean + marginOfError).clamp(0.0, 100.0),
      level: 0.95,
    );
  }

  // =================
  // 유틸리티 메서드들
  // =================

  static bool _isRelatedToArea(String identifier, String areaKey) {
    final lowerIdentifier = identifier.toLowerCase();
    final area = _competencyAreas[areaKey];
    if (area == null) return false;
    
    // 영역명으로 매칭
    if (lowerIdentifier.contains(area.name.toLowerCase())) return true;
    
    // 하위 영역으로 매칭
    return area.subAreas.any((subArea) => 
      lowerIdentifier.contains(subArea.toLowerCase()) ||
      subArea.toLowerCase().contains(lowerIdentifier)
    );
  }

  static SkillAssessment _createDefaultAssessment(String userId) {
    return SkillAssessment(
      userId: userId,
      overallScore: 0.0,
      skillLevel: SkillLevel.beginner,
      learningPhase: LearningPhase.foundation,
      areaAssessments: {},
      strengths: [],
      weaknesses: [],
      recommendedStrategies: [],
      confidenceInterval: ConfidenceInterval(lower: 0.0, upper: 0.0, level: 0.0),
      assessmentDate: DateTime.now(),
      dataPoints: 0,
    );
  }
}

// =================
// 데이터 클래스들
// =================

class SkillAssessment {
  final String userId;
  final double overallScore; // 0-100
  final SkillLevel skillLevel;
  final LearningPhase learningPhase;
  final Map<String, AreaSkillLevel> areaAssessments;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<LearningStrategy> recommendedStrategies;
  final ConfidenceInterval confidenceInterval;
  final DateTime assessmentDate;
  final int dataPoints;

  SkillAssessment({
    required this.userId,
    required this.overallScore,
    required this.skillLevel,
    required this.learningPhase,
    required this.areaAssessments,
    required this.strengths,
    required this.weaknesses,
    required this.recommendedStrategies,
    required this.confidenceInterval,
    required this.assessmentDate,
    required this.dataPoints,
  });
}

class AreaSkillLevel {
  final String areaName;
  final double score; // 0-100
  final SkillLevel level;
  final double confidence; // 0-100
  final int dataPoints;
  final Map<String, double> subAreaScores;
  final DateTime lastAssessed;

  AreaSkillLevel({
    required this.areaName,
    required this.score,
    required this.level,
    required this.confidence,
    required this.dataPoints,
    required this.subAreaScores,
    required this.lastAssessed,
  });
}

class CompetencyArea {
  final String name;
  final double weight; // 중요도 가중치
  final List<String> subAreas;
  final CompetencyImportance importance;

  const CompetencyArea({
    required this.name,
    required this.weight,
    required this.subAreas,
    required this.importance,
  });
}

class LearningStrategy {
  final StrategyType type;
  final StrategyPriority priority;
  final String description;
  final List<String> targetAreas;
  final int estimatedDuration; // 일

  LearningStrategy({
    required this.type,
    required this.priority,
    required this.description,
    required this.targetAreas,
    required this.estimatedDuration,
  });
}

class ConfidenceInterval {
  final double lower;
  final double upper;
  final double level; // 0.0-1.0

  ConfidenceInterval({
    required this.lower,
    required this.upper,
    required this.level,
  });
}

enum SkillLevel {
  beginner,    // 초급 (0-40)
  novice,      // 초보 (40-60)
  intermediate, // 중급 (60-70)
  competent,   // 숙련 (70-80)
  advanced,    // 고급 (80-90)
  expert,      // 전문가 (90-100)
}

enum LearningPhase {
  foundation,     // 기초 단계
  development,    // 발전 단계
  specialization, // 전문화 단계
  mastery,        // 숙련 단계
}

enum CompetencyImportance {
  critical,     // 생명과 직결
  foundation,   // 기본 필수
  core,         // 핵심 역량
  specialized,  // 전문 영역
  advanced,     // 고급 역량
}

enum StrategyType {
  foundation,   // 기초 학습
  weakness,     // 약점 보강
  balanced,     // 균형 학습
  advanced,     // 심화 학습
  structured,   // 체계적 학습
  case_based,   // 사례 중심
  maintenance,  // 유지 학습
  teaching,     // 교수 학습
}

enum StrategyPriority {
  high,   // 높음
  medium, // 보통
  low,    // 낮음
}