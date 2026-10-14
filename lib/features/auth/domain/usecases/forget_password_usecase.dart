import '../../data/models/auth_response_model.dart';
import '../repositories/auth_repository.dart';

class ForgetPasswordUseCase {
  final AuthRepository repository;
  ForgetPasswordUseCase(this.repository);

  Future<AuthResponseModel> call({
    required String phone,
    required String otp,
    required String password,
    String? passwordConfirmation,
  }) {
    return repository.forgetPassword(
      phone: phone,
      otp: otp,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
