import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/microphone_service.dart';
import '../services/ai_feedback_service.dart';
import '../models/audio_reference.dart';
import '../models/pitch_data.dart';
import '../widgets/accuracy_feedback_widget.dart';
import 'dart:async';
import 'dart:math' as math;

class ScalePracticeScreen extends StatefulWidget {
  final AudioReference audioReference;
  
  const ScalePracticeScreen({
    super.key,
    required this.audioReference,
  });

  @override
  State<ScalePracticeScreen> createState() => _ScalePracticeScreenState();
}

class _ScalePracticeScreenState extends State<ScalePracticeScreen>
    with TickerProviderStateMixin {
  
  final MicrophoneService _microphoneService = MicrophoneService();
  
  bool _isListening = false;
  bool _isLoading = true;
  
  PitchData? _referencePitchData;
  List<double> _referencePitches = [];
  List<String> _noteNames = [];
  
  int _currentNoteIndex = 0;
  double _pitchAccuracy = 0.0;
  bool _isNoteHit = false;
  
  Timer? _listeningTimer;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController.repeat(reverse: true);
    
    _loadReferenceData();
  }

  @override
  void dispose() {
    _stopListening();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadReferenceData() async {
    try {
      final databaseService = context.read<DatabaseService>();
      final pitchData = await databaseService.getPitchDataByAudioId(widget.audioReference.id!);
      
      if (pitchData != null) {
        setState(() {
          _referencePitchData = pitchData;
          _referencePitches = pitchData.pitchCurve;
          _noteNames = _generateNoteNames();
          _isLoading = false;
        });
      } else {
        _showError('레퍼런스 피치 데이터를 찾을 수 없습니다.');
      }
    } catch (e) {
      _showError('데이터 로딩 중 오류: $e');
    }
  }

  List<String> _generateNoteNames() {
    // 음계에 따른 노트 이름 생성
    final keyNote = widget.audioReference.key;
    final scaleType = widget.audioReference.scaleType;
    final octaves = widget.audioReference.octaves;
    
    List<String> notes = [];
    
    if (scaleType == 'Major') {
      // 메이저 스케일 패턴 (전-전-반-전-전-전-반)
      final majorPattern = [0, 2, 4, 5, 7, 9, 11]; // 반음 단위
      final baseNotes = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
      final keyIndex = baseNotes.indexOf(keyNote.split('/')[0]);
      
      for (int octave = 0; octave < octaves; octave++) {
        for (int noteInScale = 0; noteInScale < majorPattern.length; noteInScale++) {
          final noteIndex = (keyIndex + majorPattern[noteInScale]) % 12;
          final octaveNumber = 4 + octave + ((keyIndex + majorPattern[noteInScale]) ~/ 12);
          notes.add('${baseNotes[noteIndex]}$octaveNumber');
        }
      }
      // 마지막에 다음 옥타브의 첫 음 추가 (완전한 스케일을 위해)
      final finalOctave = 4 + octaves;
      notes.add('${baseNotes[keyIndex]}$finalOctave');
    } else {
      // 단순히 크로매틱으로 생성 (다른 스케일 타입들)
      for (int i = 0; i < _referencePitches.length ~/ 10; i++) {
        notes.add('Note ${i + 1}');
      }
    }
    
    return notes.take(_referencePitches.length ~/ 10).toList();
  }

  void _startListening() async {
    if (await _microphoneService.requestPermission()) {
      setState(() {
        _isListening = true;
        _currentNoteIndex = 0;
        _progressController.reset();
      });
      
      await _microphoneService.startRealtimeAnalysis();
      
      // 실시간 피치 분석 시작
      _listeningTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        _analyzePitch();
      });
    } else {
      _showError('마이크 권한이 필요합니다.');
    }
  }

  void _stopListening() async {
    setState(() {
      _isListening = false;
    });
    
    _listeningTimer?.cancel();
    _listeningTimer = null;
    await _microphoneService.stopRealtimeAnalysis();
  }

  void _analyzePitch() {
    final pitchInfo = _microphoneService.getCurrentPitchInfo();
    if (pitchInfo == null) return;
    
    final userPitch = pitchInfo['frequency'] as double;
    if (userPitch <= 0) return;
    
    // 현재 목표 음과 비교
    if (_currentNoteIndex < _referencePitches.length) {
      final targetPitch = _referencePitches[_currentNoteIndex];
      final cents = _calculateCents(userPitch, targetPitch);
      
      setState(() {
        _pitchAccuracy = cents;
        _isNoteHit = cents.abs() < 30.0; // 30센트 이내면 정확
      });
      
      // 정확한 음을 1초간 유지하면 다음 음으로 진행
      if (_isNoteHit) {
        _progressController.forward().then((_) {
          if (_progressController.isCompleted) {
            _moveToNextNote();
          }
        });
      } else {
        _progressController.reset();
      }
    }
  }

  void _moveToNextNote() {
    if (_currentNoteIndex < _noteNames.length - 1) {
      setState(() {
        _currentNoteIndex++;
        _progressController.reset();
      });
    } else {
      // 연습 완료
      _stopListening();
      _showCompletionDialog();
    }
  }

  double _calculateCents(double userFreq, double targetFreq) {
    if (userFreq <= 0 || targetFreq <= 0) return 0.0;
    return 1200 * (math.log(userFreq / targetFreq) / math.ln2);
  }

  double _calculateStability() {
    // 간단한 안정도 계산 (실제로는 최근 피치 값들의 분산을 사용)
    final absAccuracy = _pitchAccuracy.abs();
    if (absAccuracy <= 10) return 5.0; // 매우 안정적
    if (absAccuracy <= 30) return 15.0; // 안정적
    if (absAccuracy <= 50) return 30.0; // 보통
    return 45.0; // 불안정
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('연습 완료!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('스케일 연습을 완료했습니다!'),
            const SizedBox(height: 16),
            Text(
              '${widget.audioReference.key} ${widget.audioReference.scaleType}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 연습 화면 닫기
            },
            child: const Text('홈으로'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAIFeedback();
            },
            child: const Text('AI 피드백'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restartPractice();
            },
            child: const Text('다시 연습'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAIFeedback() async {
    if (_referencePitchData == null) return;
    
    // AI 분석 생성
    final analysis = AIFeedbackService.generateAnalysis(
      _referencePitchData!,
      widget.audioReference,
    );
    
    // AI 피드백 다이얼로그 표시
    showDialog(
      context: context,
      builder: (context) => _buildAIFeedbackDialog(analysis),
    );
  }

  Widget _buildAIFeedbackDialog(VocalAnalysis analysis) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue, size: 28),
                const SizedBox(width: 8),
                Text(
                  'AI 보컬 분석',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const Divider(height: 32),
            
            // 분석 결과
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 기본 통계
                    _buildAnalysisSection(
                      '기본 분석',
                      [
                        '평균 정확도: ${analysis.accuracyMean.toStringAsFixed(1)}센트',
                        '안정성: ${analysis.stabilityStd.toStringAsFixed(1)}센트',
                        '분석 시간: ${analysis.analyzedAt.toString().substring(0, 19)}',
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 약점 음표
                    if (analysis.weakNotes.isNotEmpty)
                      _buildAnalysisSection(
                        '개선이 필요한 음표',
                        analysis.weakNotes,
                        color: Colors.orange,
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // 상세 메트릭
                    _buildDetailedMetrics(analysis.detailedMetrics),
                    
                    const SizedBox(height: 24),
                    
                    // AI 피드백 로딩
                    FutureBuilder<AIFeedback?>(
                      future: _generateAIFeedback(analysis),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('AI 피드백을 생성하는 중...'),
                              ],
                            ),
                          );
                        }
                        
                        if (snapshot.hasError || !snapshot.hasData) {
                          return _buildFallbackFeedback();
                        }
                        
                        final feedback = snapshot.data!;
                        return _buildAIFeedbackContent(feedback);
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // 액션 버튼
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // AI 피드백 다이얼로그 닫기
                    Navigator.pop(context); // 연습 화면 닫기
                  },
                  child: const Text('홈으로'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // AI 피드백 다이얼로그 닫기
                    _restartPractice();
                  },
                  child: const Text('다시 연습'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSection(String title, List<String> items, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Row(
            children: [
              Icon(
                Icons.fiber_manual_record,
                size: 6,
                color: color ?? Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(item)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildDetailedMetrics(Map<String, dynamic> metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상세 분석',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMetricRow('총 음표 수', '${metrics['total_notes'] ?? 0}개'),
                _buildMetricRow('정확한 음표', '${metrics['valid_notes'] ?? 0}개'),
                _buildMetricRow('완성도', '${metrics['completion_rate'] ?? 0}%'),
                if (metrics['strongest_note']?.isNotEmpty == true)
                  _buildMetricRow('가장 정확한 음', '${metrics['strongest_note']}'),
                if (metrics['weakest_note']?.isNotEmpty == true)
                  _buildMetricRow('개선 필요한 음', '${metrics['weakest_note']}'),
                _buildMetricRow(
                  '시간별 안정성',
                  '${(metrics['time_stability'] ?? 0.0).toStringAsFixed(1)}센트',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<AIFeedback?> _generateAIFeedback(VocalAnalysis analysis) async {
    final feedbackService = AIFeedbackService();
    try {
      return await feedbackService.generateFeedback(
        analysis,
        widget.audioReference,
        language: 'ko',
      );
    } catch (e) {
      if (kDebugMode) print('AI 피드백 생성 오류: $e');
      return null;
    }
  }

  Widget _buildFallbackFeedback() {
    return Card(
      color: Colors.blue.shade50,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '기본 피드백',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text('연습 세션이 완료되었습니다. 지속적인 연습을 통해 더욱 향상될 것입니다.'),
            SizedBox(height: 8),
            Text('• 천천히 정확한 피치로 연습해보세요'),
            Text('• 메트로놈과 함께 안정적인 템포를 유지하세요'),
            Text('• 꾸준한 연습이 가장 중요합니다'),
          ],
        ),
      ),
    );
  }

  Widget _buildAIFeedbackContent(AIFeedback feedback) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 전반적 평가
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assessment, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      '전반적 평가',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(feedback.overallAssessment),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('신뢰도: '),
                    Text(
                      '${(feedback.confidenceScore * 100).round()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 강점
        if (feedback.strengthsPoints.isNotEmpty)
          _buildFeedbackSection(
            '강점',
            feedback.strengthsPoints,
            Icons.thumb_up,
            Colors.green,
          ),
        
        const SizedBox(height: 16),
        
        // 개선점
        if (feedback.improvementAreas.isNotEmpty)
          _buildFeedbackSection(
            '개선점',
            feedback.improvementAreas,
            Icons.trending_up,
            Colors.orange,
          ),
        
        const SizedBox(height: 16),
        
        // 구체적 추천사항
        if (feedback.specificRecommendations.isNotEmpty)
          _buildFeedbackSection(
            '추천사항',
            feedback.specificRecommendations,
            Icons.lightbulb,
            Colors.purple,
          ),
        
        const SizedBox(height: 16),
        
        // 연습법
        if (feedback.practiceExercises.isNotEmpty)
          _buildFeedbackSection(
            '연습법',
            feedback.practiceExercises,
            Icons.fitness_center,
            Colors.teal,
          ),
        
        const SizedBox(height: 16),
        
        // 격려 메시지
        Card(
          color: Colors.amber.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feedback.encouragementMessage,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection(String title, List<String> items, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _restartPractice() {
    setState(() {
      _currentNoteIndex = 0;
      _progressController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('스케일 연습'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.audioReference.key} ${widget.audioReference.scaleType}'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 진행 상황 표시
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '진행 상황: ${_currentNoteIndex + 1} / ${_noteNames.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_currentNoteIndex + 1) / _noteNames.length,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 현재 목표 음
            if (_currentNoteIndex < _noteNames.length) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        '목표 음',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_pulseController.value * 0.1),
                            child: Text(
                              _noteNames[_currentNoteIndex],
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _isNoteHit ? Colors.green : Theme.of(context).primaryColor,
                              ),
                            ),
                          );
                        },
                      ),
                      if (_isListening) ...[
                        const SizedBox(height: 16),
                        Text(
                          '정확도: ${_pitchAccuracy.toStringAsFixed(1)}c',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _isNoteHit ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 정확도 피드백
              if (_isListening && _currentNoteIndex < _noteNames.length) ...[
                AccuracyFeedbackWidget(
                  accuracy: _pitchAccuracy,
                  stability: _calculateStability(),
                  targetNote: _noteNames[_currentNoteIndex],
                  isActive: _isListening,
                  onAccuracyThresholdMet: () {
                    // 정확도 임계점 달성 시 진행 바 시작
                    if (!_progressController.isAnimating) {
                      _progressController.forward();
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // 진행 게이지
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          _isNoteHit ? '정확합니다! 유지하세요...' : '음정을 맞춰주세요',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _isNoteHit ? Colors.green : Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: _progressController.value,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                              minHeight: 6,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
            
            const Spacer(),
            
            // 제어 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isListening ? _stopListening : _startListening,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening ? Colors.red : Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isListening ? Icons.stop : Icons.play_arrow),
                    const SizedBox(width: 8),
                    Text(
                      _isListening ? '연습 중지' : '연습 시작',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 재시작 버튼
            if (_currentNoteIndex > 0)
              TextButton(
                onPressed: _restartPractice,
                child: const Text('처음부터 다시'),
              ),
          ],
        ),
      ),
    );
  }
}