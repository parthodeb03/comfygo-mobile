import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'one_ui_colors.dart';
import 'one_ui_typography.dart';

/// ComfyGo Theme Configuration
/// Green-and-white light mode matching the reference UI kit
class OneUITheme {
  OneUITheme._();

  // ═══════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: OneUITypography.fontFamily,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: OneUIColors.primaryLight,
        onPrimary: Color(0xFF20271A),
        primaryContainer: OneUIColors.primarySoft,
        onPrimaryContainer: OneUIColors.primaryVariantLight,
        secondary: OneUIColors.secondaryLight,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFE8F5E9),
        onSecondaryContainer: Color(0xFF2E7D32),
        tertiary: OneUIColors.tertiaryLight,
        onTertiary: Colors.white,
        surface: OneUIColors.surfaceLight,
        onSurface: OneUIColors.textPrimaryLight,
        surfaceContainerHighest: OneUIColors.surfaceVariantLight,
        error: OneUIColors.error,
        onError: Colors.white,
        outline: OneUIColors.dividerLight,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: OneUIColors.backgroundLight,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: OneUIColors.backgroundLight,
        foregroundColor: OneUIColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: OneUITypography.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: OneUIColors.textPrimaryLight,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // Card Theme - flat with subtle elevation
      cardTheme: CardThemeData(
        color: OneUIColors.surfaceLight,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: OneUIColors.surfaceLight,
        selectedItemColor: OneUIColors.primaryLight,
        unselectedItemColor: OneUIColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: OneUITypography.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: OneUITypography.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Elevated Button - full-width green, highly visible white text
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OneUIColors.primaryLight,
          foregroundColor: Color(0xFF20271A),
          elevation: 0,
          shadowColor: OneUIColors.buttonGreen.withValues(alpha: 0.45),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontFamily: OneUITypography.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
        ),
      ),

      // Filled Button - vibrant CTA
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: OneUIColors.primaryLight,
          foregroundColor: Color(0xFF20271A),
          elevation: 0,
          shadowColor: OneUIColors.buttonGreen.withValues(alpha: 0.45),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontFamily: OneUITypography.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
        ),
      ),

      // Outlined Button - white with thin gray border
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: OneUIColors.textPrimaryLight,
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontFamily: OneUITypography.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: OneUIColors.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(
            fontFamily: OneUITypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input Decoration - pill-rounded gray fill
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OneUIColors.inputFillLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(
            color: OneUIColors.primaryLight,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: OneUIColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: OneUIColors.error, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontFamily: OneUITypography.fontFamily,
          color: OneUIColors.textHintLight,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          fontFamily: OneUITypography.fontFamily,
          color: OneUIColors.textSecondaryLight,
          fontSize: 14,
        ),
      ),

      // Chip Theme - pill-shaped
      chipTheme: ChipThemeData(
        backgroundColor: OneUIColors.surfaceVariantLight,
        selectedColor: OneUIColors.primaryLight,
        labelStyle: const TextStyle(
          fontFamily: OneUITypography.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: OneUIColors.dividerLight,
        thickness: 0.5,
        space: 1,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return OneUIColors.primaryLight;
          }
          return Colors.grey.shade300;
        }),
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: OneUIColors.primaryLight,
        unselectedLabelColor: OneUIColors.textSecondaryLight,
        indicatorColor: OneUIColors.primaryLight,
        labelStyle: TextStyle(
          fontFamily: OneUITypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: OneUITypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: OneUIColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: OneUIColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontFamily: OneUITypography.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: OneUIColors.textPrimaryLight,
        ),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: OneUIColors.textPrimaryLight,
        contentTextStyle: const TextStyle(
          fontFamily: OneUITypography.fontFamily,
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: OneUIColors.primaryLight,
        linearTrackColor: OneUIColors.surfaceVariantLight,
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: OneUITypography.fontFamily,

      colorScheme: const ColorScheme.dark(
        primary: OneUIColors.primaryDark,
        onPrimary: Color(0xFF20271A),
        primaryContainer: OneUIColors.primaryVariantLight,
        onPrimaryContainer: OneUIColors.primarySoft,
        secondary: OneUIColors.secondaryDark,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFF1B5E20),
        onSecondaryContainer: Color(0xFFA5D6A7),
        tertiary: OneUIColors.tertiaryDark,
        onTertiary: Colors.white,
        surface: OneUIColors.surfaceDark,
        onSurface: OneUIColors.textPrimaryDark,
        surfaceContainerHighest: OneUIColors.surfaceVariantDark,
        error: OneUIColors.error,
        onError: Colors.white,
        outline: OneUIColors.dividerDark,
      ),

      scaffoldBackgroundColor: OneUIColors.backgroundDark,

      appBarTheme: const AppBarTheme(
        backgroundColor: OneUIColors.backgroundDark,
        foregroundColor: OneUIColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: OneUITypography.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: OneUIColors.textPrimaryDark,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      cardTheme: CardThemeData(
        color: OneUIColors.surfaceDark,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: OneUIColors.surfaceDark,
        selectedItemColor: OneUIColors.primaryDark,
        unselectedItemColor: OneUIColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: OneUITypography.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: OneUITypography.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OneUIColors.buttonGreen,
          foregroundColor: Color(0xFF20271A),
          elevation: 0,
          shadowColor: OneUIColors.buttonGreen.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontFamily: OneUITypography.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
        ),
      ),

      // Filled Button - vibrant CTA
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: OneUIColors.buttonGreen,
          foregroundColor: Color(0xFF20271A),
          elevation: 0,
          shadowColor: OneUIColors.buttonGreen.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontFamily: OneUITypography.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: OneUIColors.textPrimaryDark,
          side: const BorderSide(color: Color(0xFF424242), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontFamily: OneUITypography.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: OneUIColors.primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(
            fontFamily: OneUITypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OneUIColors.surfaceVariantDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(
            color: OneUIColors.primaryDark,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: OneUIColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: OneUIColors.error, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontFamily: OneUITypography.fontFamily,
          color: OneUIColors.textHintDark,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          fontFamily: OneUITypography.fontFamily,
          color: OneUIColors.textSecondaryDark,
          fontSize: 14,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: OneUIColors.surfaceVariantDark,
        selectedColor: OneUIColors.primaryDark,
        labelStyle: const TextStyle(
          fontFamily: OneUITypography.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),

      dividerTheme: const DividerThemeData(
        color: OneUIColors.dividerDark,
        thickness: 0.5,
        space: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return OneUIColors.primaryDark;
          }
          return Colors.grey.shade700;
        }),
      ),

      tabBarTheme: const TabBarThemeData(
        labelColor: OneUIColors.primaryDark,
        unselectedLabelColor: OneUIColors.textSecondaryDark,
        indicatorColor: OneUIColors.primaryDark,
        labelStyle: TextStyle(
          fontFamily: OneUITypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: OneUITypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: OneUIColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: OneUIColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontFamily: OneUITypography.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: OneUIColors.textPrimaryDark,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: OneUIColors.textPrimaryDark,
        contentTextStyle: const TextStyle(
          fontFamily: OneUITypography.fontFamily,
          fontSize: 14,
          color: Colors.black,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: OneUIColors.primaryDark,
        linearTrackColor: OneUIColors.surfaceVariantDark,
      ),
    );
  }
}
