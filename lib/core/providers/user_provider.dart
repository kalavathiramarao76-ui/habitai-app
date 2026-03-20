import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../gamification/xp_engine.dart';
import 'habit_provider.dart';

class UserNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    return _storage.getProfile();
  }

  StorageService get _storage => ref.read(storageServiceProvider);

  void loadProfile() {
    state = _storage.getProfile();
  }

  Future<void> updateName(String name) async {
    state = state.copyWith(name: name);
    await _storage.saveProfile(state);
  }

  Future<void> updateEmail(String email) async {
    state = state.copyWith(email: email);
    await _storage.saveProfile(state);
  }

  Future<void> addXP(int xp) async {
    final newTotalXP = state.totalXP + xp;
    final level = XPEngine.getLevelForXP(newTotalXP);
    state = state.copyWith(
      totalXP: newTotalXP,
      level: level.number,
    );
    await _storage.saveProfile(state);
  }

  Future<void> updateStreak(int streak) async {
    state = state.copyWith(currentStreak: streak);
    await _storage.saveProfile(state);
  }

  Future<void> updateSubscription(SubscriptionTier tier) async {
    state = state.copyWith(subscriptionTier: tier);
    await _storage.saveProfile(state);
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    state = state.copyWith(preferences: preferences);
    await _storage.saveProfile(state);
  }

  Future<void> updateCategories(List<String> categories) async {
    state = state.copyWith(selectedCategories: categories);
    await _storage.saveProfile(state);
  }

  Future<void> updateAvatarUrl(String? url) async {
    state = state.copyWith(avatarUrl: url);
    await _storage.saveProfile(state);
  }

  Future<void> useStreakFreeze() async {
    final currentCount = state.preferences.streakFreezeCount;
    if (currentCount <= 0) return;
    final newPrefs = state.preferences.copyWith(
      streakFreezeCount: currentCount - 1,
    );
    state = state.copyWith(preferences: newPrefs);
    await _storage.saveProfile(state);
  }
}

final userProvider =
    NotifierProvider<UserNotifier, UserProfile>(UserNotifier.new);
