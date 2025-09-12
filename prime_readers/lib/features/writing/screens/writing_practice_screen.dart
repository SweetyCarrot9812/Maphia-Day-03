import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../models/writing_models.dart';
import '../providers/writing_provider.dart';
import '../services/writing_service.dart';

class WritingPracticeScreen extends ConsumerStatefulWidget {
  final String taskId;
  
  const WritingPracticeScreen({
    super.key,
    required this.taskId,
  });

  @override
  ConsumerState<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends ConsumerState<WritingPracticeScreen>
    with TickerProviderStateMixin {
  
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  WritingTask? _currentTask;
  bool _showKeyboard = true;
  bool _showHandwritingMode = false;
  String? _handwritingImagePath;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTask();
    _textController.addListener(_onTextChanged);
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  void _loadTask() async {
    final service = ref.read(writingServiceProvider);
    final task = service.getTask(widget.taskId);
    if (task != null) {
      setState(() {
        _currentTask = task;
      });
    }
  }

  void _onTextChanged() {
    final text = _textController.text;
    ref.read(writingControllerProvider.notifier).updateContent(text);
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final writingState = ref.watch(writingControllerProvider);
    
    if (_currentTask == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('라이팅 연습')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTask!.title),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showTaskDetails,
            icon: const Icon(Icons.info_outline),
            tooltip: '과제 정보',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text('임시 저장'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'camera',
                child: Row(
                  children: [
                    Icon(Icons.camera_alt),
                    SizedBox(width: 8),
                    Text('손글씨 인식'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'keyboard_toggle',
                child: Row(
                  children: [
                    Icon(Icons.keyboard),
                    SizedBox(width: 8),
                    Text('입력 모드 전환'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 진행 상태 표시
          _buildProgressIndicator(writingState),
          
          // 메인 콘텐츠
          Expanded(
            child: _showHandwritingMode 
                ? _buildHandwritingMode(writingState)
                : _buildTypingMode(writingState),
          ),
          
          // 하단 도구 모음
          _buildBottomToolbar(writingState),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(writingState),
    );
  }

  Widget _buildProgressIndicator(WritingState state) {
    final progress = state.wordCount / _currentTask!.maxWords;
    final isOverLimit = state.wordCount > _currentTask!.maxWords;
    final isUnderLimit = state.wordCount < _currentTask!.minWords;
    
    Color progressColor = Colors.blue;
    if (isOverLimit) {
      progressColor = Colors.red;
    } else if (isUnderLimit) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '단어 수: ${state.wordCount}/${_currentTask!.maxWords}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
              if (state.realtimeErrors.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error, size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        '오류 ${state.realtimeErrors.length}개',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: progressColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
          ),
          if (isUnderLimit) ...[
            const SizedBox(height: 4),
            Text(
              '최소 ${_currentTask!.minWords}단어 이상 작성해주세요',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.orange,
              ),
            ),
          ],
          if (isOverLimit) ...[
            const SizedBox(height: 4),
            Text(
              '최대 단어 수를 초과했습니다',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingMode(WritingState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 과제 프롬프트
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        '과제',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentTask!.prompt,
                    style: const TextStyle(height: 1.5),
                  ),
                  if (_currentTask!.keyPoints.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      '핵심 포인트:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...(_currentTask!.keyPoints.map((point) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(point)),
                        ],
                      ),
                    ))),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 텍스트 입력 영역
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '작성하기',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _textFocusNode,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: '여기에 작성해주세요...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.1),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                        onChanged: (text) {
                          ref.read(writingControllerProvider.notifier)
                              .recordAction(WritingActionType.typed, content: text);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 실시간 오류 표시
          if (state.realtimeErrors.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          '실시간 검사',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...state.realtimeErrors.take(3).map((error) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${error.originalText} → ${error.correctedText}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )),
                    if (state.realtimeErrors.length > 3)
                      Text(
                        '외 ${state.realtimeErrors.length - 3}개 더',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHandwritingMode(WritingState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '손글씨 인식',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '손글씨 사진을 업로드하거나 촬영하여 텍스트로 변환할 수 있습니다.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _captureHandwriting(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('사진 촬영'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _captureHandwriting(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('갤러리에서 선택'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (_handwritingImagePath != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '촬영된 이미지',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_handwritingImagePath!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isRecognizingOCR ? null : _processHandwriting,
                        child: state.isRecognizingOCR
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 8),
                                  Text('텍스트 인식 중...'),
                                ],
                              )
                            : const Text('텍스트로 변환'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          if (state.lastOCRResult != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.text_fields, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          '인식된 텍스트',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '신뢰도: ${(state.lastOCRResult!.confidence * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        state.lastOCRResult!.text,
                        style: const TextStyle(height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _useOCRText(state.lastOCRResult!.text),
                            child: const Text('텍스트 사용'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => setState(() => _handwritingImagePath = null),
                          child: const Text('다시 촬영'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomToolbar(WritingState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _showTaskDetails,
            icon: const Icon(Icons.help_outline),
            tooltip: '도움말',
          ),
          IconButton(
            onPressed: () => setState(() => _showHandwritingMode = !_showHandwritingMode),
            icon: Icon(_showHandwritingMode ? Icons.keyboard : Icons.camera_alt),
            tooltip: _showHandwritingMode ? '키보드 입력' : '손글씨 인식',
          ),
          const Spacer(),
          
          // 단어 힌트 버튼
          if (_currentTask!.vocabularyHints.isNotEmpty)
            TextButton.icon(
              onPressed: _showVocabularyHints,
              icon: const Icon(Icons.lightbulb_outline, size: 18),
              label: const Text('힌트'),
            ),
          
          const SizedBox(width: 8),
          
          // 임시 저장 버튼
          OutlinedButton(
            onPressed: _saveTemporary,
            child: const Text('임시 저장'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(WritingState state) {
    final canSubmit = state.wordCount >= _currentTask!.minWords &&
                     !state.isProcessing &&
                     state.currentContent.trim().isNotEmpty;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: canSubmit ? _pulseAnimation.value : 1.0,
          child: FloatingActionButton.extended(
            onPressed: canSubmit ? _submitWriting : null,
            backgroundColor: canSubmit ? Colors.green : Colors.grey,
            icon: state.isProcessing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
            label: Text(state.isProcessing ? '제출 중...' : '제출하기'),
          ),
        );
      },
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'save':
        _saveTemporary();
        break;
      case 'camera':
        setState(() => _showHandwritingMode = !_showHandwritingMode);
        break;
      case 'keyboard_toggle':
        setState(() => _showKeyboard = !_showKeyboard);
        break;
    }
  }

  void _showTaskDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _currentTask!.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailSection('과제 설명', _currentTask!.description),
                    _buildDetailSection('프롬프트', _currentTask!.prompt),
                    if (_currentTask!.keyPoints.isNotEmpty)
                      _buildDetailSection(
                        '핵심 포인트',
                        _currentTask!.keyPoints.map((p) => '• $p').join('\n'),
                      ),
                    if (_currentTask!.vocabularyHints.isNotEmpty)
                      _buildDetailSection(
                        '어휘 힌트',
                        _currentTask!.vocabularyHints.join(', '),
                      ),
                    _buildDetailSection(
                      '요구사항',
                      '• 단어 수: ${_currentTask!.minWords}-${_currentTask!.maxWords}단어\n'
                      '• 제한 시간: ${_currentTask!.timeLimit.inMinutes}분\n'
                      '• 유형: ${_getTypeLabel(_currentTask!.type)}\n'
                      '• 난이도: ${_getDifficultyLabel(_currentTask!.difficulty)}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }

  void _showVocabularyHints() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('어휘 힌트'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '다음 단어들을 참고해서 작성해보세요:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _currentTask!.vocabularyHints.map((hint) => Chip(
                  label: Text(hint),
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                )).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _captureHandwriting(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _handwritingImagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 실패: $e')),
      );
    }
  }

  void _processHandwriting() async {
    if (_handwritingImagePath == null) return;
    
    await ref.read(writingControllerProvider.notifier)
        .recognizeTextFromImage(_handwritingImagePath!);
  }

  void _useOCRText(String ocrText) {
    final currentText = _textController.text;
    final newText = currentText.isEmpty ? ocrText : '$currentText\n\n$ocrText';
    
    _textController.text = newText;
    ref.read(writingControllerProvider.notifier).updateContent(newText);
    
    setState(() {
      _showHandwritingMode = false;
      _handwritingImagePath = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OCR 텍스트가 추가되었습니다')),
    );
  }

  void _saveTemporary() async {
    await ref.read(writingControllerProvider.notifier)
        .recordAction(WritingActionType.saved, content: _textController.text);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('임시 저장되었습니다')),
    );
  }

  void _submitWriting() async {
    final state = ref.read(writingControllerProvider);
    
    if (state.wordCount < _currentTask!.minWords) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('최소 ${_currentTask!.minWords}단어 이상 작성해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('제출 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('작성한 라이팅을 제출하시겠습니까?'),
            const SizedBox(height: 12),
            Text('단어 수: ${state.wordCount}개'),
            if (state.realtimeErrors.isNotEmpty)
              Text(
                '실시간 오류: ${state.realtimeErrors.length}개 발견됨',
                style: const TextStyle(color: Colors.orange),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('제출하기'),
          ),
        ],
      ),
    );

    if (shouldSubmit == true) {
      final submission = await ref.read(writingControllerProvider.notifier)
          .submitWriting(
            inputMethod: _handwritingImagePath != null 
                ? WritingInputMethod.mixed 
                : WritingInputMethod.typing,
            handwritingImageUrl: _handwritingImagePath,
          );

      if (submission != null && mounted) {
        // AI 평가 요청
        await ref.read(writingControllerProvider.notifier)
            .requestEvaluation(submission, _currentTask!);
        
        context.pushReplacement(
          '/student-dashboard/writing/result/${submission.id}',
        );
      }
    }
  }

  String _getTypeLabel(WritingTaskType type) {
    switch (type) {
      case WritingTaskType.essay: return '에세이';
      case WritingTaskType.letter: return '편지';
      case WritingTaskType.story: return '이야기';
      case WritingTaskType.diary: return '일기';
      case WritingTaskType.report: return '보고서';
      case WritingTaskType.review: return '후기';
      case WritingTaskType.description: return '묘사';
      case WritingTaskType.opinion: return '의견';
      case WritingTaskType.instruction: return '설명서';
      case WritingTaskType.creative: return '창작';
      case WritingTaskType.descriptive: return '묘사적';
      case WritingTaskType.argumentative: return '논증적';
      case WritingTaskType.summary: return '요약';
    }
  }

  String _getDifficultyLabel(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner: return '초급';
      case DifficultyLevel.intermediate: return '중급';
      case DifficultyLevel.advanced: return '고급';
    }
  }
}