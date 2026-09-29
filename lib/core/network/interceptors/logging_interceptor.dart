import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// A smart Dio logging interceptor that pretty-prints requests & responses,
/// but automatically truncates huge payloads to keep the console clean and fast.
class LoggingInterceptor extends Interceptor {
  /// Maximum number of characters to print for response bodies before truncating.
  final int maxBodyLength;

  LoggingInterceptor({this.maxBodyLength = 1500});

  final Map<String, DateTime> _requestTimes = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kDebugMode) return handler.next(options);

    final reqKey = '${options.method}_${options.uri}';
    _requestTimes[reqKey] = DateTime.now();

    debugPrint('╔╣ Request ║ ${options.method} ║ ${options.uri}');
    if (options.data != null) {
      final bodyStr = _formatData(options.data);
      if (bodyStr.length > maxBodyLength) {
        debugPrint('║ Body (Preview):');
        _printLines(bodyStr.substring(0, maxBodyLength));
        debugPrint('║ ... [⚠️ Truncated: Request body is ${bodyStr.length} chars (~${(bodyStr.length / 1024).toStringAsFixed(1)} KB)]');
      } else {
        debugPrint('║ Body:');
        _printLines(bodyStr);
      }
    }
    debugPrint('╚══════════════════════════════════════════════════════════════════════════════╝');

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!kDebugMode) return handler.next(response);

    final reqKey = '${response.requestOptions.method}_${response.requestOptions.uri}';
    final startTime = _requestTimes.remove(reqKey);
    final duration = startTime != null
        ? '${DateTime.now().difference(startTime).inMilliseconds} ms'
        : '';

    final statusText = '${response.statusCode ?? ""} ${response.statusMessage ?? ""}';
    debugPrint('╔╣ Response ║ ${response.requestOptions.method} ║ Status: $statusText ║ Time: $duration');
    debugPrint('║  ${response.requestOptions.uri}');

    if (response.data != null) {
      final formatted = _formatData(response.data);
      if (formatted.length > maxBodyLength) {
        debugPrint('║ Body (Preview - first $maxBodyLength chars):');
        _printLines(formatted.substring(0, maxBodyLength));
        debugPrint('║ ... [⚠️ Truncated: Total response is ${formatted.length} chars (~${(formatted.length / 1024).toStringAsFixed(1)} KB)]');
      } else {
        debugPrint('║ Body:');
        _printLines(formatted);
      }
    }
    debugPrint('╚══════════════════════════════════════════════════════════════════════════════╝');

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kDebugMode) return handler.next(err);

    final reqKey = '${err.requestOptions.method}_${err.requestOptions.uri}';
    _requestTimes.remove(reqKey);

    final statusCode = err.response?.statusCode?.toString() ?? 'No Status';
    debugPrint('╔╣ Error ║ ${err.requestOptions.method} ║ Status: $statusCode');
    debugPrint('║  ${err.requestOptions.uri}');
    debugPrint('║ Message: ${err.message}');
    if (err.response?.data != null) {
      debugPrint('║ Error Body:');
      _printLines(_formatData(err.response?.data));
    }
    debugPrint('╚══════════════════════════════════════════════════════════════════════════════╝');

    return handler.next(err);
  }

  void _printLines(String text) {
    for (final line in text.split('\n')) {
      debugPrint('║ $line');
    }
  }

  String _formatData(dynamic data) {
    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }
}
