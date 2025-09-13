import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../core/theme.dart';
import '../../../models/problem.dart';
import '../../../models/quiz_session.dart';
import '../../../models/user_progress.dart';
import '../../../services/database_service.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  QuizSession? _currentSession;
  Problem? _currentProblem;
  List<Problem> _sessionProblems = [];
  UserProgress? _userProgress;
  bool _isLoading = true;
  Timer? _sessionTimer;
  int _sessionStartTime = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProgress();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserProgress() async {
    setState(() => _isLoading = true);
    
    try {
      final progress = await DatabaseService.instance.getUserProgress();
      setState(() {
        _userProgress = progress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자 진도 로드 실패: $e')),
        );
      }
    }
  }

  Future<void> _startNewQuizSession({
    required SessionType type,
    int problemCount = 10,
    List<String> subjects = const [],
    List<String> difficulties = const [],
  }) async {
    setState(() => _isLoading = true);
    
    try {
      // 문제 가져오기
      final allProblems = await DatabaseService.instance.getProblems();
      var availableProblems = allProblems.where((p) => p.status == ProblemStatus.published).toList();
      
      // 필터링 적용
      if (subjects.isNotEmpty) {
        availableProblems = availableProblems.where((p) => subjects.contains(p.type.name)).toList();
      }
      if (difficulties.isNotEmpty) {
        availableProblems = availableProblems.where((p) => difficulties.contains(p.difficulty.name)).toList();
      }
      
      if (availableProblems.isEmpty) {
        throw Exception('조건에 맞는 문제가 없습니다');
      }
      
      // 문제 섞기 및 선택
      availableProblems.shuffle();
      final selectedProblems = availableProblems.take(problemCount).toList();
      
      // 퀴즈 세션 생성
      final session = QuizSession()
        ..sessionId = 'quiz_${DateTime.now().millisecondsSinceEpoch}'
        ..title = _getSessionTitle(type)
        ..type = type
        ..status = SessionStatus.active
        ..problemIds = selectedProblems.map((p) => p.problemId).join(',')
        ..totalProblems = selectedProblems.length
        ..settings = '{"problemCount": $problemCount, "subjects": $subjects, "difficulties": $difficulties}'
        ..subjects = subjects.join(',')
        ..difficulties = difficulties.join(',')
        ..createdAt = DateTime.now();
      
      await DatabaseService.instance.createQuizSession(session);
      
      setState(() {
        _currentSession = session;
        _sessionProblems = selectedProblems;
        _currentProblem = selectedProblems.first;
        _sessionStartTime = DateTime.now().millisecondsSinceEpoch;
        _isLoading = false;
      });
      
      _startSessionTimer();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('퀴즈 시작 실패: $e')),
        );
      }
    }
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSession != null && _currentSession!.isActive) {
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        final totalTime = currentTime - _sessionStartTime;
        
        final updatedSession = _currentSession!.copyWith(totalTimeMs: totalTime);
        setState(() {
          _currentSession = updatedSession;
        });
      }
    });
  }

  String _getSessionTitle(SessionType type) {
    switch (type) {
      case SessionType.practice:
        return '연습 모드';
      case SessionType.exam:
        return '시험 모드';
      case SessionType.review:
        return '복습 모드';
      case SessionType.challenge:
        return '챌린지 모드';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentSession == null) {
      return _buildSessionSetup();
    }

    if (_currentSession!.isCompleted) {
      return _buildSessionResults();
    }

    return _buildQuizInterface();
  }

  Widget _buildSessionSetup() {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildProgressSummary(),
            const SizedBox(height: 32),
            _buildSessionOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.psychology,
              size: 32,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 12),
            Text(
              '개인화 퀴즈',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'AI가 분석한 학습 패턴을 바탕으로 맞춤형 문제를 제공합니다',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSummary() {
    if (_userProgress == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '학습 현황',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProgressCard(
                    '총 문제 수',
                    '${_userProgress!.totalProblemsAttempted}',
                    Icons.quiz,
                    AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProgressCard(
                    '정답률',
                    '${_userProgress!.accuracy.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    AppTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProgressCard(
                    '연속 정답',
                    '${_userProgress!.currentStreak}',
                    Icons.local_fire_department,
                    AppTheme.accentOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProgressCard(
                    '학습 시간',
                    '${(_userProgress!.totalStudyTimeMinutes / 60).toStringAsFixed(1)}h',
                    Icons.schedule,
                    AppTheme.primaryTeal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '퀴즈 모드 선택',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3,
          children: [
            _buildModeCard(
              '연습 모드',
              '자유롭게 연습하며 실력을 향상시켜보세요',
              Icons.psychology,
              AppTheme.primaryBlue,
              () => _showSessionConfig(SessionType.practice),
            ),
            _buildModeCard(
              '시험 모드',
              '실제 시험과 같은 환경에서 실력을 점검하세요',
              Icons.assignment,
              AppTheme.errorRed,
              () => _showSessionConfig(SessionType.exam),
            ),
            _buildModeCard(
              '복습 모드',
              '틀렸던 문제를 다시 풀어보며 완전히 이해하세요',
              Icons.refresh,
              AppTheme.primaryTeal,
              () => _showSessionConfig(SessionType.review),
            ),
            _buildModeCard(
              '챌린지 모드',
              '어려운 문제에 도전하며 한 단계 더 성장하세요',
              Icons.emoji_events,
              AppTheme.accentOrange,
              () => _showSessionConfig(SessionType.challenge),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSessionConfig(SessionType type) {
    showDialog(
      context: context,
      builder: (context) => _SessionConfigDialog(
        type: type,
        onStart: (problemCount, subjects, difficulties) {
          Navigator.of(context).pop();
          _startNewQuizSession(
            type: type,
            problemCount: problemCount,
            subjects: subjects,
            difficulties: difficulties,
          );
        },
      ),
    );
  }

  Widget _buildQuizInterface() {
    if (_currentProblem == null) return const SizedBox.shrink();

    final session = _currentSession!;
    final progress = (session.currentProblemIndex + 1) / session.totalProblems;

    return Scaffold(
      body: Column(
        children: [
          _buildQuizHeader(session, progress),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildProblemCard(_currentProblem!),
            ),
          ),
          _buildQuizControls(session),
        ],
      ),
    );
  }

  Widget _buildQuizHeader(QuizSession session, double progress) {
    final timeSpent = Duration(milliseconds: session.totalTimeMs);
    final minutes = timeSpent.inMinutes;
    final seconds = timeSpent.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                session.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _pauseSession,
                icon: const Icon(Icons.pause),
                tooltip: '일시정지',
              ),
              IconButton(
                onPressed: _quitSession,
                icon: const Icon(Icons.close),
                tooltip: '종료',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '문제 ${session.currentProblemIndex + 1} / ${session.totalProblems}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProblemCard(Problem problem) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(problem.difficulty).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getDifficultyColor(problem.difficulty).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _getDifficultyText(problem.difficulty),
                    style: TextStyle(
                      color: _getDifficultyColor(problem.difficulty),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getTypeText(problem.type),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              problem.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              problem.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
            // TODO: Add answer options for multiple choice problems
            // TODO: Add text input for essay problems
          ],
        ),
      ),
    );
  }

  Widget _buildQuizControls(QuizSession session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          if (session.currentProblemIndex > 0)
            ElevatedButton.icon(
              onPressed: _previousProblem,
              icon: const Icon(Icons.arrow_back),
              label: const Text('이전'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.grey.shade700,
              ),
            ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _skipProblem,
            icon: const Icon(Icons.skip_next),
            label: const Text('건너뛰기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              foregroundColor: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _nextProblem,
            icon: const Icon(Icons.arrow_forward),
            label: Text(session.currentProblemIndex == session.totalProblems - 1 ? '완료' : '다음'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionResults() {
    final session = _currentSession!;
    final accuracy = session.accuracy;
    final timeSpent = Duration(milliseconds: session.totalTimeMs);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.celebration,
                    size: 64,
                    color: AppTheme.successGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '퀴즈 완료!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successGreen,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildResultCard('정답률', '${accuracy.toStringAsFixed(1)}%', Icons.check_circle),
                      _buildResultCard('문제 수', '${session.totalProblems}', Icons.quiz),
                      _buildResultCard('소요 시간', '${timeSpent.inMinutes}:${(timeSpent.inSeconds % 60).toString().padLeft(2, '0')}', Icons.schedule),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _reviewIncorrectAnswers,
                        icon: const Icon(Icons.replay),
                        label: const Text('오답 노트'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _startAnotherSession,
                        icon: const Icon(Icons.refresh),
                        label: const Text('다시 시작'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: _goHome,
                        icon: const Icon(Icons.home),
                        label: const Text('홈으로'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppTheme.primaryBlue),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return Colors.green;
      case Difficulty.intermediate:
        return Colors.orange;
      case Difficulty.advanced:
        return Colors.red;
      case Difficulty.expert:
        return Colors.purple;
    }
  }

  String _getDifficultyText(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return '초급';
      case Difficulty.intermediate:
        return '중급';
      case Difficulty.advanced:
        return '고급';
      case Difficulty.expert:
        return '전문';
    }
  }

  String _getTypeText(ProblemType type) {
    switch (type) {
      case ProblemType.nursing:
        return '간호학';
      case ProblemType.essay:
        return 'Essay';
      case ProblemType.simulation:
        return 'Simulation';
      case ProblemType.multiple_choice:
        return '객관식';
    }
  }

  void _pauseSession() {
    if (_currentSession != null) {
      final pausedSession = _currentSession!.pause();
      DatabaseService.instance.updateQuizSession(pausedSession);
      
      setState(() {
        _currentSession = pausedSession;
      });
      
      _sessionTimer?.cancel();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('퀴즈가 일시정지되었습니다')),
      );
    }
  }

  void _quitSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('퀴즈 종료'),
        content: const Text('정말로 퀴즈를 종료하시겠습니까?\n현재까지의 진행상황은 저장됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('계속하기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _endSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('종료'),
          ),
        ],
      ),
    );
  }

  void _previousProblem() {
    if (_currentSession != null && _currentSession!.currentProblemIndex > 0) {
      final newIndex = _currentSession!.currentProblemIndex - 1;
      final updatedSession = _currentSession!.copyWith(currentProblemIndex: newIndex);
      
      setState(() {
        _currentSession = updatedSession;
        _currentProblem = _sessionProblems[newIndex];
      });
      
      DatabaseService.instance.updateQuizSession(updatedSession);
    }
  }

  void _nextProblem() {
    if (_currentSession == null) return;
    
    final session = _currentSession!;
    
    if (session.currentProblemIndex == session.totalProblems - 1) {
      _completeSession();
    } else {
      final newIndex = session.currentProblemIndex + 1;
      final updatedSession = session.copyWith(currentProblemIndex: newIndex);
      
      setState(() {
        _currentSession = updatedSession;
        _currentProblem = _sessionProblems[newIndex];
      });
      
      DatabaseService.instance.updateQuizSession(updatedSession);
    }
  }

  void _skipProblem() {
    if (_currentSession != null) {
      final updatedSession = _currentSession!.copyWith(
        skippedProblems: _currentSession!.skippedProblems + 1,
      );
      
      setState(() {
        _currentSession = updatedSession;
      });
      
      DatabaseService.instance.updateQuizSession(updatedSession);
      _nextProblem();
    }
  }

  Future<void> _completeSession() async {
    if (_currentSession == null) return;
    
    final completedSession = _currentSession!.complete();
    await DatabaseService.instance.updateQuizSession(completedSession);
    
    // Update user progress
    if (_userProgress != null) {
      final updatedProgress = _userProgress!.updateAfterSession(
        problemsAttempted: completedSession.totalProblems,
        correctAnswers: completedSession.correctAnswers,
        sessionScore: completedSession.finalScore,
        studyTimeMinutes: (completedSession.totalTimeMs / 60000).round(),
        subject: 'general',
        typeStats: {'quiz': completedSession.totalProblems},
        difficultyStats: {'mixed': completedSession.totalProblems},
      );
      
      await DatabaseService.instance.updateUserProgress(updatedProgress);
      
      setState(() {
        _userProgress = updatedProgress;
      });
    }
    
    setState(() {
      _currentSession = completedSession;
    });
    
    _sessionTimer?.cancel();
  }

  void _endSession() {
    setState(() {
      _currentSession = null;
      _currentProblem = null;
      _sessionProblems = [];
    });
    
    _sessionTimer?.cancel();
  }

  void _reviewIncorrectAnswers() {
    // TODO: Implement incorrect answer review
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('오답 노트 기능은 추후 구현됩니다')),
    );
  }

  void _startAnotherSession() {
    _endSession();
  }

  void _goHome() {
    context.go('/');
  }
}

class _SessionConfigDialog extends StatefulWidget {
  final SessionType type;
  final Function(int problemCount, List<String> subjects, List<String> difficulties) onStart;

  const _SessionConfigDialog({
    required this.type,
    required this.onStart,
  });

  @override
  State<_SessionConfigDialog> createState() => _SessionConfigDialogState();
}

class _SessionConfigDialogState extends State<_SessionConfigDialog> {
  int _problemCount = 10;
  final Set<String> _selectedSubjects = {};
  final Set<String> _selectedDifficulties = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${_getSessionTitle(widget.type)} 설정'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '문제 개수',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _problemCount.toDouble(),
                min: 5,
                max: 50,
                divisions: 9,
                label: '$_problemCount개',
                onChanged: (value) {
                  setState(() {
                    _problemCount = value.round();
                  });
                },
              ),
              Text(
                '$_problemCount개 문제',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Text(
                '과목 선택 (선택사항)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('간호학', 'nursing'),
                  _buildFilterChip('Essay', 'essay'),
                  _buildFilterChip('Simulation', 'simulation'),
                  _buildFilterChip('객관식', 'multiple_choice'),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                '난이도 선택 (선택사항)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('초급', 'beginner'),
                  _buildFilterChip('중급', 'intermediate'),
                  _buildFilterChip('고급', 'advanced'),
                  _buildFilterChip('전문', 'expert'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onStart(
              _problemCount,
              _selectedSubjects.toList(),
              _selectedDifficulties.toList(),
            );
          },
          child: const Text('시작'),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSubject = ['nursing', 'essay', 'simulation', 'multiple_choice'].contains(value);
    final isSelected = isSubject 
        ? _selectedSubjects.contains(value)
        : _selectedDifficulties.contains(value);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (isSubject) {
            if (selected) {
              _selectedSubjects.add(value);
            } else {
              _selectedSubjects.remove(value);
            }
          } else {
            if (selected) {
              _selectedDifficulties.add(value);
            } else {
              _selectedDifficulties.remove(value);
            }
          }
        });
      },
    );
  }

  String _getSessionTitle(SessionType type) {
    switch (type) {
      case SessionType.practice:
        return '연습 모드';
      case SessionType.exam:
        return '시험 모드';
      case SessionType.review:
        return '복습 모드';
      case SessionType.challenge:
        return '챌린지 모드';
    }
  }
}