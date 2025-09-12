import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/story_model.dart';
import '../providers/story_provider.dart';
import '../services/story_service.dart';

class StoryLibraryScreen extends ConsumerStatefulWidget {
  final String userId;
  
  const StoryLibraryScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<StoryLibraryScreen> createState() => _StoryLibraryScreenState();
}

class _StoryLibraryScreenState extends ConsumerState<StoryLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StoryLevel _selectedLevel = StoryLevel.beginner;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // 샘플 데이터 추가
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storyControllerProvider.notifier).addSampleData(widget.userId);
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
        title: const Text('스토리 라이브러리'),
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
            _buildAllStoriesTab(),
            _buildLevelStoriesTab(StoryLevel.beginner),
            _buildLevelStoriesTab(StoryLevel.intermediate),
            _buildLevelStoriesTab(StoryLevel.advanced),
          ],
        ),
      ),
    );
  }

  Widget _buildAllStoriesTab() {
    final storiesAsync = ref.watch(storiesProvider(widget.userId));
    final statsAsync = ref.watch(storyStatsProvider(widget.userId));
    
    return storiesAsync.when(
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
      data: (stories) => SingleChildScrollView(
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
            
            // 스토리 목록
            Text(
              '모든 스토리',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (stories.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('아직 스토리가 없습니다'),
                  ],
                ),
              )
            else
              ...stories.map((story) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StoryCard(
                  story: story,
                  onTap: () => _openStory(context, story),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelStoriesTab(StoryLevel level) {
    final storiesAsync = ref.watch(storiesByLevelProvider({
      'userId': widget.userId,
      'level': level,
    }));
    
    return storiesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('오류: $error'),
      ),
      data: (stories) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${level.displayName} 스토리',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (stories.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('해당 레벨의 스토리가 없습니다'),
                  ],
                ),
              )
            else
              ...stories.map((story) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StoryCard(
                  story: story,
                  onTap: () => _openStory(context, story),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(StoryStats stats) {
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
                    '전체 스토리',
                    '${stats.totalStories}개',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '완료',
                    '${stats.completedStories}개',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '진행 중',
                    '${stats.inProgressStories}개',
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '평균 점수',
                    '${stats.averageScore.toInt()}점',
                    Colors.purple,
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
              value.split('개')[0].split('점')[0],
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

  void _openStory(BuildContext context, Story story) {
    // 스토리 읽기 화면으로 이동
    context.push('/story-reading/${story.id}', extra: {
      'story': story,
      'userId': widget.userId,
    });
  }
}

// 스토리 카드 위젯
class _StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;

  const _StoryCard({
    required this.story,
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
                  Icons.auto_stories_outlined,
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
                            story.title,
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
                            '${story.level.emoji} ${story.level.displayName}',
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
                      story.description,
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
                          '${story.estimatedMinutes}분',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.library_books_outlined,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${story.scenes.length}개 장면',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (story.isCompleted) ...[
                          const Spacer(),
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
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
    switch (story.level) {
      case StoryLevel.beginner:
        return Colors.green;
      case StoryLevel.intermediate:
        return Colors.orange;
      case StoryLevel.advanced:
        return Colors.red;
    }
  }
}