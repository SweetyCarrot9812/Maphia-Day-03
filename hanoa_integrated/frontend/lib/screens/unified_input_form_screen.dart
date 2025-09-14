import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../models/concept.dart';
import '../services/clintest_service.dart';
import '../services/auth_service.dart';
import '../services/obsidian_web_service.dart';
import '../widgets/image_attachment_widget.dart';

class UnifiedInputFormScreen extends ConsumerStatefulWidget {
  final Question? question; // 수정 시 사용
  final int initialTabIndex; // 0: 문제, 1: 개념

  const UnifiedInputFormScreen({
    super.key,
    this.question,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<UnifiedInputFormScreen> createState() => _UnifiedInputFormScreenState();
}

class _UnifiedInputFormScreenState extends ConsumerState<UnifiedInputFormScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // 공통 변수들
  bool _isSubmitting = false;
  bool _isSavingToObsidian = false;

  // 문제 관련 변수들
  final _questionFormKey = GlobalKey<FormState>();
  final _clintestService = ClintestService();
  late final TextEditingController _questionController;
  late final List<TextEditingController> _choiceControllers;
  String _selectedCategory = ClintestService.categories.first;
  int _correctAnswer = 0;
  List<String> _questionImages = [];
  String? _questionMainImage;
  Map<int, String> _choiceImages = {};

  // 개념 관련 변수들
  final _conceptFormKey = GlobalKey<FormState>();
  late final TextEditingController _conceptContentController;
  List<String> _conceptImageUrls = [];
  String? _conceptMainImageUrl;

  bool get isEditingQuestion => widget.question != null;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    // 문제 컨트롤러 초기화
    _questionController = TextEditingController();
    _choiceControllers = List.generate(5, (index) => TextEditingController());

    // 개념 컨트롤러 초기화
    _conceptContentController = TextEditingController();

    // 수정 모드인 경우 기존 데이터로 초기화
    if (isEditingQuestion) {
      final question = widget.question!;
      _questionController.text = question.questionText;
      for (int i = 0; i < 5; i++) {
        _choiceControllers[i].text = question.choices[i];
      }
      _selectedCategory = question.subject;
      _correctAnswer = question.correctAnswer;

      // 이미지 데이터 초기화
      _questionImages = List.from(question.imageUrls);
      _questionMainImage = question.questionImageUrl;
      _choiceImages = Map.from(question.choiceImageUrls);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionController.dispose();
    for (final controller in _choiceControllers) {
      controller.dispose();
    }
    _conceptContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('문제 & 개념 입력'),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.quiz),
              text: '문제 입력',
            ),
            Tab(
              icon: Icon(Icons.lightbulb_outline),
              text: '개념 입력',
            ),
          ],
        ),
        actions: [
          // Obsidian 저장 버튼
          TextButton.icon(
            onPressed: _isSavingToObsidian ? null : _saveCurrentTabToObsidian,
            icon: _isSavingToObsidian
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.folder_special, color: Colors.white),
            label: Text(
              'Obsidian',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _isSubmitting ? null : _submitCurrentTab,
            child: Text(
              _tabController.index == 0 ? '문제 저장' : '개념 저장',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuestionForm(),
          _buildConceptForm(),
        ],
      ),
    );
  }

  Widget _buildQuestionForm() {
    return Form(
      key: _questionFormKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 선택
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '과목 선택',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: ClintestService.categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 문제 입력
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
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '문제를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 문제 이미지 첨부
            ImageAttachmentWidget(
              title: '문제 이미지',
              imageUrls: _questionImages,
              onImagesChanged: (images) {
                setState(() {
                  _questionImages = images;
                  if (images.isNotEmpty && _questionMainImage == null) {
                    _questionMainImage = images.first;
                  }
                });
              },
              maxImages: 3,
              useObsidianStorage: false, // 문제는 Firebase Storage 사용
            ),

            const SizedBox(height: 16),

            // 선택지 입력
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '선택지',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            // 정답 선택 라디오 버튼
                            Radio<int>(
                              value: index,
                              groupValue: _correctAnswer,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _correctAnswer = value;
                                  });
                                }
                              },
                              activeColor: Colors.green,
                            ),
                            // 선택지 번호
                            Text(
                              '${index + 1}.',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 선택지 입력 필드
                            Expanded(
                              child: TextFormField(
                                controller: _choiceControllers[index],
                                decoration: InputDecoration(
                                  hintText: '선택지 ${index + 1}을 입력하세요...',
                                  border: const OutlineInputBorder(),
                                  fillColor: _correctAnswer == index
                                      ? Colors.green.shade50
                                      : null,
                                  filled: _correctAnswer == index,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
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
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade600),
                          const SizedBox(width: 8),
                          Text(
                            '정답: ${_correctAnswer + 1}번',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
                onPressed: _isSubmitting ? null : _submitQuestion,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(isEditingQuestion ? Icons.edit : Icons.save),
                label: Text(
                  _isSubmitting
                      ? (isEditingQuestion ? '수정 중...' : '저장 중...')
                      : (isEditingQuestion ? '문제 수정' : '문제 저장'),
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
    );
  }

  Widget _buildConceptForm() {
    return Form(
      key: _conceptFormKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 개념 설명
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '개념 설명',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _conceptContentController,
                      decoration: const InputDecoration(
                        hintText: '개념에 대한 설명을 입력하세요...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 8,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '개념 설명을 입력해주세요';
                        }
                        if (value.trim().length < 10) {
                          return '개념 설명은 최소 10자 이상이어야 합니다';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 개념 이미지 첨부 (Obsidian 직접 저장)
            ImageAttachmentWidget(
              title: '개념 이미지',
              imageUrls: _conceptImageUrls,
              onImagesChanged: (images) {
                setState(() {
                  _conceptImageUrls = images;
                  if (images.isNotEmpty && _conceptMainImageUrl == null) {
                    _conceptMainImageUrl = images.first;
                  }
                });
              },
              maxImages: 5,
              useObsidianStorage: true, // Obsidian에 직접 저장
            ),

            const SizedBox(height: 24),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitConcept,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isSubmitting ? '저장 중...' : '개념 저장',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
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
    );
  }


  Future<void> _submitCurrentTab() async {
    if (_tabController.index == 0) {
      await _submitQuestion();
    } else {
      await _submitConcept();
    }
  }

  Future<void> _saveCurrentTabToObsidian() async {
    if (_tabController.index == 0) {
      await _saveQuestionToObsidian();
    } else {
      await _saveConceptToObsidian();
    }
  }

  Future<void> _submitQuestion() async {
    if (!_questionFormKey.currentState!.validate()) {
      return;
    }

    final user = AuthService().currentUser;
    if (user == null) {
      _showError('로그인이 필요합니다');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final question = Question(
        id: isEditingQuestion ? widget.question!.id : '',
        questionText: _questionController.text.trim(),
        choices: _choiceControllers.map((controller) => controller.text.trim()).toList(),
        correctAnswer: _correctAnswer,
        subject: _selectedCategory,
        explanation: '',
        difficulty: '', // AI가 나중에 분석하여 설정
        imageUrls: _questionImages,
        questionImageUrl: _questionMainImage,
        choiceImageUrls: _choiceImages,
        createdBy: user.displayName ?? user.email ?? 'Unknown',
        createdAt: isEditingQuestion ? widget.question!.createdAt : DateTime.now(),
      );

      final questionId = await _clintestService.addQuestion(question);
      final success = questionId != null;

      if (success && mounted) {
        _showSuccess(isEditingQuestion ? '문제가 수정되었습니다' : '문제가 저장되었습니다');
        // 약간 지연 후 네비게이션
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else if (mounted) {
        _showError('문제 저장에 실패했습니다');
      }
    } catch (e) {
      if (mounted) {
        _showError('오류가 발생했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _submitConcept() async {
    if (!_conceptFormKey.currentState!.validate()) {
      return;
    }

    final user = AuthService().currentUser;
    if (user == null) {
      _showError('로그인이 필요합니다');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final concept = Concept(
        id: '',
        title: '', // 제목 필드 제거
        description: '', // 간단 설명 필드 제거
        subject: 'medical', // 모든 개념은 medical 카테고리
        tags: [], // 태그 제거
        content: _conceptContentController.text.trim(),
        imageUrls: _conceptImageUrls,
        mainImageUrl: _conceptMainImageUrl,
        createdBy: user.displayName ?? user.email ?? 'Unknown',
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      // TODO: ConceptService를 통해 저장
      // final success = await _conceptService.saveConcept(concept);

      if (mounted) {
        _showSuccess('개념이 저장되었습니다');
        // 폼 초기화
        _conceptContentController.clear();
        setState(() {
          _conceptImageUrls.clear();
          _conceptMainImageUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('오류가 발생했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _saveQuestionToObsidian() async {
    if (!_questionFormKey.currentState!.validate()) {
      _showError('모든 필드를 올바르게 입력해주세요');
      return;
    }

    final user = AuthService().currentUser;
    if (user == null) {
      _showError('로그인이 필요합니다');
      return;
    }

    setState(() {
      _isSavingToObsidian = true;
    });

    try {
      // Obsidian API 연결 테스트
      final isConnected = await ObsidianWebService.testConnection();
      if (!isConnected) {
        if (mounted) {
          _showError('Obsidian Local REST API에 연결할 수 없습니다.\nObsidian이 실행 중이고 API 플러그인이 활성화되어 있는지 확인해주세요.');
        }
        return;
      }

      // Question 객체 생성
      final question = Question(
        id: '',
        questionText: _questionController.text.trim(),
        choices: _choiceControllers.map((controller) => controller.text.trim()).toList(),
        correctAnswer: _correctAnswer,
        subject: _selectedCategory,
        explanation: '',
        difficulty: '', // AI가 나중에 분석하여 설정
        imageUrls: _questionImages,
        questionImageUrl: _questionMainImage,
        choiceImageUrls: _choiceImages,
        createdBy: user.displayName ?? user.email ?? 'Unknown',
        createdAt: DateTime.now(),
      );

      // Obsidian에 저장
      final success = await ObsidianWebService.saveQuestionToObsidian(question);

      if (mounted) {
        if (success) {
          _showSuccess('✅ Obsidian에 문제가 저장되었습니다!');
        } else {
          _showError('❌ Obsidian 저장에 실패했습니다.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('❌ 저장 중 오류가 발생했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingToObsidian = false;
        });
      }
    }
  }

  Future<void> _saveConceptToObsidian() async {
    if (!_conceptFormKey.currentState!.validate()) {
      _showError('모든 필드를 올바르게 입력해주세요');
      return;
    }

    final user = AuthService().currentUser;
    if (user == null) {
      _showError('로그인이 필요합니다');
      return;
    }

    setState(() {
      _isSavingToObsidian = true;
    });

    try {
      // Obsidian API 연결 테스트
      final isConnected = await ObsidianWebService.testConnection();
      if (!isConnected) {
        if (mounted) {
          _showError('Obsidian Local REST API에 연결할 수 없습니다.\nObsidian이 실행 중이고 API 플러그인이 활성화되어 있는지 확인해주세요.');
        }
        return;
      }

      // Concept 객체 생성
      final concept = Concept(
        id: '',
        title: '', // 제목 필드 제거
        description: '', // 간단 설명 필드 제거
        subject: 'medical',
        tags: [], // 태그 제거
        content: _conceptContentController.text.trim(),
        imageUrls: _conceptImageUrls,
        mainImageUrl: _conceptMainImageUrl,
        createdBy: user.displayName ?? user.email ?? 'Unknown',
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      // Obsidian에 저장
      final success = await ObsidianWebService.saveConceptToObsidian(concept);

      if (mounted) {
        if (success) {
          _showSuccess('✅ Obsidian에 개념이 저장되었습니다!\n폴더: medical/pending');
        } else {
          _showError('❌ Obsidian 저장에 실패했습니다.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('❌ 저장 중 오류가 발생했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingToObsidian = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}