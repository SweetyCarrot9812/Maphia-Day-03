import 'dart:math' as math;
import '../models/session.dart';
import '../models/vocal_types.dart';

/// 학습 목표
enum LearningGoal {
  pitchAccuracy,     // 음정 정확도
  rangeExtension,    // 음역대 확장
  vibratoMastery,    // 비브라토 마스터
  toneQuality,       // 음색 개선
  rhythmStability,   // 리듬 안정성
  performance,       // 공연 실력
}

/// 연습 타입
enum ExerciseType {
  scaleBasic,        // 기본 스케일
  scaleAdvanced,     // 고급 스케일
  interval,          // 음정 연습
  vibrato,           // 비브라토 연습
  rangeExtension,    // 음역대 확장
  toneShaping,       // 음색 조형
  rhythmPattern,     // 리듬 패턴
  songPractice,      // 곡 연습
}

/// 연습 항목
class ExerciseItem {
  final String id;
  final String title;
  final String description;
  final ExerciseType type;
  final DifficultyLevel difficulty;
  final int estimatedMinutes;
  final List<String> focusAreas;
  final Map<String, dynamic> parameters;
  final List<String> prerequisites;
  
  ExerciseItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.focusAreas,
    required this.parameters,
    required this.prerequisites,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'difficulty': difficulty.toString(),
      'estimated_minutes': estimatedMinutes,
      'focus_areas': focusAreas,
      'parameters': parameters,
      'prerequisites': prerequisites,
    };
  }
}

/// 일일 세션
class DailySession {
  final int day;
  final String title;
  final List<ExerciseItem> exercises;
  final int totalMinutes;
  final List<String> tips;
  
  DailySession({
    required this.day,
    required this.title,
    required this.exercises,
    required this.totalMinutes,
    required this.tips,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'title': title,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'total_minutes': totalMinutes,
      'tips': tips,
    };
  }
}

/// 주간 커리큘럼
class WeeklyCurriculum {
  final int week;
  final String theme;
  final List<DailySession> sessions;
  final List<String> goals;
  final Map<String, double> expectedProgress;
  
  WeeklyCurriculum({
    required this.week,
    required this.theme,
    required this.sessions,
    required this.goals,
    required this.expectedProgress,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'week': week,
      'theme': theme,
      'sessions': sessions.map((s) => s.toMap()).toList(),
      'goals': goals,
      'expected_progress': expectedProgress,
    };
  }
}

/// 커리큘럼 사용자 프로필
class CurriculumUserProfile {
  final DifficultyLevel currentLevel;
  final VoiceType voiceType;
  final List<LearningGoal> goals;
  final Map<String, double> skillLevels; // 기술별 숙련도 (0-1)
  final List<String> weakAreas;
  final int availableMinutesPerSession;
  final int sessionsPerWeek;
  final List<Session> recentSessions;
  
  CurriculumUserProfile({
    required this.currentLevel,
    required this.voiceType,
    required this.goals,
    required this.skillLevels,
    required this.weakAreas,
    required this.availableMinutesPerSession,
    required this.sessionsPerWeek,
    required this.recentSessions,
  });
}

/// 전체 적응형 커리큘럼
class AdaptiveCurriculum {
  final String userId;
  final DateTime generatedAt;
  final CurriculumUserProfile userProfile;
  final List<WeeklyCurriculum> weeks;
  final Map<String, dynamic> metadata;
  final double estimatedCompletionRate;
  
  AdaptiveCurriculum({
    required this.userId,
    required this.generatedAt,
    required this.userProfile,
    required this.weeks,
    required this.metadata,
    required this.estimatedCompletionRate,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'generated_at': generatedAt.toIso8601String(),
      'user_profile': {
        'current_level': userProfile.currentLevel.toString(),
        'voice_type': userProfile.voiceType.toString(),
        'goals': userProfile.goals.map((g) => g.toString()).toList(),
        'skill_levels': userProfile.skillLevels,
        'weak_areas': userProfile.weakAreas,
        'available_minutes_per_session': userProfile.availableMinutesPerSession,
        'sessions_per_week': userProfile.sessionsPerWeek,
      },
      'weeks': weeks.map((w) => w.toMap()).toList(),
      'metadata': metadata,
      'estimated_completion_rate': estimatedCompletionRate,
    };
  }
}

/// 적응형 연습 커리큘럼 생성기
/// 사용자의 실력, 취약점, 목표에 따라 개인화된 학습 경로를 생성
class AdaptiveCurriculumGenerator {
  static const int maxWeeksInCurriculum = 12;
  static const int sessionsPerWeek = 3;
  static const double masteryThreshold = 0.85; // 85% 이상 숙련도
  static const double strugglingThreshold = 0.65; // 65% 미만 어려움
  
  /// 메인 커리큘럼 생성 메서드
  Future<AdaptiveCurriculum> generateCurriculum(CurriculumUserProfile userProfile) async {
    final weeks = <WeeklyCurriculum>[];
    
    for (int weekIndex = 0; weekIndex < maxWeeksInCurriculum; weekIndex++) {
      final week = await _generateWeeklyCurriculum(
        weekIndex + 1, 
        userProfile,
        weeks,
      );
      weeks.add(week);
    }
    
    return AdaptiveCurriculum(
      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      userProfile: userProfile,
      weeks: weeks,
      metadata: {
        'generator_version': '1.0',
        'generation_method': 'adaptive_ai',
        'total_estimated_hours': weeks.fold(0, (sum, week) => 
          sum + week.sessions.fold(0, (sessionSum, session) => 
            sessionSum + session.totalMinutes
          )
        ) ~/ 60,
      },
      estimatedCompletionRate: _calculateCompletionRate(userProfile),
    );
  }
  
  /// 주간 커리큘럼 생성
  Future<WeeklyCurriculum> _generateWeeklyCurriculum(
    int week, 
    CurriculumUserProfile userProfile,
    List<WeeklyCurriculum> previousWeeks,
  ) async {
    final theme = _getWeekTheme(week, userProfile);
    final sessions = <DailySession>[];
    
    for (int day = 1; day <= sessionsPerWeek; day++) {
      final session = _generateDailySession(
        day, 
        week, 
        userProfile, 
        theme,
        previousWeeks,
      );
      sessions.add(session);
    }
    
    return WeeklyCurriculum(
      week: week,
      theme: theme,
      sessions: sessions,
      goals: _getWeeklyGoals(week, userProfile, theme),
      expectedProgress: _calculateExpectedProgress(week, userProfile),
    );
  }
  
  /// 일일 세션 생성
  DailySession _generateDailySession(
    int day, 
    int week, 
    CurriculumUserProfile userProfile, 
    String theme,
    List<WeeklyCurriculum> previousWeeks,
  ) {
    final exercises = <ExerciseItem>[];
    final availableMinutes = userProfile.availableMinutesPerSession;
    int usedMinutes = 0;
    
    // 워밍업 (5-10분)
    exercises.add(_createWarmUpExercise(userProfile));
    usedMinutes += 8;
    
    // 메인 연습 (20-40분)
    final mainExercises = _createMainExercises(
      week, 
      day, 
      userProfile, 
      theme, 
      availableMinutes - usedMinutes - 5,
    );
    exercises.addAll(mainExercises);
    usedMinutes += mainExercises.fold(0, (sum, ex) => sum + ex.estimatedMinutes);
    
    // 쿨다운 (3-5분)
    exercises.add(_createCoolDownExercise(userProfile));
    usedMinutes += 4;
    
    return DailySession(
      day: day,
      title: '${theme} - Day $day',
      exercises: exercises,
      totalMinutes: usedMinutes,
      tips: _generateSessionTips(week, day, userProfile, theme),
    );
  }
  
  /// 워밍업 연습 생성
  ExerciseItem _createWarmUpExercise(CurriculumUserProfile userProfile) {
    return ExerciseItem(
      id: 'warmup_${DateTime.now().millisecondsSinceEpoch}',
      title: '보컬 워밍업',
      description: '목소리 준비와 긴장 완화를 위한 기본 워밍업',
      type: ExerciseType.scaleBasic,
      difficulty: DifficultyLevel.beginner,
      estimatedMinutes: 8,
      focusAreas: ['breathing', 'relaxation', 'vocal_preparation'],
      parameters: {
        'scale_type': 'major',
        'range': _getVoiceRange(userProfile.voiceType),
        'tempo': 'slow',
      },
      prerequisites: [],
    );
  }
  
  /// 메인 연습들 생성
  List<ExerciseItem> _createMainExercises(
    int week, 
    int day, 
    CurriculumUserProfile userProfile, 
    String theme, 
    int availableMinutes,
  ) {
    final exercises = <ExerciseItem>[];
    final primaryGoals = userProfile.goals.take(2).toList();
    
    for (final goal in primaryGoals) {
      final exercise = _createExerciseForGoal(
        goal, 
        week, 
        day, 
        userProfile, 
        availableMinutes ~/ primaryGoals.length,
      );
      exercises.add(exercise);
    }
    
    return exercises;
  }
  
  /// 목표별 연습 생성
  ExerciseItem _createExerciseForGoal(
    LearningGoal goal, 
    int week, 
    int day, 
    CurriculumUserProfile userProfile, 
    int minutes,
  ) {
    switch (goal) {
      case LearningGoal.pitchAccuracy:
        return _createPitchAccuracyExercise(week, day, userProfile, minutes);
      case LearningGoal.rangeExtension:
        return _createRangeExtensionExercise(week, day, userProfile, minutes);
      case LearningGoal.vibratoMastery:
        return _createVibratoExercise(week, day, userProfile, minutes);
      case LearningGoal.toneQuality:
        return _createToneQualityExercise(week, day, userProfile, minutes);
      case LearningGoal.rhythmStability:
        return _createRhythmExercise(week, day, userProfile, minutes);
      case LearningGoal.performance:
        return _createPerformanceExercise(week, day, userProfile, minutes);
    }
  }
  
  /// 음정 정확도 연습
  ExerciseItem _createPitchAccuracyExercise(
    int week, 
    int day, 
    CurriculumUserProfile userProfile, 
    int minutes,
  ) {
    final difficulty = _getProgressiveDifficulty(week, userProfile.currentLevel);
    
    return ExerciseItem(
      id: 'pitch_${week}_${day}_${DateTime.now().millisecondsSinceEpoch}',
      title: '음정 정확도 연습',
      description: '정확한 음정 감각을 기르는 연습',
      type: week <= 4 ? ExerciseType.scaleBasic : ExerciseType.interval,
      difficulty: difficulty,
      estimatedMinutes: minutes,
      focusAreas: ['pitch_accuracy', 'interval_recognition'],
      parameters: {
        'scale_type': week <= 2 ? 'major' : (week <= 6 ? 'minor' : 'chromatic'),
        'tempo': _getProgressiveTempo(week),
        'range': _getVoiceRange(userProfile.voiceType),
      },
      prerequisites: week > 1 ? ['basic_scale_mastery'] : [],
    );
  }
  
  /// 음역대 확장 연습
  ExerciseItem _createRangeExtensionExercise(
    int week, 
    int day, 
    CurriculumUserProfile userProfile, 
    int minutes,
  ) {
    return ExerciseItem(
      id: 'range_${week}_${day}_${DateTime.now().millisecondsSinceEpoch}',
      title: '음역대 확장',
      description: '안전하게 음역대를 넓히는 연습',
      type: ExerciseType.rangeExtension,
      difficulty: _getProgressiveDifficulty(week, userProfile.currentLevel),
      estimatedMinutes: minutes,
      focusAreas: ['range_extension', 'breath_support'],
      parameters: {
        'target_extension': week * 2, // 주차별 반음 확장
        'voice_type': userProfile.voiceType.toString(),
        'approach': week <= 6 ? 'gentle' : 'moderate',
      },
      prerequisites: week > 3 ? ['breath_control_mastery'] : [],
    );
  }
  
  /// 비브라토 연습
  ExerciseItem _createVibratoExercise(
    int week, 
    int day, 
    CurriculumUserProfile userProfile, 
    int minutes,
  ) {
    return ExerciseItem(
      id: 'vibrato_${week}_${day}_${DateTime.now().millisecondsSinceEpoch}',
      title: '비브라토 마스터리',
      description: '자연스럽고 균일한 비브라토 개발',
      type: ExerciseType.vibrato,
      difficulty: _getProgressiveDifficulty(week, userProfile.currentLevel),
      estimatedMinutes: minutes,
      focusAreas: ['vibrato_control', 'pitch_oscillation'],
      parameters: {
        'vibrato_rate': week <= 4 ? '4-5 Hz' : '5-6 Hz',
        'depth_control': week <= 6 ? 'shallow' : 'moderate',
        'sustain_duration': '${week + 2} seconds',
      },
      prerequisites: week > 2 ? ['pitch_stability'] : [],
    );
  }
  
  /// 음색 개선 연습
  ExerciseItem _createToneQualityExercise(
    int week, 
    int day, 
    CurriculumUserProfile userProfile, 
    int minutes,
  ) {
    return ExerciseItem(
      id: 'tone_${week}_${day}_${DateTime.now().millisecondsSinceEpoch}',
      title: '음색 개선',
      description: '풍부하고 깔끔한 음색 개발',
      type: ExerciseType.toneShaping,
      difficulty: _getProgressiveDifficulty(week, userProfile.currentLevel),
      estimatedMinutes: minutes,
      focusAreas: ['tone_quality', 'resonance'],
      parameters: {
        'focus_formants': week <= 4 ? 'F1_F2' : 'F1_F2_F3',
        'resonance_work': week <= 6 ? 'chest_head' : 'mixed_voice',
      },
      prerequisites: week > 1 ? ['basic_breath_support'] : [],
    );
  }
  
  /// 리듬 연습
  ExerciseItem _createRhythmExercise(
    int week, 
    int day, 
    CurriculumUserProfile userProfile, 
    int minutes,
  ) {
    return ExerciseItem(
      id: 'rhythm_${week}_${day}_${DateTime.now().millisecondsSinceEpoch}',
      title: '리듬 안정성',
      description: '정확하고 안정적인 리듬감 개발',
      type: ExerciseType.rhythmPattern,
      difficulty: _getProgressiveDifficulty(week, userProfile.currentLevel),
      estimatedMinutes: minutes,
      focusAreas: ['rhythm_stability', 'timing'],
      parameters: {
        'time_signature': week <= 4 ? '4/4' : (week <= 8 ? '3/4' : '6/8'),
        'complexity': week <= 6 ? 'simple' : 'syncopated',
      },
      prerequisites: [],
    );
  }
  
  /// 공연 연습
  ExerciseItem _createPerformanceExercise(
    int week, 
    int day, 
    CurriculumUserProfile userProfile, 
    int minutes,
  ) {
    return ExerciseItem(
      id: 'performance_${week}_${day}_${DateTime.now().millisecondsSinceEpoch}',
      title: '공연 실력 향상',
      description: '무대에서의 표현력과 안정감 개발',
      type: ExerciseType.songPractice,
      difficulty: _getProgressiveDifficulty(week, userProfile.currentLevel),
      estimatedMinutes: minutes,
      focusAreas: ['expression', 'stage_presence', 'song_interpretation'],
      parameters: {
        'song_difficulty': _getSongDifficulty(week, userProfile.currentLevel),
        'focus_aspect': week <= 4 ? 'technical' : 'expressive',
      },
      prerequisites: week > 6 ? ['technical_proficiency'] : [],
    );
  }
  
  /// 쿨다운 연습
  ExerciseItem _createCoolDownExercise(CurriculumUserProfile userProfile) {
    return ExerciseItem(
      id: 'cooldown_${DateTime.now().millisecondsSinceEpoch}',
      title: '쿨다운 & 정리',
      description: '목소리 이완과 세션 마무리',
      type: ExerciseType.scaleBasic,
      difficulty: DifficultyLevel.beginner,
      estimatedMinutes: 4,
      focusAreas: ['relaxation', 'vocal_rest'],
      parameters: {
        'activity': 'gentle_humming',
        'breathing': 'deep_relaxation',
      },
      prerequisites: [],
    );
  }
  
  /// 도우미 메서드들
  String _getWeekTheme(int week, CurriculumUserProfile userProfile) {
    final themes = [
      '기초 다지기', '음정 정확도', '호흡과 지지', '음색 개발',
      '음역대 확장', '비브라토 입문', '리듬과 타이밍', '표현력 개발',
      '고급 테크닉', '공연 준비', '개인 스타일', '마스터리'
    ];
    return themes[(week - 1) % themes.length];
  }
  
  List<String> _getWeeklyGoals(int week, CurriculumUserProfile userProfile, String theme) {
    return [
      '$theme 기본기 습득',
      '일정한 연습 루틴 유지',
      '이전 주 대비 ${10 + week * 2}% 향상',
    ];
  }
  
  Map<String, double> _calculateExpectedProgress(int week, CurriculumUserProfile userProfile) {
    final baseProgress = week * 0.05;
    return {
      'pitch_accuracy': math.min(1.0, baseProgress + 0.1),
      'tone_quality': math.min(1.0, baseProgress),
      'rhythm_stability': math.min(1.0, baseProgress + 0.08),
      'overall_proficiency': math.min(1.0, baseProgress + 0.05),
    };
  }
  
  DifficultyLevel _getProgressiveDifficulty(int week, DifficultyLevel userLevel) {
    if (week <= 4) return DifficultyLevel.beginner;
    if (week <= 8) return DifficultyLevel.intermediate;
    if (week <= 10) return DifficultyLevel.advanced;
    return DifficultyLevel.expert;
  }
  
  String _getProgressiveTempo(int week) {
    if (week <= 3) return 'slow';
    if (week <= 7) return 'moderate';
    return 'fast';
  }
  
  Map<String, int> _getVoiceRange(VoiceType voiceType) {
    switch (voiceType) {
      case VoiceType.soprano:
        return {'low': 60, 'high': 84}; // C4-C6
      case VoiceType.mezzSoprano:
        return {'low': 57, 'high': 81}; // A3-A5
      case VoiceType.alto:
        return {'low': 55, 'high': 79}; // G3-G5
      case VoiceType.tenor:
        return {'low': 48, 'high': 72}; // C3-C5
      case VoiceType.baritone:
        return {'low': 45, 'high': 69}; // A2-A4
      case VoiceType.bass:
        return {'low': 43, 'high': 67}; // G2-G4
      case VoiceType.unknown:
        return {'low': 50, 'high': 74}; // D3-D5
    }
  }
  
  String _getSongDifficulty(int week, DifficultyLevel userLevel) {
    if (week <= 4) return 'simple';
    if (week <= 8) return 'intermediate';
    return 'advanced';
  }
  
  double _calculateCompletionRate(CurriculumUserProfile userProfile) {
    double baseRate = 0.7; // 70% 기본 완성률
    
    // 경험 레벨에 따른 가중치
    switch (userProfile.currentLevel) {
      case DifficultyLevel.beginner:
        baseRate += 0.1;
        break;
      case DifficultyLevel.intermediate:
        baseRate += 0.05;
        break;
      case DifficultyLevel.advanced:
        baseRate -= 0.05;
        break;
      case DifficultyLevel.expert:
        baseRate -= 0.1;
        break;
    }
    
    // 연습 빈도에 따른 가중치
    if (userProfile.sessionsPerWeek >= 4) {
      baseRate += 0.1;
    } else if (userProfile.sessionsPerWeek <= 2) {
      baseRate -= 0.1;
    }
    
    return math.max(0.3, math.min(0.95, baseRate));
  }
  
  List<String> _generateSessionTips(
    int week, 
    int day, 
    CurriculumUserProfile userProfile, 
    String theme,
  ) {
    final tips = <String>[
      '연습 전 충분한 워밍업을 하세요',
      '목이 아프면 즉시 중단하고 휴식을 취하세요',
      '일정한 템포를 유지하며 연습하세요',
    ];
    
    // 주차별 특별 팁
    if (week <= 2) {
      tips.add('기초가 가장 중요합니다. 천천히 정확하게 연습하세요');
    } else if (week <= 6) {
      tips.add('새로운 기술을 배울 때는 인내심을 가지세요');
    } else {
      tips.add('지금까지의 성과를 되돌아보며 자신감을 키우세요');
    }
    
    return tips;
  }
}