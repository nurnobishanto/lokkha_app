import 'package:lokkha/features/auth/auth.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<AuthResponseModel> call({
    required String phone,
    String? password,
    String? otp,
    String? deviceName,
  }) {
    return repository.login(
      phone: phone,
      password: password,
      otp: otp,
      deviceName: deviceName,
    );
  }
}
