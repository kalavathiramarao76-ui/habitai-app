import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/app_spacing.dart';
import '../design/app_theme.dart';

/// Button variant.
enum AppButtonVariant { primary, secondary, ghost, destructive }

/// Button size.
enum AppButtonSize { small, medium, large }

/// A themed button with variants, loading state, icon support, and haptic
/// feedback.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  /// If true the button stretches to fill the available width.
  final bool expand;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  double get _height {
    switch (widget.size) {
      case AppButtonSize.small:
        return 32;
      case AppButtonSize.medium:
        return 44;
      case AppButtonSize.large:
        return 52;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case AppButtonSize.small:
        return 13;
      case AppButtonSize.medium:
        return 14;
      case AppButtonSize.large:
        return 16;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 20;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 4);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
  }

  void _handleTapDown(TapDownDetails _) {
    if (!widget._enabled) return;
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
  }

  void _handleTapCancel() {
    setState(() => _pressed = false);
  }

  void _handleTap() {
    if (!widget._enabled) return;
    HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        bg = cs.primary;
        fg = cs.onPrimary;
        break;
      case AppButtonVariant.secondary:
        bg = Colors.transparent;
        fg = cs.primary;
        border = BorderSide(color: cs.outline, width: 1.5);
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = cs.primary;
        break;
      case AppButtonVariant.destructive:
        bg = cs.error;
        fg = cs.onError;
        break;
    }

    final double opacity = widget._enabled ? 1.0 : 0.5;
    final double scale = _pressed ? 0.97 : 1.0;

    Widget child;
    if (widget.isLoading) {
      child = SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: fg,
        ),
      );
    } else {
      final List<Widget> rowChildren = [];
      if (widget.leadingIcon != null) {
        rowChildren.add(Icon(widget.leadingIcon, size: _iconSize, color: fg));
        rowChildren.add(const SizedBox(width: 6));
      }
      rowChildren.add(
        Text(
          widget.label,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      );
      if (widget.trailingIcon != null) {
        rowChildren.add(const SizedBox(width: 6));
        rowChildren.add(
          Icon(widget.trailingIcon, size: _iconSize, color: fg),
        );
      }
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: rowChildren,
      );
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: AnimatedScale(
        scale: scale,
        duration: AppDurations.fast,
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: AppDurations.fast,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            height: _height,
            padding: _padding,
            constraints: widget.expand
                ? const BoxConstraints(minWidth: double.infinity)
                : null,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppSpacing.borderRadiusMedium,
              border: Border.fromBorderSide(border),
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
