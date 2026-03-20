import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habit_coach/core/design/app_spacing.dart';
import 'package:habit_coach/core/providers/user_provider.dart';
import 'package:habit_coach/core/widgets/app_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Set<String> _selectedCategories = {};

  static const _totalPages = 5;

  static const List<List<Color>> _pageGradients = [
    [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    [Color(0xFF3B82F6), Color(0xFF06B6D4)],
    [Color(0xFFFF6B35), Color(0xFFF59E0B)],
    [Color(0xFF10B981), Color(0xFF14B8A6)],
    [Color(0xFFEC4899), Color(0xFF8B5CF6)],
  ];

  static const List<String> _categories = [
    'Health',
    'Fitness',
    'Mindfulness',
    'Learning',
    'Productivity',
    'Social',
    'Finance',
    'Creativity',
  ];

  static const List<String> _categoryIcons = [
    '\u{2764}\u{FE0F}',
    '\u{1F4AA}',
    '\u{1F9D8}',
    '\u{1F4DA}',
    '\u{1F680}',
    '\u{1F91D}',
    '\u{1F4B0}',
    '\u{1F3A8}',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (_selectedCategories.isNotEmpty) {
      await prefs.setStringList(
          'selected_categories', _selectedCategories.toList());
      ref
          .read(userProvider.notifier)
          .updateCategories(_selectedCategories.toList());
    }
    if (mounted) {
      context.go('/home');
    }
  }

  void _nextPage() {
    if (_currentPage == _totalPages - 1) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skip() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page view
          PageView(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: [
              _buildWelcomePage(),
              _buildAICoachPage(),
              _buildStreaksPage(),
              _buildCategoriesPage(),
              _buildReadyPage(),
            ],
          ),

          // Skip button top-right
          if (_currentPage < _totalPages - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 8,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dot indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_totalPages, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                    );
                  }),
                ),
                AppSpacing.vGap24,
                // Next / Get Started button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: AppButton(
                    label: _currentPage == _totalPages - 1
                        ? 'Start Building Habits'
                        : 'Next',
                    onPressed: _nextPage,
                    size: AppButtonSize.large,
                    expand: true,
                    trailingIcon: _currentPage < _totalPages - 1
                        ? Icons.arrow_forward_rounded
                        : Icons.rocket_launch_rounded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageScaffold({
    required int pageIndex,
    required String emoji,
    required String title,
    required String subtitle,
    Widget? extraContent,
  }) {
    final gradientColors = _pageGradients[pageIndex];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Large emoji
              Text(
                emoji,
                style: const TextStyle(fontSize: 120),
              ),
              AppSpacing.vGap32,
              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGap16,
              // Subtitle
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              if (extraContent != null) ...[
                AppSpacing.vGap24,
                extraContent,
              ],
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return _buildPageScaffold(
      pageIndex: 0,
      emoji: '\u{1F31F}',
      title: 'Build habits\nthat stick',
      subtitle:
          'Welcome to HabitAI — your personal AI-powered habit coach that helps you build lasting routines.',
    );
  }

  Widget _buildAICoachPage() {
    return _buildPageScaffold(
      pageIndex: 1,
      emoji: '\u{1F9E0}',
      title: 'AI-powered\ncoaching',
      subtitle:
          'Get personalized insights, smart reminders, and motivational nudges from your AI coach tailored to your goals.',
    );
  }

  Widget _buildStreaksPage() {
    return _buildPageScaffold(
      pageIndex: 2,
      emoji: '\u{1F525}',
      title: 'Track your\nstreaks',
      subtitle:
          'Stay motivated with streak tracking, heatmaps, and detailed statistics. Watch your consistency grow day by day.',
    );
  }

  Widget _buildCategoriesPage() {
    final gradientColors = _pageGradients[3];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Text(
                '\u{1F3AF}',
                style: TextStyle(fontSize: 100),
              ),
              AppSpacing.vGap24,
              Text(
                'Choose your focus',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGap8,
              Text(
                'Select categories that interest you',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGap24,
              // Category chips grid
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: List.generate(_categories.length, (index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(
                      '${_categoryIcons[index]}  $category',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.9),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    selectedColor: Colors.white.withValues(alpha: 0.35),
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  );
                }),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadyPage() {
    return _buildPageScaffold(
      pageIndex: 4,
      emoji: '\u{1F389}',
      title: 'Ready to start!',
      subtitle:
          'Your journey to better habits begins now. Let\'s build something amazing together, one day at a time.',
    );
  }
}
