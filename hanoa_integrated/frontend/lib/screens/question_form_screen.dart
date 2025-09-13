import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../services/clintest_service.dart';
import '../services/auth_service.dart';

class QuestionFormScreen extends ConsumerStatefulWidget {
  final Question? question; // 수정 시 사용

  const QuestionFormScreen({super.key, this.question});

  @override
  ConsumerState<QuestionFormScreen> createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends ConsumerState<QuestionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clintestService = ClintestService();

  // 폼 컨트롤러들
  late final TextEditingController _questionController;
  late final List<TextEditingController> _choiceControllers;
  late final TextEditingController _explanationController;

  String _selectedCategory = ClintestService.categories.first;
  String _selectedDifficulty = 'medium';
  int _correctAnswer = 0;
  bool _isSubmitting = false;

  bool get isEditing => widget.question != null;

  @override
  void initState() {
    super.initState();

    // 컨트롤러 초기화
    _questionController = TextEditingController();
    _choiceControllers = List.generate(5, (index) => TextEditingController());
    _explanationController = TextEditingController();

    // 수정 모드인 경우 기존 데이터로 초기화
    if (isEditing) {
      final question = widget.question!;
      _questionController.text = question.questionText;
      for (int i = 0; i < 5; i++) {
        _choiceControllers[i].text = question.choices[i];
      }
      _explanationController.text = question.explanation;
      _selectedCategory = question.subject;
      _selectedDifficulty = question.difficulty;
      _correctAnswer = question.correctAnswer;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final controller in _choiceControllers) {
      controller.dispose();
    }
    _explanationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '문제 수정' : '새 문제 추가'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitForm,
            child: Text(
              isEditing ? '수정' : '저장',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 문제 텍스트
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '문제',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _questionController,
                        decoration: const InputDecoration(
                          hintText: '문제를 입력하세요...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '문제를 입력해주세요';
                          }
                          if (value.trim().length < 10) {
                            return '문제는 최소 10자 이상이어야 합니다';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 선택지들
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '선택지 (5지선다)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              // 정답 선택 라디오버튼
                              Radio<int>(
                                value: index,
                                groupValue: _correctAnswer,
                                onChanged: (value) {
                                  setState(() {
                                    _correctAnswer = value!;
                                  });
                                },
                                activeColor: Colors.green,
                              ),

                              // 선택지 번호
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _correctAnswer == index
                                      ? Colors.green
                                      : Colors.grey.shade300,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: _correctAnswer == index
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // 선택지 입력 필드
                              Expanded(
                                child: TextFormField(
                                  controller: _choiceControllers[index],
                                  decoration: InputDecoration(
                                    hintText: '${index + 1}번 선택지',
                                    border: const OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: _correctAnswer == index
                                            ? Colors.green
                                            : Colors.blue,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return '${index + 1}번 선택지를 입력해주세요';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // 정답 안내
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.green.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '현재 정답: ${_correctAnswer + 1}번\n'
                                '라디오버튼을 클릭하여 정답을 선택하세요.',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 카테고리 및 난이도
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '분류',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 카테고리 선택
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: '카테고리',
                          border: OutlineInputBorder(),
                        ),
                        items: ClintestService.categories
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      // 난이도 선택
                      DropdownButtonFormField<String>(
                        value: _selectedDifficulty,
                        decoration: const InputDecoration(
                          labelText: '난이도',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'easy', child: Text('쉬움')),
                          DropdownMenuItem(value: 'medium', child: Text('보통')),
                          DropdownMenuItem(value: 'hard', child: Text('어려움')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedDifficulty = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 해설 (선택사항)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '해설 (선택사항)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _explanationController,
                        decoration: const InputDecoration(
                          hintText: '정답에 대한 해설을 입력하세요...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(isEditing ? Icons.edit : Icons.save),
                  label: Text(
                    _isSubmitting
                        ? (isEditing ? '수정 중...' : '저장 중...')
                        : (isEditing ? '문제 수정' : '문제 저장'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = AuthService().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인이 필요합니다'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final question = Question(
        id: isEditing ? widget.question!.id : '',
        questionText: _questionController.text.trim(),
        choices: _choiceControllers.map((c) => c.text.trim()).toList(),
        correctAnswer: _correctAnswer,
        subject: _selectedCategory,
        difficulty: _selectedDifficulty,
        explanation: _explanationController.text.trim(),
        createdBy: user.displayName ?? user.email ?? 'Unknown',
        createdAt: isEditing ? widget.question!.createdAt : DateTime.now(),
        updatedAt: isEditing ? DateTime.now() : null,
      );

      bool success;
      if (isEditing) {
        success = await _clintestService.updateQuestion(widget.question!.id, question);
      } else {
        final questionId = await _clintestService.addQuestion(question);
        success = questionId != null;
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? '문제가 수정되었습니다' : '문제가 저장되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          // 에러는 서비스에서 처리됨
          final error = _clintestService.error ?? '알 수 없는 오류가 발생했습니다';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}