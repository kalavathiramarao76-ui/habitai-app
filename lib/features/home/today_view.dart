import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:habit_coach/core/design/app_spacing.dart';
import 'package:habit_coach/core/models/habit.dart';
import 'package:habit_coach/core/providers/habit_provider.dart';
import 'package:habit_coach/core/providers/user_provider.dart';
import 'package:habit_coach/core/utils/date_utils.dart';
import 'package:habit_coach/core/widgets/animated_progress_ring.dart';
import 'package:habit_coach/core/widgets/app_empty_state.dart';
import 'package:habit_coach/features/home/habit_list_card.dart';

class TodayView extends ConsumerWidget {
  const TodayView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayHabits = ref.watch(todayHabitsProvider);
    final stats = ref.watch(habitStatsProvider);
    final user = ref.watch(userProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final greeting = HabitDateUtils.getGreeting();
    final dateStr = HabitDateUtils.formatDateFull(DateTime.now());

    // Group habits by time of day
    final morningHabits = todayHabits
        .where((h) => h.timeOfDay == HabitTimeOfDay.morning)
        .toList();
    final afternoonHabits = todayHabits
        .where((h) => h.timeOfDay == HabitTimeOfDay.afternoon)
        .toList();
    final eveningHabits = todayHabits
        .where((h) => h.timeOfDay == HabitTimeOfDay.evening)
        .toList();
    final anytimeHabits = todayHabits
        .where((h) => h.timeOfDay == HabitTimeOfDay.anytime)
        .toList();

    return Scaffold(
      body: todayHabits.isEmpty
          ? RefreshIndicator(
              onRefresh: () async {
                ref.read(habitsProvider.notifier).loadHabits();
              },
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: AppEmptyState(
                      emoji: '\u{1F331}',
                      title: 'No habits yet',
                      description:
                          'Start building better habits today.\nTap the + button to create your first habit.',
                      actionLabel: 'Add Habit',
                      onAction: () => context.push('/add-habit'),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(habitsProvider.notifier).loadHabits();
              },
              child: ListView(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + AppSpacing.md,
                  bottom: 100,
                ),
                children: [
                  // Greeting & date
                  Padding(
                    padding: AppSpacing.screenPaddingHorizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting, ${user.name}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSpacing.vGap4,
                        Text(
                          dateStr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.vGap24,

                  // Progress ring
                  Center(
                    child: AnimatedProgressRing(
                      progress: stats.todayProgress,
                      size: 140,
                      strokeWidth: 12,
                      showGlow: true,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${stats.todayCompleted}',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                          Text(
                            'of ${stats.todayTotal}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSpacing.vGap24,

                  // Habit sections
                  if (morningHabits.isNotEmpty)
                    _HabitSection(
                      label: '\u{2600}\u{FE0F}  Morning',
                      habits: morningHabits,
                    ),
                  if (afternoonHabits.isNotEmpty)
                    _HabitSection(
                      label: '\u{1F324}\u{FE0F}  Afternoon',
                      habits: afternoonHabits,
                    ),
                  if (eveningHabits.isNotEmpty)
                    _HabitSection(
                      label: '\u{1F319}  Evening',
                      habits: eveningHabits,
                    ),
                  if (anytimeHabits.isNotEmpty)
                    _HabitSection(
                      label: '\u{1F552}  Anytime',
                      habits: anytimeHabits,
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-habit'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _HabitSection extends StatelessWidget {
  const _HabitSection({
    required this.label,
    required this.habits,
  });

  final String label;
  final List<Habit> habits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ...habits.map((habit) => HabitListCard(habit: habit)),
        AppSpacing.vGap8,
      ],
    );
  }
}
