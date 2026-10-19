import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/home.dart';

class DashboardRepository {
  final RestClient _client;

  DashboardRepository({RestClient? client}) : _client = client ?? RestClient();

  /// Get Dashboard Overview strictly from live V1 API
  Future<DashboardOverviewModel?> getOverview({bool forceRefresh = false}) async {
    try {
      final response = await _client.get(Endpoints.v1DashboardOverview);
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is String
            ? jsonDecode(response.data as String) as Map<String, dynamic>
            : response.data as Map<String, dynamic>;

        return DashboardOverviewModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('[DashboardRepository] Network error: $e');
    }

    return null;
  }
}
