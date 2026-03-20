import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/habit.dart';
import '../models/coach_message.dart';

class AiService {
  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  String? _apiKey;

  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  void setApiKey(String key) {
    _apiKey = key;
  }

  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  // --- Public API ---

  Future<List<CoachMessage>> getCoachInsights(List<Habit> habits) async {
    if (hasApiKey) {
      try {
        return await _getCloudInsights(habits);
      } catch (_) {
        return _getLocalInsights(habits);
      }
    }
    return _getLocalInsights(habits);
  }

  Future<List<CoachMessage>> analyzeHabitCorrelations(
      List<Habit> habits) async {
    if (hasApiKey) {
      try {
        return await _getCloudCorrelations(habits);
      } catch (_) {
        return _getLocalCorrelations(habits);
      }
    }
    return _getLocalCorrelations(habits);
  }

  Future<String> getDailyChallenge(List<Habit> habits) async {
    if (hasApiKey) {
      try {
        return await _getCloudChallenge(habits);
      } catch (_) {
        return _getLocalChallenge(habits);
      }
    }
    return _getLocalChallenge(habits);
  }

  Future<String> chatWithCoach(List<Habit> habits, String userMessage) async {
    if (hasApiKey) {
      try {
        return await _getCloudChat(habits, userMessage);
      } catch (_) {
        return _getLocalChat(habits, userMessage);
      }
    }
    return _getLocalChat(habits, userMessage);
  }

  int getWeeklyScore(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    double totalRate = 0;
    int count = 0;
    for (final habit in habits) {
      if (!habit.isPaused && !habit.isArchived) {
        totalRate += habit.completionRate(7);
        count++;
      }
    }
    if (count == 0) return 0;
    return ((totalRate / count) * 100).round().clamp(0, 100);
  }

  // --- Local Rules Engine ---

  List<CoachMessage> _getLocalInsights(List<Habit> habits) {
    final messages = <CoachMessage>[];
    final activeHabits =
        habits.where((h) => !h.isPaused && !h.isArchived).toList();

    // Streak insights
    for (final habit in activeHabits) {
      final streak = habit.currentStreak;
      if (streak >= 7 && streak % 7 == 0) {
        messages.add(CoachMessage(
          type: CoachMessageType.milestone,
          title: 'Streak Milestone!',
          message:
              'Amazing! You\'ve maintained "${habit.name}" for $streak days straight. Keep going!',
          habitId: habit.id,
        ));
      }
    }

    // At-risk habits (no completion in 2+ days)
    for (final habit in activeHabits) {
      if (habit.currentStreak == 0) {
        final lastCompletion = _findLastCompletionDate(habit);
        if (lastCompletion != null) {
          final daysSince =
              DateTime.now().difference(lastCompletion).inDays;
          if (daysSince >= 2 && daysSince <= 7) {
            messages.add(CoachMessage(
              type: CoachMessageType.alert,
              title: 'Habit at Risk',
              message:
                  '"${habit.name}" hasn\'t been completed in $daysSince days. A small step today keeps the habit alive!',
              habitId: habit.id,
            ));
          }
        }
      }
    }

    // Completion rate insights
    for (final habit in activeHabits) {
      final rate = habit.completionRate(30);
      if (rate >= 0.9) {
        messages.add(CoachMessage(
          type: CoachMessageType.insight,
          title: 'Consistency Champion',
          message:
              'Your "${habit.name}" completion rate is ${(rate * 100).round()}% over the last 30 days. Outstanding!',
          habitId: habit.id,
        ));
      }
    }

    // General tips
    if (activeHabits.isNotEmpty) {
      final tips = _getTips();
      final random = Random();
      final tip = tips[random.nextInt(tips.length)];
      messages.add(CoachMessage(
        type: CoachMessageType.tip,
        title: tip['title']!,
        message: tip['message']!,
      ));
    }

    return messages;
  }

  List<CoachMessage> _getLocalCorrelations(List<Habit> habits) {
    final messages = <CoachMessage>[];
    final activeHabits =
        habits.where((h) => !h.isPaused && !h.isArchived).toList();

    // Find habits that tend to be completed together
    for (int i = 0; i < activeHabits.length; i++) {
      for (int j = i + 1; j < activeHabits.length; j++) {
        final habitA = activeHabits[i];
        final habitB = activeHabits[j];
        int bothCompleted = 0;
        int eitherCompleted = 0;

        for (int d = 0; d < 30; d++) {
          final date = DateTime.now().subtract(Duration(days: d));
          final aCompleted = habitA.isCompletedOn(date);
          final bCompleted = habitB.isCompletedOn(date);
          if (aCompleted && bCompleted) bothCompleted++;
          if (aCompleted || bCompleted) eitherCompleted++;
        }

        if (eitherCompleted >= 10 &&
            bothCompleted / eitherCompleted > 0.7) {
          messages.add(CoachMessage(
            type: CoachMessageType.correlation,
            title: 'Habit Pair Detected',
            message:
                '"${habitA.name}" and "${habitB.name}" are often completed together. These habits reinforce each other!',
          ));
        }
      }
    }

    return messages;
  }

  String _getLocalChallenge(List<Habit> habits) {
    final challenges = [
      'Complete all your habits before noon today.',
      'Add a note to every habit you complete today.',
      'Try completing your hardest habit first thing in the morning.',
      'Increase your measurable habit target by 10% today.',
      'Complete a habit you\'ve been skipping this week.',
      'Reflect on why each habit matters to you as you complete it.',
      'Try habit stacking: pair a new habit with an existing one.',
      'Beat yesterday\'s completion count.',
    ];
    final random = Random();
    return challenges[random.nextInt(challenges.length)];
  }

  String _getLocalChat(List<Habit> habits, String userMessage) {
    final lowerMsg = userMessage.toLowerCase();
    final activeHabits =
        habits.where((h) => !h.isPaused && !h.isArchived).toList();

    if (lowerMsg.contains('streak')) {
      if (activeHabits.isEmpty) {
        return 'You don\'t have any active habits yet. Create one to start building streaks!';
      }
      final best = activeHabits.fold<Habit>(
          activeHabits.first,
          (prev, h) =>
              h.currentStreak > prev.currentStreak ? h : prev);
      return 'Your best current streak is ${best.currentStreak} days on "${best.name}". '
          'Keep it going! Consistency is the key to lasting change.';
    }

    if (lowerMsg.contains('motivat') || lowerMsg.contains('help')) {
      return 'Remember: every expert was once a beginner. The fact that you\'re tracking your habits '
          'puts you ahead of most people. Focus on showing up, not being perfect. '
          'Even 1% improvement daily leads to remarkable results over time.';
    }

    if (lowerMsg.contains('tip') || lowerMsg.contains('advice')) {
      final tips = _getTips();
      final random = Random();
      final tip = tips[random.nextInt(tips.length)];
      return '${tip['title']}: ${tip['message']}';
    }

    if (lowerMsg.contains('progress') || lowerMsg.contains('how am i')) {
      final score = getWeeklyScore(habits);
      if (score >= 80) {
        return 'Your weekly score is $score/100. You\'re doing fantastic! Keep this momentum going.';
      } else if (score >= 50) {
        return 'Your weekly score is $score/100. Good effort! Try to push for a few more completions this week.';
      } else {
        return 'Your weekly score is $score/100. Every day is a chance to restart. '
            'Pick one habit to focus on today and build from there.';
      }
    }

    return 'I\'m your habit coach! Ask me about your streaks, progress, or request motivation and tips. '
        'I\'m here to help you build lasting habits.';
  }

  // --- Cloud (Groq) API ---

  Future<List<CoachMessage>> _getCloudInsights(List<Habit> habits) async {
    final habitSummary = _buildHabitSummary(habits);
    final response = await _callGroq(
      'You are an AI habit coach. Analyze these habits and provide 2-3 actionable insights. '
      'Be encouraging but honest. Format each insight as a JSON array of objects with '
      '"type" (insight/alert/tip/milestone), "title", and "message" fields.\n\n$habitSummary',
    );
    try {
      final parsed = jsonDecode(response) as List<dynamic>;
      return parsed
          .map((e) => CoachMessage(
                type: CoachMessageType.values.firstWhere(
                  (t) => t.name == (e as Map<String, dynamic>)['type'],
                  orElse: () => CoachMessageType.insight,
                ),
                title: (e as Map<String, dynamic>)['title'] as String,
                message: e['message'] as String,
              ))
          .toList();
    } catch (_) {
      return [
        CoachMessage(
          type: CoachMessageType.insight,
          title: 'AI Coach Insight',
          message: response,
        ),
      ];
    }
  }

  Future<List<CoachMessage>> _getCloudCorrelations(List<Habit> habits) async {
    final habitSummary = _buildHabitSummary(habits);
    final response = await _callGroq(
      'Analyze correlations between these habits. Which ones reinforce each other? '
      'Which might conflict? Provide as JSON array with "title" and "message" fields.\n\n$habitSummary',
    );
    try {
      final parsed = jsonDecode(response) as List<dynamic>;
      return parsed
          .map((e) => CoachMessage(
                type: CoachMessageType.correlation,
                title: (e as Map<String, dynamic>)['title'] as String,
                message: e['message'] as String,
              ))
          .toList();
    } catch (_) {
      return [
        CoachMessage(
          type: CoachMessageType.correlation,
          title: 'Correlation Analysis',
          message: response,
        ),
      ];
    }
  }

  Future<String> _getCloudChallenge(List<Habit> habits) async {
    final habitSummary = _buildHabitSummary(habits);
    return _callGroq(
      'Based on these habits, suggest ONE specific, motivating daily challenge. '
      'Keep it under 2 sentences.\n\n$habitSummary',
    );
  }

  Future<String> _getCloudChat(List<Habit> habits, String userMessage) async {
    final habitSummary = _buildHabitSummary(habits);
    return _callGroq(
      'You are a friendly, encouraging AI habit coach. The user\'s habits:\n$habitSummary\n\n'
      'User message: $userMessage\n\n'
      'Respond helpfully in 2-3 sentences. Be specific about their habits when possible.',
    );
  }

  Future<String> _callGroq(String prompt) async {
    final response = await http.post(
      Uri.parse(_groqApiUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'llama-3.1-8b-instant',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 500,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>;
      if (choices.isNotEmpty) {
        final choice = choices[0] as Map<String, dynamic>;
        final message = choice['message'] as Map<String, dynamic>;
        return message['content'] as String;
      }
    }
    throw Exception('Groq API error: ${response.statusCode}');
  }

  String _buildHabitSummary(List<Habit> habits) {
    final buffer = StringBuffer();
    for (final habit in habits.where((h) => !h.isArchived)) {
      buffer.writeln(
          '- ${habit.name}: streak=${habit.currentStreak}, '
          'rate(30d)=${(habit.completionRate(30) * 100).round()}%, '
          'time=${habit.timeOfDay.name}, '
          'paused=${habit.isPaused}');
    }
    return buffer.toString();
  }

  DateTime? _findLastCompletionDate(Habit habit) {
    DateTime? latest;
    for (final entry in habit.completedDates.entries) {
      if (entry.value.completed) {
        final date = DateTime.tryParse(entry.key);
        if (date != null && (latest == null || date.isAfter(latest))) {
          latest = date;
        }
      }
    }
    return latest;
  }

  List<Map<String, String>> _getTips() {
    return [
      {
        'title': 'The 2-Minute Rule',
        'message':
            'If a habit takes less than 2 minutes, do it right now. For bigger habits, start with just 2 minutes to build momentum.',
      },
      {
        'title': 'Habit Stacking',
        'message':
            'Link a new habit to an existing one. "After I [existing habit], I will [new habit]." This uses existing neural pathways.',
      },
      {
        'title': 'Environment Design',
        'message':
            'Make good habits obvious and easy. Put your running shoes by the door. Keep your water bottle on your desk.',
      },
      {
        'title': 'Never Miss Twice',
        'message':
            'Missing one day is an accident. Missing two is a pattern. If you miss today, make tomorrow non-negotiable.',
      },
      {
        'title': 'Identity-Based Habits',
        'message':
            'Focus on who you want to become, not what you want to achieve. "I am a runner" is more powerful than "I want to run."',
      },
      {
        'title': 'Reward Yourself',
        'message':
            'Pair habits with immediate rewards. The brain needs a signal that a behavior is worth remembering.',
      },
      {
        'title': 'Track Visually',
        'message':
            'Seeing your streak grow is one of the most powerful motivators. Don\'t break the chain!',
      },
      {
        'title': 'Start Small',
        'message':
            'Begin with a habit so easy you can\'t say no. One pushup. One page. One minute of meditation.',
      },
    ];
  }
}
