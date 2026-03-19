import 'package:habit_coach/models/habit.dart';

class CoachAdvice {
  final String message;
  final List<String> tips;
  final List<Habit> atRiskHabits;
  final int weeklyScore;

  CoachAdvice({
    required this.message,
    required this.tips,
    required this.atRiskHabits,
    required this.weeklyScore,
  });
}

class AIService {
  CoachAdvice getCoachAdvice(List<Habit> habits) {
    if (habits.isEmpty) {
      return CoachAdvice(
        message:
            "Welcome to HabitAI! Start by adding your first habit. Small steps lead to big changes.",
        tips: [
          "Start with just one habit to build momentum",
          "Choose a habit you can do in under 2 minutes",
          "Attach your new habit to an existing routine",
        ],
        atRiskHabits: [],
        weeklyScore: 0,
      );
    }

    // Identify at-risk habits (no completion in 2+ days)
    final atRisk = habits.where((h) {
      final days = h.daysSinceLastCompletion;
      return days == -1 || days >= 2;
    }).toList();

    // Calculate weekly score
    final now = DateTime.now();
    int totalPossible = 0;
    int totalCompleted = 0;
    for (final habit in habits) {
      for (int i = 0; i < 7; i++) {
        final day = now.subtract(Duration(days: i));
        final dayKey =
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        totalPossible++;
        if (habit.completedDates.contains(dayKey)) {
          totalCompleted++;
        }
      }
    }
    final weeklyScore =
        totalPossible > 0 ? ((totalCompleted / totalPossible) * 100).round() : 0;

    // Generate motivational message
    String message;
    if (weeklyScore >= 80) {
      message =
          "Outstanding work! You're crushing it this week with a $weeklyScore% completion rate. Keep this incredible momentum going!";
    } else if (weeklyScore >= 60) {
      message =
          "Great progress! You're at $weeklyScore% this week. A little more consistency and you'll be unstoppable!";
    } else if (weeklyScore >= 40) {
      message =
          "You're building a solid foundation at $weeklyScore%. Focus on completing just one more habit each day to level up!";
    } else if (weeklyScore > 0) {
      message =
          "Every journey starts with a single step. You're at $weeklyScore% this week — let's aim a bit higher tomorrow!";
    } else {
      message =
          "Today is a fresh start! Don't let past days hold you back. Complete just one habit today and build from there.";
    }

    // Generate tips based on analysis
    final tips = <String>[];

    // Streak-based tips
    final bestStreakHabit = habits.isNotEmpty
        ? (habits.toList()..sort((a, b) => b.currentStreak.compareTo(a.currentStreak)))
            .first
        : null;
    if (bestStreakHabit != null && bestStreakHabit.currentStreak > 0) {
      tips.add(
          "Your best active streak is ${bestStreakHabit.currentStreak} days on \"${bestStreakHabit.name}\" — don't break the chain!");
    }

    // At-risk tips
    if (atRisk.isNotEmpty) {
      tips.add(
          "${atRisk.length} habit${atRisk.length > 1 ? 's are' : ' is'} at risk of breaking. A quick check-in can save your streak!");
    }

    // General tips based on score
    if (weeklyScore < 50) {
      tips.add("Try habit stacking: pair a new habit with one you already do consistently.");
    }
    if (habits.length > 5) {
      tips.add(
          "You have ${habits.length} habits. Consider focusing on your top 3 to avoid burnout.");
    }

    // Time-based tips
    final hour = now.hour;
    if (hour < 12) {
      tips.add("Morning is the best time for willpower. Knock out your hardest habit first!");
    } else if (hour >= 18) {
      tips.add(
          "End your day strong — complete any remaining habits before winding down.");
    }

    if (tips.isEmpty) {
      tips.add("Consistency beats intensity. Show up every day, even if it's just for 2 minutes.");
      tips.add("Track your progress — what gets measured gets managed.");
    }

    return CoachAdvice(
      message: message,
      tips: tips,
      atRiskHabits: atRisk,
      weeklyScore: weeklyScore,
    );
  }
}
