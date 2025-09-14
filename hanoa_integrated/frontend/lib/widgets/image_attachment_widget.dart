import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/image_service.dart';
import '../services/web_clipboard_service.dart';
import '../services/obsidian_web_service.dart';

class ImageAttachmentWidget extends StatefulWidget {
  final String title;
  final List<String> imageUrls;
  final Function(List<String>) onImagesChanged;
  final int maxImages;
  final bool useObsidianStorage; // Obsidian에 직접 저장할지 여부

  const ImageAttachmentWidget({
    super.key,
    required this.title,
    required this.imageUrls,
    required this.onImagesChanged,
    this.maxImages = 5,
    this.useObsidianStorage = false, // 기본값은 Firebase Storage 사용
  });

  @override
  State<ImageAttachmentWidget> createState() => _ImageAttachmentWidgetState();
}

class _ImageAttachmentWidgetState extends State<ImageAttachmentWidget> {
  final ImageService _imageService = ImageService();
  final WebClipboardService _clipboardService = WebClipboardService();
  bool _isUploading = false;
  List<String> _currentImages = [];

  // 임시 클립보드 이미지 저장
  Uint8List? _pendingClipboardImage;
  bool _hasPendingClipboardImage = false;

  @override
  void initState() {
    super.initState();
    _currentImages = List.from(widget.imageUrls);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.image,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_currentImages.length}/${widget.maxImages}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 이미지 업로드 버튼들
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionButton(
                  icon: Icons.photo_library,
                  label: '갤러리',
                  onPressed: _pickFromGallery,
                  color: Colors.blue,
                ),
                if (kIsWeb) ...[
                  _buildActionButton(
                    icon: Icons.content_paste,
                    label: '붙여넣기',
                    onPressed: _pasteFromClipboard,
                    color: Colors.green,
                  ),
                ],
              ],
            ),

            // 임시 클립보드 이미지 미리보기
            if (_hasPendingClipboardImage && _pendingClipboardImage != null) ...[
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.preview, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '클립보드 이미지 미리보기',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 이미지 미리보기
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _pendingClipboardImage!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 저장/취소 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _saveClipboardImage,
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('저장'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _discardClipboardImage,
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('취소'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            if (_currentImages.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildImageGrid(),
            ],

            if (_isUploading) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                widget.useObsidianStorage ? 'Obsidian에 이미지 저장 중...' : '이미지 업로드 중...',
                style: TextStyle(color: Colors.blue.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: _isUploading || _currentImages.length >= widget.maxImages ? null : onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.lerp(color, Colors.white, 0.9),
        foregroundColor: Color.lerp(color, Colors.black, 0.3),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _currentImages.length,
      itemBuilder: (context, index) {
        return _buildImageItem(_currentImages[index], index);
      },
    );
  }

  Widget _buildImageItem(String imageUrl, int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImageDisplay(imageUrl),
          ),

          // 삭제 버튼
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

          // 확대 버튼
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _showImagePreview(imageUrl),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.zoom_in,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imageService.pickImageFromGallery();
      if (image != null) {
        await _uploadAndAddImage(image);
      }
    } catch (e) {
      _showError('갤러리에서 이미지를 선택하는 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final Uint8List? imageData = await _clipboardService.getImageFromClipboard();
      if (imageData != null) {
        setState(() {
          _pendingClipboardImage = imageData;
          _hasPendingClipboardImage = true;
        });

        _showInfo('클립보드 이미지를 확인하세요. 저장하려면 "저장" 버튼을 클릭하세요.');
      } else {
        _showInfo('클립보드에 이미지가 없습니다');
      }
    } catch (e) {
      _showError('클립보드 이미지 붙여넣기 중 오류가 발생했습니다: $e');
    }
  }

  // 임시 클립보드 이미지를 실제로 저장
  Future<void> _saveClipboardImage() async {
    if (_pendingClipboardImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String? imageUrl;

      if (widget.useObsidianStorage) {
        // Obsidian에 직접 저장
        final String fileName = ObsidianWebService.generateImageFileName('png');
        final String? obsidianPath = await ObsidianWebService.saveImageToObsidian(_pendingClipboardImage!, fileName);

        if (obsidianPath != null) {
          // Obsidian 로컬 경로를 URL로 사용 (마크다운에서 참조용)
          imageUrl = obsidianPath;
        }
      } else {
        // Firebase Storage에 업로드
        imageUrl = await _imageService.uploadImageFromBytes(
          _pendingClipboardImage!,
          'questions/clipboard',
        );
      }

      if (imageUrl != null) {
        setState(() {
          _currentImages.add(imageUrl!);
          _pendingClipboardImage = null;
          _hasPendingClipboardImage = false;
        });
        widget.onImagesChanged(_currentImages);
        _showSuccess(widget.useObsidianStorage ?
          'Obsidian에 클립보드 이미지가 저장되었습니다' :
          '클립보드 이미지가 추가되었습니다');
      } else {
        _showError(widget.useObsidianStorage ?
          'Obsidian 이미지 저장에 실패했습니다' :
          '이미지 업로드에 실패했습니다');
      }
    } catch (e) {
      _showError('이미지 저장 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // 임시 클립보드 이미지를 취소
  void _discardClipboardImage() {
    setState(() {
      _pendingClipboardImage = null;
      _hasPendingClipboardImage = false;
    });
  }

  Future<void> _uploadAndAddImage(XFile image) async {
    setState(() {
      _isUploading = true;
    });

    try {
      String? imageUrl;

      if (widget.useObsidianStorage) {
        // Obsidian에 직접 저장
        final Uint8List imageBytes = await image.readAsBytes();
        final String extension = image.path.split('.').last.toLowerCase();
        final String fileName = ObsidianWebService.generateImageFileName(extension);
        final String? obsidianPath = await ObsidianWebService.saveImageToObsidian(imageBytes, fileName);

        if (obsidianPath != null) {
          imageUrl = obsidianPath;
        }
      } else {
        // Firebase Storage에 업로드
        imageUrl = await _imageService.uploadImage(image, 'questions/gallery');
      }

      if (imageUrl != null) {
        setState(() {
          _currentImages.add(imageUrl!);
        });
        widget.onImagesChanged(_currentImages);
        _showSuccess(widget.useObsidianStorage ?
          'Obsidian에 이미지가 저장되었습니다' :
          '이미지가 추가되었습니다');
      } else {
        _showError(widget.useObsidianStorage ?
          'Obsidian 이미지 저장에 실패했습니다' :
          '이미지 업로드에 실패했습니다');
      }
    } catch (e) {
      _showError(widget.useObsidianStorage ?
        'Obsidian 이미지 저장 중 오류가 발생했습니다: $e' :
        '이미지 업로드 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _removeImage(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 삭제'),
        content: const Text('이 이미지를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentImages.removeAt(index);
              });
              widget.onImagesChanged(_currentImages);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplay(String imageUrl) {
    // Obsidian 로컬 경로인지 확인
    if (imageUrl.startsWith('medical/pending/images/')) {
      // Obsidian 로컬 이미지는 아이콘으로 표시 (웹에서 로컬 파일 접근 불가)
      return Container(
        color: Colors.blue.shade50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              color: Colors.blue.shade400,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              'Obsidian 이미지',
              style: TextStyle(
                color: Colors.blue.shade600,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              imageUrl.split('/').last,
              style: TextStyle(
                color: Colors.blue.shade400,
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    } else {
      // Firebase Storage URL은 일반적으로 표시
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade100,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image,
                color: Colors.grey.shade400,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                '로드 실패',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: imageUrl.startsWith('medical/pending/images/')
                ? Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: Colors.blue.shade400,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Obsidian 로컬 이미지',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          imageUrl.split('/').last,
                          style: TextStyle(
                            color: Colors.blue.shade400,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Obsidian에서 이미지를 확인할 수 있습니다.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
            ),
            Positioned(
              top: 40,
              right: 40,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}