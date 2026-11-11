// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Folders, theme, routes and reusable widgets from the Phase 1 plan.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design_tokens.dart';
import 'one_ui_typography.dart';

/// ComfyGo Material 3 theme.
///
/// Every colour, radius, duration and type size comes from
/// `design_tokens.dart`. Screens must read values through the theme.
class OneUITheme {
  OneUITheme._();

  static final ThemeData lightTheme = _build(
    brightness: Brightness.light,
    primary: ComfyColors.primaryLight,
    onPrimary: ComfyColors.onPrimaryLight,
    primaryContainer: ComfyColors.primaryContainerLight,
    onPrimaryContainer: ComfyColors.onPrimaryContainerLight,
    secondary: ComfyColors.secondaryLight,
    onSecondary: ComfyColors.onSecondaryLight,
    secondaryContainer: ComfyColors.primaryContainerLight,
    onSecondaryContainer: ComfyColors.onPrimaryContainerLight,
    tertiary: ComfyColors.tertiaryLight,
    onTertiary: ComfyColors.onTertiaryLight,
    tertiaryContainer: ComfyColors.tierPremiumBgLight,
    onTertiaryContainer: ComfyColors.tertiaryLight,
    background: ComfyColors.backgroundLight,
    surface: ComfyColors.surfaceLight,
    surfaceVariant: ComfyColors.surfaceVariantLight,
    onSurface: ComfyColors.textPrimaryLight,
    onSurfaceVariant: ComfyColors.textSecondaryLight,
    outline: ComfyColors.outlineLight,
    outlineVariant: ComfyColors.outlineVariantLight,
    hint: ComfyColors.textHintLight,
    error: ComfyColors.errorLight,
    onError: ComfyColors.onErrorLight,
    errorContainer: ComfyColors.statusCancelledBgLight,
    onErrorContainer: ComfyColors.statusCancelledLight,
    shadow: ComfyColors.shadow,
  );

  static final ThemeData darkTheme = _build(
    brightness: Brightness.dark,
    primary: ComfyColors.primaryDark,
    onPrimary: ComfyColors.onPrimaryDark,
    primaryContainer: ComfyColors.primaryContainerDark,
    onPrimaryContainer: ComfyColors.onPrimaryContainerDark,
    secondary: ComfyColors.secondaryDark,
    onSecondary: ComfyColors.onSecondaryDark,
    secondaryContainer: ComfyColors.primaryContainerDark,
    onSecondaryContainer: ComfyColors.onPrimaryContainerDark,
    tertiary: ComfyColors.tertiaryDark,
    onTertiary: ComfyColors.onTertiaryDark,
    tertiaryContainer: ComfyColors.tierPremiumBgDark,
    onTertiaryContainer: ComfyColors.tertiaryDark,
    background: ComfyColors.backgroundDark,
    surface: ComfyColors.surfaceDark,
    surfaceVariant: ComfyColors.surfaceVariantDark,
    onSurface: ComfyColors.textPrimaryDark,
    onSurfaceVariant: ComfyColors.textSecondaryDark,
    outline: ComfyColors.outlineDark,
    outlineVariant: ComfyColors.outlineVariantDark,
    hint: ComfyColors.textHintDark,
    error: ComfyColors.errorDark,
    onError: ComfyColors.onErrorDark,
    errorContainer: ComfyColors.statusCancelledBgDark,
    onErrorContainer: ComfyColors.statusCancelledDark,
    shadow: ComfyColors.shadow,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color onPrimary,
    required Color primaryContainer,
    required Color onPrimaryContainer,
    required Color secondary,
    required Color onSecondary,
    required Color secondaryContainer,
    required Color onSecondaryContainer,
    required Color tertiary,
    required Color onTertiary,
    required Color tertiaryContainer,
    required Color onTertiaryContainer,
    required Color background,
    required Color surface,
    required Color surfaceVariant,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outline,
    required Color outlineVariant,
    required Color hint,
    required Color error,
    required Color onError,
    required Color errorContainer,
    required Color onErrorContainer,
    required Color shadow,
  }) {
    final dark = brightness == Brightness.dark;
    final textTheme = OneUITypography.textTheme(dark: dark);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      surfaceContainerHighest: surfaceVariant,
      surfaceContainerHigh: surfaceVariant,
      surfaceContainer: surface,
      surfaceContainerLow: surface,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: ComfyColors.scrim,
      surfaceTint: primary,
      inverseSurface: onSurface,
      onInverseSurface: surface,
      inversePrimary: primaryContainer,
    );

    final disabledBackground = onSurface.withValues(
      alpha: ComfyOpacity.disabled,
    );
    final disabledContent = onSurface.withValues(
      alpha: ComfyOpacity.disabledContent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: ComfyType.bodyFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: background,
      canvasColor: surface,
      dividerColor: outlineVariant,
      disabledColor: disabledContent,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkSparkle.splashFactory,

      iconTheme: IconThemeData(color: onSurface, size: OneUISpacingIcon.md),

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: ComfyType.cardTitle.copyWith(color: onSurface),
        iconTheme: IconThemeData(color: onSurface, size: OneUISpacingIcon.md),
        actionsIconTheme: IconThemeData(
          color: onSurface,
          size: OneUISpacingIcon.md,
        ),
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                statusBarBrightness: Brightness.dark,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                statusBarBrightness: Brightness.light,
              ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: shadow.withValues(alpha: 0.08),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ComfyRadii.card),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: disabledBackground,
          disabledForegroundColor: disabledContent,
          elevation: 0,
          minimumSize: const Size(OneUISpacingTouch.min, OneUISpacingTouch.min),
          padding: const EdgeInsets.symmetric(
            horizontal: ComfySpacing.xxl,
            vertical: ComfySpacing.md,
          ),
          shape: const StadiumBorder(),
          textStyle: ComfyType.button.copyWith(color: onPrimary),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: disabledBackground,
          disabledForegroundColor: disabledContent,
          elevation: 0,
          minimumSize: const Size(OneUISpacingTouch.min, OneUISpacingTouch.min),
          padding: const EdgeInsets.symmetric(
            horizontal: ComfySpacing.xxl,
            vertical: ComfySpacing.md,
          ),
          shape: const StadiumBorder(),
          textStyle: ComfyType.button.copyWith(color: onPrimary),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          disabledForegroundColor: disabledContent,
          minimumSize: const Size(OneUISpacingTouch.min, OneUISpacingTouch.min),
          padding: const EdgeInsets.symmetric(
            horizontal: ComfySpacing.xxl,
            vertical: ComfySpacing.md,
          ),
          side: BorderSide(color: outline),
          shape: const StadiumBorder(),
          textStyle: ComfyType.button.copyWith(color: primary),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          disabledForegroundColor: disabledContent,
          minimumSize: const Size(OneUISpacingTouch.min, OneUISpacingTouch.min),
          padding: const EdgeInsets.symmetric(
            horizontal: ComfySpacing.md,
            vertical: ComfySpacing.sm,
          ),
          textStyle: ComfyType.label.copyWith(color: primary),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ComfySpacing.lg,
          vertical: ComfySpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ComfyRadii.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ComfyRadii.input),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ComfyRadii.input),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ComfyRadii.input),
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ComfyRadii.input),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        hintStyle: ComfyType.bodyM.copyWith(color: hint),
        labelStyle: ComfyType.bodyM.copyWith(color: onSurfaceVariant),
        errorStyle: ComfyType.bodyS.copyWith(color: error),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primaryContainer,
        disabledColor: disabledBackground,
        labelStyle: ComfyType.label.copyWith(color: onSurface),
        secondaryLabelStyle: ComfyType.label.copyWith(
          color: onPrimaryContainer,
        ),
        shape: const StadiumBorder(),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: ComfySpacing.md,
          vertical: ComfySpacing.sm,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: outlineVariant,
        thickness: 1,
        space: 1,
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? primary : onSurfaceVariant,
            size: OneUISpacingIcon.md,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return ComfyType.nav.copyWith(
            color: selected ? primary : onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          );
        }),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        elevation: 0,
        indicatorColor: primaryContainer,
        selectedIconTheme: IconThemeData(
          color: primary,
          size: OneUISpacingIcon.md,
        ),
        unselectedIconTheme: IconThemeData(
          color: onSurfaceVariant,
          size: OneUISpacingIcon.md,
        ),
        selectedLabelTextStyle: ComfyType.nav.copyWith(
          color: primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: ComfyType.nav.copyWith(
          color: onSurfaceVariant,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: ComfyType.nav.copyWith(color: primary),
        unselectedLabelStyle: ComfyType.nav.copyWith(color: onSurfaceVariant),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: onSurfaceVariant,
        indicatorColor: primary,
        dividerColor: outlineVariant,
        labelStyle: ComfyType.label.copyWith(
          color: primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: ComfyType.label.copyWith(color: onSurfaceVariant),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ComfyRadii.sheet),
        ),
        titleTextStyle: ComfyType.h2.copyWith(color: onSurface),
        contentTextStyle: ComfyType.bodyM.copyWith(color: onSurfaceVariant),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalBackgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ComfyRadii.sheet),
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: onSurface,
        contentTextStyle: ComfyType.bodyM.copyWith(color: background),
        actionTextColor: primary,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ComfyRadii.md),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceVariant,
        circularTrackColor: surfaceVariant,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return onPrimary;
          return onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return surfaceVariant;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return outline;
        }),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: primary,
        textColor: onSurface,
        titleTextStyle: ComfyType.bodyL.copyWith(color: onSurface),
        subtitleTextStyle: ComfyType.bodyS.copyWith(color: onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ComfySpacing.lg,
          vertical: ComfySpacing.xs,
        ),
        minVerticalPadding: ComfySpacing.sm,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: onSurface,
          borderRadius: BorderRadius.circular(ComfyRadii.sm),
        ),
        textStyle: ComfyType.caption.copyWith(color: background),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: primaryContainer,
        selectionHandleColor: primary,
      ),
    );
  }
}

/// Local aliases keep icon/touch sizes readable inside this file.
abstract final class OneUISpacingIcon {
  static const double md = 24;
}

abstract final class OneUISpacingTouch {
  static const double min = 48;
}
