import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../providers/auth_provider.dart';
import '../models/workout_plan.dart';
import '../models/workout_log.dart';
import '../models/base_model.dart'; // ExerciseType, SessionStatus

/// 운동 실행 화면
/// v0.9 운동 실행 루프의 핵심 화면
class WorkoutScreen extends StatefulWidget {
  final List<Exercise>? exercises;
  final String? planId;
  
  const WorkoutScreen({
    Key? key,
    this.exercises,
    this.planId,
  }) : super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  
  // 현재 세트 입력값들
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _rpeController = TextEditingController(text: '7');
  final _noteController = TextEditingController();
  
  // 각 운동별 완료된 세트들
  final Map<int, List<WorkoutLog>> _completedSets = {};
  
  // 기본 샘플 운동들 (실제 구현에서는 AI 코치나 플랜에서 가져옴)
  late List<Exercise> _exercises;

  @override
  void initState() {
    super.initState();
    _initializeExercises();
    _initializeSession();
  }

  /// 운동 초기화 (샘플 데이터 또는 전달받은 데이터)
  void _initializeExercises() {
    _exercises = widget.exercises ?? _getDefaultExercises();
  }
  
  /// 기본 샘플 운동들
  List<Exercise> _getDefaultExercises() {
    return [
      const Exercise(
        key: 'squat',
        name: '스쿼트',
        type: ExerciseType.compound,
        targetSets: 3,
        restSec: 120,
        prescription: ExercisePrescription(
          reps: 8,
          percent1RM: 80.0,
          rpe: 8,
        ),
        notes: '무릎이 발가락을 넘지 않도록 주의',
      ),
      const Exercise(
        key: 'bench_press',
        name: '벤치프레스',
        type: ExerciseType.compound,
        targetSets: 3,
        restSec: 180,
        prescription: ExercisePrescription(
          reps: 6,
          percent1RM: 85.0,
          rpe: 8,
        ),
        notes: '가슴을 펴고 어깨날개를 모으세요',
      ),
      const Exercise(
        key: 'deadlift',
        name: '데드리프트',
        type: ExerciseType.compound,
        targetSets: 3,
        restSec: 180,
        prescription: ExercisePrescription(
          reps: 5,
          percent1RM: 90.0,
          rpe: 9,
        ),
        notes: '허리를 곧게 펴고 힙 힌지 동작',
      ),
    ];
  }

  /// 세션 초기화
  void _initializeSession() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      
      if (authProvider.user != null && _exercises.isNotEmpty) {
        final workoutProvider = context.read<WorkoutProvider>();
        workoutProvider.startNewSession(
          userId: authProvider.user!.uid,
          planId: widget.planId ?? 'demo_plan',
          exercises: _exercises,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 진행'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          Consumer<WorkoutProvider>(
            builder: (context, workoutProvider, child) {
              if (workoutProvider.currentSession?.status == SessionStatus.inProgress) {
                return TextButton(
                  onPressed: _completeWorkout,
                  child: const Text(
                    '운동 완료',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, child) {
          if (workoutProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (workoutProvider.currentSession == null) {
            return const Center(
              child: Text('세션을 시작하는 중...'),
            );
          }
          
          return _buildWorkoutContent();
        },
      ),
    );
  }

  Widget _buildWorkoutContent() {
    if (_currentExerciseIndex >= _exercises.length) {
      return _buildWorkoutComplete();
    }
    
    final currentExercise = _exercises[_currentExerciseIndex];
    final completedSetsForExercise = _completedSets[_currentExerciseIndex] ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 진행률 표시
          _buildProgressIndicator(),
          const SizedBox(height: 20),
          
          // 현재 운동 정보
          _buildCurrentExerciseCard(currentExercise),
          const SizedBox(height: 20),
          
          // 완료된 세트들
          if (completedSetsForExercise.isNotEmpty)
            _buildCompletedSets(completedSetsForExercise),
          
          // 현재 세트 입력
          _buildCurrentSetInput(currentExercise),
          const SizedBox(height: 20),
          
          // 세트 완료 버튼
          _buildCompleteSetButton(),
          const SizedBox(height: 10),
          
          // 다음 운동으로 넘어가기 버튼
          if (completedSetsForExercise.isNotEmpty)
            _buildNextExerciseButton(currentExercise),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = (_currentExerciseIndex + 1) / _exercises.length;
    
    return Column(
      children: [
        Text(
          '운동 ${_currentExerciseIndex + 1}/${_exercises.length}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
        ),
      ],
    );
  }

  Widget _buildCurrentExerciseCard(Exercise exercise) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '목표: ${exercise.targetSets}세트',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (exercise.prescription != null) ...[
              const SizedBox(height: 4),
              Text(
                _buildPrescriptionText(exercise.prescription!),
                style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500),
              ),
            ],
            if (exercise.notes != null) ...[
              const SizedBox(height: 4),
              Text(
                '노트: ${exercise.notes}',
                style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _buildPrescriptionText(ExercisePrescription prescription) {
    final parts = <String>[];
    
    if (prescription.reps != null) {
      parts.add('${prescription.reps}회');
    }
    if (prescription.percent1RM != null) {
      parts.add('${prescription.percent1RM}% 1RM');
    }
    if (prescription.rpe != null) {
      parts.add('RPE ${prescription.rpe}');
    }
    if (prescription.weight != null) {
      parts.add('${prescription.weight}kg');
    }
    
    return '권장: ${parts.join(', ')}';
  }

  Widget _buildCompletedSets(List<WorkoutLog> completedSets) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '완료된 세트',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...completedSets.asMap().entries.map((entry) {
              final setIndex = entry.key;
              final log = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: log.isPR ? Colors.amber : Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${setIndex + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${log.weight}kg × ${log.reps}회 @RPE${log.rpe}${log.isPR ? ' 🏆 PR!' : ''}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: log.isPR ? FontWeight.bold : FontWeight.normal,
                          color: log.isPR ? Colors.amber[700] : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSetInput(Exercise exercise) {
    final completedCount = _completedSets[_currentExerciseIndex]?.length ?? 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '세트 ${completedCount + 1}/${exercise.targetSets}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: '무게 (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '반복 횟수',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _rpeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'RPE (6-10)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: '메모 (선택사항)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteSetButton() {
    return ElevatedButton(
      onPressed: _canCompleteSet() ? _completeCurrentSet : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        '세트 완료',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNextExerciseButton(Exercise currentExercise) {
    final completedSets = _completedSets[_currentExerciseIndex]?.length ?? 0;
    final canProceed = completedSets >= currentExercise.targetSets;
    
    return ElevatedButton(
      onPressed: canProceed ? _nextExercise : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        _currentExerciseIndex == _exercises.length - 1 ? '운동 완료' : '다음 운동',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildWorkoutComplete() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          const Text(
            '운동 완료!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '모든 운동을 완료했습니다.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text(
              '메인으로 돌아가기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  bool _canCompleteSet() {
    return _weightController.text.isNotEmpty &&
           _repsController.text.isNotEmpty &&
           _rpeController.text.isNotEmpty;
  }

  Future<void> _completeCurrentSet() async {
    if (!_canCompleteSet()) return;
    
    final weight = double.tryParse(_weightController.text);
    final reps = int.tryParse(_repsController.text);
    final rpe = int.tryParse(_rpeController.text);
    
    if (weight == null || reps == null || rpe == null) {
      _showErrorDialog('올바른 숫자를 입력해주세요.');
      return;
    }
    
    if (rpe < 6 || rpe > 10) {
      _showErrorDialog('RPE는 6-10 사이의 값이어야 합니다.');
      return;
    }
    
    final workoutProvider = context.read<WorkoutProvider>();
    final exercise = _exercises[_currentExerciseIndex];
    
    final log = await workoutProvider.logSet(
      exerciseKey: exercise.key,
      setIndex: _currentSetIndex,
      weight: weight,
      reps: reps,
      rpe: rpe,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );
    
    if (log != null) {
      setState(() {
        if (!_completedSets.containsKey(_currentExerciseIndex)) {
          _completedSets[_currentExerciseIndex] = [];
        }
        _completedSets[_currentExerciseIndex]!.add(log);
        _currentSetIndex++;
        
        // 입력 필드 리셋 (RPE는 유지)
        _weightController.clear();
        _repsController.clear();
        _noteController.clear();
      });
      
      if (log.isPR) {
        _showPRDialog(exercise.name, log);
      }
    }
  }

  void _nextExercise() {
    setState(() {
      _currentExerciseIndex++;
      _currentSetIndex = 0;
    });
  }

  Future<void> _completeWorkout() async {
    final workoutProvider = context.read<WorkoutProvider>();
    await workoutProvider.completeCurrentSession();
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('입력 오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showPRDialog(String exerciseName, WorkoutLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 30),
            const SizedBox(width: 8),
            const Expanded(child: Text('개인 기록 달성!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              exerciseName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${log.weight}kg × ${log.reps}회'),
            Text('추정 1RM: ${log.estimated1RM?.toStringAsFixed(1)}kg'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('축하합니다!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _rpeController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}