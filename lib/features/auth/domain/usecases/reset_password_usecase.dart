import '../../data/models/auth_response_model.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;
  ResetPasswordUseCase(this.repository);

  Future<AuthResponseModel> call({
    required String phone,
    required String otp,
    required String password,
    String? passwordConfirmation,
    String? deviceName,
    String? platform,
  }) {
    return repository.resetPassword(
      phone: phone,
      otp: otp,
      password: password,
      passwordConfirmation: passwordConfirmation,
      deviceName: deviceName,
      platform: platform,
    );
  }
}
