import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_coach/core/design/app_spacing.dart';
import 'package:habit_coach/core/design/app_theme.dart';
import 'package:habit_coach/core/models/habit.dart';
import 'package:habit_coach/core/providers/habit_provider.dart';

class HabitListCard extends ConsumerStatefulWidget {
  const HabitListCard({super.key, required this.habit});

  final Habit habit;

  @override
  ConsumerState<HabitListCard> createState() => _HabitListCardState();
}

class _HabitListCardState extends ConsumerState<HabitListCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  bool get _isCompleted => widget.habit.isCompletedOn(DateTime.now());

  void _toggleCompletion() {
    HapticFeedback.mediumImpact();
    // Brief scale animation
    setState(() => _scale = 0.95);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _scale = 1.0);
    });
    ref
        .read(habitsProvider.notifier)
        .toggleCompletion(widget.habit.id, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final habit = widget.habit;
    final habitColor = Color(habit.colorValue);
    final streak = habit.currentStreak;

    return AnimatedScale(
      scale: _scale,
      duration: AppDurations.fast,
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: AppDurations.medium,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: _isCompleted
              ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
              : cs.surface,
          borderRadius: AppSpacing.borderRadiusLarge,
          border: Border.all(
            color: _isCompleted
                ? cs.outlineVariant.withValues(alpha: 0.3)
                : cs.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: _isCompleted
              ? null
              : [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppSpacing.borderRadiusLarge,
            onTap: _toggleCompletion,
            child: AnimatedOpacity(
              duration: AppDurations.medium,
              opacity: _isCompleted ? 0.6 : 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Emoji icon on colored circle
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: habitColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        habit.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    AppSpacing.hGap12,
                    // Name & streak
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: _isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            streak > 0
                                ? '\u{1F525} $streak day streak'
                                : 'Start today!',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: streak > 0
                                  ? const Color(0xFFFF6B35)
                                  : cs.onSurfaceVariant,
                              fontWeight: streak > 0
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Circular checkbox
                    GestureDetector(
                      onTap: _toggleCompletion,
                      child: AnimatedContainer(
                        duration: AppDurations.medium,
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isCompleted ? habitColor : Colors.transparent,
                          border: Border.all(
                            color:
                                _isCompleted ? habitColor : cs.outlineVariant,
                            width: 2,
                          ),
                        ),
                        child: _isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                size: 20,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
