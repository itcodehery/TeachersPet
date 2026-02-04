import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Auto-save interval options (in seconds, 0 = disabled)
class AutoSaveInterval {
  static const int disabled = 0;
  static const int seconds30 = 30;
  static const int minute1 = 60;
  static const int minutes2 = 120;
  static const int minutes5 = 300;

  static const List<int> options = [
    disabled,
    seconds30,
    minute1,
    minutes2,
    minutes5,
  ];

  static String getLabel(int seconds) {
    switch (seconds) {
      case 0:
        return 'Disabled';
      case 30:
        return '30 seconds';
      case 60:
        return '1 minute';
      case 120:
        return '2 minutes';
      case 300:
        return '5 minutes';
      default:
        return '$seconds seconds';
    }
  }
}

/// Accessibility settings model
class AccessibilitySettings {
  final double fontScale; // 0.8 to 1.3 (80% to 130%)
  final bool highContrast;
  final int autoSaveInterval; // in seconds, 0 = disabled

  const AccessibilitySettings({
    this.fontScale = 1.0,
    this.highContrast = false,
    this.autoSaveInterval = 60, // Default: 1 minute
  });

  AccessibilitySettings copyWith({
    double? fontScale,
    bool? highContrast,
    int? autoSaveInterval,
  }) {
    return AccessibilitySettings(
      fontScale: fontScale ?? this.fontScale,
      highContrast: highContrast ?? this.highContrast,
      autoSaveInterval: autoSaveInterval ?? this.autoSaveInterval,
    );
  }
}

/// Accessibility settings notifier with persistence
class AccessibilityNotifier extends StateNotifier<AccessibilitySettings> {
  AccessibilityNotifier() : super(const AccessibilitySettings()) {
    _loadSettings();
  }

  static const String _fontScaleKey = 'accessibility_font_scale';
  static const String _highContrastKey = 'accessibility_high_contrast';
  static const String _autoSaveKey = 'accessibility_auto_save_interval';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final fontScale = prefs.getDouble(_fontScaleKey) ?? 1.0;
    final highContrast = prefs.getBool(_highContrastKey) ?? false;
    final autoSaveInterval = prefs.getInt(_autoSaveKey) ?? 60;

    if (mounted) {
      state = AccessibilitySettings(
        fontScale: fontScale,
        highContrast: highContrast,
        autoSaveInterval: autoSaveInterval,
      );
    }
  }

  Future<void> setFontScale(double scale) async {
    state = state.copyWith(fontScale: scale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, scale);
  }

  Future<void> setHighContrast(bool enabled) async {
    state = state.copyWith(highContrast: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, enabled);
  }

  Future<void> setAutoSaveInterval(int seconds) async {
    state = state.copyWith(autoSaveInterval: seconds);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoSaveKey, seconds);
  }
}

/// Global accessibility provider
final accessibilityProvider =
    StateNotifierProvider<AccessibilityNotifier, AccessibilitySettings>((ref) {
      return AccessibilityNotifier();
    });
