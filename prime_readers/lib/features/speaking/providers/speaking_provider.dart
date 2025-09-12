import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/speaking_models.dart';
import '../services/speaking_service.dart';
import '../services/audio_recording_service.dart';
import '../services/ai_evaluation_service.dart';

// Services
final speakingServiceProvider = Provider<SpeakingService>((ref) {
  return SpeakingService();
});

final audioRecordingServiceProvider = Provider<AudioRecordingService>((ref) {
  return AudioRecordingService();
});

final aiEvaluationServiceProvider = Provider<AIEvaluationService>((ref) {
  return AIEvaluationService();
});

// Speaking Lessons
final speakingLessonsProvider = FutureProvider<List<SpeakingLesson>>((ref) async {
  final service = ref.read(speakingServiceProvider);
  return await service.getAllLessons();
});

final speakingLessonsByLevelProvider = 
    FutureProvider.family<List<SpeakingLesson>, SpeakingLevel>((ref, level) async {
  final service = ref.read(speakingServiceProvider);
  return await service.getLessonsByLevel(level);
});

final speakingLessonProvider = 
    FutureProvider.family<SpeakingLesson?, String>((ref, lessonId) async {
  final service = ref.read(speakingServiceProvider);
  return await service.getLessonById(lessonId);
});

// User Sessions
final userSpeakingSessionsProvider = 
    FutureProvider.family<List<SpeakingSession>, String>((ref, userId) async {
  final service = ref.read(speakingServiceProvider);
  return await service.getUserSessions(userId);
});

final speakingSessionProvider = 
    FutureProvider.family<SpeakingSession?, String>((ref, sessionId) async {
  final service = ref.read(speakingServiceProvider);
  return await service.getSessionById(sessionId);
});

// User Statistics
final speakingStatsProvider = 
    FutureProvider.family<SpeakingStats, String>((ref, userId) async {
  final service = ref.read(speakingServiceProvider);
  return await service.getUserStats(userId);
});

// Current Session State
class CurrentSpeakingSessionNotifier extends StateNotifier<SpeakingSession?> {
  CurrentSpeakingSessionNotifier(this._service) : super(null);

  final SpeakingService _service;

  Future<void> createSession(String userId, String lessonId) async {
    final session = await _service.createSession(userId, lessonId);
    state = session;
  }

  Future<void> addAttempt(SpeakingAttempt attempt) async {
    if (state == null) return;

    final updatedAttempts = [...state!.attempts, attempt];
    final updatedSession = state!.copyWith(attempts: updatedAttempts);
    
    await _service.updateSession(updatedSession);
    state = updatedSession;
  }

  Future<void> updateAttemptEvaluation(String attemptId, SpeakingEvaluation evaluation) async {
    if (state == null) return;

    final attemptIndex = state!.attempts.indexWhere((a) => a.id == attemptId);
    if (attemptIndex == -1) return;

    final updatedAttempts = [...state!.attempts];
    updatedAttempts[attemptIndex] = updatedAttempts[attemptIndex].copyWith(
      evaluation: evaluation,
    );

    final updatedSession = state!.copyWith(attempts: updatedAttempts);
    await _service.updateSession(updatedSession);
    state = updatedSession;
  }

  Future<void> completeSession() async {
    if (state == null) return;

    await _service.completeSession(state!.id);
    
    // 세션 상태 업데이트
    final completedSession = state!.copyWith(
      endTime: DateTime.now(),
      isCompleted: true,
    );
    state = completedSession;
  }

  void clearSession() {
    state = null;
  }
}

final currentSpeakingSessionProvider = 
    StateNotifierProvider<CurrentSpeakingSessionNotifier, SpeakingSession?>((ref) {
  final service = ref.read(speakingServiceProvider);
  return CurrentSpeakingSessionNotifier(service);
});

// Recording State
class RecordingStateNotifier extends StateNotifier<RecordingState> {
  RecordingStateNotifier(this._audioService) : super(RecordingState.idle) {
    _audioService.stateStream.listen((newState) {
      state = newState;
    });
  }

  final AudioRecordingService _audioService;

  Future<bool> startRecording() async {
    return await _audioService.startRecording();
  }

  Future<String?> stopRecording() async {
    return await _audioService.stopRecording();
  }

  Future<bool> pauseRecording() async {
    return await _audioService.pauseRecording();
  }

  Future<bool> resumeRecording() async {
    return await _audioService.resumeRecording();
  }

  Future<void> cancelRecording() async {
    await _audioService.cancelRecording();
  }
}

final recordingStateProvider = 
    StateNotifierProvider<RecordingStateNotifier, RecordingState>((ref) {
  final audioService = ref.read(audioRecordingServiceProvider);
  return RecordingStateNotifier(audioService);
});

// Recording Duration Stream
final recordingDurationProvider = StreamProvider<Duration>((ref) {
  final audioService = ref.read(audioRecordingServiceProvider);
  return audioService.durationStream;
});

// Recording Amplitude Stream
final recordingAmplitudeProvider = StreamProvider<double>((ref) {
  final audioService = ref.read(audioRecordingServiceProvider);
  return audioService.amplitudeStream;
});

// Current Exercise State for Practice
class CurrentExerciseNotifier extends StateNotifier<SpeakingExercise?> {
  CurrentExerciseNotifier() : super(null);

  void setExercise(SpeakingExercise exercise) {
    state = exercise;
  }

  void clearExercise() {
    state = null;
  }
}

final currentExerciseProvider = 
    StateNotifierProvider<CurrentExerciseNotifier, SpeakingExercise?>((ref) {
  return CurrentExerciseNotifier();
});

// Exercise Attempts for Current Exercise
final exerciseAttemptsProvider = 
    FutureProvider.family<List<SpeakingAttempt>, String>((ref, exerciseId) async {
  final service = ref.read(speakingServiceProvider);
  return await service.getExerciseAttempts(exerciseId);
});

// Evaluation State
class EvaluationNotifier extends StateNotifier<AsyncValue<SpeakingEvaluation?>> {
  EvaluationNotifier(this._evaluationService) : super(const AsyncValue.data(null));

  final AIEvaluationService _evaluationService;

  Future<void> evaluateRecording({
    required String audioFilePath,
    required String expectedText,
    required List<String> keyWords,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final evaluation = await _evaluationService.evaluatePronunciation(
        audioFilePath: audioFilePath,
        expectedText: expectedText,
        keyWords: keyWords,
      );
      state = AsyncValue.data(evaluation);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearEvaluation() {
    state = const AsyncValue.data(null);
  }
}

final evaluationProvider = 
    StateNotifierProvider<EvaluationNotifier, AsyncValue<SpeakingEvaluation?>>((ref) {
  final evaluationService = ref.read(aiEvaluationServiceProvider);
  return EvaluationNotifier(evaluationService);
});

// Lesson Progress
class LessonProgressNotifier extends StateNotifier<Map<String, double>> {
  LessonProgressNotifier() : super({});

  void updateProgress(String lessonId, double progress) {
    state = {
      ...state,
      lessonId: progress,
    };
  }

  double getProgress(String lessonId) {
    return state[lessonId] ?? 0.0;
  }
}

final lessonProgressProvider = 
    StateNotifierProvider<LessonProgressNotifier, Map<String, double>>((ref) {
  return LessonProgressNotifier();
});

// Speaking Controller (Main business logic coordinator)
class SpeakingControllerNotifier extends StateNotifier<AsyncValue<void>> {
  SpeakingControllerNotifier(
    this._speakingService,
    this._audioService,
    this._evaluationService,
  ) : super(const AsyncValue.data(null));

  final SpeakingService _speakingService;
  final AudioRecordingService _audioService;
  final AIEvaluationService _evaluationService;

  // 연습 세션 시작
  Future<void> startPracticeSession(String userId, String lessonId) async {
    state = const AsyncValue.loading();
    
    try {
      await _speakingService.createSession(userId, lessonId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // 녹음 및 평가 수행
  Future<SpeakingEvaluation?> recordAndEvaluate({
    required SpeakingExercise exercise,
    required int attemptNumber,
  }) async {
    try {
      // 1. 녹음 시작
      final recordingStarted = await _audioService.startRecording();
      if (!recordingStarted) {
        throw Exception('Failed to start recording');
      }

      // 녹음은 사용자가 수동으로 정지할 때까지 계속됨
      // UI에서 stopRecording()을 호출해야 함
      
      return null; // 녹음 중이므로 아직 평가 없음
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  // 녹음 완료 후 평가
  Future<SpeakingEvaluation?> finishRecordingAndEvaluate({
    required SpeakingExercise exercise,
    required int attemptNumber,
  }) async {
    try {
      // 1. 녹음 정지
      final recordingPath = await _audioService.stopRecording();
      if (recordingPath == null) {
        throw Exception('No recording found');
      }

      // 2. 시도 저장
      final attempt = await _speakingService.saveAttempt(
        exerciseId: exercise.id,
        recordingPath: recordingPath,
        recordingDuration: _audioService.recordingDuration,
        attemptNumber: attemptNumber,
      );

      // 3. AI 평가 수행
      final evaluation = await _evaluationService.evaluatePronunciation(
        audioFilePath: recordingPath,
        expectedText: exercise.text,
        keyWords: exercise.keyWords,
      );

      // 4. 평가 결과 저장
      await _speakingService.updateAttemptWithEvaluation(attempt.id, evaluation);

      return evaluation;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  // 샘플 데이터 추가 (개발용)
  Future<void> addSampleData(String userId) async {
    try {
      // 이미 데이터가 있는지 확인
      final lessons = await _speakingService.getAllLessons();
      if (lessons.isNotEmpty) return;

      // 서비스에서 샘플 데이터 생성 (이미 구현됨)
      await _speakingService.initialize();
      
    } catch (error) {
      print('Sample data creation error: $error');
    }
  }
}

final speakingControllerProvider = 
    StateNotifierProvider<SpeakingControllerNotifier, AsyncValue<void>>((ref) {
  final speakingService = ref.read(speakingServiceProvider);
  final audioService = ref.read(audioRecordingServiceProvider);
  final evaluationService = ref.read(aiEvaluationServiceProvider);
  
  return SpeakingControllerNotifier(
    speakingService,
    audioService,
    evaluationService,
  );
});