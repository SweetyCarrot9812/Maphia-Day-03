import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import '../models/pitch_data.dart';
import '../models/audio_reference.dart';
import '../models/vocal_types.dart';
import 'ai_feedback_service.dart';
import 'vibrato_analyzer.dart';
import 'dtw_melody_aligner.dart';
import 'formant_analyzer.dart';
import 'adaptive_curriculum_generator.dart';
import 'voice_range_detector.dart';
import 'progress_tracking_service.dart';

/// 종합 보컬 코치 분석 결과
class ComprehensiveVocalAnalysis {
  final VocalAnalysis basicAnalysis;
  final VibratoAnalysisResult? vibratoAnalysis;
  final AlignmentResult? alignmentAnalysis;
  final FormantAnalysisResult? formantAnalysis;
  final VoiceRangeAnalysisResult? voiceRangeAnalysis;
  final DateTime analyzedAt;
  final double overallScore; // 0.0 - 1.0
  final Map<String, double> dimensionScores; // 각 차원별 점수
  
  ComprehensiveVocalAnalysis({
    required this.basicAnalysis,
    this.vibratoAnalysis,
    this.alignmentAnalysis,
    this.formantAnalysis,
    this.voiceRangeAnalysis,
    required this.analyzedAt,
    required this.overallScore,
    required this.dimensionScores,
  });
  
  Map<String, dynamic> toJson() => {
    'basic_analysis': basicAnalysis.toJson(),
    'vibrato_analysis': vibratoAnalysis?.toJson(),
    'alignment_analysis': alignmentAnalysis?.toJson(),
    'formant_analysis': formantAnalysis?.toJson(),
    'voice_range_analysis': voiceRangeAnalysis?.toJson(),
    'analyzed_at': analyzedAt.toIso8601String(),
    'overall_score': overallScore,
    'dimension_scores': dimensionScores,
  };
}

/// 실시간 보컬 코칭 가이드
class RealTimeCoachingGuide {
  final String primaryFocus; // 현재 주요 개선 포인트
  final List<String> immediateActions; // 즉시 적용 가능한 액션
  final String visualGuidance; // 시각적 가이드 텍스트
  final CoachingPriority priority;
  final double confidence; // 가이드 신뢰도
  
  RealTimeCoachingGuide({
    required this.primaryFocus,
    required this.immediateActions,
    required this.visualGuidance,
    required this.priority,
    required this.confidence,
  });
}

enum CoachingPriority { critical, high, medium, low }

/// 개인화 보컬 학습 계획
class PersonalizedLearningPlan {
  final String userId;
  final VoiceType voiceType;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<TrainingSession> nextSessions; // 다음 3-5개 세션
  final Map<String, double> skillProgression; // 기술별 진척도
  final DateTime createdAt;
  final DateTime updatedAt;
  
  PersonalizedLearningPlan({
    required this.userId,
    required this.voiceType,
    required this.strengths,
    required this.weaknesses,
    required this.nextSessions,
    required this.skillProgression,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// 훈련 세션 정의
class TrainingSession {
  final String sessionId;
  final String title;
  final String description;
  final List<String> exercises;
  final int estimatedMinutes;
  final DifficultyLevel difficulty;
  final List<String> focusAreas;
  final String preparation;
  
  TrainingSession({
    required this.sessionId,
    required this.title,
    required this.description,
    required this.exercises,
    required this.estimatedMinutes,
    required this.difficulty,
    required this.focusAreas,
    required this.preparation,
  });
}

/// AI 기반 개인화 보컬 코치 메인 서비스
class PersonalizedVocalCoach {
  final AIFeedbackService _aiService;
  final VibratoAnalyzer _vibratoAnalyzer;
  final DTWMelodyAligner _melodyAligner;
  final FormantAnalyzer _formantAnalyzer;
  final AdaptiveCurriculumGenerator _curriculumGenerator;
  final VoiceRangeDetector _voiceRangeDetector;
  final ProgressTrackingService _progressService;
  
  // 실시간 분석 상태
  final StreamController<RealTimeCoachingGuide> _realtimeGuidanceController;
  final List<ComprehensiveVocalAnalysis> _sessionHistory = [];
  PersonalizedLearningPlan? _currentPlan;
  
  PersonalizedVocalCoach({
    String? openaiApiKey,
  }) : _aiService = AIFeedbackService(apiKey: openaiApiKey),
       _vibratoAnalyzer = VibratoAnalyzer(),
       _melodyAligner = DTWMelodyAligner(),
       _formantAnalyzer = FormantAnalyzer(),
       _curriculumGenerator = AdaptiveCurriculumGenerator(),
       _voiceRangeDetector = VoiceRangeDetector(),
       _progressService = ProgressTrackingService(),
       _realtimeGuidanceController = StreamController<RealTimeCoachingGuide>.broadcast();
  
  Stream<RealTimeCoachingGuide> get realtimeGuidanceStream => 
      _realtimeGuidanceController.stream;
  
  /// 종합 보컬 분석 수행
  Future<ComprehensiveVocalAnalysis> performComprehensiveAnalysis(
    PitchData pitchData,
    AudioReference audioReference,
    List<double> audioSamples,
  ) async {
    final analysisStart = DateTime.now();
    
    // 1. 기본 분석
    final basicAnalysis = AIFeedbackService.generateAnalysis(pitchData, audioReference);
    
    // 2. 비브라토 분석
    VibratoAnalysisResult? vibratoResult;
    try {
      // 피치 데이터를 먼저 추가
      for (int i = 0; i < pitchData.pitchCurve.length; i++) {
        _vibratoAnalyzer.addPitchSample(
          frequency: pitchData.pitchCurve[i],
          confidence: 0.8, // 기본 신뢰도
          timestamp: i * 20.0, // 20ms 간격
        );
      }
      vibratoResult = _vibratoAnalyzer.analyzeVibrato();
    } catch (e) {
      print('비브라토 분석 오류: $e');
    }
    
    // 3. 멜로디 정렬 분석 
    AlignmentResult? alignmentResult;
    try {
      // TODO: AudioReference에서 MelodyNote 목록을 생성하는 메서드 구현 필요
      // 임시로 빈 목록 사용
      final List<MelodyNote> referenceMelody = [];
      final List<MelodyNote> userMelody = [];
      
      final dtw = await _melodyAligner.alignMelodies(
        referenceMelody,
        userMelody,
      );
      alignmentResult = dtw;
    } catch (e) {
      print('멜로디 정렬 분석 오류: $e');
    }
    
    // 4. 포먼트 분석
    FormantAnalysisResult? formantResult;
    try {
      // TODO: audioSamples Float64List 구현 필요
      // 임시로 빈 Float64List 사용
      final audioSamples = Float64List(0);
      final formant = await _formantAnalyzer.analyzeFormants(audioSamples);
      formantResult = formant;
    } catch (e) {
      print('포먼트 분석 오류: $e');
    }
    
    // 5. 음성 범위 분석
    VoiceRangeAnalysisResult? voiceRangeResult;
    try {
      // 피치 데이터를 먼저 추가
      for (int i = 0; i < pitchData.pitchCurve.length; i++) {
        _voiceRangeDetector.addSample(
          frequency: pitchData.pitchCurve[i],
          confidence: 0.8, // 기본 신뢰도
          note: 'C4', // TODO: 주파수를 노트로 변환 필요
        );
      }
      voiceRangeResult = _voiceRangeDetector.analyzeVoiceRange();
    } catch (e) {
      print('음성 범위 분석 오류: $e');
    }
    
    // 6. 차원별 점수 계산
    final dimensionScores = _calculateDimensionScores(
      basicAnalysis,
      vibratoResult,
      alignmentResult,
      formantResult,
      voiceRangeResult,
    );
    
    // 7. 전체 점수 계산
    final overallScore = _calculateOverallScore(dimensionScores);
    
    final analysis = ComprehensiveVocalAnalysis(
      basicAnalysis: basicAnalysis,
      vibratoAnalysis: vibratoResult,
      alignmentAnalysis: alignmentResult,
      formantAnalysis: formantResult,
      voiceRangeAnalysis: voiceRangeResult,
      analyzedAt: analysisStart,
      overallScore: overallScore,
      dimensionScores: dimensionScores,
    );
    
    // 세션 히스토리에 추가
    _sessionHistory.add(analysis);
    
    // 진도 추적 서비스에 기록
    await _progressService.recordSession({
      'userId': 'current_user', // TODO: 실제 사용자 ID로 교체
      'sessionType': 'vocal_analysis',
      'durationSeconds': DateTime.now().difference(analysisStart).inSeconds,
      'totalNotesAttempted': 1,
      'notesCompleted': overallScore > 0.7 ? 1 : 0,
      'accuracyScores': [overallScore * 100],
      'sessionNotes': 'Comprehensive vocal analysis completed',
    });
    
    return analysis;
  }
  
  /// 실시간 보컬 코칭 가이드 생성
  Future<void> generateRealtimeGuidance(
    List<double> currentPitchData,
    AudioReference reference,
  ) async {
    if (currentPitchData.isEmpty) return;
    
    try {
      // 실시간 분석을 위한 간단한 메트릭 계산
      final recentData = currentPitchData.length > 50 
          ? currentPitchData.sublist(currentPitchData.length - 50)
          : currentPitchData;
      
      // 현재 피치 안정성 확인
      final avgPitch = recentData.reduce((a, b) => a + b) / recentData.length;
      final variance = recentData
          .map((p) => (p - avgPitch) * (p - avgPitch))
          .reduce((a, b) => a + b) / recentData.length;
      final stability = math.sqrt(variance);
      
      // 목표 주파수와의 오차 계산
      final targetFreq = reference.getTargetFrequencies().isNotEmpty
          ? reference.getTargetFrequencies().first
          : 440.0; // A4 기본값
      
      final pitchError = (avgPitch - targetFreq).abs();
      final errorCents = 1200 * math.log(avgPitch / targetFreq) / math.ln2;
      
      // 실시간 가이드 생성
      final guide = _createRealtimeGuide(stability, pitchError, errorCents.abs());
      
      // 스트림으로 전송
      if (!_realtimeGuidanceController.isClosed) {
        _realtimeGuidanceController.add(guide);
      }
      
    } catch (e) {
      print('실시간 가이드 생성 오류: $e');
    }
  }
  
  /// 개인화 학습 계획 생성/업데이트
  Future<PersonalizedLearningPlan> generatePersonalizedPlan(
    String userId,
    {int sessionCount = 5}
  ) async {
    try {
      // 최근 분석 결과 기반으로 사용자 프로필 구축
      final recentAnalyses = _sessionHistory
          .where((a) => a.analyzedAt.isAfter(DateTime.now().subtract(Duration(days: 30))))
          .toList();
      
      if (recentAnalyses.isEmpty) {
        // 기본 계획 생성
        return _createDefaultLearningPlan(userId);
      }
      
      // 강점과 약점 분석
      final strengths = _identifyStrengths(recentAnalyses);
      final weaknesses = _identifyWeaknesses(recentAnalyses);
      
      // 음성 타입 결정
      final voiceType = _determineVoiceType(recentAnalyses);
      
      // 기술별 진척도 계산
      final skillProgression = _calculateSkillProgression(recentAnalyses);
      
      // 적응형 커리큘럼 생성을 위한 CurriculumUserProfile 생성
      final curriculumProfile = CurriculumUserProfile(
        currentLevel: _determineCurrentLevel(recentAnalyses),
        voiceType: voiceType,
        goals: [LearningGoal.pitchAccuracy, LearningGoal.toneQuality], // 기본 목표
        skillLevels: _calculateSkillLevels(recentAnalyses),
        weakAreas: _identifyWeakAreas(recentAnalyses),
        availableMinutesPerSession: 30,
        sessionsPerWeek: 3,
        recentSessions: [], // TODO: 실제 세션 데이터로 교체
      );
      
      final curriculum = await _curriculumGenerator.generateCurriculum(curriculumProfile);
      
      // 다음 세션들을 TrainingSession으로 변환
      final nextSessions = curriculum.weeks
          .take(2) // 향후 2주
          .expand((week) => week.sessions)
          .take(sessionCount)
          .map((session) => TrainingSession(
            sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
            title: session.title,
            description: '일일 보컬 연습 세션',
            exercises: session.exercises.map((e) => e.title).toList(),
            estimatedMinutes: session.totalMinutes,
            difficulty: DifficultyLevel.intermediate, // 기본값
            focusAreas: session.exercises.map((e) => e.focusAreas).expand((list) => list).toList(),
            preparation: session.exercises.isNotEmpty ? session.exercises.first.title : '발성 준비',
          )).toList();
      
      final plan = PersonalizedLearningPlan(
        userId: userId,
        voiceType: voiceType,
        strengths: strengths,
        weaknesses: weaknesses,
        nextSessions: nextSessions,
        skillProgression: skillProgression,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _currentPlan = plan;
      return plan;
      
    } catch (e) {
      print('개인화 계획 생성 오류: $e');
      return _createDefaultLearningPlan(userId);
    }
  }
  
  /// AI 피드백과 함께 종합 리포트 생성
  Future<Map<String, dynamic>> generateComprehensiveReport(
    ComprehensiveVocalAnalysis analysis,
    AudioReference audioReference,
  ) async {
    try {
      // AI 피드백 생성
      final aiFeedback = await _aiService.generateFeedback(
        analysis.basicAnalysis,
        audioReference,
        language: 'ko',
      );
      
      // 종합 리포트 구성
      return {
        'timestamp': analysis.analyzedAt.toIso8601String(),
        'overall_score': analysis.overallScore,
        'dimension_breakdown': {
          'pitch_accuracy': analysis.dimensionScores['pitch_accuracy'] ?? 0.0,
          'stability': analysis.dimensionScores['stability'] ?? 0.0,
          'vibrato_quality': analysis.dimensionScores['vibrato_quality'] ?? 0.0,
          'timing_alignment': analysis.dimensionScores['timing_alignment'] ?? 0.0,
          'tone_quality': analysis.dimensionScores['tone_quality'] ?? 0.0,
          'voice_range': analysis.dimensionScores['voice_range'] ?? 0.0,
        },
        'strengths': _extractStrengthsFromAnalysis(analysis),
        'improvement_areas': _extractImprovementAreas(analysis),
        'specific_recommendations': _generateSpecificRecommendations(analysis),
        'next_practice_focus': _determineNextPracticeFocus(analysis),
        'ai_feedback': aiFeedback?.toJson(),
        'progress_indicators': await _generateProgressIndicators(analysis),
      };
    } catch (e) {
      print('종합 리포트 생성 오류: $e');
      return {
        'error': '리포트 생성 중 오류가 발생했습니다',
        'timestamp': analysis.analyzedAt.toIso8601String(),
        'overall_score': analysis.overallScore,
      };
    }
  }
  
  /// 차원별 점수 계산
  Map<String, double> _calculateDimensionScores(
    VocalAnalysis basic,
    VibratoAnalysisResult? vibrato,
    AlignmentResult? alignment,
    FormantAnalysisResult? formant,
    VoiceRangeAnalysisResult? voiceRange,
  ) {
    final scores = <String, double>{};
    
    // 피치 정확도 (0-1)
    final pitchAccuracy = math.max(0, 1.0 - (basic.accuracyMean / 50.0));
    scores['pitch_accuracy'] = pitchAccuracy.clamp(0.0, 1.0).toDouble();
    
    // 안정성 (0-1)
    final stability = math.max(0, 1.0 - (basic.stabilityStd / 30.0));
    scores['stability'] = stability.clamp(0.0, 1.0).toDouble();
    
    // 비브라토 품질 (0-1)
    if (vibrato != null) {
      final vibratoScore = _convertVibratoQualityToScore(vibrato.quality);
      scores['vibrato_quality'] = vibratoScore;
    } else {
      scores['vibrato_quality'] = 0.5; // 중성값
    }
    
    // 타이밍 정렬 (0-1)
    if (alignment != null) {
      scores['timing_alignment'] = alignment.overallAccuracy / 100.0;
    } else {
      scores['timing_alignment'] = 0.5; // 중성값
    }
    
    // 음색 품질 (0-1)
    if (formant != null) {
      final toneScore = (formant.resonanceQuality + 
                       formant.tonalCharacteristics['brightness']! +
                       formant.tonalCharacteristics['warmth']!) / 300.0;
      scores['tone_quality'] = toneScore.clamp(0.0, 1.0);
    } else {
      scores['tone_quality'] = 0.5; // 중성값
    }
    
    // 음성 범위 (0-1)
    if (voiceRange != null) {
      scores['voice_range'] = voiceRange.confidence / 100.0;
    } else {
      scores['voice_range'] = 0.5; // 중성값
    }
    
    return scores;
  }
  
  /// 전체 점수 계산
  double _calculateOverallScore(Map<String, double> dimensionScores) {
    final weights = {
      'pitch_accuracy': 0.30,
      'stability': 0.25,
      'vibrato_quality': 0.15,
      'timing_alignment': 0.15,
      'tone_quality': 0.10,
      'voice_range': 0.05,
    };
    
    double totalScore = 0.0;
    double totalWeight = 0.0;
    
    weights.forEach((dimension, weight) {
      final score = dimensionScores[dimension];
      if (score != null) {
        totalScore += score * weight;
        totalWeight += weight;
      }
    });
    
    return totalWeight > 0 ? totalScore / totalWeight : 0.0;
  }
  
  /// 실시간 가이드 생성
  RealTimeCoachingGuide _createRealtimeGuide(
    double stability,
    double pitchError,
    double errorCents,
  ) {
    String primaryFocus;
    List<String> immediateActions;
    String visualGuidance;
    CoachingPriority priority;
    double confidence = 0.8;
    
    if (errorCents > 50) {
      // 심각한 피치 오류
      primaryFocus = "피치 정확도 개선 필요";
      immediateActions = [
        "목표 음정에 더 가깝게 조정하세요",
        "천천히 정확한 피치로 다시 시도하세요",
        "호흡을 안정화하고 집중하세요"
      ];
      visualGuidance = errorCents > 0 ? "너무 높습니다 ↓" : "너무 낮습니다 ↑";
      priority = CoachingPriority.critical;
    } else if (stability > 15.0) {
      // 불안정한 발성
      primaryFocus = "발성 안정성 개선";
      immediateActions = [
        "호흡을 더 깊고 안정적으로 하세요",
        "복식호흡에 집중하세요",
        "긴장을 풀고 자연스럽게 발성하세요"
      ];
      visualGuidance = "발성이 불안정합니다";
      priority = CoachingPriority.high;
    } else if (errorCents > 20) {
      // 경미한 피치 오류
      primaryFocus = "피치 조정";
      immediateActions = [
        "조금씩 피치를 조정해보세요",
        "목표 음정을 머릿속으로 되새기세요"
      ];
      visualGuidance = errorCents > 0 ? "약간 높습니다" : "약간 낮습니다";
      priority = CoachingPriority.medium;
    } else {
      // 좋은 상태
      primaryFocus = "현재 상태 유지";
      immediateActions = [
        "훌륭합니다! 이 상태를 유지하세요",
        "일정한 호흡과 발성을 계속하세요"
      ];
      visualGuidance = "완벽합니다! ✓";
      priority = CoachingPriority.low;
      confidence = 0.95;
    }
    
    return RealTimeCoachingGuide(
      primaryFocus: primaryFocus,
      immediateActions: immediateActions,
      visualGuidance: visualGuidance,
      priority: priority,
      confidence: confidence,
    );
  }
  
  // Helper methods...
  
  double _convertVibratoQualityToScore(VibratoQuality quality) {
    switch (quality) {
      case VibratoQuality.excellent:
        return 1.0;
      case VibratoQuality.good:
        return 0.8;
      case VibratoQuality.acceptable:
        return 0.6;
      case VibratoQuality.needsWork:
        return 0.4;
      case VibratoQuality.poor:
        return 0.2;
      default:
        return 0.5;
    }
  }
  
  PersonalizedLearningPlan _createDefaultLearningPlan(String userId) {
    return PersonalizedLearningPlan(
      userId: userId,
      voiceType: VoiceType.unknown,
      strengths: ['학습 의지'],
      weaknesses: ['기초 연습 필요'],
      nextSessions: [
        TrainingSession(
          sessionId: 'default_1',
          title: '기초 발성 연습',
          description: '기본적인 발성과 호흡 연습',
          exercises: ['롱톤 연습', '호흡 연습', '립트릴'],
          estimatedMinutes: 15,
          difficulty: DifficultyLevel.beginner,
          focusAreas: ['호흡', '발성'],
          preparation: '충분한 워밍업과 물 마시기',
        ),
      ],
      skillProgression: {
        'pitch_accuracy': 0.3,
        'stability': 0.2,
        'vibrato_quality': 0.1,
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  List<String> _identifyStrengths(List<ComprehensiveVocalAnalysis> analyses) {
    final strengths = <String>[];
    
    // 최근 분석 결과를 기반으로 강점 식별
    if (analyses.isNotEmpty) {
      final latest = analyses.last;
      
      if (latest.dimensionScores['pitch_accuracy']! > 0.8) {
        strengths.add('우수한 피치 정확도');
      }
      if (latest.dimensionScores['stability']! > 0.8) {
        strengths.add('안정적인 발성');
      }
      if (latest.dimensionScores['vibrato_quality']! > 0.7) {
        strengths.add('좋은 비브라토 컨트롤');
      }
      if (latest.dimensionScores['timing_alignment']! > 0.8) {
        strengths.add('정확한 리듬감');
      }
      if (latest.dimensionScores['tone_quality']! > 0.7) {
        strengths.add('풍부한 음색');
      }
    }
    
    if (strengths.isEmpty) {
      strengths.add('지속적인 학습 의지');
    }
    
    return strengths;
  }
  
  List<String> _identifyWeaknesses(List<ComprehensiveVocalAnalysis> analyses) {
    final weaknesses = <String>[];
    
    if (analyses.isNotEmpty) {
      final latest = analyses.last;
      
      if (latest.dimensionScores['pitch_accuracy']! < 0.6) {
        weaknesses.add('피치 정확도 개선 필요');
      }
      if (latest.dimensionScores['stability']! < 0.6) {
        weaknesses.add('발성 안정성 향상 필요');
      }
      if (latest.dimensionScores['vibrato_quality']! < 0.5) {
        weaknesses.add('비브라토 기술 연습 필요');
      }
      if (latest.dimensionScores['timing_alignment']! < 0.6) {
        weaknesses.add('리듬감 개선 필요');
      }
      if (latest.dimensionScores['tone_quality']! < 0.5) {
        weaknesses.add('음색 개발 필요');
      }
    }
    
    return weaknesses;
  }
  
  VoiceType _determineVoiceType(List<ComprehensiveVocalAnalysis> analyses) {
    // 음성 범위 분석 결과를 기반으로 음성 타입 결정
    if (analyses.isNotEmpty) {
      final latest = analyses.last;
      if (latest.voiceRangeAnalysis != null) {
        return latest.voiceRangeAnalysis!.voiceType;
      }
    }
    return VoiceType.unknown;
  }
  
  Map<String, double> _calculateSkillProgression(List<ComprehensiveVocalAnalysis> analyses) {
    if (analyses.length < 2) {
      return {
        'pitch_accuracy': 0.3,
        'stability': 0.3,
        'vibrato_quality': 0.2,
        'timing_alignment': 0.3,
        'tone_quality': 0.2,
      };
    }
    
    final recent = analyses.last.dimensionScores;
    final previous = analyses[analyses.length - 2].dimensionScores;
    
    final progression = <String, double>{};
    recent.forEach((skill, currentScore) {
      final previousScore = previous[skill] ?? 0.0;
      progression[skill] = currentScore;
    });
    
    return progression;
  }
  
  DifficultyLevel _determineCurrentLevel(List<ComprehensiveVocalAnalysis> analyses) {
    if (analyses.isEmpty) return DifficultyLevel.beginner;
    
    final avgScore = analyses.last.overallScore;
    
    if (avgScore >= 0.8) return DifficultyLevel.expert;
    if (avgScore >= 0.6) return DifficultyLevel.advanced;
    if (avgScore >= 0.4) return DifficultyLevel.intermediate;
    return DifficultyLevel.beginner;
  }
  
  List<String> _extractStrengthsFromAnalysis(ComprehensiveVocalAnalysis analysis) {
    final strengths = <String>[];
    
    analysis.dimensionScores.forEach((dimension, score) {
      if (score > 0.75) {
        switch (dimension) {
          case 'pitch_accuracy':
            strengths.add('정확한 피치 조절 능력');
            break;
          case 'stability':
            strengths.add('안정적인 발성 기술');
            break;
          case 'vibrato_quality':
            strengths.add('훌륭한 비브라토 컨트롤');
            break;
          case 'timing_alignment':
            strengths.add('정확한 타이밍 감각');
            break;
          case 'tone_quality':
            strengths.add('풍부하고 아름다운 음색');
            break;
        }
      }
    });
    
    return strengths;
  }
  
  List<String> _extractImprovementAreas(ComprehensiveVocalAnalysis analysis) {
    final improvements = <String>[];
    
    analysis.dimensionScores.forEach((dimension, score) {
      if (score < 0.6) {
        switch (dimension) {
          case 'pitch_accuracy':
            improvements.add('피치 정확도 향상');
            break;
          case 'stability':
            improvements.add('발성 안정성 개선');
            break;
          case 'vibrato_quality':
            improvements.add('비브라토 기술 개발');
            break;
          case 'timing_alignment':
            improvements.add('리듬감 향상');
            break;
          case 'tone_quality':
            improvements.add('음색 품질 개선');
            break;
        }
      }
    });
    
    return improvements;
  }
  
  List<String> _generateSpecificRecommendations(ComprehensiveVocalAnalysis analysis) {
    final recommendations = <String>[];
    
    // 가장 낮은 점수의 차원에 대한 구체적인 추천사항
    final sortedDimensions = analysis.dimensionScores.entries
        .toList()
        ..sort((a, b) => a.value.compareTo(b.value));
    
    final weakestDimension = sortedDimensions.first;
    
    switch (weakestDimension.key) {
      case 'pitch_accuracy':
        recommendations.addAll([
          '피아노와 함께 음정 맞추기 연습',
          '천천히 스케일 올라가고 내려오기',
          '정확한 음정으로 롱톤 연습',
        ]);
        break;
      case 'stability':
        recommendations.addAll([
          '복식호흡 강화 연습',
          '지속음(롱톤) 연습으로 안정성 향상',
          '목과 어깨 긴장 완화 스트레칭',
        ]);
        break;
      case 'vibrato_quality':
        recommendations.addAll([
          '천천히 비브라토 속도 조절 연습',
          '다양한 음정에서 비브라토 연습',
          '전문 보컬리스트 비브라토 모방하기',
        ]);
        break;
    }
    
    return recommendations;
  }
  
  String _determineNextPracticeFocus(ComprehensiveVocalAnalysis analysis) {
    final sortedDimensions = analysis.dimensionScores.entries
        .toList()
        ..sort((a, b) => a.value.compareTo(b.value));
    
    final weakestDimension = sortedDimensions.first;
    
    switch (weakestDimension.key) {
      case 'pitch_accuracy':
        return '피치 정확도 집중 연습';
      case 'stability':
        return '발성 안정성 훈련';
      case 'vibrato_quality':
        return '비브라토 기술 개발';
      case 'timing_alignment':
        return '리듬감 향상 연습';
      case 'tone_quality':
        return '음색 개발 훈련';
      default:
        return '종합적인 보컬 기초 연습';
    }
  }
  
  Future<Map<String, dynamic>> _generateProgressIndicators(
    ComprehensiveVocalAnalysis analysis,
  ) async {
    // 진도 추적 서비스에서 사용자의 진행 상황을 가져와서 진도 지표 생성
    final progress = await _progressService.getUserProgress('current_user'); // TODO: 실제 사용자 ID
    
    return {
      'sessions_completed': progress['sessions_completed'] ?? 0,
      'total_practice_time': progress['total_practice_time'] ?? 0,
      'improvement_trend': progress['improvement_trend'] ?? 'stable',
      'streak_days': progress['streak_days'] ?? 0,
      'next_milestone': progress['next_milestone'] ?? '첫 번째 완벽한 스케일',
      'skill_levels': {
        'pitch_accuracy': _getSkillLevel(analysis.dimensionScores['pitch_accuracy'] ?? 0.0),
        'stability': _getSkillLevel(analysis.dimensionScores['stability'] ?? 0.0),
        'vibrato_quality': _getSkillLevel(analysis.dimensionScores['vibrato_quality'] ?? 0.0),
        'timing_alignment': _getSkillLevel(analysis.dimensionScores['timing_alignment'] ?? 0.0),
        'tone_quality': _getSkillLevel(analysis.dimensionScores['tone_quality'] ?? 0.0),
      },
    };
  }
  
  String _getSkillLevel(double score) {
    if (score >= 0.9) return '전문가';
    if (score >= 0.75) return '상급';
    if (score >= 0.6) return '중급';
    if (score >= 0.4) return '초급';
    return '입문';
  }
  
  /// 스킬 레벨 계산
  Map<String, double> _calculateSkillLevels(List<ComprehensiveVocalAnalysis> analyses) {
    if (analyses.isEmpty) {
      return {
        'pitch_accuracy': 0.5,
        'stability': 0.5,
        'vibrato_quality': 0.5,
        'timing_alignment': 0.5,
        'tone_quality': 0.5,
      };
    }
    
    final skillLevels = <String, double>{};
    final recentAnalyses = analyses.take(5).toList(); // 최근 5개 분석
    
    for (final dimension in ['pitch_accuracy', 'stability', 'vibrato_quality', 'timing_alignment', 'tone_quality']) {
      final scores = recentAnalyses.map((a) => a.dimensionScores[dimension] ?? 0.0).toList();
      final avgScore = scores.reduce((a, b) => a + b) / scores.length;
      skillLevels[dimension] = avgScore;
    }
    
    return skillLevels;
  }
  
  /// 약점 영역 식별
  List<String> _identifyWeakAreas(List<ComprehensiveVocalAnalysis> analyses) {
    final skillLevels = _calculateSkillLevels(analyses);
    final weakAreas = <String>[];
    
    skillLevels.forEach((skill, level) {
      if (level < 0.6) { // 60% 미만은 약점으로 간주
        switch (skill) {
          case 'pitch_accuracy':
            weakAreas.add('음정 정확도');
            break;
          case 'stability':
            weakAreas.add('발성 안정성');
            break;
          case 'vibrato_quality':
            weakAreas.add('비브라토 기술');
            break;
          case 'timing_alignment':
            weakAreas.add('리듬감');
            break;
          case 'tone_quality':
            weakAreas.add('음색');
            break;
        }
      }
    });
    
    return weakAreas;
  }

  /// 리소스 정리
  void dispose() {
    _realtimeGuidanceController.close();
  }
}