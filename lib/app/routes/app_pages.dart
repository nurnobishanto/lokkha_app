import 'package:get/get.dart';

import '../modules/auth_views/auth_gateway/bindings/auth_gateway_binding.dart';
import '../modules/auth_views/auth_gateway/views/auth_gateway_view.dart';
import '../modules/auth_views/forget_password/bindings/forget_password_binding.dart';
import '../modules/auth_views/forget_password/views/forget_password_view.dart';
import '../modules/auth_views/sign_up/bindings/sign_up_binding.dart';
import '../modules/auth_views/sign_up/views/sign_up_view.dart';
import '../modules/auth_views/signin/bindings/signin_binding.dart';
import '../modules/auth_views/signin/views/signin_view.dart';
import '../modules/auth_views/terms_condition/bindings/terms_condition_binding.dart';
import '../modules/auth_views/terms_condition/views/terms_condition_view.dart';
import '../modules/auth_views/verify_otp/bindings/verify_otp_binding.dart';
import '../modules/auth_views/verify_otp/views/verify_otp_view.dart';
import '../modules/course_details/bindings/course_details_binding.dart';
import '../modules/course_details/views/course_details_view.dart';
import '../modules/course_learn/bindings/course_learn_binding.dart';
import '../modules/course_learn/views/course_learn_view.dart';
import '../modules/courses/bindings/courses_binding.dart';
import '../modules/courses/views/courses_view.dart';
import '../modules/current_affairs/bindings/current_affairs_binding.dart';
import '../modules/current_affairs/views/current_affairs_view.dart';
import '../modules/exam_category/bindings/exam_category_binding.dart';
import '../modules/exam_category/views/exam_category_view.dart';
import '../modules/exam_category_details/bindings/exam_category_details_binding.dart';
import '../modules/exam_category_details/views/exam_category_details_view.dart';
import '../modules/fast_practice/bindings/fast_practice_binding.dart';
import '../modules/fast_practice/views/fast_practice_view.dart';
import '../modules/grid_views/jobs/bindings/jobs_binding.dart';
import '../modules/grid_views/jobs/views/job_details_view.dart';
import '../modules/grid_views/jobs/views/jobs_view.dart';
import '../modules/grid_views/mock_test_tab/controllers/mock_test_tab_controller.dart';
import '../modules/grid_views/mock_test_tab/mock_test/bindings/mock_test_binding.dart';
import '../modules/grid_views/mock_test_tab/mock_test/controllers/mock_test_controller.dart';
import '../modules/grid_views/mock_test_tab/mock_test/views/mock_test_view.dart';
import '../modules/grid_views/mock_test_tab/views/mock_test_tab_view.dart';
import '../modules/latest_exam/bindings/latest_exam_binding.dart';
import '../modules/latest_exam/views/latest_exam_view.dart';
import '../modules/lecture_sheet/bindings/lecture_sheet_binding.dart';
import '../modules/lecture_sheet/bindings/sheet_details_binding.dart';
import '../modules/lecture_sheet/views/lecture_sheet_details_view.dart';
import '../modules/lecture_sheet/views/lecture_sheet_list_view.dart';
import '../modules/maintenance_mode/bindings/maintenance_mode_view_binding.dart';
import '../modules/maintenance_mode/views/maintenance_mode_view_view.dart';
import '../modules/my_courses/bindings/my_courses_binding.dart';
import '../modules/my_courses/views/my_courses_view.dart';
import '../modules/nav_bar_views/blog/bindings/blog_binding.dart';
import '../modules/nav_bar_views/blog/views/blog_view.dart';
import '../modules/nav_bar_views/contest/all_contest/bindings/all_contest_binding.dart';
import '../modules/nav_bar_views/contest/all_contest/views/all_contest_view.dart';
import '../modules/nav_bar_views/contest/bindings/contest_binding.dart';
import '../modules/nav_bar_views/contest/views/contest_view.dart';
import '../modules/nav_bar_views/home/bindings/home_binding.dart';
import '../modules/nav_bar_views/home/views/home_view.dart';
import '../modules/nav_bar_views/question_bank/bindings/question_bank_binding.dart';
import '../modules/nav_bar_views/question_bank/views/question_bank_view.dart';
import '../modules/navbar/bindings/navbar_binding.dart';
import '../modules/navbar/views/navbar_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/premium_packages/bindings/premium_packages_binding.dart';
import '../modules/premium_packages/views/premium_packages_view.dart';
import '../modules/profile_module/my_orders/bindings/my_orders_binding.dart';
import '../modules/profile_module/my_orders/views/my_orders_view.dart';
import '../modules/profile_module/my_packages/bindings/my_packages_binding.dart';
import '../modules/profile_module/my_packages/views/my_packages_view.dart';
import '../modules/profile_module/profile/bindings/profile_binding.dart';
import '../modules/profile_module/profile/views/profile_view.dart';
import '../modules/profile_module/profile_history/bindings/profile_history_binding.dart';
import '../modules/profile_module/profile_history/views/profile_history_view.dart';
import '../modules/profile_module/self_exam_history/bindings/self_exam_history_binding.dart';
import '../modules/profile_module/self_exam_history/views/self_exam_history_view.dart';
import '../modules/profile_module/contest_history/bindings/contest_history_binding.dart';
import '../modules/profile_module/contest_history/views/contest_history_view.dart';
import '../modules/profile_module/accuracy_progress/bindings/accuracy_progress_binding.dart';
import '../modules/profile_module/accuracy_progress/views/accuracy_progress_view.dart';
import '../modules/profile_module/profile_update/bindings/profile_update_binding.dart';
import '../modules/profile_module/profile_update/views/profile_update_view.dart';
import '../modules/profile_update_required/bindings/profile_update_required_binding.dart';
import '../modules/profile_update_required/views/profile_update_required_view.dart';
import '../modules/see_all_items/bindings/see_all_items_binding.dart';
import '../modules/see_all_items/views/all_course_view.dart';
import '../modules/see_all_items/views/all_exam_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/sponsor_ads/bindings/sponsor_ads_binding.dart';
import '../modules/sponsor_ads/views/sponsor_ads_view.dart';
import '../modules/vocabulary/bindings/vocabulary_binding.dart';
import '../modules/vocabulary/views/vocabulary_view.dart';
import '../modules/profile_module/dashboard_portal/views/dashboard_portal_view.dart';
import '../views/views/onboarding_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.NAVBAR,
      page: () => const NavbarView(),
      binding: NavbarBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.QUESTION_BANK,
      page: () => const QuestionBankView(),
      binding: QuestionBankBinding(),
    ),
    GetPage(
      name: _Paths.CONTEST,
      page: () => const ContestView(),
      binding: ContestBinding(),
      children: [
        GetPage(
          name: _Paths.ALL_CONTEST,
          page: () => const AllContestView(),
          binding: AllContestBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.BLOG,
      page: () => const BlogView(),
      binding: BlogBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.MOCK_TEST,
      page: () => const MockTestView(),
      binding: MockTestBinding(),
    ),

    GetPage(
      name: _Paths.SIGNIN,
      page: () => SignInView(),
      binding: SignInBinding(),
    ),
    GetPage(
      name: _Paths.TERMS_CONDITION,
      page: () => const TermsConditionView(),
      binding: TermsConditionBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
    ),
    GetPage(
      name: _Paths.VERIFY_OTP,
      page: () => VerifyOtpView(),
      binding: VerifyOtpBinding(),
    ),
    GetPage(
      name: _Paths.FORGET_PASSWORD,
      page: () => const ForgetPasswordView(),
      binding: ForgetPasswordBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_UP,
      page: () => const SignUpView(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: _Paths.AUTH_GATEWAY,
      page: () => const AuthGatewayView(),
      binding: AuthGatewayBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_UPDATE,
      page: () => const ProfileUpdateView(),
      binding: ProfileUpdateBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_HISTORY,
      page: () => const ProfileHistoryView(),
      binding: ProfileHistoryBinding(),
    ),
    GetPage(
      name: _Paths.SELF_EXAM_HISTORY,
      page: () => const SelfExamHistoryView(),
      binding: SelfExamHistoryBinding(),
    ),
    GetPage(
      name: _Paths.CONTEST_HISTORY,
      page: () => const ContestHistoryView(),
      binding: ContestHistoryBinding(),
    ),
    GetPage(
      name: _Paths.ACCURACY_PROGRESS,
      page: () => const AccuracyProgressView(),
      binding: AccuracyProgressBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_UPDATE_REQUIRED,
      page: () => ProfileUpdateRequiredView(),
      binding: ProfileUpdateRequiredBinding(),
    ),
    GetPage(
      name: _Paths.MOCK_TEST_TAB,
      page: () => const MockTestTabView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MockTestTabController());
        Get.lazyPut(() => MockTestController());
      }),
    ),
    GetPage(
      name: _Paths.FAST_PRACTICE,
      page: () => const FastPracticeView(),
      binding: FastPracticeBinding(),
    ),
    // GetPage(
    //   name: _Paths.TOPIC_SELECTION,
    //   page: () => const TopicSelectionView(),
    //   //binding: FastPracticeBinding(),
    // ),
    GetPage(
      name: _Paths.JOBS,
      page: () => const JobsView(),
      binding: JobsBinding(),
    ),
    GetPage(
      name: _Paths.JOB_DETAILS,
      page: () => JobDetailsScreen(id: Get.arguments),
      binding: JobsBinding(),
    ),
    GetPage(
      name: _Paths.CURRENT_AFFAIRS,
      page: () => const CurrentAffairsView(),
      binding: CurrentAffairsBinding(),
    ),
    GetPage(
      name: _Paths.PREMIUM_PACKAGES,
      page: () => const PremiumPackagesView(),
      binding: PremiumPackagesBinding(),
    ),
    // GetPage(
    //   name: _Paths.MY_APP,
    //   page: () =>  MyApp(navigatorKey: null,),
    //   binding: MyAppBinding(),
    // ),
    // GetPage(
    //   name: _Paths.SUBJECT_SECTION,
    //   page: () => const SubjectSectionView(subject: null,),
    //   binding: SubjectSectionBinding(),
    // ),
    GetPage(
      name: _Paths.MY_PACKAGES,
      page: () => const MyPackagesView(),
      binding: MyPackagesBinding(),
    ),
    GetPage(
      name: _Paths.MY_ORDERS,
      page: () => const MyOrdersView(),
      binding: MyOrdersBinding(),
    ),
    GetPage(
      name: _Paths.LATEST_EXAM,
      page: () => const LatestExamView(),
      binding: LatestExamBinding(),
    ),
    GetPage(
      name: _Paths.MAINTENANCE_MODE_VIEW,
      page: () => const MaintenanceModeView(),
      binding: MaintenanceModeBinding(),
    ),
    GetPage(
      name: _Paths.SPONSOR_ADS,
      page: () => const SponsorAdsView(),
      binding: SponsorAdsBinding(),
    ),
    GetPage(
      name: _Paths.VOCABULARY,
      page: () => const VocabularyView(),
      binding: VocabularyBinding(),
    ),
    // GetPage(
    //   name: _Paths.MODEL_TEST,
    //   page: () => const ModelTestView(),
    //   binding: ModelTestBinding(),
    // ),
    GetPage(
      name: _Paths.LECTURE_SHEET,
      page: () => const LectureSheetListView(),
      binding: LectureSheetBinding(),
    ),
    GetPage(
      name: _Paths.SHEET_DETAILS,
      page: () => const LectureSheetDetailsView(),
      binding: SheetDetailsBinding(),
    ),

    GetPage(
      name: _Paths.EXAM_CATEGORY,
      page: () => const ExamCategoryView(),
      binding: ExamCategoryBinding(),
    ),
    GetPage(
      name: _Paths.EXAM_CATEGORY_DETAILS,
      page: () => const ExamCategoryDetailsView(),
      binding: ExamCategoryDetailsBinding(),
    ),
    GetPage(
      name: _Paths.COURSES,
      page: () => CoursesView(),
      binding: CoursesBinding(),
    ),
    GetPage(
      name: _Paths.COURSE_DETAILS,
      page: () => const CourseDetailsView(),
      binding: CourseDetailsBinding(),
    ),
    GetPage(
      name: _Paths.COURSE_LEARN,
      page: () => const CourseLearnView(),
      binding: CourseLearnBinding(),
    ),
    // GetPage(
    //   name: _Paths.COURSE_CHECKOUT,
    //   page: () => const CourseCheckoutView(course: null,),
    //   binding: CourseCheckoutBinding(),
    // ),
    GetPage(
      name: _Paths.ALL_COURSES,
      page: () => const AllCourseView(),
      binding: SeeAllItemsBinding(),
    ),
    GetPage(
      name: _Paths.ALL_EXAM,
      page: () => const AllExamView(),
      binding: SeeAllItemsBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.MY_COURSES,
      page: () => const MyCoursesView(),
      binding: MyCoursesBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD_PORTAL,
      page: () => const DashboardPortalView(),
    ),
  ];
}
