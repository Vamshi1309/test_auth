import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pod/core/di/locator.dart'; // Assuming navigatorKeyProvider is here
import 'package:pod/core/theme/app_colors.dart';

class AppSnackBar {
  // --- UI Methods ---
  static void success(BuildContext context, String message) =>
      _show(context, message, AppColors.success, Icons.check_circle);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppColors.error, Icons.error);

  static void warning(BuildContext context, String message) =>
      _show(context, message, AppColors.warning, Icons.warning);

  // --- Global Methods (For Providers/Notifiers) ---
  static void globalError(WidgetRef ref, String message) {
    final context = ref.read(navigatorKeyProvider).currentContext;
    if (context != null) error(context, message);
  }

  static void globalSuccess(WidgetRef ref, String message) {
    final context = ref.read(navigatorKeyProvider).currentContext;
    if (context != null) success(context, message);
  }

  // --- Private Core Logic ---
  static void _show(
      BuildContext context, String message, Color color, IconData icon) {
    // 1. Safety check
    if (!context.mounted) return;

    // 2. Clear existing snackbars so they don't queue up
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // 3. Show the styled SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
