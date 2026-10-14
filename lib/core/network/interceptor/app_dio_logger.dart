import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Clean, developer-friendly Dio logger for console inspection during development.
class AppDioLogger extends Interceptor {
  final bool request;
  final bool requestHeader;
  final bool requestBody;
  final bool responseBody;
  final bool responseHeader;
  final bool error;
  final int maxBodyLength;

  AppDioLogger({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = true,
    this.responseBody = true,
    this.responseHeader = false,
    this.error = true,
    this.maxBodyLength = 2000,
  });

  static const String _startTimeKey = '_app_dio_request_start';
  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kDebugMode) return handler.next(options);

    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;

    if (request) {
      final buffer = StringBuffer();
      buffer.writeln('┌── 🌐 [DIO REQUEST] ──────────────────────────────────────────');
      buffer.writeln('│ ➡️ [${options.method.toUpperCase()}] ${options.uri}');

      if (requestHeader && options.headers.isNotEmpty) {
        buffer.writeln('│ 🏷️ Headers:');
        options.headers.forEach((key, value) {
          buffer.writeln('│    $key: $value');
        });
      }

      if (options.queryParameters.isNotEmpty) {
        buffer.writeln('│ 📦 QueryParams:');
        buffer.writeln('│    ${_formatJson(options.queryParameters)}');
      }

      if (requestBody && options.data != null) {
        buffer.writeln('│ 📝 Body:');
        buffer.writeln('│    ${_formatBody(options.data)}');
      }

      buffer.write('└─────────────────────────────────────────────────────────────');
      debugPrint(buffer.toString());
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!kDebugMode) return handler.next(response);

    final duration = _calculateDuration(response.requestOptions);

    if (responseBody) {
      final buffer = StringBuffer();
      final statusCode = response.statusCode ?? 200;
      final statusMessage = response.statusMessage ?? 'OK';

      buffer.writeln('┌── ✅ [DIO RESPONSE] $statusCode $statusMessage ($duration) ─────────────');
      buffer.writeln('│ ⬅️ [${response.requestOptions.method.toUpperCase()}] ${response.requestOptions.uri}');

      if (responseHeader && response.headers.map.isNotEmpty) {
        buffer.writeln('│ 🏷️ Headers:');
        response.headers.map.forEach((key, value) {
          buffer.writeln('│    $key: $value');
        });
      }

      if (response.data != null) {
        buffer.writeln('│ 📄 Data:');
        buffer.writeln('│    ${_formatBody(response.data)}');
      }

      buffer.write('└─────────────────────────────────────────────────────────────');
      debugPrint(buffer.toString());
    }

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kDebugMode) return handler.next(err);

    final duration = _calculateDuration(err.requestOptions);

    if (error) {
      final buffer = StringBuffer();
      final statusCode = err.response?.statusCode ?? 'N/A';
      final statusMessage = err.response?.statusMessage ?? err.type.name;

      buffer.writeln('┌── ❌ [DIO ERROR] $statusCode $statusMessage ($duration) ──────────────');
      buffer.writeln('│ ⚠️ [${err.requestOptions.method.toUpperCase()}] ${err.requestOptions.uri}');
      buffer.writeln('│ 💬 Message: ${err.message ?? 'No error message'}');

      if (err.response?.data != null) {
        buffer.writeln('│ 📄 Error Response:');
        buffer.writeln('│    ${_formatBody(err.response!.data)}');
      }

      buffer.write('└─────────────────────────────────────────────────────────────');
      debugPrint(buffer.toString());
    }

    return handler.next(err);
  }

  String _calculateDuration(RequestOptions options) {
    final startTime = options.extra[_startTimeKey] as int?;
    if (startTime == null) return 'N/A';
    final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;
    return '${elapsed}ms';
  }

  String _formatBody(dynamic data) {
    try {
      if (data is FormData) {
        final fields = data.fields.map((f) => '${f.key}: ${f.value}').join(', ');
        final files = data.files.map((f) => '${f.key}: ${f.value.filename}').join(', ');
        return 'FormData { fields: [$fields], files: [$files] }';
      }
      if (data is Map || data is List) {
        final formatted = _encoder.convert(data);
        if (formatted.length > maxBodyLength) {
          return '${formatted.substring(0, maxBodyLength)}... (truncated ${formatted.length - maxBodyLength} chars)';
        }
        return formatted.replaceAll('\n', '\n│    ');
      }
      final str = data.toString();
      if (str.length > maxBodyLength) {
        return '${str.substring(0, maxBodyLength)}... (truncated)';
      }
      return str;
    } catch (_) {
      return data.toString();
    }
  }

  String _formatJson(dynamic data) {
    try {
      final formatted = _encoder.convert(data);
      return formatted.replaceAll('\n', '\n│    ');
    } catch (_) {
      return data.toString();
    }
  }
}
