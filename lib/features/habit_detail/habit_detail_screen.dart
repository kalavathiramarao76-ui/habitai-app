import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:habit_coach/core/design/app_spacing.dart';
import 'package:habit_coach/core/models/habit.dart';
import 'package:habit_coach/core/providers/habit_provider.dart';
import 'package:habit_coach/core/utils/date_utils.dart';
import 'package:habit_coach/core/widgets/animated_counter.dart';
import 'package:habit_coach/core/widgets/app_button.dart';
import 'package:habit_coach/core/widgets/app_card.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Habit? _findHabit() {
    final habits = ref.watch(habitsProvider);
    final matches = habits.where((h) => h.id == widget.habitId);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final habit = _findHabit();
    if (habit == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Habit not found')),
      );
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final habitColor = Color(habit.colorValue);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(habit.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(value, habit),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'archive', child: Text('Archive')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Section ──────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: habitColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      habit.icon,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  AppSpacing.vGap12,
                  Text(
                    habit.name,
                    style: theme.textTheme.headlineMedium,
                  ),
                  AppSpacing.vGap4,
                  Text(
                    'Created ${HabitDateUtils.formatDate(habit.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.vGap24,

            // ── Stat Cards ───────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Current',
                    value: habit.currentStreak,
                    suffix: ' days',
                    color: habitColor,
                  ),
                ),
                AppSpacing.hGap8,
                Expanded(
                  child: _StatCard(
                    label: 'Best',
                    value: habit.bestStreak,
                    suffix: ' days',
                    color: habitColor,
                  ),
                ),
                AppSpacing.hGap8,
                Expanded(
                  child: _StatCard(
                    label: 'Total',
                    value: habit.completedDates.values
                        .where((c) => c.completed)
                        .length,
                    suffix: '',
                    color: habitColor,
                  ),
                ),
              ],
            ),

            AppSpacing.vGap24,

            // ── Calendar Heatmap ─────────────────────────────────
            Text('Last 12 Weeks', style: theme.textTheme.titleMedium),
            AppSpacing.vGap12,
            _CalendarHeatmap(habit: habit, habitColor: habitColor),

            AppSpacing.vGap24,

            // ── Completion Rate Chart ────────────────────────────
            Text('Last 30 Days', style: theme.textTheme.titleMedium),
            AppSpacing.vGap12,
            SizedBox(
              height: 180,
              child: _CompletionChart(habit: habit, habitColor: habitColor),
            ),

            AppSpacing.vGap24,

            // ── Insights ─────────────────────────────────────────
            Text('Insights', style: theme.textTheme.titleMedium),
            AppSpacing.vGap12,
            _InsightsSection(habit: habit),

            AppSpacing.vGap24,

            // ── Actions ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Edit',
                    variant: AppButtonVariant.secondary,
                    leadingIcon: Icons.edit_rounded,
                    onPressed: () => _handleAction('edit', habit),
                  ),
                ),
                AppSpacing.hGap8,
                Expanded(
                  child: AppButton(
                    label: 'Archive',
                    variant: AppButtonVariant.secondary,
                    leadingIcon: Icons.archive_rounded,
                    onPressed: () => _handleAction('archive', habit),
                  ),
                ),
                AppSpacing.hGap8,
                Expanded(
                  child: AppButton(
                    label: 'Delete',
                    variant: AppButtonVariant.destructive,
                    leadingIcon: Icons.delete_rounded,
                    onPressed: () => _handleAction('delete', habit),
                  ),
                ),
              ],
            ),

            AppSpacing.vGap24,

            // ── Notes Section ────────────────────────────────────
            Text('Notes', style: theme.textTheme.titleMedium),
            AppSpacing.vGap12,
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: 'Add a note for today...',
                    ),
                  ),
                ),
                AppSpacing.hGap8,
                IconButton.filled(
                  onPressed: () {
                    final text = _noteController.text.trim();
                    if (text.isEmpty) return;
                    ref
                        .read(habitsProvider.notifier)
                        .addNote(habit.id, DateTime.now(), text);
                    _noteController.clear();
                  },
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
            AppSpacing.vGap12,
            _RecentNotes(habit: habit),
            AppSpacing.vGap32,
          ],
        ),
      ),
    );
  }

  void _handleAction(String action, Habit habit) {
    switch (action) {
      case 'edit':
        context.push('/add-habit');
        break;
      case 'archive':
        ref.read(habitsProvider.notifier).updateHabit(
              habit.copyWith(isArchived: true),
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Habit archived')),
          );
          context.pop();
        }
        break;
      case 'delete':
        _showDeleteDialog(habit);
        break;
    }
  }

  void _showDeleteDialog(Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Habit?'),
        content: Text(
          'Are you sure you want to delete "${habit.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(habitsProvider.notifier).deleteHabit(habit.id);
              if (mounted) context.pop();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.color,
  });

  final String label;
  final int value;
  final String suffix;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      variant: AppCardVariant.outlined,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          AnimatedCounter(
            value: value,
            suffix: suffix,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Calendar Heatmap ─────────────────────────────────────────────────────────

class _CalendarHeatmap extends StatelessWidget {
  const _CalendarHeatmap({required this.habit, required this.habitColor});

  final Habit habit;
  final Color habitColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Go back 12 weeks (84 days)
    final startDate = today.subtract(const Duration(days: 83));

    // Build grid: 7 rows (days of week) x 12 columns (weeks)
    return Column(
      children: [
        SizedBox(
          height: 7 * 18.0,
          child: Row(
            children: List.generate(12, (weekIndex) {
              return Expanded(
                child: Column(
                  children: List.generate(7, (dayIndex) {
                    final dayOffset = weekIndex * 7 + dayIndex;
                    final date = startDate.add(Duration(days: dayOffset));
                    if (date.isAfter(today)) {
                      return const SizedBox(height: 18);
                    }
                    final completed = habit.isCompletedOn(date);
                    return Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: completed
                            ? habitColor
                            : cs.surfaceContainerHighest,
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Completion Chart ─────────────────────────────────────────────────────────

class _CompletionChart extends StatelessWidget {
  const _CompletionChart({required this.habit, required this.habitColor});

  final Habit habit;
  final Color habitColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final spots = <FlSpot>[];
    for (int i = 29; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final completed = habit.isCompletedOn(date) ? 1.0 : 0.0;
      spots.add(FlSpot((29 - i).toDouble(), completed));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 7,
              getTitlesWidget: (value, meta) {
                final dayIndex = value.toInt();
                if (dayIndex < 0 || dayIndex > 29) {
                  return const SizedBox.shrink();
                }
                final date = today.subtract(Duration(days: 29 - dayIndex));
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat.MMMd().format(date),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            preventCurveOverShooting: true,
            color: habitColor,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: habitColor.withValues(alpha: 0.15),
            ),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}

// ── Insights Section ─────────────────────────────────────────────────────────

class _InsightsSection extends StatelessWidget {
  const _InsightsSection({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    // Completion rate
    final rate = habit.completionRate(30);
    final ratePercent = (rate * 100).round();

    // Best day of week
    final dayCounts = <int, int>{};
    for (final entry in habit.completedDates.entries) {
      if (!entry.value.completed) continue;
      final weekday = entry.value.timestamp.weekday;
      dayCounts[weekday] = (dayCounts[weekday] ?? 0) + 1;
    }
    String bestDay = 'N/A';
    if (dayCounts.isNotEmpty) {
      final bestWeekday =
          dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      bestDay = DateFormat.EEEE().format(
        DateTime(2024, 1, bestWeekday), // 2024-01-01 is Monday
      );
    }

    // Most common hour
    final hourCounts = <int, int>{};
    for (final completion in habit.completedDates.values) {
      if (!completion.completed) continue;
      final hour = completion.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    String commonTime = 'N/A';
    if (hourCounts.isNotEmpty) {
      final bestHour =
          hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      if (bestHour < 12) {
        commonTime = '${bestHour == 0 ? 12 : bestHour} AM';
      } else {
        commonTime = '${bestHour == 12 ? 12 : bestHour - 12} PM';
      }
    }

    return AppCard(
      variant: AppCardVariant.filled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InsightRow(
            icon: Icons.schedule_rounded,
            text: 'You usually complete this around $commonTime',
          ),
          AppSpacing.vGap8,
          _InsightRow(
            icon: Icons.calendar_today_rounded,
            text: 'Best day: $bestDay',
          ),
          AppSpacing.vGap8,
          _InsightRow(
            icon: Icons.trending_up_rounded,
            text: 'Completion rate: $ratePercent% in the last 30 days',
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        AppSpacing.hGap8,
        Expanded(
          child: Text(text, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}

// ── Recent Notes ─────────────────────────────────────────────────────────────

class _RecentNotes extends StatelessWidget {
  const _RecentNotes({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (habit.notes.isEmpty) {
      return Text(
        'No notes yet',
        style: theme.textTheme.bodySmall?.copyWith(
          color: cs.onSurfaceVariant,
        ),
      );
    }

    // Sort by date descending, take last 5
    final sorted = habit.notes.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    final recent = sorted.take(5);

    return Column(
      children: recent.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Text(entry.value, style: theme.textTheme.bodySmall),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
