import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FontSize { xtraSmall, small, medium, large, xtraLarge }

extension FontSizeExtension on FontSize {
  String get displayName {
    switch (this) {
      case FontSize.xtraSmall:
        return 'Extra Small';
      case FontSize.small:
        return 'Small';
      case FontSize.medium:
        return 'Medium';
      case FontSize.large:
        return 'Large';
      case FontSize.xtraLarge:
        return 'Extra Large';
    }
  }

  double get scaleFactor {
    switch (this) {
      case FontSize.xtraSmall:
        return 0.8;
      case FontSize.small:
        return 0.9;
      case FontSize.medium:
        return 1.0;
      case FontSize.large:
        return 1.1;
      case FontSize.xtraLarge:
        return 1.2;
    }
  }
}

final fontScaleProvider = StateNotifierProvider<FontScaleNotifier, FontSize>((
  ref,
) {
  return FontScaleNotifier();
});

class FontScaleNotifier extends StateNotifier<FontSize> {
  FontScaleNotifier() : super(FontSize.medium) {
    _loadFontScale();
  }

  static const _fontScaleKey = 'font_scale';

  Future<void> _loadFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    final fontScaleName = prefs.getString(_fontScaleKey);
    if (fontScaleName != null) {
      state = FontSize.values.firstWhere(
        (e) => e.name == fontScaleName,
        orElse: () => FontSize.medium,
      );
    }
  }

  Future<void> setFontScale(FontSize newScale) async {
    if (state != newScale) {
      state = newScale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fontScaleKey, newScale.name);
    }
  }
}
