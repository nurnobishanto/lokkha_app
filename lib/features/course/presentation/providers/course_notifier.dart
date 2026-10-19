import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/course/data/models/v1_course_category_model.dart';
import 'package:lokkha/features/course/data/models/v1_course_model.dart';
import 'package:lokkha/features/course/data/repositories/courses_repository_impl.dart';
import 'package:lokkha/features/course/domain/repositories/courses_repository.dart';
import 'package:lokkha/shared/models/category.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import 'package:lokkha/features/course/data/models/course_checkout_model.dart';
import 'package:lokkha/features/course/data/models/course_details_model.dart';
import 'package:lokkha/features/course/data/models/course_learning_model.dart';
import 'package:lokkha/features/course/data/models/lecture_sheet_category_model.dart';
import 'package:lokkha/features/course/data/models/lecture_sheet_details_model.dart';
import 'package:lokkha/features/course/data/models/lecture_sheet_list_categories_model.dart';
import 'package:lokkha/features/course/data/models/my_course_model.dart';
import 'package:lokkha/features/exam/exam.dart';

// ---------------------------------------------------------------------------
// 1. Courses List Notifier (Clean Architecture & V1 Model Supported)
// ---------------------------------------------------------------------------
class CoursesState {
  final bool isLoading;
  final bool isRefreshing;
  final bool hasError;
  final String? errorMessage;
  final List<V1CourseModel> courses;
  final List<V1CourseCategoryModel> categories;
  final int? selectedCategoryId;
  final String? searchQuery;
  final CoursesModel model;

  const CoursesState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.hasError = false,
    this.errorMessage,
    this.courses = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.searchQuery,
    required this.model,
  });

  CoursesState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? hasError,
    String? errorMessage,
    List<V1CourseModel>? courses,
    List<V1CourseCategoryModel>? categories,
    int? selectedCategoryId,
    String? searchQuery,
    CoursesModel? model,
  }) {
    return CoursesState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      courses: courses ?? this.courses,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      model: model ?? this.model,
    );
  }
}

class CoursesNotifier extends Notifier<CoursesState> {
  final int? categoryId;
  final CoursesRepository? _injectedRepo;
  bool _disposed = false;

  CoursesNotifier(this.categoryId, {CoursesRepository? repository, RestClient? client})
      : _injectedRepo = repository ?? (client != null ? CoursesRepositoryImpl(client: client) : null);

  CoursesRepository get _repository =>
      _injectedRepo ?? ref.read(coursesRepositoryProvider);

  @override
  CoursesState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    Future.microtask(() {
      fetchCategories();
      fetchCourses(categoryId);
    });
    return CoursesState(
      model: CoursesModel(),
      selectedCategoryId: categoryId,
    );
  }

  Future<void> fetchCategories() async {
    if (_disposed) return;
    try {
      final categories = await _repository.getCourseCategories();
      if (_disposed) return;
      if (categories.isNotEmpty) {
        state = state.copyWith(categories: categories);
      }
    } catch (_) {}
  }

  Future<void> fetchCourses(int? id, {bool refresh = false, String? search}) async {
    if (_disposed) return;
    state = state.copyWith(
      isLoading: !refresh && state.courses.isEmpty,
      isRefreshing: refresh,
      hasError: false,
      selectedCategoryId: id,
      searchQuery: search ?? state.searchQuery,
    );

    try {
      final response = await _repository.getCourses(
        categoryId: id,
        search: search ?? state.searchQuery,
      );
      if (_disposed) return;

      if (response.success || response.items.isNotEmpty) {
        state = state.copyWith(
          courses: response.items,
          model: response.toLegacyCoursesModel(),
          isLoading: false,
          isRefreshing: false,
          hasError: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          hasError: true,
          errorMessage: response.message ?? 'কোর্স লোড করা যায়নি',
        );
      }
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        hasError: true,
        errorMessage: 'ইন্টারনেট সংযোগ চেক করুন',
      );
      if (kDebugMode) debugPrint('Error fetching courses: $e');
    }
  }

  void selectCategory(int? id) {
    if (state.selectedCategoryId == id) return;
    fetchCourses(id);
  }

  void searchCourses(String query) {
    fetchCourses(state.selectedCategoryId, search: query);
  }
}

final coursesNotifierProvider =
    NotifierProvider.family<CoursesNotifier, CoursesState, int?>(
  CoursesNotifier.new,
);

// ---------------------------------------------------------------------------
// 2. Course Details Notifier
// ---------------------------------------------------------------------------
class CourseDetailsState {
  final CourseDetailsModel model;
  final bool isLoading;
  final bool hasError;
  final bool showFullDetails;

  const CourseDetailsState({
    required this.model,
    this.isLoading = true,
    this.hasError = false,
    this.showFullDetails = false,
  });

  CourseDetailsState copyWith({
    CourseDetailsModel? model,
    bool? isLoading,
    bool? hasError,
    bool? showFullDetails,
  }) {
    return CourseDetailsState(
      model: model ?? this.model,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      showFullDetails: showFullDetails ?? this.showFullDetails,
    );
  }
}

class CourseDetailsNotifier extends Notifier<CourseDetailsState> {
  final int courseId;
  final CoursesRepository? _injectedRepo;

  CourseDetailsNotifier(this.courseId, {CoursesRepository? repository, RestClient? client})
      : _injectedRepo = repository ?? (client != null ? CoursesRepositoryImpl(client: client) : null);

  CoursesRepository get _repository =>
      _injectedRepo ?? ref.read(coursesRepositoryProvider);

  @override
  CourseDetailsState build() {
    Future.microtask(() {
      fetchCourseDetails(courseId);
      ref.read(myCoursesNotifierProvider.notifier).fetchMyCourses(isRefresh: true);
    });
    return CourseDetailsState(model: CourseDetailsModel());
  }

  void toggleDetails() {
    state = state.copyWith(showFullDetails: !state.showFullDetails);
  }

  Future<void> fetchCourseDetails(int id) async {
    state = state.copyWith(isLoading: true, hasError: false);
    try {
      final model = await _repository.getCourseDetails(id);
      if (model != null && model.course != null) {
        state = state.copyWith(
          isLoading: false,
          hasError: false,
          model: model,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
      );
      if (kDebugMode) debugPrint('Error fetching course Details: $e');
    }
  }
}

final courseDetailsNotifierProvider =
    NotifierProvider.family<CourseDetailsNotifier, CourseDetailsState, int>(
  CourseDetailsNotifier.new,
);

// ---------------------------------------------------------------------------
// 3. My Courses Notifier
// ---------------------------------------------------------------------------
class MyCoursesState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final String? errorMessage;
  final MyCourseModel model;
  final int currentPage;
  final bool hasMore;

  const MyCoursesState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasError = false,
    this.errorMessage,
    required this.model,
    this.currentPage = 1,
    this.hasMore = false,
  });

  MyCoursesState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
    String? errorMessage,
    MyCourseModel? model,
    int? currentPage,
    bool? hasMore,
  }) {
    return MyCoursesState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      model: model ?? this.model,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class MyCoursesNotifier extends Notifier<MyCoursesState> {
  final RestClient _client;
  bool _disposed = false;

  MyCoursesNotifier({RestClient? client}) : _client = client ?? RestClient();

  @override
  MyCoursesState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    Future.microtask(() => fetchMyCourses());
    return MyCoursesState(model: MyCourseModel());
  }

  Future<void> fetchMyCourses({bool isRefresh = false}) async {
    if (!isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasError: false,
        errorMessage: null,
      );
    }

    final token = MySharedPref.getUserToken();
    final url = Endpoints.userCourses;

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await _client.get(
        url,
        queryParameters: {'page': 1},
        headers: headers,
      );

      if (_disposed) return;

      final data = response.data;
      if (data != null && (data['success'] == true || data['status'] == true)) {
        final parsed = MyCourseModel.fromJson(data);
        final enrolledIds = parsed.courses
            .where((c) => !c.isExpired)
            .map((c) => c.courseId)
            .toList();
        cacheEnrolledCourseIds(enrolledIds);
        final meta = parsed.meta;
        final hasMore = meta != null && meta.currentPage < meta.lastPage;

        state = state.copyWith(
          model: parsed,
          isLoading: false,
          hasError: false,
          errorMessage: null,
          currentPage: 1,
          hasMore: hasMore,
        );
      } else {
        final message =
            data?['message']?.toString() ?? 'কোর্স লোড করতে ব্যর্থ';
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: message,
        );
        CustomSnackBar.showCustomErrorToast(message: message);
      }
    } catch (error) {
      if (_disposed) return;
      debugPrint('MyCourses V1 API Error: $error');
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'সার্ভার সংযোগে সমস্যা হয়েছে',
      );
      CustomSnackBar.showCustomErrorToast(
        message: 'সার্ভার সংযোগে সমস্যা হয়েছে',
      );
    }
  }

  Future<void> loadMore() async {
    if (_disposed || state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;
    final token = MySharedPref.getUserToken();
    final url = Endpoints.userCourses;

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await _client.get(
        url,
        queryParameters: {'page': nextPage},
        headers: headers,
      );

      if (_disposed) return;

      final data = response.data;
      if (data != null && (data['success'] == true || data['status'] == true)) {
        final parsed = MyCourseModel.fromJson(data);
        final enrolledIds = parsed.courses
            .where((c) => !c.isExpired)
            .map((c) => c.courseId)
            .toList();
        cacheEnrolledCourseIds(enrolledIds);
        final meta = parsed.meta;
        final hasMore = meta != null && meta.currentPage < meta.lastPage;

        final combinedCourses = [
          ...state.model.courses,
          ...parsed.courses,
        ];

        final updatedModel = MyCourseModel(
          success: true,
          message: parsed.message,
          courses: combinedCourses,
          meta: meta ??
              CoursePaginationMeta(
                currentPage: nextPage,
                lastPage: nextPage,
                total: combinedCourses.length,
              ),
        );

        state = state.copyWith(
          model: updatedModel,
          isLoadingMore: false,
          currentPage: nextPage,
          hasMore: hasMore,
        );
      } else {
        state = state.copyWith(isLoadingMore: false);
      }
    } catch (error) {
      if (_disposed) return;
      debugPrint('MyCourses loadMore error: $error');
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final myCoursesNotifierProvider =
    NotifierProvider<MyCoursesNotifier, MyCoursesState>(MyCoursesNotifier.new);

// ---------------------------------------------------------------------------
// 4. Course Checkout Notifier
// ---------------------------------------------------------------------------
class CourseCheckoutState {
  final bool isChecked;
  final bool isCheckedCondition;
  final bool isLoading;
  final int selectedPayment;
  final String selectedPaymentMethod;
  final CourseCheckoutModel dataModel;
  final bool isCouponLoading;
  final String appliedCouponMessage;
  final int discountAmount;
  final int totalAmount;

  const CourseCheckoutState({
    this.isChecked = false,
    this.isCheckedCondition = false,
    this.isLoading = false,
    this.selectedPayment = 0,
    this.selectedPaymentMethod = 'bkash',
    required this.dataModel,
    this.isCouponLoading = false,
    this.appliedCouponMessage = '',
    this.discountAmount = -1,
    this.totalAmount = -1,
  });

  CourseCheckoutState copyWith({
    bool? isChecked,
    bool? isCheckedCondition,
    bool? isLoading,
    int? selectedPayment,
    String? selectedPaymentMethod,
    CourseCheckoutModel? dataModel,
    bool? isCouponLoading,
    String? appliedCouponMessage,
    int? discountAmount,
    int? totalAmount,
  }) {
    return CourseCheckoutState(
      isChecked: isChecked ?? this.isChecked,
      isCheckedCondition: isCheckedCondition ?? this.isCheckedCondition,
      isLoading: isLoading ?? this.isLoading,
      selectedPayment: selectedPayment ?? this.selectedPayment,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      dataModel: dataModel ?? this.dataModel,
      isCouponLoading: isCouponLoading ?? this.isCouponLoading,
      appliedCouponMessage: appliedCouponMessage ?? this.appliedCouponMessage,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

class CourseCheckoutNotifier extends Notifier<CourseCheckoutState> {
  final RestClient _client;

  CourseCheckoutNotifier({RestClient? client})
      : _client = client ?? RestClient();

  @override
  CourseCheckoutState build() {
    return CourseCheckoutState(dataModel: CourseCheckoutModel());
  }

  void setIsChecked(bool value) {
    state = state.copyWith(isChecked: value);
    if (!value) {
      clearCoupon();
    }
  }

  void setIsCheckedCondition(bool value) {
    state = state.copyWith(isCheckedCondition: value);
  }

  void setSelectedPayment(int index) {
    String method = 'bkash';
    switch (index) {
      case 0:
        method = 'bkash';
        break;
      case 1:
        method = 'nagad';
        break;
      case 2:
        method = 'sslcommerz';
        break;
      default:
        method = 'bkash';
        break;
    }
    state = state.copyWith(
      selectedPayment: index,
      selectedPaymentMethod: method,
    );
  }

  void clearCoupon() {
    state = state.copyWith(
      isCouponLoading: false,
      appliedCouponMessage: '',
      discountAmount: -1,
      totalAmount: -1,
    );
  }

  Future<void> couponApply(String couponCode, String price) async {
    state = state.copyWith(isCouponLoading: true);
    final token = MySharedPref.getUserToken();
    final url = Endpoints.couponApply;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final data = {
      'coupon_code': couponCode,
      'price': price,
    };

    try {
      final response = await _client.post(
        url,
        headers: headers,
        data: data,
      );
      final status = response.data['status'];
      final message = response.data['message']?.toString() ?? '';

      if (status == true) {
        final discount = int.tryParse(response.data['discount']?.toString() ?? '') ?? -1;
        final total = int.tryParse(response.data['discount_price']?.toString() ?? '') ?? -1;
        state = state.copyWith(
          isCouponLoading: false,
          appliedCouponMessage: message,
          discountAmount: discount,
          totalAmount: total,
        );
        CustomSnackBar.showCustomToast(message: message);
      } else {
        state = state.copyWith(
          isCouponLoading: false,
          appliedCouponMessage: '',
          discountAmount: -1,
          totalAmount: -1,
        );
        CustomSnackBar.showCustomErrorToast(message: message);
      }
    } catch (error) {
      state = state.copyWith(
        isCouponLoading: false,
        appliedCouponMessage: '',
        discountAmount: -1,
        totalAmount: -1,
      );
      debugPrint('Coupon API error: $error');
      CustomSnackBar.showCustomErrorToast(message: 'সার্ভারে সমস্যা হয়েছে');
    }
  }

  Future<String?> makePayment({
    required int id,
    String? couponCode,
    String? email,
  }) async {
    state = state.copyWith(isLoading: true);
    final token = MySharedPref.getUserToken();
    final orderPlaceUrl = '${Endpoints.courseEnroll}/$id';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final data = {
      'coupon_code': couponCode ?? '',
      'email': email ?? '',
      'payment_method': state.selectedPaymentMethod,
    };

    try {
      final response = await _client.post(
        orderPlaceUrl,
        headers: headers,
        data: data,
      );
      state = state.copyWith(isLoading: false);
      if (response.data != null && response.data['status'] == true) {
        final checkoutModel = CourseCheckoutModel.fromJson(response.data);
        state = state.copyWith(dataModel: checkoutModel);
        return checkoutModel.paymentUrl?.toString();
      } else {
        CustomSnackBar.showCustomToast(
          title: 'Something Went Wrong!',
          message: response.data?['message']?.toString() ?? '',
        );
        return null;
      }
    } catch (error) {
      state = state.copyWith(isLoading: false);
      debugPrint('Payment API error: $error');
      CustomSnackBar.showCustomErrorToast(message: 'সার্ভারে সমস্যা হয়েছে');
      return null;
    }
  }
}

final courseCheckoutNotifierProvider =
    NotifierProvider<CourseCheckoutNotifier, CourseCheckoutState>(
  CourseCheckoutNotifier.new,
);

// ---------------------------------------------------------------------------
// 5. Lecture Sheet Notifiers
// ---------------------------------------------------------------------------
class LectureSheetListState {
  final List<Category> categories;
  final bool isLoading;
  final bool hasError;
  final bool isLastPage;
  final int currentPage;

  const LectureSheetListState({
    this.categories = const [],
    this.isLoading = false,
    this.hasError = false,
    this.isLastPage = false,
    this.currentPage = 1,
  });

  LectureSheetListState copyWith({
    List<Category>? categories,
    bool? isLoading,
    bool? hasError,
    bool? isLastPage,
    int? currentPage,
  }) {
    return LectureSheetListState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      isLastPage: isLastPage ?? this.isLastPage,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class LectureSheetListNotifier extends Notifier<LectureSheetListState> {
  final RestClient _client;

  LectureSheetListNotifier({RestClient? client})
      : _client = client ?? RestClient();

  @override
  LectureSheetListState build() {
    Future.microtask(fetchCategories);
    return const LectureSheetListState();
  }

  Future<void> fetchCategories() async {
    if (state.isLoading || state.isLastPage) return;
    state = state.copyWith(
      isLoading: true,
      hasError: false,
    );

    final url = '${Endpoints.lectureSheetCategories}?page=${state.currentPage}';
    try {
      final response = await _client.get(url);
      if (response.data != null && response.data['status'] == true) {
        final model = LectureSheetListCategoriesModel.fromJson(response.data);
        final newCategories = model.categories?.data ?? [];
        final isLast = model.categories?.currentPage == model.categories?.lastPage;

        state = state.copyWith(
          categories: [...state.categories, ...newCategories],
          currentPage: state.currentPage + (newCategories.isNotEmpty ? 1 : 0),
          isLastPage: newCategories.isEmpty || isLast,
          isLoading: false,
          hasError: false,
        );
      } else {
        state = state.copyWith(isLoading: false, hasError: true);
      }
    } catch (error) {
      state = state.copyWith(isLoading: false, hasError: true);
      debugPrint('Pagination Error: $error');
    }
  }
}

final lectureSheetListNotifierProvider =
    NotifierProvider<LectureSheetListNotifier, LectureSheetListState>(
  LectureSheetListNotifier.new,
);

class SheetDetailsState {
  final bool isLoading;
  final bool hasError;
  final LectureSheetDetailsModel? model;

  const SheetDetailsState({
    this.isLoading = false,
    this.hasError = false,
    this.model,
  });

  SheetDetailsState copyWith({
    bool? isLoading,
    bool? hasError,
    LectureSheetDetailsModel? model,
  }) {
    return SheetDetailsState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      model: model ?? this.model,
    );
  }
}

class SheetDetailsNotifier extends Notifier<SheetDetailsState> {
  final int sheetId;
  final RestClient _client;

  SheetDetailsNotifier(this.sheetId, {RestClient? client})
      : _client = client ?? RestClient();

  @override
  SheetDetailsState build() {
    Future.microtask(() => fetchSheetDetails(sheetId));
    return const SheetDetailsState();
  }

  Future<void> fetchSheetDetails(int id) async {
    state = state.copyWith(isLoading: true, hasError: false);
    final url = '${Endpoints.lectureSheet}/$id';
    try {
      final response = await _client.get(url);
      final data = response.data;
      if (data != null && data['status'] == true) {
        state = state.copyWith(
          model: LectureSheetDetailsModel.fromJson(data),
          isLoading: false,
          hasError: false,
        );
      } else {
        state = state.copyWith(isLoading: false, hasError: true);
      }
    } catch (error) {
      state = state.copyWith(isLoading: false, hasError: true);
      debugPrint('Error: $error');
    }
  }
}

final sheetDetailsNotifierProvider =
    NotifierProvider.family<SheetDetailsNotifier, SheetDetailsState, int>(
  SheetDetailsNotifier.new,
);

class LectureSheetListDetailsState {
  final bool isLoading;
  final bool hasError;
  final LectureSheetCategory? detailsModel;
  final List<Category> lectureSheets;
  final bool isLastPage;
  final int currentPage;

  const LectureSheetListDetailsState({
    this.isLoading = false,
    this.hasError = false,
    this.detailsModel,
    this.lectureSheets = const [],
    this.isLastPage = false,
    this.currentPage = 1,
  });

  LectureSheetListDetailsState copyWith({
    bool? isLoading,
    bool? hasError,
    LectureSheetCategory? detailsModel,
    List<Category>? lectureSheets,
    bool? isLastPage,
    int? currentPage,
  }) {
    return LectureSheetListDetailsState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      detailsModel: detailsModel ?? this.detailsModel,
      lectureSheets: lectureSheets ?? this.lectureSheets,
      isLastPage: isLastPage ?? this.isLastPage,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class LectureSheetListDetailsNotifier
    extends Notifier<LectureSheetListDetailsState> {
  final int categoryId;
  final RestClient _client;

  LectureSheetListDetailsNotifier(this.categoryId, {RestClient? client})
      : _client = client ?? RestClient();

  @override
  LectureSheetListDetailsState build() {
    Future.microtask(() => fetchSheetListCategories(categoryId));
    return const LectureSheetListDetailsState();
  }

  Future<void> fetchSheetListCategories(int id) async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(
      isLoading: true,
      hasError: false,
    );
    final url =
        '${Endpoints.lectureSheetCategories}/$id?page=${state.currentPage}';

    try {
      final response = await _client.get(url);
      final data = response.data;
      if (data != null && data['status'] == true) {
        final model = LectureSheetCategory.fromJson(data);
        final sheets = model.lecturesheets?.data ?? [];
        final isLast = model.lecturesheets?.currentPage == model.lecturesheets?.lastPage;

        state = state.copyWith(
          detailsModel: model,
          lectureSheets: [...state.lectureSheets, ...sheets],
          currentPage: state.currentPage + (sheets.isNotEmpty ? 1 : 0),
          isLastPage: sheets.isEmpty || isLast,
          isLoading: false,
          hasError: false,
        );
      } else {
        state = state.copyWith(isLoading: false, hasError: true);
      }
    } catch (error) {
      state = state.copyWith(isLoading: false, hasError: true);
      debugPrint('Error: $error');
    }
  }
}

final lectureSheetListDetailsNotifierProvider =
    NotifierProvider.family<LectureSheetListDetailsNotifier,
        LectureSheetListDetailsState, int>(
  LectureSheetListDetailsNotifier.new,
);

// ---------------------------------------------------------------------------
// 7. Course Learn Notifier
// ---------------------------------------------------------------------------
class CourseLearnState {
  final bool isLoading;
  final CourseLearningModel? model;
  final String? videoId;
  final String? errorMessage;
  final int? currentCourseId;
  final int? currentItemId;

  const CourseLearnState({
    this.isLoading = true,
    this.model,
    this.videoId,
    this.errorMessage,
    this.currentCourseId,
    this.currentItemId,
  });

  CourseLearnState copyWith({
    bool? isLoading,
    CourseLearningModel? model,
    String? videoId,
    String? errorMessage,
    int? currentCourseId,
    int? currentItemId,
  }) {
    return CourseLearnState(
      isLoading: isLoading ?? this.isLoading,
      model: model ?? this.model,
      videoId: videoId ?? this.videoId,
      errorMessage: errorMessage ?? this.errorMessage,
      currentCourseId: currentCourseId ?? this.currentCourseId,
      currentItemId: currentItemId ?? this.currentItemId,
    );
  }
}

class CourseLearnNotifier extends Notifier<CourseLearnState> {
  final int courseId;
  final RestClient _client;

  CourseLearnNotifier(this.courseId, {RestClient? client})
      : _client = client ?? RestClient();

  @override
  CourseLearnState build() {
    return const CourseLearnState();
  }

  Future<void> fetchCourseItem(
    int cId, {
    int? itemID,
    void Function(String? videoId)? onVideoReady,
    void Function(String message)? onError,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentCourseId: cId,
      currentItemId: itemID,
    );
    final token = MySharedPref.getUserToken();
    if (token.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unauthenticated',
      );
      if (onError != null) onError('Unauthenticated');
      return;
    }

    try {
      String fetchUrl = "${Endpoints.courseLearn}/$cId";
      if (itemID != null) {
        fetchUrl = "${Endpoints.courseLearn}/$cId?item=$itemID";
      }

      final response = await _client.get(
        fetchUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.data != null && response.data["status"] == true) {
        final data = CourseLearningModel.fromJson(response.data);
        final currentVideoUrl = data.data?.currentItem?.youtubeVideo ?? '';
        String? extractedId;
        if (currentVideoUrl.isNotEmpty) {
          final uri = Uri.tryParse(currentVideoUrl);
          if (uri != null) {
            if (uri.host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
              extractedId = uri.pathSegments.first;
            } else if (uri.host.contains('youtube.com')) {
              extractedId = uri.queryParameters['v'];
            }
          }
        }

        state = state.copyWith(
          model: data,
          videoId: extractedId,
          isLoading: false,
        );
        if (onVideoReady != null) {
          onVideoReady(extractedId);
        }
      } else {
        final msg = response.data?['message']?.toString() ?? 'Something went wrong';
        state = state.copyWith(
          isLoading: false,
          errorMessage: msg,
        );
        if (onError != null) onError(msg);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      if (onError != null) onError(e.toString());
    }
  }
}

final courseLearnNotifierProvider =
    NotifierProvider.family<CourseLearnNotifier, CourseLearnState, int>(
  CourseLearnNotifier.new,
);
