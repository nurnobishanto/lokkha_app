import 'package:flutter/foundation.dart';
import 'package:lokkha/core/network/rest_client.dart';
import '../models/app_info_model.dart';

abstract class AppSystemRemoteDataSource {
  Future<AppInfoModel> getAppInfo({String? platform, dynamic versionCode});
  Future<ClientVersionCheckModel> checkUpdate({
    required String platform,
    required dynamic versionCode,
  });
}

class AppSystemRemoteDataSourceImpl implements AppSystemRemoteDataSource {
  final RestClient _client;

  AppSystemRemoteDataSourceImpl({RestClient? client}) : _client = client ?? RestClient();

  @override
  Future<AppInfoModel> getAppInfo({String? platform, dynamic versionCode}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (platform != null && platform.isNotEmpty) {
        queryParams['platform'] = platform;
      }
      if (versionCode != null) {
        queryParams['version_code'] = versionCode.toString();
      }

      final response = await _client.get(
        Endpoints.v1AppInfo,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data is Map<String, dynamic>) {
        return AppInfoModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Invalid response format from ${Endpoints.v1AppInfo}');
      }
    } catch (e) {
      debugPrint('[AppSystemRemoteDataSource] getAppInfo error: $e');
      rethrow;
    }
  }

  @override
  Future<ClientVersionCheckModel> checkUpdate({
    required String platform,
    required dynamic versionCode,
  }) async {
    try {
      final response = await _client.post(
        Endpoints.v1AppInfoCheckUpdate,
        data: {
          'platform': platform,
          'version_code': versionCode.toString(),
        },
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] is Map<String, dynamic>) {
          return ClientVersionCheckModel.fromJson(
              data['data'] as Map<String, dynamic>);
        }
      }
      throw Exception('Invalid check-update response');
    } catch (e) {
      debugPrint('[AppSystemRemoteDataSource] checkUpdate error: $e');
      rethrow;
    }
  }
}
