import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/core/services/app_update_service.dart';
import 'package:lokkha/features/contest/contest.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/features/home/data/models/dashboard_overview_model.dart';
import 'package:lokkha/features/home/data/models/slider_model.dart';
import 'package:lokkha/features/home/data/models/subject_sections_model.dart';
import 'package:lokkha/features/home/data/repositories/dashboard_repository.dart';

class HomeState {
  final bool isSliderLoading;
  final bool isSliderError;
  final SliderModel sliderModel;
  final bool isSubjectSectionLoading;
  final bool isSubjectSectionError;
  final SubjectSectionModel subjectSectionModel;
  final DashboardOverviewModel? dashboardOverview;
  final bool isOverviewLoading;
  final int dotsCount;

  HomeState({
    this.isSliderLoading = false,
    this.isSliderError = false,
    SliderModel? sliderModel,
    this.isSubjectSectionLoading = false,
    this.isSubjectSectionError = false,
    SubjectSectionModel? subjectSectionModel,
    this.dashboardOverview,
    this.isOverviewLoading = false,
    this.dotsCount = 0,
  })  : sliderModel = sliderModel ?? SliderModel(),
        subjectSectionModel = subjectSectionModel ?? SubjectSectionModel();

  HomeState copyWith({
    bool? isSliderLoading,
    bool? isSliderError,
    SliderModel? sliderModel,
    bool? isSubjectSectionLoading,
    bool? isSubjectSectionError,
    SubjectSectionModel? subjectSectionModel,
    DashboardOverviewModel? Function()? dashboardOverview,
    bool? isOverviewLoading,
    int? dotsCount,
  }) {
    return HomeState(
      isSliderLoading: isSliderLoading ?? this.isSliderLoading,
      isSliderError: isSliderError ?? this.isSliderError,
      sliderModel: sliderModel ?? this.sliderModel,
      isSubjectSectionLoading: isSubjectSectionLoading ?? this.isSubjectSectionLoading,
      isSubjectSectionError: isSubjectSectionError ?? this.isSubjectSectionError,
      subjectSectionModel: subjectSectionModel ?? this.subjectSectionModel,
      dashboardOverview: dashboardOverview != null ? dashboardOverview() : this.dashboardOverview,
      isOverviewLoading: isOverviewLoading ?? this.isOverviewLoading,
      dotsCount: dotsCount ?? this.dotsCount,
    );
  }
}

class HomeNotifier extends Notifier<HomeState> {
  final DashboardRepository _dashboardRepository = DashboardRepository();
  final RestClient _client = RestClient();

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
    state = state.copyWith(isSliderLoading: true, isSliderError: false);
    try {
      final response = await _client.get(Endpoints.sliders);
      if (response.data != null && response.data['status'] == true) {
        final model = SliderModel.fromJson(response.data as Map<String, dynamic>);
        state = state.copyWith(
          sliderModel: model,
          isSliderLoading: false,
          isSliderError: false,
        );
      } else {
        state = state.copyWith(isSliderLoading: false, isSliderError: true);
      }
    } catch (e) {
      state = state.copyWith(isSliderLoading: false, isSliderError: true);
    }
  }

  Future<void> fetchSubjectSections() async {
    state = state.copyWith(isSubjectSectionLoading: true, isSubjectSectionError: false);
    try {
      final response = await _client.get(Endpoints.subjectSections);
      if (response.data != null && response.data['status'] == true) {
        final model = SubjectSectionModel.fromJson(response.data as Map<String, dynamic>);
        state = state.copyWith(
          subjectSectionModel: model,
          isSubjectSectionLoading: false,
          isSubjectSectionError: false,
        );
      } else {
        state = state.copyWith(isSubjectSectionLoading: false, isSubjectSectionError: true);
      }
    } catch (e) {
      state = state.copyWith(isSubjectSectionLoading: false, isSubjectSectionError: true);
    }
  }

  Future<void> refreshHomeViewData() async {
    await fetchInitialData();
    await AppUpdateService().fetchAppInfoAndCheckVersion();
    AppUpdateService().showInAppAnnouncementIfAvailable(force: true);
  }
}

final homeNotifierProvider = NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);
