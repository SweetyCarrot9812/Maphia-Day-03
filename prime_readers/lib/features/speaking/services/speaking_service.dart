import 'dart:io';
import 'dart:typed_data';
import 'package:hive/hive.dart';
import '../models/speaking_models.dart';

class SpeakingService {
  static const String _lessonsBoxName = 'speaking_lessons';
  static const String _sessionsBoxName = 'speaking_sessions';
  static const String _attemptsBoxName = 'speaking_attempts';

  late Box<SpeakingLesson> _lessonsBox;
  late Box<SpeakingSession> _sessionsBox;
  late Box<SpeakingAttempt> _attemptsBox;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _lessonsBox = await Hive.openBox<SpeakingLesson>(_lessonsBoxName);
    _sessionsBox = await Hive.openBox<SpeakingSession>(_sessionsBoxName);
    _attemptsBox = await Hive.openBox<SpeakingAttempt>(_attemptsBoxName);

    // 샘플 데이터가 없으면 추가
    if (_lessonsBox.isEmpty) {
      await _addSampleLessons();
    }

    _isInitialized = true;
  }

  // 레슨 관리
  Future<List<SpeakingLesson>> getAllLessons() async {
    await initialize();
    return _lessonsBox.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<List<SpeakingLesson>> getLessonsByLevel(SpeakingLevel level) async {
    await initialize();
    return _lessonsBox.values
        .where((lesson) => lesson.level == level)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<SpeakingLesson?> getLessonById(String id) async {
    await initialize();
    return _lessonsBox.get(id);
  }

  Future<void> saveLesson(SpeakingLesson lesson) async {
    await initialize();
    await _lessonsBox.put(lesson.id, lesson);
  }

  // 세션 관리
  Future<SpeakingSession> createSession(String userId, String lessonId) async {
    await initialize();
    
    final session = SpeakingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      lessonId: lessonId,
      startTime: DateTime.now(),
      attempts: [],
    );

    await _sessionsBox.put(session.id, session);
    return session;
  }

  Future<void> updateSession(SpeakingSession session) async {
    await initialize();
    await _sessionsBox.put(session.id, session);
  }

  Future<SpeakingSession?> getSessionById(String id) async {
    await initialize();
    return _sessionsBox.get(id);
  }

  Future<List<SpeakingSession>> getUserSessions(String userId) async {
    await initialize();
    return _sessionsBox.values
        .where((session) => session.userId == userId)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  // 시도 관리
  Future<SpeakingAttempt> saveAttempt({
    required String exerciseId,
    required String recordingPath,
    required Duration recordingDuration,
    required int attemptNumber,
  }) async {
    await initialize();

    final attempt = SpeakingAttempt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exerciseId: exerciseId,
      recordingPath: recordingPath,
      recordedAt: DateTime.now(),
      recordingDuration: recordingDuration,
      attemptNumber: attemptNumber,
    );

    await _attemptsBox.put(attempt.id, attempt);
    return attempt;
  }

  Future<void> updateAttemptWithEvaluation(
    String attemptId,
    SpeakingEvaluation evaluation,
  ) async {
    await initialize();
    
    final attempt = _attemptsBox.get(attemptId);
    if (attempt != null) {
      final updatedAttempt = attempt.copyWith(evaluation: evaluation);
      await _attemptsBox.put(attemptId, updatedAttempt);
    }
  }

  Future<List<SpeakingAttempt>> getExerciseAttempts(String exerciseId) async {
    await initialize();
    return _attemptsBox.values
        .where((attempt) => attempt.exerciseId == exerciseId)
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  // 통계
  Future<SpeakingStats> getUserStats(String userId) async {
    await initialize();
    
    final userSessions = await getUserSessions(userId);
    final completedSessions = userSessions.where((s) => s.isCompleted).toList();
    
    final allLessons = await getAllLessons();
    final completedLessonIds = completedSessions.map((s) => s.lessonId).toSet();
    final completedLessons = allLessons.where((l) => completedLessonIds.contains(l.id)).toList();

    final totalAttempts = userSessions
        .expand((session) => session.attempts)
        .length;

    final scores = completedSessions
        .where((session) => session.overallScore != null)
        .map((session) => session.overallScore!)
        .toList();

    final averageScore = scores.isNotEmpty 
        ? scores.reduce((a, b) => a + b) / scores.length 
        : 0.0;

    final totalPracticeTime = userSessions
        .where((session) => session.duration != null)
        .map((session) => session.duration!)
        .fold(Duration.zero, (total, duration) => total + duration);

    final lessonsByLevel = <SpeakingLevel, int>{};
    for (final level in SpeakingLevel.values) {
      lessonsByLevel[level] = completedLessons
          .where((lesson) => lesson.level == level)
          .length;
    }

    final lastPracticeDate = userSessions.isNotEmpty
        ? userSessions.first.startTime
        : DateTime.now();

    final recentScores = scores.take(10).toList()..sort((a, b) => b.compareTo(a));

    return SpeakingStats(
      totalLessons: allLessons.length,
      completedLessons: completedLessons.length,
      totalAttempts: totalAttempts,
      averageScore: averageScore,
      totalPracticeTime: totalPracticeTime,
      lastPracticeDate: lastPracticeDate,
      lessonsByLevel: lessonsByLevel,
      recentScores: recentScores,
    );
  }

  // 완료된 세션의 전체 점수 계산
  Future<void> completeSession(String sessionId) async {
    await initialize();
    
    final session = await getSessionById(sessionId);
    if (session == null) return;

    final attempts = session.attempts;
    if (attempts.isEmpty) return;

    final evaluatedAttempts = attempts
        .where((attempt) => attempt.evaluation != null)
        .toList();

    if (evaluatedAttempts.isEmpty) return;

    final overallScore = evaluatedAttempts
        .map((attempt) => attempt.evaluation!.overallScore)
        .reduce((a, b) => a + b) / evaluatedAttempts.length;

    final completedSession = session.copyWith(
      endTime: DateTime.now(),
      overallScore: overallScore,
      isCompleted: true,
    );

    await updateSession(completedSession);

    // 레슨의 평균 점수도 업데이트
    await _updateLessonAverageScore(session.lessonId);
  }

  Future<void> _updateLessonAverageScore(String lessonId) async {
    final lesson = await getLessonById(lessonId);
    if (lesson == null) return;

    final lessonSessions = _sessionsBox.values
        .where((session) => session.lessonId == lessonId && 
                           session.isCompleted && 
                           session.overallScore != null)
        .toList();

    if (lessonSessions.isEmpty) return;

    final averageScore = lessonSessions
        .map((session) => session.overallScore!)
        .reduce((a, b) => a + b) / lessonSessions.length;

    final updatedLesson = lesson.copyWith(
      averageScore: averageScore,
      isCompleted: lessonSessions.isNotEmpty,
    );

    await saveLesson(updatedLesson);
  }

  // 샘플 데이터 생성
  Future<void> _addSampleLessons() async {
    final sampleLessons = [
      SpeakingLesson(
        id: 'lesson-001',
        title: '기본 인사말',
        description: '영어로 인사하는 기본적인 표현들을 연습합니다',
        level: SpeakingLevel.beginner,
        estimatedMinutes: 10,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        exercises: [
          SpeakingExercise(
            id: 'exercise-001',
            text: 'Hello, how are you?',
            phoneticTranscription: '/həˈloʊ, haʊ ɑːr juː/',
            audioUrl: 'assets/audio/hello_how_are_you.mp3',
            order: 1,
            keyWords: ['Hello', 'how', 'are', 'you'],
            hint: '자연스럽고 친근한 톤으로 말해보세요',
          ),
          SpeakingExercise(
            id: 'exercise-002',
            text: 'Nice to meet you',
            phoneticTranscription: '/naɪs tuː miːt juː/',
            audioUrl: 'assets/audio/nice_to_meet_you.mp3',
            order: 2,
            keyWords: ['Nice', 'meet', 'you'],
            hint: '\'meet\'의 [i:] 소리를 길게 발음하세요',
          ),
        ],
      ),
      SpeakingLesson(
        id: 'lesson-002',
        title: '일상 대화',
        description: '일상에서 자주 사용하는 영어 표현을 학습합니다',
        level: SpeakingLevel.intermediate,
        estimatedMinutes: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        exercises: [
          SpeakingExercise(
            id: 'exercise-003',
            text: 'What are you doing this weekend?',
            phoneticTranscription: '/wʌt ɑːr juː ˈduːɪŋ ðɪs ˈwiːkend/',
            audioUrl: 'assets/audio/weekend_plans.mp3',
            order: 1,
            keyWords: ['What', 'doing', 'weekend'],
            hint: '연결음에 주의하며 자연스럽게 말해보세요',
          ),
        ],
      ),
      SpeakingLesson(
        id: 'lesson-003',
        title: '비즈니스 영어',
        description: '업무 상황에서 사용하는 전문적인 영어 표현',
        level: SpeakingLevel.advanced,
        estimatedMinutes: 20,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        exercises: [
          SpeakingExercise(
            id: 'exercise-004',
            text: 'I would like to schedule a meeting',
            phoneticTranscription: '/aɪ wʊd laɪk tuː ˈʃedjuːl ə ˈmiːtɪŋ/',
            audioUrl: 'assets/audio/schedule_meeting.mp3',
            order: 1,
            keyWords: ['schedule', 'meeting'],
            hint: '정중하고 명확한 발음으로 말해보세요',
          ),
        ],
      ),
    ];

    for (final lesson in sampleLessons) {
      await saveLesson(lesson);
    }
  }

  // 정리
  Future<void> dispose() async {
    await _lessonsBox.close();
    await _sessionsBox.close();
    await _attemptsBox.close();
  }
}