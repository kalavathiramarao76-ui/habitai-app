import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Animation duration constants
// ─────────────────────────────────────────────────────────────────────────────
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

// ─────────────────────────────────────────────────────────────────────────────
// ThemeExtension: Habit-specific colors
// ─────────────────────────────────────────────────────────────────────────────
class HabitThemeColors extends ThemeExtension<HabitThemeColors> {
  const HabitThemeColors({
    required this.streakFire,
    required this.successGreen,
    required this.warningAmber,
    required this.errorRed,
    required this.infoBlue,
    required this.heatmapNone,
    required this.heatmapLight,
    required this.heatmapMedium,
    required this.heatmapStrong,
    required this.heatmapMax,
  });

  final Color streakFire;
  final Color successGreen;
  final Color warningAmber;
  final Color errorRed;
  final Color infoBlue;
  final Color heatmapNone;
  final Color heatmapLight;
  final Color heatmapMedium;
  final Color heatmapStrong;
  final Color heatmapMax;

  static const HabitThemeColors light = HabitThemeColors(
    streakFire: Color(0xFFFF6B35),
    successGreen: AppColors.success,
    warningAmber: AppColors.warning,
    errorRed: AppColors.error,
    infoBlue: AppColors.info,
    heatmapNone: AppColors.heatmapNone,
    heatmapLight: AppColors.heatmapLight,
    heatmapMedium: AppColors.heatmapMedium,
    heatmapStrong: AppColors.heatmapStrong,
    heatmapMax: AppColors.heatmapMax,
  );

  static const HabitThemeColors dark = HabitThemeColors(
    streakFire: Color(0xFFFF8C5A),
    successGreen: Color(0xFF34D399),
    warningAmber: Color(0xFFFBBF24),
    errorRed: Color(0xFFF87171),
    infoBlue: Color(0xFF60A5FA),
    heatmapNone: AppColors.heatmapNoneDark,
    heatmapLight: AppColors.heatmapLightDark,
    heatmapMedium: AppColors.heatmapMediumDark,
    heatmapStrong: AppColors.heatmapStrongDark,
    heatmapMax: AppColors.heatmapMaxDark,
  );

  @override
  HabitThemeColors copyWith({
    Color? streakFire,
    Color? successGreen,
    Color? warningAmber,
    Color? errorRed,
    Color? infoBlue,
    Color? heatmapNone,
    Color? heatmapLight,
    Color? heatmapMedium,
    Color? heatmapStrong,
    Color? heatmapMax,
  }) {
    return HabitThemeColors(
      streakFire: streakFire ?? this.streakFire,
      successGreen: successGreen ?? this.successGreen,
      warningAmber: warningAmber ?? this.warningAmber,
      errorRed: errorRed ?? this.errorRed,
      infoBlue: infoBlue ?? this.infoBlue,
      heatmapNone: heatmapNone ?? this.heatmapNone,
      heatmapLight: heatmapLight ?? this.heatmapLight,
      heatmapMedium: heatmapMedium ?? this.heatmapMedium,
      heatmapStrong: heatmapStrong ?? this.heatmapStrong,
      heatmapMax: heatmapMax ?? this.heatmapMax,
    );
  }

  @override
  HabitThemeColors lerp(ThemeExtension<HabitThemeColors>? other, double t) {
    if (other is! HabitThemeColors) return this;
    return HabitThemeColors(
      streakFire: Color.lerp(streakFire, other.streakFire, t)!,
      successGreen: Color.lerp(successGreen, other.successGreen, t)!,
      warningAmber: Color.lerp(warningAmber, other.warningAmber, t)!,
      errorRed: Color.lerp(errorRed, other.errorRed, t)!,
      infoBlue: Color.lerp(infoBlue, other.infoBlue, t)!,
      heatmapNone: Color.lerp(heatmapNone, other.heatmapNone, t)!,
      heatmapLight: Color.lerp(heatmapLight, other.heatmapLight, t)!,
      heatmapMedium: Color.lerp(heatmapMedium, other.heatmapMedium, t)!,
      heatmapStrong: Color.lerp(heatmapStrong, other.heatmapStrong, t)!,
      heatmapMax: Color.lerp(heatmapMax, other.heatmapMax, t)!,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme modes
// ─────────────────────────────────────────────────────────────────────────────
enum AppThemeMode { light, dark, amoledBlack }

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme builder
// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static const Color _seed = AppColors.primaryIndigo;

  // ── Public accessors ───────────────────────────────────────────────────
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData amoledBlack() => _buildAmoled();

  static ThemeData fromMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return light();
      case AppThemeMode.dark:
        return dark();
      case AppThemeMode.amoledBlack:
        return amoledBlack();
    }
  }

  // ── Private builders ───────────────────────────────────────────────────
  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    final isLight = brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: isLight ? 1 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLarge,
        ),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 44),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMedium,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 44),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMedium,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, 44),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMedium,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMedium,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMedium,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMedium,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.primaryContainer,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      extensions: [
        isLight ? HabitThemeColors.light : HabitThemeColors.dark,
      ],
    );
  }

  static ThemeData _buildAmoled() {
    final baseDark = _build(Brightness.dark);
    final baseScheme = baseDark.colorScheme;

    final amoledScheme = baseScheme.copyWith(
      surface: Colors.black,
      onSurface: Colors.white,
      surfaceContainerHighest: const Color(0xFF121212),
    );

    return baseDark.copyWith(
      colorScheme: amoledScheme,
      scaffoldBackgroundColor: Colors.black,
      cardTheme: baseDark.cardTheme.copyWith(
        color: const Color(0xFF0A0A0A),
      ),
      appBarTheme: baseDark.appBarTheme.copyWith(
        backgroundColor: Colors.black,
      ),
      navigationBarTheme: baseDark.navigationBarTheme.copyWith(
        backgroundColor: Colors.black,
      ),
      bottomNavigationBarTheme: baseDark.bottomNavigationBarTheme.copyWith(
        backgroundColor: Colors.black,
      ),
    );
  }

  // ── Text theme ─────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    final headingStyle = GoogleFonts.plusJakartaSans(
      color: colorScheme.onSurface,
    );
    final bodyStyle = GoogleFonts.inter(
      color: colorScheme.onSurface,
    );

    return TextTheme(
      // Headings – Plus Jakarta Sans
      displayLarge: headingStyle.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: headingStyle.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        height: 1.16,
      ),
      displaySmall: headingStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 1.22,
      ),
      headlineLarge: headingStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      headlineMedium: headingStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.29,
      ),
      headlineSmall: headingStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
      ),
      // Titles – Plus Jakarta Sans
      titleLarge: headingStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.27,
      ),
      titleMedium: headingStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      titleSmall: headingStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      // Body – Inter
      bodyLarge: bodyStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: bodyStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: bodyStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      // Labels – Inter
      labelLarge: bodyStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: bodyStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: bodyStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }
}
