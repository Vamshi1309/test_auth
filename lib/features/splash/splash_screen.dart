// lib/features/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pod/core/routing/routes.dart';
import 'package:pod/core/theme/app_colors.dart';
import 'package:pod/core/utils/helpers/shared_prefs.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final prefs = await ref.read(sharedPrefsProvider.future);
    final isLoggedIn = await prefs.isLoggedIn();

    if (mounted) {
      context.go(isLoggedIn ? Routes.home : Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your logo here
            Icon(Icons.podcasts, size: 100, color: AppColors.white),
            const SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
