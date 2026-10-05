import 'package:dio/dio.dart';

/// Failure from the backend, carrying the user-facing message.
///
/// Submit-style service calls throw this instead of returning `null` so the
/// UI can show *why* something failed (e.g. "Only 3 seats available").
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Convert a [DioException] into an [ApiException] with the backend's
/// `detail` message when available.
ApiException apiExceptionFrom(DioException e) {
  final response = e.response;
  if (response != null) {
    final data = response.data;
    final detail = data is Map ? data['detail'] : null;
    final message = detail is String && detail.isNotEmpty
        ? detail
        : 'Request failed (${response.statusCode})';
    return ApiException(message, statusCode: response.statusCode);
  }
  return ApiException('Connection error. Please check your network.');
}
