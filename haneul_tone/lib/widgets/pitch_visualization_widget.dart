import 'package:flutter/material.dart';
import 'dart:math' as math;

class PitchVisualizationWidget extends StatefulWidget {
  final List<double> pitchData; // 피치 데이터 (Hz 단위)
  final List<double> targetPitches; // 목표 피치 데이터 (Hz 단위)
  final List<String> noteNames; // 음표 이름들
  final double currentTime; // 현재 재생 시간 (초)
  final double duration; // 전체 길이 (초)
  final bool showTarget; // 목표 선 표시 여부
  final Color pitchColor; // 피치 선 색상
  final Color targetColor; // 목표 선 색상
  final VoidCallback? onTimeChanged; // 시간 변경 콜백
  
  const PitchVisualizationWidget({
    super.key,
    required this.pitchData,
    this.targetPitches = const [],
    this.noteNames = const [],
    this.currentTime = 0.0,
    this.duration = 10.0,
    this.showTarget = true,
    this.pitchColor = Colors.blue,
    this.targetColor = Colors.green,
    this.onTimeChanged,
  });

  @override
  State<PitchVisualizationWidget> createState() => _PitchVisualizationWidgetState();
}

class _PitchVisualizationWidgetState extends State<PitchVisualizationWidget>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _frequencyToMidi(double frequency) {
    if (frequency <= 0) return 0;
    return 69 + 12 * (math.log(frequency / 440) / math.ln2);
  }

  double _midiToFrequency(double midi) {
    return 440 * math.pow(2, (midi - 69) / 12).toDouble();
  }

  String _midiToNoteName(double midi) {
    if (midi <= 0) return '';
    
    final noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final octave = ((midi - 12) / 12).floor();
    final noteIndex = (midi.round() % 12);
    
    return '${noteNames[noteIndex]}$octave';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목과 컨트롤
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '피치 시각화',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.show_chart,
                      color: widget.pitchColor,
                      size: 20,
                    ),
                    if (widget.showTarget && widget.targetPitches.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.linear_scale,
                        color: widget.targetColor,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 메인 그래프
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return SizedBox(
                  height: 200,
                  child: CustomPaint(
                    painter: PitchGraphPainter(
                      pitchData: widget.pitchData,
                      targetPitches: widget.targetPitches,
                      noteNames: widget.noteNames,
                      currentTime: widget.currentTime,
                      duration: widget.duration,
                      showTarget: widget.showTarget,
                      pitchColor: widget.pitchColor,
                      targetColor: widget.targetColor,
                      animationValue: _animation.value,
                    ),
                    size: Size.infinite,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // 시간 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.currentTime.toStringAsFixed(1)}s',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${widget.duration.toStringAsFixed(1)}s',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            // 진행 바
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: widget.duration > 0 ? widget.currentTime / widget.duration : 0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(widget.pitchColor),
            ),
            
            const SizedBox(height: 16),
            
            // 통계 정보
            if (widget.pitchData.isNotEmpty)
              _buildStatistics(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    // 유효한 피치 데이터 필터링 (0보다 큰 값만)
    final validPitches = widget.pitchData.where((pitch) => pitch > 0).toList();
    
    if (validPitches.isEmpty) {
      return const Text('피치 데이터가 없습니다');
    }
    
    // 통계 계산
    final avgPitch = validPitches.reduce((a, b) => a + b) / validPitches.length;
    final minPitch = validPitches.reduce(math.min);
    final maxPitch = validPitches.reduce(math.max);
    
    // MIDI 노트로 변환
    final avgMidi = _frequencyToMidi(avgPitch);
    final minMidi = _frequencyToMidi(minPitch);
    final maxMidi = _frequencyToMidi(maxPitch);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '피치 통계',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '평균',
                  '${avgPitch.toStringAsFixed(1)} Hz',
                  _midiToNoteName(avgMidi),
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '최저',
                  '${minPitch.toStringAsFixed(1)} Hz',
                  _midiToNoteName(minMidi),
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '최고',
                  '${maxPitch.toStringAsFixed(1)} Hz',
                  _midiToNoteName(maxMidi),
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String frequency, String note, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          frequency,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          note,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class PitchGraphPainter extends CustomPainter {
  final List<double> pitchData;
  final List<double> targetPitches;
  final List<String> noteNames;
  final double currentTime;
  final double duration;
  final bool showTarget;
  final Color pitchColor;
  final Color targetColor;
  final double animationValue;

  PitchGraphPainter({
    required this.pitchData,
    required this.targetPitches,
    required this.noteNames,
    required this.currentTime,
    required this.duration,
    required this.showTarget,
    required this.pitchColor,
    required this.targetColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pitchData.isEmpty) {
      _drawEmptyState(canvas, size);
      return;
    }

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // 배경 그리기
    _drawBackground(canvas, rect);
    
    // Y축 범위 계산
    final validPitches = pitchData.where((pitch) => pitch > 0).toList();
    if (validPitches.isEmpty) {
      _drawEmptyState(canvas, size);
      return;
    }
    
    final minPitch = validPitches.reduce(math.min);
    final maxPitch = validPitches.reduce(math.max);
    final pitchRange = maxPitch - minPitch;
    final padding = pitchRange * 0.1; // 10% 패딩
    
    final yMin = math.max(0, minPitch - padding).toDouble();
    final yMax = (maxPitch + padding).toDouble();
    final yRange = (yMax - yMin).toDouble();
    
    // 그리드 라인 그리기
    _drawGridLines(canvas, rect, yMin, yMax);
    
    // 목표 피치 선 그리기 (먼저 그려서 뒤에 위치)
    if (showTarget && targetPitches.isNotEmpty) {
      _drawTargetLine(canvas, rect, yMin, yRange);
    }
    
    // 피치 데이터 선 그리기
    _drawPitchLine(canvas, rect, yMin, yRange);
    
    // 현재 시간 인디케이터
    _drawTimeIndicator(canvas, rect);
    
    // Y축 라벨
    _drawYAxisLabels(canvas, rect, yMin, yMax);
  }

  void _drawBackground(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      paint,
    );
  }

  void _drawEmptyState(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '피치 데이터가 없습니다',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  void _drawGridLines(Canvas canvas, Rect rect, double yMin, double yMax) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;
    
    // 수평 그리드 라인 (5개)
    for (int i = 0; i <= 4; i++) {
      final y = rect.top + (rect.height * i / 4);
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.right, y),
        paint,
      );
    }
    
    // 수직 그리드 라인 (시간 기준, 5개)
    for (int i = 0; i <= 4; i++) {
      final x = rect.left + (rect.width * i / 4);
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x, rect.bottom),
        paint,
      );
    }
  }

  void _drawTargetLine(Canvas canvas, Rect rect, double yMin, double yRange) {
    if (targetPitches.isEmpty) return;
    
    final paint = Paint()
      ..color = targetColor.withOpacity(0.7 * animationValue)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    bool pathStarted = false;
    
    for (int i = 0; i < targetPitches.length; i++) {
      final pitch = targetPitches[i];
      if (pitch <= 0) continue;
      
      final x = rect.left + (rect.width * i / (targetPitches.length - 1));
      final y = rect.bottom - ((pitch - yMin) / yRange) * rect.height;
      
      if (!pathStarted) {
        path.moveTo(x, y);
        pathStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  void _drawPitchLine(Canvas canvas, Rect rect, double yMin, double yRange) {
    final paint = Paint()
      ..color = pitchColor.withOpacity(animationValue)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    final path = Path();
    bool pathStarted = false;
    
    // 애니메이션에 따라 그려질 데이터 포인트 수 계산
    final animatedLength = (pitchData.length * animationValue).round();
    
    for (int i = 0; i < animatedLength; i++) {
      final pitch = pitchData[i];
      if (pitch <= 0) continue;
      
      final x = rect.left + (rect.width * i / (pitchData.length - 1));
      final y = rect.bottom - ((pitch - yMin) / yRange) * rect.height;
      
      if (!pathStarted) {
        path.moveTo(x, y);
        pathStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
    
    // 포인트 강조 (현재 위치)
    if (animatedLength > 0) {
      final currentIndex = (animatedLength - 1).clamp(0, pitchData.length - 1);
      final currentPitch = pitchData[currentIndex];
      
      if (currentPitch > 0) {
        final x = rect.left + (rect.width * currentIndex / (pitchData.length - 1));
        final y = rect.bottom - ((currentPitch - yMin) / yRange) * rect.height;
        
        final pointPaint = Paint()
          ..color = pitchColor
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(Offset(x, y), 4, pointPaint);
        
        // 하이라이트 링
        final ringPaint = Paint()
          ..color = pitchColor.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        
        canvas.drawCircle(Offset(x, y), 6, ringPaint);
      }
    }
  }

  void _drawTimeIndicator(Canvas canvas, Rect rect) {
    if (duration <= 0) return;
    
    final progress = currentTime / duration;
    final x = rect.left + (rect.width * progress);
    
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.8)
      ..strokeWidth = 2;
    
    canvas.drawLine(
      Offset(x, rect.top),
      Offset(x, rect.bottom),
      paint,
    );
    
    // 시간 인디케이터 상단 마커
    final markerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    final markerPath = Path();
    markerPath.moveTo(x - 4, rect.top);
    markerPath.lineTo(x + 4, rect.top);
    markerPath.lineTo(x, rect.top + 8);
    markerPath.close();
    
    canvas.drawPath(markerPath, markerPaint);
  }

  void _drawYAxisLabels(Canvas canvas, Rect rect, double yMin, double yMax) {
    const labelCount = 5;
    
    for (int i = 0; i < labelCount; i++) {
      final pitch = yMin + ((yMax - yMin) * (labelCount - 1 - i) / (labelCount - 1));
      final y = rect.top + (rect.height * i / (labelCount - 1));
      
      // 주파수를 MIDI 노트로 변환
      final midi = 69 + 12 * (math.log(pitch / 440) / math.ln2);
      final noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
      final octave = ((midi - 12) / 12).floor();
      final noteIndex = (midi.round() % 12);
      final noteName = '${noteNames[noteIndex]}$octave';
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$noteName\n${pitch.toStringAsFixed(0)}Hz',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.right + 8, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(PitchGraphPainter oldDelegate) {
    return oldDelegate.pitchData != pitchData ||
           oldDelegate.targetPitches != targetPitches ||
           oldDelegate.currentTime != currentTime ||
           oldDelegate.duration != duration ||
           oldDelegate.animationValue != animationValue;
  }
}