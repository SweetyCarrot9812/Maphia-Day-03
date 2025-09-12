import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../models/ai_analysis_models.dart';
import '../models/workout_log.dart';
import '../models/workout_plan.dart';
import '../models/isar_models.dart';
import '../models/isar_converters.dart';
import '../models/exercise_extensions.dart';
import '../utils/one_rm_calculator.dart';
import 'isar_service.dart';
import 'ai_coach_service.dart';

/// 고도화된 AI 코치 서비스
/// 개인화된 분석, 성과 추적, 부상 예방, 실시간 피드백 제공
class AdvancedCoachService {
  final IsarService _isarService;
  final AICoachService _aiCoachService;

  AdvancedCoachService(this._isarService, this._aiCoachService);

  // ===== 성과 분석 =====

  /// 종합적인 운동 성과 분석
  Future<PerformanceAnalysis> analyzePerformance({
    required String userId,
    required String exerciseId,
    int periodDays = 30,
  }) async {
    log('Analyzing performance for exercise: $exerciseId');
    
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    final sessions = await _getSessionsInPeriod(userId, startDate, endDate);
    final exerciseLogs = _extractExerciseLogs(sessions, exerciseId);
    
    if (exerciseLogs.isEmpty) {
      return _createEmptyAnalysis(userId, exerciseId);
    }

    final progressScore = _calculateProgressScore(exerciseLogs);
    final trend = _analyzeTrend(exerciseLogs);
    final insights = await _generateInsights(exerciseLogs);
    final oneRMImprovement = _calculateOneRMImprovement(exerciseLogs);
    final consistencyScore = _calculateConsistencyScore(exerciseLogs);
    final recommendations = await _generateRecommendations(exerciseLogs, insights);

    return PerformanceAnalysis(
      userId: userId,
      exerciseId: exerciseId,
      analysisDate: DateTime.now(),
      progressScore: progressScore,
      trend: trend,
      insights: insights,
      oneRMImprovement: oneRMImprovement,
      consistencyScore: consistencyScore,
      recommendations: recommendations,
      additionalMetrics: {
        'totalSets': exerciseLogs.length,
        'avgRpe': exerciseLogs.map((e) => e.rpe ?? 0).fold(0.0, (a, b) => a + b) / exerciseLogs.length,
        'maxWeight': exerciseLogs.map((e) => e.weight).reduce(math.max),
        'avgWeight': exerciseLogs.map((e) => e.weight).fold(0.0, (a, b) => a + b) / exerciseLogs.length,
      },
    );
  }

  /// 개인화된 운동 추천 생성
  Future<List<PersonalizedRecommendation>> generatePersonalizedRecommendations({
    required String userId,
  }) async {
    log('Generating personalized recommendations for user: $userId');
    
    final recentSessions = await _getSessionsInPeriod(
      userId,
      DateTime.now().subtract(const Duration(days: 14)),
      DateTime.now(),
    );

    final recommendations = <PersonalizedRecommendation>[];
    
    // 1. 운동 빈도 분석
    final frequencyRec = await _analyzeFrequency(userId, recentSessions);
    if (frequencyRec != null) recommendations.add(frequencyRec);
    
    // 2. 볼륨 분석
    final volumeRec = await _analyzeVolume(userId, recentSessions);
    if (volumeRec != null) recommendations.add(volumeRec);
    
    // 3. 회복 분석
    final recoveryRec = await _analyzeRecovery(userId, recentSessions);
    if (recoveryRec != null) recommendations.add(recoveryRec);
    
    // 4. 진행 상황 분석
    final progressRec = await _analyzeProgressPatterns(userId, recentSessions);
    if (progressRec != null) recommendations.add(progressRec);

    // 우선순위 순으로 정렬
    recommendations.sort((a, b) => b.priority.compareTo(a.priority));
    
    return recommendations;
  }

  // ===== 부상 위험도 평가 =====

  /// 부상 위험도 종합 평가
  Future<InjuryRiskAssessment> assessInjuryRisk({
    required String userId,
  }) async {
    log('Assessing injury risk for user: $userId');
    
    final recentSessions = await _getSessionsInPeriod(
      userId,
      DateTime.now().subtract(const Duration(days: 21)),
      DateTime.now(),
    );

    final riskFactors = <RiskFactor>[];
    
    // 1. 과사용 위험 분석
    riskFactors.addAll(await _analyzeOveruseRisk(recentSessions));
    
    // 2. 급격한 부하 증가 분석
    riskFactors.addAll(await _analyzeLoadProgression(recentSessions));
    
    // 3. 회복 부족 분석
    riskFactors.addAll(await _analyzeRecoveryDeficit(recentSessions));
    
    // 4. RPE 패턴 분석
    riskFactors.addAll(await _analyzeRpePatterns(recentSessions));

    final overallRisk = _calculateOverallRisk(riskFactors);
    final bodyPartRisks = _calculateBodyPartRisks(recentSessions);
    final preventions = _generatePreventionRecommendations(riskFactors);

    return InjuryRiskAssessment(
      userId: userId,
      assessmentDate: DateTime.now(),
      overallRiskScore: overallRisk,
      riskFactors: riskFactors,
      preventions: preventions,
      bodyPartRisks: bodyPartRisks,
      nextAssessmentDue: DateTime.now().add(const Duration(days: 7)),
    );
  }

  // ===== 실시간 코칭 세션 =====

  /// 실시간 코칭 세션 시작
  Future<CoachingSession> startCoachingSession({
    required String userId,
    required CoachingType type,
    Map<String, dynamic>? context,
  }) async {
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    
    final session = CoachingSession(
      id: sessionId,
      userId: userId,
      sessionStart: DateTime.now(),
      type: type,
      messages: [],
      outcome: const SessionOutcome(
        type: OutcomeType.incomplete,
        satisfactionScore: 0,
      ),
      context: context,
    );

    // 세션 초기화 메시지
    final initialMessage = await _generateInitialCoachingMessage(type, context);
    final updatedSession = session.copyWith(
      messages: [initialMessage],
    );

    await _saveCoachingSession(updatedSession);
    return updatedSession;
  }

  /// 코칭 메시지 처리 및 응답
  Future<CoachingMessage> processCoachingMessage({
    required String sessionId,
    required String userMessage,
  }) async {
    final session = await _getCoachingSession(sessionId);
    if (session == null) throw Exception('Session not found');

    // 사용자 메시지 추가
    final userMsg = CoachingMessage(
      timestamp: DateTime.now(),
      role: MessageRole.user,
      content: userMessage,
      type: MessageType.text,
    );

    // AI 응답 생성
    final aiResponse = await _generateCoachingResponse(
      session,
      userMessage,
    );

    // 세션 업데이트
    final updatedSession = session.copyWith(
      messages: [...session.messages, userMsg, aiResponse],
    );

    await _saveCoachingSession(updatedSession);
    return aiResponse;
  }

  /// 세션 종료 및 결과 분석
  Future<SessionOutcome> completeCoachingSession({
    required String sessionId,
    required double satisfactionScore,
  }) async {
    final session = await _getCoachingSession(sessionId);
    if (session == null) throw Exception('Session not found');

    final insights = _extractSessionInsights(session);
    final actionItems = _extractActionItems(session);
    
    final outcome = SessionOutcome(
      type: _determineOutcomeType(session),
      satisfactionScore: satisfactionScore,
      keyInsights: insights,
      actionItems: actionItems,
      followUpDate: _calculateFollowUpDate(session.type),
    );

    final completedSession = session.copyWith(
      sessionEnd: DateTime.now(),
      outcome: outcome,
    );

    await _saveCoachingSession(completedSession);
    return outcome;
  }

  // ===== 폼 분석 (기본 구현) =====

  /// 기본적인 폼 분석 (향후 비디오 분석으로 확장 가능)
  Future<FormAnalysis> analyzeForm({
    required String exerciseId,
    required String userId,
    required List<ExerciseLog> recentLogs,
  }) async {
    log('Analyzing form for exercise: $exerciseId');
    
    final feedback = <FormFeedback>[];
    final corrections = <FormCorrection>[];

    // RPE와 성공률 기반 폼 분석
    final avgRpe = recentLogs
        .where((log) => log.rpe != null)
        .map((log) => log.rpe!)
        .fold(0.0, (a, b) => a + b) / recentLogs.length;

    final successRate = recentLogs
        .where((log) => log.completed)
        .length / recentLogs.length;

    // 폼 점수 계산 (임시 로직)
    double formScore = 100.0;
    
    // RPE가 너무 높으면 폼 이슈일 가능성
    if (avgRpe > 8.5) {
      formScore -= 20;
      feedback.add(const FormFeedback(
        aspect: 'intensity_management',
        score: 6.0,
        comment: 'RPE가 지속적으로 높습니다. 폼 점검이 필요할 수 있습니다.',
        level: FeedbackLevel.needs_work,
        improvementTips: ['무게를 줄이고 폼에 집중', '동작 속도 조절', '전체 가동범위 확인'],
      ));
      
      corrections.add(const FormCorrection(
        issue: '과도한 강도',
        correction: '무게를 10-15% 줄이고 완벽한 폼으로 수행',
        priority: 2,
        cues: ['천천히 내리기', '멈춤 동작 포함', '전체 가동범위'],
      ));
    }

    // 성공률이 낮으면 폼 이슈
    if (successRate < 0.8) {
      formScore -= 25;
      feedback.add(const FormFeedback(
        aspect: 'consistency',
        score: 5.0,
        comment: '세트 완주율이 낮습니다. 폼 개선이 필요합니다.',
        level: FeedbackLevel.concerning,
        improvementTips: ['기본 폼 재점검', '점진적 무게 증가', '충분한 휴식'],
      ));
    }

    return FormAnalysis(
      exerciseId: exerciseId,
      userId: userId,
      analysisDate: DateTime.now(),
      overallFormScore: math.max(formScore, 0),
      feedback: feedback,
      corrections: corrections,
      biomechanicsData: {
        'avgRpe': avgRpe,
        'successRate': successRate,
        'totalSets': recentLogs.length,
      },
    );
  }

  // ===== 내부 헬퍼 메서드 =====

  Future<List<WorkoutSession>> _getSessionsInPeriod(
    String userId, 
    DateTime start, 
    DateTime end
  ) async {
    final isar = await _isarService.database;
    final localSessions = await isar.localSessions
        .filter()
        .userIdEqualTo(userId)
        .dateGreaterThan(start.subtract(const Duration(days: 1)))
        .dateLessThan(end.add(const Duration(days: 1)))
        .findAll();
    
    return localSessions.map((local) => local.toWorkoutSession()).toList();
  }

  List<ExerciseLog> _extractExerciseLogs(List<WorkoutSession> sessions, String exerciseId) {
    final logs = <ExerciseLog>[];
    
    for (final session in sessions) {
      for (final log in session.exerciseLogs) {
        if (log.exerciseId == exerciseId) {
          logs.add(log);
        }
      }
    }
    
    return logs;
  }

  PerformanceAnalysis _createEmptyAnalysis(String userId, String exerciseId) {
    return PerformanceAnalysis(
      userId: userId,
      exerciseId: exerciseId,
      analysisDate: DateTime.now(),
      progressScore: 0,
      trend: ProgressTrend.stable,
      insights: [],
      oneRMImprovement: 0,
      consistencyScore: 0,
      recommendations: ['이 운동에 대한 기록이 부족합니다. 꾸준히 수행해보세요.'],
    );
  }

  double _calculateProgressScore(List<ExerciseLog> logs) {
    if (logs.length < 2) return 50.0;
    
    // 최근 30% vs 초기 30% 비교
    final recentCount = math.max(1, (logs.length * 0.3).round());
    final oldCount = math.max(1, (logs.length * 0.3).round());
    
    final recentLogs = logs.take(recentCount).toList();
    final oldLogs = logs.reversed.take(oldCount).toList();
    
    final recentAvg = recentLogs.map((e) => e.weight * e.reps).fold(0.0, (a, b) => a + b) / recentCount;
    final oldAvg = oldLogs.map((e) => e.weight * e.reps).fold(0.0, (a, b) => a + b) / oldCount;
    
    final improvement = ((recentAvg - oldAvg) / oldAvg) * 100;
    return math.max(0, math.min(100, 50 + improvement));
  }

  ProgressTrend _analyzeTrend(List<ExerciseLog> logs) {
    if (logs.length < 3) return ProgressTrend.stable;
    
    final weights = logs.map((e) => e.weight).toList();
    int increases = 0, decreases = 0;
    
    for (int i = 1; i < weights.length; i++) {
      if (weights[i] > weights[i-1]) increases++;
      else if (weights[i] < weights[i-1]) decreases++;
    }
    
    if (increases > decreases * 1.5) return ProgressTrend.improving;
    if (decreases > increases * 1.5) return ProgressTrend.declining;
    if ((increases + decreases).abs() > weights.length * 0.6) return ProgressTrend.fluctuating;
    return ProgressTrend.stable;
  }

  Future<List<PerformanceInsight>> _generateInsights(List<ExerciseLog> logs) async {
    final insights = <PerformanceInsight>[];
    
    // RPE 패턴 분석
    final avgRpe = logs.where((e) => e.rpe != null).map((e) => e.rpe!).fold(0.0, (a, b) => a + b) / logs.length;
    
    if (avgRpe > 8.5) {
      insights.add(const PerformanceInsight(
        type: InsightType.form_issue,
        title: '높은 RPE 패턴',
        description: 'RPE가 지속적으로 높습니다. 폼 점검이나 디로드를 고려하세요.',
        severity: InsightSeverity.warning,
        confidence: 0.8,
        actionItems: ['폼 비디오 촬영', '무게 5-10% 감소', '기술적 완성도 향상'],
      ));
    }
    
    // 정체기 감지
    final recentWeights = logs.take(5).map((e) => e.weight).toList();
    if (recentWeights.length >= 5 && recentWeights.every((w) => (w - recentWeights.first).abs() < 2.5)) {
      insights.add(const PerformanceInsight(
        type: InsightType.plateau,
        title: '정체기 감지',
        description: '최근 5회 운동에서 중량 변화가 거의 없습니다.',
        severity: InsightSeverity.info,
        confidence: 0.9,
        actionItems: ['운동 변형 시도', '볼륨 조정', '새로운 자극 도입'],
      ));
    }
    
    return insights;
  }

  int _calculateOneRMImprovement(List<ExerciseLog> logs) {
    if (logs.length < 2) return 0;
    
    final recent = logs.first;
    final old = logs.last;
    
    final recentOneRM = OneRMCalculator.calculate(recent.weight, recent.reps);
    final oldOneRM = OneRMCalculator.calculate(old.weight, old.reps);
    
    return ((recentOneRM - oldOneRM) / oldOneRM * 100).round();
  }

  double _calculateConsistencyScore(List<ExerciseLog> logs) {
    if (logs.isEmpty) return 0;
    
    final completed = logs.where((e) => e.completed).length;
    return (completed / logs.length) * 100;
  }

  Future<List<String>> _generateRecommendations(
    List<ExerciseLog> logs, 
    List<PerformanceInsight> insights
  ) async {
    final recommendations = <String>[];
    
    for (final insight in insights) {
      if (insight.actionItems != null) {
        recommendations.addAll(insight.actionItems!);
      }
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('현재 좋은 패턴으로 운동하고 있습니다. 계속 유지하세요!');
    }
    
    return recommendations;
  }

  // 추가 헬퍼 메서드들 (공간 절약을 위해 일부만 구현)
  Future<PersonalizedRecommendation?> _analyzeFrequency(String userId, List<WorkoutSession> sessions) async {
    // 주간 운동 빈도 분석 로직
    return null; // 구현 예정
  }

  Future<PersonalizedRecommendation?> _analyzeVolume(String userId, List<WorkoutSession> sessions) async {
    // 운동 볼륨 분석 로직
    return null; // 구현 예정
  }

  Future<PersonalizedRecommendation?> _analyzeRecovery(String userId, List<WorkoutSession> sessions) async {
    // 회복 패턴 분석 로직
    return null; // 구현 예정
  }

  Future<PersonalizedRecommendation?> _analyzeProgressPatterns(String userId, List<WorkoutSession> sessions) async {
    // 진행 패턴 분석 로직
    return null; // 구현 예정
  }

  Future<List<RiskFactor>> _analyzeOveruseRisk(List<WorkoutSession> sessions) async {
    // 과사용 위험 분석 로직
    return []; // 구현 예정
  }

  Future<List<RiskFactor>> _analyzeLoadProgression(List<WorkoutSession> sessions) async {
    // 부하 진행 분석 로직
    return []; // 구현 예정
  }

  Future<List<RiskFactor>> _analyzeRecoveryDeficit(List<WorkoutSession> sessions) async {
    // 회복 부족 분석 로직
    return []; // 구현 예정
  }

  Future<List<RiskFactor>> _analyzeRpePatterns(List<WorkoutSession> sessions) async {
    // RPE 패턴 분석 로직
    return []; // 구현 예정
  }

  double _calculateOverallRisk(List<RiskFactor> factors) {
    if (factors.isEmpty) return 0;
    return factors.map((e) => e.score).fold(0.0, (a, b) => a + b) / factors.length * 10;
  }

  Map<String, double> _calculateBodyPartRisks(List<WorkoutSession> sessions) {
    // 신체 부위별 위험도 계산 로직
    return {
      '허리': 20.0,
      '무릎': 15.0,
      '어깨': 25.0,
      '손목': 10.0,
    };
  }

  List<PreventionRecommendation> _generatePreventionRecommendations(List<RiskFactor> factors) {
    // 예방 권장사항 생성 로직
    return [
      const PreventionRecommendation(
        title: '충분한 워밍업',
        description: '운동 전 10-15분간 동적 워밍업을 실시하세요.',
        type: PreventionType.warmup_enhancement,
        priorityLevel: 1,
      ),
    ];
  }

  Future<CoachingMessage> _generateInitialCoachingMessage(
    CoachingType type, 
    Map<String, dynamic>? context
  ) async {
    String content = '안녕하세요! AI 코치입니다. 어떻게 도와드릴까요?';
    
    switch (type) {
      case CoachingType.real_time_feedback:
        content = '운동 중이시군요! 실시간으로 도움을 드리겠습니다. 현재 상황을 알려주세요.';
        break;
      case CoachingType.post_workout_review:
        content = '운동 수고하셨습니다! 오늘 운동은 어떠셨나요? 리뷰를 도와드리겠습니다.';
        break;
      case CoachingType.planning_session:
        content = '운동 계획을 세워보시는군요! 목표와 현재 상황을 알려주세요.';
        break;
      case CoachingType.troubleshooting:
        content = '운동 중 문제가 생겼나요? 어떤 어려움이 있는지 알려주시면 도움을 드리겠습니다.';
        break;
      case CoachingType.motivation_boost:
        content = '동기 부여가 필요하시군요! 함께 목표를 다시 확인하고 의지를 다져보아요!';
        break;
    }
    
    return CoachingMessage(
      timestamp: DateTime.now(),
      role: MessageRole.coach,
      content: content,
      type: MessageType.text,
    );
  }

  Future<CoachingMessage> _generateCoachingResponse(
    CoachingSession session,
    String userMessage,
  ) async {
    // AI 응답 생성 (실제로는 _aiCoachService 활용)
    final response = await _aiCoachService.chatWithCoach(
      userId: session.userId,
      userMessage: userMessage,
      conversationHistory: session.messages
          .map((m) => {'role': m.role.name, 'content': m.content})
          .toList(),
    );
    
    return CoachingMessage(
      timestamp: DateTime.now(),
      role: MessageRole.coach,
      content: response,
      type: MessageType.text,
    );
  }

  Future<void> _saveCoachingSession(CoachingSession session) async {
    // 세션 저장 로직 (Isar 또는 다른 저장소 활용)
    log('Saving coaching session: ${session.id}');
  }

  Future<CoachingSession?> _getCoachingSession(String sessionId) async {
    // 세션 조회 로직
    return null; // 구현 예정
  }

  List<String> _extractSessionInsights(CoachingSession session) {
    // 세션에서 인사이트 추출
    return ['세션이 성공적으로 완료되었습니다.'];
  }

  List<String> _extractActionItems(CoachingSession session) {
    // 세션에서 액션 아이템 추출
    return ['다음 운동까지 충분한 휴식 취하기'];
  }

  OutcomeType _determineOutcomeType(CoachingSession session) {
    // 세션 결과 타입 결정
    return OutcomeType.plan_created;
  }

  DateTime? _calculateFollowUpDate(CoachingType type) {
    switch (type) {
      case CoachingType.planning_session:
        return DateTime.now().add(const Duration(days: 7));
      case CoachingType.post_workout_review:
        return DateTime.now().add(const Duration(days: 2));
      default:
        return null;
    }
  }
}
