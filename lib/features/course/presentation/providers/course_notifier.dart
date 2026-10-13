import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/enums/api_call_status.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
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
// 1. Courses List Notifier
// ---------------------------------------------------------------------------
class CoursesState {
  final ApiCallStatus status;
  final CoursesModel model;

  const CoursesState({
    this.status = ApiCallStatus.holding,
    required this.model,
  });

  CoursesState copyWith({
    ApiCallStatus? status,
    CoursesModel? model,
  }) {
    return CoursesState(
      status: status ?? this.status,
      model: model ?? this.model,
    );
  }
}

class CoursesNotifier extends Notifier<CoursesState> {
  final int? categoryId;
  final RestClient _client;

  CoursesNotifier(this.categoryId, {RestClient? client})
      : _client = client ?? RestClient();

  @override
  CoursesState build() {
    Future.microtask(() => fetchCourses(categoryId));
    return CoursesState(model: CoursesModel());
  }

  Future<void> fetchCourses([int? coursesID]) async {
    state = state.copyWith(status: ApiCallStatus.loading);
    try {
      final id = coursesID ?? categoryId;
      final url = (id != null && id > 0)
          ? '${AppConstants.courses}?course_category_id=$id'
          : AppConstants.courses;

      final response = await _client.get(url);
      if (response.data != null && response.data['status'] == true) {
        state = state.copyWith(
          model: CoursesModel.fromJson(response.data as Map<String, dynamic>),
          status: ApiCallStatus.success,
        );
      } else {
        state = state.copyWith(status: ApiCallStatus.error);
      }
    } catch (e) {
      state = state.copyWith(status: ApiCallStatus.error);
      debugPrint('exception in fetchCourses $e');
    }
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
  final ApiCallStatus status;
  final CourseDetailsModel model;
  final bool isLoading;
  final bool showFullDetails;

  const CourseDetailsState({
    this.status = ApiCallStatus.holding,
    required this.model,
    this.isLoading = true,
    this.showFullDetails = false,
  });

  CourseDetailsState copyWith({
    ApiCallStatus? status,
    CourseDetailsModel? model,
    bool? isLoading,
    bool? showFullDetails,
  }) {
    return CourseDetailsState(
      status: status ?? this.status,
      model: model ?? this.model,
      isLoading: isLoading ?? this.isLoading,
      showFullDetails: showFullDetails ?? this.showFullDetails,
    );
  }
}

class CourseDetailsNotifier extends Notifier<CourseDetailsState> {
  final int courseId;
  final RestClient _client;

  CourseDetailsNotifier(this.courseId, {RestClient? client})
      : _client = client ?? RestClient();

  @override
  CourseDetailsState build() {
    Future.microtask(() => fetchCourseDetails(courseId));
    return CourseDetailsState(model: CourseDetailsModel());
  }

  void toggleDetails() {
    state = state.copyWith(showFullDetails: !state.showFullDetails);
  }

  Future<void> fetchCourseDetails(int id) async {
    state = state.copyWith(
      status: ApiCallStatus.loading,
      isLoading: true,
    );
    final token = MySharedPref.getUserToken();
    final headers = {
      'Authorization': 'Bearer $token',
    };
    final url = '${AppConstants.courseDetails}/$id';

    try {
      final response = await _client.get(url, headers: headers);
      if (response.data != null && response.data['status'] == true) {
        state = state.copyWith(
          status: ApiCallStatus.success,
          isLoading: false,
          model: CourseDetailsModel.fromJson(response.data),
        );
      } else {
        state = state.copyWith(
          status: ApiCallStatus.error,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: ApiCallStatus.error,
        isLoading: false,
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
  final ApiCallStatus status;
  final MyCourseModel model;

  const MyCoursesState({
    this.status = ApiCallStatus.holding,
    required this.model,
  });

  MyCoursesState copyWith({
    ApiCallStatus? status,
    MyCourseModel? model,
  }) {
    return MyCoursesState(
      status: status ?? this.status,
      model: model ?? this.model,
    );
  }
}

class MyCoursesNotifier extends Notifier<MyCoursesState> {
  final RestClient _client;

  MyCoursesNotifier({RestClient? client}) : _client = client ?? RestClient();

  @override
  MyCoursesState build() {
    Future.microtask(fetchMyCourses);
    return MyCoursesState(model: MyCourseModel());
  }

  Future<void> fetchMyCourses() async {
    state = state.copyWith(status: ApiCallStatus.loading);
    final token = MySharedPref.getUserToken();
    final url = AppConstants.myCourses;

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await _client.post(url, headers: headers);
      if (response.data != null && response.data['status'] == true) {
        state = state.copyWith(
          model: MyCourseModel.fromJson(response.data),
          status: ApiCallStatus.success,
        );
      } else {
        state = state.copyWith(status: ApiCallStatus.error);
        CustomSnackBar.showCustomErrorToast(
          message: response.data?['message']?.toString() ?? 'কোর্স লোড করতে ব্যর্থ',
        );
      }
    } catch (error) {
      state = state.copyWith(status: ApiCallStatus.error);
      debugPrint('MyCourses API Error: $error');
      CustomSnackBar.showCustomErrorToast(
        message: 'সার্ভার সংযোগে সমস্যা হয়েছে',
      );
    }
  }
}

final myCoursesNotifierProvider =
    NotifierProvider<MyCoursesNotifier, MyCoursesState>(
  MyCoursesNotifier.new,
);

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
  final ApiCallStatus couponStatus;
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
    this.couponStatus = ApiCallStatus.holding,
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
    ApiCallStatus? couponStatus,
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
      couponStatus: couponStatus ?? this.couponStatus,
      appliedCouponMessage: appliedCouponMessage ?? this.appliedCouponMessage,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

class CourseCheckoutNotifier extends Notifier<CourseCheckoutState> {
  final RestClient _client;

  CourseCheckoutNotifier({RestClient? client}) : _client = client ?? RestClient();

  @override
  CourseCheckoutState build() {
    return CourseCheckoutState(dataModel: CourseCheckoutModel());
  }

  void setIsChecked(bool value) {
    state = state.copyWith(isChecked: value);
    if (!value) {
      state = state.copyWith(
        couponStatus: ApiCallStatus.holding,
        appliedCouponMessage: '',
        discountAmount: -1,
        totalAmount: -1,
      );
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

  Future<String?> makePayment({
    required int id,
    required String couponCode,
    required String email,
  }) async {
    state = state.copyWith(isLoading: true);
    final token = MySharedPref.getUserToken();
    final orderPlaceUrl = '${AppConstants.courseEnroll}/$id';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final data = {
      'coupon_code': couponCode,
      'email': email,
      'payment_method': state.selectedPaymentMethod,
    };

    String? paymentUrl;
    try {
      final response = await _client.post(
        orderPlaceUrl,
        data: data,
        headers: headers,
      );
      state = state.copyWith(isLoading: false);
      if (response.data != null && response.data['status'] == true) {
        final checkoutModel = CourseCheckoutModel.fromJson(response.data);
        state = state.copyWith(dataModel: checkoutModel);
        paymentUrl = checkoutModel.paymentUrl?.toString();
      } else {
        CustomSnackBar.showCustomToast(
          title: 'Something Went Wrong!',
          message: response.data?['message']?.toString() ?? '',
        );
      }
    } catch (err) {
      state = state.copyWith(isLoading: false);
      CustomSnackBar.showCustomErrorToast(
        message: 'পেমেন্ট প্রসেসিং ব্যর্থ হয়েছে',
      );
    }
    return paymentUrl;
  }

  Future<void> couponApply(String couponCode, String price) async {
    state = state.copyWith(couponStatus: ApiCallStatus.loading);
    final token = MySharedPref.getUserToken();
    final url = AppConstants.couponApply;
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
          couponStatus: ApiCallStatus.success,
          appliedCouponMessage: message,
          discountAmount: discount,
          totalAmount: total,
        );
        CustomSnackBar.showCustomToast(message: message);
      } else {
        state = state.copyWith(
          couponStatus: ApiCallStatus.error,
          appliedCouponMessage: '',
          discountAmount: -1,
          totalAmount: -1,
        );
        CustomSnackBar.showCustomErrorToast(message: message);
      }
    } catch (error) {
      state = state.copyWith(
        couponStatus: ApiCallStatus.error,
        appliedCouponMessage: '',
        discountAmount: -1,
        totalAmount: -1,
      );
      debugPrint('Coupon API error: $error');
      CustomSnackBar.showCustomErrorToast(message: 'সার্ভারে সমস্যা হয়েছে');
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
  final ApiCallStatus status;
  final List<Category> categories;
  final bool isLoading;
  final bool isLastPage;
  final int currentPage;

  const LectureSheetListState({
    this.status = ApiCallStatus.holding,
    this.categories = const [],
    this.isLoading = false,
    this.isLastPage = false,
    this.currentPage = 1,
  });

  LectureSheetListState copyWith({
    ApiCallStatus? status,
    List<Category>? categories,
    bool? isLoading,
    bool? isLastPage,
    int? currentPage,
  }) {
    return LectureSheetListState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
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
      status: state.categories.isEmpty ? ApiCallStatus.loading : state.status,
    );

    final url = '${AppConstants.lectureSheetCategories}?page=${state.currentPage}';
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
          status: ApiCallStatus.success,
          isLoading: false,
        );
      } else {
        state = state.copyWith(status: ApiCallStatus.error, isLoading: false);
      }
    } catch (error) {
      state = state.copyWith(status: ApiCallStatus.error, isLoading: false);
      debugPrint('Pagination Error: $error');
    }
  }
}

final lectureSheetListNotifierProvider =
    NotifierProvider<LectureSheetListNotifier, LectureSheetListState>(
  LectureSheetListNotifier.new,
);

class SheetDetailsState {
  final ApiCallStatus status;
  final LectureSheetDetailsModel? model;

  const SheetDetailsState({
    this.status = ApiCallStatus.holding,
    this.model,
  });

  SheetDetailsState copyWith({
    ApiCallStatus? status,
    LectureSheetDetailsModel? model,
  }) {
    return SheetDetailsState(
      status: status ?? this.status,
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
    state = state.copyWith(status: ApiCallStatus.loading);
    final url = '${AppConstants.lectureSheet}/$id';
    try {
      final response = await _client.get(url);
      final data = response.data;
      if (data != null && data['status'] == true) {
        state = state.copyWith(
          model: LectureSheetDetailsModel.fromJson(data),
          status: ApiCallStatus.success,
        );
      } else {
        state = state.copyWith(status: ApiCallStatus.error);
      }
    } catch (error) {
      state = state.copyWith(status: ApiCallStatus.error);
      debugPrint('Error: $error');
    }
  }
}

final sheetDetailsNotifierProvider =
    NotifierProvider.family<SheetDetailsNotifier, SheetDetailsState, int>(
  SheetDetailsNotifier.new,
);

class LectureSheetListDetailsState {
  final ApiCallStatus status;
  final LectureSheetCategory? detailsModel;
  final List<Category> lectureSheets;
  final bool isLoading;
  final bool isLastPage;
  final int currentPage;

  const LectureSheetListDetailsState({
    this.status = ApiCallStatus.holding,
    this.detailsModel,
    this.lectureSheets = const [],
    this.isLoading = false,
    this.isLastPage = false,
    this.currentPage = 1,
  });

  LectureSheetListDetailsState copyWith({
    ApiCallStatus? status,
    LectureSheetCategory? detailsModel,
    List<Category>? lectureSheets,
    bool? isLoading,
    bool? isLastPage,
    int? currentPage,
  }) {
    return LectureSheetListDetailsState(
      status: status ?? this.status,
      detailsModel: detailsModel ?? this.detailsModel,
      lectureSheets: lectureSheets ?? this.lectureSheets,
      isLoading: isLoading ?? this.isLoading,
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
      status: state.lectureSheets.isEmpty ? ApiCallStatus.loading : state.status,
    );
    final url =
        '${AppConstants.lectureSheetCategories}/$id?page=${state.currentPage}';

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
          status: ApiCallStatus.success,
          isLoading: false,
        );
      } else {
        state = state.copyWith(status: ApiCallStatus.error, isLoading: false);
      }
    } catch (error) {
      state = state.copyWith(status: ApiCallStatus.error, isLoading: false);
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
  final ApiCallStatus status;
  final bool isLoading;
  final CourseLearningModel? model;
  final String? videoId;
  final String? errorMessage;
  final int? currentCourseId;
  final int? currentItemId;

  const CourseLearnState({
    this.status = ApiCallStatus.holding,
    this.isLoading = true,
    this.model,
    this.videoId,
    this.errorMessage,
    this.currentCourseId,
    this.currentItemId,
  });

  CourseLearnState copyWith({
    ApiCallStatus? status,
    bool? isLoading,
    CourseLearningModel? model,
    String? videoId,
    String? errorMessage,
    int? currentCourseId,
    int? currentItemId,
  }) {
    return CourseLearnState(
      status: status ?? this.status,
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
        status: ApiCallStatus.error,
        errorMessage: 'Unauthenticated',
      );
      if (onError != null) onError('Unauthenticated');
      return;
    }

    try {
      String fetchUrl = "${AppConstants.courseLearn}/$cId";
      if (itemID != null) {
        fetchUrl = "${AppConstants.courseLearn}/$cId?item=$itemID";
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
          status: ApiCallStatus.success,
        );
        if (onVideoReady != null) {
          onVideoReady(extractedId);
        }
      } else {
        final msg = response.data?['message']?.toString() ?? 'Something went wrong';
        state = state.copyWith(
          isLoading: false,
          status: ApiCallStatus.error,
          errorMessage: msg,
        );
        if (onError != null) onError(msg);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: ApiCallStatus.error,
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

