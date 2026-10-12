import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lokkha/core/compat/get_compat.dart';
import 'package:lokkha/core/constants/app_strings.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

import '../errors/exceptions.dart';
import '../storage/secure_storage_service.dart';
import 'endpoints.dart';
import 'interceptor/token_manager.dart';

export 'endpoints.dart';
export 'interceptor/token_manager.dart';

/// Production-ready REST HTTP client with interceptors and typed error mapping.
class RestClient {
  final Dio _dio;
  final SecureStorageService secureStorageService;

  RestClient({
    Dio? dio,
    this.secureStorageService = const SecureStorageService(),
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: Endpoints.baseUrl,
                connectTimeout: Endpoints.connectTimeout,
                receiveTimeout: Endpoints.receiveTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'X-API-Key': Endpoints.xApiKey,
                },
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorageService.getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Map DioException to domain-friendly AppException
          final appException = _mapDioException(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: appException,
            ),
          );
        },
      ),
    );
  }

  Dio get rawDio => _dio;
  Dio get client => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _unwrapException(e);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _unwrapException(e);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _unwrapException(e);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _unwrapException(e);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _unwrapException(e);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      throw _unwrapException(e);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  AppException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException('Network connection timeout. Please check your connectivity.');
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        final message = data is Map ? (data['message'] ?? 'Server error') : 'Server error occurred.';
        if (status == 401 || status == 403) {
          return UnauthorizedException(message.toString(), statusCode: status);
        }
        return ServerException(message.toString(), statusCode: status, details: data);
      case DioExceptionType.cancel:
        return const AppException('Request was cancelled.');
      default:
        return AppException(error.message ?? 'Unknown network error.');
    }
  }

  AppException _unwrapException(DioException e) {
    if (e.error is AppException) {
      return e.error as AppException;
    }
    return _mapDioException(e);
  }
}

/// Backward compatibility alias
typedef DioClient = RestClient;

/// Static facade and BaseClient adapter for Clean Architecture data sources and legacy controllers
class ApiClient {
  ApiClient._();
  factory ApiClient() => _shared;
  static final ApiClient _shared = ApiClient._();

  static RestClient? _customClient;
  static RestClient get instance => _customClient ??= RestClient();
  static set customClient(RestClient client) => _customClient = client;

  static Dio get dio => instance.rawDio;

  static void init({Dio? customDio}) {
    if (customDio != null) {
      _customClient = RestClient(dio: customDio);
    }
  }

  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) =>
      instance.get<T>(path, queryParameters: queryParameters, options: options);

  static Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      instance.post<T>(path, data: data, queryParameters: queryParameters, options: options);

  static Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      instance.put<T>(path, data: data, queryParameters: queryParameters, options: options);

  static Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      instance.patch<T>(path, data: data, queryParameters: queryParameters, options: options);

  static Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      instance.delete<T>(path, data: data, queryParameters: queryParameters, options: options);

  static Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) =>
      instance.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        data: data,
        options: options,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Legacy BaseClient Adapter
// ─────────────────────────────────────────────────────────────────────────────

enum RequestType {
  get,
  post,
  put,
  delete,
}

class BaseClient {
  static Dio get dio => ApiClient.dio;
  static Dio get _dio => ApiClient.dio;

  static Future<void> safeApiCall(
    String url,
    RequestType requestType, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    required Function(Response response) onSuccess,
    Function(ApiException)? onError,
    Function(int value, int progress)? onReceiveProgress,
    Function(int total, int progress)? onSendProgress,
    Function? onLoading,
    dynamic data,
  }) async {
    try {
      await onLoading?.call();

      final options = headers != null ? Options(headers: headers) : null;
      late Response response;

      switch (requestType) {
        case RequestType.get:
          response = await _dio.get(
            url,
            onReceiveProgress: onReceiveProgress,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case RequestType.post:
          response = await _dio.post(
            url,
            data: data,
            onReceiveProgress: onReceiveProgress,
            onSendProgress: onSendProgress,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case RequestType.put:
          response = await _dio.put(
            url,
            data: data,
            onReceiveProgress: onReceiveProgress,
            onSendProgress: onSendProgress,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case RequestType.delete:
          response = await _dio.delete(
            url,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
      }

      await onSuccess(response);
    } on DioException catch (error) {
      _handleDioError(error: error, url: url, onError: onError);
    } on SocketException {
      _handleSocketException(url: url, onError: onError);
    } on TimeoutException {
      _handleTimeoutException(url: url, onError: onError);
    } catch (error) {
      _handleUnexpectedException(url: url, onError: onError, error: error);
    }
  }

  static Future<void> download({
    required String url,
    required String savePath,
    Function(ApiException)? onError,
    Function(int value, int progress)? onReceiveProgress,
    required Function onSuccess,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        options: Options(
          receiveTimeout: const Duration(milliseconds: 9999),
          sendTimeout: const Duration(milliseconds: 9999),
        ),
        onReceiveProgress: onReceiveProgress,
      );
      onSuccess();
    } catch (error) {
      final exception = ApiException(url: url, message: error.toString());
      onError?.call(exception) ?? _handleError(error.toString());
    }
  }

  static void _handleUnexpectedException({
    Function(ApiException)? onError,
    required String url,
    required Object error,
  }) {
    if (kDebugMode) debugPrint("[BaseClient] Unexpected error: $error");
    final message = Strings.somethingWentWrong.tr;
    if (onError != null) {
      onError(ApiException(message: message, url: url));
    } else {
      _handleError(message);
    }
  }

  static void _handleTimeoutException({
    Function(ApiException)? onError,
    required String url,
  }) {
    if (kDebugMode) debugPrint("[BaseClient] Timeout error on $url");
    final message = Strings.serverNotResponding.tr;
    if (onError != null) {
      onError(ApiException(message: message, url: url));
    } else {
      _handleError(message);
    }
  }

  static void _handleSocketException({
    Function(ApiException)? onError,
    required String url,
  }) {
    if (kDebugMode) debugPrint("[BaseClient] No internet connection for $url");
    final message = Strings.noInternetConnection.tr;
    if (onError != null) {
      onError(ApiException(message: message, url: url));
    } else {
      _handleError(message);
    }
  }

  static void _handleDioError({
    required DioException error,
    Function(ApiException)? onError,
    required String url,
  }) {
    if (kDebugMode) debugPrint("[BaseClient] Dio error on $url: ${error.message}");

    final statusCode = error.response?.statusCode;

    if (statusCode == 401) {
      final isAuthEndpoint = url.contains('/auth/') ||
          url.contains('login') ||
          url.contains('send-otp') ||
          url.contains('check-phone');

      if (!isAuthEndpoint) {
        String? serverMsg;
        if (error.response?.data is Map) {
          serverMsg = error.response?.data['message']?.toString();
        }
        final exception = ApiException(
          message: serverMsg ?? 'আপনার সেশনের মেয়াদ শেষ হয়ে গেছে। অনুগ্রহ করে পুনরায় লগইন করুন।',
          url: url,
          statusCode: 401,
          response: error.response,
        );
        if (onError != null) {
          return onError(exception);
        }
        return;
      }
    }

    if (statusCode == 404) {
      final message = Strings.urlNotFound.tr;
      final exception = ApiException(message: message, url: url, statusCode: 404);
      if (onError != null) {
        return onError(exception);
      } else {
        _handleError(message);
      }
      return;
    }

    if (statusCode != null && statusCode >= 500) {
      final message = Strings.serverNotResponding.tr;
      final exception = ApiException(message: message, url: url, statusCode: statusCode);
      if (onError != null) {
        return onError(exception);
      } else {
        _handleError(message);
      }
      return;
    }

    var exception = ApiException(
      url: url,
      message: error.message ?? Strings.somethingWentWrong.tr,
      response: error.response,
      statusCode: statusCode,
    );
    if (onError != null) {
      return onError(exception);
    } else {
      _handleError(exception.message);
    }
  }

  static void _handleError(String msg) {
    CustomSnackBar.showCustomErrorToast(message: msg);
  }
}
