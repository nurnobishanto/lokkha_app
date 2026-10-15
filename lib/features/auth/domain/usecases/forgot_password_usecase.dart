import '../../data/models/auth_response_model.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;
  ForgotPasswordUseCase(this.repository);

  Future<AuthResponseModel> call(String phone) {
    return repository.forgotPassword(phone);
  }
}
