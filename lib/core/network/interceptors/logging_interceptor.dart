// lib/core/network/interceptors/logging_interceptor.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../utils/logger.dart'; // Adjust path if needed

class LoggingInterceptor extends Interceptor {
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kDebugMode) {
      return super.onRequest(options, handler);
    }

    _stopwatch.reset();
    _stopwatch.start();

    final method = options.method;
    final uri = options.uri.toString();

    Logger.i('→ $method $uri');

    if (options.data != null) {
      final masked = _maskSensitiveData(options.data);
      final pretty = _prettyJson(masked);
      final lines = pretty.split('\n');

      print('   ┌─ Request');
      for (final line in lines) {
        print('   │ $line');
      }
      print('   │ }'); // close the map if it was opened
    } else {
      print('   ┌─ Request');
      print('   │ (no body)');
    }

    print(''); // breathing space before response
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!kDebugMode) {
      return super.onResponse(response, handler);
    }

    _stopwatch.stop();
    _logResponse(
      requestOptions: response.requestOptions,
      statusCode: response.statusCode!,
      data: response.data,
      isError: false,
      durationMs: _stopwatch.elapsedMilliseconds,
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kDebugMode) {
      return super.onError(err, handler);
    }

    _stopwatch.stop();
    final statusCode = err.response?.statusCode ?? 0;
    final data = err.response?.data ?? err.message;

    _logResponse(
      requestOptions: err.requestOptions,
      statusCode: statusCode,
      data: data,
      isError: true,
      durationMs: _stopwatch.elapsedMilliseconds,
    );
    super.onError(err, handler);
  }

  void _logResponse({
    required RequestOptions requestOptions,
    required int statusCode,
    required dynamic data,
    required bool isError,
    required int durationMs,
  }) {
    final method = requestOptions.method;
    final uri = requestOptions.uri.toString();

    final logger = isError ? Logger.e : Logger.s;
    logger('← $method $uri');

    print('   ├─ Status: $statusCode (${durationMs}ms)');

    final masked = _maskSensitiveData(data);
    final pretty = _prettyJson(masked);
    final lines = pretty.split('\n');

    print('   └─ Response');
    for (final line in lines) {
      print('      $line');
    }

    print('────────────────────────────────────────────────────────────');
    print(''); // clean empty line after each cycle
  }

  dynamic _maskSensitiveData(dynamic data) {
    if (data == null) return null;
    if (data is! Map && data is! List) return data;

    const sensitive = [
      'password',
      'token',
      'access_token',
      'refresh_token',
      'accessToken',
      'refreshToken',
      'secret',
      'cvv',
    ];

    dynamic mask(dynamic obj) {
      if (obj is Map) {
        final copy = Map.from(obj);
        copy.forEach((key, value) {
          final lowerKey = key.toString().toLowerCase();
          if (sensitive.any(lowerKey.contains)) {
            copy[key] = '***MASKED***';
          } else if (value is Map || value is List) {
            copy[key] = mask(value);
          }
        });
        return copy;
      } else if (obj is List) {
        return obj.map(mask).toList();
      }
      return obj;
    }

    return mask(data);
  }

  String _prettyJson(dynamic data) {
    if (data == null) return 'null';
    if (data is String) return data;

    const encoder = JsonEncoder.withIndent('  ');
    try {
      return encoder.convert(data);
    } catch (e) {
      return data.toString();
    }
  }
}
