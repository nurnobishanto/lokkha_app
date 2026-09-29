import 'package:flutter/foundation.dart';
import 'package:lokkha/shared/models/user.dart';
import 'package:lokkha/core/services/storage/my_get_storage.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/core/services/storage/secure_storage_service.dart';
import 'package:lokkha/core/utils/global.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import 'package:lokkha/features/auth/auth.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthResponseModel> checkPhone(String phone) {
    return remoteDataSource.checkPhone(phone);
  }

  @override
  Future<AuthResponseModel> sendOtp(String phone, {String type = 'Login'}) {
    return remoteDataSource.sendOtp(phone, type: type);
  }

  @override
  Future<AuthResponseModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final res = await remoteDataSource.verifyOtp(phone: phone, otp: otp);
    if (res.status && res.token != null) {
      await _saveSession(res);
    }
    return res;
  }

  @override
  Future<AuthResponseModel> login({
    required String phone,
    String? password,
    String? otp,
    String? deviceName,
  }) async {
    final res = await remoteDataSource.login(
      phone: phone,
      password: password,
      otp: otp,
      deviceName: deviceName,
    );
    if (res.status && res.token != null) {
      await _saveSession(res);
    }
    return res;
  }

  @override
  Future<AuthResponseModel> register({
    required String phone,
    required String otp,
    String? referralCode,
    String? deviceName,
  }) async {
    final res = await remoteDataSource.register(
      phone: phone,
      otp: otp,
      referralCode: referralCode,
      deviceName: deviceName,
    );
    if (res.status && res.token != null) {
      await _saveSession(res);
    }
    return res;
  }

  @override
  Future<AuthResponseModel?> getCurrentUser() async {
    final token = await SecureStorageService.getToken();
    if (token == null || token.isEmpty) {
      isLoggedIn.value = false;
      return null;
    }

    try {
      final authRes = await remoteDataSource.getCurrentUser();
      if (authRes != null && authRes.status) {
        await _saveSession(authRes);
        return authRes;
      }
    } catch (e) {
      debugPrint('[AuthRepository.getCurrentUser] Error: $e');
    }
    return null;
  }

  @override
  Future<bool> logout() async {
    try {
      await SecureStorageService.clearAuthData();
      await MySharedPref.removeUserToken();
      MyGetStorage.removeCache(MyGetStorage.meUser);
      isLoggedIn.value = false;
      havePackage.value = false;
      myUser = User();
      return true;
    } catch (e) {
      debugPrint('[AuthRepository.logout] Error: $e');
      return false;
    }
  }

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
