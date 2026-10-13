import 'dart:async';

import 'package:dio/dio.dart';

import '../errors/exceptions.dart';
import '../storage/secure_storage_service.dart';
import 'endpoints.dart';

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

  Options? _mergeOptions(Options? options, Map<String, dynamic>? headers) {
    if (headers == null || headers.isEmpty) return options;
    final merged = options ?? Options();
    merged.headers = {...?merged.headers, ...headers};
    return merged;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: _mergeOptions(options, headers),
      );
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
    Map<String, dynamic>? headers,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _mergeOptions(options, headers),
      );
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
    Map<String, dynamic>? headers,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _mergeOptions(options, headers),
      );
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
    Map<String, dynamic>? headers,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _mergeOptions(options, headers),
      );
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
    Map<String, dynamic>? headers,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _mergeOptions(options, headers),
      );
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

