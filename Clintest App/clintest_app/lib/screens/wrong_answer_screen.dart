import 'package:flutter/material.dart';
import '../models/wrong_answer.dart';
import '../services/wrong_answer_service.dart';
import '../services/database_service.dart';

class WrongAnswerScreen extends StatefulWidget {
  const WrongAnswerScreen({super.key});

  @override
  State<WrongAnswerScreen> createState() => _WrongAnswerScreenState();
}

class _WrongAnswerScreenState extends State<WrongAnswerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? currentUserId;
  List<WrongAnswer> wrongAnswers = [];
  List<WrongAnswer> reviewAnswers = [];
  List<WrongAnswer> resolvedAnswers = [];
  WrongAnswerStats? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      final user = await DatabaseService.instance.getCurrentUser();
      if (user != null) {
        currentUserId = user.id.toString();
        
        final results = await Future.wait([
          WrongAnswerService.getAllWrongAnswers(currentUserId!),
          WrongAnswerService.getWrongAnswersForReview(currentUserId!),
          WrongAnswerService.getResolvedWrongAnswers(currentUserId!),
          WrongAnswerService.getWrongAnswerStats(currentUserId!),
        ]);
        
        setState(() {
          wrongAnswers = results[0] as List<WrongAnswer>;
          reviewAnswers = results[1] as List<WrongAnswer>;
          resolvedAnswers = results[2] as List<WrongAnswer>;
          stats = results[3] as WrongAnswerStats;
        });
      }
    } catch (e) {
      print('Error loading wrong answers: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오답 노트'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showStats,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              icon: const Icon(Icons.error_outline),
              text: '전체 (${wrongAnswers.length})',
            ),
            Tab(
              icon: const Icon(Icons.schedule),
              text: '복습 (${reviewAnswers.length})',
            ),
            Tab(
              icon: const Icon(Icons.check_circle),
              text: '해결 (${resolvedAnswers.length})',
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllWrongAnswers(),
                _buildReviewAnswers(),
                _buildResolvedAnswers(),
              ],
            ),
    );
  }

  Widget _buildAllWrongAnswers() {
    if (wrongAnswers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '오답이 없습니다!\n계속해서 문제를 풀어보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: wrongAnswers.length,
        itemBuilder: (context, index) {
          final wrong = wrongAnswers[index];
          return WrongAnswerCard(
            wrongAnswer: wrong,
            onTap: () => _showQuestionDetail(wrong),
            onReview: () => _startReview([wrong]),
          );
        },
      ),
    );
  }

  Widget _buildReviewAnswers() {
    if (reviewAnswers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '복습할 문제가 없습니다!\n나중에 다시 확인해보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _startReview(reviewAnswers),
            icon: const Icon(Icons.play_arrow),
            label: Text('전체 복습 시작 (${reviewAnswers.length}문제)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: reviewAnswers.length,
            itemBuilder: (context, index) {
              final wrong = reviewAnswers[index];
              return WrongAnswerCard(
                wrongAnswer: wrong,
                onTap: () => _showQuestionDetail(wrong),
                onReview: () => _startReview([wrong]),
                showReviewDate: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResolvedAnswers() {
    if (resolvedAnswers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '해결된 문제가 없습니다.\n문제를 풀고 복습해보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resolvedAnswers.length,
      itemBuilder: (context, index) {
        final wrong = resolvedAnswers[index];
        return WrongAnswerCard(
          wrongAnswer: wrong,
          onTap: () => _showQuestionDetail(wrong),
          isResolved: true,
        );
      },
    );
  }

  void _showQuestionDetail(WrongAnswer wrongAnswer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WrongAnswerDetailScreen(wrongAnswer: wrongAnswer),
      ),
    ).then((_) => _loadData());
  }

  void _startReview(List<WrongAnswer> questions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WrongAnswerReviewScreen(questions: questions),
      ),
    ).then((_) => _loadData());
  }

  void _showStats() {
    if (stats == null) return;

    showDialog(
      context: context,
      builder: (context) => WrongAnswerStatsDialog(stats: stats!),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class WrongAnswerCard extends StatelessWidget {
  final WrongAnswer wrongAnswer;
  final VoidCallback onTap;
  final VoidCallback? onReview;
  final bool isResolved;
  final bool showReviewDate;

  const WrongAnswerCard({
    super.key,
    required this.wrongAnswer,
    required this.onTap,
    this.onReview,
    this.isResolved = false,
    this.showReviewDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(wrongAnswer.difficulty),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getDifficultyText(wrongAnswer.difficulty),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      wrongAnswer.subjectCode,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isResolved)
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                wrongAnswer.question,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '정답: ${wrongAnswer.correctAnswer}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '선택: ${wrongAnswer.userAnswer}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (showReviewDate && wrongAnswer.nextReviewDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '다음 복습: ${_formatDate(wrongAnswer.nextReviewDate!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              if (onReview != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onReview,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('복습하기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
        return '알 수 없음';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '내일';
    } else if (difference > 1) {
      return '$difference일 후';
    } else {
      return '지났음';
    }
  }
}

// 추가 화면들은 다음 파일에서 구현
class WrongAnswerDetailScreen extends StatelessWidget {
  final WrongAnswer wrongAnswer;

  const WrongAnswerDetailScreen({super.key, required this.wrongAnswer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오답 상세'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('상세 화면 구현 예정'),
      ),
    );
  }
}

class WrongAnswerReviewScreen extends StatelessWidget {
  final List<WrongAnswer> questions;

  const WrongAnswerReviewScreen({super.key, required this.questions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오답 복습'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('복습 화면 구현 예정'),
      ),
    );
  }
}

class WrongAnswerStatsDialog extends StatelessWidget {
  final WrongAnswerStats stats;

  const WrongAnswerStatsDialog({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('오답 노트 통계'),
      content: const Text('통계 다이얼로그 구현 예정'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}