import 'package:lokkha/features/app_system/app_system.dart';
import 'package:lokkha/features/navigation/navigation.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/features/question_bank/question_bank.dart';
import 'package:lokkha/features/blog/blog.dart';
import 'package:lokkha/features/mock_test/mock_test.dart';
import 'package:lokkha/features/jobs/jobs.dart';
import 'package:get/get.dart';

import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/course/course.dart';
import 'package:lokkha/features/study_material/study_material.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/features/contest/contest.dart';
import 'package:lokkha/features/notifications/notifications.dart';
import 'package:lokkha/features/packages/packages.dart';
import 'package:lokkha/features/profile/profile.dart';

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
      name: _Paths.BLOG_DETAILS,
      page: () => const BlogDetailView(),
      binding: BlogDetailBinding(),
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
      name: _Paths.REFERRAL,
      page: () => const ReferralView(),
      binding: ReferralBinding(),
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
