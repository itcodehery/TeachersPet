import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Accessibility settings model
class AccessibilitySettings {
  final double fontScale; // 0.6 to 1.4 (60% to 140%)
  final bool highContrast;

  const AccessibilitySettings({
    this.fontScale = 1.0,
    this.highContrast = false,
  });

  AccessibilitySettings copyWith({double? fontScale, bool? highContrast}) {
    return AccessibilitySettings(
      fontScale: fontScale ?? this.fontScale,
      highContrast: highContrast ?? this.highContrast,
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

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final fontScale = prefs.getDouble(_fontScaleKey) ?? 1.0;
    final highContrast = prefs.getBool(_highContrastKey) ?? false;

    if (mounted) {
      state = AccessibilitySettings(
        fontScale: fontScale,
        highContrast: highContrast,
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
}

/// Global accessibility provider
final accessibilityProvider =
    StateNotifierProvider<AccessibilityNotifier, AccessibilitySettings>((ref) {
      return AccessibilityNotifier();
    });
