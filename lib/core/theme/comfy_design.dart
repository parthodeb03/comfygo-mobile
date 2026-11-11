// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Folders, theme, routes and reusable widgets from the Phase 1 plan.

import 'package:flutter/material.dart';

/// Design tokens for the "ComfyGo Mobile UI" reference.
///
/// Every value in this file is a 1:1 translation of the CSS custom properties
/// declared in `assets/UI/ComfyGo Mobile UI.html`. New screens should read
/// colours and type from here instead of hard-coding values.
@immutable
class CgColors {
  final Color bg;
  final Color surface;
  final Color primary;
  final Color onPrimary;
  final Color sage;
  final Color text;
  final Color text2;
  final Color line;
  final Color accent;
  final Color mint;

  final LinearGradient gMain;
  final LinearGradient gSage;
  final LinearGradient gBg;
  final LinearGradient gCard;
  final LinearGradient gMint;
  final LinearGradient gAccent;

  final List<BoxShadow> cardShadow;
  final List<BoxShadow> navShadow;

  const CgColors({
    required this.bg,
    required this.surface,
    required this.primary,
    required this.onPrimary,
    required this.sage,
    required this.text,
    required this.text2,
    required this.line,
    required this.accent,
    required this.mint,
    required this.gMain,
    required this.gSage,
    required this.gBg,
    required this.gCard,
    required this.gMint,
    required this.gAccent,
    required this.cardShadow,
    required this.navShadow,
  });

  static const CgColors light = CgColors(
    bg: Color(0xFFF6F8F5),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF1B5239),
    onPrimary: Color(0xFFFFFFFF),
    sage: Color(0xFF9DB98E),
    text: Color(0xFF17372A),
    text2: Color(0xFF6C7B73),
    line: Color(0xFFE6EBE6),
    accent: Color(0xFFF2A93B),
    mint: Color(0xFFE3EFE3),
    gMain: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1B5239), Color(0xFF26704C), Color(0xFF34865B)],
      stops: [0, .55, 1],
    ),
    gSage: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFB7D1A5), Color(0xFF9DB98E), Color(0xFF82A777)],
      stops: [0, .45, 1],
    ),
    gBg: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF8FBF6), Color(0xFFEEF5EA)],
    ),
    gCard: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFFFFF), Color(0xFFF4F9F1)],
    ),
    gMint: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE8F3E4), Color(0xFFCFE6D3)],
    ),
    gAccent: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFF2A93B), Color(0xFFF6D365)],
    ),
    cardShadow: [
      BoxShadow(color: Color(0x1A1B5239), blurRadius: 24, offset: Offset(0, 8)),
    ],
    navShadow: [
      BoxShadow(
        color: Color(0x1F1B5239),
        blurRadius: 28,
        offset: Offset(0, -8),
      ),
    ],
  );

  static const CgColors dark = CgColors(
    bg: Color(0xFF0F1A14),
    surface: Color(0xFF17251D),
    primary: Color(0xFF8FD0A8),
    onPrimary: Color(0xFF0F2A1D),
    sage: Color(0xFF4E7A62),
    text: Color(0xFFEDEFE6),
    text2: Color(0xFFA9B8AE),
    line: Color(0xFF2A3B31),
    accent: Color(0xFFF2A93B),
    mint: Color(0xFF1F3328),
    gMain: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF8FD0A8), Color(0xFF6FBF92), Color(0xFFA3D98F)],
      stops: [0, .55, 1],
    ),
    gSage: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFB7D1A5), Color(0xFF9DB98E), Color(0xFF82A777)],
      stops: [0, .45, 1],
    ),
    gBg: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0F1A14), Color(0xFF13231B)],
    ),
    gCard: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1B2C22), Color(0xFF142219)],
    ),
    gMint: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF25402F), Color(0xFF1B3025)],
    ),
    gAccent: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFF2A93B), Color(0xFFF6D365)],
    ),
    cardShadow: [
      BoxShadow(color: Color(0x59000000), blurRadius: 24, offset: Offset(0, 8)),
    ],
    navShadow: [
      BoxShadow(
        color: Color(0x59000000),
        blurRadius: 28,
        offset: Offset(0, -8),
      ),
    ],
  );

  static CgColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// Fixed contrast tokens used by the always-sage intro/auth artwork.
  static const Color ink = Color(0xFF17372A);
  static const Color inkSoft = Color(0xFF3C5B48);
  static const Color deepGreen = Color(0xFF1B5239);
  static const Color sunYellow = Color(0xFFF2C230);
}

/// Type scale from the reference (`h1`, `t20`, `t16`, `b14`, `l12`).
abstract final class CgType {
  CgType._();

  static const String family = 'PlusJakartaSans';
  static const List<String> fallback = ['HindSiliguri'];

  static const TextStyle h1 = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 30,
    height: 38 / 30,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.5,
  );

  static const TextStyle h1Bold = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 30,
    height: 38 / 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static const TextStyle t20 = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle t16 = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w700,
  );

  /// Title used on pushed (non-tab) pages.
  static const TextStyle pageTitle = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
  );

  static const TextStyle b14 = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 14,
    height: 22 / 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle l12 = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle body15 = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle button = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w700,
  );
}

abstract final class CgRadii {
  CgRadii._();

  static const double card = 24;
  static const double image = 20;
  static const double input = 16;
  static const double sheet = 32;
  static const double nav = 28;
  static const double pill = 999;
}
