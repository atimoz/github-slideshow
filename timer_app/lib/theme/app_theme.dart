import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
//  Design tokens — single source of truth
// ─────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Backgrounds
  static const bg = Color(0xFF0A0A0F);          // near-black
  static const surface = Color(0xFF13131A);      // card surface
  static const surfaceAlt = Color(0xFF1C1C27);   // subtle variant

  // Brand accent — electric indigo
  static const accent = Color(0xFF6C63FF);
  static const accentGlow = Color(0x336C63FF);
  static const accentSoft = Color(0xFF8A83FF);

  // Semantic
  static const success = Color(0xFF34C759);      // Apple green
  static const warning = Color(0xFFFF9F0A);      // Apple amber
  static const destructive = Color(0xFFFF453A);  // Apple red

  // Text hierarchy
  static const textPrimary = Color(0xFFF5F5FA);
  static const textSecondary = Color(0xFF8E8EA0);
  static const textTertiary = Color(0xFF4A4A60);

  // Dividers / strokes
  static const stroke = Color(0xFF22222E);

  // Gradient pairs
  static const List<Color> timerGradient = [Color(0xFF6C63FF), Color(0xFFAE8FFF)];
  static const List<Color> chartGradient = [Color(0x996C63FF), Color(0x006C63FF)];
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentSoft,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.destructive,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      dividerColor: AppColors.stroke,
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 22),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      }),
    );
  }
}
