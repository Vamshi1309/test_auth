// lib/core/network/dio_provider.dart
import 'package:dio/dio.dart';
import 'package:pod/core/config/app_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pod/core/network/interceptors/logging_interceptor.dart';
import 'package:pod/core/utils/helpers/shared_prefs.dart';
import 'package:pod/core/di/locator.dart';
import 'package:pod/core/routing/routes.dart';
import 'package:go_router/go_router.dart';

part 'dio_provider.g.dart';

@riverpod
Dio dio(DioRef ref) {
  // Keep this provider alive to avoid closing the Dio adapter while
  // it's still in use by ongoing requests (prevents "adapter was closed" errors).
  ref.keepAlive();

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'pod-app',
        'Accept-Encoding': 'gzip, deflate',
        'Content-Type': 'application/json',
      },
      // Allow all status codes (200, 400, 403, 500, etc.) to pass through
      // so the caller can handle them. Dio defaults to throwing on 4xx/5xx.
      validateStatus: (status) => status != null,
    ),
  );

  // ✅ Token/session interceptor WITH TOKEN REFRESH
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await ref.read(sharedPrefsProvider.future);
        final token = await prefs.getToken();
        final sessionId = await prefs.getSessionId();

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (sessionId != null) {
          options.headers['sessionid'] = sessionId;
        }

        return handler.next(options);
      },
      onResponse: (response, handler) async {
        // Auto-save new token/session from headers
        final newToken = response.headers.value('token');
        final newSession = response.headers.value('sessionid');

        final prefs = await ref.read(sharedPrefsProvider.future);
        if (newToken != null) {
          await prefs.saveToken(newToken);
        }
        if (newSession != null) {
          await prefs.saveSessionId(newSession);
        }

        return handler.next(response);
      },
      // ✅ NEW: Handle 401 and attempt token refresh
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final prefs = await ref.read(sharedPrefsProvider.future);
          final refreshToken = await prefs.getRefreshToken();

          if (refreshToken != null) {
            try {
              // Create separate Dio instance for refresh (no interceptors)
              final refreshDio = Dio(
                BaseOptions(
                  baseUrl: AppConfig.baseUrl,
                  connectTimeout: const Duration(seconds: 10),
                  receiveTimeout: const Duration(seconds: 10),
                ),
              );

              // Call refresh endpoint
              final response = await refreshDio.post(
                AppConfig.authRefresh,
                data: {'refreshToken': refreshToken},
              );

              if (response.statusCode == 200 &&
                  response.data['success'] == true) {
                final data = response.data['data'];
                final newToken = data['token'] ?? data['accessToken'];
                final newRefreshToken = data['refreshToken'];

                if (newToken != null) {
                  // Save new tokens
                  await prefs.saveToken(newToken);
                  if (newRefreshToken != null) {
                    await prefs.saveRefreshToken(newRefreshToken);
                  }

                  // Retry original request with new token
                  error.requestOptions.headers['Authorization'] =
                      'Bearer $newToken';
                  final retryResponse = await dio.fetch(error.requestOptions);
                  return handler.resolve(retryResponse);
                }
              }
            } catch (_) {
              // Refresh failed - logout user
              await prefs.clearAuth();
              await prefs.setLoggedIn(false);

              final context = ref.read(navigatorKeyProvider).currentContext;
              if (context != null && context.mounted) {
                context.go(Routes.login);
              }
            }
          }
        }

        return handler.next(error);
      },
    ),
  );

  // Logging interceptor (pretty logs only in debug)
  dio.interceptors.add(LoggingInterceptor());

  // Keep ref to allow invalidation if needed
  ref.onDispose(() => dio.close());

  return dio;
}
