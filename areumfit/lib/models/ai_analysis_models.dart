import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_analysis_models.freezed.dart';
part 'ai_analysis_models.g.dart';

/// AI 분석을 위한 고급 모델들
/// 개인화된 피드백, 성과 분석, 부상 위험도 등

/// 운동 성과 분석
@freezed
class PerformanceAnalysis with _$PerformanceAnalysis {
  const factory PerformanceAnalysis({
    required String userId,
    required String exerciseId,
    required DateTime analysisDate,
    required double progressScore, // 0-100점
    required ProgressTrend trend,
    required List<PerformanceInsight> insights,
    required int oneRMImprovement, // 지난 달 대비 %
    required double consistencyScore, // 0-100점
    required List<String> recommendations,
    Map<String, dynamic>? additionalMetrics,
  }) = _PerformanceAnalysis;

  factory PerformanceAnalysis.fromJson(Map<String, dynamic> json) =>
      _$PerformanceAnalysisFromJson(json);
}

/// 성과 트렌드
enum ProgressTrend {
  improving,
  stable,
  declining,
  fluctuating,
}

/// 성과 인사이트
@freezed
class PerformanceInsight with _$PerformanceInsight {
  const factory PerformanceInsight({
    required InsightType type,
    required String title,
    required String description,
    required InsightSeverity severity,
    required double confidence, // 0-1.0
    List<String>? actionItems,
    Map<String, dynamic>? data,
  }) = _PerformanceInsight;

  factory PerformanceInsight.fromJson(Map<String, dynamic> json) =>
      _$PerformanceInsightFromJson(json);
}

enum InsightType {
  strength_gain,
  plateau,
  form_issue,
  recovery_needed,
  volume_adjustment,
  frequency_optimization,
}

enum InsightSeverity {
  info,
  warning,
  critical,
}

/// 개인화된 운동 추천
@freezed
class PersonalizedRecommendation with _$PersonalizedRecommendation {
  const factory PersonalizedRecommendation({
    required String userId,
    required DateTime createdAt,
    required RecommendationType type,
    required String title,
    required String description,
    required double priority, // 0-1.0
    required List<RecommendationAction> actions,
    required String reasoning,
    DateTime? expiresAt,
    bool? implemented,
    Map<String, dynamic>? metadata,
  }) = _PersonalizedRecommendation;

  factory PersonalizedRecommendation.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedRecommendationFromJson(json);
}

enum RecommendationType {
  exercise_modification,
  rest_day,
  deload_week,
  form_correction,
  nutrition_advice,
  recovery_optimization,
}

@freezed
class RecommendationAction with _$RecommendationAction {
  const factory RecommendationAction({
    required String actionType,
    required String description,
    Map<String, dynamic>? parameters,
    bool? completed,
  }) = _RecommendationAction;

  factory RecommendationAction.fromJson(Map<String, dynamic> json) =>
      _$RecommendationActionFromJson(json);
}

/// 부상 위험도 평가
@freezed
class InjuryRiskAssessment with _$InjuryRiskAssessment {
  const factory InjuryRiskAssessment({
    required String userId,
    required DateTime assessmentDate,
    required double overallRiskScore, // 0-100
    required List<RiskFactor> riskFactors,
    required List<PreventionRecommendation> preventions,
    required Map<String, double> bodyPartRisks, // 신체 부위별 위험도
    DateTime? nextAssessmentDue,
  }) = _InjuryRiskAssessment;

  factory InjuryRiskAssessment.fromJson(Map<String, dynamic> json) =>
      _$InjuryRiskAssessmentFromJson(json);
}

@freezed
class RiskFactor with _$RiskFactor {
  const factory RiskFactor({
    required String factor,
    required double score, // 0-10
    required String description,
    required RiskCategory category,
    List<String>? mitigationSteps,
  }) = _RiskFactor;

  factory RiskFactor.fromJson(Map<String, dynamic> json) =>
      _$RiskFactorFromJson(json);
}

enum RiskCategory {
  overuse,
  form_related,
  recovery_deficit,
  progression_error,
  equipment_issue,
}

@freezed
class PreventionRecommendation with _$PreventionRecommendation {
  const factory PreventionRecommendation({
    required String title,
    required String description,
    required PreventionType type,
    required int priorityLevel, // 1-5
    List<String>? exercises,
    Map<String, dynamic>? parameters,
  }) = _PreventionRecommendation;

  factory PreventionRecommendation.fromJson(Map<String, dynamic> json) =>
      _$PreventionRecommendationFromJson(json);
}

enum PreventionType {
  warmup_enhancement,
  mobility_work,
  strength_balancing,
  load_management,
  technique_refinement,
}

/// AI 코치 세션 기록
@freezed
class CoachingSession with _$CoachingSession {
  const factory CoachingSession({
    required String id,
    required String userId,
    required DateTime sessionStart,
    DateTime? sessionEnd,
    required CoachingType type,
    required List<CoachingMessage> messages,
    required SessionOutcome outcome,
    Map<String, dynamic>? context,
    List<String>? tags,
  }) = _CoachingSession;

  factory CoachingSession.fromJson(Map<String, dynamic> json) =>
      _$CoachingSessionFromJson(json);
}

enum CoachingType {
  real_time_feedback,
  post_workout_review,
  planning_session,
  troubleshooting,
  motivation_boost,
}

@freezed
class CoachingMessage with _$CoachingMessage {
  const factory CoachingMessage({
    required DateTime timestamp,
    required MessageRole role,
    required String content,
    MessageType? type,
    Map<String, dynamic>? metadata,
  }) = _CoachingMessage;

  factory CoachingMessage.fromJson(Map<String, dynamic> json) =>
      _$CoachingMessageFromJson(json);
}

enum MessageRole {
  user,
  coach,
  system,
}

enum MessageType {
  text,
  suggestion,
  warning,
  celebration,
  data_insight,
}

@freezed
class SessionOutcome with _$SessionOutcome {
  const factory SessionOutcome({
    required OutcomeType type,
    required double satisfactionScore, // 0-10
    List<String>? keyInsights,
    List<String>? actionItems,
    DateTime? followUpDate,
  }) = _SessionOutcome;

  factory SessionOutcome.fromJson(Map<String, dynamic> json) =>
      _$SessionOutcomeFromJson(json);
}

enum OutcomeType {
  plan_created,
  issue_resolved,
  goal_adjusted,
  motivation_restored,
  form_corrected,
  incomplete,
}

/// 운동 폼 분석 (향후 비디오 분석용)
@freezed
class FormAnalysis with _$FormAnalysis {
  const factory FormAnalysis({
    required String exerciseId,
    required String userId,
    required DateTime analysisDate,
    required double overallFormScore, // 0-100
    required List<FormFeedback> feedback,
    required List<FormCorrection> corrections,
    String? videoPath,
    Map<String, dynamic>? biomechanicsData,
  }) = _FormAnalysis;

  factory FormAnalysis.fromJson(Map<String, dynamic> json) =>
      _$FormAnalysisFromJson(json);
}

@freezed
class FormFeedback with _$FormFeedback {
  const factory FormFeedback({
    required String aspect, // "knee_tracking", "bar_path", etc.
    required double score, // 0-10
    required String comment,
    required FeedbackLevel level,
    List<String>? improvementTips,
  }) = _FormFeedback;

  factory FormFeedback.fromJson(Map<String, dynamic> json) =>
      _$FormFeedbackFromJson(json);
}

enum FeedbackLevel {
  excellent,
  good,
  needs_work,
  concerning,
}

@freezed
class FormCorrection with _$FormCorrection {
  const factory FormCorrection({
    required String issue,
    required String correction,
    required int priority, // 1-5
    List<String>? cues,
    String? demonstrationUrl,
  }) = _FormCorrection;

  factory FormCorrection.fromJson(Map<String, dynamic> json) =>
      _$FormCorrectionFromJson(json);
}
