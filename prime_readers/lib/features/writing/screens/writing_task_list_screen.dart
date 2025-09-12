import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/writing_models.dart';
import '../providers/writing_provider.dart';

class WritingTaskListScreen extends ConsumerStatefulWidget {
  final String userId;
  
  const WritingTaskListScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<WritingTaskListScreen> createState() => _WritingTaskListScreenState();
}

class _WritingTaskListScreenState extends ConsumerState<WritingTaskListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  WritingTaskType? _selectedType;
  DifficultyLevel? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(writingTasksProvider);
    final userStatsAsync = ref.watch(userWritingStatsProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('라이팅 연습'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '모든 과제', icon: Icon(Icons.assignment)),
            Tab(text: '내 활동', icon: Icon(Icons.person)),
            Tab(text: '통계', icon: Icon(Icons.analytics)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              _showFilterDialog();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    Icon(Icons.tune),
                    SizedBox(width: 8),
                    Text('필터'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 모든 과제 탭
          _buildAllTasksTab(tasksAsync),
          // 내 활동 탭
          _buildMyActivityTab(),
          // 통계 탭
          _buildStatsTab(userStatsAsync),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _checkActiveSessionAndStart(),
        tooltip: '새 라이팅 시작',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAllTasksTab(AsyncValue<List<WritingTask>> tasksAsync) {
    return tasksAsync.when(
      data: (tasks) {
        var filteredTasks = tasks;
        
        // 타입 필터 적용
        if (_selectedType != null) {
          filteredTasks = filteredTasks.where((task) => task.type == _selectedType).toList();
        }
        
        // 난이도 필터 적용
        if (_selectedDifficulty != null) {
          filteredTasks = filteredTasks.where((task) => task.difficulty == _selectedDifficulty).toList();
        }

        if (filteredTasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '조건에 맞는 과제가 없습니다',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return _buildTaskCard(task);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('오류가 발생했습니다: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(writingTasksProvider),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(WritingTask task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _startWritingTask(task),
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
                      color: _getTypeColor(task.type).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getTypeLabel(task.type),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getTypeColor(task.type),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(task.difficulty).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getDifficultyLabel(task.difficulty),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getDifficultyColor(task.difficulty),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.timeLimit.inMinutes}분',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.text_fields,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.minWords}-${task.maxWords} 단어',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _startWritingTask(task),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('시작하기'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyActivityTab() {
    final submissionsAsync = ref.watch(userWritingSubmissionsProvider(widget.userId));
    
    return submissionsAsync.when(
      data: (submissions) {
        if (submissions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '아직 제출한 라이팅이 없습니다',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  '첫 번째 라이팅을 시작해보세요!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: submissions.length,
          itemBuilder: (context, index) {
            final submission = submissions[index];
            return _buildSubmissionCard(submission);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('오류가 발생했습니다: $error'),
      ),
    );
  }

  Widget _buildSubmissionCard(WritingSubmission submission) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewSubmissionDetail(submission),
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
                      color: _getStatusColor(submission.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(submission.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(submission.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (submission.evaluation != null) ...[
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${submission.evaluation!.overallScore.toInt()}점',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                submission.content.length > 100 
                    ? '${submission.content.substring(0, 100)}...'
                    : submission.content,
                style: const TextStyle(fontSize: 14, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(submission.submittedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.text_fields,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${submission.wordCount} 단어',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsTab(AsyncValue<Map<String, dynamic>> statsAsync) {
    return statsAsync.when(
      data: (stats) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '라이팅 통계',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '총 제출',
                    '${stats['totalSubmissions']}개',
                    Icons.assignment_turned_in,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '완료',
                    '${stats['completedSubmissions']}개',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '총 단어 수',
                    '${stats['totalWords']}',
                    Icons.text_fields,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '평균 점수',
                    '${stats['averageScore'].toStringAsFixed(1)}점',
                    Icons.star,
                    Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '유형별 분포',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._buildTypeDistribution(stats['typeDistribution']),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('통계를 불러올 수 없습니다: $error'),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTypeDistribution(Map<String, dynamic> distribution) {
    if (distribution.isEmpty) {
      return [
        const Text(
          '아직 작성한 라이팅이 없습니다',
          style: TextStyle(color: Colors.grey),
        ),
      ];
    }

    return distribution.entries.map((entry) {
      final type = WritingTaskType.values.firstWhere(
        (t) => t.name == entry.key,
        orElse: () => WritingTaskType.essay,
      );
      final count = entry.value as int;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getTypeColor(type),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(_getTypeLabel(type)),
            const Spacer(),
            Text(
              '$count개',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('필터'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<WritingTaskType?>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: '과제 유형'),
              items: [
                const DropdownMenuItem(value: null, child: Text('모든 유형')),
                ...WritingTaskType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeLabel(type)),
                )),
              ],
              onChanged: (value) => setState(() => _selectedType = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DifficultyLevel?>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(labelText: '난이도'),
              items: [
                const DropdownMenuItem(value: null, child: Text('모든 난이도')),
                ...DifficultyLevel.values.map((level) => DropdownMenuItem(
                  value: level,
                  child: Text(_getDifficultyLabel(level)),
                )),
              ],
              onChanged: (value) => setState(() => _selectedDifficulty = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _selectedDifficulty = null;
              });
              Navigator.of(context).pop();
            },
            child: const Text('초기화'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('적용'),
          ),
        ],
      ),
    );
  }

  void _checkActiveSessionAndStart() async {
    final activeSession = await ref.read(activeWritingSessionProvider(widget.userId).future);
    
    if (activeSession != null) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('진행 중인 세션'),
          content: const Text('진행 중인 라이팅 세션이 있습니다. 계속하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('새로 시작'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('계속하기'),
            ),
          ],
        ),
      );

      if (shouldContinue == true) {
        context.push('/student-dashboard/writing/session/${activeSession.id}');
        return;
      } else {
        // 기존 세션 포기
        ref.read(writingControllerProvider.notifier).abandonSession();
      }
    }

    // 새로운 세션 시작을 위해 과제 선택 필요
    // 여기서는 과제 목록에서 선택하도록 안내
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('시작할 과제를 선택해주세요')),
    );
  }

  void _startWritingTask(WritingTask task) async {
    final controller = ref.read(writingControllerProvider.notifier);
    await controller.startWritingSession(widget.userId, task.id);
    
    if (mounted) {
      context.push('/student-dashboard/writing/practice/${task.id}');
    }
  }

  void _viewSubmissionDetail(WritingSubmission submission) {
    context.push('/student-dashboard/writing/submission/${submission.id}');
  }

  String _getTypeLabel(WritingTaskType type) {
    switch (type) {
      case WritingTaskType.essay: return '에세이';
      case WritingTaskType.letter: return '편지';
      case WritingTaskType.story: return '이야기';
      case WritingTaskType.diary: return '일기';
      case WritingTaskType.report: return '보고서';
      case WritingTaskType.review: return '후기';
      case WritingTaskType.description: return '묘사';
      case WritingTaskType.opinion: return '의견';
      case WritingTaskType.instruction: return '설명서';
      case WritingTaskType.creative: return '창작';
      case WritingTaskType.descriptive: return '묘사적';
      case WritingTaskType.argumentative: return '논증적';
      case WritingTaskType.summary: return '요약';
    }
  }

  Color _getTypeColor(WritingTaskType type) {
    switch (type) {
      case WritingTaskType.essay: return Colors.blue;
      case WritingTaskType.letter: return Colors.green;
      case WritingTaskType.story: return Colors.purple;
      case WritingTaskType.diary: return Colors.pink;
      case WritingTaskType.report: return Colors.indigo;
      case WritingTaskType.review: return Colors.orange;
      case WritingTaskType.description: return Colors.teal;
      case WritingTaskType.opinion: return Colors.red;
      case WritingTaskType.instruction: return Colors.brown;
      case WritingTaskType.creative: return Colors.deepPurple;
      case WritingTaskType.descriptive: return Colors.cyan;
      case WritingTaskType.argumentative: return Colors.amber;
      case WritingTaskType.summary: return Colors.lime;
    }
  }

  String _getDifficultyLabel(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner: return '초급';
      case DifficultyLevel.intermediate: return '중급';
      case DifficultyLevel.advanced: return '고급';
    }
  }

  Color _getDifficultyColor(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner: return Colors.green;
      case DifficultyLevel.intermediate: return Colors.orange;
      case DifficultyLevel.advanced: return Colors.red;
    }
  }

  String _getStatusLabel(WritingStatus status) {
    switch (status) {
      case WritingStatus.draft: return '작성 중';
      case WritingStatus.submitted: return '제출됨';
      case WritingStatus.evaluating: return '평가 중';
      case WritingStatus.evaluated: return '평가 완료';
      case WritingStatus.revised: return '수정됨';
      case WritingStatus.completed: return '완료';
    }
  }

  Color _getStatusColor(WritingStatus status) {
    switch (status) {
      case WritingStatus.draft: return Colors.grey;
      case WritingStatus.submitted: return Colors.blue;
      case WritingStatus.evaluating: return Colors.orange;
      case WritingStatus.evaluated: return Colors.green;
      case WritingStatus.revised: return Colors.purple;
      case WritingStatus.completed: return Colors.teal;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}