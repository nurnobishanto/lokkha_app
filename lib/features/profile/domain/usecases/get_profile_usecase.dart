import 'package:lokkha/shared/models/user.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase({required this.repository});

  Future<User?> call() {
    return repository.getProfile();
  }
}
