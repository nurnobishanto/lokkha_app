import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // kDebugMode
import 'package:get/get_utils/get_utils.dart';
import 'package:get/state_manager.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../config/translations/strings_enum.dart';
import '../components/custom_snackbar.dart';
import 'api_exceptions.dart';
import 'auth_service.dart';

enum RequestType {
  get,
  post,
  put,
  delete,
}

class BaseClient {
  static final Dio _dio = Dio()
    ..interceptors.addIf(
      kDebugMode, // Only add logger in debug mode
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: false,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

  /// dio getter (used for testing)
  static get dio => _dio;

  /// Perform safe API request
  static safeApiCall(
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

      late Response response;
      switch (requestType) {
        case RequestType.get:
          response = await _dio.get(
            url,
            onReceiveProgress: onReceiveProgress,
            queryParameters: queryParameters,
            options: Options(headers: headers),
          );
          break;
        case RequestType.post:
          response = await _dio.post(
            url,
            data: data,
            onReceiveProgress: onReceiveProgress,
            onSendProgress: onSendProgress,
            queryParameters: queryParameters,
            options: Options(headers: headers),
          );
          break;
        case RequestType.put:
          response = await _dio.put(
            url,
            data: data,
            onReceiveProgress: onReceiveProgress,
            onSendProgress: onSendProgress,
            queryParameters: queryParameters,
            options: Options(headers: headers),
          );
          break;
        case RequestType.delete:
          response = await _dio.delete(
            url,
            data: data,
            queryParameters: queryParameters,
            options: Options(headers: headers),
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

  /// Download file
  static download({
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

  static _handleUnexpectedException({
    Function(ApiException)? onError,
    required String url,
    required Object error,
  }) {
    _logError('Unexpected error: $error');
    final message = Strings.somethingWentWrong.tr;
    if (onError != null) {
      onError(ApiException(message: message, url: url));
    } else {
      _handleError(message);
    }
  }

  static _handleTimeoutException({
    Function(ApiException)? onError,
    required String url,
  }) {
    _logError('Timeout error on $url');
    final message = Strings.serverNotResponding.tr;
    if (onError != null) {
      onError(ApiException(message: message, url: url));
    } else {
      _handleError(message);
    }
  }

  static _handleSocketException({
    Function(ApiException)? onError,
    required String url,
  }) {
    _logError('No internet connection for $url');
    final message = Strings.noInternetConnection.tr;
    if (onError != null) {
      onError(ApiException(message: message, url: url));
    } else {
      _handleError(message);
    }
  }

  static _handleDioError({
    required DioException error,
    Function(ApiException)? onError,
    required String url,
  }) {
    _logError('Dio error on $url: ${error.message}');

    final statusCode = error.response?.statusCode;
    final errorMessage = error.message?.toLowerCase() ?? '';

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
        AuthService().handleSessionExpired(message: serverMsg);
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
      final exception =
          ApiException(message: message, url: url, statusCode: 404);
      if (onError != null) {
        return onError(exception);
      } else {
        return _handleError(message);
      }
    }

    if (errorMessage.contains('socket') ||
        error.type == DioExceptionType.connectionError ||
        errorMessage.contains('failed host lookup')) {
      final message = Strings.noInternetConnection.tr;
      final exception = ApiException(message: message, url: url);
      if (onError != null) {
        return onError(exception);
      } else {
        return _handleError(message);
      }
    }

    if (statusCode == 500) {
      final message = Strings.serverError.tr;
      final exception =
          ApiException(message: message, url: url, statusCode: 500);
      if (onError != null) {
        return onError(exception);
      } else {
        return _handleError(message);
      }
    }

    // Default error
    final exception = ApiException(
      url: url,
      message: error.message.toString(),
      response: error.response,
      statusCode: statusCode,
    );
    if (onError != null) {
      return onError(exception);
    } else {
      return _handleError(exception.message);
    }
  }

  /// Show error message to user with custom snack bar
  static _handleError(String msg) {
    CustomSnackBar.showCustomErrorToast(message: msg);
  }

  /// Log errors - print only in debug, or send to remote server in release
  static void _logError(String message) {
    if (kDebugMode) {
      debugPrint("[BaseClient] $message");
    } else {
      // TODO: integrate Firebase Crashlytics or other logging
      // FirebaseCrashlytics.instance.recordError(message, null);
    }
  }
}
