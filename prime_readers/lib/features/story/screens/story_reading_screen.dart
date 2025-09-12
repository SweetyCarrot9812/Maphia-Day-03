import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/story_model.dart';
import '../providers/story_provider.dart';

class StoryReadingScreen extends ConsumerStatefulWidget {
  final String storyId;
  final String userId;
  final Story? story;

  const StoryReadingScreen({
    super.key,
    required this.storyId,
    required this.userId,
    this.story,
  });

  @override
  ConsumerState<StoryReadingScreen> createState() => _StoryReadingScreenState();
}

class _StoryReadingScreenState extends ConsumerState<StoryReadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _sceneAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 설정
    _sceneAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // 애니메이션 정의
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sceneAnimationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _sceneAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    // 스토리 읽기 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.story != null) {
        ref.read(storyReadingSessionProvider.notifier)
            .startReading(widget.story!, widget.userId);
        _startSceneAnimation();
      }
    });
  }

  @override
  void dispose() {
    _sceneAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _startSceneAnimation() {
    _sceneAnimationController.reset();
    _sceneAnimationController.forward();
  }

  void _updateProgress() {
    _progressAnimationController.reset();
    _progressAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final readingState = ref.watch(storyReadingSessionProvider);
    
    if (readingState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (readingState.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('오류')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('오류가 발생했습니다: ${readingState.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('돌아가기'),
              ),
            ],
          ),
        ),
      );
    }

    if (readingState.currentStory == null) {
      return const Scaffold(
        body: Center(child: Text('스토리를 불러올 수 없습니다')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(readingState.currentStory!.title),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 진행도 표시
            _buildProgressBar(readingState),
            
            // 메인 스토리 영역
            Expanded(
              child: _buildStoryContent(context, readingState),
            ),
            
            // 하단 컨트롤 바
            _buildControlBar(context, readingState),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(StoryReadingState readingState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Scene ${readingState.currentScene + 1} / ${readingState.currentStory!.scenes.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '점수: ${readingState.score}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: readingState.progressPercentage * _progressAnimation.value,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  readingState.isCompleted ? Colors.green : Colors.blue,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStoryContent(BuildContext context, StoryReadingState readingState) {
    return AnimatedBuilder(
      animation: _sceneAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 스토리 이미지 영역 (애니메이션 플레이스홀더)
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getLevelColor(readingState.currentStory!.level).withOpacity(0.1),
                              _getLevelColor(readingState.currentStory!.level).withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: _buildAnimationArea(context, readingState),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 현재 씬 텍스트
                      if (readingState.currentSceneText != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            readingState.currentSceneText!,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // 완료 메시지
                      if (readingState.isCompleted)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green[600], size: 24),
                              const SizedBox(width: 8),
                              Text(
                                '스토리 완료! 점수: ${readingState.score}점',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimationArea(BuildContext context, StoryReadingState readingState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 애니메이션 아이콘 (실제 애니메이션은 향후 구현)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.2),
            duration: const Duration(seconds: 2),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Icon(
                  Icons.auto_stories_outlined,
                  size: 64,
                  color: _getLevelColor(readingState.currentStory!.level),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Scene ${readingState.currentScene + 1}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _getLevelColor(readingState.currentStory!.level),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, StoryReadingState readingState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 이전 버튼
            if (readingState.currentScene > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(storyReadingSessionProvider.notifier).previousScene();
                    _startSceneAnimation();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('이전'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              )
            else
              const Expanded(child: SizedBox()),

            const SizedBox(width: 16),

            // 다음/완료 버튼
            Expanded(
              flex: 2,
              child: readingState.isCompleted
                  ? ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(storyReadingSessionProvider.notifier).completeReading();
                        if (mounted) {
                          _showCompletionDialog(context, readingState.score);
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('완료'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(storyReadingSessionProvider.notifier).nextScene();
                        _startSceneAnimation();
                        _updateProgress();
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        readingState.currentScene == readingState.currentStory!.scenes.length - 1
                            ? '완료하기'
                            : '다음',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
            ),

            const SizedBox(width: 16),

            // 퀴즈 버튼 (향후 구현)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: readingState.quizzes.isNotEmpty
                    ? () => _showQuizDialog(context, readingState)
                    : null,
                icon: const Icon(Icons.quiz),
                label: const Text('퀴즈'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(StoryLevel level) {
    switch (level) {
      case StoryLevel.beginner:
        return Colors.green;
      case StoryLevel.intermediate:
        return Colors.orange;
      case StoryLevel.advanced:
        return Colors.red;
    }
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('스토리 종료'),
        content: const Text('스토리 읽기를 종료하시겠습니까?\n진행도가 저장됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('계속 읽기'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(storyReadingSessionProvider.notifier).endSession();
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('종료'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('읽기 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('애니메이션 속도'),
              subtitle: const Text('보통'),
              onTap: () {
                // 향후 구현: 애니메이션 속도 조절
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('글자 크기'),
              subtitle: const Text('보통'),
              onTap: () {
                // 향후 구현: 글자 크기 조절
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: const Text('음성 재생'),
              subtitle: const Text('끄기'),
              onTap: () {
                // 향후 구현: 음성 재생 설정
              },
            ),
          ],
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

  void _showQuizDialog(BuildContext context, StoryReadingState readingState) {
    if (readingState.quizzes.isEmpty) return;

    final quiz = readingState.quizzes.first;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('퀴즈'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quiz.question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ...quiz.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () async {
                    await ref.read(storyReadingSessionProvider.notifier)
                        .submitQuizAnswer(quiz.id, index);
                    
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      
                      // 정답 여부 표시
                      final isCorrect = quiz.correctAnswer == index;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isCorrect ? '정답입니다! +10점' : '틀렸습니다. 다시 시도해보세요.'),
                          backgroundColor: isCorrect ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Text('${index + 1}. $option'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 32),
            SizedBox(width: 8),
            Text('스토리 완료!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '축하합니다!\n스토리를 성공적으로 완료했습니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '최종 점수',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    '$score점',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 다른 스토리 추천 또는 메인으로 이동
            },
            child: const Text('다른 스토리'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(storyReadingSessionProvider.notifier).endSession();
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('완료'),
          ),
        ],
      ),
    );
  }
}