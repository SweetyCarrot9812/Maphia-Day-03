import 'package:flutter/material.dart';
import 'dart:math' as math;

class AccuracyFeedbackWidget extends StatefulWidget {
  final double accuracy; // 정확도 (cents)
  final double stability; // 안정도 (cents)
  final String targetNote; // 목표 음
  final bool isActive; // 피드백 활성화 여부
  final VoidCallback? onAccuracyThresholdMet; // 임계점 달성 콜백
  
  const AccuracyFeedbackWidget({
    super.key,
    required this.accuracy,
    required this.stability,
    required this.targetNote,
    this.isActive = true,
    this.onAccuracyThresholdMet,
  });

  @override
  State<AccuracyFeedbackWidget> createState() => _AccuracyFeedbackWidgetState();
}

class _AccuracyFeedbackWidgetState extends State<AccuracyFeedbackWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _stabilityController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _stabilityAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _stabilityController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _stabilityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stabilityController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stabilityController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AccuracyFeedbackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive) {
      // 정확도에 따른 애니메이션 제어
      final accuracyLevel = _getAccuracyLevel();
      
      if (accuracyLevel == AccuracyLevel.excellent) {
        _pulseController.repeat(reverse: true);
        _stabilityController.forward();
        
        // 임계점 달성 콜백 호출
        if (oldWidget.accuracy.abs() > 20 && widget.accuracy.abs() <= 20) {
          widget.onAccuracyThresholdMet?.call();
        }
      } else {
        _pulseController.stop();
        _stabilityController.reverse();
      }
    } else {
      _pulseController.stop();
      _stabilityController.reset();
    }
  }

  AccuracyLevel _getAccuracyLevel() {
    final absAccuracy = widget.accuracy.abs();
    if (absAccuracy <= 10) return AccuracyLevel.excellent;
    if (absAccuracy <= 30) return AccuracyLevel.good;
    if (absAccuracy <= 50) return AccuracyLevel.fair;
    return AccuracyLevel.poor;
  }

  Color _getAccuracyColor() {
    switch (_getAccuracyLevel()) {
      case AccuracyLevel.excellent:
        return Colors.green;
      case AccuracyLevel.good:
        return Colors.lightGreen;
      case AccuracyLevel.fair:
        return Colors.orange;
      case AccuracyLevel.poor:
        return Colors.red;
    }
  }

  String _getAccuracyText() {
    switch (_getAccuracyLevel()) {
      case AccuracyLevel.excellent:
        return '완벽!';
      case AccuracyLevel.good:
        return '좋음';
      case AccuracyLevel.fair:
        return '보통';
      case AccuracyLevel.poor:
        return '조정 필요';
    }
  }

  String _getDirectionalFeedback() {
    if (widget.accuracy > 10) {
      return '↓ 낮춰주세요';
    } else if (widget.accuracy < -10) {
      return '↑ 높여주세요';
    } else {
      return '✓ 유지하세요';
    }
  }

  IconData _getStabilityIcon() {
    if (widget.stability <= 15) return Icons.radio_button_checked;
    if (widget.stability <= 30) return Icons.adjust;
    return Icons.blur_on;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    final accuracyColor = _getAccuracyColor();
    final accuracyText = _getAccuracyText();
    final directionalFeedback = _getDirectionalFeedback();

    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 목표 음과 정확도 상태
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '목표: ${widget.targetNote}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      directionalFeedback,
                      style: TextStyle(
                        color: accuracyColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accuracyColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accuracyColor,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          accuracyText,
                          style: TextStyle(
                            color: accuracyColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 정확도 바 시각화
            Row(
              children: [
                Icon(
                  Icons.my_location,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomPaint(
                    size: const Size(double.infinity, 24),
                    painter: AccuracyBarPainter(
                      accuracy: widget.accuracy,
                      color: accuracyColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.accuracy.toStringAsFixed(1)}¢',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: accuracyColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 안정도 표시
            AnimatedBuilder(
              animation: _stabilityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.3 + (_stabilityAnimation.value * 0.7),
                  child: Row(
                    children: [
                      Icon(
                        _getStabilityIcon(),
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '안정도: ${widget.stability.toStringAsFixed(1)}¢',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: math.max(0.0, math.min(1.0, 1.0 - (widget.stability / 50))),
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: widget.stability <= 15 
                                  ? Colors.green 
                                  : widget.stability <= 30 
                                      ? Colors.orange 
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AccuracyBarPainter extends CustomPainter {
  final double accuracy;
  final Color color;

  AccuracyBarPainter({
    required this.accuracy,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // 배경
    paint.color = Colors.grey.shade300;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      paint,
    );

    // 중심선
    final centerX = size.width / 2;
    paint.color = Colors.grey.shade600;
    paint.strokeWidth = 1;
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      paint,
    );

    // 정확도 표시 (센트를 픽셀로 변환)
    final maxCents = 100.0; // ±100센트 범위
    final accuracyX = centerX + (accuracy / maxCents) * (size.width / 2);
    final clampedX = math.max(0, math.min(size.width, accuracyX));

    // 정확도 바
    paint.color = color.withOpacity(0.7);
    final barRect = Rect.fromLTWH(
      math.min(centerX, clampedX).toDouble(),
      size.height * 0.25,
      (clampedX - centerX).abs().toDouble(),
      size.height * 0.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(4)),
      paint,
    );

    // 현재 위치 마커
    paint.color = color;
    paint.style = PaintingStyle.fill;
    final markerPath = Path();
    markerPath.moveTo((clampedX - 6).toDouble(), 0);
    markerPath.lineTo((clampedX + 6).toDouble(), 0);
    markerPath.lineTo(clampedX.toDouble(), (size.height * 0.8).toDouble());
    markerPath.close();
    canvas.drawPath(markerPath, paint);

    // 가이드 라인 (±50센트, ±25센트)
    paint.color = Colors.grey.shade500;
    paint.strokeWidth = 0.5;
    final markers = [-50, -25, 25, 50];
    for (final marker in markers) {
      final x = centerX + (marker / maxCents) * (size.width / 2);
      if (x >= 0 && x <= size.width) {
        canvas.drawLine(
          Offset(x, size.height * 0.8),
          Offset(x, size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(AccuracyBarPainter oldDelegate) {
    return oldDelegate.accuracy != accuracy || oldDelegate.color != color;
  }
}

enum AccuracyLevel {
  excellent, // ±10센트 이내
  good,      // ±30센트 이내
  fair,      // ±50센트 이내
  poor,      // ±50센트 초과
}