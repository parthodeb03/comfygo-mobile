import 'package:flutter/material.dart';

import 'one_ui_colors.dart';

/// Theme-aware colors.
///
/// Screens should use these instead of the raw `OneUIColors.*Light/*Dark`
/// constants so every surface, text and divider follows light/dark mode.
class AppColors {
  AppColors._();

  /// Deep green pill/background used behind primary-colored content.
  static const Color primarySoftDark = Color(0xFF11372A);

  /// Brand travel green — used for prices, badges and accents that should
  /// read as "nature" rather than the cyan primary.
  static const Color brandGreen = Color(0xFF1B7A4F);
  static const Color brandGreenDeep = Color(0xFF155C3D);
  static const Color lime = Color(0xFF9EAF28);
  static const Color amber = Color(0xFFB07B18);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      isDark(context) ? OneUIColors.backgroundDark : OneUIColors.backgroundLight;

  static Color surface(BuildContext context) =>
      isDark(context) ? OneUIColors.surfaceDark : OneUIColors.surfaceLight;

  static Color surfaceVariant(BuildContext context) => isDark(context)
      ? OneUIColors.surfaceVariantDark
      : OneUIColors.surfaceVariantLight;

  static Color inputFill(BuildContext context) =>
      isDark(context) ? OneUIColors.surfaceVariantDark : OneUIColors.inputFillLight;

  static Color divider(BuildContext context) =>
      isDark(context) ? OneUIColors.dividerDark : OneUIColors.dividerLight;

  static Color textPrimary(BuildContext context) => isDark(context)
      ? OneUIColors.textPrimaryDark
      : OneUIColors.textPrimaryLight;

  static Color textSecondary(BuildContext context) => isDark(context)
      ? OneUIColors.textSecondaryDark
      : OneUIColors.textSecondaryLight;

  static Color textHint(BuildContext context) =>
      isDark(context) ? OneUIColors.textHintDark : OneUIColors.textHintLight;

  static Color primary(BuildContext context) =>
      isDark(context) ? OneUIColors.primaryDark : OneUIColors.primaryLight;

  static Color primaryVariant(BuildContext context) => isDark(context)
      ? OneUIColors.primaryDark
      : OneUIColors.primaryVariantLight;

  static Color primarySoft(BuildContext context) =>
      isDark(context) ? primarySoftDark : OneUIColors.primarySoft;

  /// Soft green fill for cards, chips and badges.
  static Color greenSoft(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E3529) : const Color(0xFFE3F0E7);

  /// Slightly deeper green fill for card headers/accents.
  static Color greenMist(BuildContext context) =>
      isDark(context) ? const Color(0xFF24382B) : const Color(0xFFD3E7D9);

  /// Warm cream fill used by hotel cards.
  static Color creamSoft(BuildContext context) =>
      isDark(context) ? const Color(0xFF332E22) : const Color(0xFFF6EEDF);

  /// Green accent that stays readable on both themes.
  static Color accentGreen(BuildContext context) =>
      isDark(context) ? const Color(0xFF7ED0A2) : brandGreen;

  static Color secondary(BuildContext context) =>
      isDark(context) ? OneUIColors.secondaryDark : OneUIColors.secondaryLight;

  static Color tertiary(BuildContext context) =>
      isDark(context) ? OneUIColors.tertiaryDark : OneUIColors.tertiaryLight;
}
