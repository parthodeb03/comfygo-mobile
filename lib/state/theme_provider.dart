import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/theme.dart';

/// Theme State
class ThemeState {
  final ThemeMode themeMode;
  final bool isDarkMode;

  ThemeState({this.themeMode = ThemeMode.light, this.isDarkMode = false});

  ThemeState copyWith({ThemeMode? themeMode, bool? isDarkMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

/// Theme Notifier
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeState()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    state = ThemeState(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      isDarkMode: isDark,
    );
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = !state.isDarkMode;

    await prefs.setBool(_themeKey, isDark);

    state = state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      isDarkMode: isDark,
    );
  }

  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);

    state = state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      isDarkMode: isDark,
    );
  }

  ThemeData get lightTheme => OneUITheme.lightTheme;
  ThemeData get darkTheme => OneUITheme.darkTheme;
}

/// Theme Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

/// Current Theme Provider
final currentThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeProvider);
  final notifier = ref.read(themeProvider.notifier);
  return themeState.isDarkMode ? notifier.darkTheme : notifier.lightTheme;
});
