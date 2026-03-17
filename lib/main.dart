// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pod/core/config/app_config.dart';
import 'package:pod/core/di/locator.dart';
import 'package:pod/core/routing/app_router.dart';
import 'package:pod/core/utils/logger.dart';
import 'package:pod/core/theme/app_theme.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration - CHANGE THIS LINE ONLY FOR DIFFERENT ENVIRONMENTS
  AppConfig.init(Environment.dev);

  Logger.i(
      '🚀 Starting ${AppConfig.appName} in ${AppConfig.environmentName} mode');

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Lock device orientation (optional)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Run app
  runApp(
    ProviderScope(
      observers: AppConfig.isDebug ? [RiverpodLogger()] : [],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize core providers
    ref.read(registerCoreProvidersProvider);

    // Watch router and messenger key
    final router = ref.watch(appRouterProvider);
    final scaffoldMessengerKey = ref.watch(scaffoldMessengerKeyProvider);

    // ✅ Initialize ScreenUtil FIRST
    return ScreenUtilInit(
      // Design size from your Figma/XD designs
      designSize: const Size(393, 852), // iPhone 14 Pro
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: AppConfig.isDebug,
          routerConfig: router,
          scaffoldMessengerKey: scaffoldMessengerKey,

          // ✅ Theme WITHOUT ScreenUtil (uses fixed values)
          theme: AppTheme.theme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,

          // Dismiss keyboard when tapping outside
          builder: (context, child) => GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: child!,
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Optional: Riverpod Logger for debugging
// ═══════════════════════════════════════════════════════════════════════════

// lib/main.dart - Update RiverpodLogger

class RiverpodLogger extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    // Only log in debug mode AND if it's an important provider
    if (AppConfig.isDebug) {
      Logger.i('Provider added: ${provider.name ?? provider.runtimeType}');
    }
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Don't log updates - too noisy
    // Only uncomment if debugging a specific issue
    // Logger.i('Provider updated: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    // Only log disposal if debugging
    // Logger.i('Provider disposed: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    // ✅ ALWAYS log failures (even in production for crash reporting)
    Logger.e(
      'Provider failed: ${provider.name ?? provider.runtimeType}',
      error,
      stackTrace,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Environment-specific main files (optional organization)
// ═══════════════════════════════════════════════════════════════════════════

/// lib/main_dev.dart - Development
// void main() {
//   AppConfig.init(Environment.dev);
//   runApp(const ProviderScope(child: MyApp()));
// }

/// lib/main_staging.dart - Staging
// void main() {
//   AppConfig.init(Environment.staging);
//   runApp(const ProviderScope(child: MyApp()));
// }

/// lib/main_prod.dart - Production
// void main() {
//   AppConfig.init(Environment.prod);
//   runApp(const ProviderScope(child: MyApp()));
// }

// Then in terminal:
// flutter run -t lib/main_dev.dart
// flutter run -t lib/main_staging.dart
// flutter run -t lib/main_prod.dart
