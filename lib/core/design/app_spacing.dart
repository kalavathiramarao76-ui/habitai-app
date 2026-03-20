import 'package:flutter/material.dart';

/// Spacing, gap, and border-radius tokens for HabitAI.
class AppSpacing {
  AppSpacing._();

  // ── Raw values ─────────────────────────────────────────────────────────
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // ── EdgeInsets presets ──────────────────────────────────────────────────
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: lg,
  );

  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(
    horizontal: md,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(sm);

  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  static const EdgeInsets sectionGap = EdgeInsets.only(bottom: lg);

  // ── SizedBox gap presets ───────────────────────────────────────────────
  static const SizedBox gap4 = SizedBox(height: xs, width: xs);
  static const SizedBox gap8 = SizedBox(height: sm, width: sm);
  static const SizedBox gap12 = SizedBox(height: 12, width: 12);
  static const SizedBox gap16 = SizedBox(height: md, width: md);
  static const SizedBox gap24 = SizedBox(height: lg, width: lg);
  static const SizedBox gap32 = SizedBox(height: xl, width: xl);

  // Vertical-only gaps (commonly used in Column layouts)
  static const SizedBox vGap4 = SizedBox(height: xs);
  static const SizedBox vGap8 = SizedBox(height: sm);
  static const SizedBox vGap12 = SizedBox(height: 12);
  static const SizedBox vGap16 = SizedBox(height: md);
  static const SizedBox vGap24 = SizedBox(height: lg);
  static const SizedBox vGap32 = SizedBox(height: xl);
  static const SizedBox vGap48 = SizedBox(height: xxl);

  // Horizontal-only gaps (commonly used in Row layouts)
  static const SizedBox hGap4 = SizedBox(width: xs);
  static const SizedBox hGap8 = SizedBox(width: sm);
  static const SizedBox hGap12 = SizedBox(width: 12);
  static const SizedBox hGap16 = SizedBox(width: md);
  static const SizedBox hGap24 = SizedBox(width: lg);
  static const SizedBox hGap32 = SizedBox(width: xl);

  // ── Border Radius presets ──────────────────────────────────────────────
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXL = 24;
  static const double radiusFull = 999;

  static const BorderRadius borderRadiusSmall = BorderRadius.all(
    Radius.circular(radiusSmall),
  );
  static const BorderRadius borderRadiusMedium = BorderRadius.all(
    Radius.circular(radiusMedium),
  );
  static const BorderRadius borderRadiusLarge = BorderRadius.all(
    Radius.circular(radiusLarge),
  );
  static const BorderRadius borderRadiusXL = BorderRadius.all(
    Radius.circular(radiusXL),
  );
  static const BorderRadius borderRadiusFull = BorderRadius.all(
    Radius.circular(radiusFull),
  );
}
