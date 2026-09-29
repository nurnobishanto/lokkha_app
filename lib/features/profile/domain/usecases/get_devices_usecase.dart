import '../../data/models/device_session_model.dart';
import '../repositories/profile_repository.dart';

class GetDevicesUseCase {
  final ProfileRepository repository;

  GetDevicesUseCase({required this.repository});

  Future<UserDevicesData?> call() {
    return repository.getDevices();
  }
}
