import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_coach/theme/app_theme.dart';
import 'package:habit_coach/services/storage_service.dart';
import 'package:habit_coach/screens/home_screen.dart';
import 'package:habit_coach/screens/paywall_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const HabitCoachApp());
}

class HabitCoachApp extends StatefulWidget {
  const HabitCoachApp({super.key});

  @override
  State<HabitCoachApp> createState() => _HabitCoachAppState();
}

class _HabitCoachAppState extends State<HabitCoachApp> {
  bool _isDarkMode = false;
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await _storage.isDarkMode();
    if (mounted) {
      setState(() => _isDarkMode = isDark);
    }
  }

  void _toggleTheme() async {
    setState(() => _isDarkMode = !_isDarkMode);
    await _storage.setDarkMode(_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        onToggleTheme: _toggleTheme,
        isDark: _isDarkMode,
      ),
      routes: {
        '/paywall': (context) => const PaywallScreen(),
      },
    );
  }
}
