import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/concept_provider.dart';
import '../../../core/database/models/concept.dart';
import '../../../core/theme/app_theme.dart';

/// 개념 편집/생성 화면
class ConceptEditScreen extends ConsumerStatefulWidget {
  final int? conceptId; // null이면 생성 모드

  const ConceptEditScreen({
    super.key,
    this.conceptId,
  });

  @override
  ConsumerState<ConceptEditScreen> createState() => _ConceptEditScreenState();
}

class _ConceptEditScreenState extends ConsumerState<ConceptEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _tagController = TextEditingController();
  
  List<String> _tags = [];
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.conceptId != null;
    if (_isEditMode) {
      _loadConcept();
    }
  }

  Future<void> _loadConcept() async {
    if (widget.conceptId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final concept = await ref
          .read(conceptsProvider.notifier)
          .getConceptById(widget.conceptId!);
      
      if (concept != null) {
        _titleController.text = concept.title;
        _bodyController.text = concept.body;
        _tags = List.from(concept.tags);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('개념을 불러오는데 실패했습니다: $e')),
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
    _titleController.dispose();
    _bodyController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_isEditMode ? '개념 편집' : '개념 추가'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteConcept,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 입력
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '개념 제목',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                hintText: '예: 심근경색의 정의',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '제목을 입력해주세요';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 내용 입력
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '개념 내용',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _bodyController,
                              decoration: const InputDecoration(
                                hintText: '개념에 대한 자세한 설명을 입력하세요...',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 8,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '내용을 입력해주세요';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 태그 입력
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
                            
                            // 태그 입력 필드
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
                                  child: const Text('추가'),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // 태그 목록
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
                                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                  labelStyle: const TextStyle(
                                    color: AppTheme.primaryColor,
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
                        onPressed: _saveConcept,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _isEditMode ? '수정 완료' : '개념 저장',
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

  Future<void> _saveConcept() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isEditMode && widget.conceptId != null) {
        // 수정 모드
        final concept = Concept()
          ..id = widget.conceptId!
          ..title = _titleController.text.trim()
          ..body = _bodyController.text.trim()
          ..tags = _tags
          ..updatedAt = DateTime.now();
        
        await ref.read(conceptsProvider.notifier).updateConcept(concept);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('개념이 수정되었습니다')),
          );
        }
      } else {
        // 생성 모드
        await ref.read(conceptsProvider.notifier).createConcept(
              _titleController.text.trim(),
              _bodyController.text.trim(),
              _tags,
            );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('개념이 저장되었습니다')),
          );
        }
      }

      if (mounted) {
        context.go('/concepts');
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

  Future<void> _deleteConcept() async {
    if (widget.conceptId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개념 삭제'),
        content: const Text('정말로 이 개념을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
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
        await ref.read(conceptsProvider.notifier).deleteConcept(widget.conceptId!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('개념이 삭제되었습니다')),
          );
          context.go('/concepts');
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