import 'package:flutter/material.dart';

/// Smoothly animates between numeric values with a counting effect.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.fractionDigits = 0,
  });

  /// The target numeric value.
  final num value;
  final Duration duration;
  final Curve curve;
  final TextStyle? style;

  /// String placed before the number (e.g. "\u{1F525} ").
  final String prefix;

  /// String placed after the number (e.g. " days").
  final String suffix;

  /// Decimal places shown. Use 0 for integers.
  final int fractionDigits;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, _) {
        final String formatted;
        if (fractionDigits == 0) {
          formatted = animatedValue.round().toString();
        } else {
          formatted = animatedValue.toStringAsFixed(fractionDigits);
        }
        return Text(
          '$prefix$formatted$suffix',
          style: style ?? Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }
}
