import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:habit_coach/models/habit.dart';
import 'package:habit_coach/widgets/streak_calendar.dart';
import 'package:habit_coach/theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  final List<Habit> habits;

  const StatsScreen({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate stats
    int bestStreak = 0;
    int totalCompletions = 0;
    int biggestCurrentStreak = 0;

    for (final habit in habits) {
      if (habit.bestStreak > bestStreak) bestStreak = habit.bestStreak;
      final cs = habit.currentStreak;
      if (cs > biggestCurrentStreak) biggestCurrentStreak = cs;
      if (cs > bestStreak) bestStreak = cs;
      totalCompletions += habit.completedDates.length;
    }

    // Last 7 days completions for bar chart
    final now = DateTime.now();
    final last7 = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayKey =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      int count = 0;
      for (final h in habits) {
        if (h.completedDates.contains(dayKey)) count++;
      }
      return MapEntry(day, count);
    });

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            // Stat cards row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Current Streak',
                    value: '$biggestCurrentStreak',
                    icon: '\u{1F525}',
                    color: AppTheme.warningColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Best Streak',
                    value: '$bestStreak',
                    icon: '\u{1F3C6}',
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Total Done',
                    value: '$totalCompletions',
                    icon: '\u{2705}',
                    color: AppTheme.successColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Active Habits',
                    value: '${habits.length}',
                    icon: '\u{1F4CB}',
                    color: const Color(0xFF06B6D4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Weekly heatmap
            StreakCalendar(habits: habits),
            const SizedBox(height: 32),

            // Bar chart - last 7 days
            Text(
              'Last 7 Days',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: habits.isEmpty
                  ? Center(
                      child: Text(
                        'Add habits to see your chart',
                        style: GoogleFonts.inter(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (habits.length + 1).toDouble(),
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= last7.length) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  DateFormat('E')
                                      .format(last7[idx].key)
                                      .substring(0, 2),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(7, (i) {
                          final count = last7[i].value;
                          final isToday = i == 6;
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: count.toDouble(),
                                color: isToday
                                    ? AppTheme.primaryColor
                                    : AppTheme.primaryColor
                                        .withValues(alpha: 0.4),
                                width: 24,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
