import 'package:minty/features/home/presentation/pages/home_page.dart';
import 'package:minty/features/settings/settings_page.dart';
import 'package:minty/features/settings/privacy_policy_page.dart';
import 'package:minty/features/auth/presentation/pages/login_page.dart';
import 'package:minty/features/auth/presentation/pages/signup_page.dart';
import 'package:minty/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:minty/features/auth/presentation/pages/email_verification_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import 'package:minty/features/form_builder/saved_forms_service.dart';
import 'package:minty/features/form_builder/form_builder_screen.dart';
import 'package:minty/features/home/saved_forms_screen.dart';
import 'package:minty/features/form_builder/form_setup_wizard_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  navigatorKey: GlobalNavigation.instance.navigatorKey,
  routes: [
    GoRoute(
      name: Names.login,
      path: Routes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      name: Names.signup,
      path: Routes.signup,
      builder: (context, state) => const SignupPage(),
    ),
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
      name: Names.formWizard,
      path: Routes.formWizard,
      builder: (context, state) => const FormSetupWizardScreen(),
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
    GoRoute(
      name: Names.privacyPolicy,
      path: Routes.privacyPolicy,
      builder: (context, state) => const PrivacyPolicyPage(),
    ),
    GoRoute(
      name: Names.forgotPassword,
      path: Routes.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      name: Names.emailVerification,
      path: Routes.emailVerification,
      builder: (context, state) {
        final email = state.extra as String?;
        return EmailVerificationPage(email: email);
      },
    ),
  ],
);

class GlobalNavigation {
  static final GlobalNavigation instance = GlobalNavigation._internal();
  GlobalNavigation._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
