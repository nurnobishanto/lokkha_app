import '../../data/models/app_info_model.dart';

abstract class AppSystemRepository {
  Future<AppInfoModel> getAppInfo({String? platform, dynamic versionCode});
  Future<ClientVersionCheckModel> checkUpdate({
    required String platform,
    required dynamic versionCode,
  });
}
