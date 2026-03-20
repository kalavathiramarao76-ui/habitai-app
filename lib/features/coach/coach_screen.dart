import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_coach/core/design/app_colors.dart';
import 'package:habit_coach/core/design/app_spacing.dart';
import 'package:habit_coach/core/models/coach_message.dart';
import 'package:habit_coach/core/providers/habit_provider.dart';
import 'package:habit_coach/core/services/ai_service.dart';
import 'package:habit_coach/core/widgets/animated_counter.dart';
import 'package:habit_coach/core/widgets/animated_progress_ring.dart';
import 'package:habit_coach/core/widgets/app_card.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final _aiService = AiService();
  final _chatController = TextEditingController();
  final _scrollController = ScrollController();

  List<CoachMessage> _insights = [];
  final List<_ChatBubble> _chatHistory = [];
  bool _loadingInsights = false;
  bool _sendingMessage = false;
  int _weeklyScore = 0;

  static const _motivationalLines = [
    'Small steps every day lead to big results.',
    'Consistency beats perfection, always.',
    'You are what you repeatedly do.',
    'One day or day one. You decide.',
    'Progress, not perfection.',
    'The secret of getting ahead is getting started.',
  ];

  String get _currentMotivation {
    final idx = DateTime.now().minute % _motivationalLines.length;
    return _motivationalLines[idx];
  }

  @override
  void initState() {
    super.initState();
    // Load insights after frame renders so ref is available
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInsights());
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInsights() async {
    final habits = ref.read(habitsProvider);
    setState(() {
      _loadingInsights = true;
      _weeklyScore = _aiService.getWeeklyScore(habits);
    });

    try {
      final insights = await _aiService.getCoachInsights(habits);
      if (mounted) {
        setState(() {
          _insights = insights;
          _loadingInsights = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _insights = _fallbackInsights();
          _loadingInsights = false;
        });
      }
    }
  }

  List<CoachMessage> _fallbackInsights() {
    return [
      CoachMessage(
        type: CoachMessageType.tip,
        title: 'Stay Consistent',
        message:
            'The key to building habits is showing up every day, even if just for a minute.',
      ),
      CoachMessage(
        type: CoachMessageType.insight,
        title: 'Track Your Progress',
        message:
            'Reviewing your stats regularly helps you stay motivated and spot patterns.',
      ),
    ];
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    _chatController.clear();
    setState(() {
      _chatHistory.add(_ChatBubble(text: text, isUser: true));
      _sendingMessage = true;
    });
    _scrollToBottom();

    final habits = ref.read(habitsProvider);
    try {
      final response = await _aiService.chatWithCoach(habits, text);
      if (mounted) {
        setState(() {
          _chatHistory.add(_ChatBubble(text: response, isUser: false));
          _sendingMessage = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _chatHistory.add(const _ChatBubble(
            text:
                'Sorry, I couldn\'t process that right now. Try asking about your streaks, progress, or tips!',
            isUser: false,
          ));
          _sendingMessage = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _scoreColor(int score) {
    if (score <= 30) return AppColors.error;
    if (score <= 60) return AppColors.warning;
    if (score <= 80) return AppColors.success;
    return const Color(0xFFFFD700); // gold
  }

  String _insightIcon(CoachMessageType type) {
    switch (type) {
      case CoachMessageType.correlation:
        return '\u{1F517}';
      case CoachMessageType.alert:
        return '\u{26A0}\u{FE0F}';
      case CoachMessageType.milestone:
        return '\u{1F3C6}';
      case CoachMessageType.tip:
        return '\u{1F4A1}';
      case CoachMessageType.insight:
        return '\u{1F4CA}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Coach')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: [
                // --- Hero Card ---
                _buildHeroCard(cs, tt),
                AppSpacing.vGap24,

                // --- Weekly Score Ring ---
                _buildWeeklyScore(cs, tt),
                AppSpacing.vGap24,

                // --- Insights ---
                Padding(
                  padding: AppSpacing.screenPaddingHorizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Insights',
                          style: tt.titleMedium),
                      TextButton.icon(
                        onPressed: _loadingInsights ? null : _loadInsights,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vGap8,
                if (_loadingInsights)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_insights.isEmpty)
                  Padding(
                    padding: AppSpacing.screenPaddingHorizontal,
                    child: Text(
                      'No insights available yet. Keep tracking your habits!',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  ..._insights.map((msg) => _buildInsightCard(msg, cs, tt)),
                AppSpacing.vGap24,

                // --- Chat Section ---
                Padding(
                  padding: AppSpacing.screenPaddingHorizontal,
                  child: Text('Ask Your Coach', style: tt.titleMedium),
                ),
                AppSpacing.vGap8,
                ..._chatHistory.map((bubble) =>
                    _buildChatBubble(bubble, cs, tt)),
                if (_sendingMessage)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: SizedBox(
                          width: 40,
                          height: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              3,
                              (i) => Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: cs.onSurfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                AppSpacing.vGap16,
              ],
            ),
          ),
          // --- Chat Input ---
          _buildChatInput(cs, tt),
        ],
      ),
    );
  }

  Widget _buildHeroCard(ColorScheme cs, TextTheme tt) {
    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary,
              cs.tertiary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppSpacing.borderRadiusLarge,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your AI Coach',
                    style: tt.titleLarge?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.vGap8,
                  Text(
                    _currentMotivation,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hGap16,
            const Text(
              '\u{1F9E0}',
              style: TextStyle(fontSize: 56),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyScore(ColorScheme cs, TextTheme tt) {
    final color = _scoreColor(_weeklyScore);
    return Center(
      child: Column(
        children: [
          AnimatedProgressRing(
            progress: _weeklyScore / 100,
            size: 140,
            strokeWidth: 12,
            showGlow: true,
            gradientColors: [color, color.withValues(alpha: 0.6)],
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedCounter(
                  value: _weeklyScore,
                  style: tt.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '/100',
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          AppSpacing.vGap8,
          Text(
            'Weekly Score',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
      CoachMessage msg, ColorScheme cs, TextTheme tt) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: AppCard(
        variant: AppCardVariant.outlined,
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_insightIcon(msg.type),
                          style: const TextStyle(fontSize: 24)),
                      AppSpacing.hGap8,
                      Expanded(
                        child: Text(msg.title, style: tt.titleMedium),
                      ),
                    ],
                  ),
                  AppSpacing.vGap16,
                  Text(msg.message, style: tt.bodyLarge),
                  AppSpacing.vGap24,
                ],
              ),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _insightIcon(msg.type),
              style: const TextStyle(fontSize: 24),
            ),
            AppSpacing.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.title,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  AppSpacing.vGap4,
                  Text(
                    msg.message,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(
      _ChatBubble bubble, ColorScheme cs, TextTheme tt) {
    final isUser = bubble.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isUser ? cs.primary : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft:
                  isUser ? const Radius.circular(16) : Radius.zero,
              bottomRight:
                  isUser ? Radius.zero : const Radius.circular(16),
            ),
          ),
          child: Text(
            bubble.text,
            style: tt.bodyMedium?.copyWith(
              color: isUser ? cs.onPrimary : cs.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatInput(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _chatController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Ask your coach...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            AppSpacing.hGap8,
            IconButton.filled(
              onPressed: _sendingMessage ? null : _sendMessage,
              icon: const Icon(Icons.send_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble {
  const _ChatBubble({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}
