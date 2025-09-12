import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../services/srs_service.dart';
import '../theme/app_theme.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final QuestionService _questionService = QuestionService();
  final SRSService _srsService = SRSService();
  List<Question>? _questions;
  bool _isLoading = false;
  String? _error;
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _showExplanation = false;
  int _correctAnswers = 0;
  DateTime? _questionStartTime;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final questions = await _questionService.getRandomQuestions(count: 5);
      setState(() {
        _questions = questions;
        _isLoading = false;
        if (questions == null || questions.isEmpty) {
          _error = '문제를 불러올 수 없습니다. 서버 연결을 확인해주세요.';
        } else {
          // 첫 번째 문제 시작 시간 기록
          _questionStartTime = DateTime.now();
        }
      });
    } catch (e) {
      setState(() {
        _error = '문제를 불러오는 중 오류가 발생했습니다: $e';
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(int answerIndex) {
    if (_showExplanation) return;
    
    setState(() {
      _selectedAnswer = answerIndex;
    });
  }

  void _showExplanationAndNext() async {
    if (_selectedAnswer == null) return;

    final currentQuestion = _questions![_currentQuestionIndex];
    final isCorrect = _selectedAnswer == currentQuestion.answer;
    
    if (isCorrect) {
      _correctAnswers++;
    }

    // SRS 자동 처리 (백그라운드에서 실행)
    if (_questionStartTime != null) {
      final responseTimeMs = DateTime.now().difference(_questionStartTime!).inMilliseconds;
      
      // 비동기로 SRS 처리 (UI 블로킹 방지)
      _srsService.processQuestionResult(
        questionId: currentQuestion.id,
        isCorrect: isCorrect,
        responseTimeMs: responseTimeMs,
      ).catchError((e) {
        print('SRS 처리 중 오류: $e');
        // 사용자에게는 보이지 않게 조용히 처리
      });
    }

    setState(() {
      _showExplanation = true;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions!.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showExplanation = false;
        // 다음 문제 시작 시간 기록
        _questionStartTime = DateTime.now();
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('문제풀이 완료!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: AppTheme.primaryColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '정답률: ${((_correctAnswers / _questions!.length) * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('총 ${_questions!.length}문제 중 $_correctAnswers문제 정답'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartQuiz();
            },
            child: const Text('다시 풀기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswer = null;
      _showExplanation = false;
      _correctAnswers = 0;
      _questionStartTime = null;
    });
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('간호학 문제풀이'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('문제를 불러오는 중...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadQuestions,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_questions == null || _questions!.isEmpty) {
      return const Center(
        child: Text('문제가 없습니다.'),
      );
    }

    final currentQuestion = _questions![_currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 진행률 표시
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions!.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          
          const SizedBox(height: 16),
          
          // 문제 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '문제 ${_currentQuestionIndex + 1}/${_questions!.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(currentQuestion.difficulty),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getDifficultyText(currentQuestion.difficulty),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 과목 정보
          Text(
            '${currentQuestion.subject} - ${currentQuestion.category}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 문제 본문
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      currentQuestion.stem,
                      style: const TextStyle(
                        fontSize: 16,
                        lineHeight: 1.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 선택지
                  ...currentQuestion.choices.asMap().entries.map((entry) {
                    final index = entry.key;
                    final choice = entry.value;
                    final isSelected = _selectedAnswer == index;
                    final isCorrect = index == currentQuestion.answer;
                    
                    Color? backgroundColor;
                    Color? borderColor;
                    
                    if (_showExplanation) {
                      if (isCorrect) {
                        backgroundColor = Colors.green[50];
                        borderColor = Colors.green;
                      } else if (isSelected && !isCorrect) {
                        backgroundColor = Colors.red[50];
                        borderColor = Colors.red;
                      }
                    } else if (isSelected) {
                      backgroundColor = AppTheme.primaryColor.withOpacity(0.1);
                      borderColor = AppTheme.primaryColor;
                    }
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _selectAnswer(index),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: borderColor ?? Colors.grey[300]!,
                              width: borderColor != null ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected || (_showExplanation && isCorrect)
                                      ? (isCorrect ? Colors.green : (isSelected ? Colors.red : Colors.grey[300]))
                                      : Colors.grey[300],
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index), // A, B, C, D
                                    style: TextStyle(
                                      color: isSelected || (_showExplanation && isCorrect)
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  choice,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              if (_showExplanation && isCorrect)
                                const Icon(Icons.check, color: Colors.green),
                              if (_showExplanation && isSelected && !isCorrect)
                                const Icon(Icons.close, color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  // 해설 표시
                  if (_showExplanation) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb, color: Colors.blue[600]),
                              const SizedBox(width: 8),
                              Text(
                                '해설',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentQuestion.explanation,
                            style: const TextStyle(
                              fontSize: 14,
                              lineHeight: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '출처: ${currentQuestion.source}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 버튼
          if (!_showExplanation)
            ElevatedButton(
              onPressed: _selectedAnswer != null ? _showExplanationAndNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '정답 확인',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          else
            ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _currentQuestionIndex < _questions!.length - 1 ? '다음 문제' : '결과 보기',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return '쉬움';
      case 'medium':
        return '보통';
      case 'hard':
        return '어려움';
      default:
        return difficulty;
    }
  }
}