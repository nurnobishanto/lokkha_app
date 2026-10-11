/// Unified route path constants for GoRouter & Lokkha App
class AppRoutePaths {
  AppRoutePaths._();

  static const String initial = '/';
  static const String splash = '/splash';
  static const String onboarding = '/on-boarding';
  static const String onBoarding = '/on-boarding';

  // Auth paths
  static const String authGateway = '/auth-gateway';
  static const String signUp = '/sign-up';
  static const String signIn = '/signin';
  static const String verifyOtp = '/verify-otp';
  static const String forgetPassword = '/forget-password';
  static const String terms = '/terms-condition';
  static const String termsCondition = '/terms-condition';

  // Core navigation
  static const String navBar = '/navbar';
  static const String navbar = '/navbar';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String profileUpdate = '/profile-update';
  static const String profileHistory = '/profile-history';
  static const String profileUpdateRequired = '/profile-update-required';
  static const String selfExamHistory = '/self-exam-history';
  static const String contestHistory = '/contest-history';
  static const String accuracyProgress = '/accuracy-progress';
  static const String referral = '/referral';
  static const String dashboardPortal = '/dashboard-portal';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  // Features
  static const String questionBank = '/question-bank';
  static const String contest = '/contest';
  static const String allContest = '/all-contest';
  static const String blog = '/blog';
  static const String blogDetails = '/blog-details';
  static const String mockTest = '/mock-test';
  static const String mockTestTab = '/mock-test-tab';
  static const String fastPractice = '/fast-practice';
  static const String topicSelection = '/topic-selection';
  static const String jobs = '/jobs';
  static const String jobDetails = '/job-details';
  static const String currentAffairs = '/current-affairs';
  static const String packages = '/packages';
  static const String premiumPackages = '/packages';
  static const String myPackages = '/my-packages';
  static const String myOrders = '/my-orders';
  static const String latestExam = '/latest-exam';
  static const String maintenanceMode = '/maintenance-mode-view';
  static const String appUpdate = '/app-update-view';
  static const String sponsorAds = '/sponsor-ads';
  static const String vocabulary = '/vocabulary';
  static const String lectureSheet = '/lecture-sheet';
  static const String sheetDetails = '/sheet-details';
  static const String examCategory = '/exam-category';
  static const String examCategoryDetails = '/exam-category-details';
  static const String courses = '/courses';
  static const String courseDetails = '/course-details';
  static const String courseLearn = '/course-learn';
  static const String courseCheckout = '/course-checkout';
  static const String allCourses = '/all-courses';
  static const String allExam = '/all-exam';
  static const String myCourses = '/my-courses';
  static const String subjectSection = '/subject-section';
  static const String myApp = '/my-app';
}

/// Unified Routes constants for 100% backward compatibility
abstract class Routes {
  Routes._();

  static const String HOME = AppRoutePaths.home;
  static const String SPLASH = AppRoutePaths.splash;
  static const String NAVBAR = AppRoutePaths.navbar;
  static const String QUESTION_BANK = AppRoutePaths.questionBank;
  static const String CONTEST = AppRoutePaths.contest;
  static const String BLOG = AppRoutePaths.blog;
  static const String BLOG_DETAILS = AppRoutePaths.blogDetails;
  static const String PROFILE = AppRoutePaths.profile;
  static String MOCK_TEST = AppRoutePaths.mockTest;
  static const String AJKER_PORIKKHA = '/ajker-porikkha';
  static const String JOBS_UPDATE = '/jobs-update';
  static const String AJKER_BISSHO = '/ajker-bissho';
  static const String NOTICE_BOARD = '/notice-board';
  static const String SIGNIN = AppRoutePaths.signIn;
  static const String TERMS_CONDITION = AppRoutePaths.termsCondition;
  static const String ONBOARDING = AppRoutePaths.onBoarding;
  static const String VERIFY_OTP = AppRoutePaths.verifyOtp;
  static const String FORGET_PASSWORD = AppRoutePaths.forgetPassword;
  static const String SIGN_UP = AppRoutePaths.signUp;
  static const String AUTH_GATEWAY = AppRoutePaths.authGateway;
  static const String PROFILE_UPDATE = AppRoutePaths.profileUpdate;
  static const String PROFILE_HISTORY = AppRoutePaths.profileHistory;
  static const String PROFILE_UPDATE_REQUIRED = AppRoutePaths.profileUpdateRequired;
  static const String MOCK_TEST_TAB = AppRoutePaths.mockTestTab;
  static const String FAST_PRACTICE = AppRoutePaths.fastPractice;
  static const String TOPIC_SELECTION = AppRoutePaths.topicSelection;
  static const String JOBS = AppRoutePaths.jobs;
  static const String CURRENT_AFFAIRS = AppRoutePaths.currentAffairs;
  static const String PREMIUM_PACKAGES = AppRoutePaths.packages;
  static const String MY_APP = AppRoutePaths.myApp;
  static const String SUBJECT_SECTION = AppRoutePaths.subjectSection;
  static const String MY_PACKAGES = AppRoutePaths.myPackages;
  static const String MY_ORDERS = AppRoutePaths.myOrders;
  static const String LATEST_EXAM = AppRoutePaths.latestExam;
  static const String MAINTENANCE_MODE_VIEW = AppRoutePaths.maintenanceMode;
  static const String APP_UPDATE_VIEW = AppRoutePaths.appUpdate;
  static const String ALL_CONTEST = AppRoutePaths.allContest;
  static const String SPONSOR_ADS = AppRoutePaths.sponsorAds;
  static const String VOCABULARY = AppRoutePaths.vocabulary;
  static const String MODEL_TEST = '/model-test';
  static const String LECTURE_SHEET = AppRoutePaths.lectureSheet;
  static const String SHEET_DETAILS = AppRoutePaths.sheetDetails;
  static const String MODEL_TEST_CATEGORIES = '/model-test-categories';
  static const String MODEL_TEST_DETAILS = '/model-test-details';
  static const String EXAM_CATEGORY = AppRoutePaths.examCategory;
  static const String EXAM_CATEGORY_DETAILS = AppRoutePaths.examCategoryDetails;
  static const String COURSES = AppRoutePaths.courses;
  static const String COURSE_DETAILS = AppRoutePaths.courseDetails;
  static const String COURSE_LEARN = AppRoutePaths.courseLearn;
  static const String COURSE_CHECKOUT = AppRoutePaths.courseCheckout;
  static const String ALL_COURSES = AppRoutePaths.allCourses;
  static const String ALL_EXAM = AppRoutePaths.allExam;
  static const String JOB_DETAILS = AppRoutePaths.jobDetails;
  static const String NOTIFICATIONS = AppRoutePaths.notifications;
  static const String MY_COURSES = AppRoutePaths.myCourses;
  static const String DASHBOARD_PORTAL = AppRoutePaths.dashboardPortal;
  static const String SELF_EXAM_HISTORY = AppRoutePaths.selfExamHistory;
  static const String CONTEST_HISTORY = AppRoutePaths.contestHistory;
  static const String ACCURACY_PROGRESS = AppRoutePaths.accuracyProgress;
  static const String REFERRAL = AppRoutePaths.referral;
  static const String SETTINGS = AppRoutePaths.settings;
}
