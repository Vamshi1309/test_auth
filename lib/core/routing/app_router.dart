// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:pod/features/auth/login_screen.dart';
import 'package:pod/features/splash/splash_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pod/core/di/locator.dart';
import 'package:pod/core/routing/routes.dart';
import 'package:pod/core/theme/app_colors.dart';
import 'package:pod/core/utils/helpers/shared_prefs.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final navigatorKey = ref.watch(navigatorKeyProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    initialLocation: Routes.splash,

    // ✅ FIXED: Auth redirect logic
    redirect: (context, state) async {
      final currentPath = state.matchedLocation;

      // ✅ CRITICAL: Always allow splash to show first
      if (currentPath == Routes.splash) {
        return null; // Let splash screen handle its own navigation
      }

      // Check auth state for other routes
      final prefs = await ref.read(sharedPrefsProvider.future);
      final isLoggedIn = await prefs.isLoggedIn();
      final isAuthRoute =
          currentPath == Routes.login || currentPath == Routes.login;

      // Redirect logic for protected routes
      if (!isLoggedIn && !isAuthRoute) {
        return Routes.login; // Not logged in → go to login
      }

      if (isLoggedIn && isAuthRoute) {
        return Routes.home; // Already logged in → go to home
      }

      return null; // No redirect needed
    },

    routes: [
      // ════════════════════════════════════════════════════════════════════
      // SPLASH SCREEN
      // ════════════════════════════════════════════════════════════════════
      GoRoute(
        path: Routes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ════════════════════════════════════════════════════════════════════
      // AUTH ROUTES
      // ════════════════════════════════════════════════════════════════════
      // GoRoute(
      //   path: Routes.login,
      //   name: 'login',
      //   builder: (context, state) => const LoginScreen(),
      // ),
    ],

    // ════════════════════════════════════════════════════════════════════
    // ERROR HANDLING
    // ════════════════════════════════════════════════════════════════════
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
}

// ══════════════════════════════════════════════════════════════════════════
// ERROR SCREEN
// ══════════════════════════════════════════════════════════════════════════

class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: AppColors.error,
                ),
              ),

              const SizedBox(height: 32),

              // Error Title
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Error Message
              Text(
                error?.toString() ?? 'Page not found',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Go Home Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => context.go(Routes.home),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Go to Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Go Back Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(Routes.home);
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Go Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
