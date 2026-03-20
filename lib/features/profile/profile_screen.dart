import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habit_coach/core/design/app_spacing.dart';
import 'package:habit_coach/core/gamification/achievements_data.dart';
import 'package:habit_coach/core/gamification/xp_engine.dart';
import 'package:habit_coach/core/models/user_profile.dart';
import 'package:habit_coach/core/providers/habit_provider.dart';
import 'package:habit_coach/core/widgets/app_card.dart';
import 'package:habit_coach/features/paywall/paywall_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  UserProfile _profile = UserProfile(
    name: 'User',
    memberSince: DateTime.now(),
  );
  bool _notificationsEnabled = true;
  String _themeMode = 'system'; // light, dark, system

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('user_profile');
      if (profileJson != null) {
        setState(() {
          _profile = UserProfile.fromJsonString(profileJson);
          _themeMode = _profile.preferences.themeMode;
        });
      }
      final notif = prefs.getBool('notifications_enabled');
      if (notif != null) {
        setState(() => _notificationsEnabled = notif);
      }
    } catch (_) {
      // Use defaults
    }
  }

  Future<void> _saveNotificationPref(bool value) async {
    setState(() => _notificationsEnabled = value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', value);
    } catch (_) {}
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete all your habits, progress, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
              } catch (_) {}
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data has been cleared.')),
                );
              }
            },
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final habits = ref.watch(habitsProvider);

    // Calculate total XP from habits
    final totalXP =
        habits.fold<int>(0, (sum, h) => sum + h.totalXP) + _profile.totalXP;
    final level = XPEngine.getLevelForXP(totalXP);
    final xpInLevel = totalXP - (level.number > 1 ? _prevLevelXP(level) : 0);
    final xpNeeded = level.nextLevelXP - (level.number > 1 ? _prevLevelXP(level) : 0);
    final xpProgress = xpNeeded > 0 ? (xpInLevel / xpNeeded).clamp(0.0, 1.0) : 1.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            _buildHeader(cs, tt, level, xpProgress, totalXP),
            AppSpacing.vGap24,

            // --- Achievements ---
            _SectionHeader(title: 'Your Badges'),
            AppSpacing.vGap8,
            _buildAchievements(cs, tt),
            AppSpacing.vGap24,

            // --- Settings ---
            _SectionHeader(title: 'Settings'),
            AppSpacing.vGap8,
            _buildSettings(cs, tt),
            AppSpacing.vGap24,

            // --- Upgrade Card ---
            _buildUpgradeCard(cs, tt),
            AppSpacing.vGap32,
          ],
        ),
      ),
    );
  }

  int _prevLevelXP(Level level) {
    // Approximate: the XP threshold for the current level
    // We use getLevelForXP with currentXP - 1 but simpler to
    // just compute from Level data
    final lvl = level.number;
    const thresholds = [0, 0, 100, 300, 600, 1000, 2000, 5000, 10000, 25000, 50000];
    if (lvl < thresholds.length) return thresholds[lvl];
    return 0;
  }

  Widget _buildHeader(
      ColorScheme cs, TextTheme tt, Level level, double xpProgress, int totalXP) {
    final initials = _profile.name.isNotEmpty
        ? _profile.name
            .split(' ')
            .where((s) => s.isNotEmpty)
            .take(2)
            .map((s) => s[0].toUpperCase())
            .join()
        : 'U';

    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: cs.primaryContainer,
            child: Text(
              initials,
              style: tt.headlineMedium?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AppSpacing.vGap12,
          Text(
            _profile.name,
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.vGap4,
          Text(
            'Member since ${DateFormat.yMMMd().format(_profile.memberSince)}',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          AppSpacing.vGap12,
          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: AppSpacing.borderRadiusFull,
            ),
            child: Text(
              'Level ${level.number} \u{2014} ${level.name}',
              style: tt.labelLarge?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppSpacing.vGap12,
          // XP progress bar
          Row(
            children: [
              Text(
                '$totalXP XP',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              AppSpacing.hGap8,
              Expanded(
                child: ClipRRect(
                  borderRadius: AppSpacing.borderRadiusFull,
                  child: LinearProgressIndicator(
                    value: xpProgress,
                    minHeight: 8,
                    backgroundColor: cs.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                  ),
                ),
              ),
              AppSpacing.hGap8,
              Text(
                '${level.nextLevelXP} XP',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(ColorScheme cs, TextTheme tt) {
    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: allAchievements.length,
        itemBuilder: (context, index) {
          final achievement = allAchievements[index];
          final unlocked = achievement.isUnlocked;

          return GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        unlocked ? achievement.icon : '\u{1F512}',
                        style: const TextStyle(fontSize: 48),
                      ),
                      AppSpacing.vGap12,
                      Text(
                        achievement.name,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.vGap8,
                      Text(
                        achievement.description,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.vGap8,
                      if (!unlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: AppSpacing.borderRadiusFull,
                          ),
                          child: Text(
                            achievement.requirement,
                            style: tt.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      if (unlocked)
                        Text(
                          '+${achievement.xpReward} XP',
                          style: tt.labelLarge?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      AppSpacing.vGap24,
                    ],
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: unlocked
                    ? cs.primaryContainer.withValues(alpha: 0.4)
                    : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: AppSpacing.borderRadiusMedium,
                border: Border.all(
                  color: unlocked
                      ? cs.primary.withValues(alpha: 0.3)
                      : cs.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    unlocked ? achievement.icon : '\u{1F512}',
                    style: TextStyle(
                      fontSize: 28,
                      color: unlocked ? null : cs.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.vGap4,
                  Text(
                    achievement.name,
                    style: tt.labelSmall?.copyWith(
                      color: unlocked ? cs.onSurface : cs.onSurfaceVariant,
                      fontWeight:
                          unlocked ? FontWeight.w600 : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettings(ColorScheme cs, TextTheme tt) {
    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Appearance
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Appearance'),
              subtitle: Text(
                _themeMode == 'light'
                    ? 'Light'
                    : _themeMode == 'dark'
                        ? 'Dark'
                        : 'System',
              ),
              trailing: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'light',
                    icon: Icon(Icons.light_mode, size: 16),
                  ),
                  ButtonSegment(
                    value: 'dark',
                    icon: Icon(Icons.dark_mode, size: 16),
                  ),
                  ButtonSegment(
                    value: 'system',
                    icon: Icon(Icons.settings_suggest, size: 16),
                  ),
                ],
                selected: {_themeMode},
                onSelectionChanged: (selected) {
                  setState(() => _themeMode = selected.first);
                },
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            const Divider(height: 1),

            // Notifications
            SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              subtitle: const Text('Daily reminders'),
              value: _notificationsEnabled,
              onChanged: _saveNotificationPref,
            ),
            const Divider(height: 1),

            // Export Data
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Export Data (JSON)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                final habits = ref.read(habitsProvider);
                final jsonData = jsonEncode(
                  habits.map((h) => h.toJson()).toList(),
                );
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Exported Data'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: SingleChildScrollView(
                        child: SelectableText(
                          jsonData,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                      FilledButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: jsonData),
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('JSON copied to clipboard!'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy to Clipboard'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 1),

            // Clear Data
            ListTile(
              leading: Icon(Icons.delete_outline, color: cs.error),
              title: Text('Clear All Data',
                  style: TextStyle(color: cs.error)),
              onTap: _showClearDataDialog,
            ),
            const Divider(height: 1),

            // About
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('Version 1.0.0'),
            ),
            const Divider(height: 1),

            // Rate App
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: const Text('Rate App'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Thank you for your support!')),
                );
              },
            ),
            const Divider(height: 1),

            // Privacy Policy
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Privacy Policy'),
                    content: const Text(
                      'HabitAI stores all your data locally on your device. '
                      'We do not collect, transmit, or share any personal information. '
                      'Your habits, streaks, and notes never leave your phone.',
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Got it'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeCard(ColorScheme cs, TextTheme tt) {
    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PaywallScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF7C3AED),
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppSpacing.borderRadiusLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '\u{2728}',
                    style: TextStyle(fontSize: 28),
                  ),
                  AppSpacing.hGap8,
                  Text(
                    'Upgrade to Pro',
                    style: tt.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              AppSpacing.vGap12,
              ...[
                'Unlimited habits',
                'AI-powered coaching',
                'Detailed analytics & export',
                'Premium themes',
                'No ads',
              ].map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.white70, size: 16),
                      AppSpacing.hGap8,
                      Text(f,
                          style: tt.bodySmall?.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              AppSpacing.vGap12,
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Text(
                    'View Plans',
                    style: tt.labelLarge?.copyWith(
                      color: const Color(0xFF7C3AED),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
