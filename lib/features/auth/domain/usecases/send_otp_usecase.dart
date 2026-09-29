import 'package:lokkha/features/auth/auth.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;
  SendOtpUseCase(this.repository);

  Future<AuthResponseModel> call(String phone, {String type = 'Login'}) {
    return repository.sendOtp(phone, type: type);
  }
}
