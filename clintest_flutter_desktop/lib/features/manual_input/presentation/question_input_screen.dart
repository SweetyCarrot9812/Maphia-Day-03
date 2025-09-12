import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/clipboard_service.dart';
import '../../../services/sync_management_service.dart';
import '../../../shared/models/question_data.dart';
import '../../sync_management/presentation/sync_management_screen.dart';

class QuestionInputScreen extends ConsumerStatefulWidget {
  final String subject;
  final Color subjectColor;
  
  const QuestionInputScreen({
    super.key,
    required this.subject,
    required this.subjectColor,
  });

  @override
  ConsumerState<QuestionInputScreen> createState() => _QuestionInputScreenState();
}

class _QuestionInputScreenState extends ConsumerState<QuestionInputScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _explanationController = TextEditingController();
  final SyncManagementService _syncService = SyncManagementService();
  
  // 5지선다 보기 컨트롤러들
  final List<TextEditingController> _optionControllers = List.generate(
    5, 
    (index) => TextEditingController(),
  );
  
  int _correctAnswerIndex = 0; // 정답 인덱스 (0-4)
  
  final List<File> _selectedImages = [];
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    _questionController.dispose();
    _explanationController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        setState(() {
          _selectedImages.addAll(
            result.paths.where((path) => path != null).map((path) => File(path!))
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _pasteImageFromClipboard() async {
    try {
      final hasImage = await ClipboardService.hasImageInClipboard();
      
      if (!hasImage) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('클립보드에 이미지가 없습니다.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final clipboardImage = await ClipboardService.getImageFromClipboard();
      
      if (clipboardImage != null) {
        // 파일 크기 검사
        final isValidSize = await ClipboardService.isImageSizeValid(clipboardImage);
        if (!isValidSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('이미지 크기가 너무 큽니다. (최대 5MB)'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedImages.add(clipboardImage);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('클립보드에서 이미지를 붙여넣었습니다.'),
              backgroundColor: widget.subjectColor,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('이미지 붙여넣기에 실패했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 붙여넣기 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      // Ctrl+V 키 조합 감지
      if (event.logicalKey == LogicalKeyboardKey.keyV && 
          (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
           HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlRight))) {
        _pasteImageFromClipboard();
      }
    }
  }

  Future<void> _saveQuestion() async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문제를 입력해주세요.')),
      );
      return;
    }

    // 5지선다 보기 검증
    final options = _optionControllers.map((controller) => controller.text.trim()).toList();
    final filledOptions = options.where((option) => option.isNotEmpty).toList();
    
    if (filledOptions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 2개 이상의 보기를 입력해주세요.')),
      );
      return;
    }

    if (options[_correctAnswerIndex].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('정답으로 선택한 보기를 입력해주세요.')),
      );
      return;
    }

    try {
      // 이미지 파일들을 로컬에 저장
      final List<String> imagePaths = [];
      for (int i = 0; i < _selectedImages.length; i++) {
        final imageFile = _selectedImages[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.${imageFile.path.split('.').last}';
        final savedPath = await LocalStorageService.saveImageFile(imageFile, fileName);
        imagePaths.add(savedPath);
      }

      // 5지선다 답안 문자열 생성
      const answerLabels = ['①', '②', '③', '④', '⑤'];
      final correctAnswerText = '${answerLabels[_correctAnswerIndex]} ${options[_correctAnswerIndex]}';

      // 문제 데이터 생성 (v3.1 형태로)
      final questionData = QuestionData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        subject: widget.subject,
        stem: _questionController.text.trim(), // question → stem으로 변경
        choices: options.where((opt) => opt.isNotEmpty).toList(), // 빈 선택지 제거
        correctAnswer: String.fromCharCode(65 + _correctAnswerIndex), // 0->A, 1->B, ...
        explanation: _explanationController.text.trim().isNotEmpty ? _explanationController.text.trim() : null,
        imagePaths: imagePaths,
        createdAt: DateTime.now(),
        status: QuestionStatus.pending,
        difficulty: 'MID', // 기본 난이도
        source: 'manual', // 수동 입력 표시
        // 5지선다 보기를 메타데이터로 저장 (필요시 사용)
        metadata: {
          'questionType': 'multiple_choice',
          'options': options,
          'correctIndex': _correctAnswerIndex,
          'legacyAnswer': correctAnswerText, // 기존 answer 형태 보존
        },
      );

      // 로컬 저장소에 저장
      await LocalStorageService.saveQuestion(questionData);

      // v3.1 형식으로 변환하여 동기화 대기 목록에 추가
      final v31Question = _convertToV31Format(questionData, options);
      await _syncService.addToPendingSync(v31Question);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.subject} 문제가 저장되고 동기화 대기 목록에 추가되었습니다.'),
            backgroundColor: widget.subjectColor,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '동기화 관리',
              onPressed: _navigateToSyncManagement,
              textColor: Colors.white,
            ),
          ),
        );

        // 입력창 초기화
        _questionController.clear();
        _explanationController.clear();
        for (var controller in _optionControllers) {
          controller.clear();
        }
        setState(() {
          _selectedImages.clear();
          _correctAnswerIndex = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.subject} - 문제 입력'),
          backgroundColor: widget.subjectColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: widget.subjectColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  '${widget.subject} 문제 작성',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 문제 입력
                    _buildSectionTitle('문제', Icons.quiz),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _questionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: '문제를 입력하세요...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: widget.subjectColor, width: 2),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    
                    // 5지선다 보기 입력
                    _buildSectionTitle('5지선다 보기', Icons.list),
                    SizedBox(height: 8.h),
                    ...List.generate(5, (index) {
                      const optionLabels = ['①', '②', '③', '④', '⑤'];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Row(
                          children: [
                            // 라디오 버튼 (정답 선택용)
                            Radio<int>(
                              value: index,
                              groupValue: _correctAnswerIndex,
                              onChanged: (int? value) {
                                if (value != null) {
                                  setState(() {
                                    _correctAnswerIndex = value;
                                  });
                                }
                              },
                              activeColor: widget.subjectColor,
                            ),
                            SizedBox(width: 8.w),
                            // 보기 번호 표시
                            Container(
                              width: 30.w,
                              alignment: Alignment.center,
                              child: Text(
                                optionLabels[index],
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: _correctAnswerIndex == index 
                                    ? widget.subjectColor 
                                    : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            // 보기 입력 필드
                            Expanded(
                              child: TextField(
                                controller: _optionControllers[index],
                                decoration: InputDecoration(
                                  hintText: '${index + 1}번 보기를 입력하세요...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    borderSide: BorderSide(
                                      color: _correctAnswerIndex == index 
                                        ? widget.subjectColor 
                                        : Colors.grey, 
                                      width: 2
                                    ),
                                  ),
                                  filled: _correctAnswerIndex == index,
                                  fillColor: _correctAnswerIndex == index 
                                    ? widget.subjectColor.withOpacity(0.1) 
                                    : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: 8.h),
                    // 정답 안내 텍스트
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: widget.subjectColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: widget.subjectColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: widget.subjectColor,
                            size: 16.r,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              '라디오 버튼을 클릭하여 정답을 선택하세요. 현재 정답: ${['①', '②', '③', '④', '⑤'][_correctAnswerIndex]}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: widget.subjectColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    
                    // 해설 입력
                    _buildSectionTitle('해설', Icons.description),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _explanationController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: '해설을 입력하세요... (선택사항)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: widget.subjectColor, width: 2),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    
                    // 이미지 첨부
                    _buildSectionTitle('이미지 첨부', Icons.image),
                    SizedBox(height: 8.h),
                    _buildImageSection(),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
            
            // 저장 버튼
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      side: BorderSide(color: widget.subjectColor),
                    ),
                    child: const Text('취소'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.subjectColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text('문제 저장'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: widget.subjectColor),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이미지 추가 버튼들
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('이미지 추가'),
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.subjectColor,
                side: BorderSide(color: widget.subjectColor),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
            SizedBox(width: 12.w),
            OutlinedButton.icon(
              onPressed: _pasteImageFromClipboard,
              icon: const Icon(Icons.content_paste),
              label: const Text('붙여넣기 (Ctrl+V)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.subjectColor,
                side: BorderSide(color: widget.subjectColor),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ],
        ),
        
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(height: 16.h),
          // 이미지 미리보기
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: _selectedImages.asMap().entries.map((entry) {
              int index = entry.key;
              File image = entry.value;
              
              return Stack(
                children: [
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade300),
                      image: DecorationImage(
                        image: FileImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4.w,
                    right: 4.w,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16.r,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  /// 기존 QuestionData를 v3.1 형식으로 변환
  QuestionData _convertToV31Format(dynamic oldQuestion, List<String> options) {
    // v3.1 QuestionData import 필요
    return QuestionData(
      id: oldQuestion.id,
      subject: oldQuestion.subject,
      stem: oldQuestion.stem, // stem 필드 사용
      choices: options.where((opt) => opt.isNotEmpty).toList(), // 빈 보기 제거
      correctAnswer: String.fromCharCode(65 + _correctAnswerIndex), // 0->A, 1->B, ...
      explanation: oldQuestion.explanation,
      type: QuestionType.mcq, // 기본값: 객관식
      difficulty: 'MID', // 기본 난이도
      imagePaths: oldQuestion.imagePaths ?? [],
      createdAt: oldQuestion.createdAt,
      status: QuestionStatus.pending,
      source: 'manual', // 수동 입력 표시
      embedding: const [], // 비어있음
      metadata: oldQuestion.metadata,
    );
  }

  void _navigateToSyncManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SyncManagementScreen(),
      ),
    );
  }
}