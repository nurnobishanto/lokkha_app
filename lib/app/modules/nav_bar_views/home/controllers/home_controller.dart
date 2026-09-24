import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/modules/notifications/controllers/notifications_controller.dart';
import '../../../../services/api_call_status.dart';
import '../../../contest/controller/latest_contest_controller.dart';
import '../../../current_affairs/views/current_affairs_view.dart';
import '../../../exam_category/controllers/exam_category_controller.dart';
import '../../../exam_category/views/exam_category_view.dart';
import '../../../grid_views/jobs/views/jobs_view.dart';
import '../../../grid_views/mock_test_tab/views/mock_test_tab_view.dart';
import '../../../latest_exam/views/latest_exam_view.dart';
import '../../../vocabulary/views/vocabulary_view.dart';
import 'package:lokkha/app/data/models/dashboard_overview_model.dart';
import 'package:lokkha/app/data/repositories/dashboard_repository.dart';
import '../models/slider_model.dart';
import '../models/subject_sections_model.dart';
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

  late final LatestContestController contestController;
  late final ExamCategoryController examController;

  @override
  void onInit() {
    super.onInit();
    debugPrint("HomeController Initialized with V1 Dashboard Repository");

    // Controllers injected on demand
    contestController = Get.isRegistered<LatestContestController>()
        ? Get.find<LatestContestController>()
        : Get.put(LatestContestController());
    examController = Get.isRegistered<ExamCategoryController>()
        ? Get.find<ExamCategoryController>()
        : Get.put(ExamCategoryController());

    if (!Get.isRegistered<NotificationsController>()) {
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
