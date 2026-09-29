import 'package:lokkha/features/auth/auth.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<AuthResponseModel> call({
    required String phone,
    required String otp,
    String? referralCode,
    String? deviceName,
  }) {
    return repository.register(
      phone: phone,
      otp: otp,
      referralCode: referralCode,
      deviceName: deviceName,
    );
  }
}
