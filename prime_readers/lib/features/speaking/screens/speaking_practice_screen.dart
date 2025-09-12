import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/speaking_models.dart';
import '../providers/speaking_provider.dart';
import '../services/audio_recording_service.dart';

class SpeakingPracticeScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final String userId;

  const SpeakingPracticeScreen({
    super.key,
    required this.lessonId,
    this.userId = 'temp_user',
  });

  @override
  ConsumerState<SpeakingPracticeScreen> createState() => _SpeakingPracticeScreenState();
}

class _SpeakingPracticeScreenState extends ConsumerState<SpeakingPracticeScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  
  int _currentExerciseIndex = 0;
  int _attemptNumber = 1;
  bool _isEvaluating = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
    
    // 연습 세션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(speakingControllerProvider.notifier)
          .startPracticeSession(widget.userId, widget.lessonId);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonAsync = ref.watch(speakingLessonProvider(widget.lessonId));
    final recordingState = ref.watch(recordingStateProvider);
    final recordingDuration = ref.watch(recordingDurationProvider);
    final recordingAmplitude = ref.watch(recordingAmplitudeProvider);
    final evaluation = ref.watch(evaluationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('스피킹 연습'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => _handleBackPress(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: lessonAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('레슨을 불러올 수 없습니다\n$error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('돌아가기'),
              ),
            ],
          ),
        ),
        data: (lesson) {
          if (lesson == null) {
            return const Center(child: Text('레슨을 찾을 수 없습니다'));
          }

          if (lesson.exercises.isEmpty) {
            return const Center(child: Text('연습 문제가 없습니다'));
          }

          final currentExercise = lesson.exercises[_currentExerciseIndex];
          
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 진행 상황
                _buildProgressIndicator(lesson),
                const SizedBox(height: 24),
                
                // 현재 연습 문제
                Expanded(
                  child: _buildExerciseContent(currentExercise),
                ),
                
                // 녹음 컨트롤
                _buildRecordingControls(
                  currentExercise,
                  recordingState,
                  recordingDuration,
                  recordingAmplitude,
                ),
                
                // 평가 결과
                if (evaluation.hasValue && evaluation.value != null)
                  _buildEvaluationResult(evaluation.value!),
                  
                const SizedBox(height: 16),
                
                // 네비게이션 버튼
                _buildNavigationButtons(lesson),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator(SpeakingLesson lesson) {
    final progress = (_currentExerciseIndex + 1) / lesson.exercises.length;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '문제 ${_currentExerciseIndex + 1}/${lesson.exercises.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseContent(SpeakingExercise exercise) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 연습 문장
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '다음 문장을 따라 말해보세요',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    exercise.text,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    exercise.phoneticTranscription,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.blue[600],
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 핵심 단어
          if (exercise.keyWords.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.key, size: 20, color: Colors.orange[600]),
                        const SizedBox(width: 8),
                        Text(
                          '핵심 단어',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: exercise.keyWords.map((word) => Chip(
                        label: Text(word),
                        backgroundColor: Colors.orange[100],
                        labelStyle: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w500,
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // 힌트
          if (exercise.hint != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amber[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        exercise.hint!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
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

  Widget _buildRecordingControls(
    SpeakingExercise exercise,
    RecordingState recordingState,
    AsyncValue<Duration> recordingDuration,
    AsyncValue<double> recordingAmplitude,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 녹음 상태 표시
            _buildRecordingStateIndicator(recordingState, recordingAmplitude),
            const SizedBox(height: 16),
            
            // 녹음 시간
            recordingDuration.when(
              data: (duration) => Text(
                _formatDuration(duration),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: recordingState == RecordingState.recording 
                      ? Colors.red 
                      : Colors.grey[600],
                ),
              ),
              loading: () => const Text('00:00'),
              error: (_, __) => const Text('00:00'),
            ),
            
            const SizedBox(height: 20),
            
            // 녹음 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 취소 버튼
                if (recordingState != RecordingState.idle)
                  ElevatedButton.icon(
                    onPressed: _handleCancelRecording,
                    icon: const Icon(Icons.cancel),
                    label: const Text('취소'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.grey[700],
                    ),
                  ),
                
                // 메인 녹음 버튼
                _buildMainRecordingButton(recordingState),
                
                // 완료 버튼
                if (recordingState == RecordingState.stopped)
                  ElevatedButton.icon(
                    onPressed: _isEvaluating ? null : () => _handleCompleteRecording(exercise),
                    icon: _isEvaluating 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isEvaluating ? '평가 중...' : '완료'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingStateIndicator(
    RecordingState state,
    AsyncValue<double> amplitude,
  ) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getRecordingStateColor(state).withOpacity(0.1),
        border: Border.all(
          color: _getRecordingStateColor(state),
          width: 2,
        ),
      ),
      child: AnimatedBuilder(
        animation: state == RecordingState.recording ? _pulseController : _waveController,
        builder: (context, child) {
          if (state == RecordingState.recording) {
            _pulseController.repeat(reverse: true);
          } else {
            _pulseController.stop();
          }
          
          return Transform.scale(
            scale: state == RecordingState.recording 
                ? _pulseAnimation.value 
                : 1.0,
            child: Icon(
              _getRecordingStateIcon(state),
              size: 40,
              color: _getRecordingStateColor(state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainRecordingButton(RecordingState state) {
    switch (state) {
      case RecordingState.idle:
        return ElevatedButton.icon(
          onPressed: _handleStartRecording,
          icon: const Icon(Icons.mic),
          label: const Text('녹음 시작'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        );
      
      case RecordingState.recording:
        return ElevatedButton.icon(
          onPressed: _handleStopRecording,
          icon: const Icon(Icons.stop),
          label: const Text('녹음 정지'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        );
      
      case RecordingState.paused:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: _handleResumeRecording,
              icon: const Icon(Icons.play_arrow),
              label: const Text('재개'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _handleStopRecording,
              icon: const Icon(Icons.stop),
              label: const Text('정지'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      
      case RecordingState.stopped:
        return ElevatedButton.icon(
          onPressed: _handleStartRecording,
          icon: const Icon(Icons.refresh),
          label: const Text('다시 녹음'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        );
    }
  }

  Widget _buildEvaluationResult(SpeakingEvaluation evaluation) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  '평가 결과',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 전체 점수
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '전체 점수',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${evaluation.overallScore.toInt()}점',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _getScoreColor(evaluation.overallScore),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 세부 점수
            _buildScoreRow('발음', evaluation.pronunciationScore),
            _buildScoreRow('유창성', evaluation.fluencyScore),
            _buildScoreRow('정확성', evaluation.accuracyScore),
            
            const SizedBox(height: 16),
            
            // 인식된 텍스트
            Text(
              '인식된 텍스트:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                evaluation.transcribedText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 단어별 피드백 (간략히)
            if (evaluation.feedback.isNotEmpty) ...[
              Text(
                '단어별 피드백:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: evaluation.feedback.map((feedback) => Chip(
                  label: Text('${feedback.word} ${feedback.score.toInt()}'),
                  backgroundColor: feedback.isCorrect 
                      ? Colors.green[100] 
                      : Colors.orange[100],
                  labelStyle: TextStyle(
                    color: feedback.isCorrect 
                        ? Colors.green[800] 
                        : Colors.orange[800],
                    fontSize: 12,
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Container(
                width: 60,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: score / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getScoreColor(score),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${score.toInt()}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(SpeakingLesson lesson) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 이전 문제
        ElevatedButton.icon(
          onPressed: _currentExerciseIndex > 0 ? _handlePreviousExercise : null,
          icon: const Icon(Icons.arrow_back),
          label: const Text('이전'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.grey[700],
          ),
        ),
        
        // 다음 문제 / 완료
        ElevatedButton.icon(
          onPressed: _handleNextExercise,
          icon: Icon(_currentExerciseIndex < lesson.exercises.length - 1 
              ? Icons.arrow_forward 
              : Icons.check_circle),
          label: Text(_currentExerciseIndex < lesson.exercises.length - 1 
              ? '다음' 
              : '레슨 완료'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // Event Handlers
  void _handleStartRecording() async {
    final recordingNotifier = ref.read(recordingStateProvider.notifier);
    await recordingNotifier.startRecording();
  }

  void _handleStopRecording() async {
    final recordingNotifier = ref.read(recordingStateProvider.notifier);
    await recordingNotifier.stopRecording();
  }

  void _handlePauseRecording() async {
    final recordingNotifier = ref.read(recordingStateProvider.notifier);
    await recordingNotifier.pauseRecording();
  }

  void _handleResumeRecording() async {
    final recordingNotifier = ref.read(recordingStateProvider.notifier);
    await recordingNotifier.resumeRecording();
  }

  void _handleCancelRecording() async {
    final recordingNotifier = ref.read(recordingStateProvider.notifier);
    await recordingNotifier.cancelRecording();
    
    // 평가 결과도 클리어
    ref.read(evaluationProvider.notifier).clearEvaluation();
  }

  void _handleCompleteRecording(SpeakingExercise exercise) async {
    setState(() {
      _isEvaluating = true;
    });

    try {
      final controller = ref.read(speakingControllerProvider.notifier);
      final evaluation = await controller.finishRecordingAndEvaluate(
        exercise: exercise,
        attemptNumber: _attemptNumber,
      );

      if (evaluation != null) {
        ref.read(evaluationProvider.notifier).clearEvaluation();
        // 평가 결과를 직접 상태에 설정
        ref.read(evaluationProvider.notifier).state = AsyncValue.data(evaluation);
      }

      _attemptNumber++;
    } finally {
      setState(() {
        _isEvaluating = false;
      });
    }
  }

  void _handlePreviousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _attemptNumber = 1;
      });
      _resetExerciseState();
    }
  }

  void _handleNextExercise() {
    final lessonAsync = ref.read(speakingLessonProvider(widget.lessonId));
    lessonAsync.whenData((lesson) {
      if (lesson != null) {
        if (_currentExerciseIndex < lesson.exercises.length - 1) {
          setState(() {
            _currentExerciseIndex++;
            _attemptNumber = 1;
          });
          _resetExerciseState();
        } else {
          _handleLessonComplete();
        }
      }
    });
  }

  void _handleLessonComplete() {
    // 세션 완료
    ref.read(currentSpeakingSessionProvider.notifier).completeSession();
    
    // 성공 다이얼로그 표시
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 축하합니다!'),
        content: const Text('레슨을 완료했습니다!\n훌륭한 발음 연습이었어요.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _handleBackPress() async {
    final recordingState = ref.read(recordingStateProvider);
    
    if (recordingState == RecordingState.recording || recordingState == RecordingState.paused) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('녹음 중입니다'),
          content: const Text('녹음을 취소하고 나가시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('계속 연습'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('나가기'),
            ),
          ],
        ),
      );

      if (shouldLeave == true) {
        _handleCancelRecording();
        if (mounted) {
          context.pop();
        }
      }
    } else {
      context.pop();
    }
  }

  void _resetExerciseState() {
    // 녹음 상태 초기화
    ref.read(recordingStateProvider.notifier).cancelRecording();
    
    // 평가 결과 초기화
    ref.read(evaluationProvider.notifier).clearEvaluation();
  }

  // Helper Methods
  Color _getRecordingStateColor(RecordingState state) {
    switch (state) {
      case RecordingState.idle:
        return Colors.grey;
      case RecordingState.recording:
        return Colors.red;
      case RecordingState.paused:
        return Colors.orange;
      case RecordingState.stopped:
        return Colors.blue;
    }
  }

  IconData _getRecordingStateIcon(RecordingState state) {
    switch (state) {
      case RecordingState.idle:
        return Icons.mic;
      case RecordingState.recording:
        return Icons.mic;
      case RecordingState.paused:
        return Icons.pause;
      case RecordingState.stopped:
        return Icons.stop;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.deepOrange;
    return Colors.red;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}