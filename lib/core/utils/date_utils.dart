import 'package:intl/intl.dart';

class HabitDateUtils {
  HabitDateUtils._();

  /// Format a date as "Mar 20, 2026"
  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  /// Format a date as "Thursday, March 20"
  static String formatDateFull(DateTime date) {
    return DateFormat.MMMMEEEEd().format(date);
  }

  /// Format relative: "Today", "Yesterday", "2 days ago", or the date
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff == -1) return 'Tomorrow';
    if (diff > 0 && diff <= 7) return '$diff days ago';
    if (diff < 0 && diff >= -7) return 'in ${-diff} days';
    return formatDate(date);
  }

  /// Check if two dates are the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if a date is today.
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if a date is yesterday.
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Get all dates in the week containing [date].
  /// Week starts on [weekStartDay] (1=Monday, 7=Sunday).
  static List<DateTime> getWeekDates(DateTime date, {int weekStartDay = 1}) {
    final dayOfWeek = date.weekday;
    int daysFromStart = (dayOfWeek - weekStartDay) % 7;
    if (daysFromStart < 0) daysFromStart += 7;
    final startOfWeek = DateTime(
      date.year,
      date.month,
      date.day - daysFromStart,
    );
    return List.generate(
      7,
      (i) => startOfWeek.add(Duration(days: i)),
    );
  }

  /// Get all dates in the month of [date].
  static List<DateTime> getMonthDates(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    final dayCount = lastDay.day;
    return List.generate(
      dayCount,
      (i) => firstDay.add(Duration(days: i)),
    );
  }

  /// Calculate the current streak from a map of completed dates.
  /// Keys should be in "yyyy-MM-dd" format.
  static int streakCalculator(Map<String, bool> completedDates) {
    if (completedDates.isEmpty) return 0;

    int streak = 0;
    DateTime day = DateTime.now();

    // Check today first
    final todayKey = _dateKey(day);
    if (completedDates[todayKey] != true) {
      // If not completed today, start from yesterday
      day = day.subtract(const Duration(days: 1));
    }

    while (true) {
      final key = _dateKey(day);
      if (completedDates[key] == true) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// Get a greeting based on the current time of day.
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Format time string "HH:mm" to "h:mm a"
  static String formatTime(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 2) return timeString;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return timeString;
    final dateTime = DateTime(2000, 1, 1, hour, minute);
    return DateFormat.jm().format(dateTime);
  }

  /// Generate a date key in "yyyy-MM-dd" format.
  static String dateKey(DateTime date) => _dateKey(date);

  static String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
