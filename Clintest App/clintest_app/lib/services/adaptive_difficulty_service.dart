import 'dart:math';
import 'package:isar/isar.dart';
import '../models/study_progress.dart';
import '../models/wrong_answer.dart';
import 'database_service.dart';

/// 개인별 문제 난이도 자동 조정 시스템
class AdaptiveDifficultyService {
  static final Isar _isar = DatabaseService.isar;

  // 난이도 조정 매개변수
  static const double _difficultyStepSize = 0.05; // 한 번에 조정할 난이도 크기
  static const double _maxDifficultyChange = 0.2; // 최대 난이도 변화량
  static const int _minDataPoints = 5; // 조정을 위한 최소 데이터 포인트
  static const double _targetAccuracy = 0.75; // 목표 정답률 75%
  static const double _accuracyTolerance = 0.1; // 정답률 허용 범위 ±10%

  // 난이도 레벨 정의
  static const Map<DifficultyLevel, DifficultyConfig> _difficultyConfigs = {
    DifficultyLevel.beginner: DifficultyConfig(
      range: DifficultyRange(min: 0.0, max: 0.3),
      targetAccuracy: 0.80,
      stepSize: 0.03,
      description: '초급 - 기본 개념과 간단한 적용',
    ),
    DifficultyLevel.novice: DifficultyConfig(
      range: DifficultyRange(min: 0.3, max: 0.5),
      targetAccuracy: 0.75,
      stepSize: 0.04,
      description: '초보 - 개념 이해와 기본 응용',
    ),
    DifficultyLevel.intermediate: DifficultyConfig(
      range: DifficultyRange(min: 0.5, max: 0.7),
      targetAccuracy: 0.70,
      stepSize: 0.05,
      description: '중급 - 복합 개념과 분석적 사고',
    ),
    DifficultyLevel.advanced: DifficultyConfig(
      range: DifficultyRange(min: 0.7, max: 0.85),
      targetAccuracy: 0.65,
      stepSize: 0.04,
      description: '고급 - 심화 분석과 판단력',
    ),
    DifficultyLevel.expert: DifficultyConfig(
      range: DifficultyRange(min: 0.85, max: 1.0),
      targetAccuracy: 0.60,
      stepSize: 0.03,
      description: '전문가 - 복잡한 임상 판단과 종합적 사고',
    ),
  };

  // =================
  // 메인 난이도 조정 메서드
  // =================

  /// 사용자별 현재 적정 난이도 계산
  static Future<UserDifficultyProfile> calculateCurrentDifficultyProfile(
    String userId, {
    int analysisWindowDays = 14,
  }) async {
    try {
      // 최근 데이터 수집
      final recentData = await _collectRecentPerformanceData(userId, analysisWindowDays);
      
      if (recentData.totalQuestions < _minDataPoints) {
        return _createInitialDifficultyProfile(userId);
      }

      // 영역별 난이도 분석
      final areaProfiles = <String, AreaDifficultyProfile>{};
      for (var area in recentData.performanceByArea.keys) {
        final areaPerformance = recentData.performanceByArea[area]!;
        final areaDifficulty = await _calculateAreaDifficulty(userId, area, areaPerformance);
        areaProfiles[area] = areaDifficulty;
      }

      // 전체 적정 난이도 계산
      final overallDifficulty = _calculateOverallDifficulty(areaProfiles);

      // 학습 궤도 분석
      final learningTrajectory = _analyzeLearningTrajectory(recentData);

      // 적응 속도 계산
      final adaptationRate = _calculateAdaptationRate(recentData);

      return UserDifficultyProfile(
        userId: userId,
        currentDifficultyLevel: _difficultyToLevel(overallDifficulty.currentDifficulty),
        currentDifficulty: overallDifficulty.currentDifficulty,
        targetDifficulty: overallDifficulty.targetDifficulty,
        areaProfiles: areaProfiles,
        learningTrajectory: learningTrajectory,
        adaptationRate: adaptationRate,
        confidence: overallDifficulty.confidence,
        lastUpdated: DateTime.now(),
        dataQuality: _assessDataQuality(recentData),
      );

    } catch (e) {
      print('AdaptiveDifficulty: 프로필 계산 오류 - $e');
      return _createInitialDifficultyProfile(userId);
    }
  }

  /// 다음 문제의 최적 난이도 추천
  static Future<DifficultyRecommendation> recommendNextQuestionDifficulty(
    String userId,
    String subjectArea, {
    List<double>? recentAccuracies,
    int? responseTime,
    String? lastQuestionDifficulty,
  }) async {
    // 사용자 난이도 프로필 로드
    final profile = await calculateCurrentDifficultyProfile(userId);
    final areaProfile = profile.areaProfiles[subjectArea];
    
    if (areaProfile == null) {
      return _createDefaultRecommendation(subjectArea);
    }

    // 실시간 성과 반영
    double adjustedDifficulty = areaProfile.currentDifficulty;
    
    if (recentAccuracies != null && recentAccuracies.isNotEmpty) {
      adjustedDifficulty = _adjustForRecentPerformance(
        adjustedDifficulty, 
        recentAccuracies, 
        areaProfile.targetAccuracy
      );
    }

    // 응답 시간 반영
    if (responseTime != null) {
      adjustedDifficulty = _adjustForResponseTime(adjustedDifficulty, responseTime);
    }

    // 학습 궤도 반영
    adjustedDifficulty = _adjustForLearningTrajectory(
      adjustedDifficulty, 
      profile.learningTrajectory
    );

    // 적응 속도 반영
    adjustedDifficulty = _adjustForAdaptationRate(
      adjustedDifficulty, 
      profile.adaptationRate
    );

    // 범위 제한 및 검증
    adjustedDifficulty = _validateAndClampDifficulty(
      adjustedDifficulty, 
      areaProfile.currentDifficulty
    );

    // 문제 유형별 추천 생성
    final questionTypes = _recommendQuestionTypes(adjustedDifficulty, subjectArea);

    return DifficultyRecommendation(
      recommendedDifficulty: adjustedDifficulty,
      difficultyLevel: _difficultyToLevel(adjustedDifficulty),
      confidenceScore: areaProfile.confidence,
      recommendedQuestionTypes: questionTypes,
      adjustmentReason: _generateAdjustmentReason(
        areaProfile.currentDifficulty, 
        adjustedDifficulty,
        recentAccuracies,
        responseTime,
      ),
      estimatedAccuracy: _estimateSuccessProbability(adjustedDifficulty, profile),
      learningBenefit: _calculateLearningBenefit(adjustedDifficulty, areaProfile),
      generatedAt: DateTime.now(),
    );
  }

  /// 성과 기반 실시간 난이도 업데이트
  static Future<DifficultyUpdate> updateDifficultyBasedOnPerformance(
    String userId,
    String subjectArea,
    bool wasCorrect,
    double questionDifficulty, {
    int? responseTimeMs,
    String? questionType,
  }) async {
    try {
      // 현재 프로필 로드
      final profile = await calculateCurrentDifficultyProfile(userId);
      final areaProfile = profile.areaProfiles[subjectArea];
      
      if (areaProfile == null) {
        return DifficultyUpdate(
          userId: userId,
          area: subjectArea,
          oldDifficulty: 0.5,
          newDifficulty: 0.5,
          adjustmentMagnitude: 0.0,
          reason: '초기 프로필 생성',
          confidence: 0.5,
          updatedAt: DateTime.now(),
        );
      }

      // 성과 기반 조정 계산
      final adjustment = _calculatePerformanceAdjustment(
        wasCorrect, 
        questionDifficulty,
        areaProfile.currentDifficulty,
        responseTimeMs,
      );

      // 새로운 난이도 계산
      final newDifficulty = (areaProfile.currentDifficulty + adjustment.magnitude)
          .clamp(0.0, 1.0);

      // 조정 내역 기록
      await _recordDifficultyAdjustment(
        userId, 
        subjectArea, 
        areaProfile.currentDifficulty, 
        newDifficulty, 
        adjustment
      );

      return DifficultyUpdate(
        userId: userId,
        area: subjectArea,
        oldDifficulty: areaProfile.currentDifficulty,
        newDifficulty: newDifficulty,
        adjustmentMagnitude: adjustment.magnitude,
        reason: adjustment.reason,
        confidence: min(1.0, areaProfile.confidence + 0.05), // 신뢰도 점진 증가
        updatedAt: DateTime.now(),
      );

    } catch (e) {
      print('AdaptiveDifficulty: 업데이트 오류 - $e');
      return DifficultyUpdate(
        userId: userId,
        area: subjectArea,
        oldDifficulty: 0.5,
        newDifficulty: 0.5,
        adjustmentMagnitude: 0.0,
        reason: '오류 발생',
        confidence: 0.0,
        updatedAt: DateTime.now(),
      );
    }
  }

  // =================
  // 데이터 분석 메서드
  // =================

  static Future<PerformanceData> _collectRecentPerformanceData(
    String userId, 
    int windowDays,
  ) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: windowDays));
    
    // 학습 진행 데이터
    final studyProgresses = await _isar.studyProgresses
        .where()
        .userIdEqualTo(userId)
        .filter()
        .updatedAtGreaterThan(cutoffDate)
        .findAll();
    
    // 오답 데이터
    final wrongAnswers = await _isar.wrongAnswers
        .where()
        .userIdEqualTo(userId)
        .filter()
        .createdAtGreaterThan(cutoffDate)
        .findAll();
    
    // SRS 카드 데이터
    final srsCards = await _isar.srsCards
        .where()
        .userIdEqualTo(userId)
        .filter()
        .updatedAtGreaterThan(cutoffDate)
        .findAll();

    // 데이터 분석
    final performanceByArea = <String, AreaPerformanceData>{};
    final accuracyHistory = <DateTime, double>{};
    final difficultyHistory = <DateTime, double>{};

    // 영역별 성과 계산
    for (var progress in studyProgresses) {
      final area = progress.subjectCode;
      final existing = performanceByArea[area];
      
      if (existing == null) {
        performanceByArea[area] = AreaPerformanceData(
          area: area,
          totalQuestions: progress.attemptedQuestions,
          correctAnswers: progress.correctAnswers,
          averageAccuracy: progress.accuracyRate,
          averageDifficulty: 0.5, // 기본값, 실제로는 계산 필요
          responseTimeAverage: 5000, // 기본값
          consistencyScore: 0.8, // 기본값
          improvementRate: 0.0,
        );
      } else {
        // 기존 데이터와 결합
        final totalQ = existing.totalQuestions + progress.attemptedQuestions;
        final totalC = existing.correctAnswers + progress.correctAnswers;
        
        performanceByArea[area] = AreaPerformanceData(
          area: area,
          totalQuestions: totalQ,
          correctAnswers: totalC,
          averageAccuracy: totalQ > 0 ? totalC / totalQ : 0.0,
          averageDifficulty: existing.averageDifficulty, // 유지
          responseTimeAverage: existing.responseTimeAverage, // 유지
          consistencyScore: existing.consistencyScore, // 유지
          improvementRate: existing.improvementRate, // 유지
        );
      }
      
      // 시간별 이력 추가
      if (progress.updatedAt != null) {
        accuracyHistory[progress.updatedAt!] = progress.accuracyRate;
      }
    }

    return PerformanceData(
      userId: userId,
      windowDays: windowDays,
      totalQuestions: studyProgresses.fold(0, (sum, p) => sum + p.attemptedQuestions),
      totalCorrect: studyProgresses.fold(0, (sum, p) => sum + p.correctAnswers),
      overallAccuracy: _calculateOverallAccuracy(studyProgresses),
      performanceByArea: performanceByArea,
      accuracyHistory: accuracyHistory,
      difficultyHistory: difficultyHistory,
      dataCollectedAt: DateTime.now(),
    );
  }

  static Future<AreaDifficultyProfile> _calculateAreaDifficulty(
    String userId,
    String area,
    AreaPerformanceData performance,
  ) async {
    // 현재 성과 기반 적정 난이도 계산
    final targetAccuracy = _getTargetAccuracyForArea(area);
    final currentAccuracy = performance.averageAccuracy;
    
    // 기본 난이도 조정
    double currentDifficulty = 0.5; // 기본값
    
    if (currentAccuracy > targetAccuracy + _accuracyTolerance) {
      // 너무 쉬움 - 난이도 상승
      currentDifficulty = min(0.9, currentDifficulty + 
          (currentAccuracy - targetAccuracy) * 0.5);
    } else if (currentAccuracy < targetAccuracy - _accuracyTolerance) {
      // 너무 어려움 - 난이도 하락
      currentDifficulty = max(0.1, currentDifficulty - 
          (targetAccuracy - currentAccuracy) * 0.5);
    }
    
    // 일관성 점수 반영
    final consistencyAdjustment = (performance.consistencyScore - 0.5) * 0.1;
    currentDifficulty = (currentDifficulty + consistencyAdjustment).clamp(0.0, 1.0);
    
    // 목표 난이도 계산 (점진적 상승)
    final targetDifficulty = min(1.0, currentDifficulty + 0.05);
    
    // 신뢰도 계산
    final confidence = _calculateAreaConfidence(performance);
    
    return AreaDifficultyProfile(
      area: area,
      currentDifficulty: currentDifficulty,
      targetDifficulty: targetDifficulty,
      targetAccuracy: targetAccuracy,
      actualAccuracy: currentAccuracy,
      consistencyScore: performance.consistencyScore,
      confidence: confidence,
      lastAdjusted: DateTime.now(),
      adjustmentHistory: [], // 실제로는 이력 관리 필요
    );
  }

  static OverallDifficultyProfile _calculateOverallDifficulty(
    Map<String, AreaDifficultyProfile> areaProfiles,
  ) {
    if (areaProfiles.isEmpty) {
      return OverallDifficultyProfile(
        currentDifficulty: 0.5,
        targetDifficulty: 0.5,
        confidence: 0.0,
      );
    }

    // 가중 평균 계산
    double totalWeightedCurrent = 0.0;
    double totalWeightedTarget = 0.0;
    double totalWeight = 0.0;
    double totalConfidence = 0.0;

    for (var profile in areaProfiles.values) {
      final weight = _getAreaWeight(profile.area);
      
      totalWeightedCurrent += profile.currentDifficulty * weight;
      totalWeightedTarget += profile.targetDifficulty * weight;
      totalWeight += weight;
      totalConfidence += profile.confidence;
    }

    return OverallDifficultyProfile(
      currentDifficulty: totalWeight > 0 ? totalWeightedCurrent / totalWeight : 0.5,
      targetDifficulty: totalWeight > 0 ? totalWeightedTarget / totalWeight : 0.5,
      confidence: totalConfidence / areaProfiles.length,
    );
  }

  static LearningTrajectory _analyzeLearningTrajectory(PerformanceData data) {
    if (data.accuracyHistory.length < 3) {
      return LearningTrajectory(
        trend: LearningTrend.stable,
        velocity: 0.0,
        acceleration: 0.0,
        plateauDetected: false,
      );
    }

    // 시간순 정렬
    final sortedHistory = data.accuracyHistory.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // 추세 분석
    final trend = _calculateTrend(sortedHistory.map((e) => e.value).toList());
    final velocity = _calculateVelocity(sortedHistory);
    final acceleration = _calculateAcceleration(sortedHistory);
    final plateauDetected = _detectPlateau(sortedHistory);

    return LearningTrajectory(
      trend: trend,
      velocity: velocity,
      acceleration: acceleration,
      plateauDetected: plateauDetected,
    );
  }

  static double _calculateAdaptationRate(PerformanceData data) {
    // 사용자가 새로운 난이도에 얼마나 빠르게 적응하는지 측정
    // 현재는 단순화된 버전
    if (data.performanceByArea.isEmpty) return 0.5;
    
    double totalAdaptation = 0.0;
    int areaCount = 0;
    
    for (var areaData in data.performanceByArea.values) {
      // 개선률을 적응 속도의 지표로 사용
      totalAdaptation += areaData.improvementRate.abs();
      areaCount++;
    }
    
    return areaCount > 0 ? (totalAdaptation / areaCount).clamp(0.1, 1.0) : 0.5;
  }

  // =================
  // 조정 계산 메서드
  // =================

  static double _adjustForRecentPerformance(
    double currentDifficulty,
    List<double> recentAccuracies,
    double targetAccuracy,
  ) {
    if (recentAccuracies.isEmpty) return currentDifficulty;
    
    final recentAverage = recentAccuracies.reduce((a, b) => a + b) / recentAccuracies.length;
    final deviation = recentAverage - targetAccuracy;
    
    // 최근 성과가 목표보다 높으면 난이도 상승, 낮으면 하락
    final adjustment = deviation * 0.1; // 10% 반영
    
    return (currentDifficulty + adjustment).clamp(0.0, 1.0);
  }

  static double _adjustForResponseTime(double currentDifficulty, int responseTimeMs) {
    const int targetResponseTime = 15000; // 15초
    const int fastResponseTime = 5000;    // 5초
    
    if (responseTimeMs < fastResponseTime) {
      // 매우 빠른 응답 - 난이도 상승
      return min(1.0, currentDifficulty + 0.02);
    } else if (responseTimeMs > targetResponseTime) {
      // 느린 응답 - 난이도 하락
      return max(0.0, currentDifficulty - 0.02);
    }
    
    return currentDifficulty;
  }

  static double _adjustForLearningTrajectory(
    double currentDifficulty,
    LearningTrajectory trajectory,
  ) {
    switch (trajectory.trend) {
      case LearningTrend.improving:
        // 성과 개선 중 - 점진적 난이도 상승
        return min(1.0, currentDifficulty + trajectory.velocity * 0.1);
      case LearningTrend.declining:
        // 성과 저하 중 - 난이도 하락
        return max(0.0, currentDifficulty + trajectory.velocity * 0.1);
      case LearningTrend.stable:
        // 안정적 - 작은 상승
        return min(1.0, currentDifficulty + 0.01);
    }
  }

  static double _adjustForAdaptationRate(double currentDifficulty, double adaptationRate) {
    // 빠른 적응자는 더 큰 난이도 변화를 줄 수 있음
    if (adaptationRate > 0.8) {
      return currentDifficulty; // 변화 없음 (이미 빠르게 적응)
    } else if (adaptationRate < 0.3) {
      // 느린 적응자는 보수적으로
      return currentDifficulty * 0.98; // 약간 하락
    }
    
    return currentDifficulty;
  }

  static PerformanceAdjustment _calculatePerformanceAdjustment(
    bool wasCorrect,
    double questionDifficulty,
    double currentDifficulty,
    int? responseTimeMs,
  ) {
    double adjustment = 0.0;
    String reason = '';
    
    if (wasCorrect) {
      // 정답인 경우
      if (questionDifficulty > currentDifficulty + 0.1) {
        // 예상보다 어려운 문제를 맞춤
        adjustment = _difficultyStepSize * 1.5;
        reason = '어려운 문제 정답으로 난이도 상승';
      } else {
        // 일반적인 정답
        adjustment = _difficultyStepSize;
        reason = '정답으로 난이도 소폭 상승';
      }
    } else {
      // 오답인 경우
      if (questionDifficulty < currentDifficulty - 0.1) {
        // 예상보다 쉬운 문제를 틀림
        adjustment = -_difficultyStepSize * 2.0;
        reason = '쉬운 문제 오답으로 난이도 대폭 하락';
      } else {
        // 일반적인 오답
        adjustment = -_difficultyStepSize;
        reason = '오답으로 난이도 소폭 하락';
      }
    }
    
    // 응답 시간 반영
    if (responseTimeMs != null) {
      if (responseTimeMs < 3000 && wasCorrect) {
        adjustment *= 1.2; // 빠른 정답은 조정 폭 증가
        reason += ' (빠른 응답으로 증폭)';
      } else if (responseTimeMs > 30000) {
        adjustment *= 0.8; // 너무 느린 응답은 조정 폭 감소
        reason += ' (느린 응답으로 완화)';
      }
    }
    
    // 최대 변화량 제한
    adjustment = adjustment.clamp(-_maxDifficultyChange, _maxDifficultyChange);
    
    return PerformanceAdjustment(
      magnitude: adjustment,
      reason: reason,
    );
  }

  // =================
  // 유틸리티 메서드
  // =================

  static double _validateAndClampDifficulty(double newDifficulty, double currentDifficulty) {
    // 한 번에 너무 큰 변화 방지
    final maxChange = _maxDifficultyChange;
    final clampedDifficulty = newDifficulty.clamp(
      currentDifficulty - maxChange,
      currentDifficulty + maxChange,
    );
    
    // 전체 범위 제한
    return clampedDifficulty.clamp(0.0, 1.0);
  }

  static List<QuestionType> _recommendQuestionTypes(double difficulty, String area) {
    final types = <QuestionType>[];
    
    if (difficulty < 0.3) {
      types.addAll([
        QuestionType.multipleChoice,
        QuestionType.trueFalse,
        QuestionType.basicConcept,
      ]);
    } else if (difficulty < 0.6) {
      types.addAll([
        QuestionType.multipleChoice,
        QuestionType.scenario,
        QuestionType.application,
      ]);
    } else if (difficulty < 0.8) {
      types.addAll([
        QuestionType.scenario,
        QuestionType.analysis,
        QuestionType.synthesis,
      ]);
    } else {
      types.addAll([
        QuestionType.complexScenario,
        QuestionType.criticalThinking,
        QuestionType.synthesis,
      ]);
    }
    
    return types;
  }

  static String _generateAdjustmentReason(
    double oldDifficulty,
    double newDifficulty,
    List<double>? recentAccuracies,
    int? responseTime,
  ) {
    final change = newDifficulty - oldDifficulty;
    
    if (change.abs() < 0.01) {
      return '현재 난이도 유지';
    } else if (change > 0) {
      return '성과 개선으로 난이도 상승 (+${(change * 100).toStringAsFixed(1)}%)';
    } else {
      return '어려움 감지로 난이도 하락 (${(change * 100).toStringAsFixed(1)}%)';
    }
  }

  static double _estimateSuccessProbability(double difficulty, UserDifficultyProfile profile) {
    // 사용자의 현재 수준과 문제 난이도를 비교하여 성공 확률 추정
    final skillGap = difficulty - profile.currentDifficulty;
    
    if (skillGap <= -0.2) return 0.9; // 매우 쉬움
    if (skillGap <= -0.1) return 0.8; // 쉬움
    if (skillGap <= 0.0) return 0.75;  // 적정
    if (skillGap <= 0.1) return 0.6;   // 약간 어려움
    if (skillGap <= 0.2) return 0.4;   // 어려움
    return 0.2; // 매우 어려움
  }

  static double _calculateLearningBenefit(double difficulty, AreaDifficultyProfile areaProfile) {
    // 해당 난이도의 문제를 풀었을 때 예상되는 학습 효과
    final optimalDifficulty = areaProfile.targetDifficulty;
    final distance = (difficulty - optimalDifficulty).abs();
    
    // 목표 난이도에 가까울수록 높은 학습 효과
    return max(0.0, 1.0 - distance * 2);
  }

  // Helper methods for calculations
  static double _getTargetAccuracyForArea(String area) {
    // 영역별 목표 정답률 (의료/간호학 특성 반영)
    if (area.toLowerCase().contains('emergency') || 
        area.toLowerCase().contains('critical')) {
      return 0.80; // 응급/중환자 - 높은 정확도 요구
    } else if (area.toLowerCase().contains('basic') || 
               area.toLowerCase().contains('fundamental')) {
      return 0.85; // 기본 영역 - 매우 높은 정확도 요구
    }
    return _targetAccuracy; // 기본 75%
  }

  static double _getAreaWeight(String area) {
    // 영역별 중요도 가중치
    if (area.toLowerCase().contains('emergency')) return 2.0;
    if (area.toLowerCase().contains('pharmacology')) return 1.8;
    if (area.toLowerCase().contains('basic')) return 1.5;
    return 1.0;
  }

  static double _calculateOverallAccuracy(List<StudyProgress> progresses) {
    if (progresses.isEmpty) return 0.0;
    
    final totalCorrect = progresses.fold(0, (sum, p) => sum + p.correctAnswers);
    final totalQuestions = progresses.fold(0, (sum, p) => sum + p.attemptedQuestions);
    
    return totalQuestions > 0 ? totalCorrect / totalQuestions : 0.0;
  }

  static double _calculateAreaConfidence(AreaPerformanceData performance) {
    // 데이터 점수와 일관성을 기반으로 신뢰도 계산
    final dataConfidence = min(1.0, performance.totalQuestions / 20.0);
    final consistencyConfidence = performance.consistencyScore;
    
    return (dataConfidence + consistencyConfidence) / 2;
  }

  static DataQuality _assessDataQuality(PerformanceData data) {
    if (data.totalQuestions >= 50) return DataQuality.high;
    if (data.totalQuestions >= 20) return DataQuality.medium;
    if (data.totalQuestions >= 10) return DataQuality.low;
    return DataQuality.insufficient;
  }

  static LearningTrend _calculateTrend(List<double> accuracies) {
    if (accuracies.length < 3) return LearningTrend.stable;
    
    // 간단한 선형 회귀로 추세 계산
    final n = accuracies.length;
    final x = List.generate(n, (i) => i.toDouble());
    final y = accuracies;
    
    final xMean = x.reduce((a, b) => a + b) / n;
    final yMean = y.reduce((a, b) => a + b) / n;
    
    double numerator = 0.0;
    double denominator = 0.0;
    
    for (int i = 0; i < n; i++) {
      numerator += (x[i] - xMean) * (y[i] - yMean);
      denominator += (x[i] - xMean) * (x[i] - xMean);
    }
    
    final slope = denominator != 0 ? numerator / denominator : 0.0;
    
    if (slope > 0.05) return LearningTrend.improving;
    if (slope < -0.05) return LearningTrend.declining;
    return LearningTrend.stable;
  }

  static double _calculateVelocity(List<MapEntry<DateTime, double>> history) {
    if (history.length < 2) return 0.0;
    
    final recent = history.last;
    final previous = history[history.length - 2];
    
    final timeDiff = recent.key.difference(previous.key).inDays;
    final accuracyDiff = recent.value - previous.value;
    
    return timeDiff > 0 ? accuracyDiff / timeDiff : 0.0;
  }

  static double _calculateAcceleration(List<MapEntry<DateTime, double>> history) {
    if (history.length < 3) return 0.0;
    
    // 속도 변화율 계산 (단순화)
    return 0.0;
  }

  static bool _detectPlateau(List<MapEntry<DateTime, double>> history) {
    if (history.length < 5) return false;
    
    // 최근 5개 데이터의 표준편차가 매우 작으면 정체기
    final recent5 = history.takeLast(5).map((e) => e.value).toList();
    final mean = recent5.reduce((a, b) => a + b) / 5;
    final variance = recent5.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / 5;
    
    return sqrt(variance) < 0.03; // 표준편차 3% 미만이면 정체
  }

  static DifficultyLevel _difficultyToLevel(double difficulty) {
    for (var entry in _difficultyConfigs.entries) {
      if (difficulty >= entry.value.range.min && difficulty < entry.value.range.max) {
        return entry.key;
      }
    }
    return DifficultyLevel.intermediate;
  }

  // Default/Initial creation methods
  static UserDifficultyProfile _createInitialDifficultyProfile(String userId) {
    return UserDifficultyProfile(
      userId: userId,
      currentDifficultyLevel: DifficultyLevel.novice,
      currentDifficulty: 0.4,
      targetDifficulty: 0.5,
      areaProfiles: {},
      learningTrajectory: LearningTrajectory(
        trend: LearningTrend.stable,
        velocity: 0.0,
        acceleration: 0.0,
        plateauDetected: false,
      ),
      adaptationRate: 0.5,
      confidence: 0.0,
      lastUpdated: DateTime.now(),
      dataQuality: DataQuality.insufficient,
    );
  }

  static DifficultyRecommendation _createDefaultRecommendation(String area) {
    return DifficultyRecommendation(
      recommendedDifficulty: 0.4,
      difficultyLevel: DifficultyLevel.novice,
      confidenceScore: 0.0,
      recommendedQuestionTypes: [QuestionType.multipleChoice, QuestionType.basicConcept],
      adjustmentReason: '초기 프로필 - 기본 난이도 적용',
      estimatedAccuracy: 0.75,
      learningBenefit: 0.8,
      generatedAt: DateTime.now(),
    );
  }

  static Future<void> _recordDifficultyAdjustment(
    String userId,
    String area,
    double oldDifficulty,
    double newDifficulty,
    PerformanceAdjustment adjustment,
  ) async {
    // 실제로는 데이터베이스에 조정 이력 저장
    print('Difficulty adjusted for $userId in $area: $oldDifficulty -> $newDifficulty (${adjustment.reason})');
  }
}

// =================
// 데이터 클래스들
// =================

class UserDifficultyProfile {
  final String userId;
  final DifficultyLevel currentDifficultyLevel;
  final double currentDifficulty;
  final double targetDifficulty;
  final Map<String, AreaDifficultyProfile> areaProfiles;
  final LearningTrajectory learningTrajectory;
  final double adaptationRate;
  final double confidence;
  final DateTime lastUpdated;
  final DataQuality dataQuality;

  UserDifficultyProfile({
    required this.userId,
    required this.currentDifficultyLevel,
    required this.currentDifficulty,
    required this.targetDifficulty,
    required this.areaProfiles,
    required this.learningTrajectory,
    required this.adaptationRate,
    required this.confidence,
    required this.lastUpdated,
    required this.dataQuality,
  });
}

class AreaDifficultyProfile {
  final String area;
  final double currentDifficulty;
  final double targetDifficulty;
  final double targetAccuracy;
  final double actualAccuracy;
  final double consistencyScore;
  final double confidence;
  final DateTime lastAdjusted;
  final List<DifficultyAdjustment> adjustmentHistory;

  AreaDifficultyProfile({
    required this.area,
    required this.currentDifficulty,
    required this.targetDifficulty,
    required this.targetAccuracy,
    required this.actualAccuracy,
    required this.consistencyScore,
    required this.confidence,
    required this.lastAdjusted,
    required this.adjustmentHistory,
  });
}

class DifficultyRecommendation {
  final double recommendedDifficulty;
  final DifficultyLevel difficultyLevel;
  final double confidenceScore;
  final List<QuestionType> recommendedQuestionTypes;
  final String adjustmentReason;
  final double estimatedAccuracy;
  final double learningBenefit;
  final DateTime generatedAt;

  DifficultyRecommendation({
    required this.recommendedDifficulty,
    required this.difficultyLevel,
    required this.confidenceScore,
    required this.recommendedQuestionTypes,
    required this.adjustmentReason,
    required this.estimatedAccuracy,
    required this.learningBenefit,
    required this.generatedAt,
  });
}

class DifficultyUpdate {
  final String userId;
  final String area;
  final double oldDifficulty;
  final double newDifficulty;
  final double adjustmentMagnitude;
  final String reason;
  final double confidence;
  final DateTime updatedAt;

  DifficultyUpdate({
    required this.userId,
    required this.area,
    required this.oldDifficulty,
    required this.newDifficulty,
    required this.adjustmentMagnitude,
    required this.reason,
    required this.confidence,
    required this.updatedAt,
  });
}

class PerformanceData {
  final String userId;
  final int windowDays;
  final int totalQuestions;
  final int totalCorrect;
  final double overallAccuracy;
  final Map<String, AreaPerformanceData> performanceByArea;
  final Map<DateTime, double> accuracyHistory;
  final Map<DateTime, double> difficultyHistory;
  final DateTime dataCollectedAt;

  PerformanceData({
    required this.userId,
    required this.windowDays,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.overallAccuracy,
    required this.performanceByArea,
    required this.accuracyHistory,
    required this.difficultyHistory,
    required this.dataCollectedAt,
  });
}

class AreaPerformanceData {
  final String area;
  final int totalQuestions;
  final int correctAnswers;
  final double averageAccuracy;
  final double averageDifficulty;
  final double responseTimeAverage;
  final double consistencyScore;
  final double improvementRate;

  AreaPerformanceData({
    required this.area,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.averageAccuracy,
    required this.averageDifficulty,
    required this.responseTimeAverage,
    required this.consistencyScore,
    required this.improvementRate,
  });
}

class LearningTrajectory {
  final LearningTrend trend;
  final double velocity;
  final double acceleration;
  final bool plateauDetected;

  LearningTrajectory({
    required this.trend,
    required this.velocity,
    required this.acceleration,
    required this.plateauDetected,
  });
}

class DifficultyConfig {
  final DifficultyRange range;
  final double targetAccuracy;
  final double stepSize;
  final String description;

  const DifficultyConfig({
    required this.range,
    required this.targetAccuracy,
    required this.stepSize,
    required this.description,
  });
}

class DifficultyRange {
  final double min;
  final double max;

  const DifficultyRange({
    required this.min,
    required this.max,
  });
}

class OverallDifficultyProfile {
  final double currentDifficulty;
  final double targetDifficulty;
  final double confidence;

  OverallDifficultyProfile({
    required this.currentDifficulty,
    required this.targetDifficulty,
    required this.confidence,
  });
}

class PerformanceAdjustment {
  final double magnitude;
  final String reason;

  PerformanceAdjustment({
    required this.magnitude,
    required this.reason,
  });
}

class DifficultyAdjustment {
  final double oldDifficulty;
  final double newDifficulty;
  final String reason;
  final DateTime adjustedAt;

  DifficultyAdjustment({
    required this.oldDifficulty,
    required this.newDifficulty,
    required this.reason,
    required this.adjustedAt,
  });
}

// Enums
enum DifficultyLevel {
  beginner,
  novice,
  intermediate,
  advanced,
  expert,
}

enum LearningTrend {
  improving,
  stable,
  declining,
}

enum DataQuality {
  insufficient,
  low,
  medium,
  high,
}

enum QuestionType {
  multipleChoice,
  trueFalse,
  basicConcept,
  scenario,
  application,
  analysis,
  synthesis,
  complexScenario,
  criticalThinking,
}