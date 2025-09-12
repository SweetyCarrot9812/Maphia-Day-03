import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/clipboard_service.dart';
import '../../../shared/models/concept_data.dart';

class ManualConceptsScreen extends ConsumerStatefulWidget {
  const ManualConceptsScreen({super.key});

  @override
  ConsumerState<ManualConceptsScreen> createState() => _ManualConceptsScreenState();
}

class _ManualConceptsScreenState extends ConsumerState<ManualConceptsScreen> {
  final TextEditingController _contentController = TextEditingController();
  
  final List<File> _selectedImages = [];
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    _contentController.dispose();
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
            const SnackBar(
              content: Text('클립보드에서 이미지를 붙여넣었습니다.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
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
      if (event.logicalKey == LogicalKeyboardKey.keyV && 
          (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
           HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlRight))) {
        _pasteImageFromClipboard();
      }
    }
  }

  Future<void> _saveConcept() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요.')),
      );
      return;
    }

    try {
      // 이미지 파일들을 로컬에 저장
      final List<String> imagePaths = [];
      for (int i = 0; i < _selectedImages.length; i++) {
        final imageFile = _selectedImages[i];
        final fileName = 'concept_${DateTime.now().millisecondsSinceEpoch}_$i.${imageFile.path.split('.').last}';
        final savedPath = await LocalStorageService.saveImageFile(imageFile, fileName);
        imagePaths.add(savedPath);
      }

      // 개념 데이터 생성
      final conceptData = ConceptData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _contentController.text.trim().split('\n').first.trim(), // 첫 줄을 제목으로 사용
        content: _contentController.text.trim(),
        keywords: <String>[], // 키워드는 빈 리스트
        imagePaths: imagePaths,
        createdAt: DateTime.now(),
        status: ConceptStatus.pending,
      );

      // 로컬 저장소에 저장
      await LocalStorageService.saveConcept(conceptData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('개념이 로컬에 저장되었습니다.\nAI 검토 후 Firebase에 동기화됩니다.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // 입력창 초기화
        _contentController.clear();
        setState(() {
          _selectedImages.clear();
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
          title: const Text('수동 개념 입력'),
          backgroundColor: Colors.green,
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
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  '개념 정리 및 이론 작성',
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
                    // 내용 입력
                    _buildSectionTitle('내용', Icons.description),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _contentController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: '개념의 상세 내용을 입력하세요...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    
                    // 이미지 첨부 (다중)
                    _buildSectionTitle('이미지 첨부 (다중 선택 가능)', Icons.image),
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
                      side: const BorderSide(color: Colors.green),
                    ),
                    child: const Text('취소'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveConcept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text('개념 저장'),
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
        Icon(icon, size: 20.r, color: Colors.green),
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
              label: const Text('여러 이미지 추가'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
            SizedBox(width: 12.w),
            OutlinedButton.icon(
              onPressed: _pasteImageFromClipboard,
              icon: const Icon(Icons.content_paste),
              label: const Text('붙여넣기 (Ctrl+V)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ],
        ),
        
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Text(
            '첨부된 이미지 (${_selectedImages.length}개)',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 12.h),
          // 이미지 미리보기 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              File image = _selectedImages[index];
              
              return Stack(
                children: [
                  Container(
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
            },
          ),
        ],
      ],
    );
  }
}