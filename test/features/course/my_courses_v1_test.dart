import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/features/course/data/models/my_course_model.dart';
import 'package:lokkha/features/course/presentation/my_courses/views/my_courses_view.dart';
import 'package:lokkha/features/course/presentation/providers/course_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('My Enrolled Courses V1 Model Tests', () {
    test('Parses official V1 JSON response accurately', () {
      final json = {
        "success": true,
        "message": "Enrolled courses retrieved successfully.",
        "data": {
          "items": [
            {
              "enrollment_id": 14,
              "course_id": 5,
              "title": "Complete BCS English Grammar Mastery",
              "slug": "complete-bcs-english-grammar-mastery",
              "image_url": "https://lokkha.com/uploads/courses/eng.jpg",
              "lifetime_access": true,
              "access_expiry": null,
              "is_expired": false,
              "enrolled_at": "2026-08-15 12:00:00"
            }
          ]
        },
        "meta": {"current_page": 1, "last_page": 1, "total": 1}
      };

      final response = MyCourseModel.fromJson(json);

      expect(response.success, isTrue);
      expect(response.message, "Enrolled courses retrieved successfully.");
      expect(response.courses.length, 1);
      expect(response.meta?.currentPage, 1);
      expect(response.meta?.lastPage, 1);
      expect(response.meta?.total, 1);

      final course = response.courses.first;
      expect(course.enrollmentId, 14);
      expect(course.courseId, 5);
      expect(course.title, "Complete BCS English Grammar Mastery");
      expect(course.slug, "complete-bcs-english-grammar-mastery");
      expect(course.imageUrl, "https://lokkha.com/uploads/courses/eng.jpg");
      expect(course.resolvedImageUrl,
          "https://lokkha.com/uploads/courses/eng.jpg");
      expect(course.lifetimeAccess, isTrue);
      expect(course.accessExpiry, isNull);
      expect(course.isExpired, isFalse);
      expect(course.validityBadgeText, "লাইফটাইম");
      expect(course.enrolledAt, DateTime(2026, 8, 15, 12, 0, 0));

      // Test backward compatibility getters
      expect(course.id, 5);
      expect(course.course.title, "Complete BCS English Grammar Mastery");
      expect(course.image, "https://lokkha.com/uploads/courses/eng.jpg");
      expect(response.packages.length, 1);
      expect(response.items.length, 1);
      expect(response.status, isTrue);
    });

    test('Parses expiring course with remaining days', () {
      final json = {
        "enrollment_id": 20,
        "course_id": 8,
        "title": "Primary Teacher Exam Batch",
        "slug": "primary-teacher-batch",
        "image_url": "/courses/primary.jpg",
        "lifetime_access": false,
        "access_expiry": "2026-11-20 00:00:00",
        "remaining_days": 5,
        "is_expired": false,
        "enrolled_at": "2026-09-01 10:00:00"
      };

      final course = EnrolledCourseItem.fromJson(json);

      expect(course.lifetimeAccess, isFalse);
      expect(course.isExpired, isFalse);
      expect(course.remainingDays, 5);
      expect(course.isExpiringSoon, isTrue);
      expect(course.validityBadgeText, "5 দিন বাকি");
      expect(course.resolvedImageUrl.contains('/courses/primary.jpg'), isTrue);
    });

    test('Parses expired course correctly', () {
      final json = {
        "enrollment_id": 21,
        "course_id": 9,
        "title": "Expired Course",
        "lifetime_access": false,
        "access_expiry": "2026-01-01 00:00:00",
        "is_expired": true,
      };

      final course = EnrolledCourseItem.fromJson(json);

      expect(course.isExpired, isTrue);
      expect(course.validityBadgeText, "মেয়াদ শেষ");
    });

    test('Parses legacy packages fallback structure', () {
      final legacyJson = {
        "status": true,
        "packages": [
          {
            "id": 101,
            "course_id": 42,
            "lifetime_access": 1,
            "course": {
              "id": 42,
              "title": "Legacy Bangla Course",
              "image": "courses/bangla.jpg",
            }
          }
        ]
      };

      final response = MyCourseModel.fromJson(legacyJson);
      expect(response.success, isTrue);
      expect(response.courses.length, 1);
      final item = response.courses.first;
      expect(item.enrollmentId, 101);
      expect(item.courseId, 42);
      expect(item.title, "Legacy Bangla Course");
      expect(item.lifetimeAccess, isTrue);
    });

    test('Endpoints contains userCourses as /api/v1/user/courses', () {
      expect(Endpoints.userCourses, '/api/v1/user/courses');
      expect(Endpoints.v1UserCourses, '/api/v1/user/courses');
      expect(Endpoints.myCourses, '/api/v1/user/courses');
    });
  });

  group('MyCoursesView Widget Tests', () {
    Widget buildTestWidget({required MyCoursesState state}) {
      return ProviderScope(
        overrides: [
          myCoursesNotifierProvider.overrideWith(
            () => _FakeMyCoursesNotifier(state),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: MyCoursesView(),
          ),
        ),
      );
    }

    testWidgets('Renders empty state when user has no enrolled courses',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          state: MyCoursesState(
            isLoading: false,
            model: MyCourseModel(success: true, courses: []),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('আমার কোর্স'), findsOneWidget);
      expect(find.text('কোনো কোর্স পাওয়া যায়নি'), findsOneWidget);
      expect(find.text('কোর্সগুলো দেখুন'), findsOneWidget);
    });

    testWidgets('Renders enrolled course card with lifetime badge and title',
        (tester) async {
      final course = EnrolledCourseItem(
        enrollmentId: 14,
        courseId: 5,
        title: "Complete BCS English Grammar Mastery",
        imageUrl: "https://lokkha.com/uploads/courses/eng.jpg",
        lifetimeAccess: true,
      );

      await tester.pumpWidget(
        buildTestWidget(
          state: MyCoursesState(
            isLoading: false,
            model: MyCourseModel(success: true, courses: [course]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('আমার কোর্স'), findsOneWidget);
      expect(find.text('Complete BCS English Grammar Mastery'), findsOneWidget);
      expect(find.text('লাইফটাইম'), findsOneWidget);
      expect(find.text('কোর্সটি দেখুন'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_fill), findsOneWidget);
    });

    testWidgets('Renders error state with retry button on error',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          state: MyCoursesState(
            isLoading: false,
            hasError: true,
            errorMessage: 'সার্ভার সংযোগে সমস্যা হয়েছে',
            model: MyCourseModel(courses: []),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('সার্ভার সংযোগে সমস্যা হয়েছে'), findsOneWidget);
      expect(find.text('আবার চেষ্টা করুন'), findsOneWidget);
    });
  });
}

class _FakeMyCoursesNotifier extends MyCoursesNotifier {
  final MyCoursesState _initialState;
  _FakeMyCoursesNotifier(this._initialState);

  @override
  MyCoursesState build() => _initialState;

  @override
  Future<void> fetchMyCourses({bool isRefresh = false}) async {}

  @override
  Future<void> loadMore() async {}
}
