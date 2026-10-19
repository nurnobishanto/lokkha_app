import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central API Endpoints and Base URL configuration following Clean Architecture.
class Endpoints {
  Endpoints._();

  // ─── Base URLs (Configurable via .env) ─────────────────────────────────────
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

  /// Image & File Storage Base URL (default: https://lokkha.com/uploads/)
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

  static String resolveImageUrl(String? path) => resolveUrl(path);

  // ─── Network Settings ───────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const String xApiKey = '';

  // ─── V1 Authentication ─────────────────────────────────────────────────────
  static const String checkPhone = '/api/v1/auth/check-phone';
  static const String sendOtp = '/api/v1/auth/send-otp';
  static const String verifyOtp = '/api/v1/auth/verify-otp';
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String me = '/api/v1/auth/me';
  static const String logout = '/api/v1/auth/logout';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String resetPassword = '/api/v1/auth/reset-password';
  static const String forgetPassword = forgotPassword;

  // ─── Dashboard & Profile ───────────────────────────────────────────────────
  static const String dashboardOverview = '/api/v1/dashboard/overview';
  static const String profile = '/api/v1/profile';
  static const String profileUpdate = '/api/v1/profile/update';
  static const String changePassword = '/api/v1/profile/change-password';
  static const String devices = '/api/v1/user/devices';
  static const String logoutOtherDevices = '/api/v1/user/devices/logout-others';

  // ─── Orders, Exams, History & Analytics ────────────────────────────────────
  static const String userOrders = '/api/v1/user/orders';
  static const String userExams = '/api/v1/user/exams';
  static const String userCourses = '/api/v1/user/courses';
  static const String userSelfAcademyHistory = '/api/v1/user/self-academy-history';
  static String userSelfAcademyDetail(dynamic id) => '$userSelfAcademyHistory/$id';
  static const String userExamHistory = '/api/v1/user/exam-history';
  static const String accuracy = '/api/v1/user/accuracy';
  static const String rewardPoints = '/api/v1/user/reward-points';
  static const String rewardTransactions = '/api/v1/user/reward-points/transactions';
  static const String referrals = '/api/v1/user/referrals';
  static const String savedQuestions = '/api/v1/user/content-history/saved-questions';
  static const String toggleSaveQuestion = '/api/v1/user/content-history/toggle-save-question';

  // ─── Packages & Subscriptions ──────────────────────────────────────────────
  static const String packages = '/api/v1/packages';
  static String packageDetail(dynamic id) => '/api/v1/packages/$id';
  static const String userPackages = '/api/v1/user/packages';
  static const String couponApply = '/api/v1/packages/coupon-apply';
  static const String claimFreeTrial = '/api/v1/packages/claim-trial';
  static const String packagePurchase = '/api/v1/packages/purchase';

  // ─── Module 23: Home Feed & Landing Hub (8 Endpoints) ──────────────────────
  static const String homeFeed = '/api/v1/home';
  static const String homeContests = '/api/v1/home/contests';
  static const String homeQuestionBanks = '/api/v1/home/question-banks';
  static const String questionBankRandom = '/api/v1/question-bank/random';
  static const String v1QuestionBankRandom = questionBankRandom;
  static const String subjectWiseBanks = homeQuestionBanks;
  static const String quickPracticeSubjects = homeQuestionBanks;
  static const String homeJobsExams = '/api/v1/home/jobs-exams';
  static const String homeStats = '/api/v1/home/stats';
  static const String homeVocabulary = '/api/v1/home/vocabulary';
  static const String homeTestimonials = '/api/v1/home/testimonials';
  static const String sliders = '/api/v1/sliders';
  static const String contact = '/api/v1/contact';
  static const String contactSubmit = '/api/v1/contact/submit';
  static const String about = '/api/v1/about';
  static const String appInfo = '/api/v1/app-info';
  static const String checkUpdate = '/api/v1/app-info/check-update';
  static const String currentAffairs = '/api/v1/current-affairs/feed';
  static const String currentAffairsMonthlyDigest = '/api/v1/current-affairs/monthly-digest';
  static const String currentAffairsMonths = '/api/v1/current-affairs/months';
  static const String currentAffairsCategories = '/api/v1/current-affairs/categories';
  static const String currentAffairsLatest = '/api/v1/current-affairs/latest';
  static String currentAffairsDetails(dynamic id) => '/api/v1/current-affairs/$id';
  static String currentAffairsToggleBookmark(dynamic id) => '/api/v1/current-affairs/$id/toggle-bookmark';
  static const String blogs = '/api/v1/blog';
  static const String blog = '/api/v1/blog';

  // ─── Quick Practice / Subject Sections (V1) ────────────────────────────────
  static const String subjectSectionsSubjects = '/api/v1/subject-sections/subjects';
  static String subjectSectionsChildren(dynamic id) =>
      '/api/v1/subject-sections/subjects/$id/children';
  static String subjectSectionsQuestions(dynamic id) =>
      '/api/v1/subject-sections/subjects/$id/questions';
  static const String v1SubjectSectionsSubjects = subjectSectionsSubjects;
  static String v1SubjectSectionsChildren(dynamic id) =>
      subjectSectionsChildren(id);
  static String v1SubjectSectionsQuestions(dynamic id) =>
      subjectSectionsQuestions(id);

  // ─── Aliases for compatibility ────────────────────────────────────────────
  static const String v1AuthCheckPhone = checkPhone;
  static const String v1AuthSendOtp = sendOtp;
  static const String v1AuthVerifyOtp = verifyOtp;
  static const String v1AuthLogin = login;
  static const String v1AuthRegister = register;
  static const String v1AuthMe = me;
  static const String v1AuthLogout = logout;
  static const String v1AuthForgetPassword = forgetPassword;
  static const String v1AuthForgotPassword = forgotPassword;
  static const String v1AuthResetPassword = resetPassword;
  static const String v1DashboardOverview = dashboardOverview;
  static const String v1UserProfile = profile;
  static const String v1UserProfileUpdate = profileUpdate;
  static const String v1UserChangePassword = changePassword;
  static const String v1UserDevices = devices;
  static const String v1UserDevicesLogout = logoutOtherDevices;
  static const String v1UserDevicesLogoutOthers = logoutOtherDevices;
  static const String v1UserOrders = userOrders;
  static const String v1UserExams = userExams;
  static const String v1UserCourses = userCourses;
  static const String v1UserSelfAcademyHistory = userSelfAcademyHistory;
  static String v1UserSelfAcademyDetail(dynamic id) => userSelfAcademyDetail(id);
  static const String v1UserExamHistory = userExamHistory;
  static const String v1ContentHistory = '/api/v1/user/content-history';
  static const String v1SavedQuestions = savedQuestions;
  static const String v1Bookmarks = savedQuestions;
  static const String v1ToggleSaveQuestion = toggleSaveQuestion;
  static const String v1BookmarkToggle = toggleSaveQuestion;
  static const String v1UserAccuracy = accuracy;
  static const String v1RewardPoints = rewardPoints;
  static const String v1RewardTransactions = rewardTransactions;
  static const String v1Referrals = referrals;
  static const String v1Packages = packages;
  static const String v1PackagesCouponApply = couponApply;
  static const String v1UserPackages = userPackages;
  static const String v1Sliders = sliders;
  static const String v1Contact = contact;
  static const String v1ContactSubmit = contactSubmit;
  static const String v1About = about;
  static const String v1AppInfo = appInfo;
  static const String v1AppInfoCheckUpdate = checkUpdate;
  static const String v1CurrentAffairsFeed = currentAffairs;
  static const String v1Blogs = blogs;
  static const String v1Vocabulary = '/api/v1/vocabularies';
  static const String v1Vocabularies = '/api/v1/vocabularies';
  static const String v1VocabularyAlphabets = '/api/v1/vocabularies/alphabets';
  static const String v1VocabularyCategories = '/api/v1/vocabularies/categories';
  static const String v1VocabularyTypes = '/api/v1/vocabularies/types';
  static String v1VocabularyDetail(dynamic id) => '/api/v1/vocabularies/$id';
  static const String v1Jobs = '/api/v1/jobs';
  static const String v1JobDepartments = '/api/v1/jobs/departments';
  static String v1JobDetail(dynamic id) => '/api/v1/jobs/$id';

  // ─── Legacy Web & App Routes ───────────────────────────────────────────────
  static final String appVersionCheck = '$appUrl/app/update';
  static final String updateProfileInfo = '$appUrl/update-profile-info';
  static final String getSubjects = '$appUrl/get-subjects';
  static final String webTestExamStart = '$appUrl/web-test-exam/start';
  static final String randomQuestion = '$appUrl/random-question';
  static final String myQuestions = '$appUrl/my-questions';
  static const String jobsList = v1Jobs;
  static const String job = v1Jobs;
  static final String internationalCA = '$appUrl/current-affairs/international';
  static final String nationalCA = '$appUrl/current-affairs/national';
  static final String privacyPolicy = '$appUrl/page/privacy-policy';
  static final String termsPolicy = '$appUrl/page/terms-and-conditions';
  static final String refundPolicy = '$appUrl/page/refund-policy';
  static final String contestPolicy = '$appUrl/page/contest-policy';
  static const String premiumPackage = packages;
  static final String packageOrder = '$appUrl/package/order';
  static final String latestContest = '$appUrl/latest-contest';
  static final String startContest = '$appUrl/contest/';
  static final String latestContestResult = '$appUrl/latest-contest-result';
  static final String allContestList = '$appUrl/contest-list';
  static final String subjectSections = '$appUrl/subject-sections';
  static const String myPackages = userPackages;
  static final String myOrders = '$appUrl/my-orders';
  static final String myOrderDetails = '$appUrl/order-details';
  static final String latestExam = '$appUrl/latest-exams';
  static final String vocabularies = '$appUrl/vocabularies';
  static final String webExamRead = '$appUrl/web-exam-read';
  static final String webExamStart = '$appUrl/web-exam-start';
  static final String lectureSheetCategories = '$appUrl/lecturesheet-categories';
  static final String lectureSheet = '$appUrl/lecturesheets';
  static final String examsCategories = '$appUrl/exam-categories';
  static final String examsCategory = '$appUrl/exam-category';
  static final String examList = '$appUrl/exam-list';
  static final String courseCategories = '$appUrl/course-categories';
  static final String courses = '$appUrl/courses';
  static const String v1CourseCategories = '/api/v1/courses/categories';
  static const String v1Courses = '/api/v1/courses';
  static String v1CourseDetails(dynamic id) => '/api/v1/courses/$id';
  static final String courseDetails = '$appUrl/course';
  static final String courseLearn = '$appUrl/course-learn';
  static final String courseEnroll = '$appUrl/course-enroll';
  // ─── Module 35: User Push Notifications (3 Endpoints) ───────────────────
  static const String notifications = '/api/v1/notifications';
  static const String notificationsReadAll = '/api/v1/notifications/read-all';
  static String notificationMarkRead(dynamic id) => '/api/v1/notifications/$id/read';
  static const String v1Notifications = notifications;
  static const String v1NotificationsReadAll = notificationsReadAll;
  static String v1NotificationMarkRead(dynamic id) => notificationMarkRead(id);

  static const String myCourses = userCourses;
}

/// Typedef alias for backward compatibility
typedef ApiEndpoints = Endpoints;
