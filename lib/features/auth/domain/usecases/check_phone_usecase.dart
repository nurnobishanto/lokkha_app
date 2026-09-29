import 'package:lokkha/features/auth/auth.dart';
import '../repositories/auth_repository.dart';

class CheckPhoneUseCase {
  final AuthRepository repository;
  CheckPhoneUseCase(this.repository);

  Future<AuthResponseModel> call(String phone) {
    return repository.checkPhone(phone);
  }
}
