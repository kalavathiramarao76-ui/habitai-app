import 'dart:convert';

import 'package:uuid/uuid.dart';

enum HabitFrequency { daily, specificDays, timesPerWeek, timesPerMonth }

enum HabitTimeOfDay { morning, afternoon, evening, anytime }

class HabitCompletion {
  final bool completed;
  final double? value;
  final String? note;
  final DateTime timestamp;

  const HabitCompletion({
    required this.completed,
    this.value,
    this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'completed': completed,
        'value': value,
        'note': note,
        'timestamp': timestamp.toIso8601String(),
      };

  factory HabitCompletion.fromJson(Map<String, dynamic> json) {
    return HabitCompletion(
      completed: json['completed'] as bool? ?? false,
      value: (json['value'] as num?)?.toDouble(),
      note: json['note'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  HabitCompletion copyWith({
    bool? completed,
    double? value,
    String? note,
    DateTime? timestamp,
  }) {
    return HabitCompletion(
      completed: completed ?? this.completed,
      value: value ?? this.value,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class Habit {
  final String id;
  final String name;
  final String icon;
  final int colorValue;
  final HabitFrequency frequency;
  final List<int> targetDays;
  final int timesPerPeriod;
  final HabitTimeOfDay timeOfDay;
  final String? reminderTime;
  final Map<String, HabitCompletion> completedDates;
  final bool measurable;
  final String? unit;
  final double? targetValue;
  final int bestStreak;
  final int totalXP;
  final Map<String, String> notes;
  final bool isPaused;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Habit({
    String? id,
    required this.name,
    this.icon = '\u{1F31F}',
    this.colorValue = 0xFF2196F3,
    this.frequency = HabitFrequency.daily,
    this.targetDays = const [],
    this.timesPerPeriod = 1,
    this.timeOfDay = HabitTimeOfDay.anytime,
    this.reminderTime,
    this.completedDates = const {},
    this.measurable = false,
    this.unit,
    this.targetValue,
    this.bestStreak = 0,
    this.totalXP = 0,
    this.notes = const {},
    this.isPaused = false,
    this.isArchived = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool isCompletedOn(DateTime date) {
    final key = _dateKey(date);
    final completion = completedDates[key];
    return completion != null && completion.completed;
  }

  int get currentStreak {
    int streak = 0;
    DateTime day = DateTime.now();
    // If not completed today, start from yesterday
    if (!isCompletedOn(day)) {
      day = day.subtract(const Duration(days: 1));
    }
    while (isCompletedOn(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  double completionRate(int days) {
    if (days <= 0) return 0.0;
    final now = DateTime.now();
    int completed = 0;
    int applicable = 0;
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      if (_isApplicableOn(date)) {
        applicable++;
        if (isCompletedOn(date)) {
          completed++;
        }
      }
    }
    if (applicable == 0) return 0.0;
    return completed / applicable;
  }

  List<HabitCompletion> getCompletionsInRange(DateTime start, DateTime end) {
    final results = <HabitCompletion>[];
    DateTime current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    while (!current.isAfter(endDate)) {
      final key = _dateKey(current);
      final completion = completedDates[key];
      if (completion != null && completion.completed) {
        results.add(completion);
      }
      current = current.add(const Duration(days: 1));
    }
    return results;
  }

  bool _isApplicableOn(DateTime date) {
    if (frequency == HabitFrequency.daily) return true;
    if (frequency == HabitFrequency.specificDays) {
      // 1=Mon..7=Sun matches DateTime.weekday
      return targetDays.contains(date.weekday);
    }
    // For timesPerWeek/Month, consider every day applicable
    return true;
  }

  static String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'colorValue': colorValue,
        'frequency': frequency.name,
        'targetDays': targetDays,
        'timesPerPeriod': timesPerPeriod,
        'timeOfDay': timeOfDay.name,
        'reminderTime': reminderTime,
        'completedDates': completedDates
            .map((key, value) => MapEntry(key, value.toJson())),
        'measurable': measurable,
        'unit': unit,
        'targetValue': targetValue,
        'bestStreak': bestStreak,
        'totalXP': totalXP,
        'notes': notes,
        'isPaused': isPaused,
        'isArchived': isArchived,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) {
    final completedDatesRaw =
        json['completedDates'] as Map<String, dynamic>? ?? {};
    final completedDates = completedDatesRaw.map(
      (key, value) => MapEntry(
        key,
        HabitCompletion.fromJson(value as Map<String, dynamic>),
      ),
    );
    final notesRaw = json['notes'] as Map<String, dynamic>? ?? {};
    final notes = notesRaw.map((k, v) => MapEntry(k, v as String));

    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '\u{1F31F}',
      colorValue: json['colorValue'] as int? ?? 0xFF2196F3,
      frequency: HabitFrequency.values
          .firstWhere((e) => e.name == json['frequency'], orElse: () => HabitFrequency.daily),
      targetDays: (json['targetDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      timesPerPeriod: json['timesPerPeriod'] as int? ?? 1,
      timeOfDay: HabitTimeOfDay.values
          .firstWhere((e) => e.name == json['timeOfDay'], orElse: () => HabitTimeOfDay.anytime),
      reminderTime: json['reminderTime'] as String?,
      completedDates: completedDates,
      measurable: json['measurable'] as bool? ?? false,
      unit: json['unit'] as String?,
      targetValue: (json['targetValue'] as num?)?.toDouble(),
      bestStreak: json['bestStreak'] as int? ?? 0,
      totalXP: json['totalXP'] as int? ?? 0,
      notes: notes,
      isPaused: json['isPaused'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Habit copyWith({
    String? id,
    String? name,
    String? icon,
    int? colorValue,
    HabitFrequency? frequency,
    List<int>? targetDays,
    int? timesPerPeriod,
    HabitTimeOfDay? timeOfDay,
    String? reminderTime,
    Map<String, HabitCompletion>? completedDates,
    bool? measurable,
    String? unit,
    double? targetValue,
    int? bestStreak,
    int? totalXP,
    Map<String, String>? notes,
    bool? isPaused,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      frequency: frequency ?? this.frequency,
      targetDays: targetDays ?? this.targetDays,
      timesPerPeriod: timesPerPeriod ?? this.timesPerPeriod,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      reminderTime: reminderTime ?? this.reminderTime,
      completedDates: completedDates ?? this.completedDates,
      measurable: measurable ?? this.measurable,
      unit: unit ?? this.unit,
      targetValue: targetValue ?? this.targetValue,
      bestStreak: bestStreak ?? this.bestStreak,
      totalXP: totalXP ?? this.totalXP,
      notes: notes ?? this.notes,
      isPaused: isPaused ?? this.isPaused,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Habit.fromJsonString(String source) =>
      Habit.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
