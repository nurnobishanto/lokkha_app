import '../../data/models/app_info_model.dart';
import '../repositories/app_system_repository.dart';

class GetAppInfoUseCase {
  final AppSystemRepository repository;

  GetAppInfoUseCase(this.repository);

  Future<AppInfoModel> call({String? platform, dynamic versionCode}) {
    return repository.getAppInfo(platform: platform, versionCode: versionCode);
  }
}
