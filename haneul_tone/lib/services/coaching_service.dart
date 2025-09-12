import 'dart:math';
import '../models/session_v2.dart';
import '../core/metrics/metrics_calculator.dart';
import '../core/audio/formant_analyzer.dart';
import 'formant_analysis_service.dart';

/// 목표 코칭 서비스
/// 
/// HaneulTone v1 고도화 - 개인화된 학습 코칭
/// 
/// Features:
/// - 1분 요약 리포트 생성
/// - 개인 맞춤 목표 설정
/// - 학습 진도 추적
/// - AI 기반 개선 제안
class CoachingService {
  static const String _version = '1.0.0';
  static const int _maxCoachingHistory = 100;

  /// 코칭 히스토리
  final List<CoachingCard> _coachingHistory = [];
  
  /// 사용자 학습 프로필
  UserLearningProfile? _userProfile;

  /// 코칭 카드 생성
  CoachingCard generateCoachingCard(SessionV2 session, {
    VowelStabilityStats? formantStats,
    List<SessionV2>? recentSessions,
  }) {
    final analysisResult = _analyzeSession(session, formantStats);
    final progressData = _calculateProgress(session, recentSessions ?? []);
    final goals = _generatePersonalizedGoals(analysisResult, progressData);
    final actionPlan = _createActionPlan(analysisResult, goals);

    final card = CoachingCard(
      id: _generateCardId(),
      sessionId: session.id,
      createdAt: DateTime.now(),
      analysisResult: analysisResult,
      progressData: progressData,
      goals: goals,
      actionPlan: actionPlan,
      estimatedPracticeTime: _estimatePracticeTime(goals),
      priority: _calculatePriority(analysisResult),
    );

    // 히스토리 관리
    _coachingHistory.add(card);
    if (_coachingHistory.length > _maxCoachingHistory) {
      _coachingHistory.removeAt(0);
    }

    // 사용자 프로필 업데이트
    _updateUserProfile(card);

    return card;
  }

  /// 1분 요약 리포트 생성
  QuickSummaryReport generateQuickSummary(SessionV2 session, {
    VowelStabilityStats? formantStats,
  }) {
    final metrics = session.metrics;
    if (metrics == null) {
      return QuickSummaryReport.empty();
    }

    // 핵심 지표 분석
    final overallGrade = _calculateOverallGrade(metrics);
    final strengths = _identifyStrengths(session, formantStats);
    final weaknesses = _identifyWeaknesses(session, formantStats);
    final keyInsight = _generateKeyInsight(metrics, formantStats);
    final nextAction = _suggestNextAction(weaknesses);

    return QuickSummaryReport(
      sessionId: session.id,
      duration: _calculateSessionDuration(session),
      overallGrade: overallGrade,
      overallScore: metrics.overallScore,
      strengths: strengths,
      weaknesses: weaknesses,
      keyInsight: keyInsight,
      nextAction: nextAction,
      practiceTime: _estimateQuickPracticeTime(weaknesses),
      createdAt: DateTime.now(),
    );
  }

  /// 세션 분석
  SessionAnalysisResult _analyzeSession(SessionV2 session, VowelStabilityStats? formantStats) {
    final metrics = session.metrics;
    if (metrics == null) {
      return SessionAnalysisResult.empty();
    }

    // 피치 정확도 분석
    final pitchAccuracy = _analyzePitchAccuracy(metrics.accuracyCents);
    
    // 안정성 분석
    final stability = _analyzeStability(metrics.stabilityCents);
    
    // 비브라토 분석
    final vibrato = _analyzeVibrato(metrics.vibratoRateHz, metrics.vibratoExtentCents);
    
    // 모음 안정성 분석 (포먼트)
    final vowelStability = _analyzeVowelStability(formantStats);
    
    // 음성화 비율 분석
    final voicing = _analyzeVoicing(metrics.voicedRatio);
    
    // 전체 평가
    final overall = _analyzeOverall(metrics.overallScore);

    return SessionAnalysisResult(
      pitchAccuracy: pitchAccuracy,
      stability: stability,
      vibrato: vibrato,
      vowelStability: vowelStability,
      voicing: voicing,
      overall: overall,
      detailedFeedback: _generateDetailedFeedback(metrics, formantStats),
    );
  }

  /// 피치 정확도 분석
  AnalysisItem _analyzePitchAccuracy(double accuracyCents) {
    String grade, feedback;
    CoachingPriority priority;
    
    if (accuracyCents <= 20) {
      grade = 'S';
      feedback = '완벽한 음정 정확도입니다! 🎯';
      priority = CoachingPriority.maintain;
    } else if (accuracyCents <= 35) {
      grade = 'A';
      feedback = '우수한 음정 정확도입니다 👍';
      priority = CoachingPriority.low;
    } else if (accuracyCents <= 50) {
      grade = 'B';
      feedback = '좋은 음정 정확도입니다. 조금 더 정밀하게 해보세요';
      priority = CoachingPriority.medium;
    } else if (accuracyCents <= 80) {
      grade = 'C';
      feedback = '음정을 더 정확히 맞춰보세요. 천천히 연습하세요';
      priority = CoachingPriority.high;
    } else {
      grade = 'D';
      feedback = '음정 연습이 필요합니다. 기본기부터 차근차근!';
      priority = CoachingPriority.critical;
    }

    return AnalysisItem(
      category: '음정 정확도',
      score: (100 - accuracyCents * 1.2).clamp(0, 100),
      grade: grade,
      feedback: feedback,
      priority: priority,
      suggestions: _generatePitchSuggestions(accuracyCents),
    );
  }

  /// 안정성 분석
  AnalysisItem _analyzeStability(double stabilityCents) {
    String grade, feedback;
    CoachingPriority priority;
    
    if (stabilityCents <= 10) {
      grade = 'S';
      feedback = '매우 안정적인 발성입니다! 🌟';
      priority = CoachingPriority.maintain;
    } else if (stabilityCents <= 20) {
      grade = 'A';
      feedback = '안정적인 발성입니다';
      priority = CoachingPriority.low;
    } else if (stabilityCents <= 35) {
      grade = 'B';
      feedback = '발성 안정성을 더 높여보세요';
      priority = CoachingPriority.medium;
    } else if (stabilityCents <= 50) {
      grade = 'C';
      feedback = '발성이 불안정합니다. 호흡과 자세를 점검하세요';
      priority = CoachingPriority.high;
    } else {
      grade = 'D';
      feedback = '안정적인 발성 연습이 시급합니다';
      priority = CoachingPriority.critical;
    }

    return AnalysisItem(
      category: '발성 안정성',
      score: (100 - stabilityCents * 1.8).clamp(0, 100),
      grade: grade,
      feedback: feedback,
      priority: priority,
      suggestions: _generateStabilitySuggestions(stabilityCents),
    );
  }

  /// 비브라토 분석
  AnalysisItem _analyzeVibrato(double vibratoRate, double vibratoExtent) {
    String grade, feedback;
    CoachingPriority priority;
    
    // 이상적인 비브라토: 5-7Hz, 50-100cents 범위
    final rateScore = _scoreVibratoRate(vibratoRate);
    final extentScore = _scoreVibratoExtent(vibratoExtent);
    final overallScore = (rateScore + extentScore) / 2;
    
    if (overallScore >= 90) {
      grade = 'S';
      feedback = '완벽한 비브라토입니다! 🎵';
      priority = CoachingPriority.maintain;
    } else if (overallScore >= 75) {
      grade = 'A';
      feedback = '좋은 비브라토입니다';
      priority = CoachingPriority.low;
    } else if (overallScore >= 60) {
      grade = 'B';
      feedback = '비브라토를 더 다듬어보세요';
      priority = CoachingPriority.medium;
    } else if (overallScore >= 40) {
      grade = 'C';
      feedback = '비브라토 연습이 필요합니다';
      priority = CoachingPriority.high;
    } else {
      grade = 'D';
      feedback = '비브라토 기초 연습을 시작하세요';
      priority = CoachingPriority.critical;
    }

    return AnalysisItem(
      category: '비브라토',
      score: overallScore,
      grade: grade,
      feedback: feedback,
      priority: priority,
      suggestions: _generateVibratoSuggestions(vibratoRate, vibratoExtent),
    );
  }

  /// 모음 안정성 분석
  AnalysisItem _analyzeVowelStability(VowelStabilityStats? stats) {
    if (stats == null) {
      return AnalysisItem(
        category: '모음 안정성',
        score: 50,
        grade: 'N/A',
        feedback: '모음 분석 데이터가 없습니다',
        priority: CoachingPriority.low,
        suggestions: ['모음 분석 기능을 활성화하세요'],
      );
    }

    final stability = stats.overallStability * 100;
    String grade, feedback;
    CoachingPriority priority;
    
    if (stability >= 90) {
      grade = 'S';
      feedback = '완벽한 모음 발음입니다! 👑';
      priority = CoachingPriority.maintain;
    } else if (stability >= 75) {
      grade = 'A';
      feedback = '우수한 모음 안정성입니다';
      priority = CoachingPriority.low;
    } else if (stability >= 60) {
      grade = 'B';
      feedback = '모음 발음을 더 안정적으로 해보세요';
      priority = CoachingPriority.medium;
    } else if (stability >= 45) {
      grade = 'C';
      feedback = '모음 발음 연습이 필요합니다';
      priority = CoachingPriority.high;
    } else {
      grade = 'D';
      feedback = '모음 발음 기초부터 다시 시작하세요';
      priority = CoachingPriority.critical;
    }

    return AnalysisItem(
      category: '모음 안정성',
      score: stability,
      grade: grade,
      feedback: feedback,
      priority: priority,
      suggestions: _generateVowelSuggestions(stats),
    );
  }

  /// 개인화된 목표 생성
  List<LearningGoal> _generatePersonalizedGoals(
    SessionAnalysisResult analysis,
    ProgressData progress,
  ) {
    final goals = <LearningGoal>[];
    
    // 우선순위가 높은 개선 영역부터 목표 생성
    final priorities = [
      analysis.pitchAccuracy,
      analysis.stability,
      analysis.vibrato,
      analysis.vowelStability,
      analysis.voicing,
    ]..sort((a, b) => b.priority.index.compareTo(a.priority.index));

    for (int i = 0; i < min(3, priorities.length); i++) {
      final item = priorities[i];
      if (item.priority.index >= CoachingPriority.medium.index) {
        goals.add(_createGoalForItem(item, progress));
      }
    }

    // 기본 목표가 없으면 유지 목표 추가
    if (goals.isEmpty) {
      goals.add(LearningGoal(
        id: _generateGoalId(),
        title: '현재 수준 유지',
        description: '훌륭한 실력을 계속 유지하세요',
        targetScore: 95,
        currentScore: analysis.overall.score,
        category: '전체',
        difficulty: GoalDifficulty.easy,
        estimatedDays: 7,
        milestones: ['매일 10분 연습', '주 3회 녹음 분석'],
        rewards: ['🏆 마스터 뱃지'],
      ));
    }

    return goals;
  }

  /// 실행 계획 생성
  ActionPlan _createActionPlan(SessionAnalysisResult analysis, List<LearningGoal> goals) {
    final dailyTasks = <DailyTask>[];
    final weeklyTasks = <WeeklyTask>[];
    
    // 목표별 일일 과제 생성
    for (final goal in goals) {
      dailyTasks.addAll(_generateDailyTasks(goal, analysis));
      weeklyTasks.addAll(_generateWeeklyTasks(goal));
    }

    return ActionPlan(
      id: _generatePlanId(),
      goals: goals,
      dailyTasks: dailyTasks,
      weeklyTasks: weeklyTasks,
      estimatedCompletionDate: DateTime.now().add(
        Duration(days: goals.map((g) => g.estimatedDays).fold(0, max))
      ),
      totalPracticeTime: goals.map((g) => g.estimatedDays * 10).fold(0, (a, b) => a + b),
    );
  }

  /// 연습 시간 추정
  int _estimatePracticeTime(List<LearningGoal> goals) {
    return goals.map((goal) {
      switch (goal.difficulty) {
        case GoalDifficulty.easy: return 10;
        case GoalDifficulty.medium: return 20;
        case GoalDifficulty.hard: return 30;
        case GoalDifficulty.expert: return 45;
      }
    }).fold(0, (a, b) => a + b);
  }

  /// 우선순위 계산
  CoachingPriority _calculatePriority(SessionAnalysisResult analysis) {
    final criticalCount = [
      analysis.pitchAccuracy,
      analysis.stability,
      analysis.vibrato,
      analysis.vowelStability,
    ].where((item) => item.priority == CoachingPriority.critical).length;

    if (criticalCount >= 2) return CoachingPriority.critical;
    if (criticalCount >= 1) return CoachingPriority.high;
    
    final highCount = [
      analysis.pitchAccuracy,
      analysis.stability,
      analysis.vibrato,
      analysis.vowelStability,
    ].where((item) => item.priority == CoachingPriority.high).length;

    if (highCount >= 2) return CoachingPriority.high;
    if (highCount >= 1) return CoachingPriority.medium;
    
    return CoachingPriority.low;
  }

  /// 사용자 프로필 업데이트
  void _updateUserProfile(CoachingCard card) {
    _userProfile ??= UserLearningProfile();
    
    // 학습 패턴 분석
    _userProfile!.totalSessions++;
    _userProfile!.totalPracticeMinutes += card.estimatedPracticeTime;
    
    // 강점/약점 업데이트
    final analysis = card.analysisResult;
    _updateStrengthsWeaknesses(analysis);
    
    // 진도 업데이트
    _userProfile!.lastSessionDate = DateTime.now();
    _updateLearningStreak();
  }

  /// 헬퍼 메서드들
  String _generateCardId() => 'card_${DateTime.now().millisecondsSinceEpoch}';
  String _generateGoalId() => 'goal_${DateTime.now().millisecondsSinceEpoch}';  
  String _generatePlanId() => 'plan_${DateTime.now().millisecondsSinceEpoch}';

  double _scoreVibratoRate(double rate) {
    // 이상적: 5-7Hz
    if (rate >= 5 && rate <= 7) return 100;
    if (rate >= 4 && rate <= 8) return 80;
    if (rate >= 3 && rate <= 9) return 60;
    return 40;
  }

  double _scoreVibratoExtent(double extent) {
    // 이상적: 50-100cents
    if (extent >= 50 && extent <= 100) return 100;
    if (extent >= 30 && extent <= 120) return 80;
    if (extent >= 20 && extent <= 150) return 60;
    return 40;
  }

  List<String> _generatePitchSuggestions(double accuracy) {
    if (accuracy > 50) {
      return [
        '피아노와 함께 음정 맞추기 연습하세요',
        '계이름 부르기로 음감을 기르세요',
        '천천히 불러서 정확도를 높이세요',
      ];
    } else {
      return [
        '현재 수준을 유지하며 다른 영역을 발전시키세요',
        '완벽한 음정을 다른 곡에서도 재현해보세요',
      ];
    }
  }

  List<String> _generateStabilitySuggestions(double stability) {
    if (stability > 25) {
      return [
        '복식호흡 연습으로 안정적인 발성을 만드세요',
        '긴 음표 연습으로 지속력을 기르세요',
        '올바른 자세로 연습하세요',
      ];
    } else {
      return [
        '현재의 안정적인 발성을 계속 유지하세요',
        '더 어려운 곡에 도전해보세요',
      ];
    }
  }

  List<String> _generateVibratoSuggestions(double rate, double extent) {
    final suggestions = <String>[];
    
    if (rate < 4 || rate > 8) {
      suggestions.add('비브라토 속도를 5-7Hz로 조절해보세요');
    }
    
    if (extent < 40 || extent > 120) {
      suggestions.add('비브라토 폭을 적절히 조절해보세요');
    }
    
    if (suggestions.isEmpty) {
      suggestions.add('완벽한 비브라토입니다!');
    }
    
    return suggestions;
  }

  List<String> _generateVowelSuggestions(VowelStabilityStats stats) {
    final suggestions = <String>[];
    
    // 가장 불안정한 모음 찾기
    VowelClass? weakestVowel;
    double lowestScore = 1.0;
    
    for (final entry in stats.vowelStabilities.entries) {
      if (entry.value < lowestScore) {
        lowestScore = entry.value;
        weakestVowel = entry.key;
      }
    }
    
    if (weakestVowel != null && lowestScore < 0.7) {
      final vowelName = _getVowelName(weakestVowel);
      suggestions.add('$vowelName 모음 발음을 더 연습하세요');
      suggestions.add('입 모양과 혀 위치를 확인하세요');
    } else {
      suggestions.add('모든 모음이 안정적입니다!');
    }
    
    return suggestions;
  }

  String _getVowelName(VowelClass vowel) {
    switch (vowel) {
      case VowelClass.a: return 'ㅏ';
      case VowelClass.ae: return 'ㅐ';
      case VowelClass.e: return 'ㅔ';
      case VowelClass.i: return 'ㅣ';
      case VowelClass.o: return 'ㅓ';
      case VowelClass.u: return 'ㅜ';
      default: return '모음';
    }
  }

  // 추가 구현 필요한 메서드들 (스텁)
  ProgressData _calculateProgress(SessionV2 session, List<SessionV2> recentSessions) {
    return ProgressData.empty();
  }

  String _calculateOverallGrade(Metrics metrics) {
    if (metrics.overallScore >= 90) return 'S';
    if (metrics.overallScore >= 80) return 'A';
    if (metrics.overallScore >= 70) return 'B';
    if (metrics.overallScore >= 60) return 'C';
    return 'D';
  }

  Duration _calculateSessionDuration(SessionV2 session) {
    return const Duration(minutes: 5); // 임시값
  }

  List<String> _identifyStrengths(SessionV2 session, VowelStabilityStats? formantStats) {
    return ['음정 정확도', '발성 안정성']; // 임시값
  }

  List<String> _identifyWeaknesses(SessionV2 session, VowelStabilityStats? formantStats) {
    return ['비브라토', '모음 안정성']; // 임시값
  }

  String _generateKeyInsight(Metrics metrics, VowelStabilityStats? formantStats) {
    return '전반적으로 우수한 실력입니다!';
  }

  String _suggestNextAction(List<String> weaknesses) {
    if (weaknesses.isNotEmpty) {
      return '${weaknesses.first} 연습을 집중적으로 해보세요';
    }
    return '현재 수준을 유지하며 새로운 도전을 해보세요';
  }

  int _estimateQuickPracticeTime(List<String> weaknesses) {
    return weaknesses.length * 10;
  }

  AnalysisItem _analyzeVoicing(double voicedRatio) {
    return AnalysisItem(
      category: '음성화',
      score: voicedRatio * 100,
      grade: voicedRatio > 0.8 ? 'A' : 'B',
      feedback: '음성화 비율이 적절합니다',
      priority: CoachingPriority.low,
      suggestions: [],
    );
  }

  AnalysisItem _analyzeOverall(double overallScore) {
    return AnalysisItem(
      category: '종합',
      score: overallScore,
      grade: _calculateOverallGrade(Metrics(
        accuracyCents: 0, stabilityCents: 0, vibratoRateHz: 0,
        vibratoExtentCents: 0, voicedRatio: 0, overallScore: overallScore,
      )),
      feedback: '종합 점수가 우수합니다',
      priority: CoachingPriority.maintain,
      suggestions: [],
    );
  }

  String _generateDetailedFeedback(Metrics metrics, VowelStabilityStats? stats) {
    return '상세한 분석 결과를 확인하세요';
  }

  LearningGoal _createGoalForItem(AnalysisItem item, ProgressData progress) {
    return LearningGoal(
      id: _generateGoalId(),
      title: '${item.category} 개선',
      description: item.feedback,
      targetScore: item.score + 20,
      currentScore: item.score,
      category: item.category,
      difficulty: GoalDifficulty.medium,
      estimatedDays: 14,
      milestones: item.suggestions,
      rewards: ['🎯 개선 뱃지'],
    );
  }

  List<DailyTask> _generateDailyTasks(LearningGoal goal, SessionAnalysisResult analysis) {
    return [
      DailyTask(
        id: 'task_${goal.id}',
        title: '${goal.category} 연습',
        description: '10분간 집중 연습',
        estimatedMinutes: 10,
        category: goal.category,
      ),
    ];
  }

  List<WeeklyTask> _generateWeeklyTasks(LearningGoal goal) {
    return [
      WeeklyTask(
        id: 'weekly_${goal.id}',
        title: '주간 점검',
        description: '이번 주 발전 상황 점검',
        estimatedMinutes: 30,
        category: goal.category,
      ),
    ];
  }

  void _updateStrengthsWeaknesses(SessionAnalysisResult analysis) {
    // 구현 예정
  }

  void _updateLearningStreak() {
    // 구현 예정
  }
}

/// 코칭 카드
class CoachingCard {
  final String id;
  final String sessionId;
  final DateTime createdAt;
  final SessionAnalysisResult analysisResult;
  final ProgressData progressData;
  final List<LearningGoal> goals;
  final ActionPlan actionPlan;
  final int estimatedPracticeTime;
  final CoachingPriority priority;

  CoachingCard({
    required this.id,
    required this.sessionId,
    required this.createdAt,
    required this.analysisResult,
    required this.progressData,
    required this.goals,
    required this.actionPlan,
    required this.estimatedPracticeTime,
    required this.priority,
  });
}

/// 1분 요약 리포트
class QuickSummaryReport {
  final String sessionId;
  final Duration duration;
  final String overallGrade;
  final double overallScore;
  final List<String> strengths;
  final List<String> weaknesses;
  final String keyInsight;
  final String nextAction;
  final int practiceTime;
  final DateTime createdAt;

  QuickSummaryReport({
    required this.sessionId,
    required this.duration,
    required this.overallGrade,
    required this.overallScore,
    required this.strengths,
    required this.weaknesses,
    required this.keyInsight,
    required this.nextAction,
    required this.practiceTime,
    required this.createdAt,
  });

  factory QuickSummaryReport.empty() {
    return QuickSummaryReport(
      sessionId: '',
      duration: Duration.zero,
      overallGrade: 'N/A',
      overallScore: 0,
      strengths: [],
      weaknesses: [],
      keyInsight: '분석할 데이터가 없습니다',
      nextAction: '새로운 세션을 시작하세요',
      practiceTime: 0,
      createdAt: DateTime.now(),
    );
  }
}

/// 세션 분석 결과
class SessionAnalysisResult {
  final AnalysisItem pitchAccuracy;
  final AnalysisItem stability;
  final AnalysisItem vibrato;
  final AnalysisItem vowelStability;
  final AnalysisItem voicing;
  final AnalysisItem overall;
  final String detailedFeedback;

  SessionAnalysisResult({
    required this.pitchAccuracy,
    required this.stability,
    required this.vibrato,
    required this.vowelStability,
    required this.voicing,
    required this.overall,
    required this.detailedFeedback,
  });

  factory SessionAnalysisResult.empty() {
    final emptyItem = AnalysisItem(
      category: '',
      score: 0,
      grade: 'N/A',
      feedback: '',
      priority: CoachingPriority.low,
      suggestions: [],
    );
    
    return SessionAnalysisResult(
      pitchAccuracy: emptyItem,
      stability: emptyItem,
      vibrato: emptyItem,
      vowelStability: emptyItem,
      voicing: emptyItem,
      overall: emptyItem,
      detailedFeedback: '',
    );
  }
}

/// 분석 항목
class AnalysisItem {
  final String category;
  final double score;
  final String grade;
  final String feedback;
  final CoachingPriority priority;
  final List<String> suggestions;

  AnalysisItem({
    required this.category,
    required this.score,
    required this.grade,
    required this.feedback,
    required this.priority,
    required this.suggestions,
  });
}

/// 학습 목표
class LearningGoal {
  final String id;
  final String title;
  final String description;
  final double targetScore;
  final double currentScore;
  final String category;
  final GoalDifficulty difficulty;
  final int estimatedDays;
  final List<String> milestones;
  final List<String> rewards;

  LearningGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetScore,
    required this.currentScore,
    required this.category,
    required this.difficulty,
    required this.estimatedDays,
    required this.milestones,
    required this.rewards,
  });
}

/// 실행 계획
class ActionPlan {
  final String id;
  final List<LearningGoal> goals;
  final List<DailyTask> dailyTasks;
  final List<WeeklyTask> weeklyTasks;
  final DateTime estimatedCompletionDate;
  final int totalPracticeTime;

  ActionPlan({
    required this.id,
    required this.goals,
    required this.dailyTasks,
    required this.weeklyTasks,
    required this.estimatedCompletionDate,
    required this.totalPracticeTime,
  });
}

/// 일일 과제
class DailyTask {
  final String id;
  final String title;
  final String description;
  final int estimatedMinutes;
  final String category;

  DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    required this.category,
  });
}

/// 주간 과제
class WeeklyTask {
  final String id;
  final String title;
  final String description;
  final int estimatedMinutes;
  final String category;

  WeeklyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    required this.category,
  });
}

/// 진도 데이터
class ProgressData {
  final Map<String, double> categoryProgress;
  final List<double> recentScores;
  final int practiceStreak;
  final DateTime lastPracticeDate;

  ProgressData({
    required this.categoryProgress,
    required this.recentScores,
    required this.practiceStreak,
    required this.lastPracticeDate,
  });

  factory ProgressData.empty() {
    return ProgressData(
      categoryProgress: {},
      recentScores: [],
      practiceStreak: 0,
      lastPracticeDate: DateTime.now(),
    );
  }
}

/// 사용자 학습 프로필
class UserLearningProfile {
  int totalSessions = 0;
  int totalPracticeMinutes = 0;
  Map<String, double> strengths = {};
  Map<String, double> weaknesses = {};
  DateTime? lastSessionDate;
  int learningStreak = 0;

  UserLearningProfile();
}

/// 코칭 우선순위
enum CoachingPriority {
  maintain,   // 유지
  low,        // 낮음
  medium,     // 보통
  high,       // 높음
  critical,   // 긴급
}

/// 목표 난이도
enum GoalDifficulty {
  easy,    // 쉬움
  medium,  // 보통
  hard,    // 어려움
  expert,  // 전문가
}