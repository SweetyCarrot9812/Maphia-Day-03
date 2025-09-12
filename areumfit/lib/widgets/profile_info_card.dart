import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/base_model.dart';

/// 사용자 기본 정보를 표시하는 카드 위젯
class ProfileInfoCard extends StatelessWidget {
  final UserProfile profile;

  const ProfileInfoCard({
    super.key,
    required this.profile,
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
              '기본 정보',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.person,
              label: '이름',
              value: profile.name,
            ),
            _buildInfoRow(
              context,
              icon: Icons.wc,
              label: '성별',
              value: _getSexDisplay(profile.sex),
            ),
            _buildInfoRow(
              context,
              icon: Icons.height,
              label: '키',
              value: '${profile.heightCm}cm',
            ),
            _buildInfoRow(
              context,
              icon: Icons.monitor_weight,
              label: '체중',
              value: '${profile.weightKg.toStringAsFixed(1)}${_getWeightUnit(profile.unit)}',
            ),
            if (profile.injuries.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoSection(
                context,
                icon: Icons.healing,
                label: '부상 이력',
                items: profile.injuries,
                color: Colors.orange,
              ),
            ],
            if (profile.preferredDays.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoSection(
                context,
                icon: Icons.calendar_today,
                label: '선호 운동 요일',
                items: profile.preferredDays.map(_getDayDisplay).toList(),
                color: Colors.blue,
              ),
            ],
            if (profile.equipment.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoSection(
                context,
                icon: Icons.fitness_center,
                label: '보유 장비',
                items: profile.equipment,
                color: Colors.green,
              ),
            ],
            const SizedBox(height: 12),
            _buildRpeRange(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required String label,
    required List<String> items,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items.map((item) => Chip(
            label: Text(
              item,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.8),
              ),
            ),
            backgroundColor: color.withValues(alpha: 0.1),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildRpeRange(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.speed,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RPE 선호 범위',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.rpeMin} - ${profile.rpeMax}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getRpeColor(profile.rpeMin, profile.rpeMax),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getRpeIntensity(profile.rpeMin, profile.rpeMax),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSexDisplay(Sex sex) {
    switch (sex) {
      case Sex.male:
        return '남성';
      case Sex.female:
        return '여성';
      case Sex.other:
        return '기타';
    }
  }

  String _getWeightUnit(WeightUnit unit) {
    switch (unit) {
      case WeightUnit.kg:
        return 'kg';
      case WeightUnit.lbs:
        return 'lbs';
    }
  }

  String _getDayDisplay(String day) {
    const dayMap = {
      'Monday': '월',
      'Tuesday': '화',
      'Wednesday': '수',
      'Thursday': '목',
      'Friday': '금',
      'Saturday': '토',
      'Sunday': '일',
      'Mon': '월',
      'Tue': '화',
      'Wed': '수',
      'Thu': '목',
      'Fri': '금',
      'Sat': '토',
      'Sun': '일',
    };
    return dayMap[day] ?? day;
  }

  Color _getRpeColor(int min, int max) {
    final avg = (min + max) / 2;
    if (avg <= 5) return Colors.green;
    if (avg <= 7) return Colors.orange;
    return Colors.red;
  }

  String _getRpeIntensity(int min, int max) {
    final avg = (min + max) / 2;
    if (avg <= 5) return '가벼움';
    if (avg <= 7) return '보통';
    return '힘듦';
  }
}
