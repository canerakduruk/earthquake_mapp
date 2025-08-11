import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true, // Material 3 aktif
      scaffoldBackgroundColor: Colors.white, // Sayfa arka plan rengi

      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.white, // Temanın genel tonu turuncu
        brightness: Brightness.light,

        primary:
            Colors.deepOrangeAccent, // ElevatedButton, AppBar arka plan rengi
        onPrimary:
            Colors.white, // Primary arka planın üzerindeki yazı/ikon rengi

        secondary: Colors.orange, // İkincil vurgu rengi (FAB default)
        onSecondary:
            Colors.white, // Secondary arka planın üzerindeki yazı/ikon rengi

        surface: Colors.white, // Kart, dialog, sheet arka plan rengi
        onSurface: Colors.black, // Surface üzerindeki yazı/ikon rengi

        error: Colors.red,
        onError: Colors.white,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.orange, // FAB arka plan rengi
        foregroundColor: Colors.white, // FAB ikon rengi
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.black,

      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.black,
        brightness: Brightness.dark,

        primary: Colors.orangeAccent, // ElevatedButton, AppBar arka plan rengi
        onPrimary:
            Colors.black, // Primary arka planın üzerindeki yazı/ikon rengi

        secondary: Colors.orange[300]!, // İkincil vurgu rengi (FAB default)
        onSecondary:
            Colors.black, // Secondary arka planın üzerindeki yazı/ikon rengi

        surface: Colors.black, // Kart, dialog, sheet arka plan rengi
        onSurface: Colors.white, // Surface üzerindeki yazı/ikon rengi

        error: Colors.red[300]!,
        onError: Colors.black,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.orange[300], // FAB arka plan rengi
        foregroundColor: Colors.black, // FAB ikon rengi
      ),
    );
  }
}
