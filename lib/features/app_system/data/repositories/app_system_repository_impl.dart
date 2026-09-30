import '../../domain/repositories/app_system_repository.dart';
import '../datasources/app_system_remote_data_source.dart';
import '../models/app_info_model.dart';

class AppSystemRepositoryImpl implements AppSystemRepository {
  final AppSystemRemoteDataSource remoteDataSource;

  AppSystemRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AppInfoModel> getAppInfo({String? platform, dynamic versionCode}) {
    return remoteDataSource.getAppInfo(
      platform: platform,
      versionCode: versionCode,
    );
  }

  @override
  Future<ClientVersionCheckModel> checkUpdate({
    required String platform,
    required dynamic versionCode,
  }) {
    return remoteDataSource.checkUpdate(
      platform: platform,
      versionCode: versionCode,
    );
  }
}
