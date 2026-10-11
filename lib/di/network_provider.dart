import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/network/api_client.dart';

/// Provider for Dio instance configured in ApiClient
final dioProvider = Provider<Dio>((ref) {
  return ApiClient.dio;
});

/// Provider for ApiClient singleton
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
