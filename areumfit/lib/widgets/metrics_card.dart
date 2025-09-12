import 'package:flutter/material.dart';
import '../models/user_profile.dart';

/// 사용자 운동 메트릭스를 표시하는 카드 위젯
class MetricsCard extends StatelessWidget {
  final UserMetrics metrics;

  const MetricsCard({
    super.key,
    required this.metrics,
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
              '운동 메트릭스',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildFatigueScore(context),
            const SizedBox(height: 12),
            _buildSleepHours(context),
            if (metrics.oneRM.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildOneRMSection(context),
            ],
            if (metrics.lastPRAt != null) ...[
              const SizedBox(height: 12),
              _buildLastPR(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFatigueScore(BuildContext context) {
    final color = _getFatigueColor(metrics.fatigueScore);
    final description = _getFatigueDescription(metrics.fatigueScore);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.battery_alert, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '피로도',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${metrics.fatigueScore}/10',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepHours(BuildContext context) {
    final color = _getSleepColor(metrics.sleepHours);
    final description = _getSleepDescription(metrics.sleepHours);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.bedtime, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '수면 시간',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${metrics.sleepHours.toStringAsFixed(1)}h',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOneRMSection(BuildContext context) {
    final sortedEntries = metrics.oneRM.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1RM 기록',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...sortedEntries.take(5).map((entry) => _buildOneRMItem(
          context,
          exercise: entry.key,
          weight: entry.value,
        )),
        if (sortedEntries.length > 5) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _showAllOneRM(context),
            child: Text(
              '모든 1RM 보기 (${sortedEntries.length}개)',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOneRMItem(
    BuildContext context, {
    required String exercise,
    required double weight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.fitness_center,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              exercise,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${weight.toStringAsFixed(1)}kg',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastPR(BuildContext context) {
    final daysSincePR = DateTime.now().difference(metrics.lastPRAt!).inDays;
    final prText = daysSincePR == 0 
        ? '오늘' 
        : daysSincePR == 1 
        ? '어제' 
        : '$daysSincePR일 전';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '최근 개인 기록',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$prText 개인 기록 달성!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.star, color: Colors.amber),
        ],
      ),
    );
  }

  Color _getFatigueColor(int fatigueScore) {
    if (fatigueScore <= 3) return Colors.green;
    if (fatigueScore <= 6) return Colors.orange;
    return Colors.red;
  }

  String _getFatigueDescription(int fatigueScore) {
    if (fatigueScore <= 3) return '컨디션 좋음, 운동하기 좋은 상태';
    if (fatigueScore <= 6) return '보통 컨디션, 적당한 강도로 운동';
    return '피로함, 휴식이나 가벼운 운동 권장';
  }

  Color _getSleepColor(double sleepHours) {
    if (sleepHours >= 7) return Colors.green;
    if (sleepHours >= 5) return Colors.orange;
    return Colors.red;
  }

  String _getSleepDescription(double sleepHours) {
    if (sleepHours >= 7) return '충분한 수면, 회복이 잘 됨';
    if (sleepHours >= 5) return '보통 수면, 컨디션 관리 필요';
    return '수면 부족, 휴식 우선 권장';
  }

  void _showAllOneRM(BuildContext context) {
    final allEntries = metrics.oneRM.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 1RM 기록'),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: allEntries.length,
            itemBuilder: (context, index) {
              final entry = allEntries[index];
              return ListTile(
                leading: const Icon(Icons.fitness_center, size: 20),
                title: Text(entry.key),
                trailing: Text(
                  '${entry.value.toStringAsFixed(1)}kg',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}