import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 부상 위험도 인디케이터 위젯
/// 원형 게이지로 위험도를 시각적으로 표시
class InjuryRiskIndicator extends StatefulWidget {
  final double riskScore; // 0-100
  final double size;
  final bool showLabel;
  final bool animated;

  const InjuryRiskIndicator({
    super.key,
    required this.riskScore,
    this.size = 80,
    this.showLabel = true,
    this.animated = true,
  });

  @override
  State<InjuryRiskIndicator> createState() => _InjuryRiskIndicatorState();
}

class _InjuryRiskIndicatorState extends State<InjuryRiskIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.riskScore,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animated) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: widget.animated
          ? AnimatedBuilder(
              animation: _animation,
              builder: (context, child) => _buildIndicator(_animation.value),
            )
          : _buildIndicator(widget.riskScore),
    );
  }

  Widget _buildIndicator(double currentValue) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 원형 진행 인디케이터
        CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _RiskIndicatorPainter(
            riskScore: currentValue,
          ),
        ),
        
        // 중앙 텍스트
        if (widget.showLabel)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${currentValue.toInt()}%',
                style: TextStyle(
                  fontSize: widget.size * 0.15,
                  fontWeight: FontWeight.bold,
                  color: _getRiskColor(currentValue),
                ),
              ),
              Text(
                _getRiskLabel(currentValue),
                style: TextStyle(
                  fontSize: widget.size * 0.08,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Color _getRiskColor(double risk) {
    if (risk < 20) return Colors.green;
    if (risk < 40) return Colors.yellow[700]!;
    if (risk < 70) return Colors.orange;
    return Colors.red;
  }

  String _getRiskLabel(double risk) {
    if (risk < 20) return '안전';
    if (risk < 40) return '낮음';
    if (risk < 70) return '주의';
    return '위험';
  }
}

/// 위험도 인디케이터 커스텀 페인터
class _RiskIndicatorPainter extends CustomPainter {
  final double riskScore;
  
  _RiskIndicatorPainter({required this.riskScore});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    
    // 배경 원
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // 위험도에 따른 색상 그라데이션
    final colors = _getGradientColors(riskScore);
    final gradient = SweepGradient(
      colors: colors,
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + (2 * math.pi * riskScore / 100),
    );
    
    // 진행 호
    final progressPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = 2 * math.pi * riskScore / 100;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
    
    // 위험 구간 표시 (작은 마커들)
    _drawRiskMarkers(canvas, center, radius);
  }

  List<Color> _getGradientColors(double risk) {
    if (risk < 20) {
      return [Colors.green[300]!, Colors.green];
    } else if (risk < 40) {
      return [Colors.green, Colors.yellow[700]!];
    } else if (risk < 70) {
      return [Colors.yellow[700]!, Colors.orange];
    } else {
      return [Colors.orange, Colors.red];
    }
  }

  void _drawRiskMarkers(Canvas canvas, Offset center, double radius) {
    final markerPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    // 20%, 40%, 70% 지점에 마커 표시
    final markers = [20, 40, 70];
    
    for (final marker in markers) {
      final angle = -math.pi / 2 + (2 * math.pi * marker / 100);
      final markerRadius = 3.0;
      final markerCenter = Offset(
        center.dx + (radius + 6) * math.cos(angle),
        center.dy + (radius + 6) * math.sin(angle),
      );
      
      canvas.drawCircle(markerCenter, markerRadius, markerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}