import 'dart:io';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/shared/models/user.dart';
import '../../data/models/device_session_model.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';

abstract class ProfileRepository {
  factory ProfileRepository() =>
      ProfileRepositoryImpl(remoteDataSource: ProfileRemoteDataSourceImpl());

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
