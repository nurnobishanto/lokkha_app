import 'package:flutter/foundation.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/features/packages/data/models/package_detail_response_model.dart';
import 'package:lokkha/features/packages/data/models/premium_package_model.dart';

abstract class PackagesRemoteDataSource {
  Future<PackageDetailResponseModel?> getPackageDetails(int packageId);

  Future<PremiumPackageModel?> getPremiumPackages({
    int page = 1,
    int perPage = 15,
    String? search,
    bool? isFeatured,
    bool? isTrial,
    String? sortBy,
  });

  Future<Map<String, dynamic>?> claimFreeTrial(int packageId);
}

class PackagesRemoteDataSourceImpl implements PackagesRemoteDataSource {
  final RestClient _client;

  PackagesRemoteDataSourceImpl({RestClient? client})
      : _client = client ?? RestClient();

  Map<String, String> _buildHeaders() {
    final token = MySharedPref.getUserToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<PackageDetailResponseModel?> getPackageDetails(int packageId) async {
    final url = Endpoints.packageDetail(packageId);
    try {
      final response = await _client.get(url, headers: _buildHeaders());
      final data = response.data;
      if (data != null && (data['success'] == true || data['status'] == true)) {
        return PackageDetailResponseModel.fromJson(data);
      }

      // If server returned status: false due to expired/invalid session, retry once as guest
      if (data != null && (data['status'] == false || data['success'] == false)) {
        final msg = data['message']?.toString().toLowerCase() ?? '';
        if (msg.contains('session') ||
            msg.contains('device') ||
            msg.contains('limit') ||
            msg.contains('unauthenticated') ||
            msg.contains('token')) {
          final guestResponse = await _client.get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          );
          final guestData = guestResponse.data;
          if (guestData != null &&
              (guestData['success'] == true || guestData['status'] == true)) {
            return PackageDetailResponseModel.fromJson(guestData);
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('[PackagesRemoteDataSource] Error fetching package details: $e');
      rethrow;
    }
  }

  @override
  Future<PremiumPackageModel?> getPremiumPackages({
    int page = 1,
    int perPage = 15,
    String? search,
    bool? isFeatured,
    bool? isTrial,
    String? sortBy,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (search != null && search.isNotEmpty) 'search': search,
      if (isFeatured != null) 'is_featured': isFeatured ? 1 : 0,
      if (isTrial != null) 'is_trial': isTrial ? 1 : 0,
      if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
    };

    try {
      final response = await _client.get(
        Endpoints.packages,
        queryParameters: queryParams,
        headers: _buildHeaders(),
      );
      final data = response.data;
      if (data != null && (data['success'] == true || data['status'] == true)) {
        return PremiumPackageModel.fromJson(data);
      }

      // If server returned status: false due to expired/invalid session, retry once as guest
      if (data != null && (data['status'] == false || data['success'] == false)) {
        final msg = data['message']?.toString().toLowerCase() ?? '';
        if (msg.contains('session') ||
            msg.contains('device') ||
            msg.contains('limit') ||
            msg.contains('unauthenticated') ||
            msg.contains('token')) {
          debugPrint(
              '[PackagesRemoteDataSource] Expired token on packages. Retrying as guest...');
          final guestResponse = await _client.get(
            Endpoints.packages,
            queryParameters: queryParams,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          );
          final guestData = guestResponse.data;
          if (guestData != null &&
              (guestData['success'] == true || guestData['status'] == true)) {
            return PremiumPackageModel.fromJson(guestData);
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('[PackagesRemoteDataSource] Error fetching premium packages: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> claimFreeTrial(int packageId) async {
    try {
      final response = await _client.post(
        Endpoints.claimFreeTrial,
        data: {'package_id': packageId},
        headers: _buildHeaders(),
      );
      if (response.data is Map) {
        return response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } catch (e) {
      debugPrint('[PackagesRemoteDataSource] Error claiming free trial: $e');
      rethrow;
    }
  }
}
