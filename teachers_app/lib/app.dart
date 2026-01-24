import 'core/themes/app_theme.dart';
import 'core/accessibility/accessibility_settings.dart';
import 'routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final accessibility = ref.watch(accessibilityProvider);

    // Get base theme and apply high contrast if enabled
    ThemeData theme = AppTheme.getTheme(currentTheme);
    if (accessibility.highContrast) {
      theme = _applyHighContrast(theme);
    }

    return MaterialApp.router(
      title: 'Minty',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: router,
      builder: (context, child) {
        // Apply font scaling
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(accessibility.fontScale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  /// Apply high contrast modifications to theme
  ThemeData _applyHighContrast(ThemeData theme) {
    // Apply bolder text styles for improved readability
    final textTheme = theme.textTheme;
    return theme.copyWith(
      textTheme: textTheme.copyWith(
        bodyLarge: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        bodyMedium: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        bodySmall: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
        labelLarge: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        labelMedium: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        titleSmall: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      colorScheme: theme.colorScheme.copyWith(
        // Increase contrast for key colors
        onSurface: theme.brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        onSurfaceVariant: theme.brightness == Brightness.dark
            ? Colors.white70
            : Colors.black87,
      ),
    );
  }
}
