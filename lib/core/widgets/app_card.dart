import 'package:flutter/material.dart';

import '../design/app_spacing.dart';
import '../design/app_theme.dart';

/// Card variant.
enum AppCardVariant { elevated, filled, outlined }

/// A themed card with optional tap, press-scale animation, and variant styles.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.color,
  });

  final Widget child;
  final AppCardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? color;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
  }

  void _handleTapCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = widget.borderRadius ?? AppSpacing.borderRadiusLarge;

    Color bg;
    BoxBorder? border;
    List<BoxShadow>? shadow;

    switch (widget.variant) {
      case AppCardVariant.elevated:
        bg = widget.color ?? cs.surface;
        shadow = [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
        break;
      case AppCardVariant.filled:
        bg = widget.color ?? cs.surfaceContainerHighest;
        break;
      case AppCardVariant.outlined:
        bg = widget.color ?? cs.surface;
        border = Border.all(color: cs.outlineVariant, width: 1);
        break;
    }

    final double scale = _pressed ? 0.98 : 1.0;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: scale,
        duration: AppDurations.fast,
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: widget.padding ?? AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: border,
            boxShadow: shadow,
          ),
          child: widget.onTap != null
              ? Material(
                  color: Colors.transparent,
                  child: widget.child,
                )
              : widget.child,
        ),
      ),
    );
  }
}
