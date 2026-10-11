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
import 'app_route_paths.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: Get.key,
    initialLocation: AppRoutePaths.splash,
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => AppRoutePaths.splash,
      ),
      GoRoute(
        path: '/onboarding',
        redirect: (_, __) => AppRoutePaths.onBoarding,
      ),
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) {
          return const SplashView();
        },
      ),
      GoRoute(
        path: '/navbar',
        name: 'navbar',
        builder: (context, state) {
          NavbarBinding().dependencies();
          return const NavbarView();
        },
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          HomeBinding().dependencies();
          return const HomeView();
        },
      ),
      GoRoute(
        path: '/question-bank',
        name: 'question-bank',
        builder: (context, state) {
          QuestionBankBinding().dependencies();
          return const QuestionBankView();
        },
      ),
      GoRoute(
        path: '/contest',
        name: 'contest',
        builder: (context, state) {
          AllContestBinding().dependencies();
          return const ContestTabView();
        },
      ),
      GoRoute(
        path: '/all-contest',
        name: 'all-contest',
        builder: (context, state) {
          AllContestBinding().dependencies();
          return const ContestTabView(initialIndex: 1);
        },
      ),
      GoRoute(
        path: '/blog',
        name: 'blog',
        builder: (context, state) {
          BlogBinding().dependencies();
          return const BlogView();
        },
      ),
      GoRoute(
        path: '/blog-details',
        name: 'blog-details',
        builder: (context, state) {
          BlogDetailBinding().dependencies();
          return const BlogDetailView();
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) {
          ProfileBinding().dependencies();
          return const ProfileView();
        },
      ),
      GoRoute(
        path: '/mock-test',
        name: 'mock-test',
        builder: (context, state) {
          MockTestBinding().dependencies();
          return const MockTestView();
        },
      ),
      GoRoute(
        path: '/signin',
        name: 'signin',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final phone = extra['phoneNumber'] as String?;
          final type = extra['type'] as String?;
          return SignInView(phoneNumber: phone, type: type);
        },
      ),
      GoRoute(
        path: '/terms-condition',
        name: 'terms-condition',
        builder: (context, state) => const TermsConditionView(),
      ),
      GoRoute(
        path: '/on-boarding',
        name: 'on-boarding',
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: '/verify-otp',
        name: 'verify-otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final phone = extra['phoneNumber'] as String?;
          final type = extra['type'] as String?;
          return VerifyOtpView(phoneNumber: phone, type: type);
        },
      ),
      GoRoute(
        path: '/forget-password',
        name: 'forget-password',
        builder: (context, state) => const ForgetPasswordView(),
      ),
      GoRoute(
        path: '/sign-up',
        name: 'sign-up',
        builder: (context, state) => const SignUpView(),
      ),
      GoRoute(
        path: '/auth-gateway',
        name: 'auth-gateway',
        builder: (context, state) => const AuthGatewayView(),
      ),
      GoRoute(
        path: '/profile-update',
        name: 'profile-update',
        builder: (context, state) {
          ProfileUpdateBinding().dependencies();
          return const ProfileUpdateView();
        },
      ),
      GoRoute(
        path: '/profile-history',
        name: 'profile-history',
        builder: (context, state) {
          ProfileHistoryBinding().dependencies();
          return const ProfileHistoryView();
        },
      ),
      GoRoute(
        path: '/self-exam-history',
        name: 'self-exam-history',
        builder: (context, state) {
          SelfExamHistoryBinding().dependencies();
          return const SelfExamHistoryView();
        },
      ),
      GoRoute(
        path: '/contest-history',
        name: 'contest-history',
        builder: (context, state) {
          ContestHistoryBinding().dependencies();
          return const ContestHistoryView();
        },
      ),
      GoRoute(
        path: '/accuracy-progress',
        name: 'accuracy-progress',
        builder: (context, state) {
          AccuracyProgressBinding().dependencies();
          return const AccuracyProgressView();
        },
      ),
      GoRoute(
        path: '/referral',
        name: 'referral',
        builder: (context, state) {
          ReferralBinding().dependencies();
          return const ReferralView();
        },
      ),
      GoRoute(
        path: '/profile-update-required',
        name: 'profile-update-required',
        builder: (context, state) {
          ProfileUpdateRequiredBinding().dependencies();
          return ProfileUpdateRequiredView();
        },
      ),
      GoRoute(
        path: '/mock-test-tab',
        name: 'mock-test-tab',
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
        path: '/fast-practice',
        name: 'fast-practice',
        builder: (context, state) {
          FastPracticeBinding().dependencies();
          return const FastPracticeView();
        },
      ),
      GoRoute(
        path: '/jobs',
        name: 'jobs',
        builder: (context, state) {
          JobsBinding().dependencies();
          return const JobsView();
        },
      ),
      GoRoute(
        path: '/job-details',
        name: 'job-details',
        builder: (context, state) {
          JobsBinding().dependencies();
          final id = state.extra is int
              ? state.extra as int
              : (int.tryParse(state.extra?.toString() ?? '') ?? 0);
          return JobDetailsScreen(id: id);
        },
      ),
      GoRoute(
        path: '/current-affairs',
        name: 'current-affairs',
        builder: (context, state) {
          CurrentAffairsBinding().dependencies();
          return const CurrentAffairsView();
        },
      ),
      GoRoute(
        path: '/packages',
        name: 'packages',
        builder: (context, state) {
          PremiumPackagesBinding().dependencies();
          return const PremiumPackagesView();
        },
      ),
      GoRoute(
        path: '/my-packages',
        name: 'my-packages',
        builder: (context, state) {
          MyPackagesBinding().dependencies();
          return const MyPackagesView();
        },
      ),
      GoRoute(
        path: '/my-orders',
        name: 'my-orders',
        builder: (context, state) {
          MyOrdersBinding().dependencies();
          return const MyOrdersView();
        },
      ),
      GoRoute(
        path: '/latest-exam',
        name: 'latest-exam',
        builder: (context, state) {
          LatestExamBinding().dependencies();
          return const LatestExamView();
        },
      ),
      GoRoute(
        path: '/maintenance-mode-view',
        name: 'maintenance-mode-view',
        builder: (context, state) {
          MaintenanceModeBinding().dependencies();
          return const MaintenanceModeView();
        },
      ),
      GoRoute(
        path: '/sponsor-ads',
        name: 'sponsor-ads',
        builder: (context, state) {
          SponsorAdsBinding().dependencies();
          return const SponsorAdsView();
        },
      ),
      GoRoute(
        path: '/vocabulary',
        name: 'vocabulary',
        builder: (context, state) {
          VocabularyBinding().dependencies();
          return const VocabularyView();
        },
      ),
      GoRoute(
        path: '/lecture-sheet',
        name: 'lecture-sheet',
        builder: (context, state) {
          LectureSheetBinding().dependencies();
          return const LectureSheetListView();
        },
      ),
      GoRoute(
        path: '/sheet-details',
        name: 'sheet-details',
        builder: (context, state) {
          SheetDetailsBinding().dependencies();
          return const LectureSheetDetailsView();
        },
      ),
      GoRoute(
        path: '/exam-category',
        name: 'exam-category',
        builder: (context, state) {
          ExamCategoryBinding().dependencies();
          return const ExamCategoryView();
        },
      ),
      GoRoute(
        path: '/exam-category-details',
        name: 'exam-category-details',
        builder: (context, state) {
          ExamCategoryDetailsBinding().dependencies();
          return const ExamCategoryDetailsView();
        },
      ),
      GoRoute(
        path: '/courses',
        name: 'courses',
        builder: (context, state) {
          CoursesBinding().dependencies();
          return CoursesView();
        },
      ),
      GoRoute(
        path: '/course-details',
        name: 'course-details',
        builder: (context, state) {
          CourseDetailsBinding().dependencies();
          return const CourseDetailsView();
        },
      ),
      GoRoute(
        path: '/course-learn',
        name: 'course-learn',
        builder: (context, state) {
          CourseLearnBinding().dependencies();
          return const CourseLearnView();
        },
      ),
      GoRoute(
        path: '/all-courses',
        name: 'all-courses',
        builder: (context, state) {
          SeeAllItemsBinding().dependencies();
          return const AllCourseView();
        },
      ),
      GoRoute(
        path: '/all-exam',
        name: 'all-exam',
        builder: (context, state) {
          SeeAllItemsBinding().dependencies();
          return const AllExamView();
        },
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) {
          NotificationsBinding().dependencies();
          return const NotificationsView();
        },
      ),
      GoRoute(
        path: '/my-courses',
        name: 'my-courses',
        builder: (context, state) {
          MyCoursesBinding().dependencies();
          return const MyCoursesView();
        },
      ),
      GoRoute(
        path: '/dashboard-portal',
        name: 'dashboard-portal',
        builder: (context, state) => const DashboardPortalView(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) {
          SettingsBinding().dependencies();
          return const SettingsView();
        },
      ),
      GoRoute(
        path: '/subject-section',
        name: 'subject-section',
        builder: (context, state) {
          final subject = state.extra as Subject? ?? (Get.arguments as Subject?);
          return SubjectSectionView(subject: subject);
        },
      ),
      GoRoute(
        path: '/topic-selection',
        name: 'topic-selection',
        builder: (context, state) {
          final subject = (state.extra as Subject?) ?? (Get.arguments as Subject?);
          return TopicSelectionView(subject: subject ?? Subject());
        },
      ),
      GoRoute(
        path: '/app-update-view',
        name: 'app-update-view',
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
