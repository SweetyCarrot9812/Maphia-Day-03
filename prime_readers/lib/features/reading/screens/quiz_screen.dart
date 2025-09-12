import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/reading_models.dart';
import '../services/quiz_service.dart';
import 'dart:async';

final quizServiceProvider = Provider<QuizService>((ref) => QuizService());

final currentQuizSessionProvider = StateProvider<QuizSession?>((ref) => null);
final currentQuestionIndexProvider = StateProvider<int>((ref) => 0);
final selectedAnswerProvider = StateProvider<String?>((ref) => null);
final timeRemainingProvider = StateProvider<int>((ref) => 0);

class QuizScreen extends ConsumerStatefulWidget {
  final String bookId;
  final String bookTitle;

  const QuizScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  Timer? _timer;
  bool _isQuizStarted = false;
  bool _isAnswered = false;
  List<QuizQuestion> _questions = [];
  
  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeQuiz() async {
    final quizService = ref.read(quizServiceProvider);
    await quizService.initialize();
    
    try {
      final session = await quizService.startQuizSession('student1', widget.bookId);
      ref.read(currentQuizSessionProvider.notifier).state = session;
      
      // 문제들 로드
      _questions = session.questionIds
          .map((id) => quizService.getQuestion(id))
          .where((q) => q != null)
          .cast<QuizQuestion>()
          .toList();
      
      setState(() {
        _isQuizStarted = true;
      });
      
      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('퀴즈를 시작할 수 없습니다: $e')),
      );
    }
  }

  void _startTimer() {
    ref.read(timeRemainingProvider.notifier).state = 60; // 1분 타이머
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = ref.read(timeRemainingProvider);
      if (remaining > 0) {
        ref.read(timeRemainingProvider.notifier).state = remaining - 1;
      } else {
        _timer?.cancel();
        _autoSubmitAnswer();
      }
    });
  }

  void _autoSubmitAnswer() {
    if (!_isAnswered) {
      _submitAnswer('시간 초과');
    }
  }

  Future<void> _submitAnswer(String answer) async {
    if (_isAnswered) return;
    
    setState(() {
      _isAnswered = true;
    });
    
    _timer?.cancel();
    
    final session = ref.read(currentQuizSessionProvider);
    final questionIndex = ref.read(currentQuestionIndexProvider);
    
    if (session != null && questionIndex < _questions.length) {
      final question = _questions[questionIndex];
      final quizService = ref.read(quizServiceProvider);
      
      try {
        await quizService.submitAnswer(session.id, question.id, answer);
        
        // 정답 확인 후 다음 문제로 이동
        Future.delayed(const Duration(seconds: 2), () {
          _nextQuestion();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('답안 제출 실패: $e')),
        );
      }
    }
  }

  void _nextQuestion() {
    final questionIndex = ref.read(currentQuestionIndexProvider);
    
    if (questionIndex < _questions.length - 1) {
      ref.read(currentQuestionIndexProvider.notifier).state = questionIndex + 1;
      ref.read(selectedAnswerProvider.notifier).state = null;
      setState(() {
        _isAnswered = false;
      });
      _startTimer();
    } else {
      _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    final session = ref.read(currentQuizSessionProvider);
    if (session != null) {
      final quizService = ref.read(quizServiceProvider);
      await quizService.completeQuizSession(session.id);
      
      // 결과 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(sessionId: session.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(currentQuizSessionProvider);
    final questionIndex = ref.watch(currentQuestionIndexProvider);
    final selectedAnswer = ref.watch(selectedAnswerProvider);
    final timeRemaining = ref.watch(timeRemainingProvider);

    if (!_isQuizStarted || session == null || _questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('퀴즈 - ${widget.bookTitle}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = _questions[questionIndex];
    final progress = (questionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('퀴즈 - ${widget.bookTitle}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 진행 상황 및 타이머
          Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '문제 ${questionIndex + 1}/${_questions.length}',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: timeRemaining <= 10 
                            ? Colors.red.withOpacity(0.1)
                            : Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16.sp,
                            color: timeRemaining <= 10 ? Colors.red : null,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${timeRemaining}초',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: timeRemaining <= 10 ? Colors.red : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Theme.of(context).dividerColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 문제 타입과 난이도
                  Row(
                    children: [
                      _buildInfoChip(
                        _getQuizTypeLabel(question.type),
                        Icons.quiz,
                        Colors.blue,
                      ),
                      SizedBox(width: 8.w),
                      _buildInfoChip(
                        _getDifficultyLabel(question.difficulty),
                        Icons.bar_chart,
                        _getDifficultyColor(question.difficulty),
                      ),
                      SizedBox(width: 8.w),
                      _buildInfoChip(
                        '${question.points}점',
                        Icons.star,
                        Colors.orange,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // 문제
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '문제',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            question.question,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // 답안 선택
                  if (question.type == QuizType.multipleChoice || question.type == QuizType.trueFalse)
                    ...question.options.map((option) => _buildOptionCard(option, selectedAnswer))
                  else if (question.type == QuizType.shortAnswer)
                    _buildTextAnswerField(),

                  SizedBox(height: 24.h),

                  // 제출 버튼
                  if (selectedAnswer != null && !_isAnswered)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _submitAnswer(selectedAnswer),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Text(
                          '답안 제출',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  // 정답 확인 결과
                  if (_isAnswered)
                    _buildAnswerResult(question, selectedAnswer ?? ''),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String option, String? selectedAnswer) {
    final isSelected = selectedAnswer == option;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      color: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: InkWell(
        onTap: _isAnswered ? null : () {
          ref.read(selectedAnswerProvider.notifier).state = option;
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                    width: 2,
                  ),
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 12.sp,
                        color: Colors.white,
                      )
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextAnswerField() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '답안을 입력하세요',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              enabled: !_isAnswered,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '여기에 답안을 입력하세요...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(selectedAnswerProvider.notifier).state = value.trim();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerResult(QuizQuestion question, String userAnswer) {
    final isCorrect = _checkAnswer(question, userAnswer);
    
    return Card(
      color: isCorrect 
          ? Colors.green.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  isCorrect ? '정답입니다!' : '틀렸습니다',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              '정답: ${question.correctAnswer}',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            if (question.explanation != null) ...[
              SizedBox(height: 8.h),
              Text(
                '해설: ${question.explanation}',
                style: TextStyle(fontSize: 13.sp),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _checkAnswer(QuizQuestion question, String userAnswer) {
    switch (question.type) {
      case QuizType.multipleChoice:
      case QuizType.trueFalse:
        return question.correctAnswer.toLowerCase().trim() == userAnswer.toLowerCase().trim();
      case QuizType.shortAnswer:
        final correctWords = question.correctAnswer.toLowerCase().split(RegExp(r'[,\s]+'));
        final userWords = userAnswer.toLowerCase().split(RegExp(r'[,\s]+'));
        return correctWords.every((word) => 
          userWords.any((userWord) => userWord.contains(word) || word.contains(userWord))
        );
      default:
        return false;
    }
  }

  String _getQuizTypeLabel(QuizType type) {
    switch (type) {
      case QuizType.multipleChoice: return '객관식';
      case QuizType.trueFalse: return '참/거짓';
      case QuizType.shortAnswer: return '단답형';
      case QuizType.essay: return '서술형';
      case QuizType.comprehension: return '독해';
      case QuizType.vocabulary: return '어휘';
      case QuizType.sequencing: return '순서';
    }
  }

  String _getDifficultyLabel(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy: return '쉬움';
      case QuizDifficulty.medium: return '보통';
      case QuizDifficulty.hard: return '어려움';
    }
  }

  Color _getDifficultyColor(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy: return Colors.green;
      case QuizDifficulty.medium: return Colors.orange;
      case QuizDifficulty.hard: return Colors.red;
    }
  }
}

// 퀴즈 결과 화면
class QuizResultScreen extends ConsumerWidget {
  final String sessionId;

  const QuizResultScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('퀴즈 결과'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getQuizResults(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text('결과를 불러오는 중 오류가 발생했습니다'),
                ],
              ),
            );
          }

          final results = snapshot.data!;
          return _buildResultsContent(context, results);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getQuizResults(WidgetRef ref) async {
    final quizService = ref.read(quizServiceProvider);
    await quizService.initialize();
    
    final session = quizService.getQuizSession(sessionId);
    if (session == null) throw Exception('Quiz session not found');
    
    return quizService.analyzeQuizResults(session);
  }

  Widget _buildResultsContent(BuildContext context, Map<String, dynamic> results) {
    final score = results['score'].toDouble();
    final grade = results['grade'];
    final isPassed = results['isPassed'];
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // 점수 카드
          Card(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  Text(
                    '${score.toInt()}점',
                    style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                      color: isPassed ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    grade,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    isPassed ? '합격!' : '불합격',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: isPassed ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // 상세 결과
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '상세 결과',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12.h),
                  _buildResultRow('총 문제 수', '${results['totalQuestions']}문제'),
                  _buildResultRow('정답 수', '${results['correctAnswers']}문제'),
                  _buildResultRow('소요 시간', '${results['timeSpent']}분'),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // 추천 사항
          if (results['recommendations'] != null && (results['recommendations'] as List).isNotEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '학습 추천',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12.h),
                    ...(results['recommendations'] as List).map((recommendation) =>
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(fontSize: 16.sp)),
                            Expanded(
                              child: Text(
                                recommendation,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          SizedBox(height: 24.h),
          
          // 버튼들
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('돌아가기'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // 다시 도전하기
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          bookId: 'book_001', // TODO: 실제 bookId 전달
                          bookTitle: '퀴즈 재도전',
                        ),
                      ),
                    );
                  },
                  child: const Text('다시 도전'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp)),
          Text(
            value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}