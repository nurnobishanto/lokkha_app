import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/network/api_client.dart';
import 'package:lokkha/shared/models/user.dart';
import 'package:lokkha/features/home/home.dart';
import '../models/device_session_model.dart';

abstract class ProfileRemoteDataSource {
  Future<User?> getProfile();
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? email,
    String? gender,
    String? dateOfBirth,
    String? occupation,
    String? organization,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    File? photoFile,
  });
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
  Future<UserDevicesData?> getDevices();
  Future<Map<String, dynamic>> terminateDevice(int deviceId);
  Future<Map<String, dynamic>> logoutOtherDevices();
  Future<DashboardOverviewModel?> getDashboardOverview();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<User?> getProfile() async {
    try {
      final response = await ApiClient.get(AppConstants.v1UserProfile);
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] is Map) {
          return User.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('[ProfileRemoteDataSource] getProfile error: $e');
      rethrow;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? email,
    String? gender,
    String? dateOfBirth,
    String? occupation,
    String? organization,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    File? photoFile,
  }) async {
    try {
      MultipartFile? photoMultipart;
      if (photoFile != null && await photoFile.exists()) {
        photoMultipart = await MultipartFile.fromFile(
          photoFile.path,
          filename: photoFile.path.split('/').last,
        );
      }

      final Map<String, dynamic> formMap = {
        'name': name.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (gender != null && gender.trim().isNotEmpty) 'gender': gender.trim(),
        if (dateOfBirth != null && dateOfBirth.trim().isNotEmpty)
          'date_of_birth': dateOfBirth.trim(),
        if (occupation != null && occupation.trim().isNotEmpty)
          'occupation': occupation.trim(),
        if (organization != null && organization.trim().isNotEmpty)
          'organization': organization.trim(),
        if (addressLine1 != null && addressLine1.trim().isNotEmpty)
          'address_line_1': addressLine1.trim(),
        if (addressLine2 != null && addressLine2.trim().isNotEmpty)
          'address_line_2': addressLine2.trim(),
        if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
        if (state != null && state.trim().isNotEmpty) 'state': state.trim(),
        if (zipCode != null && zipCode.trim().isNotEmpty)
          'zip_code': zipCode.trim(),
        if (country != null && country.trim().isNotEmpty)
          'country': country.trim(),
        if (photoMultipart != null) 'photo': photoMultipart,
      };

      final formData = FormData.fromMap(formMap);
      final response = await ApiClient.post(
        AppConstants.v1UserProfileUpdate,
        data: formData,
      );

      if (response.data is Map) {
        return response.data as Map<String, dynamic>;
      }
      return {'success': response.statusCode == 200};
    } catch (e) {
      debugPrint('[ProfileRemoteDataSource] updateProfile error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await ApiClient.post(
        AppConstants.v1UserChangePassword,
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
      );

      if (response.data is Map) {
        return response.data as Map<String, dynamic>;
      }
      return {'success': response.statusCode == 200};
    } catch (e) {
      debugPrint('[ProfileRemoteDataSource] changePassword error: $e');
      rethrow;
    }
  }

  @override
  Future<UserDevicesData?> getDevices() async {
    try {
      final response = await ApiClient.get(AppConstants.v1UserDevices);
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] is Map) {
          return UserDevicesData.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('[ProfileRemoteDataSource] getDevices error: $e');
      rethrow;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> terminateDevice(int deviceId) async {
    try {
      final response = await ApiClient.delete(
        '${AppConstants.v1UserDevices}/$deviceId',
      );
      if (response.data is Map) {
        return response.data as Map<String, dynamic>;
      }
      return {'success': response.statusCode == 200};
    } catch (e) {
      debugPrint('[ProfileRemoteDataSource] terminateDevice error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> logoutOtherDevices() async {
    try {
      final response = await ApiClient.post(
        AppConstants.v1UserDevicesLogoutOthers,
      );
      if (response.data is Map) {
        return response.data as Map<String, dynamic>;
      }
      return {'success': response.statusCode == 200};
    } catch (e) {
      debugPrint('[ProfileRemoteDataSource] logoutOtherDevices error: $e');
      rethrow;
    }
  }

  @override
  Future<DashboardOverviewModel?> getDashboardOverview() async {
    try {
      final response = await ApiClient.get(AppConstants.v1DashboardOverview);
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is Map
            ? response.data as Map<String, dynamic>
            : {};
        return DashboardOverviewModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('[ProfileRemoteDataSource] getDashboardOverview error: $e');
    }
    return null;
  }
}
