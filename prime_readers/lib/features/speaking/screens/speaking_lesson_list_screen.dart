import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/speaking_models.dart';
import '../providers/speaking_provider.dart';

class SpeakingLessonListScreen extends ConsumerStatefulWidget {
  final String userId;
  
  const SpeakingLessonListScreen({
    super.key,
    this.userId = 'temp_user',
  });

  @override
  ConsumerState<SpeakingLessonListScreen> createState() => _SpeakingLessonListScreenState();
}

class _SpeakingLessonListScreenState extends ConsumerState<SpeakingLessonListScreen>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // 샘플 데이터 추가
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(speakingControllerProvider.notifier).addSampleData(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스피킹 연습'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '🟢 초급'),
            Tab(text: '🟡 중급'),
            Tab(text: '🔴 고급'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAllLessonsTab(),
            _buildLevelLessonsTab(SpeakingLevel.beginner),
            _buildLevelLessonsTab(SpeakingLevel.intermediate),
            _buildLevelLessonsTab(SpeakingLevel.advanced),
          ],
        ),
      ),
    );
  }

  Widget _buildAllLessonsTab() {
    final lessonsAsync = ref.watch(speakingLessonsProvider);
    final statsAsync = ref.watch(speakingStatsProvider(widget.userId));
    
    return lessonsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('오류가 발생했습니다\n$error'),
          ],
        ),
      ),
      data: (lessons) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 통계 카드
            statsAsync.when(
              loading: () => const SizedBox(height: 120),
              error: (_, __) => const SizedBox(),
              data: (stats) => _buildStatsCard(stats),
            ),
            const SizedBox(height: 24),
            
            // 레슨 목록
            Text(
              '모든 레슨',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (lessons.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.mic_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('아직 레슨이 없습니다'),
                  ],
                ),
              )
            else
              ...lessons.map((lesson) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SpeakingLessonCard(
                  lesson: lesson,
                  onTap: () => _openLesson(context, lesson),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelLessonsTab(SpeakingLevel level) {
    final lessonsAsync = ref.watch(speakingLessonsByLevelProvider(level));
    
    return lessonsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('오류: $error'),
      ),
      data: (lessons) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${level.displayName} 레슨',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (lessons.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.mic_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('해당 레벨의 레슨이 없습니다'),
                  ],
                ),
              )
            else
              ...lessons.map((lesson) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SpeakingLessonCard(
                  lesson: lesson,
                  onTap: () => _openLesson(context, lesson),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(SpeakingStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_outlined, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '학습 현황',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '전체 레슨',
                    '${stats.totalLessons}개',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '완료',
                    '${stats.completedLessons}개',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '평균 점수',
                    '${stats.averageScore.toInt()}점',
                    Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '연습 시간',
                    '${stats.totalPracticeTime.inMinutes}분',
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              value.split('개')[0].split('점')[0].split('분')[0],
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _openLesson(BuildContext context, SpeakingLesson lesson) {
    context.push('/student-dashboard/speaking/${lesson.id}', extra: {
      'lesson': lesson,
      'userId': widget.userId,
    });
  }
}

// 스피킹 레슨 카드 위젯
class _SpeakingLessonCard extends StatelessWidget {
  final SpeakingLesson lesson;
  final VoidCallback onTap;

  const _SpeakingLessonCard({
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 썸네일
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getLevelColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.mic_outlined,
                  color: _getLevelColor(),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              
              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getLevelColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${lesson.level.emoji} ${lesson.level.displayName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getLevelColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.estimatedMinutes}분',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.quiz_outlined,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.exercises.length}개 문제',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (lesson.isCompleted) ...[ 
                          const Spacer(),
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                        ],
                        if (lesson.averageScore != null) ...[ 
                          const Spacer(),
                          Text(
                            '${lesson.averageScore!.toInt()}점',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getScoreColor(lesson.averageScore!),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // 화살표
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor() {
    switch (lesson.level) {
      case SpeakingLevel.beginner:
        return Colors.green;
      case SpeakingLevel.intermediate:
        return Colors.orange;
      case SpeakingLevel.advanced:
        return Colors.red;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.deepOrange;
    return Colors.red;
  }
}