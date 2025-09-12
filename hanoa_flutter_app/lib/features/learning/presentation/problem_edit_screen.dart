import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/problem_provider.dart';
import '../../../core/database/models/problem.dart';
import '../../../core/theme/app_theme.dart';

/// 문제 편집/생성 화면
class ProblemEditScreen extends ConsumerStatefulWidget {
  final int? problemId; // null이면 생성 모드

  const ProblemEditScreen({
    super.key,
    this.problemId,
  });

  @override
  ConsumerState<ProblemEditScreen> createState() => _ProblemEditScreenState();
}

class _ProblemEditScreenState extends ConsumerState<ProblemEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stemController = TextEditingController();
  final _tagController = TextEditingController();
  
  List<TextEditingController> _choiceControllers = [];
  List<String> _tags = [];
  int _selectedAnswerIndex = 0;
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.problemId != null;
    _initializeChoices();
    
    if (_isEditMode) {
      _loadProblem();
    }
  }

  void _initializeChoices() {
    // 기본 4개 선택지
    for (int i = 0; i < 4; i++) {
      _choiceControllers.add(TextEditingController());
    }
  }

  Future<void> _loadProblem() async {
    if (widget.problemId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final problem = await ref
          .read(problemsProvider.notifier)
          .getProblemById(widget.problemId!);
      
      if (problem != null) {
        _stemController.text = problem.stem;
        _selectedAnswerIndex = problem.answerIndex;
        _tags = List.from(problem.tags);
        
        // 기존 컨트롤러 정리
        for (var controller in _choiceControllers) {
          controller.dispose();
        }
        _choiceControllers.clear();
        
        // 선택지 컨트롤러 재생성
        for (int i = 0; i < problem.choices.length; i++) {
          final controller = TextEditingController(text: problem.choices[i]);
          _choiceControllers.add(controller);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('문제를 불러오는데 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _stemController.dispose();
    _tagController.dispose();
    for (var controller in _choiceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_isEditMode ? '문제 편집' : '문제 추가'),
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteProblem,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 문제 문항 입력
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '문제 문항',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _stemController,
                              decoration: const InputDecoration(
                                hintText: '문제를 입력하세요...',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 5,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '문제 문항을 입력해주세요';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 선택지 입력
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '선택지',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimaryColor,
                                  ),
                                ),
                                if (_choiceControllers.length < 6)
                                  TextButton.icon(
                                    onPressed: _addChoice,
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('선택지 추가'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // 선택지 목록
                            ...List.generate(
                              _choiceControllers.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    // 정답 선택 라디오 버튼
                                    Radio<int>(
                                      value: index,
                                      groupValue: _selectedAnswerIndex,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedAnswerIndex = value!;
                                        });
                                      },
                                      activeColor: AppTheme.successColor,
                                    ),
                                    
                                    // 선택지 번호
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: _selectedAnswerIndex == index
                                            ? AppTheme.successColor
                                            : AppTheme.textSecondaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
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
                                          isDense: true,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return '선택지를 입력해주세요';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    
                                    // 선택지 삭제 버튼
                                    if (_choiceControllers.length > 2)
                                      IconButton(
                                        onPressed: () => _removeChoice(index),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppTheme.errorColor,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // 정답 안내
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: AppTheme.successColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '정답: ${_selectedAnswerIndex + 1}번',
                                    style: const TextStyle(
                                      color: AppTheme.successColor,
                                      fontWeight: FontWeight.w500,
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
                    
                    // 태그 입력 (개념과 동일)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '태그',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _tagController,
                                    decoration: const InputDecoration(
                                      hintText: '태그 입력 후 추가 버튼 클릭',
                                      border: OutlineInputBorder(),
                                    ),
                                    onSubmitted: (_) => _addTag(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _addTag,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentColor,
                                  ),
                                  child: const Text('추가'),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            if (_tags.isNotEmpty) ...[
                              const Text(
                                '추가된 태그:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _tags.map((tag) => Chip(
                                  label: Text(tag),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () => _removeTag(tag),
                                  backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                                  labelStyle: const TextStyle(
                                    color: AppTheme.accentColor,
                                  ),
                                )).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProblem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _isEditMode ? '수정 완료' : '문제 저장',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  void _addChoice() {
    if (_choiceControllers.length < 6) {
      setState(() {
        _choiceControllers.add(TextEditingController());
      });
    }
  }

  void _removeChoice(int index) {
    if (_choiceControllers.length > 2) {
      setState(() {
        _choiceControllers[index].dispose();
        _choiceControllers.removeAt(index);
        
        // 정답 인덱스 조정
        if (_selectedAnswerIndex >= index && _selectedAnswerIndex > 0) {
          _selectedAnswerIndex--;
        }
        if (_selectedAnswerIndex >= _choiceControllers.length) {
          _selectedAnswerIndex = _choiceControllers.length - 1;
        }
      });
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveProblem() async {
    if (!_formKey.currentState!.validate()) return;
    
    // 선택지가 최소 2개 이상인지 확인
    if (_choiceControllers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택지는 최소 2개 이상이어야 합니다')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final choices = _choiceControllers
          .map((controller) => controller.text.trim())
          .toList();

      if (_isEditMode && widget.problemId != null) {
        // 수정 모드
        final problem = Problem()
          ..id = widget.problemId!
          ..stem = _stemController.text.trim()
          ..choices = choices
          ..answerIndex = _selectedAnswerIndex
          ..tags = _tags
          ..updatedAt = DateTime.now();
        
        await ref.read(problemsProvider.notifier).updateProblem(problem);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('문제가 수정되었습니다')),
          );
        }
      } else {
        // 생성 모드
        await ref.read(problemsProvider.notifier).createProblem(
              _stemController.text.trim(),
              choices,
              _selectedAnswerIndex,
              _tags,
            );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('문제가 저장되었습니다')),
          );
        }
      }

      if (mounted) {
        context.go('/problems');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteProblem() async {
    if (widget.problemId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('문제 삭제'),
        content: const Text('정말로 이 문제를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        await ref.read(problemsProvider.notifier).deleteProblem(widget.problemId!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('문제가 삭제되었습니다')),
          );
          context.go('/problems');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제에 실패했습니다: $e')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }
}