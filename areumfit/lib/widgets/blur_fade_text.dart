import 'package:flutter/material.dart';
import 'dart:ui';

class BlurFadeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration delay;
  final Duration duration;

  const BlurFadeText({
    super.key,
    required this.text,
    this.style,
    this.delay = const Duration(milliseconds: 0),
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<BlurFadeText> createState() => _BlurFadeTextState();
}

class _BlurFadeTextState extends State<BlurFadeText>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _blurAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    ));

    _blurAnimation = Tween<double>(
      begin: 20.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: _blurAnimation.value,
                sigmaY: _blurAnimation.value,
              ),
              child: Text(
                widget.text,
                style: widget.style,
              ),
            ),
          ),
        );
      },
    );
  }
}