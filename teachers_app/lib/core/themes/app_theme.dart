import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.lime,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.lime,
        brightness: Brightness.light,
      ),
      brightness: Brightness.light,
      fontFamily: 'Outfit',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.lime,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.lime,
        brightness: Brightness.dark,
      ),
      brightness: Brightness.dark,
      fontFamily: 'Outfit',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
    );
  }
}
