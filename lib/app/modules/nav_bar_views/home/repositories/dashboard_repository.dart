import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../utils/constants.dart';
import '../../../../data/models/dashboard_overview_model.dart';
import '../../../../data/network/api_client.dart';

class DashboardRepository {
  static const String _cacheKey = 'dashboard_overview_cache';

  /// Get Dashboard Overview with automatic offline cache fallback
  Future<DashboardOverviewModel?> getOverview({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Try fetching from V1 API
    try {
      final response = await ApiClient.get(AppConstants.v1DashboardOverview);
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is String
            ? jsonDecode(response.data as String) as Map<String, dynamic>
            : response.data as Map<String, dynamic>;

        // Cache the raw JSON
        await prefs.setString(_cacheKey, jsonEncode(data));
        return DashboardOverviewModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('[DashboardRepository] Network error: $e');
    }

    // 2. Offline fallback from local cache
    final cachedString = prefs.getString(_cacheKey);
    if (cachedString != null && cachedString.isNotEmpty) {
      try {
        final Map<String, dynamic> cachedData =
            jsonDecode(cachedString) as Map<String, dynamic>;
        debugPrint('[DashboardRepository] Loaded overview from offline cache');
        return DashboardOverviewModel.fromJson(cachedData);
      } catch (e) {
        debugPrint('[DashboardRepository] Cache parse error: $e');
      }
    }

    return null;
  }
}
