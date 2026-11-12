// Design tokens transcribed 1:1 from the reference UI (plan §06, §07).
import 'package:flutter/material.dart';

/// Tokens for the landing, sign-in and sign-up screens.
///
/// Every value is a 1:1 transcription of the final CSS layer in
/// `assets/UI/ComfyGo Mobile UI (2).html` — the "aqua + orange travel layer"
/// that overrides the earlier palettes, so these are the colours the reference
/// actually paints.
@immutable
class CgRefColors { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
  const CgRefColors({
    required this.bg,
    required this.surface,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.accent,
    required this.text,
    required this.text2,
    required this.outline,
    required this.orange,
    required this.gMain,
    required this.gBg,
    required this.gCard,
    required this.glassFill,
    required this.glassBorder,
    required this.artStart,
    required this.artEnd,
    required this.artHighlight,
    required this.artScrim,
    required this.shadow1,
    required this.shadow2,
  });

  /// `--bg`
  final Color bg;

  /// `--surface`
  final Color surface;

  /// `--primary` (deep teal ink)
  final Color primary;

  /// `--onPrimary`
  final Color onPrimary;

  /// `--secondary`
  final Color secondary;

  /// `--accent`
  final Color accent;

  /// `--text`
  final Color text;

  /// `--text2`
  final Color text2;

  /// `--outline`
  final Color outline;

  /// `--orange`
  final Color orange;

  /// `--g-main` — the single call-to-action gradient.
  final LinearGradient gMain;

  /// `--g-bg` — page background of the landing screen.
  final LinearGradient gBg;

  /// `--g-card`
  final LinearGradient gCard;

  /// `.glass` fill.
  final Color glassFill;

  /// `.glass` border.
  final Color glassBorder;

  /// Login/sign-up artwork gradient start (`#1F4D3A`).
  final Color artStart;

  /// Login/sign-up artwork gradient end (`#8FB39A`).
  final Color artEnd;

  /// Radial highlight painted over the artwork gradient.
  final Color artHighlight;

  /// Bottom scrim that keeps white artwork copy readable.
  final Color artScrim;

  /// `--sh1`
  final List<BoxShadow> shadow1;

  /// `--sh2`
  final List<BoxShadow> shadow2;

  /// Error ink — the reference has no error token, so the app's danger red is
  /// kept for inline validation text.
  static const Color danger = Color(0xFFC0453A);

  static const CgRefColors light = CgRefColors(
    bg: Color(0xFFE4F8F3),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF0F3D46),
    onPrimary: Color(0xFF2B1500),
    secondary: Color(0xFF5FD3D0),
    accent: Color(0xFFB45F0A),
    text: Color(0xFF0F3D46),
    text2: Color(0xFF4B6A70),
    outline: Color(0xFFCFE8EA),
    orange: Color(0xFFFF9A3D),
    gMain: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF8A2B), Color(0xFFFFA24A)],
    ),
    gBg: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFE3FAF2), Color(0xFFCDF1F7), Color(0xFFF8F4DC)],
      stops: [0, 0.48, 1],
    ),
    gCard: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xEBFFFFFF), Color(0xD9ECFAFA)],
    ),
    glassFill: Color(0xBDFFFFFF),
    glassBorder: Color(0xB3FFFFFF),
    artStart: Color(0xFF1F4D3A),
    artEnd: Color(0xFF8FB39A),
    artHighlight: Color(0x8CFFECAA),
    artScrim: Color(0xC708140E),
    shadow1: [
      BoxShadow(color: Color(0x141F4D3A), blurRadius: 8, offset: Offset(0, 2)),
    ],
    shadow2: [
      BoxShadow(
        color: Color(0x291F4D3A),
        blurRadius: 32,
        offset: Offset(0, 12),
      ),
    ],
  );

  /// `:root[data-theme="dark"]` from the same layer.
  static const CgRefColors dark = CgRefColors(
    bg: Color(0xFF0A1C20),
    surface: Color(0xFF112A30),
    primary: Color(0xFF6FE0D6),
    onPrimary: Color(0xFF2B1500),
    secondary: Color(0xFF2E8F96),
    accent: Color(0xFFFFB766),
    text: Color(0xFFE8F6F5),
    text2: Color(0xFF9CC0C2),
    outline: Color(0xFF1F4249),
    orange: Color(0xFFFF9A3D),
    gMain: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF8A2B), Color(0xFFFFA24A)],
    ),
    gBg: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0A1C20), Color(0xFF0E2A30), Color(0xFF13303A)],
      stops: [0, 0.5, 1],
    ),
    gCard: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF133038), Color(0xFF0F262C)],
    ),
    glassFill: Color(0xE0112A30),
    glassBorder: Color(0x2EFFFFFF),
    artStart: Color(0xFF1F4D3A),
    artEnd: Color(0xFF8FB39A),
    artHighlight: Color(0x8CFFECAA),
    artScrim: Color(0xC708140E),
    shadow1: [
      BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
    shadow2: [
      BoxShadow(
        color: Color(0x99000000),
        blurRadius: 32,
        offset: Offset(0, 12),
      ),
    ],
  );

  static CgRefColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// Colour of the fixed dark-green artwork header, which the reference keeps
  /// identical in both themes.
  static const Color onArt = Colors.white;
}

/// Type scale from the reference: Playfair Display for display copy, DM Sans
/// for everything functional, Hind Siliguri as the Bengali fallback.
abstract final class CgRefType {
  CgRefType._();

  static const String serif = 'PlayfairDisplay';
  static const String sans = 'DMSans';
  static const List<String> fallback = ['HindSiliguri'];

  /// `.display` — 700 34/40, tracking −0.5.
  static const TextStyle display = TextStyle(
    fontFamily: serif,
    fontFamilyFallback: fallback,
    fontSize: 34,
    height: 40 / 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  /// `.headline` — 700 28/34, tracking −0.3.
  static const TextStyle headline = TextStyle(
    fontFamily: serif,
    fontFamilyFallback: fallback,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  /// `.title` — 600 22/28.
  static const TextStyle title = TextStyle(
    fontFamily: serif,
    fontFamilyFallback: fallback,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
  );

  /// `.titles` — 700 18/24.
  static const TextStyle titles = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w700,
  );

  /// `.body` — 400 16/24.
  static const TextStyle body = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  /// `.bodys` — 400 14/20.
  static const TextStyle bodyS = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );

  /// `.label` — 500 12/16.
  static const TextStyle label = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
  );

  /// `.btn` — 700 16.
  static const TextStyle button = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w700,
  );

  /// `.chip` — 500 14.
  static const TextStyle chip = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
  );
}

/// Shape tokens: `--r-input`, `--r-card`, `--r-sheet`, `--r-pill`.
abstract final class CgRefRadii {
  CgRefRadii._();

  static const double input = 16;
  static const double card = 24;
  static const double sheet = 28;
  static const double pill = 999;
}
