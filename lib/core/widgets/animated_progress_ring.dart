import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A circular progress ring with gradient stroke, animated fill, optional glow,
/// and a center widget slot.
class AnimatedProgressRing extends StatelessWidget {
  const AnimatedProgressRing({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 8,
    this.gradientColors,
    this.trackColor,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
    this.center,
    this.showGlow = false,
  });

  /// Value between 0.0 and 1.0.
  final double progress;
  final double size;
  final double strokeWidth;

  /// Gradient applied to the progress arc. Falls back to primary color.
  final List<Color>? gradientColors;

  /// Background track color. Falls back to surfaceContainerHighest.
  final Color? trackColor;
  final Duration duration;
  final Curve curve;

  /// Widget rendered in the centre of the ring.
  final Widget? center;

  /// If true, a soft coloured glow is drawn behind the ring.
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = gradientColors ?? [cs.primary, cs.tertiary];
    final track = trackColor ?? cs.surfaceContainerHighest;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (showGlow)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.first.withValues(alpha: 0.25 * value),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(
                  progress: value,
                  strokeWidth: strokeWidth,
                  trackColor: track,
                  gradientColors: colors,
                ),
              ),
              ?child,
            ],
          ),
        );
      },
      child: center,
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.gradientColors,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final List<Color> gradientColors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Progress arc
    final sweepAngle = 2 * math.pi * progress;
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi,
      colors: gradientColors,
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.trackColor != trackColor;
}
