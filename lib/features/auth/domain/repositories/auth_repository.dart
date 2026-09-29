import '../../data/datasources/auth_remote_data_source.dart';
import 'package:lokkha/features/auth/auth.dart';
import '../../data/repositories/auth_repository_impl.dart';

abstract class AuthRepository {
  factory AuthRepository() =>
      AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSourceImpl());

  Future<AuthResponseModel> checkPhone(String phone);
  Future<AuthResponseModel> sendOtp(String phone, {String type = 'Login'});
  Future<AuthResponseModel> verifyOtp({
    required String phone,
    required String otp,
  });
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
  Future<bool> logout();
}
