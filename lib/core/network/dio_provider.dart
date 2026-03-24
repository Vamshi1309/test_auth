// lib/core/network/dio_provider.dart
import 'package:dio/dio.dart';
import 'package:pod/core/config/app_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pod/core/network/interceptors/logging_interceptor.dart';
import 'package:pod/core/utils/helpers/shared_prefs.dart';

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
        final prefs = await ref.read(sharedPrefsProvider.future);

        // Auto-save new token/session from headers
        final newToken = response.headers.value('token');
        final newSession = response.headers.value('sessionid');

        if (newToken != null) {
          await prefs.saveToken(newToken);
        }
        if (newSession != null) {
          await prefs.saveSessionId(newSession);
        }
        if (response.requestOptions.path.contains(AppConfig.refresh)) {
          return handler.next(response);
        }

        if (response.statusCode == 401) {
          final refreshToken = await prefs.getRefreshToken();

          if (refreshToken != null) {
            try {
              final refreshDio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));

              final refreshResponse = await refreshDio.post(
                AppConfig.refresh,
                data: {'refreshToken': refreshToken},
              );

              if (refreshResponse.statusCode == 200 &&
                  refreshResponse.data['success'] == true) {
                final data = refreshResponse.data['data'];
                final newToken = data['token'];
                final newRefreshToken = data['refreshToken'];

                if (newRefreshToken != null) {
                  await prefs.saveRefreshToken(newRefreshToken);
                }

                if (newToken != null) {
                  response.requestOptions.headers['Authorization'] =
                      'Bearer $newToken';
                  await prefs.saveToken(newToken);
                  final retryResponse =
                      await dio.fetch(response.requestOptions);
                  return handler.resolve(retryResponse);
                }

                await prefs.clearAuth();
                await prefs.setLoggedIn(false);
                return handler.next(response);
              } else {
                await prefs.clearAuth();
                await prefs.setLoggedIn(false);
                return handler.next(response);
              }
            } catch (_) {
              await prefs.clearAuth();
              await prefs.setLoggedIn(false);
              return handler.next(response);
            }
          } else {
            await prefs.clearAuth();
            await prefs.setLoggedIn(false);
            return handler.next(response);
          }
        }

        return handler.next(response);
      },
    ),
  );

  // Logging interceptor (pretty logs only in debug)
  dio.interceptors.add(LoggingInterceptor());

  // Keep ref to allow invalidation if needed
  ref.onDispose(() => dio.close());

  return dio;
}
