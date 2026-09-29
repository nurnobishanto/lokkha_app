import '../repositories/profile_repository.dart';

class TerminateDeviceUseCase {
  final ProfileRepository repository;

  TerminateDeviceUseCase({required this.repository});

  Future<Map<String, dynamic>> call(int deviceId) {
    return repository.terminateDevice(deviceId);
  }
}
