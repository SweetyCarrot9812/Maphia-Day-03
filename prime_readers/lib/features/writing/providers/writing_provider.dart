import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/writing_models.dart';
import '../services/writing_service.dart';
import '../services/ocr_service.dart';
import '../services/ai_correction_service.dart';

// 서비스 프로바이더
final writingServiceProvider = Provider<WritingService>((ref) {
  return WritingService();
});

final ocrServiceProvider = Provider<OCRService>((ref) {
  return OCRService();
});

final aiCorrectionServiceProvider = Provider<AICorrectionService>((ref) {
  return AICorrectionService(
    // 실제 API 키는 환경변수나 설정에서 가져와야 함
    // openAIApiKey: 'your-openai-api-key',
    // geminiApiKey: 'your-gemini-api-key',
  );
});

// 상태 프로바이더들
final writingTasksProvider = FutureProvider<List<WritingTask>>((ref) async {
  final service = ref.read(writingServiceProvider);
  return service.getTasks();
});

final writingTasksByTypeProvider = FutureProvider.family<List<WritingTask>, WritingTaskType?>((ref, type) async {
  final service = ref.read(writingServiceProvider);
  return service.getTasks(type: type);
});

final writingTasksByDifficultyProvider = FutureProvider.family<List<WritingTask>, DifficultyLevel?>((ref, difficulty) async {
  final service = ref.read(writingServiceProvider);
  return service.getTasks(difficulty: difficulty);
});

final userWritingSubmissionsProvider = FutureProvider.family<List<WritingSubmission>, String>((ref, userId) async {
  final service = ref.read(writingServiceProvider);
  return service.getSubmissions(userId);
});

final userWritingStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final service = ref.read(writingServiceProvider);
  return service.getUserStats(userId);
});

final activeWritingSessionProvider = FutureProvider.family<WritingSession?, String>((ref, userId) async {
  final service = ref.read(writingServiceProvider);
  return service.getActiveSession(userId);
});

// 라이팅 컨트롤러 NotifierProvider
final writingControllerProvider = StateNotifierProvider<WritingController, WritingState>((ref) {
  return WritingController(
    writingService: ref.read(writingServiceProvider),
    ocrService: ref.read(ocrServiceProvider),
    aiCorrectionService: ref.read(aiCorrectionServiceProvider),
  );
});

// 라이팅 상태
class WritingState {
  final WritingSession? currentSession;
  final String currentContent;
  final int wordCount;
  final List<WritingError> realtimeErrors;
  final WritingEvaluation? lastEvaluation;
  final bool isProcessing;
  final bool isRecognizingOCR;
  final String? error;
  final OCRResult? lastOCRResult;

  WritingState({
    this.currentSession,
    this.currentContent = '',
    this.wordCount = 0,
    this.realtimeErrors = const [],
    this.lastEvaluation,
    this.isProcessing = false,
    this.isRecognizingOCR = false,
    this.error,
    this.lastOCRResult,
  });

  WritingState copyWith({
    WritingSession? currentSession,
    String? currentContent,
    int? wordCount,
    List<WritingError>? realtimeErrors,
    WritingEvaluation? lastEvaluation,
    bool? isProcessing,
    bool? isRecognizingOCR,
    String? error,
    OCRResult? lastOCRResult,
  }) {
    return WritingState(
      currentSession: currentSession ?? this.currentSession,
      currentContent: currentContent ?? this.currentContent,
      wordCount: wordCount ?? this.wordCount,
      realtimeErrors: realtimeErrors ?? this.realtimeErrors,
      lastEvaluation: lastEvaluation ?? this.lastEvaluation,
      isProcessing: isProcessing ?? this.isProcessing,
      isRecognizingOCR: isRecognizingOCR ?? this.isRecognizingOCR,
      error: error ?? this.error,
      lastOCRResult: lastOCRResult ?? this.lastOCRResult,
    );
  }
}

// 라이팅 컨트롤러
class WritingController extends StateNotifier<WritingState> {
  final WritingService _writingService;
  final OCRService _ocrService;
  final AICorrectionService _aiCorrectionService;

  WritingController({
    required WritingService writingService,
    required OCRService ocrService,
    required AICorrectionService aiCorrectionService,
  }) : _writingService = writingService,
       _ocrService = ocrService,
       _aiCorrectionService = aiCorrectionService,
       super(WritingState());

  // 새로운 라이팅 세션 시작
  Future<void> startWritingSession(String userId, String taskId) async {
    try {
      state = state.copyWith(isProcessing: true, error: null);
      
      final session = await _writingService.startSession(userId, taskId);
      
      state = state.copyWith(
        currentSession: session,
        currentContent: '',
        wordCount: 0,
        realtimeErrors: [],
        lastEvaluation: null,
        isProcessing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to start writing session: $e',
      );
    }
  }

  // 텍스트 내용 업데이트
  void updateContent(String content) {
    final wordCount = content.split(' ').where((word) => word.isNotEmpty).length;
    
    state = state.copyWith(
      currentContent: content,
      wordCount: wordCount,
    );

    // 세션이 있으면 업데이트
    if (state.currentSession != null) {
      _updateSessionContent(content, wordCount);
    }

    // 실시간 문법 검사
    _performRealtimeGrammarCheck(content);
  }

  // 세션 내용 업데이트
  Future<void> _updateSessionContent(String content, int wordCount) async {
    if (state.currentSession == null) return;

    final updatedSession = WritingSession(
      id: state.currentSession!.id,
      userId: state.currentSession!.userId,
      taskId: state.currentSession!.taskId,
      startedAt: state.currentSession!.startedAt,
      endedAt: state.currentSession!.endedAt,
      duration: state.currentSession!.duration,
      currentContent: content,
      currentWordCount: wordCount,
      actions: state.currentSession!.actions,
      status: state.currentSession!.status,
      submissionId: state.currentSession!.submissionId,
    );

    await _writingService.updateSession(updatedSession);
    
    state = state.copyWith(currentSession: updatedSession);
  }

  // 실시간 문법 검사
  Future<void> _performRealtimeGrammarCheck(String content) async {
    if (content.isEmpty) {
      state = state.copyWith(realtimeErrors: []);
      return;
    }

    try {
      final errors = await _aiCorrectionService.checkGrammarRealtime(content);
      state = state.copyWith(realtimeErrors: errors);
    } catch (e) {
      // 실시간 검사 실패는 조용히 처리
      print('Realtime grammar check failed: $e');
    }
  }

  // 세션 행동 기록
  Future<void> recordAction(WritingActionType actionType, {
    String? content,
    int? position,
    Map<String, dynamic>? metadata,
  }) async {
    if (state.currentSession == null) return;

    await _writingService.addSessionAction(
      sessionId: state.currentSession!.id,
      type: actionType,
      content: content,
      position: position,
      metadata: metadata,
    );
  }

  // 손글씨 이미지에서 텍스트 인식
  Future<void> recognizeTextFromImage(String imagePath) async {
    try {
      state = state.copyWith(isRecognizingOCR: true, error: null);
      
      final ocrResult = await _ocrService.recognizeTextFromImage(imagePath);
      
      // OCR 결과로 내용 업데이트
      updateContent(ocrResult.text);
      
      state = state.copyWith(
        isRecognizingOCR: false,
        lastOCRResult: ocrResult,
      );

      // OCR 행동 기록
      await recordAction(
        WritingActionType.pasted,
        content: ocrResult.text,
        metadata: {
          'source': 'ocr',
          'confidence': ocrResult.confidence,
          'method': ocrResult.method.name,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isRecognizingOCR: false,
        error: 'OCR failed: $e',
      );
    }
  }

  // 라이팅 제출
  Future<WritingSubmission?> submitWriting({
    required WritingInputMethod inputMethod,
    String? handwritingImageUrl,
  }) async {
    if (state.currentSession == null) {
      state = state.copyWith(error: 'No active session');
      return null;
    }

    try {
      state = state.copyWith(isProcessing: true, error: null);

      final submission = await _writingService.submitWriting(
        sessionId: state.currentSession!.id,
        content: state.currentContent,
        inputMethod: inputMethod,
        handwritingImageUrl: handwritingImageUrl,
        ocrText: state.lastOCRResult?.text,
        ocrConfidence: state.lastOCRResult?.confidence,
      );

      // 세션 종료
      await _writingService.endSession(state.currentSession!.id);

      // 제출 행동 기록
      await recordAction(WritingActionType.submitted, content: state.currentContent);

      state = state.copyWith(
        isProcessing: false,
        currentSession: null,
      );

      return submission;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to submit writing: $e',
      );
      return null;
    }
  }

  // AI 평가 요청
  Future<void> requestEvaluation(WritingSubmission submission, WritingTask task) async {
    try {
      state = state.copyWith(isProcessing: true, error: null);

      final evaluation = await _aiCorrectionService.evaluateWriting(
        submissionId: submission.id,
        content: submission.content,
        task: task,
        ocrText: submission.ocrText,
      );

      // 제출물에 평가 결과 추가
      await _writingService.updateSubmissionWithEvaluation(submission.id, evaluation);

      state = state.copyWith(
        isProcessing: false,
        lastEvaluation: evaluation,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to evaluate writing: $e',
      );
    }
  }

  // 세션 일시정지
  Future<void> pauseSession() async {
    if (state.currentSession == null) return;

    await recordAction(WritingActionType.paused);

    final pausedSession = WritingSession(
      id: state.currentSession!.id,
      userId: state.currentSession!.userId,
      taskId: state.currentSession!.taskId,
      startedAt: state.currentSession!.startedAt,
      endedAt: state.currentSession!.endedAt,
      duration: state.currentSession!.duration,
      currentContent: state.currentSession!.currentContent,
      currentWordCount: state.currentSession!.currentWordCount,
      actions: state.currentSession!.actions,
      status: WritingSessionStatus.paused,
      submissionId: state.currentSession!.submissionId,
    );

    await _writingService.updateSession(pausedSession);
    state = state.copyWith(currentSession: pausedSession);
  }

  // 세션 재개
  Future<void> resumeSession() async {
    if (state.currentSession == null) return;

    await recordAction(WritingActionType.resumed);

    final activeSession = WritingSession(
      id: state.currentSession!.id,
      userId: state.currentSession!.userId,
      taskId: state.currentSession!.taskId,
      startedAt: state.currentSession!.startedAt,
      endedAt: state.currentSession!.endedAt,
      duration: state.currentSession!.duration,
      currentContent: state.currentSession!.currentContent,
      currentWordCount: state.currentSession!.currentWordCount,
      actions: state.currentSession!.actions,
      status: WritingSessionStatus.active,
      submissionId: state.currentSession!.submissionId,
    );

    await _writingService.updateSession(activeSession);
    state = state.copyWith(currentSession: activeSession);
  }

  // 세션 포기
  Future<void> abandonSession() async {
    if (state.currentSession == null) return;

    final abandonedSession = WritingSession(
      id: state.currentSession!.id,
      userId: state.currentSession!.userId,
      taskId: state.currentSession!.taskId,
      startedAt: state.currentSession!.startedAt,
      endedAt: DateTime.now(),
      duration: DateTime.now().difference(state.currentSession!.startedAt),
      currentContent: state.currentSession!.currentContent,
      currentWordCount: state.currentSession!.currentWordCount,
      actions: state.currentSession!.actions,
      status: WritingSessionStatus.abandoned,
      submissionId: state.currentSession!.submissionId,
    );

    await _writingService.updateSession(abandonedSession);
    
    state = WritingState(); // 상태 초기화
  }

  // 오류 지우기
  void clearError() {
    state = state.copyWith(error: null);
  }

  // 세션 리셋
  void resetSession() {
    state = WritingState();
  }
}