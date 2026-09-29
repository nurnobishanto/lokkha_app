import '../repositories/profile_repository.dart';

class LogoutOtherDevicesUseCase {
  final ProfileRepository repository;

  LogoutOtherDevicesUseCase({required this.repository});

  Future<Map<String, dynamic>> call() {
    return repository.logoutOtherDevices();
  }
}
