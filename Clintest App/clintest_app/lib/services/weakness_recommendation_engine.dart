import 'dart:math';
import 'package:isar/isar.dart';
import '../models/study_progress.dart';
import '../models/wrong_answer.dart';
import '../models/srs_card.dart';
import 'database_service.dart';
import 'skill_assessment_service.dart';

/// 약점 기반 집중 학습 영역 추천 엔진
class WeaknessRecommendationEngine {
  static final Isar _isar = DatabaseService.isar;

  // 추천 가중치 매개변수
  static const double _recentWeightDecay = 0.7; // 시간에 따른 가중치 감소
  static const double _criticalAreaBoost = 2.0; // 중요 영역 가중치 증폭
  static const double _foundationAreaBoost = 1.5; // 기초 영역 가중치 증폭

  // =================
  // 메인 추천 엔진
  // =================

  /// 사용자 맞춤형 약점 영역 추천
  static Future<WeaknessRecommendation> generateWeaknessRecommendation(
    String userId, {
    int maxRecommendations = 5,
    int analysisWindowDays = 30,
  }) async {
    try {
      // 1. 현재 실력 평가 수행
      final skillAssessment = await SkillAssessmentService.assessOverallSkillLevel(userId);
      
      // 2. 약점 패턴 분석
      final weaknessPatterns = await _analyzeWeaknessPatterns(userId, analysisWindowDays);
      
      // 3. 학습 우선순위 계산
      final prioritizedWeaknesses = _calculateLearningPriorities(
        skillAssessment, 
        weaknessPatterns
      );
      
      // 4. 상위 추천 항목 선별
      final topRecommendations = prioritizedWeaknesses
          .take(maxRecommendations)
          .toList();
      
      // 5. 맞춤형 학습 전략 생성
      final learningStrategies = await _generateFocusedStrategies(
        userId, 
        topRecommendations, 
        skillAssessment
      );
      
      // 6. 학습 계획 수립
      final studyPlan = _createStudyPlan(topRecommendations, learningStrategies);
      
      return WeaknessRecommendation(
        userId: userId,
        overallWeaknessScore: _calculateOverallWeaknessScore(weaknessPatterns),
        prioritizedWeaknesses: topRecommendations,
        learningStrategies: learningStrategies,
        studyPlan: studyPlan,
        estimatedImprovementTime: _estimateImprovementTime(topRecommendations),
        confidenceLevel: _calculateRecommendationConfidence(weaknessPatterns),
        generatedAt: DateTime.now(),
        dataSourceSummary: _generateDataSummary(weaknessPatterns),
      );

    } catch (e) {
      print('WeaknessRecommendation: 추천 생성 오류 - $e');
      return _createDefaultRecommendation(userId);
    }
  }

  /// 실시간 약점 영역 감지
  static Future<List<WeaknessAlert>> detectRealtimeWeaknesses(
    String userId, {
    int recentSessionsCount = 10,
  }) async {
    final recentWrongAnswers = await _isar.wrongAnswers
        .where()
        .userIdEqualTo(userId)
        .sortByCreatedAt()
        .limit(recentSessionsCount * 5) // 세션당 평균 5개 오답 가정
        .findAll();
    
    final recentCards = await _isar.sRSCards
        .where()
        .userIdEqualTo(userId)
        .filter()
        .updatedAtGreaterThan(DateTime.now().subtract(const Duration(days: 7)))
        .findAll();
    
    final alerts = <WeaknessAlert>[];
    
    // 급격한 성능 저하 감지
    final performanceAlert = _detectPerformanceDecline(recentWrongAnswers);
    if (performanceAlert != null) alerts.add(performanceAlert);
    
    // 특정 영역 집중 실수 감지
    final areaAlerts = _detectAreaConcentratedMistakes(recentWrongAnswers);
    alerts.addAll(areaAlerts);
    
    // 기억 유지 문제 감지
    final retentionAlerts = _detectRetentionIssues(recentCards);
    alerts.addAll(retentionAlerts);
    
    return alerts;
  }

  // =================
  // 약점 패턴 분석
  // =================

  static Future<List<WeaknessPattern>> _analyzeWeaknessPatterns(
    String userId, 
    int analysisWindowDays,
  ) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: analysisWindowDays));
    
    // 데이터 수집
    final wrongAnswers = await _isar.wrongAnswers
        .where()
        .userIdEqualTo(userId)
        .filter()
        .createdAtGreaterThan(cutoffDate)
        .findAll();
    
    final studyProgresses = await _isar.studyProgress
        .where()
        .userIdEqualTo(userId)
        .filter()
        .updatedAtGreaterThan(cutoffDate)
        .findAll();
    
    final srsCards = await _isar.sRSCards
        .where()
        .userIdEqualTo(userId)
        .filter()
        .updatedAtGreaterThan(cutoffDate)
        .findAll();
    
    // 영역별 패턴 분석
    final patterns = <WeaknessPattern>[];
    
    // 1. 오답 빈도 패턴
    patterns.addAll(_analyzeWrongAnswerPatterns(wrongAnswers));
    
    // 2. 성과 저하 패턴
    patterns.addAll(_analyzePerformanceDeclinePatterns(studyProgresses));
    
    // 3. 기억 유지 패턴
    patterns.addAll(_analyzeRetentionPatterns(srsCards));
    
    // 4. 난이도별 성과 패턴
    patterns.addAll(_analyzeDifficultyPatterns(wrongAnswers, srsCards));
    
    return patterns;
  }

  static List<WeaknessPattern> _analyzeWrongAnswerPatterns(List<WrongAnswer> wrongAnswers) {
    if (wrongAnswers.isEmpty) return [];
    
    final patterns = <WeaknessPattern>[];
    final categoryGroups = <String, List<WrongAnswer>>{};
    
    // 카테고리별 그룹화
    for (var wrong in wrongAnswers) {
      final category = wrong.questionCategory ?? 'unknown';
      categoryGroups.putIfAbsent(category, () => []).add(wrong);
    }
    
    // 각 카테고리별 패턴 분석
    for (var entry in categoryGroups.entries) {
      final category = entry.key;
      final categoryWrongs = entry.value;
      
      if (categoryWrongs.length < 3) continue; // 최소 3개 이상의 오답
      
      // 빈도 기반 약점 점수 계산
      final frequency = categoryWrongs.length.toDouble();
      final recency = _calculateRecencyWeight(categoryWrongs);
      final severity = _calculateErrorSeverity(categoryWrongs);
      
      final weaknessScore = (frequency * recency * severity).clamp(0.0, 100.0);
      
      if (weaknessScore >= 30.0) { // 임계값 이상인 경우만
        patterns.add(WeaknessPattern(
          area: category,
          patternType: WeaknessPatternType.frequentErrors,
          severity: _scoreToSeverity(weaknessScore),
          score: weaknessScore,
          evidence: categoryWrongs.map((w) => w.id.toString()).toList(),
          detectedAt: DateTime.now(),
          description: '$category 영역에서 ${categoryWrongs.length}회 반복 오답',
        ));
      }
    }
    
    return patterns;
  }

  static List<WeaknessPattern> _analyzePerformanceDeclinePatterns(List<StudyProgress> progresses) {
    if (progresses.length < 3) return [];
    
    // 시간순 정렬
    progresses.sort((a, b) => (a.updatedAt ?? DateTime.now())
        .compareTo(b.updatedAt ?? DateTime.now()));
    
    final patterns = <WeaknessPattern>[];
    
    // 과목별 성과 추이 분석
    final subjectGroups = <String, List<StudyProgress>>{};
    for (var progress in progresses) {
      subjectGroups.putIfAbsent(progress.subjectCode, () => []).add(progress);
    }
    
    for (var entry in subjectGroups.entries) {
      final subject = entry.key;
      final subjectProgresses = entry.value;
      
      if (subjectProgresses.length < 3) continue;
      
      // 성과 하락 탐지
      final decline = _detectPerformanceDeclineInSubject(subjectProgresses);
      if (decline > 0.15) { // 15% 이상 하락
        patterns.add(WeaknessPattern(
          area: subject,
          patternType: WeaknessPatternType.performanceDecline,
          severity: decline > 0.3 ? WeaknessSeverity.high : WeaknessSeverity.medium,
          score: decline * 100,
          evidence: subjectProgresses.map((p) => p.id.toString()).toList(),
          detectedAt: DateTime.now(),
          description: '$subject 영역에서 ${(decline * 100).toStringAsFixed(1)}% 성과 하락',
        ));
      }
    }
    
    return patterns;
  }

  static List<WeaknessPattern> _analyzeRetentionPatterns(List<SRSCard> cards) {
    if (cards.isEmpty) return [];
    
    final patterns = <WeaknessPattern>[];
    
    // 기억 유지가 어려운 카드들 식별
    final poorRetentionCards = cards
        .where((c) => c.memoryStrength < 0.3 && c.totalReviews > 3)
        .toList();
    
    if (poorRetentionCards.length >= 5) {
      // 영역별 그룹화
      final areaGroups = <String, List<SRSCard>>{};
      for (var card in poorRetentionCards) {
        final area = card.medicalCategory ?? 'unknown';
        areaGroups.putIfAbsent(area, () => []).add(card);
      }
      
      for (var entry in areaGroups.entries) {
        final area = entry.key;
        final areaCards = entry.value;
        
        if (areaCards.length >= 3) {
          final averageRetention = areaCards
              .map((c) => c.memoryStrength)
              .reduce((a, b) => a + b) / areaCards.length;
          
          patterns.add(WeaknessPattern(
            area: area,
            patternType: WeaknessPatternType.poorRetention,
            severity: averageRetention < 0.2 ? WeaknessSeverity.high : WeaknessSeverity.medium,
            score: (1 - averageRetention) * 100,
            evidence: areaCards.map((c) => c.id.toString()).toList(),
            detectedAt: DateTime.now(),
            description: '$area 영역의 기억 유지 어려움 (평균 ${(averageRetention * 100).toStringAsFixed(1)}%)',
          ));
        }
      }
    }
    
    return patterns;
  }

  static List<WeaknessPattern> _analyzeDifficultyPatterns(
    List<WrongAnswer> wrongAnswers, 
    List<SRSCard> cards,
  ) {
    final patterns = <WeaknessPattern>[];
    
    // 난이도별 카드 성과 분석
    final difficultyGroups = <String, List<SRSCard>>{
      'easy': [],
      'medium': [],
      'hard': [],
    };
    
    for (var card in cards) {
      if (card.aiDifficultyScore < 0.4) {
        difficultyGroups['easy']!.add(card);
      } else if (card.aiDifficultyScore < 0.7) {
        difficultyGroups['medium']!.add(card);
      } else {
        difficultyGroups['hard']!.add(card);
      }
    }
    
    // 쉬운 문제에서도 실수가 많은 경우
    final easyCards = difficultyGroups['easy']!;
    if (easyCards.isNotEmpty) {
      final easySuccessRate = easyCards
          .where((c) => c.consecutiveCorrect > 0)
          .length / easyCards.length;
      
      if (easySuccessRate < 0.7) { // 쉬운 문제 성공률이 70% 미만
        patterns.add(WeaknessPattern(
          area: 'basic_concepts',
          patternType: WeaknessPatternType.basicConceptGaps,
          severity: easySuccessRate < 0.5 ? WeaknessSeverity.high : WeaknessSeverity.medium,
          score: (1 - easySuccessRate) * 100,
          evidence: easyCards.map((c) => c.id.toString()).toList(),
          detectedAt: DateTime.now(),
          description: '기본 개념 이해 부족 (쉬운 문제 성공률 ${(easySuccessRate * 100).toStringAsFixed(1)}%)',
        ));
      }
    }
    
    return patterns;
  }

  // =================
  // 우선순위 계산
  // =================

  static List<PrioritizedWeakness> _calculateLearningPriorities(
    SkillAssessment skillAssessment,
    List<WeaknessPattern> patterns,
  ) {
    final prioritizedList = <PrioritizedWeakness>[];
    
    for (var pattern in patterns) {
      // 기본 우선순위 점수 계산
      double priority = pattern.score;
      
      // 학습 단계에 따른 가중치 적용
      priority *= _getLearningPhaseMultiplier(skillAssessment.learningPhase, pattern);
      
      // 영역 중요도에 따른 가중치 적용
      priority *= _getAreaImportanceMultiplier(pattern.area);
      
      // 심각도에 따른 가중치 적용
      priority *= _getSeverityMultiplier(pattern.severity);
      
      // 패턴 유형에 따른 가중치 적용
      priority *= _getPatternTypeMultiplier(pattern.patternType);
      
      prioritizedList.add(PrioritizedWeakness(
        pattern: pattern,
        priority: priority.clamp(0.0, 100.0),
        urgencyLevel: _calculateUrgencyLevel(priority, pattern),
        estimatedEffort: _estimateRequiredEffort(pattern),
        expectedImprovement: _estimateExpectedImprovement(pattern),
      ));
    }
    
    // 우선순위별 정렬
    prioritizedList.sort((a, b) => b.priority.compareTo(a.priority));
    
    return prioritizedList;
  }

  // =================
  // 맞춤형 전략 생성
  // =================

  static Future<List<FocusedLearningStrategy>> _generateFocusedStrategies(
    String userId,
    List<PrioritizedWeakness> weaknesses,
    SkillAssessment skillAssessment,
  ) async {
    final strategies = <FocusedLearningStrategy>[];
    
    for (var weakness in weaknesses.take(3)) { // 상위 3개 약점
      final strategy = await _createStrategyForWeakness(weakness, skillAssessment);
      if (strategy != null) strategies.add(strategy);
    }
    
    return strategies;
  }

  static Future<FocusedLearningStrategy?> _createStrategyForWeakness(
    PrioritizedWeakness weakness,
    SkillAssessment skillAssessment,
  ) async {
    final pattern = weakness.pattern;
    
    switch (pattern.patternType) {
      case WeaknessPatternType.frequentErrors:
        return FocusedLearningStrategy(
          targetArea: pattern.area,
          strategyType: FocusedStrategyType.errorCorrection,
          approach: 'concentrated_practice',
          duration: Duration(days: _calculateDurationDays(weakness.estimatedEffort)),
          dailyTargets: {
            'problems': 15,
            'review_sessions': 2,
            'concept_study': 30, // 분
          },
          milestones: [
            StrategyMilestone(
              description: '${pattern.area} 기본 개념 복습 완료',
              targetDate: DateTime.now().add(const Duration(days: 3)),
              successMetric: 'concept_understanding',
            ),
            StrategyMilestone(
              description: '관련 문제 정답률 70% 이상 달성',
              targetDate: DateTime.now().add(const Duration(days: 7)),
              successMetric: 'accuracy_improvement',
            ),
          ],
          resources: [
            '${pattern.area} 핵심 개념 정리',
            '유사 문제 집중 연습',
            '오답 패턴 분석',
          ],
        );
        
      case WeaknessPatternType.performanceDecline:
        return FocusedLearningStrategy(
          targetArea: pattern.area,
          strategyType: FocusedStrategyType.performanceRecovery,
          approach: 'systematic_review',
          duration: Duration(days: _calculateDurationDays(weakness.estimatedEffort)),
          dailyTargets: {
            'problems': 10,
            'review_sessions': 3,
            'concept_study': 45,
          },
          milestones: [
            StrategyMilestone(
              description: '기존 학습 내용 재점검 완료',
              targetDate: DateTime.now().add(const Duration(days: 5)),
              successMetric: 'knowledge_review',
            ),
            StrategyMilestone(
              description: '성과 회복 (이전 수준의 90%)',
              targetDate: DateTime.now().add(const Duration(days: 14)),
              successMetric: 'performance_recovery',
            ),
          ],
          resources: [
            '기존 학습 자료 재검토',
            '단계별 난이도 조정',
            '정기적 성과 모니터링',
          ],
        );
        
      case WeaknessPatternType.poorRetention:
        return FocusedLearningStrategy(
          targetArea: pattern.area,
          strategyType: FocusedStrategyType.memoryStrengthening,
          approach: 'spaced_repetition',
          duration: Duration(days: _calculateDurationDays(weakness.estimatedEffort) * 2), // 장기간 필요
          dailyTargets: {
            'problems': 8,
            'review_sessions': 4,
            'concept_study': 25,
          },
          milestones: [
            StrategyMilestone(
              description: '기억 강화 기법 적용 시작',
              targetDate: DateTime.now().add(const Duration(days: 1)),
              successMetric: 'technique_adoption',
            ),
            StrategyMilestone(
              description: '기억 유지율 60% 이상 달성',
              targetDate: DateTime.now().add(const Duration(days: 21)),
              successMetric: 'retention_improvement',
            ),
          ],
          resources: [
            '간격 반복 학습 시스템',
            '연상법 및 기억술',
            '시각적 학습 자료',
          ],
        );
        
      case WeaknessPatternType.basicConceptGaps:
        return FocusedLearningStrategy(
          targetArea: pattern.area,
          strategyType: FocusedStrategyType.foundationBuilding,
          approach: 'ground_up_learning',
          duration: Duration(days: _calculateDurationDays(weakness.estimatedEffort) + 7), // 추가 시간
          dailyTargets: {
            'problems': 12,
            'review_sessions': 2,
            'concept_study': 60, // 더 많은 개념 학습
          },
          milestones: [
            StrategyMilestone(
              description: '기본 용어 및 개념 정리 완료',
              targetDate: DateTime.now().add(const Duration(days: 7)),
              successMetric: 'terminology_mastery',
            ),
            StrategyMilestone(
              description: '기초 문제 정답률 85% 이상 달성',
              targetDate: DateTime.now().add(const Duration(days: 14)),
              successMetric: 'basic_competency',
            ),
          ],
          resources: [
            '기초 개념 강의 자료',
            '단계별 학습 가이드',
            '기본 문제집',
          ],
        );
    }
  }

  // =================
  // 학습 계획 수립
  // =================

  static StudyPlan _createStudyPlan(
    List<PrioritizedWeakness> weaknesses,
    List<FocusedLearningStrategy> strategies,
  ) {
    final phases = <StudyPhase>[];
    
    // Phase 1: 긴급 약점 해결 (1-2주)
    final urgentWeaknesses = weaknesses
        .where((w) => w.urgencyLevel == UrgencyLevel.critical)
        .toList();
    
    if (urgentWeaknesses.isNotEmpty) {
      phases.add(StudyPhase(
        phaseNumber: 1,
        title: '긴급 약점 해결',
        duration: const Duration(days: 14),
        targetWeaknesses: urgentWeaknesses.map((w) => w.pattern.area).toList(),
        primaryStrategy: strategies.isNotEmpty ? strategies.first : null,
        goals: [
          '가장 심각한 약점 영역 집중 학습',
          '기본 정답률 60% 이상 달성',
          '반복 오답 패턴 해결',
        ],
        successCriteria: [
          '대상 영역 정답률 15% 이상 향상',
          '연속 오답 3회 이하로 감소',
          '기본 개념 이해도 80% 이상',
        ],
      ));
    }
    
    // Phase 2: 중요 약점 보강 (2-3주)
    final importantWeaknesses = weaknesses
        .where((w) => w.urgencyLevel == UrgencyLevel.high)
        .toList();
    
    if (importantWeaknesses.isNotEmpty) {
      phases.add(StudyPhase(
        phaseNumber: 2,
        title: '중요 약점 보강',
        duration: const Duration(days: 21),
        targetWeaknesses: importantWeaknesses.map((w) => w.pattern.area).toList(),
        primaryStrategy: strategies.length > 1 ? strategies[1] : null,
        goals: [
          '중요 영역 체계적 학습',
          '전반적 성과 향상',
          '지식 연결성 강화',
        ],
        successCriteria: [
          '대상 영역 정답률 70% 이상 달성',
          '기억 유지율 향상',
          '응용 문제 해결 능력 향상',
        ],
      ));
    }
    
    // Phase 3: 종합 정리 및 강화 (1-2주)
    phases.add(StudyPhase(
      phaseNumber: phases.length + 1,
      title: '종합 정리 및 강화',
      duration: const Duration(days: 14),
      targetWeaknesses: weaknesses.take(5).map((w) => w.pattern.area).toList(),
      primaryStrategy: null, // 종합 전략
      goals: [
        '전 영역 통합 복습',
        '약점 재발 방지',
        '전반적 수준 향상',
      ],
      successCriteria: [
        '모든 대상 영역 정답률 75% 이상',
        '약점 재발률 10% 이하',
        '종합 평가 점수 향상',
      ],
    ));
    
    return StudyPlan(
      planId: _generatePlanId(),
      userId: weaknesses.isNotEmpty ? 'user' : '', // 실제로는 userId 전달
      phases: phases,
      totalDuration: Duration(
        days: phases.map((p) => p.duration.inDays).reduce((a, b) => a + b)
      ),
      createdAt: DateTime.now(),
      estimatedCompletionDate: DateTime.now().add(
        Duration(days: phases.map((p) => p.duration.inDays).reduce((a, b) => a + b))
      ),
    );
  }

  // =================
  // 유틸리티 메서드들
  // =================

  static double _calculateRecencyWeight(List<WrongAnswer> wrongAnswers) {
    final now = DateTime.now();
    double totalWeight = 0.0;
    
    for (var wrong in wrongAnswers) {
      final daysSince = now.difference(wrong.createdAt).inDays;
      final weight = pow(_recentWeightDecay, daysSince / 7.0); // 주 단위 감소
      totalWeight += weight;
    }
    
    return totalWeight / wrongAnswers.length;
  }

  static double _calculateErrorSeverity(List<WrongAnswer> wrongAnswers) {
    // 오답의 심각도 평가 (현재는 단순화)
    return 1.0;
  }

  static WeaknessSeverity _scoreToSeverity(double score) {
    if (score >= 80) return WeaknessSeverity.critical;
    if (score >= 60) return WeaknessSeverity.high;
    if (score >= 40) return WeaknessSeverity.medium;
    return WeaknessSeverity.low;
  }

  static double _detectPerformanceDeclineInSubject(List<StudyProgress> progresses) {
    if (progresses.length < 2) return 0.0;
    
    final first = progresses.first.accuracyRate;
    final last = progresses.last.accuracyRate;
    
    return max(0.0, first - last);
  }

  static double _getLearningPhaseMultiplier(LearningPhase phase, WeaknessPattern pattern) {
    switch (phase) {
      case LearningPhase.foundation:
        return pattern.patternType == WeaknessPatternType.basicConceptGaps ? 2.0 : 1.0;
      case LearningPhase.development:
        return 1.2;
      case LearningPhase.specialization:
        return pattern.patternType == WeaknessPatternType.frequentErrors ? 1.5 : 1.0;
      case LearningPhase.mastery:
        return 0.8; // 숙련 단계에서는 약점 가중치 감소
    }
  }

  static double _getAreaImportanceMultiplier(String area) {
    // 영역별 중요도 반영
    if (area.toLowerCase().contains('emergency') || 
        area.toLowerCase().contains('pharmacology')) {
      return _criticalAreaBoost;
    }
    if (area.toLowerCase().contains('basic') || 
        area.toLowerCase().contains('foundation')) {
      return _foundationAreaBoost;
    }
    return 1.0;
  }

  static double _getSeverityMultiplier(WeaknessSeverity severity) {
    switch (severity) {
      case WeaknessSeverity.critical:
        return 2.0;
      case WeaknessSeverity.high:
        return 1.5;
      case WeaknessSeverity.medium:
        return 1.0;
      case WeaknessSeverity.low:
        return 0.7;
    }
  }

  static double _getPatternTypeMultiplier(WeaknessPatternType type) {
    switch (type) {
      case WeaknessPatternType.basicConceptGaps:
        return 2.0; // 기초 개념 부족은 최우선
      case WeaknessPatternType.frequentErrors:
        return 1.5;
      case WeaknessPatternType.performanceDecline:
        return 1.3;
      case WeaknessPatternType.poorRetention:
        return 1.0;
    }
  }

  static UrgencyLevel _calculateUrgencyLevel(double priority, WeaknessPattern pattern) {
    if (priority >= 80 || pattern.severity == WeaknessSeverity.critical) {
      return UrgencyLevel.critical;
    }
    if (priority >= 60) return UrgencyLevel.high;
    if (priority >= 40) return UrgencyLevel.medium;
    return UrgencyLevel.low;
  }

  static EffortLevel _estimateRequiredEffort(WeaknessPattern pattern) {
    switch (pattern.patternType) {
      case WeaknessPatternType.basicConceptGaps:
        return EffortLevel.high;
      case WeaknessPatternType.poorRetention:
        return EffortLevel.high;
      case WeaknessPatternType.performanceDecline:
        return EffortLevel.medium;
      case WeaknessPatternType.frequentErrors:
        return EffortLevel.medium;
    }
  }

  static double _estimateExpectedImprovement(WeaknessPattern pattern) {
    // 패턴 유형별 예상 개선도
    switch (pattern.patternType) {
      case WeaknessPatternType.frequentErrors:
        return 20.0; // 20% 향상 예상
      case WeaknessPatternType.performanceDecline:
        return 15.0;
      case WeaknessPatternType.poorRetention:
        return 25.0;
      case WeaknessPatternType.basicConceptGaps:
        return 30.0;
    }
  }

  static int _calculateDurationDays(EffortLevel effort) {
    switch (effort) {
      case EffortLevel.low:
        return 7;
      case EffortLevel.medium:
        return 14;
      case EffortLevel.high:
        return 21;
    }
  }

  static double _calculateOverallWeaknessScore(List<WeaknessPattern> patterns) {
    if (patterns.isEmpty) return 0.0;
    return patterns.map((p) => p.score).reduce((a, b) => a + b) / patterns.length;
  }

  static double _calculateRecommendationConfidence(List<WeaknessPattern> patterns) {
    if (patterns.isEmpty) return 0.0;
    
    final dataPoints = patterns.map((p) => p.evidence.length).reduce((a, b) => a + b);
    return min(1.0, dataPoints / 20.0); // 20개 증거를 100%로 설정
  }

  static String _estimateImprovementTime(List<PrioritizedWeakness> weaknesses) {
    if (weaknesses.isEmpty) return '정보 부족';
    
    final maxEffort = weaknesses
        .map((w) => w.estimatedEffort)
        .reduce((a, b) => a.index > b.index ? a : b);
    
    switch (maxEffort) {
      case EffortLevel.low:
        return '1-2주';
      case EffortLevel.medium:
        return '2-4주';
      case EffortLevel.high:
        return '4-8주';
    }
  }

  static String _generateDataSummary(List<WeaknessPattern> patterns) {
    final totalEvidence = patterns.map((p) => p.evidence.length).reduce((a, b) => a + b);
    return '총 ${patterns.length}개 패턴, $totalEvidence개 증거 데이터 기반';
  }

  static String _generatePlanId() {
    return 'plan_${DateTime.now().millisecondsSinceEpoch}';
  }

  // 알림 관련 메서드들
  static WeaknessAlert? _detectPerformanceDecline(List<WrongAnswer> recentWrongs) {
    // 간단한 구현 - 실제로는 더 복잡한 로직 필요
    if (recentWrongs.length >= 10) {
      return WeaknessAlert(
        alertType: AlertType.performanceDecline,
        severity: AlertSeverity.high,
        message: '최근 성과가 저하되고 있습니다',
        detectedAt: DateTime.now(),
        affectedAreas: ['general'],
      );
    }
    return null;
  }

  static List<WeaknessAlert> _detectAreaConcentratedMistakes(List<WrongAnswer> recentWrongs) {
    // 영역별 집중 실수 감지
    return [];
  }

  static List<WeaknessAlert> _detectRetentionIssues(List<SRSCard> recentCards) {
    // 기억 유지 문제 감지
    return [];
  }

  static WeaknessRecommendation _createDefaultRecommendation(String userId) {
    return WeaknessRecommendation(
      userId: userId,
      overallWeaknessScore: 0.0,
      prioritizedWeaknesses: [],
      learningStrategies: [],
      studyPlan: StudyPlan(
        planId: _generatePlanId(),
        userId: userId,
        phases: [],
        totalDuration: const Duration(days: 0),
        createdAt: DateTime.now(),
        estimatedCompletionDate: DateTime.now(),
      ),
      estimatedImprovementTime: '정보 부족',
      confidenceLevel: 0.0,
      generatedAt: DateTime.now(),
      dataSourceSummary: '데이터 없음',
    );
  }
}

// =================
// 데이터 클래스들
// =================

class WeaknessRecommendation {
  final String userId;
  final double overallWeaknessScore;
  final List<PrioritizedWeakness> prioritizedWeaknesses;
  final List<FocusedLearningStrategy> learningStrategies;
  final StudyPlan studyPlan;
  final String estimatedImprovementTime;
  final double confidenceLevel;
  final DateTime generatedAt;
  final String dataSourceSummary;

  WeaknessRecommendation({
    required this.userId,
    required this.overallWeaknessScore,
    required this.prioritizedWeaknesses,
    required this.learningStrategies,
    required this.studyPlan,
    required this.estimatedImprovementTime,
    required this.confidenceLevel,
    required this.generatedAt,
    required this.dataSourceSummary,
  });
}

class WeaknessPattern {
  final String area;
  final WeaknessPatternType patternType;
  final WeaknessSeverity severity;
  final double score;
  final List<String> evidence;
  final DateTime detectedAt;
  final String description;

  WeaknessPattern({
    required this.area,
    required this.patternType,
    required this.severity,
    required this.score,
    required this.evidence,
    required this.detectedAt,
    required this.description,
  });
}

class PrioritizedWeakness {
  final WeaknessPattern pattern;
  final double priority;
  final UrgencyLevel urgencyLevel;
  final EffortLevel estimatedEffort;
  final double expectedImprovement;

  PrioritizedWeakness({
    required this.pattern,
    required this.priority,
    required this.urgencyLevel,
    required this.estimatedEffort,
    required this.expectedImprovement,
  });
}

class FocusedLearningStrategy {
  final String targetArea;
  final FocusedStrategyType strategyType;
  final String approach;
  final Duration duration;
  final Map<String, int> dailyTargets;
  final List<StrategyMilestone> milestones;
  final List<String> resources;

  FocusedLearningStrategy({
    required this.targetArea,
    required this.strategyType,
    required this.approach,
    required this.duration,
    required this.dailyTargets,
    required this.milestones,
    required this.resources,
  });
}

class StrategyMilestone {
  final String description;
  final DateTime targetDate;
  final String successMetric;

  StrategyMilestone({
    required this.description,
    required this.targetDate,
    required this.successMetric,
  });
}

class StudyPlan {
  final String planId;
  final String userId;
  final List<StudyPhase> phases;
  final Duration totalDuration;
  final DateTime createdAt;
  final DateTime estimatedCompletionDate;

  StudyPlan({
    required this.planId,
    required this.userId,
    required this.phases,
    required this.totalDuration,
    required this.createdAt,
    required this.estimatedCompletionDate,
  });
}

class StudyPhase {
  final int phaseNumber;
  final String title;
  final Duration duration;
  final List<String> targetWeaknesses;
  final FocusedLearningStrategy? primaryStrategy;
  final List<String> goals;
  final List<String> successCriteria;

  StudyPhase({
    required this.phaseNumber,
    required this.title,
    required this.duration,
    required this.targetWeaknesses,
    required this.primaryStrategy,
    required this.goals,
    required this.successCriteria,
  });
}

class WeaknessAlert {
  final AlertType alertType;
  final AlertSeverity severity;
  final String message;
  final DateTime detectedAt;
  final List<String> affectedAreas;

  WeaknessAlert({
    required this.alertType,
    required this.severity,
    required this.message,
    required this.detectedAt,
    required this.affectedAreas,
  });
}

// Enums
enum WeaknessPatternType {
  frequentErrors,    // 빈발 오답
  performanceDecline, // 성과 저하
  poorRetention,     // 기억 유지 부족
  basicConceptGaps,  // 기초 개념 부족
}

enum WeaknessSeverity {
  low,
  medium,
  high,
  critical,
}

enum UrgencyLevel {
  low,
  medium,
  high,
  critical,
}

enum EffortLevel {
  low,
  medium,
  high,
}

enum FocusedStrategyType {
  errorCorrection,      // 오답 교정
  performanceRecovery,  // 성과 회복
  memoryStrengthening,  // 기억 강화
  foundationBuilding,   // 기초 구축
}

enum AlertType {
  performanceDecline,
  concentratedErrors,
  retentionIssues,
}

enum AlertSeverity {
  info,
  warning,
  high,
  critical,
}