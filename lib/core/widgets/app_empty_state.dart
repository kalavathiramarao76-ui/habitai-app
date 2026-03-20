import 'package:flutter/material.dart';

import '../design/app_spacing.dart';

/// A centered empty-state placeholder with icon, title, description and
/// optional action button.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    this.icon,
    this.emoji,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  }) : assert(
         icon != null || emoji != null,
         'Provide either an icon or an emoji.',
       );

  /// Material icon displayed at the top.
  final IconData? icon;

  /// Emoji string displayed at the top (takes priority over [icon] visually).
  final String? emoji;

  final String title;
  final String? description;

  /// Label for the optional CTA button.
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null)
              Text(emoji!, style: const TextStyle(fontSize: 56))
            else if (icon != null)
              Icon(icon!, size: 56, color: cs.onSurfaceVariant),
            AppSpacing.vGap16,
            Text(
              title,
              style: tt.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              AppSpacing.vGap8,
              Text(
                description!,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.vGap24,
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
