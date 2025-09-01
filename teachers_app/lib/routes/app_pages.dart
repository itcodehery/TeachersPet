import 'package:minty/features/home/presentation/pages/home_page.dart';
import 'package:minty/features/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import 'package:minty/features/form_builder/saved_forms_service.dart';
import 'package:minty/features/form_builder/form_builder_screen.dart';
import 'package:minty/features/home/saved_forms_screen.dart';

final router = GoRouter(
  initialLocation: '/home',
  navigatorKey: GlobalNavigation.instance.navigatorKey,
  routes: [
    GoRoute(
      name: Names.home,
      path: Routes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      name: Names.formBuilder,
      path: Routes.formBuilder,
      builder: (context, state) {
        final form = state.extra as SavedForm?;
        return FormBuilderScreen(form: form);
      },
    ),
    GoRoute(
      name: Names.savedForms,
      path: Routes.savedForms,
      builder: (context, state) => const SavedFormsScreen(),
    ),
    GoRoute(
      name: Names.settings,
      path: Routes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);

class GlobalNavigation {
  static final GlobalNavigation instance = GlobalNavigation._internal();
  GlobalNavigation._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
