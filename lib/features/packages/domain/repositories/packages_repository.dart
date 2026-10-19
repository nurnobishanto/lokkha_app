import 'package:lokkha/features/packages/data/models/package_detail_response_model.dart';
import 'package:lokkha/features/packages/data/models/premium_package_model.dart';

abstract class PackagesRepository {
  Future<PackageDetailResponseModel?> getPackageDetails(int packageId);

  Future<PremiumPackageModel?> getPremiumPackages({
    int page = 1,
    int perPage = 15,
    String? search,
    bool? isFeatured,
    bool? isTrial,
    String? sortBy,
  });

  Future<Map<String, dynamic>?> claimFreeTrial(int packageId);
}

