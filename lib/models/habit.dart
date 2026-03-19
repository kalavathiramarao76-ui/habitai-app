import 'package:uuid/uuid.dart';

class Habit {
  final String id;
  final String name;
  final String icon;
  final int colorValue;
  final String frequency; // 'daily' or 'weekly'
  final int targetDays;
  final List<String> completedDates;
  int streakCount;
  int bestStreak;
  final String createdAt;

  Habit({
    String? id,
    required this.name,
    required this.icon,
    required this.colorValue,
    this.frequency = 'daily',
    this.targetDays = 30,
    List<String>? completedDates,
    this.streakCount = 0,
    this.bestStreak = 0,
    String? createdAt,
  })  : id = id ?? const Uuid().v4(),
        completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now().toIso8601String();

  bool isCompletedToday() {
    final today = _dateKey(DateTime.now());
    return completedDates.contains(today);
  }

  bool isCompletedOn(DateTime date) {
    return completedDates.contains(_dateKey(date));
  }

  int get currentStreak {
    if (completedDates.isEmpty) return 0;

    final sortedDates = completedDates.toList()..sort((a, b) => b.compareTo(a));
    final today = DateTime.now();
    final todayKey = _dateKey(today);
    final yesterdayKey = _dateKey(today.subtract(const Duration(days: 1)));

    if (sortedDates.first != todayKey && sortedDates.first != yesterdayKey) {
      return 0;
    }

    int streak = 1;
    for (int i = 0; i < sortedDates.length - 1; i++) {
      final current = DateTime.parse(sortedDates[i]);
      final previous = DateTime.parse(sortedDates[i + 1]);
      final diff = current.difference(previous).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int get daysSinceLastCompletion {
    if (completedDates.isEmpty) return -1;
    final sortedDates = completedDates.toList()..sort((a, b) => b.compareTo(a));
    final lastDate = DateTime.parse(sortedDates.first);
    return DateTime.now().difference(lastDate).inDays;
  }

  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Habit copyWith({
    String? name,
    String? icon,
    int? colorValue,
    String? frequency,
    int? targetDays,
    List<String>? completedDates,
    int? streakCount,
    int? bestStreak,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      frequency: frequency ?? this.frequency,
      targetDays: targetDays ?? this.targetDays,
      completedDates: completedDates ?? List.from(this.completedDates),
      streakCount: streakCount ?? this.streakCount,
      bestStreak: bestStreak ?? this.bestStreak,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'colorValue': colorValue,
      'frequency': frequency,
      'targetDays': targetDays,
      'completedDates': completedDates,
      'streakCount': streakCount,
      'bestStreak': bestStreak,
      'createdAt': createdAt,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      colorValue: json['colorValue'] as int,
      frequency: json['frequency'] as String? ?? 'daily',
      targetDays: json['targetDays'] as int? ?? 30,
      completedDates: (json['completedDates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      streakCount: json['streakCount'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
