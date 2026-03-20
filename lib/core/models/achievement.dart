import 'dart:convert';

enum AchievementCategory { streak, completion, special }

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String requirement;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final AchievementCategory category;
  final int xpReward;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    this.icon = '\u{1F3C6}',
    required this.requirement,
    this.isUnlocked = false,
    this.unlockedAt,
    this.category = AchievementCategory.completion,
    this.xpReward = 50,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'requirement': requirement,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'category': category.name,
        'xpReward': xpReward,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String? ?? '\u{1F3C6}',
      requirement: json['requirement'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AchievementCategory.completion,
      ),
      xpReward: json['xpReward'] as int? ?? 50,
    );
  }

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? requirement,
    bool? isUnlocked,
    DateTime? unlockedAt,
    AchievementCategory? category,
    int? xpReward,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      requirement: requirement ?? this.requirement,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      category: category ?? this.category,
      xpReward: xpReward ?? this.xpReward,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Achievement.fromJsonString(String source) =>
      Achievement.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
