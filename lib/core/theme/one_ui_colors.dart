// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Folders, theme, routes and reusable widgets from the Phase 1 plan.

import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// ComfyGo colour names.
///
/// Values live only in `design_tokens.dart`. This class keeps the historical
/// names so existing screens continue to compile while they migrate to
/// `AppColors` / `Theme.of(context)`.
class OneUIColors {
  OneUIColors._();

  // Primary
  static const Color primaryLight = ComfyColors.primaryLight;
  static const Color primaryDark = ComfyColors.primaryDark;
  static const Color primaryVariantLight = ComfyColors.onPrimaryContainerLight;
  static const Color primarySoft = ComfyColors.primaryContainerLight;

  // Button inks that work with white / dark labels
  static const Color buttonGreenDark = ComfyColors.onPrimaryDark;
  static const Color buttonGreen = ComfyColors.primaryDark;
  static const Color buttonGreenLight = ComfyColors.primaryLight;

  // Secondary & tertiary
  static const Color secondaryLight = ComfyColors.secondaryLight;
  static const Color secondaryDark = ComfyColors.secondaryDark;
  static const Color tertiaryLight = ComfyColors.tertiaryLight;
  static const Color tertiaryDark = ComfyColors.tertiaryDark;

  // Backgrounds
  static const Color backgroundLight = ComfyColors.backgroundLight;
  static const Color surfaceLight = ComfyColors.surfaceLight;
  static const Color surfaceVariantLight = ComfyColors.surfaceVariantLight;
  static const Color inputFillLight = ComfyColors.inputFillLight;

  static const Color backgroundDark = ComfyColors.backgroundDark;
  static const Color surfaceDark = ComfyColors.surfaceDark;
  static const Color surfaceVariantDark = ComfyColors.surfaceVariantDark;
  static const Color inputFillDark = ComfyColors.inputFillDark;

  // Text
  static const Color textPrimaryLight = ComfyColors.textPrimaryLight;
  static const Color textSecondaryLight = ComfyColors.textSecondaryLight;
  static const Color textHintLight = ComfyColors.textHintLight;

  static const Color textPrimaryDark = ComfyColors.textPrimaryDark;
  static const Color textSecondaryDark = ComfyColors.textSecondaryDark;
  static const Color textHintDark = ComfyColors.textHintDark;

  // Semantic
  static const Color success = ComfyColors.successLight;
  static const Color successDark = ComfyColors.successDark;
  static const Color warning = ComfyColors.warningLight;
  static const Color warningDark = ComfyColors.warningDark;
  static const Color error = ComfyColors.errorLight;
  static const Color errorDark = ComfyColors.errorDark;
  static const Color info = ComfyColors.infoLight;
  static const Color infoDark = ComfyColors.infoDark;

  // Lines
  static const Color dividerLight = ComfyColors.outlineVariantLight;
  static const Color dividerDark = ComfyColors.outlineVariantDark;
  static const Color outlineLight = ComfyColors.outlineLight;
  static const Color outlineDark = ComfyColors.outlineDark;

  // Package tiers
  static const Color tierBasic = ComfyColors.tierBasicLight;
  static const Color tierPro = ComfyColors.tierProLight;
  static const Color tierPremium = ComfyColors.tierPremiumLight;
  static const Color tierUltimate = ComfyColors.tierUltimateLight;

  static const Color tierBasicBg = ComfyColors.tierBasicBgLight;
  static const Color tierProBg = ComfyColors.tierProBgLight;
  static const Color tierPremiumBg = ComfyColors.tierPremiumBgLight;
  static const Color tierUltimateBg = ComfyColors.tierUltimateBgLight;

  static const Color tierBasicDark = ComfyColors.tierBasicDark;
  static const Color tierProDark = ComfyColors.tierProDark;
  static const Color tierPremiumDark = ComfyColors.tierPremiumDark;
  static const Color tierUltimateDark = ComfyColors.tierUltimateDark;

  static const Color tierBasicBgDark = ComfyColors.tierBasicBgDark;
  static const Color tierProBgDark = ComfyColors.tierProBgDark;
  static const Color tierPremiumBgDark = ComfyColors.tierPremiumBgDark;
  static const Color tierUltimateBgDark = ComfyColors.tierUltimateBgDark;

  // Booking statuses
  static const Color statusPending = ComfyColors.statusPendingLight;
  static const Color statusPendingBg = ComfyColors.statusPendingBgLight;
  static const Color statusConfirmed = ComfyColors.statusConfirmedLight;
  static const Color statusConfirmedBg = ComfyColors.statusConfirmedBgLight;
  static const Color statusCancelled = ComfyColors.statusCancelledLight;
  static const Color statusCancelledBg = ComfyColors.statusCancelledBgLight;
  static const Color statusCompleted = ComfyColors.statusCompletedLight;
  static const Color statusCompletedBg = ComfyColors.statusCompletedBgLight;

  static const Color statusPendingDark = ComfyColors.statusPendingDark;
  static const Color statusPendingBgDark = ComfyColors.statusPendingBgDark;
  static const Color statusConfirmedDark = ComfyColors.statusConfirmedDark;
  static const Color statusConfirmedBgDark = ComfyColors.statusConfirmedBgDark;
  static const Color statusCancelledDark = ComfyColors.statusCancelledDark;
  static const Color statusCancelledBgDark = ComfyColors.statusCancelledBgDark;
  static const Color statusCompletedDark = ComfyColors.statusCompletedDark;
  static const Color statusCompletedBgDark = ComfyColors.statusCompletedBgDark;
}
