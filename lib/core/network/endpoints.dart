import 'package:lokkha/core/constants/app_constants.dart';

/// Central API Endpoints definition following Clean Architecture
class Endpoints {
  Endpoints._();

  static String get baseUrl => AppConstants.baseUrl;
  static String get appUrl => AppConstants.appUrl;
  static String get apiV1BaseUrl => AppConstants.apiV1BaseUrl;
  static String get imageBaseUrl => AppConstants.imageBaseUrl;

  // Timeouts & Headers
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const String xApiKey = '';

  // V1 Authentication
  static const String checkPhone = '/auth/check-phone';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  static const String forgetPassword = '/auth/forget-password';

  // Dashboard & Profile
  static const String dashboardOverview = '/dashboard/overview';
  static const String profile = '/profile';
  static const String profileUpdate = '/profile/update';
  static const String changePassword = '/profile/change-password';
  static const String devices = '/user/devices';
  static const String logoutOtherDevices = '/user/devices/logout-others';

  // Orders, Exams, History & Analytics
  static const String userOrders = '/user/orders';
  static const String userExams = '/user/exams';
  static const String userCourses = '/user/courses';
  static const String userSelfAcademyHistory = '/user/self-academy-history';
  static const String userExamHistory = '/user/exam-history';
  static const String accuracy = '/user/accuracy';
  static const String rewardPoints = '/user/reward-points';
  static const String rewardTransactions = '/user/reward-points/transactions';
  static const String referrals = '/user/referrals';
  static const String savedQuestions = '/user/content-history/saved-questions';
  static const String toggleSaveQuestion = '/user/content-history/toggle-save-question';

  // Packages & Subscriptions
  static const String packages = '/packages';
  static const String userPackages = '/user/packages';
  static const String couponApply = '/packages/coupon-apply';

  // Public Dynamic Content
  static const String sliders = '/sliders';
  static const String contact = '/contact';
  static const String contactSubmit = '/contact/submit';
  static const String about = '/about';
  static const String appInfo = '/app-info';
  static const String checkUpdate = '/app-info/check-update';
  static const String currentAffairs = '/current-affairs/feed';
  static const String blogs = '/blog';
}

/// Typedef alias for backward compatibility
typedef ApiEndpoints = Endpoints;
