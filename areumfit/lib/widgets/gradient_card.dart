import 'package:flutter/material.dart';
import 'dart:ui';

class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GradientCard({
    super.key,
    required this.child,
    this.colors = const [Color(0xFF2AB1A2), Color(0xFF1A8A7D)],
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.borderRadius,
    this.padding = const EdgeInsets.all(16),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: child,
      ),
    );
  }
}

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double blur;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.blur = 10.0,
    this.borderRadius,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: border ??
            Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}