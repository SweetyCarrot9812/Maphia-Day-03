import 'package:flutter/material.dart';
import '../models/learning_goal.dart';
import '../services/learning_goal_service.dart';
import '../services/auth_service.dart';
import 'create_goal_screen.dart';

class LearningGoalsScreen extends StatefulWidget {
  const LearningGoalsScreen({super.key});

  @override
  State<LearningGoalsScreen> createState() => _LearningGoalsScreenState();
}

class _LearningGoalsScreenState extends State<LearningGoalsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<LearningGoal> _activeGoals = [];
  List<LearningGoal> _completedGoals = [];
  List<GoalRecommendation> _recommendations = [];
  GoalAchievementStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = AuthService.instance.currentUser?.uid ?? 'user1';
      
      final results = await Future.wait([
        LearningGoalService.getActiveGoals(userId),
        LearningGoalService.getCompletedGoals(userId),
        LearningGoalService.recommendGoals(userId),
        LearningGoalService.getGoalAchievementStats(userId),
      ]);
      
      setState(() {
        _activeGoals = results[0] as List<LearningGoal>;
        _completedGoals = results[1] as List<LearningGoal>;
        _recommendations = results[2] as List<GoalRecommendation>;
        _stats = results[3] as GoalAchievementStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로딩 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 목표'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '활성 목표'),
            Tab(text: '완료된 목표'),
            Tab(text: '추천 목표'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToCreateGoal(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_stats != null) _buildStatsOverview(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildActiveGoalsTab(),
                      _buildCompletedGoalsTab(),
                      _buildRecommendationsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('완료율', '${(_stats!.completionRate * 100).toStringAsFixed(1)}%'),
          _buildStatItem('활성 목표', '${_stats!.activeGoals}개'),
          _buildStatItem('획득 XP', '${_stats!.totalXpEarned}'),
          _buildStatItem('연속 달성', '${_stats!.streakDays}일'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveGoalsTab() {
    if (_activeGoals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.target, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '활성 목표가 없습니다',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '새로운 목표를 만들어 학습을 시작해보세요!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _activeGoals.length,
      itemBuilder: (context, index) {
        return _buildGoalCard(_activeGoals[index]);
      },
    );
  }

  Widget _buildCompletedGoalsTab() {
    if (_completedGoals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '완료된 목표가 없습니다',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '목표를 달성하면 여기에 표시됩니다!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _completedGoals.length,
      itemBuilder: (context, index) {
        return _buildGoalCard(_completedGoals[index]);
      },
    );
  }

  Widget _buildRecommendationsTab() {
    if (_recommendations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '추천 목표가 없습니다',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '학습 데이터가 충분하지 않습니다',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _recommendations.length,
      itemBuilder: (context, index) {
        return _buildRecommendationCard(_recommendations[index]);
      },
    );
  }

  Widget _buildGoalCard(LearningGoal goal) {
    final isCompleted = goal.isCompleted;
    final isOverdue = goal.isOverdue;
    
    Color cardColor = Colors.white;
    Color accentColor = Colors.blue;
    
    if (isCompleted) {
      cardColor = Colors.green.withOpacity(0.1);
      accentColor = Colors.green;
    } else if (isOverdue) {
      cardColor = Colors.red.withOpacity(0.1);
      accentColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildPriorityChip(goal.priority),
              ],
            ),
            if (goal.description?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                goal.description!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(_getGoalTypeIcon(goal.type), size: 16, color: accentColor),
                const SizedBox(width: 4),
                Text(
                  _getGoalTypeText(goal.type),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '${goal.currentValue}/${goal.targetValue} ${goal.targetUnit}',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: goal.progressPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '진행률: ${goal.progressPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (goal.targetDate != null && !isCompleted)
                  Text(
                    isOverdue 
                        ? '${goal.daysRemaining.abs()}일 지연'
                        : '${goal.daysRemaining}일 남음',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                if (isCompleted && goal.completionDate != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        '완료됨',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (goal.milestones.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildMilestonesRow(goal.milestones),
            ],
            if (!isCompleted && goal.status == GoalStatus.active) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _pauseGoal(goal),
                    child: const Text('일시정지'),
                  ),
                  TextButton(
                    onPressed: () => _completeGoal(goal),
                    child: const Text('완료 처리'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesRow(List<GoalMilestone> milestones) {
    return Row(
      children: [
        const Icon(Icons.flag, size: 14, color: Colors.orange),
        const SizedBox(width: 4),
        Expanded(
          child: Wrap(
            spacing: 4,
            children: milestones.map((milestone) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: milestone.isCompleted ? Colors.green : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  milestone.title,
                  style: TextStyle(
                    fontSize: 10,
                    color: milestone.isCompleted ? Colors.white : Colors.grey[700],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(GoalRecommendation recommendation) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    recommendation.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildPriorityChip(recommendation.priority),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              recommendation.description,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(_getGoalTypeIcon(recommendation.type), size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  _getGoalTypeText(recommendation.type),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '목표: ${recommendation.targetValue} ${recommendation.targetUnit}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '예상 기간: ${recommendation.estimatedDays}일',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _createGoalFromRecommendation(recommendation),
                  child: const Text('목표 설정'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(GoalPriority priority) {
    Color color;
    String text;
    
    switch (priority) {
      case GoalPriority.low:
        color = Colors.grey;
        text = '낮음';
        break;
      case GoalPriority.medium:
        color = Colors.blue;
        text = '보통';
        break;
      case GoalPriority.high:
        color = Colors.orange;
        text = '높음';
        break;
      case GoalPriority.critical:
        color = Colors.red;
        text = '긴급';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getGoalTypeIcon(GoalType type) {
    switch (type) {
      case GoalType.accuracy:
        return Icons.precision_manufacturing;
      case GoalType.volume:
        return Icons.quiz;
      case GoalType.consistency:
        return Icons.calendar_today;
      case GoalType.mastery:
        return Icons.school;
      case GoalType.speed:
        return Icons.speed;
      case GoalType.comprehensive:
        return Icons.all_inclusive;
    }
  }

  String _getGoalTypeText(GoalType type) {
    switch (type) {
      case GoalType.accuracy:
        return '정확도';
      case GoalType.volume:
        return '문제량';
      case GoalType.consistency:
        return '일관성';
      case GoalType.mastery:
        return '마스터리';
      case GoalType.speed:
        return '속도';
      case GoalType.comprehensive:
        return '종합';
    }
  }

  void _navigateToCreateGoal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGoalScreen()),
    );
    
    if (result == true) {
      _loadData();
    }
  }

  void _createGoalFromRecommendation(GoalRecommendation recommendation) async {
    final userId = AuthService.instance.currentUser?.uid ?? 'user1';
    
    try {
      await LearningGoalService.createGoal(
        userId: userId,
        title: recommendation.title,
        description: recommendation.description,
        category: recommendation.category,
        type: recommendation.type,
        targetValue: recommendation.targetValue,
        targetUnit: recommendation.targetUnit,
        targetDate: DateTime.now().add(Duration(days: recommendation.estimatedDays)),
        priority: recommendation.priority,
        difficulty: recommendation.difficulty,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('목표가 생성되었습니다!')),
      );
      
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('목표 생성 중 오류가 발생했습니다: $e')),
      );
    }
  }

  void _pauseGoal(LearningGoal goal) async {
    final userId = AuthService.instance.currentUser?.uid ?? 'user1';
    
    try {
      await LearningGoalService.updateGoalStatus(userId, goal.id!, GoalStatus.paused);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('목표가 일시정지되었습니다')),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }

  void _completeGoal(LearningGoal goal) async {
    final userId = AuthService.instance.currentUser?.uid ?? 'user1';
    
    try {
      await LearningGoalService.updateGoalStatus(userId, goal.id!, GoalStatus.completed);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 목표 달성! ${goal.xpReward} XP를 획득했습니다!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }
}