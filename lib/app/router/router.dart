import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Feature Imports
import 'package:lokkha/features/app_system/app_system.dart';
import 'package:lokkha/features/navigation/navigation.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/features/question_bank/question_bank.dart';
import 'package:lokkha/features/blog/blog.dart';
import 'package:lokkha/features/mock_test/mock_test.dart';
import 'package:lokkha/features/jobs/jobs.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/course/course.dart';
import 'package:lokkha/features/study_material/study_material.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/features/contest/contest.dart';
import 'package:lokkha/features/notifications/notifications.dart';
import 'package:lokkha/features/packages/packages.dart';
import 'package:lokkha/features/profile/profile.dart';
import 'package:lokkha/features/settings/settings.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/core/compat/get_compat.dart';
import 'routes.dart';
export 'routes.dart';

/// Central GoRouter Riverpod provider
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: Get.key,
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.initial,
        redirect: (_, __) => Routes.splash,
      ),
      GoRoute(
        path: '/onboarding',
        redirect: (_, __) => Routes.onBoarding,
      ),
      GoRoute(
        path: Routes.splash,
        name: Routes.splash,
        builder: (context, state) {
          return const SplashView();
        },
      ),

      // Navbar ShellRoute for persistent bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          NavbarBinding().dependencies();
          return NavbarView(child: child);
        },
        routes: [
          GoRoute(
            path: Routes.navbar,
            name: Routes.navbar,
            builder: (context, state) {
              NavbarBinding().dependencies();
              return const NavbarView();
            },
          ),
          GoRoute(
            path: Routes.home,
            name: Routes.home,
            builder: (context, state) {
              HomeBinding().dependencies();
              return const HomeView();
            },
          ),
        ],
      ),

      GoRoute(
        path: Routes.questionBank,
        name: Routes.questionBank,
        builder: (context, state) {
          QuestionBankBinding().dependencies();
          return const QuestionBankView();
        },
      ),
      GoRoute(
        path: Routes.contest,
        name: Routes.contest,
        builder: (context, state) {
          AllContestBinding().dependencies();
          return const ContestTabView();
        },
      ),
      GoRoute(
        path: Routes.allContest,
        name: Routes.allContest,
        builder: (context, state) {
          AllContestBinding().dependencies();
          return const ContestTabView(initialIndex: 1);
        },
      ),
      GoRoute(
        path: Routes.blog,
        name: Routes.blog,
        builder: (context, state) {
          BlogBinding().dependencies();
          return const BlogView();
        },
      ),
      GoRoute(
        path: Routes.blogDetails,
        name: Routes.blogDetails,
        builder: (context, state) {
          BlogDetailBinding().dependencies();
          return const BlogDetailView();
        },
      ),
      GoRoute(
        path: Routes.profile,
        name: Routes.profile,
        builder: (context, state) {
          ProfileBinding().dependencies();
          return const ProfileView();
        },
      ),
      GoRoute(
        path: Routes.mockTest,
        name: Routes.mockTest,
        builder: (context, state) {
          MockTestBinding().dependencies();
          return const MockTestView();
        },
      ),
      GoRoute(
        path: Routes.signIn,
        name: Routes.signIn,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final phone = extra['phoneNumber'] as String?;
          final type = extra['type'] as String?;
          return SignInView(phoneNumber: phone, type: type);
        },
      ),
      GoRoute(
        path: Routes.termsCondition,
        name: Routes.termsCondition,
        builder: (context, state) => const TermsConditionView(),
      ),
      GoRoute(
        path: Routes.onBoarding,
        name: Routes.onBoarding,
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: Routes.verifyOtp,
        name: Routes.verifyOtp,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final phone = extra['phoneNumber'] as String?;
          final type = extra['type'] as String?;
          return VerifyOtpView(phoneNumber: phone, type: type);
        },
      ),
      GoRoute(
        path: Routes.forgetPassword,
        name: Routes.forgetPassword,
        builder: (context, state) => const ForgetPasswordView(),
      ),
      GoRoute(
        path: Routes.signUp,
        name: Routes.signUp,
        builder: (context, state) => const SignUpView(),
      ),
      GoRoute(
        path: Routes.authGateway,
        name: Routes.authGateway,
        builder: (context, state) => const AuthGatewayView(),
      ),
      GoRoute(
        path: Routes.profileUpdate,
        name: Routes.profileUpdate,
        builder: (context, state) {
          ProfileUpdateBinding().dependencies();
          return const ProfileUpdateView();
        },
      ),
      GoRoute(
        path: Routes.profileHistory,
        name: Routes.profileHistory,
        builder: (context, state) {
          ProfileHistoryBinding().dependencies();
          return const ProfileHistoryView();
        },
      ),
      GoRoute(
        path: Routes.selfExamHistory,
        name: Routes.selfExamHistory,
        builder: (context, state) {
          SelfExamHistoryBinding().dependencies();
          return const SelfExamHistoryView();
        },
      ),
      GoRoute(
        path: Routes.contestHistory,
        name: Routes.contestHistory,
        builder: (context, state) {
          ContestHistoryBinding().dependencies();
          return const ContestHistoryView();
        },
      ),
      GoRoute(
        path: Routes.accuracyProgress,
        name: Routes.accuracyProgress,
        builder: (context, state) {
          AccuracyProgressBinding().dependencies();
          return const AccuracyProgressView();
        },
      ),
      GoRoute(
        path: Routes.referral,
        name: Routes.referral,
        builder: (context, state) {
          ReferralBinding().dependencies();
          return const ReferralView();
        },
      ),
      GoRoute(
        path: Routes.profileUpdateRequired,
        name: Routes.profileUpdateRequired,
        builder: (context, state) {
          ProfileUpdateRequiredBinding().dependencies();
          return ProfileUpdateRequiredView();
        },
      ),
      GoRoute(
        path: Routes.mockTestTab,
        name: Routes.mockTestTab,
        builder: (context, state) {
          if (!Get.isRegistered<MockTestTabController>()) {
            Get.lazyPut(() => MockTestTabController());
          }
          if (!Get.isRegistered<MockTestController>()) {
            Get.lazyPut(() => MockTestController());
          }
          return const MockTestTabView();
        },
      ),
      GoRoute(
        path: Routes.fastPractice,
        name: Routes.fastPractice,
        builder: (context, state) {
          FastPracticeBinding().dependencies();
          return const FastPracticeView();
        },
      ),
      GoRoute(
        path: Routes.jobs,
        name: Routes.jobs,
        builder: (context, state) {
          JobsBinding().dependencies();
          return const JobsView();
        },
      ),
      GoRoute(
        path: Routes.jobDetails,
        name: Routes.jobDetails,
        builder: (context, state) {
          JobsBinding().dependencies();
          final id = state.extra is int
              ? state.extra as int
              : (int.tryParse(state.extra?.toString() ?? '') ?? 0);
          return JobDetailsScreen(id: id);
        },
      ),
      GoRoute(
        path: Routes.currentAffairs,
        name: Routes.currentAffairs,
        builder: (context, state) {
          CurrentAffairsBinding().dependencies();
          return const CurrentAffairsView();
        },
      ),
      GoRoute(
        path: Routes.packages,
        name: Routes.packages,
        builder: (context, state) {
          PremiumPackagesBinding().dependencies();
          return const PremiumPackagesView();
        },
      ),
      GoRoute(
        path: Routes.myPackages,
        name: Routes.myPackages,
        builder: (context, state) {
          MyPackagesBinding().dependencies();
          return const MyPackagesView();
        },
      ),
      GoRoute(
        path: Routes.myOrders,
        name: Routes.myOrders,
        builder: (context, state) {
          MyOrdersBinding().dependencies();
          return const MyOrdersView();
        },
      ),
      GoRoute(
        path: Routes.latestExam,
        name: Routes.latestExam,
        builder: (context, state) {
          LatestExamBinding().dependencies();
          return const LatestExamView();
        },
      ),
      GoRoute(
        path: Routes.maintenanceMode,
        name: Routes.maintenanceMode,
        builder: (context, state) {
          MaintenanceModeBinding().dependencies();
          return const MaintenanceModeView();
        },
      ),
      GoRoute(
        path: Routes.sponsorAds,
        name: Routes.sponsorAds,
        builder: (context, state) {
          SponsorAdsBinding().dependencies();
          return const SponsorAdsView();
        },
      ),
      GoRoute(
        path: Routes.vocabulary,
        name: Routes.vocabulary,
        builder: (context, state) {
          VocabularyBinding().dependencies();
          return const VocabularyView();
        },
      ),
      GoRoute(
        path: Routes.lectureSheet,
        name: Routes.lectureSheet,
        builder: (context, state) {
          LectureSheetBinding().dependencies();
          return const LectureSheetListView();
        },
      ),
      GoRoute(
        path: Routes.sheetDetails,
        name: Routes.sheetDetails,
        builder: (context, state) {
          SheetDetailsBinding().dependencies();
          return const LectureSheetDetailsView();
        },
      ),
      GoRoute(
        path: Routes.examCategory,
        name: Routes.examCategory,
        builder: (context, state) {
          ExamCategoryBinding().dependencies();
          return const ExamCategoryView();
        },
      ),
      GoRoute(
        path: Routes.examCategoryDetails,
        name: Routes.examCategoryDetails,
        builder: (context, state) {
          ExamCategoryDetailsBinding().dependencies();
          return const ExamCategoryDetailsView();
        },
      ),
      GoRoute(
        path: Routes.courses,
        name: Routes.courses,
        builder: (context, state) {
          CoursesBinding().dependencies();
          return CoursesView();
        },
      ),
      GoRoute(
        path: Routes.courseDetails,
        name: Routes.courseDetails,
        builder: (context, state) {
          CourseDetailsBinding().dependencies();
          return const CourseDetailsView();
        },
      ),
      GoRoute(
        path: Routes.courseLearn,
        name: Routes.courseLearn,
        builder: (context, state) {
          CourseLearnBinding().dependencies();
          return const CourseLearnView();
        },
      ),
      GoRoute(
        path: Routes.allCourses,
        name: Routes.allCourses,
        builder: (context, state) {
          SeeAllItemsBinding().dependencies();
          return const AllCourseView();
        },
      ),
      GoRoute(
        path: Routes.allExam,
        name: Routes.allExam,
        builder: (context, state) {
          SeeAllItemsBinding().dependencies();
          return const AllExamView();
        },
      ),
      GoRoute(
        path: Routes.notifications,
        name: Routes.notifications,
        builder: (context, state) {
          NotificationsBinding().dependencies();
          return const NotificationsView();
        },
      ),
      GoRoute(
        path: Routes.myCourses,
        name: Routes.myCourses,
        builder: (context, state) {
          MyCoursesBinding().dependencies();
          return const MyCoursesView();
        },
      ),
      GoRoute(
        path: Routes.dashboardPortal,
        name: Routes.dashboardPortal,
        builder: (context, state) => const DashboardPortalView(),
      ),
      GoRoute(
        path: Routes.settings,
        name: Routes.settings,
        builder: (context, state) {
          SettingsBinding().dependencies();
          return const SettingsView();
        },
      ),
      GoRoute(
        path: Routes.subjectSection,
        name: Routes.subjectSection,
        builder: (context, state) {
          final subject = state.extra as Subject? ?? (Get.arguments as Subject?);
          return SubjectSectionView(subject: subject);
        },
      ),
      GoRoute(
        path: Routes.topicSelection,
        name: Routes.topicSelection,
        builder: (context, state) {
          final subject = (state.extra as Subject?) ?? (Get.arguments as Subject?);
          return TopicSelectionView(subject: subject ?? Subject());
        },
      ),
      GoRoute(
        path: Routes.appUpdate,
        name: Routes.appUpdate,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return AppUpdateView(
            url: extra['url'] as Uri? ?? Uri.parse(''),
            title: extra['title'] as String?,
            message: extra['message'] as String?,
            currentVersion: extra['currentVersion'] as String?,
            latestVersion: extra['latestVersion'] as String?,
          );
        },
      ),
    ],
  );
});

