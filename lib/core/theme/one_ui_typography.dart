// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Folders, theme, routes and reusable widgets from the Phase 1 plan.

import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// ComfyGo typography.
///
/// Playfair Display carries editorial headings and prices; DM Sans carries UI
/// and body copy; Hind Siliguri is the bundled Bengali fallback. No font is
/// downloaded at runtime.
class OneUITypography {
  OneUITypography._();

  static const String fontFamily = ComfyType.bodyFamily;
  static const String displayFontFamily = ComfyType.displayFamily;
  static const List<String> bengaliFallback = ComfyType.bengaliFallback;

  // Display / editorial
  static final TextStyle displayLargeLight = ComfyType.displayXl.copyWith(
    color: ComfyColors.textPrimaryLight,
  );
  static final TextStyle displayMediumLight = ComfyType.displayL.copyWith(
    color: ComfyColors.textPrimaryLight,
  );
  static final TextStyle displaySmallLight = ComfyType.h1.copyWith(
    color: ComfyColors.textPrimaryLight,
  );

  // Headlines
  static final TextStyle headlineLargeLight = ComfyType.section.copyWith(
    color: ComfyColors.textPrimaryLight,
  );
  static final TextStyle headlineMediumLight = ComfyType.h2.copyWith(
    color: ComfyColors.textPrimaryLight,
  );
  static final TextStyle headlineSmallLight = ComfyType.cardTitle.copyWith(
    color: ComfyColors.textPrimaryLight,
  );

  // Titles
  static final TextStyle titleLargeLight = ComfyType.cardTitle.copyWith(
    color: ComfyColors.textPrimaryLight,
  );
  static final TextStyle titleMediumLight = ComfyType.bodyL.copyWith(
    color: ComfyColors.textPrimaryLight,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle titleSmallLight = ComfyType.bodyM.copyWith(
    color: ComfyColors.textPrimaryLight,
    fontWeight: FontWeight.w600,
  );

  // Body
  static final TextStyle bodyLargeLight = ComfyType.bodyL.copyWith(
    color: ComfyColors.textPrimaryLight,
  );
  static final TextStyle bodyMediumLight = ComfyType.bodyM.copyWith(
    color: ComfyColors.textPrimaryLight,
  );
  static final TextStyle bodySmallLight = ComfyType.bodyS.copyWith(
    color: ComfyColors.textSecondaryLight,
  );

  // Labels
  static final TextStyle labelLargeLight = ComfyType.button.copyWith(
    color: ComfyColors.textPrimaryLight,
  );
  static final TextStyle labelMediumLight = ComfyType.label.copyWith(
    color: ComfyColors.textSecondaryLight,
  );
  static final TextStyle labelSmallLight = ComfyType.caption.copyWith(
    color: ComfyColors.textSecondaryLight,
  );

  // ─────────────────────────────────────────────────────────────
  // DARK
  // ─────────────────────────────────────────────────────────────
  static final TextStyle displayLargeDark = ComfyType.displayXl.copyWith(
    color: ComfyColors.textPrimaryDark,
  );
  static final TextStyle displayMediumDark = ComfyType.displayL.copyWith(
    color: ComfyColors.textPrimaryDark,
  );
  static final TextStyle displaySmallDark = ComfyType.h1.copyWith(
    color: ComfyColors.textPrimaryDark,
  );

  static final TextStyle headlineLargeDark = ComfyType.section.copyWith(
    color: ComfyColors.textPrimaryDark,
  );
  static final TextStyle headlineMediumDark = ComfyType.h2.copyWith(
    color: ComfyColors.textPrimaryDark,
  );
  static final TextStyle headlineSmallDark = ComfyType.cardTitle.copyWith(
    color: ComfyColors.textPrimaryDark,
  );

  static final TextStyle titleLargeDark = ComfyType.cardTitle.copyWith(
    color: ComfyColors.textPrimaryDark,
  );
  static final TextStyle titleMediumDark = ComfyType.bodyL.copyWith(
    color: ComfyColors.textPrimaryDark,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle titleSmallDark = ComfyType.bodyM.copyWith(
    color: ComfyColors.textPrimaryDark,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle bodyLargeDark = ComfyType.bodyL.copyWith(
    color: ComfyColors.textPrimaryDark,
  );
  static final TextStyle bodyMediumDark = ComfyType.bodyM.copyWith(
    color: ComfyColors.textPrimaryDark,
  );
  static final TextStyle bodySmallDark = ComfyType.bodyS.copyWith(
    color: ComfyColors.textSecondaryDark,
  );

  static final TextStyle labelLargeDark = ComfyType.button.copyWith(
    color: ComfyColors.textPrimaryDark,
  );
  static final TextStyle labelMediumDark = ComfyType.label.copyWith(
    color: ComfyColors.textSecondaryDark,
  );
  static final TextStyle labelSmallDark = ComfyType.caption.copyWith(
    color: ComfyColors.textSecondaryDark,
  );

  /// Material text theme assembled from the token styles.
  static TextTheme textTheme({required bool dark}) {
    if (dark) {
      return TextTheme(
        displayLarge: displayLargeDark,
        displayMedium: displayMediumDark,
        displaySmall: displaySmallDark,
        headlineLarge: headlineLargeDark,
        headlineMedium: headlineMediumDark,
        headlineSmall: headlineSmallDark,
        titleLarge: titleLargeDark,
        titleMedium: titleMediumDark,
        titleSmall: titleSmallDark,
        bodyLarge: bodyLargeDark,
        bodyMedium: bodyMediumDark,
        bodySmall: bodySmallDark,
        labelLarge: labelLargeDark,
        labelMedium: labelMediumDark,
        labelSmall: labelSmallDark,
      );
    }
    return TextTheme(
      displayLarge: displayLargeLight,
      displayMedium: displayMediumLight,
      displaySmall: displaySmallLight,
      headlineLarge: headlineLargeLight,
      headlineMedium: headlineMediumLight,
      headlineSmall: headlineSmallLight,
      titleLarge: titleLargeLight,
      titleMedium: titleMediumLight,
      titleSmall: titleSmallLight,
      bodyLarge: bodyLargeLight,
      bodyMedium: bodyMediumLight,
      bodySmall: bodySmallLight,
      labelLarge: labelLargeLight,
      labelMedium: labelMediumLight,
      labelSmall: labelSmallLight,
    );
  }
}
