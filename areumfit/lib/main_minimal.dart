import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const AreumFitMinimalApp());
}

class AreumFitMinimalApp extends StatelessWidget {
  const AreumFitMinimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AreumFit Minimal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2AB1A2), // Primary Teal
          secondary: const Color(0xFFFF6F61), // Accent Coral
        ),
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isHealthMode = true; // true: Health, false: CrossFit

  final List<Widget> _screens = [
    const RecommendationScreen(),
    const WorkoutScreen(),
    const CalendarScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'AreumFit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('헬스'),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('크로스핏'),
                ),
              ],
              selected: {_isHealthMode},
              onSelectionChanged: (selected) {
                setState(() {
                  _isHealthMode = selected.first;
                });
              },
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: '운동',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat),
            label: '대화',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}

// Recommendation Screen with muscle group toggles
class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final Map<String, bool> _muscleGroups = {
    '가슴': true,
    '등': true,
    '어깨': false,
    '팔': false,
    '복근': true,
    '다리': true,
  };

  bool _isAiMode = false;
  bool _isAiLoading = false;
  String _aiRecommendation = '';
  List<String> _aiSelectedMuscleGroups = [];

  final List<Map<String, dynamic>> _recommendations = [
    {
      'name': '인클라인 바벨 벤치프레스',
      'weight': 82.5,
      'reps': 7,
      'rest': 150,
      'rpe': 8.0,
      'reasons': ['볼륨', '성공률'],
      'muscleGroup': '가슴'
    },
    {
      'name': '데드리프트',
      'weight': 120.0,
      'reps': 5,
      'rest': 180,
      'rpe': 8.5,
      'reasons': ['볼륨', '성공률'],
      'muscleGroup': '등'
    },
    {
      'name': '스쿼트',
      'weight': 100.0,
      'reps': 8,
      'rest': 160,
      'rpe': 7.5,
      'reasons': ['볼륨'],
      'muscleGroup': '다리'
    },
  ];

  Future<void> _askAiCoach() async {
    setState(() {
      _isAiLoading = true;
      _aiRecommendation = '';
    });

    // Simulate AI call - replace with actual GPT-5 API call
    await Future.delayed(const Duration(seconds: 2));
    
    final aiResponse = {
      'recommendation': '오늘은 상체 위주로 운동하세요! 최근 하체 볼륨이 높아서 상체에 집중하는 것이 좋겠습니다.',
      'selectedMuscleGroups': ['가슴', '등', '어깨'],
      'reasoning': '지난주 스쿼트와 데드리프트를 많이 하셨고, 가슴과 등 근육이 충분히 회복되었습니다.',
    };

    setState(() {
      _isAiMode = true;
      _isAiLoading = false;
      _aiRecommendation = aiResponse['recommendation'] as String;
      _aiSelectedMuscleGroups = (aiResponse['selectedMuscleGroups'] as List)
          .map((e) => e.toString())
          .toList();
      
      // Reset manual selection and apply AI selection
      for (var key in _muscleGroups.keys) {
        _muscleGroups[key] = _aiSelectedMuscleGroups.contains(key);
      }
    });
  }

  void _exitAiMode() {
    setState(() {
      _isAiMode = false;
      _aiRecommendation = '';
      _aiSelectedMuscleGroups = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeRecommendations = _recommendations
        .where((rec) => _muscleGroups[rec['muscleGroup']] == true)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Coach Card
          if (_isAiMode)
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'AI 코치 추천',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _exitAiMode,
                          child: const Text('수동 선택'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _aiRecommendation,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 4,
                      children: _aiSelectedMuscleGroups.map((group) => Chip(
                        label: Text(group),
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      )).toList(),
                    ),
                  ],
                ),
              ),
            )
          else
            // Muscle Group Toggles / AI Button
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '운동 계획',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _isAiLoading ? null : _askAiCoach,
                          icon: _isAiLoading 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.psychology),
                          label: Text(_isAiLoading ? '분석중...' : 'AI 코치에게 물어보기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('근육군 선택', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _muscleGroups.entries.map((entry) {
                        return FilterChip(
                          label: Text(entry.key),
                          selected: entry.value,
                          onSelected: (selected) {
                            setState(() {
                              _muscleGroups[entry.key] = selected;
                            });
                          },
                          selectedColor: Theme.of(context).colorScheme.primaryContainer,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          
          // Recommendations Header
          Row(
            children: [
              const Text(
                '오늘의 추천 운동',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${activeRecommendations.length}개 추천',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Recommendation Cards
          Expanded(
            child: activeRecommendations.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('선택된 근육군에 대한 추천이 없습니다'),
                        SizedBox(height: 8),
                        Text('근육군을 선택해주세요'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: activeRecommendations.length,
                    itemBuilder: (context, index) {
                      final rec = activeRecommendations[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      rec['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      rec['muscleGroup'],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              Row(
                                children: [
                                  _buildInfoChip('${rec['weight']}kg', Icons.fitness_center),
                                  const SizedBox(width: 8),
                                  _buildInfoChip('${rec['reps']}회', Icons.repeat),
                                  const SizedBox(width: 8),
                                  _buildInfoChip('${rec['rest']}초', Icons.timer),
                                  const SizedBox(width: 8),
                                  _buildInfoChip('RPE ${rec['rpe']}', Icons.speed),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              Row(
                                children: [
                                  const Text('이유: '),
                                  ...rec['reasons'].map<Widget>((reason) => Container(
                                    margin: const EdgeInsets.only(right: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: reason == '볼륨' 
                                          ? Colors.blue.withValues(alpha: 0.2)
                                          : Colors.green.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      reason,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  )).toList(),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Navigate to workout screen
                                    },
                                    child: const Text('시작하기'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// Workout Recording Screen
class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final List<ExerciseSet> _currentSets = [];
  String _currentExercise = '벤치프레스';
  bool _isRestTimer = false;
  int _restSeconds = 0;
  Timer? _timer;
  
  final List<String> _exercises = [
    '벤치프레스', '스쿼트', '데드리프트', '오버헤드프레스',
    '바벨로우', '인클라인벤치프레스', '딥스', '풀업'
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _addSet() {
    showDialog(
      context: context,
      builder: (context) => _SetInputDialog(
        onSave: (weight, reps, rpe) {
          setState(() {
            _currentSets.add(ExerciseSet(
              exercise: _currentExercise,
              weight: weight,
              reps: reps,
              rpe: rpe,
              completedAt: DateTime.now(),
            ));
          });
          _startRestTimer();
        },
      ),
    );
  }

  void _startRestTimer() {
    setState(() {
      _isRestTimer = true;
      _restSeconds = 90; // 기본 90초
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_restSeconds > 0) {
          _restSeconds--;
        } else {
          _isRestTimer = false;
          timer.cancel();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRestTimer = false;
      _restSeconds = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('현재 운동', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _currentExercise,
                    isExpanded: true,
                    items: _exercises.map((exercise) => DropdownMenuItem(
                      value: exercise,
                      child: Text(exercise),
                    )).toList(),
                    onChanged: (value) => setState(() => _currentExercise = value!),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Rest Timer
          if (_isRestTimer)
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.timer, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('휴식 시간', style: TextStyle(fontSize: 16)),
                          Text('${_restSeconds}초', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _stopTimer,
                      child: const Text('완료'),
                    ),
                  ],
                ),
              ),
            ),
          
          if (_isRestTimer) const SizedBox(height: 16),
          
          // Add Set Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isRestTimer ? null : _addSet,
              icon: const Icon(Icons.add),
              label: Text(_isRestTimer ? '휴식 중...' : '세트 추가'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Sets History
          const Text('오늘의 기록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          
          Expanded(
            child: _currentSets.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('아직 기록이 없습니다'),
                        Text('첫 세트를 추가해보세요!'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _currentSets.length,
                    itemBuilder: (context, index) {
                      final set = _currentSets[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: Text(set.exercise),
                          subtitle: Text('${set.weight}kg × ${set.reps}회'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getRpeColor(set.rpe),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('RPE ${set.rpe}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                          onLongPress: () {
                            setState(() {
                              _currentSets.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getRpeColor(int rpe) {
    if (rpe <= 6) return Colors.green;
    if (rpe <= 8) return Colors.orange;
    return Colors.red;
  }
}

class ExerciseSet {
  final String exercise;
  final double weight;
  final int reps;
  final int rpe;
  final DateTime completedAt;

  ExerciseSet({
    required this.exercise,
    required this.weight,
    required this.reps,
    required this.rpe,
    required this.completedAt,
  });
}

class _SetInputDialog extends StatefulWidget {
  final Function(double weight, int reps, int rpe) onSave;

  const _SetInputDialog({required this.onSave});

  @override
  State<_SetInputDialog> createState() => _SetInputDialogState();
}

class _SetInputDialogState extends State<_SetInputDialog> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  int _rpe = 7;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('세트 기록'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '중량 (kg)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _repsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '횟수',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('RPE: '),
              Expanded(
                child: Slider(
                  value: _rpe.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _rpe.toString(),
                  onChanged: (value) => setState(() => _rpe = value.round()),
                ),
              ),
              Text(_rpe.toString()),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            final weight = double.tryParse(_weightController.text) ?? 0;
            final reps = int.tryParse(_repsController.text) ?? 0;
            
            if (weight > 0 && reps > 0) {
              widget.onSave(weight, reps, _rpe);
              Navigator.of(context).pop();
            }
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}

// Placeholder screens
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64),
          SizedBox(height: 16),
          Text('운동 캘린더', style: TextStyle(fontSize: 24)),
          SizedBox(height: 8),
          Text('운동 기록을 달력으로 확인하세요'),
        ],
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat, size: 64),
          SizedBox(height: 16),
          Text('AI 코치', style: TextStyle(fontSize: 24)),
          SizedBox(height: 8),
          Text('AI와 대화하여 운동을 개선하세요'),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64),
          SizedBox(height: 16),
          Text('프로필', style: TextStyle(fontSize: 24)),
          SizedBox(height: 8),
          Text('사용자 정보와 설정을 관리하세요'),
        ],
      ),
    );
  }
}
