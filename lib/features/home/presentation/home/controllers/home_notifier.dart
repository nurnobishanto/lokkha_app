import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/enums/api_call_status.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/core/services/app_update_service.dart';
import 'package:lokkha/features/contest/contest.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/features/home/data/models/dashboard_overview_model.dart';
import 'package:lokkha/features/home/data/models/slider_model.dart';
import 'package:lokkha/features/home/data/models/subject_sections_model.dart';
import 'package:lokkha/features/home/data/repositories/dashboard_repository.dart';
import 'package:lokkha/features/notifications/notifications.dart';

class HomeState {
  final ApiCallStatus sliderStatus;
  final SliderModel sliderModel;
  final ApiCallStatus subjectSectionStatus;
  final SubjectSectionModel subjectSectionModel;
  final DashboardOverviewModel? dashboardOverview;
  final bool isOverviewLoading;
  final int dotsCount;

  HomeState({
    this.sliderStatus = ApiCallStatus.holding,
    SliderModel? sliderModel,
    this.subjectSectionStatus = ApiCallStatus.holding,
    SubjectSectionModel? subjectSectionModel,
    this.dashboardOverview,
    this.isOverviewLoading = false,
    this.dotsCount = 0,
  })  : sliderModel = sliderModel ?? SliderModel(),
        subjectSectionModel = subjectSectionModel ?? SubjectSectionModel();

  HomeState copyWith({
    ApiCallStatus? sliderStatus,
    SliderModel? sliderModel,
    ApiCallStatus? subjectSectionStatus,
    SubjectSectionModel? subjectSectionModel,
    DashboardOverviewModel? Function()? dashboardOverview,
    bool? isOverviewLoading,
    int? dotsCount,
  }) {
    return HomeState(
      sliderStatus: sliderStatus ?? this.sliderStatus,
      sliderModel: sliderModel ?? this.sliderModel,
      subjectSectionStatus: subjectSectionStatus ?? this.subjectSectionStatus,
      subjectSectionModel: subjectSectionModel ?? this.subjectSectionModel,
      dashboardOverview: dashboardOverview != null ? dashboardOverview() : this.dashboardOverview,
      isOverviewLoading: isOverviewLoading ?? this.isOverviewLoading,
      dotsCount: dotsCount ?? this.dotsCount,
    );
  }
}

class HomeNotifier extends Notifier<HomeState> {
  final DashboardRepository _dashboardRepository = DashboardRepository();

  @override
  HomeState build() {
    return HomeState();
  }

  void setDotsCount(int count) {
    state = state.copyWith(dotsCount: count);
  }

  Future<void> fetchInitialData() async {
    state = state.copyWith(isOverviewLoading: true);

    try {
      // 1. Fetch dashboard overview
      final overview = await _dashboardRepository.getOverview();
      if (overview != null && overview.status) {
        state = state.copyWith(
          dashboardOverview: () => overview,
        );
      }

      // 2. Fetch sliders, subject sections, and contest data in parallel
      await Future.wait([
        fetchSliders(),
        fetchSubjectSections(),
        _fetchContestAndExams(),
      ]);
    } catch (e) {
      debugPrint("Error fetching initial Home data (Riverpod): $e");
    } finally {
      state = state.copyWith(isOverviewLoading: false);
    }
  }

  Future<void> _fetchContestAndExams() async {
    try {
      ref.read(latestContestNotifierProvider.notifier).fetchContest();
      ref.read(latestContestNotifierProvider.notifier).fetchContestResult();
      ref.read(latestContestNotifierProvider.notifier).fetchAllContest();
      ref.read(examCategoriesNotifierProvider.notifier).fetchCourseCategories();
      ref.read(examCategoriesNotifierProvider.notifier).fetchExamCategories();
    } catch (e) {
      debugPrint("Error fetching contest & exams: $e");
    }
  }

  Future<void> fetchSliders() async {
    state = state.copyWith(sliderStatus: ApiCallStatus.loading);
    try {
      await BaseClient.safeApiCall(
        AppConstants.sliders,
        RequestType.get,
        onSuccess: (response) {
          if (response.data != null && response.data['status'] == true) {
            final model = SliderModel.fromJson(response.data as Map<String, dynamic>);
            state = state.copyWith(
              sliderModel: model,
              sliderStatus: ApiCallStatus.success,
            );
          } else {
            state = state.copyWith(sliderStatus: ApiCallStatus.error);
          }
        },
        onError: (err) {
          state = state.copyWith(sliderStatus: ApiCallStatus.error);
        },
        onLoading: () {
          state = state.copyWith(sliderStatus: ApiCallStatus.loading);
        },
      );
    } catch (e) {
      state = state.copyWith(sliderStatus: ApiCallStatus.error);
    }
  }

  Future<void> fetchSubjectSections() async {
    state = state.copyWith(subjectSectionStatus: ApiCallStatus.loading);
    try {
      await BaseClient.safeApiCall(
        AppConstants.subjectSections,
        RequestType.get,
        onSuccess: (response) {
          if (response.data != null && response.data['status'] == true) {
            final model = SubjectSectionModel.fromJson(response.data as Map<String, dynamic>);
            state = state.copyWith(
              subjectSectionModel: model,
              subjectSectionStatus: ApiCallStatus.success,
            );
          } else {
            state = state.copyWith(subjectSectionStatus: ApiCallStatus.error);
          }
        },
        onError: (_) {
          state = state.copyWith(subjectSectionStatus: ApiCallStatus.error);
        },
        onLoading: () {
          state = state.copyWith(subjectSectionStatus: ApiCallStatus.loading);
        },
      );
    } catch (e) {
      state = state.copyWith(subjectSectionStatus: ApiCallStatus.error);
    }
  }

  Future<void> refreshHomeViewData() async {
    await fetchInitialData();
    await AppUpdateService().fetchAppInfoAndCheckVersion();
    AppUpdateService().showInAppAnnouncementIfAvailable(force: true);
  }
}

final homeNotifierProvider = NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);
