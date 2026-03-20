import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';
import '../models/user_profile.dart';
import '../models/achievement.dart';
import '../gamification/achievements_data.dart';

class StorageService {
  static const String _habitsBoxName = 'habits';
  static const String _profileBoxName = 'profile';
  static const String _achievementsBoxName = 'achievements';
  static const String _messagesBoxName = 'messages';

  late Box<String> _habitsBox;
  late Box<String> _profileBox;
  late Box<String> _achievementsBox;
  late Box<String> _messagesBox;

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Future<void> initStorage() async {
    await Hive.initFlutter();
    _habitsBox = await Hive.openBox<String>(_habitsBoxName);
    _profileBox = await Hive.openBox<String>(_profileBoxName);
    _achievementsBox = await Hive.openBox<String>(_achievementsBoxName);
    _messagesBox = await Hive.openBox<String>(_messagesBoxName);

    // Initialize default achievements if empty
    if (_achievementsBox.isEmpty) {
      for (final achievement in allAchievements) {
        await _achievementsBox.put(achievement.id, achievement.toJsonString());
      }
    }
  }

  // --- Habits ---

  List<Habit> getHabits() {
    return _habitsBox.values
        .map((json) => Habit.fromJsonString(json))
        .toList();
  }

  Future<void> saveHabit(Habit habit) async {
    await _habitsBox.put(habit.id, habit.toJsonString());
  }

  Future<void> deleteHabit(String id) async {
    await _habitsBox.delete(id);
  }

  // --- Profile ---

  UserProfile getProfile() {
    final json = _profileBox.get('user');
    if (json == null) return UserProfile();
    return UserProfile.fromJsonString(json);
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _profileBox.put('user', profile.toJsonString());
  }

  // --- Achievements ---

  List<Achievement> getAchievements() {
    return _achievementsBox.values
        .map((json) => Achievement.fromJsonString(json))
        .toList();
  }

  Future<void> unlockAchievement(String id) async {
    final json = _achievementsBox.get(id);
    if (json == null) return;
    final achievement = Achievement.fromJsonString(json);
    if (achievement.isUnlocked) return;
    final unlocked = achievement.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );
    await _achievementsBox.put(id, unlocked.toJsonString());
  }

  Future<void> saveAchievement(Achievement achievement) async {
    await _achievementsBox.put(achievement.id, achievement.toJsonString());
  }

  // --- Messages ---

  Future<void> saveMessage(String id, String jsonString) async {
    await _messagesBox.put(id, jsonString);
  }

  List<String> getMessages() {
    return _messagesBox.values.toList();
  }

  Future<void> clearMessages() async {
    await _messagesBox.clear();
  }

  // --- Settings (SharedPreferences) ---

  Future<String?> getSetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> setSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // --- Export / Import ---

  String exportData() {
    final data = {
      'habits': getHabits().map((h) => h.toJson()).toList(),
      'profile': getProfile().toJson(),
      'achievements': getAchievements().map((a) => a.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
    return jsonEncode(data);
  }

  Future<void> importData(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    // Import habits
    if (data['habits'] != null) {
      await _habitsBox.clear();
      final habits = (data['habits'] as List<dynamic>)
          .map((h) => Habit.fromJson(h as Map<String, dynamic>));
      for (final habit in habits) {
        await _habitsBox.put(habit.id, habit.toJsonString());
      }
    }

    // Import profile
    if (data['profile'] != null) {
      final profile =
          UserProfile.fromJson(data['profile'] as Map<String, dynamic>);
      await _profileBox.put('user', profile.toJsonString());
    }

    // Import achievements
    if (data['achievements'] != null) {
      await _achievementsBox.clear();
      final achievements = (data['achievements'] as List<dynamic>)
          .map((a) => Achievement.fromJson(a as Map<String, dynamic>));
      for (final achievement in achievements) {
        await _achievementsBox.put(achievement.id, achievement.toJsonString());
      }
    }
  }
}
