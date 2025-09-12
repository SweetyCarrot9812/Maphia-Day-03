import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import '../db/database.dart';
import '../services/ai_coach_service.dart';
import '../models/todays_workout_plan.dart';
import '../models/exercise_recommendation.dart';
import '../widgets/blur_fade_text.dart';
import '../widgets/animated_beam.dart';
import '../widgets/gradient_card.dart';
import '../utils/responsive_utils.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final AICoachService _aiService = AICoachService();
  TodaysWorkoutPlan? _workoutPlan;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTodaysWorkout();
  }

  Future<void> _loadTodaysWorkout() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final plan = await _aiService.generateTodaysWorkout(
        userId: 'demo_user',
        currentCondition: {
          'energy': 'good',
          'soreness': 'none',
          'sleep': 8,
          'stress': 'low'
        },
      );
      
      setState(() {
        _workoutPlan = plan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('오늘의 운동을 분석하고 있습니다...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('오류가 발생했습니다: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTodaysWorkout,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_workoutPlan == null) {
      return const Center(child: Text('운동 계획을 불러올 수 없습니다.'));
    }

    return RefreshIndicator(
      onRefresh: _loadTodaysWorkout,
      child: ResponsiveBuilder(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        foldableExpanded: _buildFoldableLayout(),
      ),
    );
  }

  Widget _buildHeader() {
    final today = DateTime.now();
    final dateStr = '${today.month}월 ${today.day}일 (${_getWeekdayStr(today.weekday)})';
    
    return GradientCard(
      colors: const [Color(0xFF2AB1A2), Color(0xFF1A8A7D)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: BlurFadeText(
                  text: dateStr,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  delay: const Duration(milliseconds: 300),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadTodaysWorkout,
                tooltip: '새로고침',
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlurFadeText(
            text: _workoutPlan!.dailyReasoning,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            delay: const Duration(milliseconds: 600),
          ),
        ],
      ),
    );
  }

  Widget _buildRestDay() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.hotel, size: 64, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  '오늘은 휴식일입니다',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  '근육 회복과 성장을 위해 충분한 휴식을 취하세요.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildTips(),
      ],
    );
  }

  Widget _buildWorkoutPlan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMuscleGroups(),
        const SizedBox(height: 16),
        _buildExercises(),
        const SizedBox(height: 16),
        _buildTips(),
      ],
    );
  }

  Widget _buildMuscleGroups() {
    return BeamBorder(
      borderColor: Colors.teal.withOpacity(0.6),
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlurFadeText(
                text: '오늘의 타겟 근육군',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                delay: const Duration(milliseconds: 900),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _workoutPlan!.primaryMuscleGroups
                    .asMap()
                    .entries
                    .map((entry) => AnimatedBeam(
                          beamColor: Colors.teal.withOpacity(0.3),
                          duration: Duration(milliseconds: 1500 + (entry.key * 200)),
                          continuous: false,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.secondaryContainer,
                                  Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExercises() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlurFadeText(
          text: '추천 운동',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          delay: const Duration(milliseconds: 1200),
        ),
        const SizedBox(height: 12),
        ...(_workoutPlan!.exercises.asMap().entries.map(
          (entry) => _buildExerciseCard(entry.value, entry.key),
        )),
      ],
    );
  }

  Widget _buildExerciseCard(ExerciseRecommendation exercise, int index) {
    return AnimatedBeam(
      beamColor: _getPriorityColor(exercise.priority).withOpacity(0.3),
      duration: Duration(milliseconds: 2000 + (index * 300)),
      continuous: false,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: BlurFadeText(
                      text: exercise.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      delay: Duration(milliseconds: 1500 + (index * 200)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getPriorityColor(exercise.priority),
                          _getPriorityColor(exercise.priority).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _getPriorityColor(exercise.priority).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      exercise.priority.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatChip('${exercise.weight}kg', Icons.fitness_center),
                  const SizedBox(width: 8),
                  _buildStatChip('${exercise.reps}회', Icons.repeat),
                  const SizedBox(width: 8),
                  _buildStatChip('${exercise.sets}세트', Icons.format_list_numbered),
                  const SizedBox(width: 8),
                  _buildStatChip('RPE ${exercise.rpe}', Icons.speed),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '휴식: ${exercise.restSeconds}초',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                exercise.reasoning,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to exercise detail
                    },
                    child: const Text('상세 보기'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Start this exercise
                      _startExercise(exercise);
                    },
                    child: const Text('시작하기'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    if (_workoutPlan!.tips.isEmpty) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '오늘의 팁',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_workoutPlan!.tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(tip)),
                ],
              ),
            ))),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getWeekdayStr(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[weekday - 1];
  }

  void _startExercise(ExerciseRecommendation exercise) {
    // TODO: Navigate to workout screen with this exercise pre-selected
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${exercise.name} 운동을 시작합니다!'),
        action: SnackBarAction(
          label: '운동하기',
          onPressed: () {
            HapticFeedback.selectionClick();
            // Navigate to workout screen
          },
        ),
      ),
    );
  }

  // 모바일 레이아웃
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: ResponsiveUtils.getAdaptivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          if (_workoutPlan!.isRestDay) _buildRestDay() else _buildWorkoutPlan(),
        ],
      ),
    );
  }

  // 태블릿 레이아웃
  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: ResponsiveUtils.getAdaptivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          if (_workoutPlan!.isRestDay) 
            _buildRestDay() 
          else 
            _buildTabletWorkoutPlan(),
        ],
      ),
    );
  }

  // 갤럭시 폴드 펼친 상태 레이아웃
  Widget _buildFoldableLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 메인 콘텐츠 (왼쪽)
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: ResponsiveUtils.getAdaptivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                if (_workoutPlan!.isRestDay) 
                  _buildRestDay() 
                else 
                  _buildMuscleGroups(),
                const SizedBox(height: 16),
                if (!_workoutPlan!.isRestDay)
                  _buildTips(),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        // 사이드 패널 (오른쪽) - 운동 목록
        Expanded(
          flex: 1,
          child: Container(
            height: double.infinity,
            padding: ResponsiveUtils.getAdaptivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlurFadeText(
                  text: '오늘의 운동',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  delay: const Duration(milliseconds: 300),
                ),
                const SizedBox(height: 16),
                if (!_workoutPlan!.isRestDay)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _workoutPlan!.exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _workoutPlan!.exercises[index];
                        return _buildCompactExerciseCard(exercise, index);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 태블릿용 그리드 워크아웃 플랜
  Widget _buildTabletWorkoutPlan() {
    final columns = ResponsiveUtils.getGridColumns(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMuscleGroups(),
        const SizedBox(height: 24),
        BlurFadeText(
          text: '추천 운동',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          delay: const Duration(milliseconds: 1200),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _workoutPlan!.exercises.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: 1.2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final exercise = _workoutPlan!.exercises[index];
            return _buildGridExerciseCard(exercise, index);
          },
        ),
        const SizedBox(height: 24),
        _buildTips(),
      ],
    );
  }

  // 간단한 운동 카드 (사이드 패널용)
  Widget _buildCompactExerciseCard(ExerciseRecommendation exercise, int index) {
    return AnimatedBeam(
      beamColor: _getPriorityColor(exercise.priority).withOpacity(0.3),
      duration: Duration(milliseconds: 1000 + (index * 200)),
      continuous: false,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 4,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            _startExercise(exercise);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(exercise.priority),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${exercise.weight}kg × ${exercise.reps}회 × ${exercise.sets}세트',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'RPE ${exercise.rpe}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 그리드용 운동 카드
  Widget _buildGridExerciseCard(ExerciseRecommendation exercise, int index) {
    return AnimatedBeam(
      beamColor: _getPriorityColor(exercise.priority).withOpacity(0.3),
      duration: Duration(milliseconds: 1500 + (index * 200)),
      continuous: false,
      child: Card(
        elevation: 6,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            _showExerciseDetails(exercise);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(exercise.priority),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        exercise.priority[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _buildMiniStatChip('${exercise.weight}kg'),
                    _buildMiniStatChip('${exercise.reps}회'),
                    _buildMiniStatChip('${exercise.sets}세트'),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RPE ${exercise.rpe}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.play_circle_fill,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStatChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }

  void _showExerciseDetails(ExerciseRecommendation exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              exercise.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatChip('${exercise.weight}kg', Icons.fitness_center),
                const SizedBox(width: 8),
                _buildStatChip('${exercise.reps}회', Icons.repeat),
                const SizedBox(width: 8),
                _buildStatChip('${exercise.sets}세트', Icons.format_list_numbered),
                const SizedBox(width: 8),
                _buildStatChip('RPE ${exercise.rpe}', Icons.speed),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '설명',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              exercise.reasoning,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _startExercise(exercise);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('운동 시작'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
