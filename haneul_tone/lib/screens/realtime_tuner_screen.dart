import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../services/microphone_service.dart';
import '../utils/note_utils.dart';
import '../widgets/accuracy_feedback_widget.dart';

class RealtimeTunerScreen extends StatefulWidget {
  const RealtimeTunerScreen({super.key});

  @override
  State<RealtimeTunerScreen> createState() => _RealtimeTunerScreenState();
}

class _RealtimeTunerScreenState extends State<RealtimeTunerScreen>
    with TickerProviderStateMixin {
  final MicrophoneService _micService = MicrophoneService();
  
  // 실시간 데이터
  double _currentFrequency = 0.0;
  String _currentNote = '';
  double _cents = 0.0;
  bool _isRecording = false;
  bool _hasPermission = false;
  
  // 히스토리 데이터 (안정성 표시용)
  final List<double> _frequencyHistory = [];
  final List<double> _centsHistory = [];
  static const int maxHistoryLength = 20; // 1초간의 데이터 (50ms * 20)
  
  // 애니메이션
  late AnimationController _needleAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _needleAnimation;
  late Animation<double> _pulseAnimation;
  
  // 설정값
  double _a4Frequency = 440.0;
  double _sensitivity = 0.5; // 0.0 ~ 1.0
  
  // 스트림 구독
  StreamSubscription<double>? _pitchSubscription;
  
  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 초기화
    _needleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _needleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _needleAnimationController,
      curve: Curves.easeOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _initializeMicrophone();
  }
  
  @override
  void dispose() {
    _pitchSubscription?.cancel();
    _micService.stopRealtimeAnalysis();
    _needleAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeMicrophone() async {
    final hasPermission = await _micService.requestMicrophonePermission();
    setState(() {
      _hasPermission = hasPermission;
    });
    
    if (hasPermission) {
      await _startListening();
    }
  }
  
  Future<void> _startListening() async {
    if (_isRecording) return;
    
    final success = await _micService.startRealtimeAnalysis();
    if (success) {
      setState(() {
        _isRecording = true;
      });
      
      _pitchSubscription = _micService.pitchStream.listen((frequency) {
        _updatePitchData(frequency);
      });
      
      _pulseAnimationController.repeat(reverse: true);
    }
  }
  
  Future<void> _stopListening() async {
    await _micService.stopRealtimeAnalysis();
    await _pitchSubscription?.cancel();
    _pitchSubscription = null;
    
    setState(() {
      _isRecording = false;
      _currentFrequency = 0.0;
      _currentNote = '';
      _cents = 0.0;
    });
    
    _pulseAnimationController.stop();
    _needleAnimationController.reset();
    _frequencyHistory.clear();
    _centsHistory.clear();
  }
  
  void _updatePitchData(double frequency) {
    if (!mounted) return;
    
    // 히스토리 업데이트
    _frequencyHistory.add(frequency);
    if (_frequencyHistory.length > maxHistoryLength) {
      _frequencyHistory.removeAt(0);
    }
    
    // 주파수가 유효한 경우에만 처리
    if (frequency > 0) {
      final noteInfo = NoteUtils.snapToNearestNote(frequency, _a4Frequency);
      final cents = noteInfo['cents'] as double;
      
      _centsHistory.add(cents);
      if (_centsHistory.length > maxHistoryLength) {
        _centsHistory.removeAt(0);
      }
      
      setState(() {
        _currentFrequency = frequency;
        _currentNote = noteInfo['note'] as String;
        _cents = cents;
      });
      
      // 바늘 애니메이션
      final targetPosition = (cents.clamp(-50.0, 50.0) + 50.0) / 100.0;
      _needleAnimationController.animateTo(targetPosition);
    } else {
      // 무음 상태
      setState(() {
        _currentFrequency = 0.0;
        _currentNote = '';
        _cents = 0.0;
      });
      
      _needleAnimationController.animateTo(0.5); // 중앙 위치
    }
  }
  
  Color _getAccuracyColor() {
    if (_cents.abs() < 5) return Colors.green;
    if (_cents.abs() < 15) return Colors.orange;
    return Colors.red;
  }
  
  double _getStability() {
    if (_centsHistory.length < 5) return 0.0;
    
    final recentCents = _centsHistory.take(10).where((c) => c.abs() < 100).toList();
    if (recentCents.isEmpty) return 0.0;
    
    final mean = recentCents.reduce((a, b) => a + b) / recentCents.length;
    final variance = recentCents
        .map((c) => math.pow(c - mean, 2))
        .reduce((a, b) => a + b) / recentCents.length;
    final stability = math.max(0.0, 1.0 - (math.sqrt(variance) / 20.0));
    
    return stability.clamp(0.0, 1.0);
  }
  
  double _getStabilityValue() {
    if (_centsHistory.length < 5) return 50.0; // 높은 불안정성
    
    final recentCents = _centsHistory.take(10).where((c) => c.abs() < 100).toList();
    if (recentCents.isEmpty) return 50.0;
    
    final mean = recentCents.reduce((a, b) => a + b) / recentCents.length;
    final variance = recentCents
        .map((c) => math.pow(c - mean, 2))
        .reduce((a, b) => a + b) / recentCents.length;
    
    return math.sqrt(variance).clamp(0.0, 50.0); // 표준편차를 센트 단위로 반환
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('실시간 튜너'),
        actions: [
          IconButton(
            icon: Icon(_isRecording ? Icons.stop : Icons.play_arrow),
            onPressed: _hasPermission
                ? (_isRecording ? _stopListening : _startListening)
                : null,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                _showSettingsDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('설정'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _hasPermission
          ? _buildTunerBody()
          : _buildPermissionRequestBody(),
    );
  }
  
  Widget _buildPermissionRequestBody() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '마이크 권한이 필요합니다',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            '설정에서 마이크 권한을 허용해주세요',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTunerBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 상태 표시
          _buildStatusCard(),
          const SizedBox(height: 16),
          
          // 정확도 피드백
          if (_isRecording && _currentNote.isNotEmpty)
            AccuracyFeedbackWidget(
              accuracy: _cents,
              stability: _getStabilityValue(),
              targetNote: _currentNote,
              isActive: _isRecording,
            ),
          
          const SizedBox(height: 16),
          
          // 메인 튜너 디스플레이
          Expanded(
            child: _buildTunerDisplay(),
          ),
          
          // 하단 정보
          _buildBottomInfo(),
        ],
      ),
    );
  }
  
  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 녹음 상태
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRecording ? _pulseAnimation.value : 1.0,
                  child: Icon(
                    _isRecording ? Icons.mic : Icons.mic_none,
                    color: _isRecording ? Colors.red : Colors.grey,
                    size: 24,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            
            // 상태 텍스트
            Text(
              _isRecording ? '듣는 중...' : '일시 정지',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const Spacer(),
            
            // 안정성 표시
            if (_isRecording) ...[
              const Text('안정성: '),
              SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  value: _getStability(),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStability() > 0.7 ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(_getStability() * 100).round()}%',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildTunerDisplay() {
    return Column(
      children: [
        // 현재 음표 표시
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                _currentNote.isEmpty ? '♪' : _currentNote,
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: _currentNote.isEmpty ? Colors.grey : _getAccuracyColor(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentFrequency > 0 
                    ? '${_currentFrequency.toStringAsFixed(1)} Hz'
                    : 'Silent',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        
        // 튜너 게이지
        Expanded(
          child: CustomPaint(
            painter: TunerGaugePainter(
              cents: _cents,
              needlePosition: _needleAnimation.value,
              color: _getAccuracyColor(),
            ),
            child: const SizedBox.expand(),
          ),
        ),
        
        // 센트 표시
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                _cents == 0.0 ? '0¢' : '${_cents > 0 ? '+' : ''}${_cents.round()}¢',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getAccuracyColor(),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getAccuracyMessage(),
                style: TextStyle(
                  fontSize: 14,
                  color: _getAccuracyColor(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _getAccuracyMessage() {
    if (_cents == 0.0) return '음표를 연주해보세요';
    final absCents = _cents.abs();
    if (absCents < 5) return '완벽합니다! 🎯';
    if (absCents < 15) return '거의 정확해요 👍';
    if (absCents < 30) return _cents > 0 ? '조금 높아요 ↑' : '조금 낮아요 ↓';
    return _cents > 0 ? '너무 높아요 ⬆️' : '너무 낮아요 ⬇️';
  }
  
  Widget _buildBottomInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem('A4', '${_a4Frequency.round()}Hz'),
            _buildInfoItem('감도', '${(_sensitivity * 100).round()}%'),
            _buildInfoItem('이력', '${_frequencyHistory.length}/$maxHistoryLength'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('튜너 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // A4 주파수 설정
            ListTile(
              title: const Text('A4 주파수'),
              subtitle: Text('${_a4Frequency.round()}Hz'),
              trailing: SizedBox(
                width: 100,
                child: Slider(
                  value: _a4Frequency,
                  min: 430.0,
                  max: 450.0,
                  divisions: 20,
                  onChanged: (value) {
                    setState(() {
                      _a4Frequency = value;
                    });
                  },
                ),
              ),
            ),
            
            // 감도 설정
            ListTile(
              title: const Text('감도'),
              subtitle: Text('${(_sensitivity * 100).round()}%'),
              trailing: SizedBox(
                width: 100,
                child: Slider(
                  value: _sensitivity,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    setState(() {
                      _sensitivity = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}

class TunerGaugePainter extends CustomPainter {
  final double cents;
  final double needlePosition;
  final Color color;
  
  TunerGaugePainter({
    required this.cents,
    required this.needlePosition,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 3;
    
    // 배경 호
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );
    
    // 정확도 구역 표시 (녹색 중앙 부분)
    final accuratePaint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.9,
      math.pi * 0.2,
      false,
      accuratePaint,
    );
    
    // 센트 마크 (-50 ~ +50)
    for (int i = -50; i <= 50; i += 10) {
      final angle = math.pi + (i / 50.0) * (math.pi / 2);
      final isMainMark = i % 25 == 0;
      final markLength = isMainMark ? 20.0 : 10.0;
      
      final startX = center.dx + (radius - markLength) * math.cos(angle);
      final startY = center.dy + (radius - markLength) * math.sin(angle);
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);
      
      final markPaint = Paint()
        ..color = i == 0 ? Colors.green : Colors.grey[600]!
        ..strokeWidth = isMainMark ? 3 : 1;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        markPaint,
      );
      
      // 숫자 표시
      if (isMainMark) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: i == 0 ? '0' : '${i > 0 ? '+' : ''}$i',
            style: TextStyle(
              color: i == 0 ? Colors.green : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        final textX = center.dx + (radius + 25) * math.cos(angle) - textPainter.width / 2;
        final textY = center.dy + (radius + 25) * math.sin(angle) - textPainter.height / 2;
        textPainter.paint(canvas, Offset(textX, textY));
      }
    }
    
    // 바늘
    final needleAngle = math.pi + (needlePosition - 0.5) * math.pi;
    final needleLength = radius - 10;
    
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );
    
    final needlePaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(center, needleEnd, needlePaint);
    
    // 중심점
    canvas.drawCircle(
      center,
      8,
      Paint()..color = color,
    );
  }
  
  @override
  bool shouldRepaint(TunerGaugePainter oldDelegate) {
    return cents != oldDelegate.cents ||
           needlePosition != oldDelegate.needlePosition ||
           color != oldDelegate.color;
  }
}