import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBeam extends StatefulWidget {
  final Widget child;
  final Color beamColor;
  final Duration duration;
  final double beamWidth;
  final bool continuous;

  const AnimatedBeam({
    super.key,
    required this.child,
    this.beamColor = Colors.blue,
    this.duration = const Duration(seconds: 2),
    this.beamWidth = 100.0,
    this.continuous = true,
  });

  @override
  State<AnimatedBeam> createState() => _AnimatedBeamState();
}

class _AnimatedBeamState extends State<AnimatedBeam>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    if (widget.continuous) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipRect(
          child: CustomPaint(
            painter: BeamPainter(
              progress: _animation.value,
              color: widget.beamColor,
              beamWidth: widget.beamWidth,
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class BeamPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double beamWidth;

  BeamPainter({
    required this.progress,
    required this.color,
    required this.beamWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.8),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, beamWidth, size.height));

    final beamRect = Rect.fromLTWH(
      (size.width + beamWidth) * progress - beamWidth,
      0,
      beamWidth,
      size.height,
    );

    canvas.drawRect(beamRect, paint);
  }

  @override
  bool shouldRepaint(covariant BeamPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.beamWidth != beamWidth;
  }
}

// Beam Border Widget for cards
class BeamBorder extends StatefulWidget {
  final Widget child;
  final Color borderColor;
  final double borderWidth;
  final Duration duration;

  const BeamBorder({
    super.key,
    required this.child,
    this.borderColor = Colors.teal,
    this.borderWidth = 2.0,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<BeamBorder> createState() => _BeamBorderState();
}

class _BeamBorderState extends State<BeamBorder>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: BeamBorderPainter(
            progress: _animation.value,
            color: widget.borderColor,
            borderWidth: widget.borderWidth,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class BeamBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double borderWidth;

  BeamBorderPainter({
    required this.progress,
    required this.color,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Create path for the border
    final path = Path()..addRRect(rrect);
    
    final pathMetrics = path.computeMetrics();
    final pathMetric = pathMetrics.first;
    final totalLength = pathMetric.length;
    
    // Calculate the current position along the path
    final currentLength = totalLength * progress;
    const beamLength = 50.0;
    
    // Create gradient along the beam
    final startLength = math.max(0.0, currentLength - beamLength);
    final endLength = math.min(totalLength, currentLength);
    
    if (endLength > startLength) {
      final subPath = pathMetric.extractPath(startLength, endLength);
      
      // Create gradient effect
      paint.shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.8),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);
      
      canvas.drawPath(subPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BeamBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
