import 'package:flutter/material.dart';

/// App-wide color definitions for HabitAI.
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────
  static const Color primaryIndigo = Color(0xFF6366F1);

  // ── Preset Habit Colors ────────────────────────────────────────────────
  static const List<HabitColor> habitColors = [
    HabitColor('Indigo', Color(0xFF6366F1), Color(0xFFE0E7FF)),
    HabitColor('Rose', Color(0xFFF43F5E), Color(0xFFFFE4E6)),
    HabitColor('Emerald', Color(0xFF10B981), Color(0xFFD1FAE5)),
    HabitColor('Amber', Color(0xFFF59E0B), Color(0xFFFEF3C7)),
    HabitColor('Sky', Color(0xFF0EA5E9), Color(0xFFE0F2FE)),
    HabitColor('Violet', Color(0xFF8B5CF6), Color(0xFFEDE9FE)),
    HabitColor('Pink', Color(0xFFEC4899), Color(0xFFFCE7F3)),
    HabitColor('Teal', Color(0xFF14B8A6), Color(0xFFCCFBF1)),
    HabitColor('Orange', Color(0xFFF97316), Color(0xFFFFF7ED)),
    HabitColor('Cyan', Color(0xFF06B6D4), Color(0xFFCFFAFE)),
  ];

  // ── Streak Fire Gradient ───────────────────────────────────────────────
  static const List<Color> streakFireGradient = [
    Color(0xFFFF6B35),
    Color(0xFFF7931E),
    Color(0xFFFFCD00),
  ];

  static const List<Color> streakFireGradientIntense = [
    Color(0xFFFF4500),
    Color(0xFFFF6B35),
    Color(0xFFF7931E),
    Color(0xFFFFCD00),
  ];

  // ── Heatmap Intensity ──────────────────────────────────────────────────
  static const Color heatmapNone = Color(0xFFE5E7EB);
  static const Color heatmapLight = Color(0xFFC7D2FE);
  static const Color heatmapMedium = Color(0xFF818CF8);
  static const Color heatmapStrong = Color(0xFF6366F1);
  static const Color heatmapMax = Color(0xFF4338CA);

  static const List<Color> heatmapLevels = [
    heatmapNone,
    heatmapLight,
    heatmapMedium,
    heatmapStrong,
    heatmapMax,
  ];

  // Dark-mode heatmap variants
  static const Color heatmapNoneDark = Color(0xFF1F2937);
  static const Color heatmapLightDark = Color(0xFF3730A3);
  static const Color heatmapMediumDark = Color(0xFF4F46E5);
  static const Color heatmapStrongDark = Color(0xFF6366F1);
  static const Color heatmapMaxDark = Color(0xFF818CF8);

  static const List<Color> heatmapLevelsDark = [
    heatmapNoneDark,
    heatmapLightDark,
    heatmapMediumDark,
    heatmapStrongDark,
    heatmapMaxDark,
  ];

  // ── Semantic ───────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ── Glass Morphism ─────────────────────────────────────────────────────
  static Color glassWhite = Colors.white.withValues(alpha: 0.15);
  static Color glassBorder = Colors.white.withValues(alpha: 0.25);
  static Color glassWhiteDark = Colors.white.withValues(alpha: 0.08);
  static Color glassBorderDark = Colors.white.withValues(alpha: 0.12);
  static Color glassOverlay = Colors.black.withValues(alpha: 0.3);
}

/// A named color pair for habits (main + light variant).
class HabitColor {
  const HabitColor(this.name, this.color, this.light);

  final String name;
  final Color color;
  final Color light;
}
