import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/services/storage/secure_storage_service.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/features/profile/domain/repositories/profile_repository.dart';
import 'package:lokkha/features/profile/domain/usecases/get_dashboard_overview_usecase.dart';

class DashboardPortalState {
  final DashboardOverviewModel? dashboardOverview;
  final bool isLoading;
  final bool hasError;

  const DashboardPortalState({
    this.dashboardOverview,
    this.isLoading = false,
    this.hasError = false,
  });

  DashboardData? get data => dashboardOverview?.data;
  DashboardCounts? get counts => data?.counts;
  DashboardActiveSubscription? get subscription => data?.activeSubscription;
  DashboardPerformance? get performance => data?.performance;
  DashboardReferral? get referral => data?.referral;
  DashboardRewards? get rewards => data?.rewards;

  DashboardPortalState copyWith({
    DashboardOverviewModel? Function()? dashboardOverview,
    bool? isLoading,
    bool? hasError,
  }) {
    return DashboardPortalState(
      dashboardOverview: dashboardOverview != null ? dashboardOverview() : this.dashboardOverview,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }
}

class DashboardPortalNotifier extends Notifier<DashboardPortalState> {
  final GetDashboardOverviewUseCase _overviewUseCase =
      GetDashboardOverviewUseCase(repository: ProfileRepository());

  @override
  DashboardPortalState build() {
    return const DashboardPortalState();
  }

  Future<void> fetchDashboardOverview() async {
    final token = await SecureStorageService.getToken();
    if (token == null || token.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        hasError: false,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      hasError: false,
    );

    try {
      final res = await _overviewUseCase();
      if (res != null && res.data != null) {
        state = state.copyWith(
          dashboardOverview: () => res,
          isLoading: false,
          hasError: false,
        );

        // Sync subscription state
        if (res.data?.activeSubscription != null) {
          final isSubActive = res.data!.activeSubscription!.status == 'active' &&
              res.data!.activeSubscription!.daysLeft > 0;
          havePackage.value = isSubActive;
        }

        // Sync reward points
        if (res.data?.rewards != null && myUser.id != null) {
          myUser = myUser.copyWithRewardPoints(res.data!.rewards!.balance);
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
        );
      }
    } catch (e) {
      debugPrint("Error fetching dashboard overview (Riverpod): $e");
      state = state.copyWith(
        isLoading: false,
        hasError: true,
      );
    }
  }

  Future<void> refreshDashboard() async {
    await fetchDashboardOverview();
  }
}

final dashboardPortalNotifierProvider =
    NotifierProvider<DashboardPortalNotifier, DashboardPortalState>(DashboardPortalNotifier.new);
