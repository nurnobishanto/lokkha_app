import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/app/router/route_observer.dart';
import 'package:lokkha/core/network/rest_client.dart';

void main() {
  group('AppDioLogger Interceptor Tests', () {
    late Dio dio;
    late AppDioLogger logger;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      logger = AppDioLogger();
      dio.interceptors.add(logger);
    });

    test('AppDioLogger logs request without throwing', () {
      final options = RequestOptions(
        path: '/api/v1/auth/login',
        method: 'POST',
        headers: {'Authorization': 'Bearer test_token'},
        data: {'phone': '01712345678'},
      );

      final handler = RequestInterceptorHandler();
      expect(() => logger.onRequest(options, handler), returnsNormally);
    });

    test('AppDioLogger logs response with duration without throwing', () {
      final options = RequestOptions(path: '/api/v1/auth/login', method: 'POST');
      options.extra['_app_dio_request_start'] = DateTime.now().millisecondsSinceEpoch - 150;

      final response = Response(
        requestOptions: options,
        statusCode: 200,
        statusMessage: 'OK',
        data: {'success': true, 'message': 'Login successful.'},
      );

      final handler = ResponseInterceptorHandler();
      expect(() => logger.onResponse(response, handler), returnsNormally);
    });

    test('AppDioLogger logs DioException without throwing', () {
      final options = RequestOptions(path: '/api/v1/auth/login', method: 'POST');
      options.extra['_app_dio_request_start'] = DateTime.now().millisecondsSinceEpoch - 200;

      final err = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: options,
          statusCode: 401,
          data: {'message': 'Unauthorized'},
        ),
      );

      final handler = _FakeErrorInterceptorHandler();
      logger.onError(err, handler);
      expect(handler.nextError, equals(err));
    });

    test('RestClient initializes with AppDioLogger in debug mode', () {
      final client = RestClient();
      final hasLogger = client.client.interceptors.any((i) => i is AppDioLogger);
      expect(hasLogger, isTrue);
    });
  });

  group('AppRouteObserver Navigation Tests', () {
    test('AppRouteObserver handles route lifecycle events without error', () {
      final observer = AppRouteObserver();

      final route1 = MaterialPageRoute(
        builder: (_) => const SizedBox(),
        settings: const RouteSettings(name: '/auth-gateway'),
      );
      final route2 = MaterialPageRoute(
        builder: (_) => const SizedBox(),
        settings: const RouteSettings(name: '/signin'),
      );

      expect(() => observer.didPush(route1, null), returnsNormally);
      expect(() => observer.didPush(route2, route1), returnsNormally);
      expect(() => observer.didPop(route2, route1), returnsNormally);
      expect(() => observer.didReplace(newRoute: route2, oldRoute: route1), returnsNormally);
      expect(() => observer.didRemove(route1, null), returnsNormally);
    });
  });
}

class _FakeErrorInterceptorHandler extends ErrorInterceptorHandler {
  DioException? nextError;

  @override
  void next(DioException err) {
    nextError = err;
  }
}
