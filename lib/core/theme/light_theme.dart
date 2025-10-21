import 'package:flutter/material.dart';

class LightTheme {
  static const Color _primarySeedColor = Colors.orange;

  static final ColorScheme _lightColorScheme =
      ColorScheme.fromSeed(
        seedColor: _primarySeedColor,
        brightness: Brightness.light,
      ).copyWith(
        primaryContainer: _primarySeedColor,
        onPrimaryContainer: Colors.white,
        onSecondaryContainer: Colors.black,
      );

  static final ThemeData themeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: _lightColorScheme,
    scaffoldBackgroundColor: Colors.white,

    appBarTheme: AppBarThemeData(backgroundColor: Colors.white),
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
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
    )
  );
}
