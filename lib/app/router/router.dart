import 'package:flutter/foundation.dart';
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
import 'package:lokkha/features/course/course.dart' hide Package;
import 'package:lokkha/features/study_material/study_material.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/features/contest/contest.dart';
import 'package:lokkha/features/notifications/notifications.dart';
import 'package:lokkha/features/packages/packages.dart';
import 'package:lokkha/features/profile/profile.dart';
import 'package:lokkha/features/settings/settings.dart';
import 'package:lokkha/features/about/about.dart';
import 'package:lokkha/shared/shared.dart';
import 'route_observer.dart';
import 'routes.dart';
export 'route_observer.dart';
export 'routes.dart';

/// Central Navigation & Messenger Keys
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Central GoRouter Riverpod provider
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash,
    debugLogDiagnostics: kDebugMode,
    observers: [
      AppRouteObserver(),
    ],
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

      // Redirect /navbar to /home
      GoRoute(
        path: Routes.navbar,
        name: Routes.navbar,
        redirect: (_, __) => Routes.home,
      ),

      // StatefulShellRoute for persistent bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavbarView(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: হোম (Home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                name: Routes.home,
                builder: (context, state) {
                  return const HomeView();
                },
              ),
            ],
          ),

          // Branch 1: পরীক্ষা (Exam)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.examCategory,
                name: Routes.examCategory,
                builder: (context, state) {
                  return const ExamCategoryView();
                },
              ),
            ],
          ),

          // Branch 2: মেসেঞ্জার (Messenger)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.messenger,
                name: Routes.messenger,
                builder: (context, state) {
                  return const MessengerRedirectScreen();
                },
              ),
            ],
          ),

          // Branch 3: প্রিমিয়াম (Premium Packages)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.packages,
                name: Routes.packages,
                builder: (context, state) {
                  return const PremiumPackagesView();
                },
              ),
            ],
          ),

          // Branch 4: প্রোফাইল / ড্যাশবোর্ড (Profile / Dashboard)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.dashboardPortal,
                name: Routes.dashboardPortal,
                builder: (context, state) {
                  return const DashboardPortalView();
                },
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: Routes.questionBank,
        name: Routes.questionBank,
        builder: (context, state) {
          return const QuestionBankView();
        },
      ),
      GoRoute(
        path: Routes.contest,
        name: Routes.contest,
        builder: (context, state) {
          return const ContestTabView();
        },
      ),
      GoRoute(
        path: Routes.allContest,
        name: Routes.allContest,
        builder: (context, state) {
          return const ContestTabView(initialIndex: 1);
        },
      ),
      GoRoute(
        path: Routes.blog,
        name: Routes.blog,
        builder: (context, state) {
          return const BlogView();
        },
      ),
      GoRoute(
        path: Routes.blogDetails,
        name: Routes.blogDetails,
        builder: (context, state) {
          final post = state.extra as BlogPost?;
          return BlogDetailView(post: post);
        },
      ),
      GoRoute(
        path: Routes.profile,
        name: Routes.profile,
        builder: (context, state) {
          return const ProfileView();
        },
      ),
      GoRoute(
        path: Routes.mockTest,
        name: Routes.mockTest,
        builder: (context, state) {
          return const MockTestView();
        },
      ),
      GoRoute(
        path: Routes.signIn,
        name: Routes.signIn,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final phone = extra['phoneNumber'] as String? ?? '';
          final type = extra['type'] as String? ?? 'password';
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
          final phone = extra['phoneNumber'] as String? ?? '';
          final type = extra['type'] as String? ?? 'Registration';
          final autoSendOtp = extra['autoSendOtp'] as bool? ??
              (!type.toLowerCase().contains('forget') &&
                  !type.toLowerCase().contains('forgot') &&
                  !type.toLowerCase().contains('reset'));
          final initialExpiresIn = extra['initialExpiresIn'] as int? ?? 300;
          final serverOtp = extra['serverOtp'] as String? ?? extra['otp'] as String?;
          return VerifyOtpView(
            phoneNumber: phone,
            type: type,
            autoSendOtp: autoSendOtp,
            initialExpiresIn: initialExpiresIn,
            serverOtp: serverOtp,
          );
        },
      ),
      GoRoute(
        path: Routes.forgetPassword,
        name: Routes.forgetPassword,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final phone = extra['phoneNumber'] as String? ?? '';
          return ForgetPasswordView(initialPhoneNumber: phone);
        },
      ),
      GoRoute(
        path: Routes.resetPassword,
        name: Routes.resetPassword,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final phone = extra['phoneNumber'] as String? ?? '';
          final otp = extra['otp'] as String? ?? '';
          return ResetPasswordView(phoneNumber: phone, otp: otp);
        },
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
        builder: (context, state) => const ProfileUpdateView(),
      ),
      GoRoute(
        path: Routes.profileHistory,
        name: Routes.profileHistory,
        builder: (context, state) => const ProfileHistoryView(),
      ),
      GoRoute(
        path: Routes.selfExamHistory,
        name: Routes.selfExamHistory,
        builder: (context, state) => const SelfExamHistoryView(),
      ),
      GoRoute(
        path: Routes.contestHistory,
        name: Routes.contestHistory,
        builder: (context, state) => const LiveContestView(),
      ),
      GoRoute(
        path: Routes.liveContest,
        name: Routes.liveContest,
        builder: (context, state) => const LiveContestView(),
      ),
      GoRoute(
        path: Routes.accuracyProgress,
        name: Routes.accuracyProgress,
        builder: (context, state) => const AccuracyProgressView(),
      ),
      GoRoute(
        path: Routes.referral,
        name: Routes.referral,
        builder: (context, state) => const ReferralView(),
      ),
      GoRoute(
        path: Routes.profileUpdateRequired,
        name: Routes.profileUpdateRequired,
        builder: (context, state) {
          final phone = (state.extra as Map<String, dynamic>?)?['phoneNumber'] as String? ?? '';
          return ProfileUpdateRequiredView(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: Routes.mockTestTab,
        name: Routes.mockTestTab,
        builder: (context, state) {
          return const MockTestTabView();
        },
      ),
      GoRoute(
        path: Routes.fastPractice,
        name: Routes.fastPractice,
        builder: (context, state) => const FastPracticeView(),
      ),
      GoRoute(
        path: Routes.jobs,
        name: Routes.jobs,
        builder: (context, state) {
          return const JobsView();
        },
      ),
      GoRoute(
        path: Routes.jobDetails,
        name: Routes.jobDetails,
        builder: (context, state) {
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
          return const CurrentAffairsView();
        },
      ),
      GoRoute(
        path: Routes.packageDetails,
        name: Routes.packageDetails,
        builder: (context, state) {
          final extra = state.extra;
          int packageId = 0;
          Package? initialPackage;

          if (extra is int) {
            packageId = extra;
          } else if (extra is Package) {
            packageId = extra.id ?? 0;
            initialPackage = extra;
          } else if (extra is Map) {
            packageId = extra['id'] is int
                ? extra['id']
                : int.tryParse(extra['id']?.toString() ?? '') ?? 0;
            if (extra['package'] is Package) {
              initialPackage = extra['package'] as Package;
            }
          }

          if (packageId == 0) {
            final qId = state.uri.queryParameters['id'];
            if (qId != null) {
              packageId = int.tryParse(qId) ?? 0;
            }
          }

          return PackageDetailsView(
            packageId: packageId,
            initialPackage: initialPackage,
          );
        },
      ),
      GoRoute(
        path: Routes.myPackages,
        name: Routes.myPackages,
        builder: (context, state) => const MyPackagesView(),
      ),
      GoRoute(
        path: Routes.myOrders,
        name: Routes.myOrders,
        builder: (context, state) => const MyOrdersView(),
      ),
      GoRoute(
        path: Routes.latestExam,
        name: Routes.latestExam,
        builder: (context, state) => const LatestExamView(),
      ),
      GoRoute(
        path: Routes.maintenanceMode,
        name: Routes.maintenanceMode,
        builder: (context, state) => const MaintenanceModeView(),
      ),
      GoRoute(
        path: Routes.sponsorAds,
        name: Routes.sponsorAds,
        builder: (context, state) => const SponsorAdsView(),
      ),
      GoRoute(
        path: Routes.vocabulary,
        name: Routes.vocabulary,
        builder: (context, state) {
          return const VocabularyView();
        },
      ),
      GoRoute(
        path: Routes.lectureSheet,
        name: Routes.lectureSheet,
        builder: (context, state) {
          return const LectureSheetListView();
        },
      ),
      GoRoute(
        path: Routes.sheetDetails,
        name: Routes.sheetDetails,
        builder: (context, state) {
          final extra = state.extra;
          int id = 0;
          if (extra is int) {
            id = extra;
          } else if (extra is Map) {
            id = extra['id'] as int? ?? int.tryParse(extra['id']?.toString() ?? '') ?? 0;
          }
          if (id == 0) {
            id = int.tryParse(state.uri.queryParameters['id'] ?? '') ?? 0;
          }
          return LectureSheetDetailsView(id: id);
        },
      ),
      GoRoute(
        path: Routes.examCategoryDetails,
        name: Routes.examCategoryDetails,
        builder: (context, state) {
          final extra = state.extra;
          int categoryId = 0;
          String categoryName = '';
          if (extra is Map) {
            categoryId = extra['category_id'] as int? ??
                int.tryParse(extra['category_id']?.toString() ?? '') ??
                0;
            categoryName = extra['category_name'] as String? ?? '';
          }
          return ExamCategoryDetailsView(
            categoryId: categoryId,
            categoryName: categoryName,
          );
        },
      ),
      GoRoute(
        path: Routes.courses,
        name: Routes.courses,
        builder: (context, state) {
          final extra = state.extra;
          int? categoryId;
          String? categoryName;
          if (extra is Map) {
            final rawId = extra['course_category_id'] ?? extra['id'];
            if (rawId is int) {
              categoryId = rawId;
            } else if (rawId != null) {
              categoryId = int.tryParse(rawId.toString());
            }
            categoryName = extra['category_name']?.toString();
          }
          categoryId ??= int.tryParse(state.uri.queryParameters['course_category_id'] ?? '');
          categoryName ??= state.uri.queryParameters['category_name'];
          return CoursesView(categoryId: categoryId, categoryName: categoryName);
        },
      ),
      GoRoute(
        path: Routes.courseDetails,
        name: Routes.courseDetails,
        builder: (context, state) {
          final extra = state.extra;
          int courseId = 0;
          if (extra is int) {
            courseId = extra;
          } else if (extra is Map) {
            final rawId = extra['course_id'] ?? extra['id'];
            if (rawId is int) {
              courseId = rawId;
            } else if (rawId != null) {
              courseId = int.tryParse(rawId.toString()) ?? 0;
            }
          }
          if (courseId == 0) {
            final param = state.uri.queryParameters['course_id'] ??
                state.uri.queryParameters['id'];
            if (param != null) {
              courseId = int.tryParse(param) ?? 0;
            }
          }
          return CourseDetailsView(courseId: courseId);
        },
      ),
      GoRoute(
        path: Routes.courseLearn,
        name: Routes.courseLearn,
        builder: (context, state) {
          final extra = state.extra;
          int? id;
          int? itemId;
          if (extra is Map) {
            id = extra['id'] as int? ?? int.tryParse(extra['id']?.toString() ?? '');
            itemId = extra['item_id'] as int? ?? int.tryParse(extra['item_id']?.toString() ?? '');
          } else if (extra is int) {
            id = extra;
          }
          id ??= int.tryParse(state.uri.queryParameters['id'] ?? '');
          itemId ??= int.tryParse(state.uri.queryParameters['item_id'] ?? '');
          return CourseLearnView(id: id, itemId: itemId);
        },
      ),
      GoRoute(
        path: Routes.allCourses,
        name: Routes.allCourses,
        builder: (context, state) => const AllCourseView(),
      ),
      GoRoute(
        path: Routes.allExam,
        name: Routes.allExam,
        builder: (context, state) => const AllExamView(),
      ),
      GoRoute(
        path: Routes.notifications,
        name: Routes.notifications,
        builder: (context, state) {
          return const NotificationsView();
        },
      ),
      GoRoute(
        path: Routes.myCourses,
        name: Routes.myCourses,
        builder: (context, state) {
          return const MyCoursesView();
        },
      ),
      GoRoute(
        path: Routes.settings,
        name: Routes.settings,
        builder: (context, state) {
          return const SettingsView();
        },
      ),
      GoRoute(
        path: Routes.subjectSection,
        name: Routes.subjectSection,
        builder: (context, state) {
          final subject = state.extra as Subject?;
          return SubjectSectionView(subject: subject);
        },
      ),
      GoRoute(
        path: Routes.topicSelection,
        name: Routes.topicSelection,
        builder: (context, state) {
          final subject = state.extra as Subject?;
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
      GoRoute(
        path: Routes.about,
        name: Routes.about,
        builder: (context, state) => const AboutUsView(),
      ),
    ],
  );
});

