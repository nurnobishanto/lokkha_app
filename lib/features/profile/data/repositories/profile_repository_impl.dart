import 'dart:io';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/shared/models/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/device_session_model.dart';
import '../models/exam_history_model.dart';
import '../models/exam_review_detail_model.dart';
import '../models/order_v1_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User?> getProfile() {
    return remoteDataSource.getProfile();
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
  }) {
    return remoteDataSource.updateProfile(
      name: name,
      email: email,
      gender: gender,
      dateOfBirth: dateOfBirth,
      occupation: occupation,
      organization: organization,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      state: state,
      zipCode: zipCode,
      country: country,
      photoFile: photoFile,
    );
  }

  @override
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  @override
  Future<UserDevicesData?> getDevices() {
    return remoteDataSource.getDevices();
  }

  @override
  Future<Map<String, dynamic>> terminateDevice(int deviceId) {
    return remoteDataSource.terminateDevice(deviceId);
  }

  @override
  Future<Map<String, dynamic>> logoutOtherDevices() {
    return remoteDataSource.logoutOtherDevices();
  }

  @override
  Future<DashboardOverviewModel?> getDashboardOverview() {
    return remoteDataSource.getDashboardOverview();
  }

  @override
  Future<ExamHistoryResponseModel> getExamHistory({int page = 1}) {
    return remoteDataSource.getExamHistory(page: page);
  }

  @override
  Future<ExamReviewDetailModel> getExamHistoryDetail(
    dynamic id, {
    ExamHistoryModel? summaryExam,
  }) {
    return remoteDataSource.getExamHistoryDetail(id, summaryExam: summaryExam);
  }

  @override
  Future<OrderV1ListResponse> getUserOrders({
    String status = 'all',
    String modelType = 'all',
    String paymentMethod = 'all',
    String? search,
    int page = 1,
    int perPage = 10,
  }) {
    return remoteDataSource.getUserOrders(
      status: status,
      modelType: modelType,
      paymentMethod: paymentMethod,
      search: search,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<OrderDetailV1Data> getOrderDetails(dynamic id) {
    return remoteDataSource.getOrderDetails(id);
  }
}
