import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/enums/api_call_status.dart';
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
  final ApiCallStatus examApiCallStatus;
  final AllCourseModel allCourseModel;
  final ApiCallStatus courseApiCallStatus;

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
    this.examApiCallStatus = ApiCallStatus.holding,
    AllCourseModel? allCourseModel,
    this.courseApiCallStatus = ApiCallStatus.holding,
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
    ApiCallStatus? examApiCallStatus,
    AllCourseModel? allCourseModel,
    ApiCallStatus? courseApiCallStatus,
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
      examApiCallStatus: examApiCallStatus ?? this.examApiCallStatus,
      allCourseModel: allCourseModel ?? this.allCourseModel,
      courseApiCallStatus: courseApiCallStatus ?? this.courseApiCallStatus,
    );
  }
}

class SeeAllItemsNotifier extends Notifier<SeeAllItemsState> {
  final GetUserExamsUseCase _getUserExamsUseCase;

  SeeAllItemsNotifier({GetUserExamsUseCase? getUserExamsUseCase})
      : _getUserExamsUseCase = getUserExamsUseCase ?? GetUserExamsUseCase();

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
    state = state.copyWith(examApiCallStatus: ApiCallStatus.loading);

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
        examApiCallStatus: ApiCallStatus.success,
      );
    } catch (e) {
      debugPrint('[SeeAllItemsNotifier] fetchAllExams error: $e');
      state = state.copyWith(examApiCallStatus: ApiCallStatus.error);
    }
  }

  Future<void> fetchAllCourses({int page = 1}) async {
    state = state.copyWith(
      courseApiCallStatus: ApiCallStatus.loading,
      isLoading: true,
    );
    final url = AppConstants.courses;

    await BaseClient.safeApiCall(
      url,
      RequestType.get,
      queryParameters: {'page': page},
      onSuccess: (response) {
        if (response.data["status"] == true) {
          final modelData = AllCourseModel.fromJson(response.data);

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
              courseApiCallStatus: ApiCallStatus.success,
              isLoading: false,
            );
          } else {
            state = state.copyWith(
              allCourseModel: modelData,
              currentCoursePage: page,
              totalCoursePages: modelData.courses?.lastPage ?? 1,
              courseApiCallStatus: ApiCallStatus.success,
              isLoading: false,
            );
          }
        } else {
          state = state.copyWith(
            courseApiCallStatus: ApiCallStatus.error,
            isLoading: false,
          );
        }
      },
      onError: (err) {
        state = state.copyWith(
          courseApiCallStatus: ApiCallStatus.error,
          isLoading: false,
        );
      },
    );
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
