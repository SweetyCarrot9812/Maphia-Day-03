import 'package:flutter/material.dart';
import '../services/smart_study_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

/// GPT-5 Standard 기반 스마트 학습 화면
/// 새 문제 + 복습 문제 AI 최적화 혼합
class SmartQuestionsScreen extends StatefulWidget {
  final String userId;
  final String subjectCode;
  final String? subjectName;
  final String? questionType; // 'medical' 또는 'nursing'  
  final String? learningMode; // 'smart' (기본) 또는 'concept' (개념 학습)
  final int problemCount; // 학습할 문제 개수

  const SmartQuestionsScreen({
    super.key,
    required this.userId,
    required this.subjectCode,
    this.subjectName,
    this.questionType,
    this.learningMode = 'smart', // 기본값: 일반 스마트 학습
    this.problemCount = 10, // 기본값: 10문제
  });

  @override
  State<SmartQuestionsScreen> createState() => _SmartQuestionsScreenState();
}

class _SmartQuestionsScreenState extends State<SmartQuestionsScreen> {
  List<StudyQuestion>? _questions;
  bool _isLoading = false;
  String? _error;
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _showExplanation = false;
  int _correctAnswers = 0;
  int _reviewQuestions = 0;
  DateTime? _questionStartTime;
  String? _currentUserId;

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
      // 현재 사용자 가져오기
      final user = await DatabaseService.instance.getCurrentUser();
      if (user == null) {
        setState(() {
          _error = '로그인이 필요합니다.';
          _isLoading = false;
        });
        return;
      }
      
      _currentUserId = user.id.toString();

      // GPT-5 Standard 최적화 문제 세트 생성 (사용자 선택 문제 개수 적용)
      List<StudyQuestion> questions;
      if (widget.questionType == 'medical') {
        questions = await SmartStudyService.generateMedicalStudySet(
          userId: _currentUserId!,
          subjectCode: widget.subjectCode,
          questionCount: widget.problemCount,
        );
      } else {
        questions = await SmartStudyService.generateNursingStudySet(
          userId: _currentUserId!,
          subjectCode: widget.subjectCode,
          questionCount: widget.problemCount,
        );
      }

      // 복습 문제 개수 계산
      final reviewCount = questions.where((q) => q.isReview).length;

      setState(() {
        _questions = questions;
        _reviewQuestions = reviewCount;
        _isLoading = false;
        if (questions.isEmpty) {
          _error = '사용 가능한 문제가 없습니다.';
        } else {
          _questionStartTime = DateTime.now();
        }
      });
    } catch (e) {
      setState(() {
        _error = 'AI 학습 최적화 중 오류가 발생했습니다: $e';
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
    final userAnswer = String.fromCharCode(65 + _selectedAnswer!); // A, B, C, D
    final isCorrect = userAnswer == currentQuestion.correctAnswer;
    
    if (isCorrect) {
      _correctAnswers++;
    }

    // 학습 시간 계산
    int studyTimeSeconds = 0;
    if (_questionStartTime != null) {
      studyTimeSeconds = DateTime.now().difference(_questionStartTime!).inSeconds;
    }

    // GPT-5 기반 학습 결과 처리 (백그라운드)
    if (_currentUserId != null) {
      SmartStudyService.processStudyResult(
        userId: _currentUserId!,
        question: currentQuestion,
        userAnswer: userAnswer,
        isCorrect: isCorrect,
        studyTimeSeconds: studyTimeSeconds,
      ).catchError((e) {
        print('AI 학습 결과 처리 중 오류: $e');
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
        _questionStartTime = DateTime.now();
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final totalQuestions = _questions!.length;
    final newQuestions = totalQuestions - _reviewQuestions;
    final accuracyRate = (_correctAnswers / totalQuestions) * 100;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.psychology, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text('AI 최적화 학습 완료!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 전체 결과
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '정답률: ${accuracyRate.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('총 $totalQuestions문제 중 $_correctAnswers문제 정답'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // AI 최적화 정보
            Text(
              '🧠 AI 최적화 결과',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 8),
            Text('• 새로운 문제: $newQuestions개'),
            Text('• 복습 문제: $_reviewQuestions개'),
            if (_reviewQuestions > 0)
              Text('• GPT-5가 복습이 필요하다고 판단한 문제들을 포함했습니다'),
            
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '💡 AI가 당신의 학습 패턴을 분석하여 최적의 문제 조합을 제공했습니다!',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartQuiz();
            },
            child: const Text('다시 학습'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('완료'),
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
      _reviewQuestions = 0;
      _questionStartTime = null;
    });
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.subjectName} - AI 학습'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_questions != null && _reviewQuestions > 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange[600],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '복습 $_reviewQuestions개',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            const Text('GPT-5 AI가 최적의 학습 문제를 준비하고 있습니다...'),
            const SizedBox(height: 8),
            Text(
              '학습 패턴 분석 중',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
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
        child: Text('사용 가능한 문제가 없습니다.'),
      );
    }

    final currentQuestion = _questions![_currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 진행률 및 AI 정보
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions!.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '문제 ${_currentQuestionIndex + 1}/${_questions!.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        if (currentQuestion.isReview)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange[600],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '복습',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[600],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '신규',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(currentQuestion.difficulty),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getDifficultyText(currentQuestion.difficulty),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
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
                      currentQuestion.question,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 선택지
                  ...currentQuestion.choices.asMap().entries.map((entry) {
                    final index = entry.key;
                    final choice = entry.value;
                    final choiceLetter = String.fromCharCode(65 + index); // A, B, C, D
                    final isSelected = _selectedAnswer == index;
                    final isCorrect = choiceLetter == currentQuestion.correctAnswer;
                    
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
                                    choiceLetter,
                                    style: TextStyle(
                                      color: isSelected || (_showExplanation && isCorrect)
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
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
                  if (_showExplanation && currentQuestion.explanation != null) ...[
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
                            currentQuestion.explanation!,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          if (currentQuestion.isReview)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '💡 이 문제는 AI가 복습이 필요하다고 판단한 문제입니다.',
                                style: TextStyle(fontSize: 12),
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