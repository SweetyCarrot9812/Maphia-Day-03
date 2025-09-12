import 'package:hive/hive.dart';
import '../models/writing_models.dart';

class WritingService {
  static const String _tasksBoxName = 'writing_tasks';
  static const String _submissionsBoxName = 'writing_submissions';
  static const String _sessionsBoxName = 'writing_sessions';
  
  late Box<WritingTask> _tasksBox;
  late Box<WritingSubmission> _submissionsBox;
  late Box<WritingSession> _sessionsBox;

  Future<void> initialize() async {
    _tasksBox = await Hive.openBox<WritingTask>(_tasksBoxName);
    _submissionsBox = await Hive.openBox<WritingSubmission>(_submissionsBoxName);
    _sessionsBox = await Hive.openBox<WritingSession>(_sessionsBoxName);
    
    await addSampleData();
  }

  // 샘플 데이터 추가
  Future<void> addSampleData() async {
    if (_tasksBox.isEmpty) {
      final sampleTasks = [
        WritingTask(
          id: 'task_001',
          title: '내가 좋아하는 계절',
          description: '자신이 가장 좋아하는 계절에 대해 써보세요.',
          prompt: '당신이 가장 좋아하는 계절은 무엇인가요? 그 계절을 좋아하는 이유와 그 계절에 하는 활동에 대해 100-200단어로 작성해보세요.',
          type: WritingTaskType.essay,
          difficulty: DifficultyLevel.beginner,
          maxWords: 200,
          minWords: 100,
          timeLimit: const Duration(minutes: 30),
          keyPoints: ['계절 선택', '좋아하는 이유', '계절별 활동', '개인적 경험'],
          vocabularyHints: ['spring', 'summer', 'autumn', 'winter', 'weather', 'activities', 'beautiful', 'enjoy'],
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        WritingTask(
          id: 'task_002',
          title: '나의 꿈',
          description: '미래의 꿈과 목표에 대해 작성해보세요.',
          prompt: '당신의 미래 꿈은 무엇인가요? 그 꿈을 이루기 위해 어떤 노력을 하고 있는지 150-300단어로 작성해보세요.',
          type: WritingTaskType.essay,
          difficulty: DifficultyLevel.intermediate,
          maxWords: 300,
          minWords: 150,
          timeLimit: const Duration(minutes: 45),
          keyPoints: ['미래 꿈', '목표 설정', '현재 노력', '계획'],
          vocabularyHints: ['dream', 'future', 'goal', 'career', 'education', 'effort', 'achieve', 'plan'],
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        WritingTask(
          id: 'task_003',
          title: '친구에게 보내는 편지',
          description: '멀리 있는 친구에게 편지를 써보세요.',
          prompt: '멀리 살고 있는 친구에게 근황을 알리는 편지를 써보세요. 최근에 있었던 일과 친구를 그리워하는 마음을 담아 작성해주세요.',
          type: WritingTaskType.letter,
          difficulty: DifficultyLevel.beginner,
          maxWords: 250,
          minWords: 150,
          timeLimit: const Duration(minutes: 40),
          keyPoints: ['인사말', '근황 공유', '그리움 표현', '마무리 인사'],
          vocabularyHints: ['dear', 'friend', 'miss', 'recently', 'news', 'hope', 'see you soon'],
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        WritingTask(
          id: 'task_004',
          title: '여행 후기',
          description: '최근에 다녀온 여행에 대한 후기를 작성해보세요.',
          prompt: '최근에 다녀온 여행지에 대한 후기를 작성해보세요. 여행지의 특징, 인상 깊었던 경험, 추천 이유 등을 포함해주세요.',
          type: WritingTaskType.review,
          difficulty: DifficultyLevel.intermediate,
          maxWords: 400,
          minWords: 200,
          timeLimit: const Duration(minutes: 60),
          keyPoints: ['여행지 소개', '경험 공유', '감상 서술', '추천 여부'],
          vocabularyHints: ['travel', 'destination', 'experience', 'beautiful', 'culture', 'food', 'recommend'],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        WritingTask(
          id: 'task_005',
          title: '창작 이야기',
          description: '주어진 첫 문장으로 시작하는 짧은 이야기를 만들어보세요.',
          prompt: '"문을 열자 예상치 못한 광경이 펼쳐졌다."로 시작하는 창작 이야기를 써보세요. 상상력을 발휘해 흥미로운 스토리를 만들어주세요.',
          type: WritingTaskType.creative,
          difficulty: DifficultyLevel.advanced,
          maxWords: 500,
          minWords: 300,
          timeLimit: const Duration(minutes: 90),
          keyPoints: ['흥미로운 시작', '상황 전개', '갈등 요소', '적절한 마무리'],
          vocabularyHints: ['unexpected', 'scene', 'surprised', 'mysterious', 'adventure', 'character', 'plot'],
          createdAt: DateTime.now(),
        ),
      ];
      
      for (final task in sampleTasks) {
        await _tasksBox.put(task.id, task);
      }
    }
  }

  // 과제 목록 조회
  List<WritingTask> getTasks({WritingTaskType? type, DifficultyLevel? difficulty}) {
    var tasks = _tasksBox.values.toList();
    
    if (type != null) {
      tasks = tasks.where((task) => task.type == type).toList();
    }
    
    if (difficulty != null) {
      tasks = tasks.where((task) => task.difficulty == difficulty).toList();
    }
    
    // 생성일 기준 내림차순 정렬
    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return tasks;
  }

  // 특정 과제 조회
  WritingTask? getTask(String taskId) {
    return _tasksBox.get(taskId);
  }

  // 새로운 세션 시작
  Future<WritingSession> startSession(String userId, String taskId) async {
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final session = WritingSession(
      id: sessionId,
      userId: userId,
      taskId: taskId,
      startedAt: DateTime.now(),
      duration: Duration.zero,
      currentContent: '',
      currentWordCount: 0,
      actions: [],
      status: WritingSessionStatus.active,
    );
    
    await _sessionsBox.put(sessionId, session);
    return session;
  }

  // 세션 업데이트
  Future<void> updateSession(WritingSession session) async {
    await _sessionsBox.put(session.id, session);
  }

  // 세션 종료
  Future<WritingSession> endSession(String sessionId) async {
    final session = _sessionsBox.get(sessionId);
    if (session == null) {
      throw Exception('Session not found');
    }
    
    final endedAt = DateTime.now();
    final updatedSession = WritingSession(
      id: session.id,
      userId: session.userId,
      taskId: session.taskId,
      startedAt: session.startedAt,
      endedAt: endedAt,
      duration: endedAt.difference(session.startedAt),
      currentContent: session.currentContent,
      currentWordCount: session.currentWordCount,
      actions: session.actions,
      status: WritingSessionStatus.completed,
      submissionId: session.submissionId,
    );
    
    await _sessionsBox.put(sessionId, updatedSession);
    return updatedSession;
  }

  // 제출물 저장
  Future<WritingSubmission> submitWriting({
    required String sessionId,
    required String content,
    required WritingInputMethod inputMethod,
    String? handwritingImageUrl,
    String? ocrText,
    double? ocrConfidence,
  }) async {
    final session = _sessionsBox.get(sessionId);
    if (session == null) {
      throw Exception('Session not found');
    }
    
    final submissionId = 'submission_${DateTime.now().millisecondsSinceEpoch}';
    final submission = WritingSubmission(
      id: submissionId,
      taskId: session.taskId,
      userId: session.userId,
      content: content,
      inputMethod: inputMethod,
      handwritingImageUrl: handwritingImageUrl,
      ocrText: ocrText,
      ocrConfidence: ocrConfidence,
      submittedAt: DateTime.now(),
      timeSpent: session.duration,
      wordCount: content.split(' ').where((word) => word.isNotEmpty).length,
      status: WritingStatus.submitted,
    );
    
    await _submissionsBox.put(submissionId, submission);
    
    // 세션에 제출물 ID 연결
    final updatedSession = WritingSession(
      id: session.id,
      userId: session.userId,
      taskId: session.taskId,
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      duration: session.duration,
      currentContent: session.currentContent,
      currentWordCount: session.currentWordCount,
      actions: session.actions,
      status: session.status,
      submissionId: submissionId,
    );
    
    await _sessionsBox.put(sessionId, updatedSession);
    
    return submission;
  }

  // 제출물 목록 조회
  List<WritingSubmission> getSubmissions(String userId) {
    return _submissionsBox.values
        .where((submission) => submission.userId == userId)
        .toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  // 특정 제출물 조회
  WritingSubmission? getSubmission(String submissionId) {
    return _submissionsBox.get(submissionId);
  }

  // 제출물에 평가 결과 추가
  Future<void> updateSubmissionWithEvaluation(
    String submissionId, 
    WritingEvaluation evaluation,
  ) async {
    final submission = _submissionsBox.get(submissionId);
    if (submission == null) {
      throw Exception('Submission not found');
    }
    
    final updatedSubmission = WritingSubmission(
      id: submission.id,
      taskId: submission.taskId,
      userId: submission.userId,
      content: submission.content,
      inputMethod: submission.inputMethod,
      handwritingImageUrl: submission.handwritingImageUrl,
      ocrText: submission.ocrText,
      ocrConfidence: submission.ocrConfidence,
      submittedAt: submission.submittedAt,
      timeSpent: submission.timeSpent,
      wordCount: submission.wordCount,
      status: WritingStatus.evaluated,
      evaluation: evaluation,
    );
    
    await _submissionsBox.put(submissionId, updatedSubmission);
  }

  // 세션 행동 기록
  Future<void> addSessionAction({
    required String sessionId,
    required WritingActionType type,
    String? content,
    int? position,
    Map<String, dynamic>? metadata,
  }) async {
    final session = _sessionsBox.get(sessionId);
    if (session == null) return;
    
    final action = WritingAction(
      id: 'action_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      timestamp: DateTime.now(),
      content: content,
      position: position,
      metadata: metadata,
    );
    
    final updatedActions = List<WritingAction>.from(session.actions)..add(action);
    
    final updatedSession = WritingSession(
      id: session.id,
      userId: session.userId,
      taskId: session.taskId,
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      duration: session.duration,
      currentContent: session.currentContent,
      currentWordCount: session.currentWordCount,
      actions: updatedActions,
      status: session.status,
      submissionId: session.submissionId,
    );
    
    await _sessionsBox.put(sessionId, updatedSession);
  }

  // 사용자 통계 조회
  Map<String, dynamic> getUserStats(String userId) {
    final submissions = getSubmissions(userId);
    final completedSubmissions = submissions
        .where((s) => s.status == WritingStatus.completed || s.status == WritingStatus.evaluated)
        .toList();
    
    final totalWords = submissions.fold<int>(
      0,
      (sum, submission) => sum + submission.wordCount,
    );
    
    final averageScore = submissions
        .where((s) => s.evaluation != null)
        .map((s) => s.evaluation!.overallScore)
        .fold<double>(0, (sum, score) => sum + score) /
        submissions.where((s) => s.evaluation != null).length;
    
    final typeDistribution = <WritingTaskType, int>{};
    for (final submission in submissions) {
      final task = getTask(submission.taskId);
      if (task != null) {
        typeDistribution[task.type] = (typeDistribution[task.type] ?? 0) + 1;
      }
    }
    
    return {
      'totalSubmissions': submissions.length,
      'completedSubmissions': completedSubmissions.length,
      'totalWords': totalWords,
      'averageScore': averageScore.isNaN ? 0.0 : averageScore,
      'typeDistribution': typeDistribution,
      'recentActivity': submissions.take(5).map((s) => s.toJson()).toList(),
    };
  }

  // 진행 중인 세션 조회
  WritingSession? getActiveSession(String userId) {
    return _sessionsBox.values
        .where((session) => 
            session.userId == userId && 
            session.status == WritingSessionStatus.active)
        .firstOrNull;
  }

  // 세션 목록 조회
  List<WritingSession> getSessions(String userId) {
    return _sessionsBox.values
        .where((session) => session.userId == userId)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  void dispose() {
    _tasksBox.close();
    _submissionsBox.close();
    _sessionsBox.close();
  }
}