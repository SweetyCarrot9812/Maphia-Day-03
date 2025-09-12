import 'package:flutter/material.dart';
import '../models/user_profile.dart';

/// 사용자 성취와 통계를 표시하는 카드 위젯
class AchievementsCard extends StatelessWidget {
  final UserWorkoutStats stats;

  const AchievementsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '운동 성취',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildStreakCard(context),
            const SizedBox(height: 12),
            _buildStatsGrid(context),
            const SizedBox(height: 16),
            _buildAchievementBadges(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.8),
            Colors.deepOrange.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '운동 연속 기록',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '${stats.currentStreak}일',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _getStreakIcon(stats.currentStreak),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2,
      children: [
        _buildStatItem(
          context,
          icon: Icons.fitness_center,
          label: '총 운동 세션',
          value: '${stats.totalSessions}회',
          color: Colors.blue,
        ),
        _buildStatItem(
          context,
          icon: Icons.calendar_today,
          label: '이번 주',
          value: '${stats.thisWeekSessions}회',
          color: Colors.green,
        ),
        _buildStatItem(
          context,
          icon: Icons.timer,
          label: '총 운동 시간',
          value: '${(stats.totalMinutes / 60).toStringAsFixed(1)}시간',
          color: Colors.purple,
        ),
        _buildStatItem(
          context,
          icon: Icons.trending_up,
          label: '이번 달',
          value: '${stats.thisMonthSessions}회',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadges(BuildContext context) {
    final achievements = _getAchievements();
    
    if (achievements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.grey[400], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '첫 번째 운동을 시작해보세요!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '달성한 뱃지',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: achievements.map((achievement) => _buildAchievementBadge(
            context,
            achievement: achievement,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(
    BuildContext context, {
    required Achievement achievement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: achievement.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: achievement.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            achievement.icon,
            color: achievement.color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: achievement.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStreakIcon(int streak) {
    if (streak >= 30) {
      return const Icon(Icons.whatshot, color: Colors.white, size: 24);
    } else if (streak >= 7) {
      return const Icon(Icons.local_fire_department, color: Colors.white, size: 24);
    } else if (streak >= 3) {
      return const Icon(Icons.fireplace, color: Colors.white, size: 24);
    } else {
      return const Icon(Icons.whatshot, color: Colors.white, size: 24);
    }
  }

  List<Achievement> _getAchievements() {
    final achievements = <Achievement>[];

    // 운동 횟수 기반 뱃지
    if (stats.totalSessions >= 100) {
      achievements.add(Achievement(
        title: '운동 마스터',
        icon: Icons.fitness_center,
        color: Colors.purple,
      ));
    } else if (stats.totalSessions >= 50) {
      achievements.add(Achievement(
        title: '운동 전문가',
        icon: Icons.fitness_center,
        color: Colors.blue,
      ));
    } else if (stats.totalSessions >= 10) {
      achievements.add(Achievement(
        title: '운동 초보자',
        icon: Icons.fitness_center,
        color: Colors.green,
      ));
    }

    // 연속 기록 기반 뱃지
    if (stats.currentStreak >= 30) {
      achievements.add(Achievement(
        title: '불굴의 의지',
        icon: Icons.whatshot,
        color: Colors.red,
      ));
    } else if (stats.currentStreak >= 7) {
      achievements.add(Achievement(
        title: '일주일 챌린지',
        icon: Icons.local_fire_department,
        color: Colors.orange,
      ));
    } else if (stats.currentStreak >= 3) {
      achievements.add(Achievement(
        title: '꾸준함',
        icon: Icons.fireplace,
        color: Colors.amber,
      ));
    }

    // 성취 기반 뱃지 (achievements 리스트에서)
    for (final achievement in stats.achievements) {
      if (achievement.contains('PR')) {
        achievements.add(Achievement(
          title: 'PR 달성',
          icon: Icons.emoji_events,
          color: const Color(0xFFFFD700),
        ));
        break;
      }
    }

    // 운동 시간 기반 뱃지
    final totalHours = stats.totalMinutes / 60;
    if (totalHours >= 100) {
      achievements.add(Achievement(
        title: '시간의 마법사',
        icon: Icons.schedule,
        color: Colors.indigo,
      ));
    } else if (totalHours >= 50) {
      achievements.add(Achievement(
        title: '시간 투자자',
        icon: Icons.schedule,
        color: Colors.teal,
      ));
    }

    return achievements;
  }
}

class Achievement {
  final String title;
  final IconData icon;
  final Color color;

  const Achievement({
    required this.title,
    required this.icon,
    required this.color,
  });
}

// Color extensions for better achievement colors
extension ColorExtensions on Colors {
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
}
