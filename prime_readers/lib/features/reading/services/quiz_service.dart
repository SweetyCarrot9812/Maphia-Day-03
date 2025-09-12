import 'package:hive/hive.dart';
import '../models/reading_models.dart';
import 'dart:math';

class QuizService {
  static const String _questionsBoxName = 'quiz_questions';
  static const String _sessionsBoxName = 'quiz_sessions';
  
  late Box<QuizQuestion> _questionsBox;
  late Box<QuizSession> _sessionsBox;
  final Random _random = Random();

  Future<void> initialize() async {
    _questionsBox = await Hive.openBox<QuizQuestion>(_questionsBoxName);
    _sessionsBox = await Hive.openBox<QuizSession>(_sessionsBoxName);
    
    await addSampleQuestions();
  }

  // 샘플 퀴즈 질문 추가
  Future<void> addSampleQuestions() async {
    if (_questionsBox.isEmpty) {
      final sampleQuestions = [
        // 어린 왕자 퀴즈
        QuizQuestion(
          id: 'q_001',
          bookId: 'book_001',
          type: QuizType.multipleChoice,
          difficulty: QuizDifficulty.easy,
          question: '어린 왕자가 살고 있던 곳은 어디인가요?',
          options: ['지구', 'B-612 소행성', '화성', '달'],
          correctAnswer: 'B-612 소행성',
          explanation: '어린 왕자는 B-612라는 작은 소행성에 살고 있었습니다.',
          points: 5,
          tags: ['기본정보', '배경'],
          createdAt: DateTime.now(),
          chapterNumber: 1,
        ),
        QuizQuestion(
          id: 'q_002',
          bookId: 'book_001',
          type: QuizType.trueFalse,
          difficulty: QuizDifficulty.medium,
          question: '어린 왕자는 장미꽃을 소중히 여겼다.',
          options: ['참', '거짓'],
          correctAnswer: '참',
          explanation: '어린 왕자는 자신의 행성에 있는 장미꽃을 매우 소중히 여겼습니다.',
          points: 3,
          tags: ['감정', '관계'],
          createdAt: DateTime.now(),
          chapterNumber: 2,
        ),
        
        // 해리 포터 퀴즈
        QuizQuestion(
          id: 'q_003',
          bookId: 'book_002',
          type: QuizType.multipleChoice,
          difficulty: QuizDifficulty.easy,
          question: '해리 포터가 다니는 마법학교의 이름은?',
          options: ['호그와트', '일베르모니', '보바통', '더름스트랑'],
          correctAnswer: '호그와트',
          explanation: '해리 포터는 호그와트 마법학교에 다닙니다.',
          points: 5,
          tags: ['기본정보', '학교'],
          createdAt: DateTime.now(),
          chapterNumber: 1,
        ),
        QuizQuestion(
          id: 'q_004',
          bookId: 'book_002',
          type: QuizType.shortAnswer,
          difficulty: QuizDifficulty.medium,
          question: '해리 포터의 가장 친한 친구 두 명의 이름을 쓰시오.',
          options: [],
          correctAnswer: '론 위즐리, 헤르미온느 그레인저',
          explanation: '해리의 가장 친한 친구는 론 위즐리와 헤르미온느 그레인저입니다.',
          points: 8,
          tags: ['인물관계', '우정'],
          createdAt: DateTime.now(),
          chapterNumber: 3,
        ),
        
        // 과학 도서 퀴즈
        QuizQuestion(
          id: 'q_005',
          bookId: 'book_003',
          type: QuizType.multipleChoice,
          difficulty: QuizDifficulty.medium,
          question: '주기율표에서 첫 번째 원소는 무엇인가요?',
          options: ['헬륨', '수소', '리튬', '베릴륨'],
          correctAnswer: '수소',
          explanation: '수소는 원자번호 1번으로 주기율표의 첫 번째 원소입니다.',
          points: 6,
          tags: ['과학', '원소', '화학'],
          createdAt: DateTime.now(),
          chapterNumber: 1,
        ),
        QuizQuestion(
          id: 'q_006',
          bookId: 'book_003',
          type: QuizType.trueFalse,
          difficulty: QuizDifficulty.hard,
          question: '산소의 원자기호는 O2이다.',
          options: ['참', '거짓'],
          correctAnswer: '거짓',
          explanation: '산소의 원자기호는 O이고, O2는 산소 분자를 나타냅니다.',
          points: 4,
          tags: ['과학', '화학기호'],
          createdAt: DateTime.now(),
          chapterNumber: 2,
        ),
      ];
      
      for (final question in sampleQuestions) {
        await _questionsBox.put(question.id, question);
      }
    }
  }

  // 책에 대한 퀴즈 문제 조회
  List<QuizQuestion> getQuestionsByBook(String bookId, {int? limit, QuizDifficulty? difficulty}) {
    var questions = _questionsBox.values
        .where((question) => question.bookId == bookId)
        .toList();
    
    if (difficulty != null) {
      questions = questions.where((q) => q.difficulty == difficulty).toList();
    }
    
    // 무작위로 섞기
    questions.shuffle(_random);
    
    if (limit != null && limit > 0) {
      questions = questions.take(limit).toList();
    }
    
    return questions;
  }

  // 퀴즈 세션 시작
  Future<QuizSession> startQuizSession(String userId, String bookId, {int questionCount = 10}) async {
    final questions = getQuestionsByBook(bookId, limit: questionCount);
    
    if (questions.isEmpty) {
      throw Exception('No questions available for this book');
    }
    
    final sessionId = 'quiz_${DateTime.now().millisecondsSinceEpoch}';
    final session = QuizSession(
      id: sessionId,
      userId: userId,
      bookId: bookId,
      questionIds: questions.map((q) => q.id).toList(),
      startedAt: DateTime.now(),
      timeSpent: Duration.zero,
      totalQuestions: questions.length,
      correctAnswers: 0,
      score: 0.0,
      isPassed: false,
      userAnswers: {},
      attempts: [],
    );
    
    await _sessionsBox.put(sessionId, session);
    return session;
  }

  // 퀴즈 답안 제출
  Future<QuizAttempt> submitAnswer(String sessionId, String questionId, String userAnswer) async {
    final session = _sessionsBox.get(sessionId);
    if (session == null) {
      throw Exception('Quiz session not found');
    }
    
    final question = _questionsBox.get(questionId);
    if (question == null) {
      throw Exception('Question not found');
    }
    
    final isCorrect = _checkAnswer(question, userAnswer);
    
    final attemptId = 'attempt_${DateTime.now().millisecondsSinceEpoch}';
    final attempt = QuizAttempt(
      id: attemptId,
      questionId: questionId,
      userAnswer: userAnswer,
      isCorrect: isCorrect,
      answeredAt: DateTime.now(),
      timeSpent: Duration.zero, // 추후 타이머 기능 추가시 구현
      attempts: 1,
    );
    
    // 세션 업데이트
    final updatedAttempts = List<QuizAttempt>.from(session.attempts)..add(attempt);
    final updatedAnswers = Map<String, String>.from(session.userAnswers);
    updatedAnswers[questionId] = userAnswer;
    
    final correctCount = updatedAttempts.where((a) => a.isCorrect).length;
    final score = (correctCount / session.totalQuestions * 100.0);
    
    final updatedSession = QuizSession(
      id: session.id,
      userId: session.userId,
      bookId: session.bookId,
      questionIds: session.questionIds,
      startedAt: session.startedAt,
      completedAt: session.completedAt,
      timeSpent: session.timeSpent,
      totalQuestions: session.totalQuestions,
      correctAnswers: correctCount,
      score: score,
      isPassed: score >= 80.0,
      userAnswers: updatedAnswers,
      attempts: updatedAttempts,
    );
    
    await _sessionsBox.put(sessionId, updatedSession);
    return attempt;
  }

  // 답안 확인 로직
  bool _checkAnswer(QuizQuestion question, String userAnswer) {
    switch (question.type) {
      case QuizType.multipleChoice:
      case QuizType.trueFalse:
        return question.correctAnswer.toLowerCase().trim() == userAnswer.toLowerCase().trim();
      
      case QuizType.shortAnswer:
        // 단답형은 더 유연한 매칭 (키워드 포함 여부)
        final correctWords = question.correctAnswer.toLowerCase().split(RegExp(r'[,\s]+'));
        final userWords = userAnswer.toLowerCase().split(RegExp(r'[,\s]+'));
        
        // 모든 핵심 키워드가 포함되었는지 확인
        return correctWords.every((word) => 
          userWords.any((userWord) => userWord.contains(word) || word.contains(userWord))
        );
      
      default:
        return false;
    }
  }

  // 퀴즈 세션 완료
  Future<QuizSession> completeQuizSession(String sessionId) async {
    final session = _sessionsBox.get(sessionId);
    if (session == null) {
      throw Exception('Quiz session not found');
    }
    
    final completedAt = DateTime.now();
    final timeSpent = completedAt.difference(session.startedAt);
    
    final completedSession = QuizSession(
      id: session.id,
      userId: session.userId,
      bookId: session.bookId,
      questionIds: session.questionIds,
      startedAt: session.startedAt,
      completedAt: completedAt,
      timeSpent: timeSpent,
      totalQuestions: session.totalQuestions,
      correctAnswers: session.correctAnswers,
      score: session.score,
      isPassed: session.isPassed,
      userAnswers: session.userAnswers,
      attempts: session.attempts,
    );
    
    await _sessionsBox.put(sessionId, completedSession);
    return completedSession;
  }

  // 퀴즈 결과 분석
  Map<String, dynamic> analyzeQuizResults(QuizSession session) {
    final totalQuestions = session.totalQuestions;
    final correctAnswers = session.correctAnswers;
    final score = session.score;
    
    // 난이도별 성과 분석
    final difficultyResults = <QuizDifficulty, Map<String, int>>{};
    
    for (final attempt in session.attempts) {
      final question = _questionsBox.get(attempt.questionId);
      if (question != null) {
        final difficulty = question.difficulty;
        difficultyResults[difficulty] ??= {'correct': 0, 'total': 0};
        difficultyResults[difficulty]!['total'] = difficultyResults[difficulty]!['total']! + 1;
        if (attempt.isCorrect) {
          difficultyResults[difficulty]!['correct'] = difficultyResults[difficulty]!['correct']! + 1;
        }
      }
    }
    
    // 타입별 성과 분석
    final typeResults = <QuizType, Map<String, int>>{};
    
    for (final attempt in session.attempts) {
      final question = _questionsBox.get(attempt.questionId);
      if (question != null) {
        final type = question.type;
        typeResults[type] ??= {'correct': 0, 'total': 0};
        typeResults[type]!['total'] = typeResults[type]!['total']! + 1;
        if (attempt.isCorrect) {
          typeResults[type]!['correct'] = typeResults[type]!['correct']! + 1;
        }
      }
    }
    
    // 성과 등급
    String grade = 'F';
    if (score >= 97) grade = 'A+';
    else if (score >= 93) grade = 'A';
    else if (score >= 90) grade = 'A-';
    else if (score >= 87) grade = 'B+';
    else if (score >= 83) grade = 'B';
    else if (score >= 80) grade = 'B-';
    else if (score >= 77) grade = 'C+';
    else if (score >= 73) grade = 'C';
    else if (score >= 70) grade = 'C-';
    else if (score >= 60) grade = 'D';
    
    // 추천 학습 방향
    final recommendations = <String>[];
    
    if (score < 80) {
      recommendations.add('책을 다시 한 번 읽어보세요');
    }
    
    // 난이도별 약점 분석
    for (final entry in difficultyResults.entries) {
      final difficulty = entry.key;
      final results = entry.value;
      final accuracy = results['correct']! / results['total']!;
      
      if (accuracy < 0.7) {
        switch (difficulty) {
          case QuizDifficulty.easy:
            recommendations.add('기본 내용을 더 자세히 학습하세요');
            break;
          case QuizDifficulty.medium:
            recommendations.add('중급 수준의 이해력을 높여보세요');
            break;
          case QuizDifficulty.hard:
            recommendations.add('고급 분석 능력을 기르세요');
            break;
        }
      }
    }
    
    return {
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'score': score,
      'grade': grade,
      'isPassed': session.isPassed,
      'timeSpent': session.timeSpent.inMinutes,
      'difficultyResults': difficultyResults.map((k, v) => MapEntry(k.name, v)),
      'typeResults': typeResults.map((k, v) => MapEntry(k.name, v)),
      'recommendations': recommendations,
      'strengths': _identifyStrengths(typeResults, difficultyResults),
      'weaknesses': _identifyWeaknesses(typeResults, difficultyResults),
    };
  }

  // 강점 분석
  List<String> _identifyStrengths(Map<QuizType, Map<String, int>> typeResults, Map<QuizDifficulty, Map<String, int>> difficultyResults) {
    final strengths = <String>[];
    
    for (final entry in typeResults.entries) {
      final type = entry.key;
      final results = entry.value;
      final accuracy = results['correct']! / results['total']!;
      
      if (accuracy >= 0.9) {
        switch (type) {
          case QuizType.multipleChoice:
            strengths.add('객관식 문제 해결 능력이 뛰어납니다');
            break;
          case QuizType.trueFalse:
            strengths.add('참/거짓 판단 능력이 우수합니다');
            break;
          case QuizType.shortAnswer:
            strengths.add('단답형 서술 능력이 뛰어납니다');
            break;
          default:
            break;
        }
      }
    }
    
    for (final entry in difficultyResults.entries) {
      final difficulty = entry.key;
      final results = entry.value;
      final accuracy = results['correct']! / results['total']!;
      
      if (accuracy >= 0.9) {
        switch (difficulty) {
          case QuizDifficulty.hard:
            strengths.add('고난도 문제 해결 능력이 뛰어납니다');
            break;
          default:
            break;
        }
      }
    }
    
    return strengths;
  }

  // 약점 분석
  List<String> _identifyWeaknesses(Map<QuizType, Map<String, int>> typeResults, Map<QuizDifficulty, Map<String, int>> difficultyResults) {
    final weaknesses = <String>[];
    
    for (final entry in typeResults.entries) {
      final type = entry.key;
      final results = entry.value;
      final accuracy = results['correct']! / results['total']!;
      
      if (accuracy < 0.6) {
        switch (type) {
          case QuizType.shortAnswer:
            weaknesses.add('서술형 문제에 대한 연습이 필요합니다');
            break;
          case QuizType.essay:
            weaknesses.add('에세이 작성 능력 향상이 필요합니다');
            break;
          case QuizType.comprehension:
            weaknesses.add('독해 능력을 기르는 것이 필요합니다');
            break;
          default:
            break;
        }
      }
    }
    
    return weaknesses;
  }

  // 사용자의 퀴즈 세션 목록 조회
  List<QuizSession> getUserQuizSessions(String userId, {String? bookId}) {
    var sessions = _sessionsBox.values
        .where((session) => session.userId == userId)
        .toList();
    
    if (bookId != null) {
      sessions = sessions.where((session) => session.bookId == bookId).toList();
    }
    
    return sessions..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  // 특정 퀴즈 세션 조회
  QuizSession? getQuizSession(String sessionId) {
    return _sessionsBox.get(sessionId);
  }

  // 퀴즈 문제 조회
  QuizQuestion? getQuestion(String questionId) {
    return _questionsBox.get(questionId);
  }

  // 맞춤형 퀴즈 생성 (사용자 레벨에 맞춤)
  Future<QuizSession> createAdaptiveQuiz(String userId, String bookId, {int questionCount = 10}) async {
    // 사용자의 이전 퀴즈 결과 분석
    final previousSessions = getUserQuizSessions(userId, bookId: bookId);
    
    QuizDifficulty targetDifficulty = QuizDifficulty.medium;
    
    if (previousSessions.isNotEmpty) {
      final averageScore = previousSessions.fold<double>(0.0, (sum, session) => sum + session.score) / previousSessions.length;
      
      if (averageScore >= 90) {
        targetDifficulty = QuizDifficulty.hard;
      } else if (averageScore >= 70) {
        targetDifficulty = QuizDifficulty.medium;
      } else {
        targetDifficulty = QuizDifficulty.easy;
      }
    }
    
    // 난이도별 문제 비율 조정
    final questions = <QuizQuestion>[];
    final allQuestions = getQuestionsByBook(bookId);
    
    switch (targetDifficulty) {
      case QuizDifficulty.easy:
        questions.addAll(allQuestions.where((q) => q.difficulty == QuizDifficulty.easy).take(6));
        questions.addAll(allQuestions.where((q) => q.difficulty == QuizDifficulty.medium).take(3));
        questions.addAll(allQuestions.where((q) => q.difficulty == QuizDifficulty.hard).take(1));
        break;
      case QuizDifficulty.medium:
        questions.addAll(allQuestions.where((q) => q.difficulty == QuizDifficulty.easy).take(3));
        questions.addAll(allQuestions.where((q) => q.difficulty == QuizDifficulty.medium).take(5));
        questions.addAll(allQuestions.where((q) => q.difficulty == QuizDifficulty.hard).take(2));
        break;
      case QuizDifficulty.hard:
        questions.addAll(allQuestions.where((q) => q.difficulty == QuizDifficulty.easy).take(2));
        questions.addAll(allQuestions.where((q) => q.difficulty == QuizDifficulty.medium).take(3));
        questions.addAll(allQuestions.where((q) => q.difficulty == QuizDifficulty.hard).take(5));
        break;
    }
    
    questions.shuffle(_random);
    final selectedQuestions = questions.take(questionCount).toList();
    
    final sessionId = 'adaptive_${DateTime.now().millisecondsSinceEpoch}';
    final session = QuizSession(
      id: sessionId,
      userId: userId,
      bookId: bookId,
      questionIds: selectedQuestions.map((q) => q.id).toList(),
      startedAt: DateTime.now(),
      timeSpent: Duration.zero,
      totalQuestions: selectedQuestions.length,
      correctAnswers: 0,
      score: 0.0,
      isPassed: false,
      userAnswers: {},
      attempts: [],
    );
    
    await _sessionsBox.put(sessionId, session);
    return session;
  }

  void dispose() {
    _questionsBox.close();
    _sessionsBox.close();
  }
}