import '../../data/models/app_info_model.dart';
import '../repositories/app_system_repository.dart';

class CheckAppUpdateUseCase {
  final AppSystemRepository repository;

  CheckAppUpdateUseCase(this.repository);

  Future<ClientVersionCheckModel> call({
    required String platform,
    required dynamic versionCode,
  }) {
    return repository.checkUpdate(
      platform: platform,
      versionCode: versionCode,
    );
  }
}
