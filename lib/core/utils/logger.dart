// lib/core/utils/logger.dart
import 'package:flutter/foundation.dart';

class Logger {
  static void i(String message) {
    if (kDebugMode) {
      print('💡 $message');
    }
  }

  static void s(String message) {
    if (kDebugMode) {
      print('✅ $message');
    }
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ $message');
      if (error != null) print('   Error: $error');
      if (stackTrace != null) print(stackTrace);
    }
  }
}
