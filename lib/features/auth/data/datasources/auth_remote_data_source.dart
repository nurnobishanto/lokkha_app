import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/network/api_client.dart';
import 'package:lokkha/features/auth/auth.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> checkPhone(String phone);
  Future<AuthResponseModel> sendOtp(String phone, {String type = 'Login'});
  Future<AuthResponseModel> verifyOtp({required String phone, required String otp});
  Future<AuthResponseModel> login({
    required String phone,
    String? password,
    String? otp,
    String? deviceName,
  });
  Future<AuthResponseModel> register({
    required String phone,
    required String otp,
    String? referralCode,
    String? deviceName,
  });
  Future<AuthResponseModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<AuthResponseModel> checkPhone(String phone) async {
    try {
      final response = await ApiClient.post(
        AppConstants.v1AuthCheckPhone,
        data: {'phone': phone},
      );
      if (response.data is Map) {
        return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      }
      return AuthResponseModel(status: false, message: 'অপ্রত্যাশিত সার্ভার রেসপন্স।');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return AuthResponseModel(
        status: false,
        message: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।',
      );
    }
  }

  @override
  Future<AuthResponseModel> sendOtp(String phone, {String type = 'Login'}) async {
    try {
      final response = await ApiClient.post(
        AppConstants.v1AuthSendOtp,
        data: {'phone': phone, 'type': type},
      );
      if (response.data is Map) {
        return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      }
      return AuthResponseModel(status: false, message: 'ওটিপি পাঠাতে ব্যর্থ হয়েছে।');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return AuthResponseModel(
        status: false,
        message: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।',
      );
    }
  }

  @override
  Future<AuthResponseModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await ApiClient.post(
        AppConstants.v1AuthVerifyOtp,
        data: {'phone': phone, 'otp': otp},
      );
      if (response.data is Map) {
        return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      }
      return AuthResponseModel(status: false, message: 'সঠিক ওটিপি দিন।');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return AuthResponseModel(
        status: false,
        message: 'ওটিপি যাচাই করা সম্ভব হয়নি।',
      );
    }
  }

  @override
  Future<AuthResponseModel> login({
    required String phone,
    String? password,
    String? otp,
    String? deviceName,
  }) async {
    final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other');
    final isOtp = otp != null && otp.isNotEmpty;
    final payload = <String, dynamic>{
      'phone': phone,
      'type': isOtp ? 'otp' : 'password',
      'value': isOtp ? otp : (password ?? ''),
      if (password != null && password.isNotEmpty) 'password': password,
      if (otp != null && otp.isNotEmpty) 'otp': otp,
      'device_name': deviceName ?? (Platform.isAndroid ? 'Android Device' : 'iOS Device'),
      'platform': platform,
    };

    try {
      final response = await ApiClient.post(
        AppConstants.v1AuthLogin,
        data: payload,
      );
      if (response.data is Map) {
        return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      }
      return AuthResponseModel(status: false, message: 'লগইন ব্যর্থ হয়েছে।');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return AuthResponseModel(
        status: false,
        message: 'লগইন ব্যর্থ হয়েছে। ফোন ও পাসওয়ার্ড যাচাই করুন।',
      );
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String phone,
    required String otp,
    String? referralCode,
    String? deviceName,
  }) async {
    final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other');
    final payload = <String, dynamic>{
      'phone': phone,
      'otp': otp,
      if (referralCode != null && referralCode.isNotEmpty) 'referral_code': referralCode,
      'device_name': deviceName ?? (Platform.isAndroid ? 'Android Device' : 'iOS Device'),
      'platform': platform,
      'app_version': '1.0.0',
    };

    try {
      final response = await ApiClient.post(
        AppConstants.v1AuthRegister,
        data: payload,
      );
      if (response.data is Map) {
        return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      }
      return AuthResponseModel(status: false, message: 'রেজিস্ট্রেশন সম্পন্ন করা সম্ভব হয়নি।');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return AuthResponseModel(
        status: false,
        message: 'রেজিস্ট্রেশন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।',
      );
    }
  }

  @override
  Future<AuthResponseModel?> getCurrentUser() async {
    try {
      final response = await ApiClient.get(AppConstants.v1AuthMe);
      if (response.statusCode == 200 && response.data is Map) {
        return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[AuthRemoteDataSource.getCurrentUser] Error: $e');
    }
    return null;
  }

  AuthResponseModel _handleDioError(DioException e) {
    if (e.response != null && e.response?.data is Map) {
      return AuthResponseModel.fromJson(e.response!.data as Map<String, dynamic>);
    }
    return AuthResponseModel(
      status: false,
      message: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।',
    );
  }
}
