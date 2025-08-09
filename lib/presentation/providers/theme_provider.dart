import 'package:earthquake_mapp/core/utils/logger_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((
  ref,
) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _prefsKey = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.system) {
    LoggerHelper.info("ThemeNotifier", "Initializing ThemeNotifier...");
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    LoggerHelper.debug(
      "ThemeNotifier",
      "Loading theme from SharedPreferences...",
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_prefsKey) ?? 'system';
      state = _stringToThemeMode(themeString);
      LoggerHelper.info(
        "ThemeNotifier",
        "Loaded theme from prefs: $themeString",
      );
    } catch (e, st) {
      LoggerHelper.err(
        "ThemeNotifier",
        "Failed to load theme from prefs",
        e,
        st,
      );
    }
  }

  Future<void> setTheme(ThemeMode newTheme) async {
    LoggerHelper.info(
      "ThemeNotifier",
      "Setting theme to ${_themeModeToString(newTheme)}",
    );
    state = newTheme;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _themeModeToString(newTheme));
      LoggerHelper.info("ThemeNotifier", "Saved theme to prefs");
    } catch (e, st) {
      LoggerHelper.err("ThemeNotifier", "Failed to save theme to prefs", e, st);
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _stringToThemeMode(String str) {
    switch (str) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
