import 'package:lokkha/features/packages/data/datasources/packages_remote_data_source.dart';
import 'package:lokkha/features/packages/data/models/package_detail_response_model.dart';
import 'package:lokkha/features/packages/data/models/premium_package_model.dart';
import 'package:lokkha/features/packages/domain/repositories/packages_repository.dart';

class PackagesRepositoryImpl implements PackagesRepository {
  final PackagesRemoteDataSource remoteDataSource;

  PackagesRepositoryImpl({PackagesRemoteDataSource? remoteDataSource})
      : remoteDataSource =
            remoteDataSource ?? PackagesRemoteDataSourceImpl();

  @override
  Future<PackageDetailResponseModel?> getPackageDetails(int packageId) {
    return remoteDataSource.getPackageDetails(packageId);
  }

  @override
  Future<PremiumPackageModel?> getPremiumPackages({
    int page = 1,
    int perPage = 15,
    String? search,
    bool? isFeatured,
    bool? isTrial,
    String? sortBy,
  }) {
    return remoteDataSource.getPremiumPackages(
      page: page,
      perPage: perPage,
      search: search,
      isFeatured: isFeatured,
      isTrial: isTrial,
      sortBy: sortBy,
    );
  }

  @override
  Future<Map<String, dynamic>?> claimFreeTrial(int packageId) {
    return remoteDataSource.claimFreeTrial(packageId);
  }
}

