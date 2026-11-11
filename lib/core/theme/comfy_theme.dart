// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Folders, theme, routes and reusable widgets from the Phase 1 plan.

import 'package:flutter/material.dart';

import 'comfy_design.dart';

/// Material theme built from the ComfyGo Mobile UI tokens.
///
/// Screens read colours from [CgColors] directly; this theme keeps built-in
/// widgets (app bars, dialogs, snack bars, pickers, progress) consistent with
/// the same design language.
abstract final class CgTheme {
  CgTheme._();

  static const Color _errorLight = Color(0xFFC0453A);
  static const Color _errorDark = Color(0xFFFFB4AB);

  static ThemeData get light => _build(CgColors.light, Brightness.light);

  static ThemeData get dark => _build(CgColors.dark, Brightness.dark);

  static ThemeData _build(CgColors c, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final error = isDark ? _errorDark : _errorLight;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.mint,
      onPrimaryContainer: c.primary,
      secondary: c.sage,
      onSecondary: c.onPrimary,
      surface: c.surface,
      onSurface: c.text,
      surfaceContainerHighest: c.mint,
      onSurfaceVariant: c.text2,
      outline: c.line,
      outlineVariant: c.line,
      error: error,
      onError: isDark ? CgColors.dark.bg : Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      fontFamily: CgType.family,
      fontFamilyFallback: CgType.fallback,
      splashFactory: InkSparkle.splashFactory,
    );

    final text = base.textTheme.apply(bodyColor: c.text, displayColor: c.text);

    return base.copyWith(
      textTheme: text.copyWith(
        displayLarge: CgType.h1Bold.copyWith(fontSize: 40, color: c.text),
        displayMedium: CgType.h1Bold.copyWith(fontSize: 34, color: c.text),
        headlineMedium: CgType.pageTitle.copyWith(color: c.text),
        headlineSmall: CgType.t20.copyWith(color: c.text),
        titleLarge: CgType.t20.copyWith(color: c.text),
        titleMedium: CgType.t16.copyWith(color: c.text),
        bodyLarge: CgType.body15.copyWith(color: c.text),
        bodyMedium: CgType.b14.copyWith(color: c.text),
        bodySmall: CgType.l12.copyWith(color: c.text2),
        labelLarge: CgType.button.copyWith(color: c.text),
        labelMedium: CgType.l12.copyWith(color: c.text2),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: CgType.t20.copyWith(color: c.text),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CgRadii.card),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CgRadii.card),
        ),
        titleTextStyle: CgType.t20.copyWith(color: c.text),
        contentTextStyle: CgType.b14.copyWith(color: c.text2),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(CgRadii.sheet),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.primary,
        contentTextStyle: CgType.b14.copyWith(color: c.onPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hintStyle: CgType.body15.copyWith(color: c.text2),
        labelStyle: CgType.l12.copyWith(color: c.text2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CgRadii.input),
          borderSide: BorderSide(color: c.line, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CgRadii.input),
          borderSide: BorderSide(color: c.line, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CgRadii.input),
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CgRadii.input),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CgRadii.input),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          minimumSize: const Size(0, 56),
          shape: const StadiumBorder(),
          textStyle: CgType.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.text,
          minimumSize: const Size(0, 56),
          side: BorderSide(color: c.line, width: 1.5),
          shape: const StadiumBorder(),
          textStyle: CgType.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          textStyle: CgType.button.copyWith(fontSize: 14),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.mint,
      ),
      dividerTheme: DividerThemeData(color: c.line, thickness: 1),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? c.primary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(c.onPrimary),
        side: BorderSide(color: c.line, width: 1.5),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? c.onPrimary : c.text2,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? c.primary : c.line,
        ),
      ),
    );
  }
}
