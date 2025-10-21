import 'package:flutter/material.dart';

class DarkTheme {
  static const Color _primarySeedColor = Colors.deepOrangeAccent;

  static final ColorScheme _darkColorScheme =
      ColorScheme.fromSeed(
        seedColor: _primarySeedColor,
        brightness: Brightness.dark,
      ).copyWith(
        primaryContainer: _primarySeedColor,
        onPrimaryContainer: Colors.white,
        onSecondaryContainer: Colors.black,
      );

  static final ThemeData themeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: _darkColorScheme,
    scaffoldBackgroundColor: Colors.black,

    appBarTheme: AppBarThemeData(backgroundColor: Colors.black),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primarySeedColor,
        foregroundColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _primarySeedColor),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.black,
      surfaceTintColor: Colors.black,
    ),
  );
}
