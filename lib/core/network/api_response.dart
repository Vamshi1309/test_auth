// lib/core/network/models/api_response.dart
class ApiResponse<T> {
  final bool success;
  final int? statusCode;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    this.statusCode,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      statusCode: json['statusCode'],
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }
}
