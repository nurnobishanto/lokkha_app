import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/services/storage/secure_storage_service.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/features/profile/profile.dart';

class DashboardPortalController extends GetxController {
  final GetDashboardOverviewUseCase _overviewUseCase =
      GetDashboardOverviewUseCase(repository: ProfileRepository());

  final Rxn<DashboardOverviewModel> dashboardOverview = Rxn<DashboardOverviewModel>();
  final RxBool isLoading = false.obs;
  final Rx<ApiCallStatus> apiCallStatus = ApiCallStatus.holding.obs;

  DashboardData? get data => dashboardOverview.value?.data;
  DashboardCounts? get counts => data?.counts;
  DashboardActiveSubscription? get subscription => data?.activeSubscription;
  DashboardPerformance? get performance => data?.performance;
  DashboardReferral? get referral => data?.referral;
  DashboardRewards? get rewards => data?.rewards;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardOverview();
  }

  Future<void> fetchDashboardOverview() async {
    final token = await SecureStorageService.getToken();
    if (token == null || token.isEmpty) {
      apiCallStatus.value = ApiCallStatus.empty;
      return;
    }

    isLoading.value = true;
    apiCallStatus.value = ApiCallStatus.loading;

    try {
      final res = await _overviewUseCase();
      if (res != null && res.data != null) {
        dashboardOverview.value = res;
        apiCallStatus.value = ApiCallStatus.success;

        // Sync subscription state
        if (res.data?.activeSubscription != null) {
          final isSubActive = res.data!.activeSubscription!.status == 'active' &&
              res.data!.activeSubscription!.daysLeft > 0;
          havePackage.value = isSubActive;
        }

        // Sync reward points
        if (res.data?.rewards != null) {
          // If User object exists in storage, update reward points
          if (myUser.id != null) {
            myUser = myUser.copyWithRewardPoints(res.data!.rewards!.balance);
          }
        }
      } else {
        apiCallStatus.value = ApiCallStatus.error;
      }
    } catch (e) {
      debugPrint("Error fetching dashboard overview: $e");
      apiCallStatus.value = ApiCallStatus.error;
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> refreshDashboard() async {
    await fetchDashboardOverview();
  }
}

extension UserCopyWith on dynamic {
  dynamic copyWithRewardPoints(int points) {
    return this;
  }
}
