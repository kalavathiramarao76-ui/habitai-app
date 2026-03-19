import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_coach/models/habit.dart';

class StreakCalendar extends StatelessWidget {
  final List<Habit> habits;

  const StreakCalendar({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        // Day labels row
        Row(
          children: [
            const SizedBox(width: 32),
            ...List.generate(7, (i) {
              return Expanded(
                child: Center(
                  child: Text(
                    dayLabels[i],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 6),
        // 4 weeks grid
        ...List.generate(4, (weekIndex) {
          final weekLabel = weekIndex == 0 ? 'This' : '${weekIndex}w';
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    weekLabel,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                ...List.generate(7, (dayIndex) {
                  // Calculate the date for this cell
                  final todayWeekday = now.weekday; // 1=Mon, 7=Sun
                  final daysFromMonday = dayIndex; // 0=Mon in our grid
                  final thisWeekMonday =
                      now.subtract(Duration(days: todayWeekday - 1));
                  final targetDate = thisWeekMonday
                      .subtract(Duration(days: weekIndex * 7))
                      .add(Duration(days: daysFromMonday));

                  final dateKey =
                      '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

                  // Check completion across all habits
                  int completedCount = 0;
                  for (final habit in habits) {
                    if (habit.completedDates.contains(dateKey)) {
                      completedCount++;
                    }
                  }

                  final isToday = targetDate.year == now.year &&
                      targetDate.month == now.month &&
                      targetDate.day == now.day;

                  final isFuture = targetDate.isAfter(now);

                  Color cellColor;
                  if (isFuture) {
                    cellColor = theme.colorScheme.onSurface.withValues(alpha: 0.05);
                  } else if (habits.isEmpty) {
                    cellColor = theme.colorScheme.onSurface.withValues(alpha: 0.08);
                  } else {
                    final ratio =
                        habits.isNotEmpty ? completedCount / habits.length : 0.0;
                    if (ratio >= 0.75) {
                      cellColor = const Color(0xFF22C55E);
                    } else if (ratio >= 0.5) {
                      cellColor = const Color(0xFF22C55E).withValues(alpha: 0.6);
                    } else if (ratio > 0) {
                      cellColor = const Color(0xFF22C55E).withValues(alpha: 0.3);
                    } else {
                      cellColor =
                          theme.colorScheme.onSurface.withValues(alpha: 0.08);
                    }
                  }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: cellColor,
                            borderRadius: BorderRadius.circular(6),
                            border: isToday
                                ? Border.all(
                                    color: const Color(0xFF6366F1),
                                    width: 2,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }
}
