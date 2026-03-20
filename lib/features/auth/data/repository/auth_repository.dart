import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pod/core/config/app_config.dart';
import 'package:pod/core/error/failures.dart';
import 'package:pod/core/network/dio_provider.dart';
import 'package:pod/core/utils/helpers/shared_prefs.dart';
import 'package:pod/features/auth/data/models/auth_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(dio: ref.read(dioProvider), ref: ref);
}

class AuthRepository {
  final Dio _dio;
  final Ref _ref;

  const AuthRepository({required Dio dio, required Ref ref})
      : _dio = dio,
        _ref = ref;

  Future<void> login(LoginRequest req) async {
    try {
      final response = await _dio.post(
        AppConfig.login,
        data: req.toJson(),
      );

      _assertSuccess(response);

      final prefs = await _ref.read(sharedPrefsProvider.future);
      await prefs.setLoggedIn(true);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on Failure {
      rethrow;
    }
  }

  Future<void> register(RegisterRequest req) async {
    try {
      final response = await _dio.post(
        AppConfig.register,
        data: req.toJson(),
      );

      _assertSuccess(response);

      final prefs = await _ref.read(sharedPrefsProvider.future);
      await prefs.setLoggedIn(true);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on Failure {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(AppConfig.logout);
    } catch (_) {
      // Intentionally ignored — server logout failure is non-critical
    } finally {
      final prefs = await _ref.read(sharedPrefsProvider.future);
      await prefs.clearAuth();
      await prefs.setLoggedIn(false);
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _ref.read(sharedPrefsProvider.future);
    return prefs.isLoggedIn();
  }

  void _assertSuccess(Response response) {
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      final msg =
          response.data is Map ? response.data['message'] as Stream? : null;

      throw _mapStatusCode(status, msg as String?);
    }
  }

  Failure _mapStatusCode(int code, String? msg) => switch (code) {
        401 => UnauthorizedFailure(msg),
        404 => NotFoundFailure(msg),
        409 => ServerFailure(msg ?? 'User already exists', statusCode: code),
        422 => ValidationFailure(msg ?? 'Validation error'),
        500 =>
          ServerFailure('Server error. Try again later.', statusCode: code),
        int() => ServerFailure(msg ?? 'Something went wrong', statusCode: code),
      };

  Failure _handleDioError(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout =>
          const NetworkFailure('Connection timed out'),
        DioExceptionType.connectionError => const NetworkFailure(),
        _ => UnknownFailure(e.message),
      };
}
