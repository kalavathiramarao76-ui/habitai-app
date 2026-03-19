import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_coach/models/habit.dart';

class StorageService {
  static const String _habitsKey = 'habits_data';
  static const String _userNameKey = 'user_name';
  static const String _isDarkModeKey = 'is_dark_mode';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  Future<List<Habit>> getHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_habitsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => Habit.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(habits.map((h) => h.toJson()).toList());
    await prefs.setString(_habitsKey, jsonString);
  }

  Future<void> addHabit(Habit habit) async {
    final habits = await getHabits();
    habits.add(habit);
    await saveHabits(habits);
  }

  Future<void> deleteHabit(String habitId) async {
    final habits = await getHabits();
    habits.removeWhere((h) => h.id == habitId);
    await saveHabits(habits);
  }

  Future<void> updateHabit(Habit habit) async {
    final habits = await getHabits();
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      habits[index] = habit;
      await saveHabits(habits);
    }
  }

  Future<Habit?> toggleCompletion(String habitId, DateTime date) async {
    final habits = await getHabits();
    final index = habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return null;

    final habit = habits[index];
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    List<String> updatedDates = List.from(habit.completedDates);
    if (updatedDates.contains(dateKey)) {
      updatedDates.remove(dateKey);
    } else {
      updatedDates.add(dateKey);
    }

    final updatedHabit = habit.copyWith(completedDates: updatedDates);
    final newStreak = updatedHabit.currentStreak;
    final newBest =
        newStreak > updatedHabit.bestStreak ? newStreak : updatedHabit.bestStreak;

    final finalHabit = updatedHabit.copyWith(
      streakCount: newStreak,
      bestStreak: newBest,
    );

    habits[index] = finalHabit;
    await saveHabits(habits);
    return finalHabit;
  }

  // User preferences
  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? '';
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDarkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkModeKey, value);
  }

  Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, value);
  }
}
