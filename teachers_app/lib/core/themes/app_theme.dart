import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_storage.dart';

enum AppThemeType { light, dark, minty, ocean, midday, sunset, mintyLegacy }

class AppTheme {
  static const String fontFamily = 'Outfit';

  static ThemeData getTheme(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return _lightTheme;
      case AppThemeType.dark:
        return _darkTheme;
      case AppThemeType.minty:
        return _mintyTheme;
      case AppThemeType.ocean:
        return _oceanTheme;
      case AppThemeType.midday:
        return _sunsetTheme;
      case AppThemeType.sunset:
        return _sunsetOrangeTheme;
      case AppThemeType.mintyLegacy:
        return _mintyLegacyTheme;
    }
  }

  static ThemeData get _lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.lime,
      brightness: Brightness.light,
    );
    return ThemeData(
      primarySwatch: Colors.lime,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.primary,
      ),
      scaffoldBackgroundColor: Colors.white,
      cardTheme: CardThemeData(
        color: Colors.grey[50],
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lime[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  static ThemeData get _darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.lime,
      brightness: Brightness.dark,
    );
    return ThemeData(
      primarySwatch: Colors.lime,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.primary,
      ),
      scaffoldBackgroundColor: Colors.limeAccent.withAlpha(10),
      cardTheme: CardThemeData(
        color: Colors.grey[850],
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lime[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  static ThemeData get _mintyTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.light,
    );
    return ThemeData(
      primarySwatch: Colors.teal,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.primary,
      ),
      scaffoldBackgroundColor: Colors.teal[50],
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  static ThemeData get _oceanTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    );
    return ThemeData(
      primarySwatch: Colors.blue,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.primary,
      ),
      scaffoldBackgroundColor: Colors.blue[50],
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  static ThemeData get _sunsetTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.light,
    );
    return ThemeData(
      primarySwatch: Colors.orange,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.primary,
      ),
      scaffoldBackgroundColor: Colors.orange[50],
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  static ThemeData get _sunsetOrangeTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.dark,
    );
    return ThemeData(
      primarySwatch: Colors.orange,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.primary,
      ),
      scaffoldBackgroundColor: Colors.orangeAccent.withAlpha(10),
      cardTheme: CardThemeData(
        color: Colors.grey[850],
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  static ThemeData get _mintyLegacyTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.dark,
    );
    return ThemeData(
      primarySwatch: Colors.teal,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.primary,
      ),
      scaffoldBackgroundColor: Colors.tealAccent.withAlpha(10),
      cardTheme: CardThemeData(
        color: Colors.grey[850],
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

// Theme provider with persistence
class ThemeNotifier extends StateNotifier<AppThemeType> {
  ThemeNotifier() : super(AppThemeType.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedTheme = await ThemeStorage.loadTheme();
    if (mounted) {
      state = savedTheme;
    }
  }

  Future<void> setTheme(AppThemeType theme) async {
    state = theme;
    await ThemeStorage.saveTheme(theme);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeType>((ref) {
  return ThemeNotifier();
});

// Extension for theme type to string
extension AppThemeTypeExtension on AppThemeType {
  String get displayName {
    switch (this) {
      case AppThemeType.light:
        return 'Light';
      case AppThemeType.dark:
        return 'Dark';
      case AppThemeType.minty:
        return 'Minty Teal';
      case AppThemeType.ocean:
        return 'Ocean Blue';
      case AppThemeType.midday:
        return 'Midday Orange';
      case AppThemeType.sunset:
        return 'Sunset Orange';
      case AppThemeType.mintyLegacy:
        return 'Minty Legacy';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeType.light:
        return Icons.light_mode;
      case AppThemeType.dark:
        return Icons.dark_mode;
      case AppThemeType.minty:
        return Icons.eco;
      case AppThemeType.ocean:
        return Icons.water;
      case AppThemeType.midday:
        return Icons.wb_sunny_outlined;
      case AppThemeType.sunset:
        return Icons.nights_stay;
      case AppThemeType.mintyLegacy:
        return Icons.history;
    }
  }
}
