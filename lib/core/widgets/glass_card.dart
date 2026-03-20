import 'dart:ui';

import 'package:flutter/material.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';

/// A frosted-glass morphism card using [BackdropFilter].
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.blur = 12,
    this.opacity = 0.15,
    this.borderRadius,
    this.padding,
    this.borderColor,
  });

  final Widget child;

  /// Blur sigma applied to the backdrop.
  final double blur;

  /// Opacity of the white (light) or dark (dark theme) fill.
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark
        ? Colors.white.withValues(alpha: opacity * 0.5)
        : Colors.white.withValues(alpha: opacity);
    final border = borderColor ??
        (isDark ? AppColors.glassBorderDark : AppColors.glassBorder);
    final radius = borderRadius ?? AppSpacing.borderRadiusLarge;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: radius,
            border: Border.all(color: border, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
