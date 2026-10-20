import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// Foreground/background pair for a semantic badge.
typedef StatusColors = ({Color foreground, Color background});

/// Theme-aware colours.
///
/// Screens should use these instead of raw `OneUIColors.*` constants so every
/// surface, text and divider follows light/dark mode. All values originate in
/// `design_tokens.dart`.
class AppColors {
  AppColors._();

  static const Color primarySoftDark = ComfyColors.primarySoftDark;

  static const Color brandGreen = ComfyColors.brandGreen;
  static const Color brandGreenDeep = ComfyColors.brandGreenDeep;
  static const Color lime = ComfyColors.lime;
  static const Color amber = ComfyColors.amber;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) => isDark(context)
      ? ComfyColors.backgroundDark
      : ComfyColors.backgroundLight;

  static Color surface(BuildContext context) =>
      isDark(context) ? ComfyColors.surfaceDark : ComfyColors.surfaceLight;

  static Color surfaceVariant(BuildContext context) => isDark(context)
      ? ComfyColors.surfaceVariantDark
      : ComfyColors.surfaceVariantLight;

  static Color inputFill(BuildContext context) =>
      isDark(context) ? ComfyColors.inputFillDark : ComfyColors.inputFillLight;

  static Color divider(BuildContext context) => isDark(context)
      ? ComfyColors.outlineVariantDark
      : ComfyColors.outlineVariantLight;

  static Color outline(BuildContext context) =>
      isDark(context) ? ComfyColors.outlineDark : ComfyColors.outlineLight;

  static Color textPrimary(BuildContext context) => isDark(context)
      ? ComfyColors.textPrimaryDark
      : ComfyColors.textPrimaryLight;

  static Color textSecondary(BuildContext context) => isDark(context)
      ? ComfyColors.textSecondaryDark
      : ComfyColors.textSecondaryLight;

  static Color textHint(BuildContext context) =>
      isDark(context) ? ComfyColors.textHintDark : ComfyColors.textHintLight;

  static Color primary(BuildContext context) =>
      isDark(context) ? ComfyColors.primaryDark : ComfyColors.primaryLight;

  static Color onPrimary(BuildContext context) =>
      isDark(context) ? ComfyColors.onPrimaryDark : ComfyColors.onPrimaryLight;

  static Color primaryVariant(BuildContext context) => isDark(context)
      ? ComfyColors.primaryDark
      : ComfyColors.onPrimaryContainerLight;

  static Color primaryContainer(BuildContext context) => isDark(context)
      ? ComfyColors.primaryContainerDark
      : ComfyColors.primaryContainerLight;

  static Color onPrimaryContainer(BuildContext context) => isDark(context)
      ? ComfyColors.onPrimaryContainerDark
      : ComfyColors.onPrimaryContainerLight;

  static Color primarySoft(BuildContext context) => primaryContainer(context);

  static Color secondary(BuildContext context) =>
      isDark(context) ? ComfyColors.secondaryDark : ComfyColors.secondaryLight;

  static Color onSecondary(BuildContext context) => isDark(context)
      ? ComfyColors.onSecondaryDark
      : ComfyColors.onSecondaryLight;

  static Color tertiary(BuildContext context) =>
      isDark(context) ? ComfyColors.tertiaryDark : ComfyColors.tertiaryLight;

  static Color onTertiary(BuildContext context) => isDark(context)
      ? ComfyColors.onTertiaryDark
      : ComfyColors.onTertiaryLight;

  /// Price / premium / single-CTA money colour.
  static Color price(BuildContext context) => tertiary(context);

  static Color success(BuildContext context) =>
      isDark(context) ? ComfyColors.successDark : ComfyColors.successLight;

  static Color warning(BuildContext context) =>
      isDark(context) ? ComfyColors.warningDark : ComfyColors.warningLight;

  static Color error(BuildContext context) =>
      isDark(context) ? ComfyColors.errorDark : ComfyColors.errorLight;

  static Color info(BuildContext context) =>
      isDark(context) ? ComfyColors.infoDark : ComfyColors.infoLight;

  static Color scrim(BuildContext context) => ComfyColors.scrim;

  static Color shadow(BuildContext context) => ComfyColors.shadow;

  /// Soft green fill for cards, chips and badges.
  static Color greenSoft(BuildContext context) =>
      isDark(context) ? ComfyColors.greenSoftDark : ComfyColors.greenSoftLight;

  /// Slightly deeper green fill for card headers/accents.
  static Color greenMist(BuildContext context) =>
      isDark(context) ? ComfyColors.greenMistDark : ComfyColors.greenMistLight;

  /// Warm cream fill used by hotel cards.
  static Color creamSoft(BuildContext context) =>
      isDark(context) ? ComfyColors.creamSoftDark : ComfyColors.creamSoftLight;

  /// Green accent that stays readable on both themes.
  static Color accentGreen(BuildContext context) =>
      isDark(context) ? ComfyColors.primaryDark : ComfyColors.primaryLight;

  /// Foreground/background pair for a booking status.
  static StatusColors statusColors(BuildContext context, String status) {
    final dark = isDark(context);
    switch (status.toLowerCase()) {
      case 'confirmed':
        return dark
            ? (
                foreground: ComfyColors.statusConfirmedDark,
                background: ComfyColors.statusConfirmedBgDark,
              )
            : (
                foreground: ComfyColors.statusConfirmedLight,
                background: ComfyColors.statusConfirmedBgLight,
              );
      case 'completed':
        return dark
            ? (
                foreground: ComfyColors.statusCompletedDark,
                background: ComfyColors.statusCompletedBgDark,
              )
            : (
                foreground: ComfyColors.statusCompletedLight,
                background: ComfyColors.statusCompletedBgLight,
              );
      case 'cancelled':
        return dark
            ? (
                foreground: ComfyColors.statusCancelledDark,
                background: ComfyColors.statusCancelledBgDark,
              )
            : (
                foreground: ComfyColors.statusCancelledLight,
                background: ComfyColors.statusCancelledBgLight,
              );
      case 'pending':
      default:
        return dark
            ? (
                foreground: ComfyColors.statusPendingDark,
                background: ComfyColors.statusPendingBgDark,
              )
            : (
                foreground: ComfyColors.statusPendingLight,
                background: ComfyColors.statusPendingBgLight,
              );
    }
  }

  /// Foreground/background pair for a package tier.
  static StatusColors tierColors(BuildContext context, String tier) {
    final dark = isDark(context);
    switch (tier.toLowerCase()) {
      case 'pro':
        return dark
            ? (
                foreground: ComfyColors.tierProDark,
                background: ComfyColors.tierProBgDark,
              )
            : (
                foreground: ComfyColors.tierProLight,
                background: ComfyColors.tierProBgLight,
              );
      case 'premium':
        return dark
            ? (
                foreground: ComfyColors.tierPremiumDark,
                background: ComfyColors.tierPremiumBgDark,
              )
            : (
                foreground: ComfyColors.tierPremiumLight,
                background: ComfyColors.tierPremiumBgLight,
              );
      case 'ultimate':
        return dark
            ? (
                foreground: ComfyColors.tierUltimateDark,
                background: ComfyColors.tierUltimateBgDark,
              )
            : (
                foreground: ComfyColors.tierUltimateLight,
                background: ComfyColors.tierUltimateBgLight,
              );
      case 'basic':
      default:
        return dark
            ? (
                foreground: ComfyColors.tierBasicDark,
                background: ComfyColors.tierBasicBgDark,
              )
            : (
                foreground: ComfyColors.tierBasicLight,
                background: ComfyColors.tierBasicBgLight,
              );
    }
  }
}
