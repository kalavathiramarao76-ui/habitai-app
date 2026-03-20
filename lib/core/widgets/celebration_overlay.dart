import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/app_colors.dart';

/// Shows a confetti burst overlay that auto-dismisses.
///
/// Usage:
/// ```dart
/// CelebrationOverlay.show(context);
/// ```
class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({super.key});

  /// Trigger the celebration overlay on top of the current route.
  static void show(BuildContext context, {Duration duration = const Duration(seconds: 2)}) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _AutoDismiss(
        duration: duration,
        onDismiss: () => entry.remove(),
        child: const CelebrationOverlay(),
      ),
    );
    overlay.insert(entry);
  }

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  static const int _particleCount = 80;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    final rng = math.Random();
    _particles = List.generate(_particleCount, (_) => _Particle(rng));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: MediaQuery.sizeOf(context),
            painter: _ConfettiPainter(
              particles: _particles,
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

/// Wraps a child and removes itself after [duration].
class _AutoDismiss extends StatefulWidget {
  const _AutoDismiss({
    required this.duration,
    required this.onDismiss,
    required this.child,
  });

  final Duration duration;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  State<_AutoDismiss> createState() => _AutoDismissState();
}

class _AutoDismissState extends State<_AutoDismiss> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ── Particle data ────────────────────────────────────────────────────────────

class _Particle {
  _Particle(math.Random rng)
      : x = rng.nextDouble(),
        startY = -0.05 - rng.nextDouble() * 0.1,
        speed = 0.4 + rng.nextDouble() * 0.8,
        drift = (rng.nextDouble() - 0.5) * 0.3,
        size = 4 + rng.nextDouble() * 6,
        rotation = rng.nextDouble() * math.pi * 2,
        rotationSpeed = (rng.nextDouble() - 0.5) * 6,
        color = _confettiColors[rng.nextInt(_confettiColors.length)];

  final double x;
  final double startY;
  final double speed;
  final double drift;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final Color color;

  static const List<Color> _confettiColors = [
    AppColors.primaryIndigo,
    Color(0xFFF43F5E),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF0EA5E9),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFFFF6B35),
  ];
}

// ── Painter ──────────────────────────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final t = progress;
      final opacity = (1.0 - t).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final px = (p.x + p.drift * t) * size.width;
      final py = (p.startY + p.speed * t) * size.height;

      if (py > size.height || py < -20) continue;

      paint.color = p.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation + p.rotationSpeed * t);

      // Draw a small rectangle as confetti piece
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
