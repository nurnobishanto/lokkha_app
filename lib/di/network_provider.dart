import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/network/rest_client.dart';

/// Primary provider for RestClient instance following Clean Architecture
final restClientProvider = Provider<RestClient>((ref) {
  return RestClient();
});

/// Provider for Dio instance configured in RestClient
final dioProvider = Provider<Dio>((ref) {
  return ref.watch(restClientProvider).rawDio;
});
