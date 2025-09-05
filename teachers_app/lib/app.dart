import 'package:minty/core/themes/font_scale_provider.dart';

import 'core/themes/app_theme.dart';
import 'routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final fontScale = ref.watch(fontScaleProvider);

    return MaterialApp.router(
      title: 'Minty',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(currentTheme, fontScale.scaleFactor),
      routerConfig: router,
    );
  }
}
