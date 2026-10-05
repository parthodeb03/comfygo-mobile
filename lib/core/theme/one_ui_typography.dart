import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ComfyGo Typography Scale
/// Based on Poppins / rounded-modern sans-serif matching the reference kit
class OneUITypography {
  OneUITypography._();

  // ═══════════════════════════════════════════════════
  // FONT FAMILY
  // ═══════════════════════════════════════════════════
  static const String fontFamily = 'Poppins';

  /// Get the Poppins TextStyle from Google Fonts
  static TextStyle poppins({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // ═══════════════════════════════════════════════════
  // LIGHT MODE STYLES
  // ═══════════════════════════════════════════════════

  // Display / Hero
  static const TextStyle displayLargeLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: Color(0xFF1A1A1A),
  );

  static const TextStyle displayMediumLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: Color(0xFF1A1A1A),
  );

  static const TextStyle displaySmallLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1A1A1A),
  );

  // Headlines
  static const TextStyle headlineLargeLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1A1A1A),
  );

  static const TextStyle headlineMediumLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1A1A1A),
  );

  static const TextStyle headlineSmallLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1A1A1A),
  );

  // Titles
  static const TextStyle titleLargeLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1A1A1A),
  );

  static const TextStyle titleMediumLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF1A1A1A),
  );

  static const TextStyle titleSmallLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF1A1A1A),
  );

  // Body
  static const TextStyle bodyLargeLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFF1A1A1A),
    height: 1.5,
  );

  static const TextStyle bodyMediumLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF1A1A1A),
    height: 1.5,
  );

  static const TextStyle bodySmallLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF8A8A8A),
    height: 1.4,
  );

  // Labels
  static const TextStyle labelLargeLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: Color(0xFF1A1A1A),
  );

  static const TextStyle labelMediumLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: Color(0xFF8A8A8A),
  );

  static const TextStyle labelSmallLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: Color(0xFF8A8A8A),
  );

  // ═══════════════════════════════════════════════════
  // DARK MODE STYLES
  // ═══════════════════════════════════════════════════

  static const TextStyle displayLargeDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: Color(0xFFE0E0E0),
  );

  static const TextStyle displayMediumDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: Color(0xFFE0E0E0),
  );

  static const TextStyle displaySmallDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Color(0xFFE0E0E0),
  );

  static const TextStyle headlineLargeDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Color(0xFFE0E0E0),
  );

  static const TextStyle headlineMediumDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFFE0E0E0),
  );

  static const TextStyle headlineSmallDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFFE0E0E0),
  );

  static const TextStyle titleLargeDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFFE0E0E0),
  );

  static const TextStyle titleMediumDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFFE0E0E0),
  );

  static const TextStyle titleSmallDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFFE0E0E0),
  );

  static const TextStyle bodyLargeDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFFE0E0E0),
    height: 1.5,
  );

  static const TextStyle bodyMediumDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFFE0E0E0),
    height: 1.5,
  );

  static const TextStyle bodySmallDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF9E9E9E),
    height: 1.4,
  );

  static const TextStyle labelLargeDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: Color(0xFFE0E0E0),
  );

  static const TextStyle labelMediumDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: Color(0xFF9E9E9E),
  );

  static const TextStyle labelSmallDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: Color(0xFF9E9E9E),
  );
}
