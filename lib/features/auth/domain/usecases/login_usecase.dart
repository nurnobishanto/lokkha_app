import '../../data/models/auth_response_model.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<AuthResponseModel> call({
    required String phone,
    String? type,
    String? password,
    String? otp,
    String? deviceName,
    String? platform,
  }) {
    return repository.login(
      phone: phone,
      type: type,
      password: password,
      otp: otp,
      deviceName: deviceName,
      platform: platform,
    );
  }
}
