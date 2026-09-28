import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lokkha/app/data/local/my_get_storage.dart';
import 'package:lokkha/app/data/local/my_shared_pref.dart';
import 'package:lokkha/app/data/local/secure_storage_service.dart';
import 'package:lokkha/app/data/models/auth_response_model.dart';
import 'package:lokkha/app/data/network/api_client.dart';
import 'package:lokkha/app/helper/global.dart';
import 'package:lokkha/app/models/user.dart';
import 'package:lokkha/utils/constants.dart';

/// Pure V1 Authentication Repository (Single Source of Truth)
class AuthRepository {
  /// 1. Check Phone Number (POST /api/v1/auth/check-phone)
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
      debugPrint('[AuthRepository.checkPhone] Error: $e');
      return AuthResponseModel(
        status: false,
        message: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।',
      );
    }
  }

  /// 2. Send OTP (POST /api/v1/auth/send-otp)
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
      debugPrint('[AuthRepository.sendOtp] Error: $e');
      return AuthResponseModel(
        status: false,
        message: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।',
      );
    }
  }

  /// 3. Verify OTP (POST /api/v1/auth/verify-otp)
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
        final authRes = AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
        if (authRes.status && authRes.token != null) {
          await _saveSession(authRes);
        }
        return authRes;
      }
      return AuthResponseModel(status: false, message: 'সঠিক ওটিপি দিন।');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      debugPrint('[AuthRepository.verifyOtp] Error: $e');
      return AuthResponseModel(
        status: false,
        message: 'ওটিপি যাচাই করা সম্ভব হয়নি।',
      );
    }
  }

  /// 4. Login with Password or OTP (POST /api/v1/auth/login)
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
        final authRes = AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
        if (authRes.status && authRes.token != null) {
          await _saveSession(authRes);
        }
        return authRes;
      }
      return AuthResponseModel(status: false, message: 'লগইন ব্যর্থ হয়েছে।');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      debugPrint('[AuthRepository.login] Error: $e');
      return AuthResponseModel(
        status: false,
        message: 'লগইন ব্যর্থ হয়েছে। ফোন ও পাসওয়ার্ড যাচাই করুন।',
      );
    }
  }

  /// 5. Register (POST /api/v1/auth/register)
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
        final authRes = AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
        if (authRes.status && authRes.token != null) {
          await _saveSession(authRes);
        }
        return authRes;
      }
      return AuthResponseModel(status: false, message: 'রেজিস্ট্রেশন সম্পন্ন করা সম্ভব হয়নি।');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      debugPrint('[AuthRepository.register] Error: $e');
      return AuthResponseModel(
        status: false,
        message: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।',
      );
    }
  }

  /// 6. Get Current User / Validate Session (GET /api/v1/auth/me)
  Future<AuthResponseModel?> getCurrentUser() async {
    final token = await SecureStorageService.getToken();
    if (token == null || token.isEmpty) {
      isLoggedIn.value = false;
      return null;
    }

    try {
      final response = await ApiClient.get(AppConstants.v1AuthMe);
      if (response.statusCode == 200 && response.data is Map) {
        final authRes = AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
        if (authRes.status) {
          if (authRes.user != null) {
            myUser = authRes.user!;
            MyGetStorage.writeCacheData(MyGetStorage.meUser, myUser);
          }
          isLoggedIn.value = true;
          havePackage.value = authRes.havePackage;
          return authRes;
        }
      }
    } on DioException catch (e) {
      debugPrint('[AuthRepository.getCurrentUser] Status: ${e.response?.statusCode}');
      if (e.response?.statusCode == 401) {
        await logout();
        return AuthResponseModel(status: false, message: 'সেশনের মেয়াদ শেষ হয়েছে।');
      }
    } catch (e) {
      debugPrint('[AuthRepository.getCurrentUser] Error: $e');
    }
    return null;
  }

  /// 7. Logout (POST /api/v1/auth/logout)
  Future<void> logout() async {
    try {
      await ApiClient.post(AppConstants.v1AuthLogout);
    } catch (e) {
      debugPrint('[AuthRepository.logout] API error: $e');
    } finally {
      await SecureStorageService.clearAuthData();
      await MySharedPref.removeUserToken();
      MyGetStorage.removeCache(MyGetStorage.meUser);
      isLoggedIn.value = false;
      havePackage.value = false;
      myUser = User();
    }
  }

  /// 8. Forget Password (POST /api/v1/auth/forget-password)
  Future<AuthResponseModel> forgetPassword(String phone) async {
    try {
      final response = await ApiClient.post(
        AppConstants.v1AuthForgetPassword,
        data: {'phone': phone},
      );
      if (response.data is Map) {
        return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      }
      return AuthResponseModel(status: false, message: 'পাসওয়ার্ড রিসেট রিকোয়েস্ট ব্যর্থ হয়েছে।');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return AuthResponseModel(status: false, message: 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।');
    }
  }

  /// Helper: Centralized Dio error handling
  AuthResponseModel _handleDioError(DioException e) {
    if (e.response?.data is Map) {
      return AuthResponseModel.fromJson(e.response!.data as Map<String, dynamic>);
    }
    final message = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout
        ? 'সার্ভার রেসপন্স টাইমআউট হয়েছে। ইন্টারনেট সংযোগ চেক করুন।'
        : (e.message ?? 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।');
    return AuthResponseModel(status: false, message: message);
  }

  /// Helper: Save session credentials directly to Encrypted SecureStorage & SharedPrefs
  Future<void> _saveSession(AuthResponseModel authRes) async {
    if (authRes.token != null && authRes.token!.isNotEmpty) {
      await SecureStorageService.saveToken(authRes.token!);
      await MySharedPref.setUserToken(authRes.token!);
    }
    if (authRes.user != null) {
      myUser = authRes.user!;
      MyGetStorage.writeCacheData(MyGetStorage.meUser, myUser);
    }
    isLoggedIn.value = true;
    havePackage.value = authRes.havePackage;
  }
}
