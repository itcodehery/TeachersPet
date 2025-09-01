import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class AppSnackbar {
  static void showSuccess(BuildContext context, String message) {
    final theme = Theme.of(context);
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message: message,
        backgroundColor: theme.colorScheme.primary,
        textStyle: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    final theme = Theme.of(context);
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.info(
        message: message,
        backgroundColor: theme.colorScheme.primaryContainer,
        textStyle: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    final theme = Theme.of(context);
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        message: message,
        backgroundColor: theme.colorScheme.error,
        textStyle: TextStyle(
          color: theme.colorScheme.onError,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
