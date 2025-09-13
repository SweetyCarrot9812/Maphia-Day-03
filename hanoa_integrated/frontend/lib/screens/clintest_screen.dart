import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/clintest_service.dart';
import '../models/question.dart';
import 'question_form_screen.dart';

class ClintestScreen extends ConsumerStatefulWidget {
  const ClintestScreen({super.key});

  @override
  ConsumerState<ClintestScreen> createState() => _ClintestScreenState();
}

class _ClintestScreenState extends ConsumerState<ClintestScreen> {
  final ClintestService _clintestService = ClintestService();
  String _selectedSubject = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    if (_selectedSubject == 'all') {
      await _clintestService.loadQuestions();
    } else {
      await _clintestService.loadQuestionsBySubject(_selectedSubject);
    }
  }

  Future<void> _searchQuestions(String query) async {
    setState(() {
      _searchQuery = query;
    });
    await _clintestService.searchQuestions(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clintest - 의학 문제 은행'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('문제 추가'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuestionFormScreen(),
                ),
              ).then((_) => _loadQuestions());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red.shade600,
              elevation: 0,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuestions,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 및 필터 영역
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                // 검색바
                TextField(
                  decoration: InputDecoration(
                    hintText: '문제 검색...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: _searchQuestions,
                ),
                const SizedBox(height: 12),

                // 카테고리 필터
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('all', '전체'),
                      ...ClintestService.categories.map(
                        (category) => _buildCategoryChip(category, category),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 문제 목록
          Expanded(
            child: AnimatedBuilder(
              animation: _clintestService,
              builder: (context, child) {
                if (_clintestService.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (_clintestService.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _clintestService.error!,
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _clintestService.clearError();
                            _loadQuestions();
                          },
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  );
                }

                final questions = _clintestService.questions;

                if (questions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? '검색 결과가 없습니다'
                              : '등록된 문제가 없습니다',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QuestionFormScreen(),
                              ),
                            ).then((_) => _loadQuestions());
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('첫 문제 추가하기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return _buildQuestionCard(question);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QuestionFormScreen(),
            ),
          ).then((_) => _loadQuestions());
        },
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('문제 추가'),
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    final isSelected = _selectedSubject == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedSubject = value;
          });
          _loadQuestions();
        },
        selectedColor: Colors.red.shade100,
        checkmarkColor: Colors.red.shade600,
        labelStyle: TextStyle(
          color: isSelected ? Colors.red.shade600 : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 문제 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    question.subject,
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(question.difficulty),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getDifficultyLabel(question.difficulty),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestionFormScreen(
                            question: question,
                          ),
                        ),
                      ).then((_) => _loadQuestions());
                    } else if (value == 'delete') {
                      _showDeleteDialog(question);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('수정'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('삭제', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 문제 텍스트
            Text(
              question.questionText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // 선택지들
            ...question.choices.asMap().entries.map((entry) {
              final index = entry.key;
              final choice = entry.value;
              final isCorrect = index == question.correctAnswer;

              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCorrect ? Colors.green : Colors.grey.shade300,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCorrect ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        choice,
                        style: TextStyle(
                          fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                          color: isCorrect ? Colors.green.shade700 : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // 설명 (있는 경우)
            if (question.explanation.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '해설',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      question.explanation,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 작성 정보
            const SizedBox(height: 8),
            Text(
              '작성자: ${question.createdBy} | 작성일: ${_formatDate(question.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
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

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return '쉬움';
      case 'medium':
        return '보통';
      case 'hard':
        return '어려움';
      default:
        return '보통';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog(Question question) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('문제 삭제'),
        content: const Text('이 문제를 삭제하시겠습니까?\n삭제된 문제는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _clintestService.deleteQuestion(question.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('문제가 삭제되었습니다'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}