// lib/core/error/failures.dart
sealed class Failure {
  const Failure(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

// Network & API failures (your ApiException → now a sealed class)
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure([String? message])
      : super(message ?? 'No internet connection', statusCode: 0);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String? message])
      : super(message ?? 'Session expired', statusCode: 401);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([String? message])
      : super(message ?? 'Resource not found', statusCode: 404);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.statusCode});
}

class UnknownFailure extends Failure {
  const UnknownFailure([String? message])
      : super(message ?? 'Something went wrong');
}
