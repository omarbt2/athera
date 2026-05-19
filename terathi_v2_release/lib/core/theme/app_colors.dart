import 'package:flutter/material.dart';

/// Heritage Immersion Design System — Colors
/// Adapted from Stitch "Heritage Immersion" theme
class AppColors {
      // شعار التطبيق (Teal فاتح)
      static const Color logoTeal = Color(0xFF4FD1C5); // يمكنك تغيير الكود اللوني حسب الهوية البصرية
  // ── Primary (Deep Teal) ──────────────────────
  static const Color primary = Color(0xFF035F5B);
  static const Color primaryContainer = Color(0xFF2C7873);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFB4FDF7);
  static const Color inversePrimary = Color(0xFF8BD3CD);

  // ── Secondary (Warm Gold) ────────────────────
  static const Color secondary = Color(0xFF755B00);
  static const Color secondaryContainer = Color(0xFFFED977);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF785D00);

  // ── Tertiary (Warm Brown) ────────────────────
  static const Color tertiary = Color(0xFF5F533E);
  static const Color tertiaryContainer = Color(0xFF786B54);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFFFEDD2);

  // ── Surfaces & Backgrounds ───────────────────
  static const Color background = Color(0xFFFFF8F5);          // Warm cream
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFEBD6C5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFFFF1E7);
  static const Color surfaceContainer = Color(0xFFFFEAD9);
  static const Color surfaceContainerHigh = Color(0xFFFAE4D3);
  static const Color surfaceContainerHighest = Color(0xFFF4DFCD);
  static const Color surfaceVariant = Color(0xFFF4DFCD);
  static const Color inverseSurface = Color(0xFF3A2E22);
  static const Color inverseOnSurface = Color(0xFFFFEEE0);

  // ── Text ─────────────────────────────────────
  static const Color onSurface = Color(0xFF24190F);           // Warm black
  static const Color onSurfaceVariant = Color(0xFF3F4947);
  static const Color textPrimary = Color(0xFF24190F);
  static const Color textSecondary = Color(0xFF3F4947);
  static const Color textTertiary = Color(0xFF6F7978);

  // ── Outline ──────────────────────────────────
  static const Color outline = Color(0xFF6F7978);
  static const Color outlineVariant = Color(0xFFBEC9C7);

  // ── Navigation ───────────────────────────────
  static const Color navActive = Color(0xFF1C1208);           // Warm black
  static const Color navInactive = Color(0xFFB0A898);         // Muted sand

  // ── Error ────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // ── Shadows ──────────────────────────────────
  static const Color shadowColor = Color(0x141C1208);         // 8% warm black

  // ── Category Colors ──────────────────────────
  static const Color catArchaeological = Color(0xFF755B00);   // Gold
  static const Color catIslamic = Color(0xFF035F5B);          // Teal
  static const Color catNatural = Color(0xFF005F73);          // Blue-teal
  static const Color catMuseums = Color(0xFF5F533E);          // Warm brown

  // ── UNESCO Badge ─────────────────────────────
  static const Color unescoGold = Color(0xFFC9A84C);
}
