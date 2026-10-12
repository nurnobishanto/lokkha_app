import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/network/rest_client.dart';

/// Provider for Dio instance configured in ApiClient
final dioProvider = Provider<Dio>((ref) {
  return ApiClient.dio;
});

/// Provider for ApiClient singleton
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Primary provider for RestClient instance following Clean Architecture
final restClientProvider = Provider<RestClient>((ref) {
  return ApiClient.instance;
});

/// Backward compatibility alias for restClientProvider
final dioClientProvider = restClientProvider;
