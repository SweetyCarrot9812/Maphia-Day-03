// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_analysis_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PerformanceAnalysisImpl _$$PerformanceAnalysisImplFromJson(
        Map<String, dynamic> json) =>
    _$PerformanceAnalysisImpl(
      userId: json['userId'] as String,
      exerciseId: json['exerciseId'] as String,
      analysisDate: DateTime.parse(json['analysisDate'] as String),
      progressScore: (json['progressScore'] as num).toDouble(),
      trend: $enumDecode(_$ProgressTrendEnumMap, json['trend']),
      insights: (json['insights'] as List<dynamic>)
          .map((e) => PerformanceInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      oneRMImprovement: (json['oneRMImprovement'] as num).toInt(),
      consistencyScore: (json['consistencyScore'] as num).toDouble(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      additionalMetrics: json['additionalMetrics'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$PerformanceAnalysisImplToJson(
        _$PerformanceAnalysisImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'exerciseId': instance.exerciseId,
      'analysisDate': instance.analysisDate.toIso8601String(),
      'progressScore': instance.progressScore,
      'trend': _$ProgressTrendEnumMap[instance.trend]!,
      'insights': instance.insights,
      'oneRMImprovement': instance.oneRMImprovement,
      'consistencyScore': instance.consistencyScore,
      'recommendations': instance.recommendations,
      'additionalMetrics': instance.additionalMetrics,
    };

const _$ProgressTrendEnumMap = {
  ProgressTrend.improving: 'improving',
  ProgressTrend.stable: 'stable',
  ProgressTrend.declining: 'declining',
  ProgressTrend.fluctuating: 'fluctuating',
};

_$PerformanceInsightImpl _$$PerformanceInsightImplFromJson(
        Map<String, dynamic> json) =>
    _$PerformanceInsightImpl(
      type: $enumDecode(_$InsightTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      severity: $enumDecode(_$InsightSeverityEnumMap, json['severity']),
      confidence: (json['confidence'] as num).toDouble(),
      actionItems: (json['actionItems'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$PerformanceInsightImplToJson(
        _$PerformanceInsightImpl instance) =>
    <String, dynamic>{
      'type': _$InsightTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'severity': _$InsightSeverityEnumMap[instance.severity]!,
      'confidence': instance.confidence,
      'actionItems': instance.actionItems,
      'data': instance.data,
    };

const _$InsightTypeEnumMap = {
  InsightType.strength_gain: 'strength_gain',
  InsightType.plateau: 'plateau',
  InsightType.form_issue: 'form_issue',
  InsightType.recovery_needed: 'recovery_needed',
  InsightType.volume_adjustment: 'volume_adjustment',
  InsightType.frequency_optimization: 'frequency_optimization',
};

const _$InsightSeverityEnumMap = {
  InsightSeverity.info: 'info',
  InsightSeverity.warning: 'warning',
  InsightSeverity.critical: 'critical',
};

_$PersonalizedRecommendationImpl _$$PersonalizedRecommendationImplFromJson(
        Map<String, dynamic> json) =>
    _$PersonalizedRecommendationImpl(
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: $enumDecode(_$RecommendationTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      priority: (json['priority'] as num).toDouble(),
      actions: (json['actions'] as List<dynamic>)
          .map((e) => RecommendationAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      reasoning: json['reasoning'] as String,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      implemented: json['implemented'] as bool?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$PersonalizedRecommendationImplToJson(
        _$PersonalizedRecommendationImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'type': _$RecommendationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'priority': instance.priority,
      'actions': instance.actions,
      'reasoning': instance.reasoning,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'implemented': instance.implemented,
      'metadata': instance.metadata,
    };

const _$RecommendationTypeEnumMap = {
  RecommendationType.exercise_modification: 'exercise_modification',
  RecommendationType.rest_day: 'rest_day',
  RecommendationType.deload_week: 'deload_week',
  RecommendationType.form_correction: 'form_correction',
  RecommendationType.nutrition_advice: 'nutrition_advice',
  RecommendationType.recovery_optimization: 'recovery_optimization',
};

_$RecommendationActionImpl _$$RecommendationActionImplFromJson(
        Map<String, dynamic> json) =>
    _$RecommendationActionImpl(
      actionType: json['actionType'] as String,
      description: json['description'] as String,
      parameters: json['parameters'] as Map<String, dynamic>?,
      completed: json['completed'] as bool?,
    );

Map<String, dynamic> _$$RecommendationActionImplToJson(
        _$RecommendationActionImpl instance) =>
    <String, dynamic>{
      'actionType': instance.actionType,
      'description': instance.description,
      'parameters': instance.parameters,
      'completed': instance.completed,
    };

_$InjuryRiskAssessmentImpl _$$InjuryRiskAssessmentImplFromJson(
        Map<String, dynamic> json) =>
    _$InjuryRiskAssessmentImpl(
      userId: json['userId'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      overallRiskScore: (json['overallRiskScore'] as num).toDouble(),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
      preventions: (json['preventions'] as List<dynamic>)
          .map((e) =>
              PreventionRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      bodyPartRisks: (json['bodyPartRisks'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      nextAssessmentDue: json['nextAssessmentDue'] == null
          ? null
          : DateTime.parse(json['nextAssessmentDue'] as String),
    );

Map<String, dynamic> _$$InjuryRiskAssessmentImplToJson(
        _$InjuryRiskAssessmentImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
      'overallRiskScore': instance.overallRiskScore,
      'riskFactors': instance.riskFactors,
      'preventions': instance.preventions,
      'bodyPartRisks': instance.bodyPartRisks,
      'nextAssessmentDue': instance.nextAssessmentDue?.toIso8601String(),
    };

_$RiskFactorImpl _$$RiskFactorImplFromJson(Map<String, dynamic> json) =>
    _$RiskFactorImpl(
      factor: json['factor'] as String,
      score: (json['score'] as num).toDouble(),
      description: json['description'] as String,
      category: $enumDecode(_$RiskCategoryEnumMap, json['category']),
      mitigationSteps: (json['mitigationSteps'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$RiskFactorImplToJson(_$RiskFactorImpl instance) =>
    <String, dynamic>{
      'factor': instance.factor,
      'score': instance.score,
      'description': instance.description,
      'category': _$RiskCategoryEnumMap[instance.category]!,
      'mitigationSteps': instance.mitigationSteps,
    };

const _$RiskCategoryEnumMap = {
  RiskCategory.overuse: 'overuse',
  RiskCategory.form_related: 'form_related',
  RiskCategory.recovery_deficit: 'recovery_deficit',
  RiskCategory.progression_error: 'progression_error',
  RiskCategory.equipment_issue: 'equipment_issue',
};

_$PreventionRecommendationImpl _$$PreventionRecommendationImplFromJson(
        Map<String, dynamic> json) =>
    _$PreventionRecommendationImpl(
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$PreventionTypeEnumMap, json['type']),
      priorityLevel: (json['priorityLevel'] as num).toInt(),
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      parameters: json['parameters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$PreventionRecommendationImplToJson(
        _$PreventionRecommendationImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'type': _$PreventionTypeEnumMap[instance.type]!,
      'priorityLevel': instance.priorityLevel,
      'exercises': instance.exercises,
      'parameters': instance.parameters,
    };

const _$PreventionTypeEnumMap = {
  PreventionType.warmup_enhancement: 'warmup_enhancement',
  PreventionType.mobility_work: 'mobility_work',
  PreventionType.strength_balancing: 'strength_balancing',
  PreventionType.load_management: 'load_management',
  PreventionType.technique_refinement: 'technique_refinement',
};

_$CoachingSessionImpl _$$CoachingSessionImplFromJson(
        Map<String, dynamic> json) =>
    _$CoachingSessionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      sessionStart: DateTime.parse(json['sessionStart'] as String),
      sessionEnd: json['sessionEnd'] == null
          ? null
          : DateTime.parse(json['sessionEnd'] as String),
      type: $enumDecode(_$CoachingTypeEnumMap, json['type']),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => CoachingMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      outcome: SessionOutcome.fromJson(json['outcome'] as Map<String, dynamic>),
      context: json['context'] as Map<String, dynamic>?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$CoachingSessionImplToJson(
        _$CoachingSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'sessionStart': instance.sessionStart.toIso8601String(),
      'sessionEnd': instance.sessionEnd?.toIso8601String(),
      'type': _$CoachingTypeEnumMap[instance.type]!,
      'messages': instance.messages,
      'outcome': instance.outcome,
      'context': instance.context,
      'tags': instance.tags,
    };

const _$CoachingTypeEnumMap = {
  CoachingType.real_time_feedback: 'real_time_feedback',
  CoachingType.post_workout_review: 'post_workout_review',
  CoachingType.planning_session: 'planning_session',
  CoachingType.troubleshooting: 'troubleshooting',
  CoachingType.motivation_boost: 'motivation_boost',
};

_$CoachingMessageImpl _$$CoachingMessageImplFromJson(
        Map<String, dynamic> json) =>
    _$CoachingMessageImpl(
      timestamp: DateTime.parse(json['timestamp'] as String),
      role: $enumDecode(_$MessageRoleEnumMap, json['role']),
      content: json['content'] as String,
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$CoachingMessageImplToJson(
        _$CoachingMessageImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'role': _$MessageRoleEnumMap[instance.role]!,
      'content': instance.content,
      'type': _$MessageTypeEnumMap[instance.type],
      'metadata': instance.metadata,
    };

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.coach: 'coach',
  MessageRole.system: 'system',
};

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.suggestion: 'suggestion',
  MessageType.warning: 'warning',
  MessageType.celebration: 'celebration',
  MessageType.data_insight: 'data_insight',
};

_$SessionOutcomeImpl _$$SessionOutcomeImplFromJson(Map<String, dynamic> json) =>
    _$SessionOutcomeImpl(
      type: $enumDecode(_$OutcomeTypeEnumMap, json['type']),
      satisfactionScore: (json['satisfactionScore'] as num).toDouble(),
      keyInsights: (json['keyInsights'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      actionItems: (json['actionItems'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      followUpDate: json['followUpDate'] == null
          ? null
          : DateTime.parse(json['followUpDate'] as String),
    );

Map<String, dynamic> _$$SessionOutcomeImplToJson(
        _$SessionOutcomeImpl instance) =>
    <String, dynamic>{
      'type': _$OutcomeTypeEnumMap[instance.type]!,
      'satisfactionScore': instance.satisfactionScore,
      'keyInsights': instance.keyInsights,
      'actionItems': instance.actionItems,
      'followUpDate': instance.followUpDate?.toIso8601String(),
    };

const _$OutcomeTypeEnumMap = {
  OutcomeType.plan_created: 'plan_created',
  OutcomeType.issue_resolved: 'issue_resolved',
  OutcomeType.goal_adjusted: 'goal_adjusted',
  OutcomeType.motivation_restored: 'motivation_restored',
  OutcomeType.form_corrected: 'form_corrected',
  OutcomeType.incomplete: 'incomplete',
};

_$FormAnalysisImpl _$$FormAnalysisImplFromJson(Map<String, dynamic> json) =>
    _$FormAnalysisImpl(
      exerciseId: json['exerciseId'] as String,
      userId: json['userId'] as String,
      analysisDate: DateTime.parse(json['analysisDate'] as String),
      overallFormScore: (json['overallFormScore'] as num).toDouble(),
      feedback: (json['feedback'] as List<dynamic>)
          .map((e) => FormFeedback.fromJson(e as Map<String, dynamic>))
          .toList(),
      corrections: (json['corrections'] as List<dynamic>)
          .map((e) => FormCorrection.fromJson(e as Map<String, dynamic>))
          .toList(),
      videoPath: json['videoPath'] as String?,
      biomechanicsData: json['biomechanicsData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$FormAnalysisImplToJson(_$FormAnalysisImpl instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'userId': instance.userId,
      'analysisDate': instance.analysisDate.toIso8601String(),
      'overallFormScore': instance.overallFormScore,
      'feedback': instance.feedback,
      'corrections': instance.corrections,
      'videoPath': instance.videoPath,
      'biomechanicsData': instance.biomechanicsData,
    };

_$FormFeedbackImpl _$$FormFeedbackImplFromJson(Map<String, dynamic> json) =>
    _$FormFeedbackImpl(
      aspect: json['aspect'] as String,
      score: (json['score'] as num).toDouble(),
      comment: json['comment'] as String,
      level: $enumDecode(_$FeedbackLevelEnumMap, json['level']),
      improvementTips: (json['improvementTips'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$FormFeedbackImplToJson(_$FormFeedbackImpl instance) =>
    <String, dynamic>{
      'aspect': instance.aspect,
      'score': instance.score,
      'comment': instance.comment,
      'level': _$FeedbackLevelEnumMap[instance.level]!,
      'improvementTips': instance.improvementTips,
    };

const _$FeedbackLevelEnumMap = {
  FeedbackLevel.excellent: 'excellent',
  FeedbackLevel.good: 'good',
  FeedbackLevel.needs_work: 'needs_work',
  FeedbackLevel.concerning: 'concerning',
};

_$FormCorrectionImpl _$$FormCorrectionImplFromJson(Map<String, dynamic> json) =>
    _$FormCorrectionImpl(
      issue: json['issue'] as String,
      correction: json['correction'] as String,
      priority: (json['priority'] as num).toInt(),
      cues: (json['cues'] as List<dynamic>?)?.map((e) => e as String).toList(),
      demonstrationUrl: json['demonstrationUrl'] as String?,
    );

Map<String, dynamic> _$$FormCorrectionImplToJson(
        _$FormCorrectionImpl instance) =>
    <String, dynamic>{
      'issue': instance.issue,
      'correction': instance.correction,
      'priority': instance.priority,
      'cues': instance.cues,
      'demonstrationUrl': instance.demonstrationUrl,
    };
