import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._(); // Prevent instantiation

  /// Base URLs
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'https://lokkha.com';
  static final String appUrl = '$baseUrl/api';
  static final String apiV1BaseUrl = '$baseUrl/api/v1';
  static const String storageUrl = 'https://lokkha.com/uploads/';
  static const String sponsorAds = 'https://bdtaxation.com/api/app-ads';

  /// V1 API Endpoints
  static const String v1DashboardOverview = '/dashboard/overview';
  static const String v1UserDevices = '/user/devices';
  static const String v1UserDevicesLogout = '/user/devices/logout';
  static const String v1UserAccuracy = '/user/accuracy';
  static const String v1UserProfile = '/user/profile';
  static const String v1UserProfileUpdate = '/user/profile/update';
  static const String v1Blogs = '/blogs';
  static const String v1BlogCategories = '/blogs/categories';
  static const String v1Bookmarks = '/user/content-history/bookmarks';
  static const String v1BookmarkToggle = '/user/content-history/bookmark';
  static const String v1RewardPoints = '/user/reward-points';
  static const String v1Referrals = '/user/referrals';
  static const String v1Exams = '/exams';
  static const String v1Contests = '/contests';
  static const String v1SelfTests = '/self-tests';
  static const String v1ApplePayVerify = '/apple-pay/verify';

  /// Auth Endpoints
  static final String checkPhoneNumber = '$appUrl/check-phone-number';
  static final String sendOtp = '$appUrl/send-otp';
  static final String login = '$appUrl/login';
  static final String register = '$appUrl/register';
  static final String appVersionCheck = '$appUrl/app/update';
  static final String updateProfileRequired = '$appUrl/update-profile-required';
  static final String updateProfileInfo = '$appUrl/update-profile-info';
  static final String me = '$appUrl/me';
  static final String authCheck = '$appUrl/auth-check';
  static final String logout = '$appUrl/logout';

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
