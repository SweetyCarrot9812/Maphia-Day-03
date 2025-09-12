import 'package:flutter/material.dart';
import '../models/ai_analysis_models.dart';

/// 개인화된 추천사항 카드 위젯
class RecommendationCard extends StatefulWidget {
  final PersonalizedRecommendation recommendation;
  final Function(PersonalizedRecommendation) onImplement;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.onImplement,
  });

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final recommendation = widget.recommendation;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: _getRecommendationIcon(recommendation.type),
            title: Text(
              recommendation.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              recommendation.description,
              maxLines: _isExpanded ? null : 2,
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPriorityChip(recommendation.priority),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이유 설명
                  Text(
                    '추천 이유',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recommendation.reasoning,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 액션 아이템들
                  if (recommendation.actions.isNotEmpty) ...[
                    Text(
                      '실행 단계',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ...recommendation.actions.map((action) => _buildActionItem(action)),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // 구현 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: recommendation.implemented == true
                          ? null
                          : () => widget.onImplement(recommendation),
                      icon: Icon(
                        recommendation.implemented == true
                            ? Icons.check_circle
                            : Icons.play_arrow,
                      ),
                      label: Text(
                        recommendation.implemented == true
                            ? '적용 완료'
                            : '지금 적용하기',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: recommendation.implemented == true
                            ? Colors.green
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _getRecommendationIcon(RecommendationType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case RecommendationType.exercise_modification:
        iconData = Icons.fitness_center;
        color = Colors.blue;
        break;
      case RecommendationType.rest_day:
        iconData = Icons.hotel;
        color = Colors.green;
        break;
      case RecommendationType.deload_week:
        iconData = Icons.trending_down;
        color = Colors.orange;
        break;
      case RecommendationType.form_correction:
        iconData = Icons.accessibility_new;
        color = Colors.purple;
        break;
      case RecommendationType.nutrition_advice:
        iconData = Icons.restaurant;
        color = Colors.teal;
        break;
      case RecommendationType.recovery_optimization:
        iconData = Icons.self_improvement;
        color = Colors.indigo;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(iconData, color: color),
    );
  }

  Widget _buildPriorityChip(double priority) {
    Color color;
    String label;

    if (priority >= 0.8) {
      color = Colors.red;
      label = '높음';
    } else if (priority >= 0.6) {
      color = Colors.orange;
      label = '보통';
    } else {
      color = Colors.green;
      label = '낮음';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionItem(RecommendationAction action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: action.completed == true ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              action.description,
              style: TextStyle(
                decoration: action.completed == true
                    ? TextDecoration.lineThrough
                    : null,
                color: action.completed == true
                    ? Colors.grey
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
