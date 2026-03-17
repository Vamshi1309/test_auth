// lib/core/network/api_service_provider.dart
import 'package:dio/dio.dart';
import 'package:pod/core/connectivity/connectivity_provider.dart';
import 'package:pod/core/network/api_response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pod/core/di/locator.dart';
import 'package:pod/core/error/failures.dart';
import 'package:pod/core/network/dio_provider.dart';
import 'package:pod/core/utils/snackbar.dart';

part 'api_service_provider.g.dart';

@riverpod
class ApiService extends _$ApiService {
  static const _maxRetries = 3;
  static const _retryDelay = Duration(seconds: 2);

  @override
  void build() {}

  late final Dio _dio = ref.read(dioProvider);

  // --- Public API Methods ---

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object?) fromJsonT,
  }) =>
      _call(() => _dio.get(path, queryParameters: queryParameters), fromJsonT);

  Future<T> post<T>(
    String path, {
    dynamic data,
    required T Function(Object?) fromJsonT,
  }) =>
      _call(() => _dio.post(path, data: data), fromJsonT);

  Future<T> put<T>(
    String path, {
    dynamic data,
    required T Function(Object?) fromJsonT,
  }) =>
      _call(() => _dio.put(path, data: data), fromJsonT);

  // ✅ NEW: PATCH method
  Future<T> patch<T>(
    String path, {
    dynamic data,
    required T Function(Object?) fromJsonT,
  }) =>
      _call(() => _dio.patch(path, data: data), fromJsonT);

  // ✅ NEW: DELETE method
  Future<T> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object?) fromJsonT,
  }) =>
      _call(
        () => _dio.delete(path, queryParameters: queryParameters),
        fromJsonT,
      );

  // --- Internal Logic ---

  Future<T> _call<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Object?) fromJsonT,
  ) async {
    // ✅ FIXED: Check connectivity ONCE upfront (not inside retry loop)
    final isConnected =
        await ref.read(connectivityStatusProvider.notifier).isConnected;

    if (!isConnected) {
      _showNoInternetToast();
      throw const NetworkFailure();
    }

    Failure? lastFailure;

    // ✅ Retry loop now only runs for actual network/server errors
    for (int i = 0; i < _maxRetries; i++) {
      try {
        final response = await request();

        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300) {
          // 1. Centralized Unwrapping
          final apiResponse = ApiResponse<T>.fromJson(
            response.data as Map<String, dynamic>,
            fromJsonT,
          );

          // 2. Success Flag Validation
          if (!apiResponse.success) {
            throw ServerFailure(apiResponse.message,
                statusCode: apiResponse.statusCode);
          }

          // 3. Return only the data payload
          if (apiResponse.data == null) {
            throw const ServerFailure('No data returned from server');
          }

          return apiResponse.data!;
        }

        throw _mapStatusCode(response.statusCode!, response.data);
      } on DioException catch (e) {
        lastFailure = _mapDioError(e);
        if (_shouldRetry(e) && i < _maxRetries - 1) {
          await Future.delayed(_retryDelay);
          continue;
        }
        throw lastFailure;
      } catch (e) {
        if (e is Failure) rethrow;
        throw UnknownFailure(e.toString());
      }
    }
    throw lastFailure!;
  }

  void _showNoInternetToast() {
    final context = ref.read(navigatorKeyProvider).currentContext;
    if (context != null && context.mounted) {
      AppSnackBar.warning(context, 'No internet connection');
    }
  }

  bool _shouldRetry(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      (e.response?.statusCode ?? 0) >= 500;

  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.badResponse) {
      return _mapStatusCode(e.response!.statusCode!, e.response!.data);
    }
    return const NetworkFailure('Network connection error');
  }

  Failure _mapStatusCode(int statusCode, dynamic data) {
    final message = data is Map ? data['message'] ?? data['error'] : null;
    return switch (statusCode) {
      401 => UnauthorizedFailure(message),
      404 => NotFoundFailure(message),
      _ => ServerFailure(message ?? 'Server error', statusCode: statusCode),
    };
  }
}
