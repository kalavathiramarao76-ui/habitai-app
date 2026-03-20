import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit.dart';
import '../services/storage_service.dart';

class HabitNotifier extends Notifier<List<Habit>> {
  @override
  List<Habit> build() {
    return _storage.getHabits();
  }

  StorageService get _storage => ref.read(storageServiceProvider);

  void loadHabits() {
    state = _storage.getHabits();
  }

  Future<void> addHabit(Habit habit) async {
    await _storage.saveHabit(habit);
    state = [...state, habit];
  }

  Future<void> updateHabit(Habit habit) async {
    final updated = habit.copyWith(updatedAt: DateTime.now());
    await _storage.saveHabit(updated);
    state = [
      for (final h in state)
        if (h.id == updated.id) updated else h,
    ];
  }

  Future<void> deleteHabit(String id) async {
    await _storage.deleteHabit(id);
    state = state.where((h) => h.id != id).toList();
  }

  Future<void> toggleCompletion(String habitId, DateTime date,
      {double? value}) async {
    final index = state.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = state[index];
    final dateKey = _dateKey(date);
    final completedDates =
        Map<String, HabitCompletion>.from(habit.completedDates);

    if (habit.isCompletedOn(date)) {
      completedDates.remove(dateKey);
    } else {
      completedDates[dateKey] = HabitCompletion(
        completed: true,
        value: value,
        timestamp: DateTime.now(),
      );
    }

    final updatedHabit = habit.copyWith(
      completedDates: completedDates,
      updatedAt: DateTime.now(),
    );

    // Update best streak if current is higher
    final currentStreak = updatedHabit.currentStreak;
    final finalHabit = currentStreak > updatedHabit.bestStreak
        ? updatedHabit.copyWith(bestStreak: currentStreak)
        : updatedHabit;

    await _storage.saveHabit(finalHabit);
    state = [
      for (final h in state)
        if (h.id == habitId) finalHabit else h,
    ];
  }

  Future<void> addNote(String habitId, DateTime date, String note) async {
    final index = state.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = state[index];
    final dateKey = _dateKey(date);
    final notes = Map<String, String>.from(habit.notes);
    notes[dateKey] = note;

    final updated = habit.copyWith(notes: notes, updatedAt: DateTime.now());
    await _storage.saveHabit(updated);
    state = [
      for (final h in state)
        if (h.id == habitId) updated else h,
    ];
  }

  static String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final habitsProvider =
    NotifierProvider<HabitNotifier, List<Habit>>(HabitNotifier.new);

final todayHabitsProvider = Provider<List<Habit>>((ref) {
  final habits = ref.watch(habitsProvider);
  final now = DateTime.now();
  return habits.where((habit) {
    if (habit.isPaused || habit.isArchived) return false;
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.specificDays:
        return habit.targetDays.contains(now.weekday);
      case HabitFrequency.timesPerWeek:
      case HabitFrequency.timesPerMonth:
        return true;
    }
  }).toList();
});

final habitStatsProvider = Provider<HabitStats>((ref) {
  final habits = ref.watch(habitsProvider);
  final activeHabits =
      habits.where((h) => !h.isPaused && !h.isArchived).toList();

  final totalHabits = activeHabits.length;
  final totalCompletions = habits.fold<int>(
    0,
    (sum, h) =>
        sum + h.completedDates.values.where((c) => c.completed).length,
  );
  final bestStreak = habits.fold<int>(
    0,
    (max, h) => h.bestStreak > max ? h.bestStreak : max,
  );
  final longestCurrentStreak = activeHabits.fold<int>(
    0,
    (max, h) => h.currentStreak > max ? h.currentStreak : max,
  );

  double avgRate = 0;
  if (activeHabits.isNotEmpty) {
    avgRate = activeHabits.fold<double>(
            0, (sum, h) => sum + h.completionRate(30)) /
        activeHabits.length;
  }

  final todayCompleted =
      activeHabits.where((h) => h.isCompletedOn(DateTime.now())).length;

  return HabitStats(
    totalHabits: totalHabits,
    totalCompletions: totalCompletions,
    bestStreak: bestStreak,
    longestCurrentStreak: longestCurrentStreak,
    averageCompletionRate: avgRate,
    todayCompleted: todayCompleted,
    todayTotal: activeHabits.length,
  );
});

class HabitStats {
  final int totalHabits;
  final int totalCompletions;
  final int bestStreak;
  final int longestCurrentStreak;
  final double averageCompletionRate;
  final int todayCompleted;
  final int todayTotal;

  const HabitStats({
    this.totalHabits = 0,
    this.totalCompletions = 0,
    this.bestStreak = 0,
    this.longestCurrentStreak = 0,
    this.averageCompletionRate = 0.0,
    this.todayCompleted = 0,
    this.todayTotal = 0,
  });

  double get todayProgress =>
      todayTotal > 0 ? todayCompleted / todayTotal : 0.0;
}
