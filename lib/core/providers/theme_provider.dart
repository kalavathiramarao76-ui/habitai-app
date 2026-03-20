import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';
import 'habit_provider.dart';

/// Extended theme mode that includes AMOLED option.
enum AppThemeMode { light, dark, system, amoled }

class ThemeModeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    _loadTheme();
    return AppThemeMode.system;
  }

  StorageService get _storage => ref.read(storageServiceProvider);

  Future<void> _loadTheme() async {
    final saved = await _storage.getSetting('themeMode');
    if (saved != null) {
      state = AppThemeMode.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => AppThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    await _storage.setSetting('themeMode', mode.name);
  }

  /// Convert AppThemeMode to Flutter's ThemeMode.
  ThemeMode get flutterThemeMode {
    switch (state) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  bool get isAmoled => state == AppThemeMode.amoled;
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, AppThemeMode>(ThemeModeNotifier.new);
