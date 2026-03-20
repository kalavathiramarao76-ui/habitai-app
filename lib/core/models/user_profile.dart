import 'dart:convert';

enum SubscriptionTier { free, pro, lifetime }

class UserPreferences {
  final String themeMode;
  final int weekStartDay;
  final int streakFreezeCount;

  const UserPreferences({
    this.themeMode = 'system',
    this.weekStartDay = 1,
    this.streakFreezeCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode,
        'weekStartDay': weekStartDay,
        'streakFreezeCount': streakFreezeCount,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      themeMode: json['themeMode'] as String? ?? 'system',
      weekStartDay: json['weekStartDay'] as int? ?? 1,
      streakFreezeCount: json['streakFreezeCount'] as int? ?? 0,
    );
  }

  UserPreferences copyWith({
    String? themeMode,
    int? weekStartDay,
    int? streakFreezeCount,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      weekStartDay: weekStartDay ?? this.weekStartDay,
      streakFreezeCount: streakFreezeCount ?? this.streakFreezeCount,
    );
  }
}

class UserProfile {
  final String name;
  final String email;
  final String? avatarUrl;
  final int level;
  final int totalXP;
  final int currentStreak;
  final DateTime memberSince;
  final SubscriptionTier subscriptionTier;
  final List<String> selectedCategories;
  final UserPreferences preferences;

  UserProfile({
    this.name = 'User',
    this.email = '',
    this.avatarUrl,
    this.level = 1,
    this.totalXP = 0,
    this.currentStreak = 0,
    DateTime? memberSince,
    this.subscriptionTier = SubscriptionTier.free,
    this.selectedCategories = const [],
    this.preferences = const UserPreferences(),
  }) : memberSince = memberSince ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'level': level,
        'totalXP': totalXP,
        'currentStreak': currentStreak,
        'memberSince': memberSince.toIso8601String(),
        'subscriptionTier': subscriptionTier.name,
        'selectedCategories': selectedCategories,
        'preferences': preferences.toJson(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      level: json['level'] as int? ?? 1,
      totalXP: json['totalXP'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      memberSince: json['memberSince'] != null
          ? DateTime.parse(json['memberSince'] as String)
          : DateTime.now(),
      subscriptionTier: SubscriptionTier.values.firstWhere(
        (e) => e.name == json['subscriptionTier'],
        orElse: () => SubscriptionTier.free,
      ),
      selectedCategories: (json['selectedCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(
              json['preferences'] as Map<String, dynamic>)
          : const UserPreferences(),
    );
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    int? level,
    int? totalXP,
    int? currentStreak,
    DateTime? memberSince,
    SubscriptionTier? subscriptionTier,
    List<String>? selectedCategories,
    UserPreferences? preferences,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      totalXP: totalXP ?? this.totalXP,
      currentStreak: currentStreak ?? this.currentStreak,
      memberSince: memberSince ?? this.memberSince,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      preferences: preferences ?? this.preferences,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserProfile.fromJsonString(String source) =>
      UserProfile.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
