import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:habit_coach/core/design/app_spacing.dart';
import 'package:habit_coach/core/design/app_theme.dart';
import 'package:habit_coach/core/models/habit.dart';
import 'package:habit_coach/core/providers/habit_provider.dart';
import 'package:habit_coach/core/services/ai_service.dart';
import 'package:habit_coach/core/widgets/animated_counter.dart';
import 'package:habit_coach/core/widgets/animated_progress_ring.dart';
import 'package:habit_coach/core/widgets/app_card.dart';
import 'package:habit_coach/core/widgets/app_empty_state.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final activeHabits =
        habits.where((h) => !h.isPaused && !h.isArchived).toList();

    if (activeHabits.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statistics')),
        body: const AppEmptyState(
          emoji: '\u{1F4CA}',
          title: 'No Data Yet',
          description:
              'Start tracking habits to see your statistics and analytics here.',
        ),
      );
    }

    final stats = ref.watch(habitStatsProvider);
    final weeklyScore = AiService().getWeeklyScore(habits);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Stat Cards ---
            _StatCardsRow(stats: stats, weeklyScore: weeklyScore),
            AppSpacing.vGap24,

            // --- Heatmap ---
            _SectionHeader(title: 'Streak Calendar'),
            AppSpacing.vGap8,
            _HeatmapSection(habits: activeHabits),
            AppSpacing.vGap24,

            // --- Weekly Chart ---
            _SectionHeader(title: 'Last 7 Days'),
            AppSpacing.vGap8,
            _WeeklyBarChart(habits: activeHabits),
            AppSpacing.vGap24,

            // --- Habit Rankings ---
            _SectionHeader(title: 'Most Consistent'),
            AppSpacing.vGap8,
            _HabitRankings(habits: activeHabits),
            AppSpacing.vGap16,
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Header
// ---------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

// ---------------------------------------------------------------------------
// Top stat cards – horizontal scroll
// ---------------------------------------------------------------------------
class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({required this.stats, required this.weeklyScore});
  final HabitStats stats;
  final int weeklyScore;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPaddingHorizontal,
        children: [
          _StatCard(
            label: 'Total Habits',
            child: AnimatedCounter(
              value: stats.totalHabits,
              style: tt.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
          ),
          AppSpacing.hGap12,
          _StatCard(
            label: 'Best Streak',
            child: AnimatedCounter(
              value: stats.bestStreak,
              prefix: '\u{1F525} ',
              style: tt.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
          ),
          AppSpacing.hGap12,
          _StatCard(
            label: 'Total Completions',
            child: AnimatedCounter(
              value: stats.totalCompletions,
              style: tt.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
          ),
          AppSpacing.hGap12,
          _StatCard(
            label: 'Weekly Score',
            child: SizedBox(
              width: 64,
              height: 64,
              child: AnimatedProgressRing(
                progress: weeklyScore / 100,
                size: 64,
                strokeWidth: 6,
                gradientColors: [cs.primary, cs.tertiary],
                center: Text(
                  '$weeklyScore',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Heatmap – 12-week grid (84 days)
// ---------------------------------------------------------------------------
class _HeatmapSection extends StatelessWidget {
  const _HeatmapSection({required this.habits});
  final List<Habit> habits;

  @override
  Widget build(BuildContext context) {
    final habitColors =
        Theme.of(context).extension<HabitThemeColors>() ?? HabitThemeColors.light;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    // Build a map: date-key -> count of habits completed
    final Map<String, int> completionCounts = {};
    for (final habit in habits) {
      for (final entry in habit.completedDates.entries) {
        if (entry.value.completed) {
          completionCounts[entry.key] = (completionCounts[entry.key] ?? 0) + 1;
        }
      }
    }

    // Calculate start date: go back 83 days from today, then align to Monday
    final rawStart = todayNorm.subtract(const Duration(days: 83));
    final daysToMonday = (rawStart.weekday - 1) % 7;
    final startDate = rawStart.subtract(Duration(days: daysToMonday));

    // Total days from startDate to today
    final totalDays = todayNorm.difference(startDate).inDays + 1;
    final numWeeks = (totalDays / 7).ceil();

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day labels column
                Column(
                  children: List.generate(7, (row) {
                    return SizedBox(
                      height: 16,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          dayLabels[row],
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                // Grid
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cellSize =
                          ((constraints.maxWidth - (numWeeks - 1) * 2) / numWeeks)
                              .clamp(8.0, 16.0);
                      final gap = 2.0;

                      return Wrap(
                        direction: Axis.vertical,
                        spacing: gap,
                        runSpacing: gap,
                        children: List.generate(numWeeks * 7, (index) {
                          final week = index ~/ 7;
                          final dayOfWeek = index % 7;
                          // Column-major: each "run" is a column (week)
                          // Wrap vertical means items go top-to-bottom, then next column
                          // But we want week columns left-to-right with rows Mon-Sun
                          // So we reorder: item at (week, dayOfWeek)
                          final date = startDate
                              .add(Duration(days: week * 7 + dayOfWeek));
                          final dateNorm =
                              DateTime(date.year, date.month, date.day);

                          if (dateNorm.isAfter(todayNorm)) {
                            return SizedBox(width: cellSize, height: cellSize);
                          }

                          final key =
                              '${dateNorm.year.toString().padLeft(4, '0')}-${dateNorm.month.toString().padLeft(2, '0')}-${dateNorm.day.toString().padLeft(2, '0')}';
                          final count = completionCounts[key] ?? 0;

                          Color cellColor;
                          if (count == 0) {
                            cellColor = habitColors.heatmapNone;
                          } else if (count <= 2) {
                            cellColor = habitColors.heatmapLight;
                          } else if (count <= 4) {
                            cellColor = habitColors.heatmapMedium;
                          } else {
                            cellColor = habitColors.heatmapMax;
                          }

                          final isToday = dateNorm == todayNorm;

                          return Container(
                            width: cellSize,
                            height: cellSize,
                            decoration: BoxDecoration(
                              color: cellColor,
                              borderRadius: BorderRadius.circular(3),
                              border: isToday
                                  ? Border.all(color: cs.primary, width: 1.5)
                                  : null,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ],
            ),
            AppSpacing.vGap8,
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Less', style: tt.labelSmall?.copyWith(fontSize: 10)),
                AppSpacing.hGap4,
                _LegendDot(color: habitColors.heatmapNone),
                _LegendDot(color: habitColors.heatmapLight),
                _LegendDot(color: habitColors.heatmapMedium),
                _LegendDot(color: habitColors.heatmapStrong),
                _LegendDot(color: habitColors.heatmapMax),
                AppSpacing.hGap4,
                Text('More', style: tt.labelSmall?.copyWith(fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weekly Bar Chart – Last 7 days
// ---------------------------------------------------------------------------
class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.habits});
  final List<Habit> habits;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final today = DateTime.now();
    // Calculate data for each of the last 7 days
    final List<_DayData> days = [];
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      int count = 0;
      for (final habit in habits) {
        if (habit.isCompletedOn(date)) count++;
      }
      days.add(_DayData(
        date: date,
        count: count,
        isToday: i == 0,
      ));
    }

    final maxY = days
        .fold<int>(0, (max, d) => d.count > max ? d.count : max)
        .toDouble();
    final chartMax = maxY < 1 ? 1.0 : maxY + 1;

    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: chartMax,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.round()} done',
                      TextStyle(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= days.length) {
                        return const SizedBox.shrink();
                      }
                      final dayName =
                          DateFormat.E().format(days[idx].date).substring(0, 3);
                      final isToday = days[idx].isToday;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          dayName,
                          style: tt.labelSmall?.copyWith(
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday
                                ? cs.primary
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      if (value == value.roundToDouble() && value >= 0) {
                        return Text(
                          value.round().toString(),
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: cs.outlineVariant.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(days.length, (i) {
                final d = days[i];
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: d.count.toDouble(),
                      width: 24,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      color: d.isToday
                          ? cs.primary
                          : cs.primary.withValues(alpha: 0.5),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayData {
  const _DayData({
    required this.date,
    required this.count,
    required this.isToday,
  });
  final DateTime date;
  final int count;
  final bool isToday;
}

// ---------------------------------------------------------------------------
// Habit Rankings
// ---------------------------------------------------------------------------
class _HabitRankings extends StatelessWidget {
  const _HabitRankings({required this.habits});
  final List<Habit> habits;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Sort by 30-day completion rate descending
    final sorted = List<Habit>.from(habits)
      ..sort((a, b) => b.completionRate(30).compareTo(a.completionRate(30)));

    const medals = ['\u{1F947}', '\u{1F948}', '\u{1F949}'];

    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: Column(
        children: List.generate(sorted.length, (i) {
          final habit = sorted[i];
          final rate = habit.completionRate(30);
          final pct = (rate * 100).round();
          final medal = i < 3 ? medals[i] : '';

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              variant: AppCardVariant.filled,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  if (medal.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(medal, style: const TextStyle(fontSize: 20)),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 24,
                        child: Text(
                          '${i + 1}',
                          textAlign: TextAlign.center,
                          style: tt.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  Text(habit.icon, style: const TextStyle(fontSize: 20)),
                  AppSpacing.hGap8,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.vGap4,
                        ClipRRect(
                          borderRadius: AppSpacing.borderRadiusFull,
                          child: LinearProgressIndicator(
                            value: rate,
                            minHeight: 6,
                            backgroundColor: cs.surfaceContainerHighest,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(cs.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.hGap8,
                  Text(
                    '$pct%',
                    style: tt.titleSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
