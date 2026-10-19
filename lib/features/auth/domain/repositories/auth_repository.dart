import '../../data/models/auth_response_model.dart';

abstract class AuthRepository {

  Future<AuthResponseModel> checkPhone(String phone);
  Future<AuthResponseModel> sendOtp(String phone, {String type = 'Login'});
  Future<AuthResponseModel> verifyOtp({
    required String phone,
    required String otp,
  });
  Future<AuthResponseModel> login({
    required String phone,
    String? type,
    String? password,
    String? otp,
    String? deviceName,
    String? platform,
  });
  Future<AuthResponseModel> register({
    required String phone,
    required String otp,
    String? referralCode,
    String? deviceName,
  });
  Future<AuthResponseModel> forgotPassword(String phone);
  Future<AuthResponseModel> resetPassword({
    required String phone,
    required String otp,
    required String password,
    String? passwordConfirmation,
    String? deviceName,
    String? platform,
  });
  Future<AuthResponseModel> forgetPassword({
    required String phone,
    required String otp,
    required String password,
    String? passwordConfirmation,
  });
  Future<AuthResponseModel?> getCurrentUser();
  Future<bool> logout();
}
