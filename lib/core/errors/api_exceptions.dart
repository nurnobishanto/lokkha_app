import 'package:dio/dio.dart';

/// Base domain-friendly application exception
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const AppException(
    this.message, {
    this.statusCode,
    this.details,
  });

  @override
  String toString() => message;
}

/// Network connectivity / timeout exception
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.statusCode,
    super.details,
  });
}

/// Unauthorized / Session expired exception (401, 403)
class UnauthorizedException extends AppException {
  const UnauthorizedException(
    super.message, {
    super.statusCode,
    super.details,
  });
}

/// Remote server error (500, bad response)
class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.statusCode,
    super.details,
  });
}

/// Legacy ApiException for backward compatibility
class ApiException extends AppException {
  final String url;
  final Response? response;

  ApiException({
    required this.url,
    required String message,
    this.response,
    int? statusCode,
  }) : super(message, statusCode: statusCode, details: response?.data);

  @override
  String toString() {
    String result = '';
    result += response?.data?['error'] ?? '';
    if (result.isEmpty) {
      result += message;
    }
    return result;
  }
}
