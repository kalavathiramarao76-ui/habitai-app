import '../models/habit.dart';
import '../models/user_profile.dart';
import '../models/achievement.dart';

class Level {
  final int number;
  final String name;
  final int currentXP;
  final int nextLevelXP;

  const Level({
    required this.number,
    required this.name,
    required this.currentXP,
    required this.nextLevelXP,
  });
}

class XPEngine {
  static const List<Map<String, dynamic>> _levels = [
    {'name': 'Seed', 'xp': 0},
    {'name': 'Sprout', 'xp': 100},
    {'name': 'Sapling', 'xp': 300},
    {'name': 'Plant', 'xp': 600},
    {'name': 'Tree', 'xp': 1000},
    {'name': 'Forest', 'xp': 2000},
    {'name': 'Ecosystem', 'xp': 5000},
    {'name': 'Planet', 'xp': 10000},
    {'name': 'Galaxy', 'xp': 25000},
    {'name': 'Universe', 'xp': 50000},
  ];

  /// Calculate XP earned for completing a habit.
  static int calculateXPForCompletion({
    required Habit habit,
    required int currentStreak,
    required bool allHabitsCompleted,
    bool completedEarly = false,
  }) {
    // Base XP
    int xp = 10;

    // Streak bonus: +5 per streak day, capped at +50
    final streakBonus = (currentStreak * 5).clamp(0, 50);
    xp += streakBonus;

    // Perfect day bonus
    if (allHabitsCompleted) {
      xp += 25;
    }

    // Early bird bonus
    if (completedEarly) {
      xp += 10;
    }

    return xp;
  }

  /// Get the level information for a given XP total.
  static Level getLevelForXP(int xp) {
    int levelNumber = 1;
    String levelName = _levels[0]['name'] as String;
    int nextLevelXP = _levels[1]['xp'] as int;

    for (int i = _levels.length - 1; i >= 0; i--) {
      final threshold = _levels[i]['xp'] as int;
      if (xp >= threshold) {
        levelNumber = i + 1;
        levelName = _levels[i]['name'] as String;
        nextLevelXP = i + 1 < _levels.length
            ? _levels[i + 1]['xp'] as int
            : threshold * 2;
        break;
      }
    }

    return Level(
      number: levelNumber,
      name: levelName,
      currentXP: xp,
      nextLevelXP: nextLevelXP,
    );
  }

  /// Check which achievements have been newly unlocked.
  static List<Achievement> checkAchievements({
    required List<Habit> habits,
    required UserProfile profile,
    required List<Achievement> currentAchievements,
  }) {
    final newlyUnlocked = <Achievement>[];
    final activeHabits =
        habits.where((h) => !h.isPaused && !h.isArchived).toList();

    for (final achievement in currentAchievements) {
      if (achievement.isUnlocked) continue;

      bool unlocked = false;

      switch (achievement.id) {
        case 'first_flame':
          unlocked = habits.any((h) => h.completedDates.values
              .any((c) => c.completed));
          break;

        case 'week_warrior':
          unlocked = activeHabits.any((h) => h.currentStreak >= 7);
          break;

        case 'fortnight_force':
          unlocked = activeHabits.any((h) => h.currentStreak >= 14);
          break;

        case 'monthly_master':
          unlocked = activeHabits.any((h) => h.currentStreak >= 30);
          break;

        case 'century_club':
          final total = habits.fold<int>(
              0,
              (sum, h) => sum +
                  h.completedDates.values
                      .where((c) => c.completed)
                      .length);
          unlocked = total >= 100;
          break;

        case 'perfect_day':
          unlocked = _checkPerfectDay(activeHabits);
          break;

        case 'early_bird':
          unlocked = _checkEarlyBird(activeHabits, 7);
          break;

        case 'night_owl':
          final eveningHabits = activeHabits
              .where((h) => h.timeOfDay == HabitTimeOfDay.evening)
              .toList();
          unlocked = eveningHabits.isNotEmpty &&
              eveningHabits.every((h) => h.currentStreak >= 14);
          break;

        case 'habit_collector':
          unlocked = activeHabits.length >= 10;
          break;

        case 'consistency_king':
          unlocked = activeHabits.isNotEmpty &&
              activeHabits.every((h) => h.completionRate(30) >= 0.8);
          break;

        case 'streak_saver':
          unlocked = profile.preferences.streakFreezeCount > 0;
          break;

        case 'five_alive':
          unlocked = activeHabits.length >= 5;
          break;

        case 'level_10':
          unlocked = profile.level >= 10;
          break;

        case 'level_25':
          unlocked = profile.level >= 25;
          break;

        case 'comeback_kid':
          unlocked = _checkComebackKid(activeHabits);
          break;

        // These require external triggers, checked elsewhere
        case 'ai_student':
        case 'explorer':
        case 'data_nerd':
        case 'challenger':
        case 'social_butterfly':
          break;
      }

      if (unlocked) {
        newlyUnlocked.add(achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        ));
      }
    }

    return newlyUnlocked;
  }

  static bool _checkPerfectDay(List<Habit> activeHabits) {
    if (activeHabits.isEmpty) return false;
    final today = DateTime.now();
    return activeHabits.every((h) => h.isCompletedOn(today));
  }

  static bool _checkEarlyBird(List<Habit> habits, int requiredDays) {
    final morningHabits =
        habits.where((h) => h.timeOfDay == HabitTimeOfDay.morning).toList();
    if (morningHabits.isEmpty) return false;

    int consecutiveDays = 0;
    for (int d = 0; d < 30; d++) {
      final date = DateTime.now().subtract(Duration(days: d));
      final allMorningDone = morningHabits.every((h) {
        final key =
            '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final completion = h.completedDates[key];
        if (completion == null || !completion.completed) return false;
        // Check if completed before 8 AM
        return completion.timestamp.hour < 8;
      });
      if (allMorningDone) {
        consecutiveDays++;
        if (consecutiveDays >= requiredDays) return true;
      } else {
        consecutiveDays = 0;
      }
    }
    return false;
  }

  static bool _checkComebackKid(List<Habit> habits) {
    // Check if any habit had a broken streak (gap) and then resumed
    for (final habit in habits) {
      final dates = habit.completedDates.entries
          .where((e) => e.value.completed)
          .map((e) => DateTime.tryParse(e.key))
          .whereType<DateTime>()
          .toList()
        ..sort();

      if (dates.length < 3) continue;

      for (int i = 1; i < dates.length - 1; i++) {
        final gap = dates[i].difference(dates[i - 1]).inDays;
        if (gap >= 3) {
          // Had a gap of 3+ days, then came back
          final resumed = dates[i + 1].difference(dates[i]).inDays <= 1;
          if (resumed) return true;
        }
      }
    }
    return false;
  }
}
