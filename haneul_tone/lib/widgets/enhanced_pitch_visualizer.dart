import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 고급 피치 시각화 위젯
/// 색상 기반 정확도 표시, 실시간 피드백, 부드러운 애니메이션
class EnhancedPitchVisualizer extends StatefulWidget {
  final double currentFrequency;
  final double targetFrequency;
  final String currentNote;
  final double cents; // 음정 오차 (-50 ~ +50)
  final double confidence; // 0.0 ~ 1.0
  final List<double> frequencyHistory;
  final bool isRecording;
  
  const EnhancedPitchVisualizer({
    super.key,
    required this.currentFrequency,
    required this.targetFrequency,
    required this.currentNote,
    required this.cents,
    required this.confidence,
    required this.frequencyHistory,
    required this.isRecording,
  });

  @override
  State<EnhancedPitchVisualizer> createState() => _EnhancedPitchVisualizerState();
}

class _EnhancedPitchVisualizerState extends State<EnhancedPitchVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _needleController;
  late AnimationController _confidenceController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _needleAnimation;
  late Animation<double> _confidenceAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _needleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _confidenceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _needleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _needleController,
      curve: Curves.easeOutCubic,
    ));
    
    _confidenceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confidenceController,
      curve: Curves.easeOut,
    ));

    if (widget.isRecording) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(EnhancedPitchVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
    
    if (widget.currentFrequency != oldWidget.currentFrequency) {
      _needleController.reset();
      _needleController.forward();
    }
    
    if (widget.confidence != oldWidget.confidence) {
      _confidenceController.reset();
      _confidenceController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _needleController.dispose();
    _confidenceController.dispose();
    super.dispose();
  }

  Color _getAccuracyColor(double cents) {
    final absError = cents.abs();
    
    if (absError <= 5) {
      return Colors.green; // 매우 정확
    } else if (absError <= 10) {
      return Colors.lightGreen; // 정확
    } else if (absError <= 20) {
      return Colors.yellow; // 보통
    } else if (absError <= 35) {
      return Colors.orange; // 부정확
    } else {
      return Colors.red; // 매우 부정확
    }
  }

  String _getAccuracyText(double cents) {
    final absError = cents.abs();
    
    if (absError <= 5) {
      return '완벽!';
    } else if (absError <= 10) {
      return '훌륭';
    } else if (absError <= 20) {
      return '좋음';
    } else if (absError <= 35) {
      return '보통';
    } else {
      return '개선 필요';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 메인 피치 미터
          _buildMainPitchMeter(),
          
          const SizedBox(height: 20),
          
          // 현재 음표 및 주파수 표시
          _buildCurrentNoteDisplay(),
          
          const SizedBox(height: 20),
          
          // 정확도 및 피드백
          _buildAccuracyFeedback(),
          
          const SizedBox(height: 20),
          
          // 주파수 히스토리 그래프
          if (widget.frequencyHistory.isNotEmpty)
            _buildFrequencyHistory(),
        ],
      ),
    );
  }

  Widget _buildMainPitchMeter() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isRecording ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 300,
            height: 300,
            child: CustomPaint(
              painter: PitchMeterPainter(
                cents: widget.cents,
                confidence: widget.confidence,
                color: _getAccuracyColor(widget.cents),
                isRecording: widget.isRecording,
                needleProgress: _needleAnimation.value,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentNoteDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getAccuracyColor(widget.cents).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getAccuracyColor(widget.cents),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.currentNote.isEmpty ? '---' : widget.currentNote,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _getAccuracyColor(widget.cents),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.currentFrequency.toStringAsFixed(1)} Hz',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.cents >= 0 ? '+' : ''}${widget.cents.toStringAsFixed(0)} cents',
            style: TextStyle(
              fontSize: 16,
              color: _getAccuracyColor(widget.cents),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyFeedback() {
    return AnimatedBuilder(
      animation: _confidenceAnimation,
      builder: (context, child) {
        return Column(
          children: [
            // 정확도 상태
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _getAccuracyColor(widget.cents),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getAccuracyText(widget.cents),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 신뢰도 바
            Text(
              '신뢰도: ${(widget.confidence * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              width: 200,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                widthFactor: widget.confidence * _confidenceAnimation.value,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.confidence > 0.7 ? Colors.green : 
                           widget.confidence > 0.4 ? Colors.orange : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFrequencyHistory() {
    return Container(
      height: 80,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: CustomPaint(
        painter: FrequencyHistoryPainter(
          frequencies: widget.frequencyHistory,
          targetFrequency: widget.targetFrequency,
        ),
      ),
    );
  }
}

class PitchMeterPainter extends CustomPainter {
  final double cents;
  final double confidence;
  final Color color;
  final bool isRecording;
  final double needleProgress;

  PitchMeterPainter({
    required this.cents,
    required this.confidence,
    required this.color,
    required this.isRecording,
    required this.needleProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // 배경 원
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    
    canvas.drawCircle(center, radius, backgroundPaint);

    // 정확도 구간 표시 (색상별)
    _drawAccuracyRanges(canvas, center, radius);

    // 센트 눈금 표시
    _drawCentMarks(canvas, center, radius);

    // 바늘 (현재 피치)
    _drawNeedle(canvas, center, radius);
    
    // 중심점
    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 8, centerPaint);
  }

  void _drawAccuracyRanges(Canvas canvas, Offset center, double radius) {
    final strokeWidth = 8.0;
    
    // 매우 정확 (±5 cents) - 녹색
    _drawArc(canvas, center, radius, -5, 5, Colors.green.withOpacity(0.3), strokeWidth);
    
    // 정확 (±10 cents) - 밝은 녹색
    _drawArc(canvas, center, radius, -10, -5, Colors.lightGreen.withOpacity(0.3), strokeWidth);
    _drawArc(canvas, center, radius, 5, 10, Colors.lightGreen.withOpacity(0.3), strokeWidth);
    
    // 보통 (±20 cents) - 노란색
    _drawArc(canvas, center, radius, -20, -10, Colors.yellow.withOpacity(0.3), strokeWidth);
    _drawArc(canvas, center, radius, 10, 20, Colors.yellow.withOpacity(0.3), strokeWidth);
    
    // 부정확 (±35 cents) - 주황색
    _drawArc(canvas, center, radius, -35, -20, Colors.orange.withOpacity(0.3), strokeWidth);
    _drawArc(canvas, center, radius, 20, 35, Colors.orange.withOpacity(0.3), strokeWidth);
    
    // 매우 부정확 (±50 cents) - 빨간색
    _drawArc(canvas, center, radius, -50, -35, Colors.red.withOpacity(0.3), strokeWidth);
    _drawArc(canvas, center, radius, 35, 50, Colors.red.withOpacity(0.3), strokeWidth);
  }

  void _drawArc(Canvas canvas, Offset center, double radius, double startCents, double endCents, Color color, double strokeWidth) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    
    final startAngle = _centsToAngle(startCents);
    final sweepAngle = _centsToAngle(endCents) - startAngle;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  void _drawCentMarks(Canvas canvas, Offset center, double radius) {
    final markPaint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 2;
    
    final textStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );

    // 주요 센트 마크 (-50, -25, 0, +25, +50)
    for (final cents in [-50, -25, 0, 25, 50]) {
      final angle = _centsToAngle(cents.toDouble());
      final startX = center.dx + (radius - 15) * math.cos(angle);
      final startY = center.dy + (radius - 15) * math.sin(angle);
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), markPaint);
      
      // 레이블
      final textPainter = TextPainter(
        text: TextSpan(text: '${cents >= 0 ? '+' : ''}$cents', style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      final labelX = center.dx + (radius + 25) * math.cos(angle) - textPainter.width / 2;
      final labelY = center.dy + (radius + 25) * math.sin(angle) - textPainter.height / 2;
      
      textPainter.paint(canvas, Offset(labelX, labelY));
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    final clampedCents = cents.clamp(-50.0, 50.0);
    final angle = _centsToAngle(clampedCents);
    
    final needlePaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    final needleLength = (radius - 20) * needleProgress;
    final endX = center.dx + needleLength * math.cos(angle);
    final endY = center.dy + needleLength * math.sin(angle);
    
    canvas.drawLine(center, Offset(endX, endY), needlePaint);
    
    // 바늘 끝 점
    final tipPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(endX, endY), 6, tipPaint);
  }

  double _centsToAngle(double cents) {
    // -50~+50 센트를 -π/2 ~ +π/2 각도로 변환 (상단이 0)
    return (cents / 100.0 * math.pi) - math.pi / 2;
  }

  @override
  bool shouldRepaint(covariant PitchMeterPainter oldDelegate) {
    return cents != oldDelegate.cents ||
           confidence != oldDelegate.confidence ||
           color != oldDelegate.color ||
           isRecording != oldDelegate.isRecording ||
           needleProgress != oldDelegate.needleProgress;
  }
}

class FrequencyHistoryPainter extends CustomPainter {
  final List<double> frequencies;
  final double targetFrequency;

  FrequencyHistoryPainter({
    required this.frequencies,
    required this.targetFrequency,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (frequencies.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final targetPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // 주파수 범위 계산
    final minFreq = frequencies.reduce(math.min) - 10;
    final maxFreq = frequencies.reduce(math.max) + 10;
    final freqRange = maxFreq - minFreq;

    // 타겟 주파수 라인
    if (targetFrequency > 0) {
      final targetY = size.height - (targetFrequency - minFreq) / freqRange * size.height;
      canvas.drawLine(
        Offset(0, targetY),
        Offset(size.width, targetY),
        targetPaint,
      );
    }

    // 주파수 히스토리 곡선
    final path = Path();
    for (int i = 0; i < frequencies.length; i++) {
      final x = i / (frequencies.length - 1) * size.width;
      final y = size.height - (frequencies[i] - minFreq) / freqRange * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant FrequencyHistoryPainter oldDelegate) {
    return frequencies != oldDelegate.frequencies ||
           targetFrequency != oldDelegate.targetFrequency;
  }
}