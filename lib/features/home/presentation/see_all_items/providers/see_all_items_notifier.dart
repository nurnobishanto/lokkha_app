import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/shared/models/courses.dart' hide Link;
import 'package:lokkha/shared/models/exam.dart';

class SeeAllItemsState {
  final String selectedFilter;
  final bool isLoading;
  final int currentExamPage;
  final int totalExamPages;
  final int currentCoursePage;
  final int totalCoursePages;
  final AllExamModel allExamModel;
  final List<Exam> examsList;
  final List<UserExamV1Item> v1ExamsList;
  final UserExamV1Meta? examMeta;
  final bool isExamLoading;
  final bool isExamError;
  final AllCourseModel allCourseModel;
  final bool isCourseLoading;
  final bool isCourseError;

  SeeAllItemsState({
    this.selectedFilter = "all",
    this.isLoading = true,
    this.currentExamPage = 1,
    this.totalExamPages = 1,
    this.currentCoursePage = 1,
    this.totalCoursePages = 1,
    AllExamModel? allExamModel,
    this.examsList = const [],
    this.v1ExamsList = const [],
    this.examMeta,
    this.isExamLoading = false,
    this.isExamError = false,
    AllCourseModel? allCourseModel,
    this.isCourseLoading = false,
    this.isCourseError = false,
  })  : allExamModel = allExamModel ?? AllExamModel(),
        allCourseModel = allCourseModel ?? AllCourseModel();

  SeeAllItemsState copyWith({
    String? selectedFilter,
    bool? isLoading,
    int? currentExamPage,
    int? totalExamPages,
    int? currentCoursePage,
    int? totalCoursePages,
    AllExamModel? allExamModel,
    List<Exam>? examsList,
    List<UserExamV1Item>? v1ExamsList,
    UserExamV1Meta? examMeta,
    bool? isExamLoading,
    bool? isExamError,
    AllCourseModel? allCourseModel,
    bool? isCourseLoading,
    bool? isCourseError,
  }) {
    return SeeAllItemsState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
      currentExamPage: currentExamPage ?? this.currentExamPage,
      totalExamPages: totalExamPages ?? this.totalExamPages,
      currentCoursePage: currentCoursePage ?? this.currentCoursePage,
      totalCoursePages: totalCoursePages ?? this.totalCoursePages,
      allExamModel: allExamModel ?? this.allExamModel,
      examsList: examsList ?? this.examsList,
      v1ExamsList: v1ExamsList ?? this.v1ExamsList,
      examMeta: examMeta ?? this.examMeta,
      isExamLoading: isExamLoading ?? this.isExamLoading,
      isExamError: isExamError ?? this.isExamError,
      allCourseModel: allCourseModel ?? this.allCourseModel,
      isCourseLoading: isCourseLoading ?? this.isCourseLoading,
      isCourseError: isCourseError ?? this.isCourseError,
    );
  }
}

class SeeAllItemsNotifier extends Notifier<SeeAllItemsState> {
  final GetUserExamsUseCase _getUserExamsUseCase;
  final RestClient _client;

  SeeAllItemsNotifier({
    GetUserExamsUseCase? getUserExamsUseCase,
    RestClient? client,
  })  : _getUserExamsUseCase = getUserExamsUseCase ?? GetUserExamsUseCase(),
        _client = client ?? RestClient();

  @override
  SeeAllItemsState build() {
    Future.microtask(() {
      fetchAllExams();
      fetchAllCourses();
    });
    return SeeAllItemsState();
  }

  void setFilter(String filter) {
    final nextFilter =
        (state.selectedFilter == filter && filter != 'all') ? 'all' : filter;
    state = state.copyWith(selectedFilter: nextFilter);
    fetchAllExams(page: 1);
  }

  Future<void> fetchAllExams({int page = 1}) async {
    state = state.copyWith(isExamLoading: true, isExamError: false);

    try {
      final filterParam =
          state.selectedFilter == 'all' ? null : state.selectedFilter;
      final response = await _getUserExamsUseCase(
        page: page,
        perPage: 10,
        filter: filterParam,
      );

      final convertedExams =
          response.items.map((item) => item.toExam()).toList();

      state = state.copyWith(
        v1ExamsList: List.of(response.items),
        examsList: List.of(convertedExams),
        examMeta: response.meta,
        allExamModel: AllExamModel(
          status: response.success,
          exams: Exams(
            currentPage: response.meta.currentPage,
            lastPage: response.meta.lastPage,
            perPage: response.meta.perPage,
            total: response.meta.total,
            data: convertedExams,
          ),
        ),
        currentExamPage: response.meta.currentPage,
        totalExamPages:
            response.meta.lastPage > 0 ? response.meta.lastPage : 1,
        isExamLoading: false,
        isExamError: false,
      );
    } catch (e) {
      debugPrint('[SeeAllItemsNotifier] fetchAllExams error: $e');
      state = state.copyWith(isExamLoading: false, isExamError: true);
    }
  }

  Future<void> fetchAllCourses({int page = 1}) async {
    state = state.copyWith(
      isCourseLoading: true,
      isCourseError: false,
      isLoading: true,
    );

    try {
      final response = await _client.get(
        AppConstants.courses,
        queryParameters: {'page': page},
      );

      if (response.data != null && response.data["status"] == true) {
        final modelData = AllCourseModel.fromJson(response.data as Map<String, dynamic>);

        if (page > 1 && state.allCourseModel.courses?.data != null) {
          final combinedList =
              List.of(state.allCourseModel.courses!.data!)
                ..addAll(modelData.courses?.data ?? []);
          final updatedCourses = Courses(
            currentPage: modelData.courses?.currentPage,
            lastPage: modelData.courses?.lastPage,
            perPage: modelData.courses?.perPage,
            total: modelData.courses?.total,
            data: combinedList,
          );
          state = state.copyWith(
            allCourseModel: AllCourseModel(
              status: modelData.status,
              courses: updatedCourses,
            ),
            currentCoursePage: page,
            totalCoursePages: modelData.courses?.lastPage ?? 1,
            isCourseLoading: false,
            isCourseError: false,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            allCourseModel: modelData,
            currentCoursePage: page,
            totalCoursePages: modelData.courses?.lastPage ?? 1,
            isCourseLoading: false,
            isCourseError: false,
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          isCourseLoading: false,
          isCourseError: true,
          isLoading: false,
        );
      }
    } catch (_) {
      state = state.copyWith(
        isCourseLoading: false,
        isCourseError: true,
        isLoading: false,
      );
    }
  }

  void goToExamPage(int page) => fetchAllExams(page: page);
  void nextExamPage() => fetchAllExams(page: state.currentExamPage + 1);
  void previousExamPage() => fetchAllExams(page: state.currentExamPage - 1);
  void firstExamPage() => fetchAllExams(page: 1);
  void lastExamPage() => fetchAllExams(page: state.totalExamPages);

  void goToCoursePage(int page) => fetchAllCourses(page: page);
  void nextCoursePage() => fetchAllCourses(page: state.currentCoursePage + 1);
  void previousCoursePage() =>
      fetchAllCourses(page: state.currentCoursePage - 1);
  void firstCoursePage() => fetchAllCourses(page: 1);
  void lastCoursePage() => fetchAllCourses(page: state.totalCoursePages);
}

final seeAllItemsNotifierProvider =
    NotifierProvider<SeeAllItemsNotifier, SeeAllItemsState>(
  SeeAllItemsNotifier.new,
);
