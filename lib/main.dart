import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habit_coach/core/design/app_theme.dart' hide AppThemeMode;
import 'package:habit_coach/core/services/storage_service.dart';
import 'package:habit_coach/core/providers/theme_provider.dart';
import 'package:habit_coach/features/onboarding/onboarding_screen.dart';
import 'package:habit_coach/features/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().initStorage();
  runApp(const ProviderScope(child: HabitAIApp()));
}

/// Provider for the initial route based on onboarding status.
final _initialLocationProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
  return onboardingComplete ? '/home' : '/onboarding';
});

class HabitAIApp extends ConsumerWidget {
  const HabitAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final initialLocation = ref.watch(_initialLocationProvider);

    return initialLocation.when(
      data: (location) {
        final router = GoRouter(
          initialLocation: location,
          routes: [
            GoRoute(
              path: '/onboarding',
              builder: (context, state) => const OnboardingScreen(),
            ),
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/add-habit',
              builder: (context, state) => const _AddHabitPlaceholder(),
            ),
          ],
        );

        // Determine Flutter ThemeMode
        ThemeMode flutterThemeMode;
        switch (themeMode) {
          case AppThemeMode.light:
            flutterThemeMode = ThemeMode.light;
          case AppThemeMode.dark:
          case AppThemeMode.amoled:
            flutterThemeMode = ThemeMode.dark;
          case AppThemeMode.system:
            flutterThemeMode = ThemeMode.system;
        }

        // Determine dark theme
        final darkTheme = themeMode == AppThemeMode.amoled
            ? AppTheme.amoledBlack()
            : AppTheme.dark();

        return MaterialApp.router(
          title: 'HabitAI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: darkTheme,
          themeMode: flutterThemeMode,
          routerConfig: router,
        );
      },
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Center(child: Text('Something went wrong')),
        ),
      ),
    );
  }
}

/// Placeholder screen for Add Habit route.
class _AddHabitPlaceholder extends StatelessWidget {
  const _AddHabitPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Habit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction_rounded, size: 48),
            SizedBox(height: 12),
            Text('Add Habit screen coming soon'),
          ],
        ),
      ),
    );
  }
}
