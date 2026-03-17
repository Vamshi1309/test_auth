// lib/core/network/api_endpoints.dart
// This file can be empty or used for grouping endpoints
// Your AppConfig already handles this well!

class ApiEndpoints {
  // Add any additional endpoint helpers here if needed
  // For example, pagination helpers:

  static String withPagination(String endpoint,
      {int page = 1, int limit = 20}) {
    final separator = endpoint.contains('?') ? '&' : '?';
    return '$endpoint${separator}page=$page&limit=$limit';
  }

  static String withQuery(String endpoint, Map<String, dynamic> params) {
    if (params.isEmpty) return endpoint;
    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    final separator = endpoint.contains('?') ? '&' : '?';
    return '$endpoint$separator$queryString';
  }
}
