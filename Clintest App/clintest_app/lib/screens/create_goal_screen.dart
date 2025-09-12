import 'package:flutter/material.dart';
import '../models/learning_goal.dart';
import '../services/learning_goal_service.dart';
import '../services/auth_service.dart';

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetValueController = TextEditingController();
  
  GoalType _selectedType = GoalType.accuracy;
  GoalPriority _selectedPriority = GoalPriority.medium;
  GoalDifficulty _selectedDifficulty = GoalDifficulty.intermediate;
  String _selectedCategory = 'overall';
  String _selectedUnit = 'percentage';
  DateTime? _targetDate;
  
  bool _isLoading = false;
  
  final Map<GoalType, List<String>> _unitsByType = {
    GoalType.accuracy: ['percentage'],
    GoalType.volume: ['questions', 'problems'],
    GoalType.consistency: ['days', 'weeks'],
    GoalType.mastery: ['percentage', 'level'],
    GoalType.speed: ['seconds', 'minutes'],
    GoalType.comprehensive: ['percentage', 'score'],
  };
  
  final List<String> _categories = [
    'overall',
    'nursing_fundamentals',
    'medical_surgical',
    'critical_care',
    'emergency_care',
    'pharmacology',
    'anatomy_physiology',
    'nursing_ethics',
    'mental_health',
    'pediatric_nursing',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 학습 목표'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveGoal,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildGoalTypeSection(),
            const SizedBox(height: 24),
            _buildTargetSection(),
            const SizedBox(height: 24),
            _buildSettingsSection(),
            const SizedBox(height: 24),
            _buildAdvancedSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '기본 정보',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: '목표 제목',
            hintText: '예: NCLEX 정확도 90% 달성',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '목표 제목을 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: '목표 설명 (선택)',
            hintText: '목표에 대한 상세한 설명을 입력해주세요',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildGoalTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '목표 유형',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GoalType.values.map((type) {
            return ChoiceChip(
              label: Text(_getGoalTypeText(type)),
              selected: _selectedType == type,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedType = type;
                    _selectedUnit = _unitsByType[type]!.first;
                  });
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          _getGoalTypeDescription(_selectedType),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTargetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '목표 설정',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _targetValueController,
                decoration: const InputDecoration(
                  labelText: '목표 수치',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '목표 수치를 입력해주세요';
                  }
                  final numValue = int.tryParse(value);
                  if (numValue == null || numValue <= 0) {
                    return '올바른 숫자를 입력해주세요';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedUnit,
                decoration: const InputDecoration(
                  labelText: '단위',
                  border: OutlineInputBorder(),
                ),
                items: _unitsByType[_selectedType]!.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(_getUnitText(unit)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedUnit = value);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: const InputDecoration(
            labelText: '학습 영역',
            border: OutlineInputBorder(),
          ),
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(_getCategoryText(category)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCategory = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '목표 설정',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<GoalPriority>(
          initialValue: _selectedPriority,
          decoration: const InputDecoration(
            labelText: '우선순위',
            border: OutlineInputBorder(),
          ),
          items: GoalPriority.values.map((priority) {
            return DropdownMenuItem(
              value: priority,
              child: Text(_getPriorityText(priority)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedPriority = value);
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<GoalDifficulty>(
          initialValue: _selectedDifficulty,
          decoration: const InputDecoration(
            labelText: '난이도',
            border: OutlineInputBorder(),
          ),
          items: GoalDifficulty.values.map((difficulty) {
            return DropdownMenuItem(
              value: difficulty,
              child: Text(_getDifficultyText(difficulty)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedDifficulty = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildAdvancedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '고급 설정',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('목표 달성 기한'),
          subtitle: _targetDate != null
              ? Text('${_targetDate!.year}년 ${_targetDate!.month}월 ${_targetDate!.day}일')
              : const Text('기한 없음'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_targetDate != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() => _targetDate = null);
                  },
                ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _selectTargetDate,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectTargetDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() => _targetDate = date);
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final userId = AuthService.instance.currentUser?.uid ?? 'user1';
      final targetValue = int.parse(_targetValueController.text);
      
      await LearningGoalService.createGoal(
        userId: userId,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        category: _selectedCategory,
        type: _selectedType,
        targetValue: targetValue,
        targetUnit: _selectedUnit,
        targetDate: _targetDate,
        priority: _selectedPriority,
        difficulty: _selectedDifficulty,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('목표가 성공적으로 생성되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('목표 생성 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
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

  String _getGoalTypeDescription(GoalType type) {
    switch (type) {
      case GoalType.accuracy:
        return '문제 풀이 정확도를 향상시키는 목표';
      case GoalType.volume:
        return '푼 문제 수량을 늘리는 목표';
      case GoalType.consistency:
        return '꾸준한 학습 습관을 형성하는 목표';
      case GoalType.mastery:
        return '특정 주제의 숙련도를 높이는 목표';
      case GoalType.speed:
        return '문제 풀이 속도를 개선하는 목표';
      case GoalType.comprehensive:
        return '전반적인 실력 향상을 목표로 하는 종합적인 목표';
    }
  }

  String _getUnitText(String unit) {
    switch (unit) {
      case 'percentage':
        return '%';
      case 'questions':
        return '문제';
      case 'problems':
        return '문항';
      case 'days':
        return '일';
      case 'weeks':
        return '주';
      case 'level':
        return '레벨';
      case 'seconds':
        return '초';
      case 'minutes':
        return '분';
      case 'score':
        return '점';
      default:
        return unit;
    }
  }

  String _getCategoryText(String category) {
    switch (category) {
      case 'overall':
        return '전체';
      case 'nursing_fundamentals':
        return '간호학 개론';
      case 'medical_surgical':
        return '성인간호학';
      case 'critical_care':
        return '중환자실 간호';
      case 'emergency_care':
        return '응급간호';
      case 'pharmacology':
        return '약리학';
      case 'anatomy_physiology':
        return '해부생리학';
      case 'nursing_ethics':
        return '간호윤리';
      case 'mental_health':
        return '정신건강간호';
      case 'pediatric_nursing':
        return '아동간호학';
      default:
        return category;
    }
  }

  String _getPriorityText(GoalPriority priority) {
    switch (priority) {
      case GoalPriority.low:
        return '낮음';
      case GoalPriority.medium:
        return '보통';
      case GoalPriority.high:
        return '높음';
      case GoalPriority.critical:
        return '긴급';
    }
  }

  String _getDifficultyText(GoalDifficulty difficulty) {
    switch (difficulty) {
      case GoalDifficulty.beginner:
        return '초급';
      case GoalDifficulty.intermediate:
        return '중급';
      case GoalDifficulty.advanced:
        return '고급';
      case GoalDifficulty.expert:
        return '전문가';
    }
  }
}