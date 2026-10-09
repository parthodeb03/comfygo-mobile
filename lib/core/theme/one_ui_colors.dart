import 'package:flutter/material.dart';

/// ComfyGo Color System
/// Based on the green-and-white reference UI kit
class OneUIColors {
  OneUIColors._();

  // ═══════════════════════════════════════════════════
  // PRIMARY - Naturistic Emerald Green
  // ═══════════════════════════════════════════════════
  static const Color primaryLight = Color(0xFF3EBACE);
  static const Color primaryDark = Color(0xFF3EBACE);
  static const Color primaryVariantLight = Color(0xFF20271A);
  static const Color primarySoft = Color(0xFFD8ECF1);

  // Button green (works with white text in BOTH light and dark mode)
  static const Color buttonGreenDark = Color(0xFF20271A);
  static const Color buttonGreen = Color(0xFF3EBACE);
  static const Color buttonGreenLight = Color(0xFF3EBACE);

  // ═══════════════════════════════════════════════════
  // SECONDARY - Lighter green accents
  // ═══════════════════════════════════════════════════
  static const Color secondaryLight = Color(0xFF9EAF28);
  static const Color secondaryDark = Color(0xFFB6CC35);

  // ═══════════════════════════════════════════════════
  // TERRIARY - Warm accent for highlights
  // ═══════════════════════════════════════════════════
  static const Color tertiaryLight = Color(0xFF879078);
  static const Color tertiaryDark = Color(0xFFAAB596);

  // ═══════════════════════════════════════════════════
  // BACKGROUNDS - soft, nature-inspired greens
  // ═══════════════════════════════════════════════════
  static const Color backgroundLight = Color(0xFFF3F5F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF3F0E6);
  static const Color inputFillLight = Color(0xFFF3F0E6);

  // Dark Mode
  static const Color backgroundDark = Color(0xFF20271A);
  static const Color surfaceDark = Color(0xFF2A3022);
  static const Color surfaceVariantDark = Color(0xFF383D30);

  // ═══════════════════════════════════════════════════
  // TEXT — tuned for WCAG-AA readability on their backgrounds
  // ═══════════════════════════════════════════════════
  static const Color textPrimaryLight = Color(0xFF20271A);
  static const Color textSecondaryLight = Color(0xFF707266);
  static const Color textHintLight = Color(0xFF858678);

  static const Color textPrimaryDark = Color(0xFFF4F0E4);
  static const Color textSecondaryDark = Color(0xFFCBC7B7);
  static const Color textHintDark = Color(0xFFAAA695);

  // ═══════════════════════════════════════════════════
  // STATUS
  // ═══════════════════════════════════════════════════
  static const Color success = Color(0xFF9EAF28);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // ═══════════════════════════════════════════════════
  // DIVIDER & BORDER
  // ═══════════════════════════════════════════════════
  static const Color dividerLight = Color(0xFFDDD9CA);
  static const Color dividerDark = Color(0xFF414536);

  // ═══════════════════════════════════════════════════
  // PACKAGE TIER COLORS
  // ═══════════════════════════════════════════════════
  static const Color tierBasic = Color(0xFF78909C);
  static const Color tierPro = Color(0xFFB6CC35);
  static const Color tierPremium = Color(0xFFFFB300);
  static const Color tierUltimate = Color(0xFF9C27B0);

  // ═══════════════════════════════════════════════════
  // BOOKING STATUS
  // ═══════════════════════════════════════════════════
  static const Color statusPending = Color(0xFFFFC107);
  static const Color statusConfirmed = Color(0xFF9EAF28);
  static const Color statusCancelled = Color(0xFFF44336);
  static const Color statusCompleted = Color(0xFFB6CC35);
}
