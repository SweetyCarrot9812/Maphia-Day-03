import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProblemCreationScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const ProblemCreationScreen({
    super.key,
    this.initialCategory,
  });

  @override
  ConsumerState<ProblemCreationScreen> createState() => _ProblemCreationScreenState();
}

class _ProblemCreationScreenState extends ConsumerState<ProblemCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _explanationController = TextEditingController();

  String _selectedCategory = 'Clintest';
  String _selectedDifficulty = '중급';
  String _selectedType = '객관식';
  List<String> _options = ['', '', '', ''];
  int _correctAnswerIndex = 0;

  final List<String> _categories = ['Clintest', 'Lingumo', 'AreumFit', 'HaneulTone'];
  final List<String> _difficulties = ['초급', '중급', '고급'];
  final List<String> _types = ['객관식', '주관식', '서술형'];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && _categories.contains(widget.initialCategory)) {
      _selectedCategory = widget.initialCategory!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildCategoryAndSettings(),
                const SizedBox(height: 24),
                _buildProblemContent(),
                const SizedBox(height: 24),
                if (_selectedType == '객관식') _buildMultipleChoiceOptions(),
                if (_selectedType == '객관식') const SizedBox(height: 24),
                _buildExplanation(),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add_circle,
                color: Colors.teal.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '문제 생성',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '새로운 학습 문제를 생성합니다',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryAndSettings() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '기본 설정',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: '카테고리',
                    value: _selectedCategory,
                    items: _categories,
                    onChanged: (value) => setState(() => _selectedCategory = value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    label: '난이도',
                    value: _selectedDifficulty,
                    items: _difficulties,
                    onChanged: (value) => setState(() => _selectedDifficulty = value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    label: '유형',
                    value: _selectedType,
                    items: _types,
                    onChanged: (value) => setState(() => _selectedType = value!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemContent() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '문제 내용',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '문제 제목',
                hintText: '문제 제목을 입력하세요',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '문제 제목을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '문제 내용',
                hintText: '문제 내용을 입력하세요',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '문제 내용을 입력해주세요';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleChoiceOptions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '객관식 선택지',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Radio<int>(
                      value: index,
                      groupValue: _correctAnswerIndex,
                      onChanged: (value) => setState(() => _correctAnswerIndex = value!),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: _options[index],
                        decoration: InputDecoration(
                          labelText: '선택지 ${index + 1}',
                          hintText: '선택지를 입력하세요',
                          border: const OutlineInputBorder(),
                          suffixIcon: _correctAnswerIndex == index
                            ? Icon(Icons.check_circle, color: Colors.green.shade600)
                            : null,
                        ),
                        onChanged: (value) => _options[index] = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '선택지를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Text(
              '정답을 선택하려면 해당 선택지의 라디오 버튼을 클릭하세요',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '정답 해설',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _explanationController,
              decoration: const InputDecoration(
                labelText: '해설',
                hintText: '정답에 대한 설명을 입력하세요',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '해설을 입력해주세요';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => _resetForm(),
          child: const Text('초기화'),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () => _saveAsDraft(),
          child: const Text('임시저장'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => _createProblem(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade600,
            foregroundColor: Colors.white,
          ),
          child: const Text('문제 생성'),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _contentController.clear();
    _explanationController.clear();
    setState(() {
      _selectedCategory = 'Clintest';
      _selectedDifficulty = '중급';
      _selectedType = '객관식';
      _options = ['', '', '', ''];
      _correctAnswerIndex = 0;
    });
  }

  void _saveAsDraft() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('문제가 임시저장되었습니다'),
          backgroundColor: Colors.orange.shade600,
        ),
      );
    }
  }

  void _createProblem() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement actual problem creation logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('문제가 성공적으로 생성되었습니다'),
          backgroundColor: Colors.green.shade600,
        ),
      );

      // Reset form after successful creation
      _resetForm();
    }
  }
}