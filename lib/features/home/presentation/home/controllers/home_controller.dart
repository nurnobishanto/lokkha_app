import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/notifications/notifications.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/features/contest/contest.dart';
import 'package:lokkha/features/study_material/study_material.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/features/jobs/jobs.dart';
import 'package:lokkha/features/mock_test/mock_test.dart';
import 'package:lokkha/features/home/home.dart';
import '../services/home_api_service.dart';

class HomeController extends GetxController {
  int dotsCount = 0;

  final List<String> gridViewTitle = [
    'বিষয়ভিত্তিক পরীক্ষা',
    'কারেন্ট এ্যাফেয়ার্স',
    'সর্বশেষ নিয়োগ বিজ্ঞপ্তি',
    'সর্বশেষ নিয়োগ পরীক্ষা',
    'Vocabulary',
    'পরীক্ষা সমূহ',
  ];

  final List<Widget> gridViewRoutePage = [
    const MockTestTabView(),
    const CurrentAffairsView(),
    const JobsView(),
    const LatestExamView(),
    const VocabularyView(),
    const ExamCategoryView(),
  ];

  final HomeApiService homeApiService = HomeApiService();
  final DashboardRepository dashboardRepository = DashboardRepository();

  // V1 Dashboard Overview State
  final Rx<DashboardOverviewModel?> dashboardOverview = Rx<DashboardOverviewModel?>(null);
  final RxBool isOverviewLoading = false.obs;

  // Reactive API statuses & models (backward compatibility)
  Rx<ApiCallStatus> get sliderApiStatus => homeApiService.sliderApiStatus;
  Rx<ApiCallStatus> get subjectSectionApiStatus =>
      homeApiService.subjectSectionApiStatus;

  Rx<SliderModel> get sliderModel => homeApiService.sliderModel;
  Rx<SubjectSectionModel> get subjectSectionModel =>
      homeApiService.subjectSectionModel;

  LatestContestController? _contestController;
  ExamCategoryController? _examController;

  LatestContestController get contestController {
    if (_contestController != null) return _contestController!;
    _contestController = Get.isRegistered<LatestContestController>()
        ? Get.find<LatestContestController>()
        : Get.put(LatestContestController());
    return _contestController!;
  }

  ExamCategoryController get examController {
    if (_examController != null) return _examController!;
    _examController = Get.isRegistered<ExamCategoryController>()
        ? Get.find<ExamCategoryController>()
        : Get.put(ExamCategoryController());
    return _examController!;
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint("HomeController Initialized with V1 Dashboard Repository");

    if (!Get.isRegistered<NotificationsController>() && Get.isRegistered<GetNotificationsUseCase>()) {
      Get.put(NotificationsController());
    }

    // Initial 1-call API fetch
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    isOverviewLoading.value = true;
    try {
      // 1. Fetch single-call V1 Dashboard Overview
      final overview = await dashboardRepository.getOverview();
      if (overview != null && overview.status) {
        dashboardOverview.value = overview;
      }

      // 2. Fetch background sections in parallel
      await Future.wait([
        homeApiService.fetchSliders(),
        homeApiService.fetchSubjectSection(),
        contestController.fetchContest(),
        contestController.fetchContestResult(),
        contestController.fetchAllContest(),
        examController.fetchCourseCategories(),
      ]);
      debugPrint("Initial Home data fetched successfully");
    } catch (e) {
      debugPrint("Error fetching initial Home data: $e");
    } finally {
      isOverviewLoading.value = false;
    }
  }

  Future<void> refreshHomeViewData() async {
    try {
      await _fetchInitialData();
    } catch (e) {
      debugPrint("Error refreshing Home data: $e");
    }
  }

  @override
  void onClose() {
    debugPrint("HomeController disposed");
    super.onClose();
  }
}
