import 'package:flutter/material.dart';

/// The single source of truth for ComfyGo visual tokens.
///
/// Nothing outside this file may declare a raw colour, font size, radius or
/// duration for app UI. Screens and widgets must read these values through
/// `AppColors`, `OneUISpacing`, `OneUITypography` or `Theme.of(context)`.
///
/// All Pantone references in the design spec are approximate.
abstract final class ComfyColors {
  ComfyColors._();

  // ─────────────────────────────────────────────────────────────
  // LIGHT
  // ─────────────────────────────────────────────────────────────
  static const Color primaryLight = Color(0xFF176F47);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFFDDEFE4);
  static const Color onPrimaryContainerLight = Color(0xFF11372A);

  static const Color secondaryLight = Color(0xFF556B2F);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color tertiaryLight = Color(0xFF8A5A00);
  static const Color onTertiaryLight = Color(0xFFFFFFFF);

  static const Color backgroundLight = Color(0xFFF4F5F0);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFE7ECE3);
  static const Color inputFillLight = Color(0xFFE7ECE3);

  static const Color outlineLight = Color(0xFF7C8676);
  static const Color outlineVariantLight = Color(0xFFDCE1D8);

  static const Color textPrimaryLight = Color(0xFF1B211A);
  static const Color textSecondaryLight = Color(0xFF5B6358);
  static const Color textHintLight = Color(0xFF66705F);

  static const Color successLight = Color(0xFF17603E);
  static const Color onSuccessLight = Color(0xFFFFFFFF);
  static const Color warningLight = Color(0xFF8A5A00);
  static const Color onWarningLight = Color(0xFFFFFFFF);
  static const Color errorLight = Color(0xFFB3261E);
  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color infoLight = Color(0xFF2A5D7A);
  static const Color onInfoLight = Color(0xFFFFFFFF);

  static const Color statusPendingLight = Color(0xFF8A5A00);
  static const Color statusPendingBgLight = Color(0xFFFFF1CC);
  static const Color statusConfirmedLight = Color(0xFF17603E);
  static const Color statusConfirmedBgLight = Color(0xFFDDF0E4);
  static const Color statusCompletedLight = Color(0xFF2A5D7A);
  static const Color statusCompletedBgLight = Color(0xFFDCECF5);
  static const Color statusCancelledLight = Color(0xFFA32A22);
  static const Color statusCancelledBgLight = Color(0xFFFBE3E0);

  static const Color tierBasicLight = Color(0xFF5B6470);
  static const Color tierBasicBgLight = Color(0xFFE8EBEF);
  static const Color tierProLight = Color(0xFF17603E);
  static const Color tierProBgLight = Color(0xFFDDF0E4);
  static const Color tierPremiumLight = Color(0xFF8A5A00);
  static const Color tierPremiumBgLight = Color(0xFFFBEDD8);
  static const Color tierUltimateLight = Color(0xFF5B3E8E);
  static const Color tierUltimateBgLight = Color(0xFFEDE7F7);

  // ─────────────────────────────────────────────────────────────
  // DARK
  // ─────────────────────────────────────────────────────────────
  static const Color primaryDark = Color(0xFF86D6A8);
  static const Color onPrimaryDark = Color(0xFF0A2416);
  static const Color primaryContainerDark = Color(0xFF1E3A2B);
  static const Color onPrimaryContainerDark = Color(0xFFCBEBD8);

  static const Color secondaryDark = Color(0xFFB7CE86);
  static const Color onSecondaryDark = Color(0xFF0A2416);
  static const Color tertiaryDark = Color(0xFFE8B86A);
  static const Color onTertiaryDark = Color(0xFF0A2416);

  static const Color backgroundDark = Color(0xFF0F1611);
  static const Color surfaceDark = Color(0xFF171F19);
  static const Color surfaceVariantDark = Color(0xFF222C24);
  static const Color inputFillDark = Color(0xFF222C24);

  static const Color outlineDark = Color(0xFF6C7A6A);
  static const Color outlineVariantDark = Color(0xFF2C352D);

  static const Color textPrimaryDark = Color(0xFFF1F4EE);
  static const Color textSecondaryDark = Color(0xFFC4CBBE);
  static const Color textHintDark = Color(0xFF9BA495);

  static const Color successDark = Color(0xFF86D6A8);
  static const Color onSuccessDark = Color(0xFF0A2416);
  static const Color warningDark = Color(0xFFF2C14E);
  static const Color onWarningDark = Color(0xFF0F1611);
  static const Color errorDark = Color(0xFFFFB4AB);
  static const Color onErrorDark = Color(0xFF0F1611);
  static const Color infoDark = Color(0xFF9CD3EC);
  static const Color onInfoDark = Color(0xFF0F1611);

  static const Color statusPendingDark = Color(0xFFF2C14E);
  static const Color statusPendingBgDark = Color(0xFF3A2E12);
  static const Color statusConfirmedDark = Color(0xFF8FE0B0);
  static const Color statusConfirmedBgDark = Color(0xFF173A28);
  static const Color statusCompletedDark = Color(0xFF9CD3EC);
  static const Color statusCompletedBgDark = Color(0xFF16333F);
  static const Color statusCancelledDark = Color(0xFFFFB4AB);
  static const Color statusCancelledBgDark = Color(0xFF3E1D1A);

  static const Color tierBasicDark = Color(0xFFC3CBD6);
  static const Color tierBasicBgDark = Color(0xFF2A3038);
  static const Color tierProDark = Color(0xFF8FE0B0);
  static const Color tierProBgDark = Color(0xFF173A28);
  static const Color tierPremiumDark = Color(0xFFF2C14E);
  static const Color tierPremiumBgDark = Color(0xFF3A2E12);
  static const Color tierUltimateDark = Color(0xFFD6C2F5);
  static const Color tierUltimateBgDark = Color(0xFF332647);

  // ─────────────────────────────────────────────────────────────
  // SHARED / LEGACY ACCENT NAMES
  // ─────────────────────────────────────────────────────────────
  static const Color brandGreen = primaryLight;
  static const Color brandGreenDeep = onPrimaryContainerLight;
  static const Color lime = secondaryLight;
  static const Color amber = tertiaryLight;
  static const Color gold = tertiaryLight;
  static const Color scrim = Color(0xFF0B1F17);
  static const Color shadow = Color(0xFF0B1F17);

  static const Color greenSoftLight = primaryContainerLight;
  static const Color greenMistLight = Color(0xFFD3E7D9);
  static const Color creamSoftLight = Color(0xFFF6F0E3);
  static const Color greenSoftDark = primaryContainerDark;
  static const Color greenMistDark = Color(0xFF24382B);
  static const Color creamSoftDark = Color(0xFF332E22);

  static const Color primarySoftDark = primaryContainerDark;
}

/// 4pt spacing grid.
abstract final class ComfySpacing {
  ComfySpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 40;
  static const double huge = 48;
  static const double massive = 64;

  static const double pageCompact = 20;
  static const double pageMedium = 24;
  static const double pageExpanded = 32;
  static const double contentMaxWidth = 1120;
}

abstract final class ComfyRadii {
  ComfyRadii._();

  static const double sm = 8;
  static const double input = 14;
  static const double md = 12;
  static const double lg = 16;
  static const double card = 20;
  static const double xl = 20;
  static const double sheet = 24;
  static const double xxl = 24;
  static const double pill = 999;
}

abstract final class ComfyElevation {
  ComfyElevation._();

  static const double none = 0;
  static const double card = 2;
  static const double dark = 0;
  static const double sheet = 3;
}

abstract final class ComfyDurations {
  ComfyDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration verySlow = Duration(milliseconds: 600);
}

abstract final class ComfyCurves {
  ComfyCurves._();

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
}

abstract final class ComfyOpacity {
  ComfyOpacity._();

  static const double disabled = 0.38;
  static const double disabledContent = 0.60;
  static const double scrim = 0.68;
  static const double shimmer = 0.12;
}

abstract final class ComfyBreakpoints {
  ComfyBreakpoints._();

  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 840;
  static const double wide = 1200;
  static const double contentMaxWidth = 1120;
}

/// Green-tinted elevation. Dark mode uses surface tint instead of shadows.
abstract final class ComfyShadows {
  ComfyShadows._();

  static const List<BoxShadow> level1 = [
    BoxShadow(color: Color(0x0F0B1F17), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> level2 = [
    BoxShadow(color: Color(0x140B1F17), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> level3 = [
    BoxShadow(color: Color(0x1A0B1F17), blurRadius: 28, offset: Offset(0, 12)),
  ];

  static const List<BoxShadow> none = [];
}

/// Typography tokens. Colours are applied by `OneUITheme`; screens should use
/// `Theme.of(context).textTheme` so dark mode and Bengali fallback follow.
abstract final class ComfyType {
  ComfyType._();

  static const String bodyFamily = 'DMSans';
  static const String displayFamily = 'PlayfairDisplay';
  static const List<String> bengaliFallback = ['HindSiliguri'];

  static const TextStyle displayXl = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: bengaliFallback,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.1875,
    letterSpacing: -0.5,
  );

  static const TextStyle displayL = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: bengaliFallback,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2143,
    letterSpacing: -0.3,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: bengaliFallback,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: bengaliFallback,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle section = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: bengaliFallback,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2727,
    letterSpacing: -0.2,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: bengaliFallback,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3333,
  );

  static const TextStyle bodyL = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: bengaliFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyM = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: bengaliFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5714,
  );

  static const TextStyle bodyS = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: bengaliFallback,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5385,
  );

  static const TextStyle label = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: bengaliFallback,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3333,
    letterSpacing: 0.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: bengaliFallback,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4545,
    letterSpacing: 0.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: bengaliFallback,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.3333,
    letterSpacing: 0.2,
  );

  static const TextStyle price = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: bengaliFallback,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle nav = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: bengaliFallback,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2727,
    letterSpacing: 0.2,
  );
}
