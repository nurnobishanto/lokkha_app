import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._(); // Prevent instantiation

  /// Base URLs
  static String get baseUrl {
    try {
      if (dotenv.isInitialized) {
        return dotenv.env['API_BASE_URL'] ?? 'https://lokkha.com';
      }
    } catch (_) {}
    return 'https://lokkha.com';
  }
  static String get appUrl => '$baseUrl/api';
  static String get apiV1BaseUrl => '$baseUrl/api/v1';
  /// Image & File Storage Base URL: https://lokkha.com/uploads
  static String get imageBaseUrl {
    try {
      if (dotenv.isInitialized) {
        final envUrl = dotenv.env['IMAGE_BASE_URL'];
        if (envUrl != null && envUrl.isNotEmpty) {
          return envUrl.endsWith('/') ? envUrl : '$envUrl/';
        }
      }
    } catch (_) {}
    return 'https://lokkha.com/uploads/';
  }

  /// Backward-compatible storage URL
  static String get storageUrl => imageBaseUrl;
  static const String sponsorAds = 'https://bdtaxation.com/api/app-ads';

  /// Safely resolves any relative or absolute image/file URL.
  /// Automatically ensures images from lokkha.com include the /uploads/ storage path.
  static String resolveUrl(String? path) {
    if (path == null) return '';
    final trimmed = path.trim();
    if (trimmed.isEmpty) return '';

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      final uri = Uri.tryParse(trimmed);
      if (uri != null &&
          (uri.host == 'lokkha.com' || uri.host == 'www.lokkha.com')) {
        // If pointing to lokkha.com without /uploads/ and not an API call
        if (!uri.path.startsWith('/uploads/') &&
            !uri.path.startsWith('/api/') &&
            uri.path.isNotEmpty) {
          final cleanPath = uri.path.startsWith('/') ? uri.path : '/${uri.path}';
          return 'https://${uri.host}/uploads$cleanPath';
        }
      }
      return trimmed;
    }

    final base = imageBaseUrl.endsWith('/') ? imageBaseUrl : '$imageBaseUrl/';
    final cleanPath = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    if (cleanPath.startsWith('uploads/')) {
      return '$baseUrl/$cleanPath';
    }
    return '$base$cleanPath';
  }

  /// Alias for resolving image URLs
  static String resolveImageUrl(String? path) => resolveUrl(path);

  /// V1 Auth Endpoints
  static const String v1AuthCheckPhone = '/auth/check-phone';
  static const String v1AuthSendOtp = '/auth/send-otp';
  static const String v1AuthVerifyOtp = '/auth/verify-otp';
  static const String v1AuthLogin = '/auth/login';
  static const String v1AuthRegister = '/auth/register';
  static const String v1AuthMe = '/auth/me';
  static const String v1AuthLogout = '/auth/logout';
  static const String v1AuthForgetPassword = '/auth/forget-password';

  /// V1 Dashboard & Core Modules
  static const String v1DashboardOverview = '/dashboard/overview';
  static const String v1UserProfile = '/profile';
  static const String v1UserProfileUpdate = '/profile/update';
  static const String v1UserChangePassword = '/profile/change-password';

  /// V1 Device Sessions (3-device limit)
  static const String v1UserDevices = '/user/devices';
  static const String v1UserDevicesLogout = '/user/devices/logout-others';
  static const String v1UserDevicesLogoutOthers = '/user/devices/logout-others';

  /// V1 Orders, Exams & Courses
  static const String v1UserOrders = '/user/orders';
  static const String v1UserExams = '/user/exams';
  static const String v1UserCourses = '/user/courses';
  static const String v1UserSelfAcademyHistory = '/user/self-academy-history';
  static const String v1UserExamHistory = '/user/exam-history';

  /// V1 Bookmarks & Saved Questions
  static const String v1ContentHistory = '/user/content-history';
  static const String v1SavedQuestions = '/user/content-history/saved-questions';
  static const String v1Bookmarks = '/user/content-history/saved-questions';
  static const String v1ToggleSaveQuestion = '/user/content-history/toggle-save-question';
  static const String v1BookmarkToggle = '/user/content-history/toggle-save-question';

  /// V1 Analytics, Rewards & Referrals
  static const String v1UserAccuracy = '/user/accuracy';
  static const String v1RewardPoints = '/user/reward-points';
  static const String v1RewardTransactions = '/user/reward-points/transactions';
  static const String v1Referrals = '/user/referrals';

  /// V1 Packages & Subscriptions
  static const String v1Packages = '/packages';
  static const String v1PackagesCouponApply = '/packages/coupon-apply';
  static const String v1UserPackages = '/user/packages';

  /// V1 Public Dynamic Content
  static const String v1Sliders = '/sliders';
  static const String v1Contact = '/contact';
  static const String v1ContactSubmit = '/contact/submit';
  static const String v1About = '/about';
  static const String v1AppInfo = '/app-info';
  static const String v1AppInfoCheckUpdate = '/app-info/check-update';

  /// V1 Current Affairs & GK Hub
  static const String v1CurrentAffairsFeed = '/current-affairs/feed';
  static const String v1CurrentAffairsMonthlyDigest = '/current-affairs/monthly-digest';
  static const String v1CurrentAffairsMonths = '/current-affairs/months';
  static const String v1CurrentAffairsCategories = '/current-affairs/categories';
  static const String v1CurrentAffairsLatest = '/current-affairs/latest';

  /// V1 Blog
  static const String v1Blog = '/blog';
  static const String v1Blogs = '/blog';
  static const String v1BlogCategories = '/blog/categories';
  static const String v1BlogTags = '/blog/tags';
  static const String v1BlogFeatured = '/blog/featured';

  /// V1 Apple Pay
  static const String v1ApplePayConfig = '/apple-pay/config';
  static const String v1ApplePaySession = '/apple-pay/session';
  static const String v1ApplePayVerify = '/apple-pay/verify';
  static const String v1ApplePayCancel = '/apple-pay/cancel';
  static const String v1ApplePayFail = '/apple-pay/fail';

  /// App Updates
  static final String appVersionCheck = '$appUrl/app/update';
  static final String updateProfileInfo = '$appUrl/update-profile-info';

  /// Subjects & Exams
  static final String getSubjects = '$appUrl/get-subjects';
  //static final String testExamStart = '$appUrl/test-exam/start';
  static final String webTestExamStart = '$appUrl/web-test-exam/start';
  //static final String testExamSubmit = '$appUrl/test-exam/submit';
  static final String randomQuestion = '$appUrl/random-question';

  /// Favorites
  // static final String questionFavAdd = '$appUrl/question/favorite/add';
  // static final String questionFavRemove = '$appUrl/question/favorite/remove';
  // static final String questionFavList = '$appUrl/question/favorite/list';
  static final String myQuestions = '$appUrl/my-questions';

  /// Jobs
  static final String jobsList = '$appUrl/jobs';
  static final String job = '$appUrl/job';

  // Current Affairs
  static final String internationalCA = '$appUrl/current-affairs/international';
  static final String nationalCA = '$appUrl/current-affairs/national';

  /// Home
  static final String sliders = '$appUrl/sliders';

  /// Drawer Pages
  static final String privacyPolicy = '$appUrl/page/privacy-policy';
  static final String termsPolicy = '$appUrl/page/terms-and-conditions';
  static final String refundPolicy = '$appUrl/page/refund-policy';
  static final String contestPolicy = '$appUrl/page/contest-policy';
  static final String about = '$appUrl/page/about';

  /// Premium Packages
  static final String premiumPackage = '$appUrl/packages';
  static final String packageOrder = '$appUrl/package/order';
  static final String couponApply = '$appUrl/coupon-apply';

  /// Contests
  static final String latestContest = '$appUrl/latest-contest';
  static final String startContest = '$appUrl/contest/';
  static final String latestContestResult = '$appUrl/latest-contest-result';
  static final String allContestList = '$appUrl/contest-list';

  /// Subject Sections
  static final String subjectSections = '$appUrl/subject-sections';

  /// User Orders & Packages
  static final String myPackages = '$appUrl/my-packages';
  static final String myOrders = '$appUrl/my-orders';
  static final String myOrderDetails = '$appUrl/order-details';

  /// Latest Exams
  static final String latestExam = '$appUrl/latest-exams';
 // static final String tag = '$appUrl/tag';
  static final String vocabularies = '$appUrl/vocabularies';

  /// Model test
  // static final String modelTests = '$appUrl/model-tests';
  // static final String modelTest = '$appUrl/model-test';
  // static final String modelTestCategories = '$appUrl/model-test-categories';
  // static final String exam = '$appUrl/exam';
  static final String webExamRead = '$appUrl/web-exam-read';
  static final String webExamStart = '$appUrl/web-exam-start';

  /// Lecture Sheet
  static final String lectureSheetCategories =
      '$appUrl/lecturesheet-categories';
  static final String lectureSheet = '$appUrl/lecturesheets';

  /// Exams Categories
  static final String examsCategories = '$appUrl/exam-categories';
  static final String examsCategory = '$appUrl/exam-category';
  // static final String startExam = '$appUrl/start-exam';
  // static final String submitExam = '$appUrl/submit-exam';
  static final String examList = '$appUrl/exam-list';

  /// Course Categories
  static final String courseCategories = '$appUrl/course-categories';
  static final String courses = '$appUrl/courses';
  static final String courseDetails = '$appUrl/course';
  static final String courseLearn = '$appUrl/course-learn';
  static final String courseEnroll = '$appUrl/course-enroll';
  ///
  static final String notifications = '$appUrl/notifications';
  static final String myCourses = '$appUrl/my-courses';
}
