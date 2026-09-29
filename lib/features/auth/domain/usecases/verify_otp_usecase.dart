import 'package:lokkha/features/auth/auth.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;
  VerifyOtpUseCase(this.repository);

  Future<AuthResponseModel> call({required String phone, required String otp}) {
    return repository.verifyOtp(phone: phone, otp: otp);
  }
}
