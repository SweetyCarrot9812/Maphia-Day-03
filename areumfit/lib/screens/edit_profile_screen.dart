import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../models/base_model.dart';
import '../providers/app_providers.dart';
import '../utils/responsive_utils.dart';

/// 사용자 프로필 편집 화면
class EditProfileScreen extends StatefulWidget {
  final UserProfile? profile; // null이면 새 프로필 생성

  const EditProfileScreen({super.key, this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _rpeMinController;
  late TextEditingController _rpeMaxController;

  Sex _selectedSex = Sex.male;
  WeightUnit _selectedUnit = WeightUnit.kg;
  List<String> _selectedInjuries = [];
  List<String> _selectedDays = [];
  List<String> _selectedEquipment = [];

  // 사전 정의된 옵션들
  final List<String> _injuryOptions = [
    '무릎', '허리', '어깨', '목', '발목', '손목', '팔꿈치', '고관절', '없음',
  ];

  final List<String> _dayOptions = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  final Map<String, String> _dayDisplayMap = {
    'Monday': '월요일',
    'Tuesday': '화요일', 
    'Wednesday': '수요일',
    'Thursday': '목요일',
    'Friday': '금요일',
    'Saturday': '토요일',
    'Sunday': '일요일',
  };

  final List<String> _equipmentOptions = [
    '바벨', '덤벨', '케틀벨', '저항밴드', '풀업바', '디핑바', '벤치', '스쿼트랙', '없음',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final profile = widget.profile;
    
    _nameController = TextEditingController(text: profile?.name ?? '');
    _heightController = TextEditingController(
      text: profile?.heightCm.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: profile?.weightKg.toString() ?? '',
    );
    _rpeMinController = TextEditingController(
      text: (profile?.rpeMin ?? 6).toString(),
    );
    _rpeMaxController = TextEditingController(
      text: (profile?.rpeMax ?? 9).toString(),
    );

    if (profile != null) {
      _selectedSex = profile.sex;
      _selectedUnit = profile.unit;
      _selectedInjuries = List.from(profile.injuries);
      _selectedDays = List.from(profile.preferredDays);
      _selectedEquipment = List.from(profile.equipment);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _rpeMinController.dispose();
    _rpeMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.profile != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '프로필 수정' : '프로필 생성'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('저장'),
          ),
        ],
      ),
      body: ResponsiveBuilder(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        foldableExpanded: _buildTabletLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: ResponsiveUtils.getAdaptivePadding(context),
        children: [
          _buildBasicInfoSection(),
          const SizedBox(height: 16),
          _buildPhysicalInfoSection(),
          const SizedBox(height: 16),
          _buildPreferencesSection(),
          const SizedBox(height: 16),
          _buildRPESection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          // Left panel - Basic and physical info
          Expanded(
            flex: 1,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBasicInfoSection(),
                const SizedBox(height: 16),
                _buildPhysicalInfoSection(),
                const SizedBox(height: 16),
                _buildRPESection(),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Right panel - Preferences
          Expanded(
            flex: 1,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPreferencesSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: '기본 정보',
      icon: Icons.person,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '이름',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '이름을 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<Sex>(
          value: _selectedSex,
          decoration: const InputDecoration(
            labelText: '성별',
            prefixIcon: Icon(Icons.wc),
          ),
          items: Sex.values.map((sex) => DropdownMenuItem(
            value: sex,
            child: Text(_getSexDisplay(sex)),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedSex = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPhysicalInfoSection() {
    return _buildSection(
      title: '신체 정보',
      icon: Icons.accessibility,
      children: [
        TextFormField(
          controller: _heightController,
          decoration: const InputDecoration(
            labelText: '키 (cm)',
            prefixIcon: Icon(Icons.height),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '키를 입력해주세요';
            }
            final height = int.tryParse(value);
            if (height == null || height < 100 || height > 250) {
              return '올바른 키를 입력해주세요 (100-250cm)';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: '체중',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '체중을 입력해주세요';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight < 30 || weight > 300) {
                    return '올바른 체중을 입력해주세요';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<WeightUnit>(
                value: _selectedUnit,
                decoration: const InputDecoration(
                  labelText: '단위',
                ),
                items: WeightUnit.values.map((unit) => DropdownMenuItem(
                  value: unit,
                  child: Text(_getWeightUnitDisplay(unit)),
                )).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedUnit = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSection(
      title: '운동 선호도',
      icon: Icons.fitness_center,
      children: [
        const Text('부상 이력', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildChipSelection(
          options: _injuryOptions,
          selected: _selectedInjuries,
          onChanged: (value) {
            setState(() {
              _selectedInjuries = value;
            });
          },
        ),
        const SizedBox(height: 16),
        const Text('선호 운동 요일', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildChipSelection(
          options: _dayOptions,
          selected: _selectedDays,
          onChanged: (value) {
            setState(() {
              _selectedDays = value;
            });
          },
          displayMap: _dayDisplayMap,
        ),
        const SizedBox(height: 16),
        const Text('보유 장비', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildChipSelection(
          options: _equipmentOptions,
          selected: _selectedEquipment,
          onChanged: (value) {
            setState(() {
              _selectedEquipment = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRPESection() {
    return _buildSection(
      title: 'RPE 선호 범위',
      icon: Icons.speed,
      children: [
        Text(
          'RPE (Rate of Perceived Exertion)는 주관적 운동 강도를 나타냅니다.\n'
          '1-10 범위에서 선호하는 운동 강도를 설정해주세요.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _rpeMinController,
                decoration: const InputDecoration(
                  labelText: '최소 RPE',
                  prefixIcon: Icon(Icons.remove),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '최소 RPE를 입력해주세요';
                  }
                  final rpe = int.tryParse(value);
                  if (rpe == null || rpe < 1 || rpe > 10) {
                    return '1-10 범위로 입력해주세요';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _rpeMaxController,
                decoration: const InputDecoration(
                  labelText: '최대 RPE',
                  prefixIcon: Icon(Icons.add),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '최대 RPE를 입력해주세요';
                  }
                  final rpe = int.tryParse(value);
                  if (rpe == null || rpe < 1 || rpe > 10) {
                    return '1-10 범위로 입력해주세요';
                  }
                  final minRpe = int.tryParse(_rpeMinController.text) ?? 1;
                  if (rpe <= minRpe) {
                    return '최소 RPE보다 커야 합니다';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildChipSelection({
    required List<String> options,
    required List<String> selected,
    required ValueChanged<List<String>> onChanged,
    Map<String, String>? displayMap,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        final displayText = displayMap?[option] ?? option;

        return FilterChip(
          label: Text(displayText),
          selected: isSelected,
          onSelected: (isSelected) {
            final newSelected = List<String>.from(selected);
            if (isSelected) {
              newSelected.add(option);
            } else {
              newSelected.remove(option);
            }
            onChanged(newSelected);
          },
        );
      }).toList(),
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

  String _getWeightUnitDisplay(WeightUnit unit) {
    switch (unit) {
      case WeightUnit.kg:
        return 'kg';
      case WeightUnit.lbs:
        return 'lbs';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final now = DateTime.now();
      final profile = UserProfile(
        id: widget.profile?.id ?? 'profile-${now.millisecondsSinceEpoch}',
        userId: widget.profile?.userId ?? 'user-1', // TODO: 실제 사용자 ID 사용
        createdAt: widget.profile?.createdAt ?? now,
        updatedAt: now,
        deviceId: widget.profile?.deviceId ?? 'device-1', // TODO: 실제 기기 ID 사용
        conflicted: false,
        name: _nameController.text.trim(),
        sex: _selectedSex,
        heightCm: int.parse(_heightController.text),
        weightKg: double.parse(_weightController.text),
        unit: _selectedUnit,
        injuries: _selectedInjuries,
        preferredDays: _selectedDays,
        equipment: _selectedEquipment,
        rpeMin: int.parse(_rpeMinController.text),
        rpeMax: int.parse(_rpeMaxController.text),
      );

      await context.read<UserProvider>().saveProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.profile != null ? '프로필이 수정되었습니다' : '프로필이 생성되었습니다'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }
}