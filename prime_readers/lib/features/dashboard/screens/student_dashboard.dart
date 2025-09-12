import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prime Readers'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.logout_outlined),
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                _buildWelcomeHeader(context),
                const SizedBox(height: 24),

                // Quick actions
                _buildQuickActions(context, isDesktop),
                const SizedBox(height: 24),

                // Today's tasks
                _buildTodaysTasks(context),
                const SizedBox(height: 24),

                // Progress overview
                _buildProgressOverview(context),
                const SizedBox(height: 24),

                // Recent achievements
                _buildRecentAchievements(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요, 김학생님! 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '오늘도 즐겁게 학습해보세요!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('연속 출석', '7일', Icons.calendar_today),
              const SizedBox(width: 24),
              _buildStatItem('완료한 스토리', '12개', Icons.book),
              const SizedBox(width: 24),
              _buildStatItem('학습 포인트', '850P', Icons.stars),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDesktop) {
    final actions = [
      _ActionItem(
        title: '출석 체크',
        subtitle: '오늘 출석하기',
        icon: Icons.how_to_reg_outlined,
        color: Colors.green,
        onTap: () => context.go('/student-dashboard/attendance'),
      ),
      _ActionItem(
        title: '단어 학습',
        subtitle: '새로운 단어 배우기',
        icon: Icons.quiz_outlined,
        color: Colors.blue,
        onTap: () => context.go('/student-dashboard/learning'),
      ),
      _ActionItem(
        title: '스토리 라이브러리',
        subtitle: '재미있는 이야기',
        icon: Icons.auto_stories_outlined,
        color: Colors.orange,
        onTap: () => context.go('/student-dashboard/story-library'),
      ),
      _ActionItem(
        title: '스피킹 연습',
        subtitle: '발음 연습하기',
        icon: Icons.mic_outlined,
        color: Colors.red,
        onTap: () => context.go('/student-dashboard/speaking'),
      ),
      _ActionItem(
        title: '라이팅 연습',
        subtitle: '글쓰기 연습',
        icon: Icons.edit_outlined,
        color: Colors.purple,
        onTap: () => context.go('/student-dashboard/writing'),
      ),
      _ActionItem(
        title: '독서 라이브러리',
        subtitle: '책 읽고 퀴즈 풀기',
        icon: Icons.library_books_outlined,
        color: Colors.teal,
        onTap: () => context.go('/student-dashboard/reading'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 학습',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 3 : 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _QuickActionCard(action: action);
          },
        ),
      ],
    );
  }

  Widget _buildTodaysTasks(BuildContext context) {
    final tasks = [
      {'title': '영어 단어 10개 복습', 'completed': true},
      {'title': '스토리 "바다 모험" 완료', 'completed': true},
      {'title': '스피킹 연습 3문장', 'completed': false},
      {'title': '"해리포터" 1장 읽기', 'completed': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 할일',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: tasks.map((task) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        task['completed'] as bool
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: task['completed'] as bool
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task['title'] as String,
                          style: TextStyle(
                            decoration: task['completed'] as bool
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressOverview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '학습 진도',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildProgressCard(
                '단어 학습',
                '85%',
                0.85,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProgressCard(
                '스토리 완료',
                '12/20',
                0.60,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProgressCard(
                '독서 목표',
                '8/10',
                0.80,
                Colors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressCard(String title, String value, double progress, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAchievements(BuildContext context) {
    final achievements = [
      {'title': '첫 스피킹 완료', 'date': '2024-01-15', 'icon': Icons.mic},
      {'title': '연속 7일 출석', 'date': '2024-01-14', 'icon': Icons.calendar_today},
      {'title': '단어 마스터', 'date': '2024-01-13', 'icon': Icons.school},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 성취',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: achievements.map((achievement) {
              return ListTile(
                leading: Icon(
                  achievement['icon'] as IconData,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(achievement['title'] as String),
                subtitle: Text(achievement['date'] as String),
                trailing: const Icon(Icons.emoji_events, color: Colors.amber),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _ActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _ActionItem action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                action.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                action.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}