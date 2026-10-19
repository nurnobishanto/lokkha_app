import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/course/data/models/course_details_model.dart';
import 'package:lokkha/features/course/data/models/v1_course_category_model.dart';
import 'package:lokkha/features/course/data/models/v1_courses_response.dart';
import 'package:lokkha/features/course/data/repositories/courses_repository_impl.dart';
import 'package:lokkha/features/course/domain/repositories/courses_repository.dart';
import 'package:lokkha/features/course/presentation/course_details/views/course_details_view.dart';
import 'package:lokkha/features/course/presentation/course_details/widgets/course_module_expansion.dart';
import 'package:lokkha/features/course/presentation/courses/views/courses_view.dart';
import 'package:lokkha/features/course/presentation/courses/widgets/custom_course_card.dart';
import 'package:lokkha/features/course/presentation/providers/course_notifier.dart';

class _MockCoursesRepository implements CoursesRepository {
  List<V1CourseCategoryModel> categoriesToReturn;
  V1CoursesResponse coursesResponseToReturn;
  CourseDetailsModel? courseDetailsToReturn;
  bool shouldThrow;

  _MockCoursesRepository({
    this.categoriesToReturn = const [],
    V1CoursesResponse? coursesResponse,
    this.courseDetailsToReturn,
    this.shouldThrow = false,
  }) : coursesResponseToReturn = coursesResponse ?? const V1CoursesResponse();

  int? lastRequestedCategoryId;
  String? lastRequestedSearch;

  @override
  Future<List<V1CourseCategoryModel>> getCourseCategories() async {
    if (shouldThrow) throw Exception('Network error');
    return categoriesToReturn;
  }

  @override
  Future<V1CoursesResponse> getCourses({
    int? categoryId,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    if (shouldThrow) throw Exception('Failed to fetch courses');
    lastRequestedCategoryId = categoryId;
    lastRequestedSearch = search;
    return coursesResponseToReturn;
  }

  @override
  Future<CourseDetailsModel?> getCourseDetails(int courseId) async {
    if (shouldThrow) throw Exception('Course details error');
    return courseDetailsToReturn;
  }
}

class _FakeRestClient extends RestClient {
  final Map<String, dynamic>? Function(String path, Map<String, dynamic>? queryParams)? onGet;

  _FakeRestClient({this.onGet});

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
  }) async {
    final data = onGet?.call(path, queryParameters);
    return Response<T>(
      data: data as T?,
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleCategoriesJson = {
    "success": true,
    "message": "Course categories retrieved successfully.",
    "data": [
      {
        "id": 3,
        "title": "BCS",
        "slug": "bcs",
        "description": null,
        "image_url": null,
        "courses_count": 1
      },
      {
        "id": 4,
        "title": "Primary",
        "slug": "primary",
        "description": null,
        "image_url": null,
        "courses_count": 3
      },
      {
        "id": 5,
        "title": "NTRCA",
        "slug": "ntrca",
        "description": null,
        "image_url": null,
        "courses_count": 2
      }
    ]
  };

  final sampleCoursesJson = {
    "success": true,
    "message": "Courses retrieved successfully.",
    "data": {
      "items": [
        {
          "id": 12,
          "title": "১৯ তম নিবন্ধন পরীক্ষা-স্কুল পর্যায়",
          "slug": "19-nibndhn-preeksha-skul-przay",
          "category": {
            "id": 5,
            "title": "NTRCA",
            "slug": "ntrca"
          },
          "image_url": "https://lokkha.com/uploads/files/shares/exam/school.jpeg",
          "duration": "120 days",
          "access_duration_text": "200 Days",
          "lifetime_access": false,
          "is_exam_batch": false,
          "featured": false,
          "is_upcoming": false,
          "is_ongoing": true,
          "pricing": {
            "regular_price": 500,
            "sale_price": 299,
            "is_free": false,
            "discount_amount": 201,
            "discount_percent": 40,
            "currency": "BDT"
          },
          "stats": {
            "modules_count": 0,
            "items_count": 0,
            "enrolled_students": 15,
            "average_rating": 0,
            "total_reviews": 0
          },
          "teachers_summary": [
            {
              "id": 2,
              "name": "লক্ষ্য",
              "designation": "All",
              "image_url": null
            }
          ],
          "is_enrolled": false
        },
        {
          "id": 8,
          "title": "১৯তম নিবন্ধন পরীক্ষা কলেজ পর্যায়",
          "slug": "ntrca-college",
          "category": {
            "id": 5,
            "title": "NTRCA",
            "slug": "ntrca"
          },
          "image_url": "https://lokkha.com/uploads/files/shares/Paid Exam/college.jpeg",
          "duration": null,
          "access_duration_text": "Lifetime",
          "lifetime_access": true,
          "is_exam_batch": false,
          "featured": false,
          "is_upcoming": false,
          "is_ongoing": true,
          "pricing": {
            "regular_price": 500,
            "sale_price": 299,
            "is_free": false,
            "discount_amount": 201,
            "discount_percent": 40,
            "currency": "BDT"
          },
          "stats": {
            "modules_count": 8,
            "items_count": 22,
            "enrolled_students": 25,
            "average_rating": 4.8,
            "total_reviews": 12
          },
          "teachers_summary": [],
          "is_enrolled": false
        }
      ],
      "meta": {
        "current_page": 1,
        "last_page": 1,
        "per_page": 20,
        "total": 2,
        "has_more": false
      }
    }
  };

  group('V1 Course Clean Architecture Models Tests', () {
    test('V1CourseCategoryModel parses category list successfully', () {
      final list = (sampleCategoriesJson['data'] as List)
          .map((e) => V1CourseCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(list.length, 3);
      expect(list[0].id, 3);
      expect(list[0].title, 'BCS');
      expect(list[0].coursesCount, 1);

      expect(list[2].id, 5);
      expect(list[2].title, 'NTRCA');
      expect(list[2].coursesCount, 2);
    });

    test('V1CoursesResponse & V1CourseModel parse pricing, stats & formatting correctly', () {
      final response = V1CoursesResponse.fromJson(sampleCoursesJson);
      expect(response.success, isTrue);
      expect(response.items.length, 2);

      final course1 = response.items[0];
      expect(course1.id, 12);
      expect(course1.title, '১৯ তম নিবন্ধন পরীক্ষা-স্কুল পর্যায়');
      expect(course1.category?.title, 'NTRCA');
      expect(course1.category?.id, 5);
      expect(course1.pricing.regularPrice, 500.0);
      expect(course1.pricing.salePrice, 299.0);
      expect(course1.pricing.discountPercent, 40);
      expect(course1.pricing.discountAmount, 201.0);
      expect(course1.displayRegularPrice, '500');
      expect(course1.displaySalePrice, '299');
      // When average_rating is 0, defaults to '5'
      expect(course1.displayRating, '5');

      final course2 = response.items[1];
      expect(course2.id, 8);
      expect(course2.lifetimeAccess, isTrue);
      expect(course2.stats.averageRating, 4.8);
      expect(course2.displayRating, '4.8');

      // Legacy model conversion compatibility
      final legacyModel = response.toLegacyCoursesModel();
      expect(legacyModel.courses?.data?.length, 2);
      expect(legacyModel.courses?.data?[0].title, course1.title);
    });
  });

  group('CoursesRepositoryImpl Unit Tests', () {
    test('getCourseCategories calls correct endpoint and maps data', () async {
      final fakeClient = _FakeRestClient(
        onGet: (path, queryParams) {
          if (path == Endpoints.v1CourseCategories) {
            return sampleCategoriesJson;
          }
          return null;
        },
      );

      final repo = CoursesRepositoryImpl(client: fakeClient);
      final categories = await repo.getCourseCategories();

      expect(categories.length, 3);
      expect(categories[0].title, 'BCS');
      expect(categories[2].title, 'NTRCA');
    });

    test('getCourses sends categoryId query param and maps response', () async {
      int? capturedCategoryId;
      int? capturedCourseCategoryId;
      final fakeClient = _FakeRestClient(
        onGet: (path, queryParams) {
          if (path == Endpoints.v1Courses) {
            capturedCategoryId = queryParams?['category_id'] as int?;
            capturedCourseCategoryId = queryParams?['course_category_id'] as int?;
            return sampleCoursesJson;
          }
          return null;
        },
      );

      final repo = CoursesRepositoryImpl(client: fakeClient);
      final response = await repo.getCourses(categoryId: 5);

      expect(capturedCategoryId, 5);
      expect(capturedCourseCategoryId, 5);
      expect(response.success, isTrue);
      expect(response.items.length, 2);
    });

    test('getCourses defensively filters items if backend returns mismatched categories', () async {
      final mixedCoursesJson = {
        "success": true,
        "message": "Courses retrieved successfully.",
        "data": {
          "items": [
            {
              "id": 13,
              "title": "GK Power Course",
              "category": {"id": 9, "title": "University Admission Test"}
            },
            {
              "id": 12,
              "title": "NTRCA Course",
              "category": {"id": 5, "title": "NTRCA"}
            }
          ]
        }
      };

      final fakeClient = _FakeRestClient(
        onGet: (path, queryParams) => mixedCoursesJson,
      );

      final repo = CoursesRepositoryImpl(client: fakeClient);
      final response = await repo.getCourses(categoryId: 5);

      expect(response.items.length, 1);
      expect(response.items[0].id, 12);
    });
  });

  group('CoursesNotifier State Management Tests', () {
    test('CoursesNotifier fetches categories and filtered courses on build', () async {
      final parsedCategories = (sampleCategoriesJson['data'] as List)
          .map((e) => V1CourseCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final parsedCoursesResponse = V1CoursesResponse.fromJson(sampleCoursesJson);

      final mockRepo = _MockCoursesRepository(
        categoriesToReturn: parsedCategories,
        coursesResponse: parsedCoursesResponse,
      );

      final container = ProviderContainer(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      // Trigger build
      final state = container.read(coursesNotifierProvider(5));
      expect(state.selectedCategoryId, 5);

      // Allow microtask to execute
      await Future<void>.delayed(Duration.zero);

      final updatedState = container.read(coursesNotifierProvider(5));
      expect(updatedState.isLoading, isFalse);
      expect(updatedState.hasError, isFalse);
      expect(updatedState.courses.length, 2);
      expect(updatedState.categories.length, 3);
      expect(mockRepo.lastRequestedCategoryId, 5);
    });

    test('CoursesNotifier handles repository errors gracefully', () async {
      final mockRepo = _MockCoursesRepository(shouldThrow: true);

      final container = ProviderContainer(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(coursesNotifierProvider(5));
      await Future<void>.delayed(Duration.zero);

      final state = container.read(coursesNotifierProvider(5));
      expect(state.isLoading, isFalse);
      expect(state.hasError, isTrue);
      expect(state.errorMessage, isNotNull);
    });
  });

  group('CoursesView & CustomCourseCard Widget Tests', () {
    testWidgets('Renders 2-column grid with cards matching screenshot design', (tester) async {
      final parsedCategories = (sampleCategoriesJson['data'] as List)
          .map((e) => V1CourseCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final parsedCoursesResponse = V1CoursesResponse.fromJson(sampleCoursesJson);

      final mockRepo = _MockCoursesRepository(
        categoriesToReturn: parsedCategories,
        coursesResponse: parsedCoursesResponse,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coursesRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) => const MaterialApp(
              home: CoursesView(
                categoryId: 5,
                categoryName: 'NTRCA',
              ),
            ),
          ),
        ),
      );

      // Let microtask run
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Verify AppBar Title & Back Button
      expect(find.text('NTRCA'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      // 2. Verify Courses Cards in Grid
      expect(find.byType(CustomCourseCard), findsNWidgets(2));
      expect(find.text('১৯ তম নিবন্ধন পরীক্ষা-স্কুল পর্যায়'), findsOneWidget);
      expect(find.text('১৯তম নিবন্ধন পরীক্ষা কলেজ পর্যায়'), findsOneWidget);

      // 3. Verify Price Formatting (regular strike-through and sale price)
      expect(find.text('৳500'), findsNWidgets(2));
      expect(find.text('৳299'), findsNWidgets(2));

      // 4. Verify Star Rating
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(2));
    });

    testWidgets('Renders empty state when no courses exist in category', (tester) async {
      final mockRepo = _MockCoursesRepository(
        categoriesToReturn: [],
        coursesResponse: const V1CoursesResponse(
          success: true,
          items: [],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coursesRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) => const MaterialApp(
              home: CoursesView(
                categoryId: 6,
                categoryName: 'Bank Preperation',
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Empty State widgets
      expect(find.text('Bank Preperation'), findsOneWidget);
      expect(find.text('কোনো কোর্স পাওয়া যায়নি'), findsOneWidget);
      expect(find.text('অন্যান্য ক্যাটাগরিগুলো দেখুন'), findsOneWidget);
      expect(find.byIcon(Icons.school_outlined), findsOneWidget);
    });
  });

  final sampleCourse6DetailsJson = {
    "success": true,
    "message": "Course details retrieved successfully.",
    "data": {
      "id": 6,
      "title": "প্রধান শিক্ষক নিয়োগ পরীক্ষা -১",
      "slug": "prdhan-sikshk-niyog-preeksha-2",
      "category": {
        "id": 4,
        "title": "Primary",
        "slug": "primary"
      },
      "image_url": "https://lokkha.com/uploads/files/shares/Paid Exam/Primary.jpg",
      "routine_file_url": "https://lokkha.com/uploads/files/shares/Paid Exam/Routine.pdf",
      "details": "<p>প্রধান শিক্ষক নিয়োগ পরীক্ষা প্রস্তুতি</p>",
      "duration": "120 days",
      "access_duration": 50,
      "access_duration_text": "আজীবন মেয়াদ (Lifetime Access)",
      "lifetime_access": true,
      "is_exam_batch": true,
      "publish_date": "2025-09-20",
      "pricing": {
        "regular_price": 300,
        "sale_price": 150,
        "is_free": false,
        "discount_amount": 150,
        "discount_percent": 50,
        "currency": "BDT",
        "currency_symbol": "৳"
      },
      "stats": {
        "total_modules": 8,
        "total_items": 76,
        "enrolled_students": 33,
        "average_rating": 5,
        "total_reviews": 1
      },
      "instructors": [
        {
          "id": 2,
          "name": "লক্ষ্য",
          "designation": "All",
          "institution": "All",
          "bio": "Experience: 10 years",
          "image_url": ""
        }
      ],
      "syllabus": [
        {
          "id": 8,
          "title": "বাংলা",
          "type": "current",
          "description": null,
          "order": 1,
          "items_count": 10,
          "items": [
            {
              "id": 46,
              "title": "পরীক্ষা- 01 বাংলা  ব্যাকরণ",
              "type": ["exam"],
              "is_free": false,
              "order": 1,
              "duration": null,
              "has_exam": true,
              "exam_id": 345
            }
          ]
        },
        {
          "id": 9,
          "title": "ইংরেজী",
          "type": "current",
          "description": null,
          "order": 2,
          "items_count": 10,
          "items": [
            {
              "id": 12,
              "title": "ইংরেজী ১",
              "type": ["exam"],
              "is_free": true,
              "order": 0,
              "duration": null,
              "has_exam": true,
              "exam_id": 284
            }
          ]
        }
      ],
      "user_access": {
        "is_authenticated": false,
        "is_enrolled": false,
        "enrollment": null
      }
    }
  };

  group('CourseDetails V1 Clean Architecture Tests', () {
    test('CourseDetailsModel accurately parses V1 course 6 details with syllabus', () {
      final model = CourseDetailsModel.fromJson(sampleCourse6DetailsJson);
      expect(model.status, isTrue);
      expect(model.course, isNotNull);

      final course = model.course!;
      expect(course.id, 6);
      expect(course.title, 'প্রধান শিক্ষক নিয়োগ পরীক্ষা -১');
      expect(course.courseCategoryId, 4);
      expect(course.image, 'https://lokkha.com/uploads/files/shares/Paid Exam/Primary.jpg');
      expect(course.routineFile, 'https://lokkha.com/uploads/files/shares/Paid Exam/Routine.pdf');
      expect(course.regularPrice, '300');
      expect(course.salePrice, '150');
      expect(course.usersCount, 33);
      expect(course.itemsCount, 76);
      expect(course.modulesCount, 8);
      expect(course.lifetimeAccess, isTrue);
      expect(course.isExamBatch, isTrue);
      expect(course.isEnrolled, isFalse);

      // Syllabus & Modules parsing
      expect(course.modules?.length, 2);
      expect(course.modules?[0].title, 'বাংলা');
      expect(course.modules?[0].items?.length, 1);
      expect(course.modules?[0].items?[0].title, 'পরীক্ষা- 01 বাংলা  ব্যাকরণ');
      expect(course.modules?[0].items?[0].hasExam, isTrue);
      expect(course.modules?[0].items?[0].examId, 345);
      expect(course.modules?[0].items?[0].isFree, isFalse);

      expect(course.modules?[1].title, 'ইংরেজী');
      expect(course.modules?[1].items?[0].isFree, isTrue);

      // Instructors
      expect(course.teachers?.length, 1);
      expect(course.teachers?[0].name, 'লক্ষ্য');
    });

    test('CoursesRepositoryImpl getCourseDetails fetches and parses v1 endpoint', () async {
      final fakeClient = _FakeRestClient(
        onGet: (path, queryParams) {
          if (path == '/api/v1/courses/6') {
            return sampleCourse6DetailsJson;
          }
          return null;
        },
      );

      final repo = CoursesRepositoryImpl(client: fakeClient);
      final details = await repo.getCourseDetails(6);

      expect(details, isNotNull);
      expect(details?.course?.id, 6);
      expect(details?.course?.title, 'প্রধান শিক্ষক নিয়োগ পরীক্ষা -১');
    });

    testWidgets('CourseDetailsView renders course 6 with syllabus modules and enrollment CTA', (tester) async {
      final parsedDetails = CourseDetailsModel.fromJson(sampleCourse6DetailsJson);
      final mockRepo = _MockCoursesRepository(
        courseDetailsToReturn: parsedDetails,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coursesRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) => const MaterialApp(
              home: CourseDetailsView(courseId: 6),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Title in AppBar & Body
      expect(find.text('প্রধান শিক্ষক নিয়োগ পরীক্ষা -১'), findsWidgets);

      // 2. Quick info row
      expect(find.text('সাধারণ তথ্য'), findsOneWidget);
      expect(find.text('33 জন ভর্তি'), findsOneWidget);
      expect(find.text('76 টি পরীক্ষা'), findsOneWidget);
      expect(find.text('আজীবন মেয়াদ'), findsOneWidget);

      // 3. Routine
      expect(find.text('কোর্স রুটিন'), findsOneWidget);
      expect(find.text('রুটিন দেখুন (PDF / Image)'), findsOneWidget);

      // 4. Syllabus / Exam Modules
      expect(find.text('কোর্স সূচি / পরীক্ষা সমূহ'), findsOneWidget);
      expect(find.byType(CourseModuleExpansion), findsNWidgets(2));
      expect(find.text('বাংলা'), findsOneWidget);
      expect(find.text('ইংরেজী'), findsOneWidget);

      // 5. Bottom enrollment bar
      expect(find.text('৳150'), findsOneWidget);
      expect(find.text('৳300'), findsOneWidget);
      expect(find.text('এখনই ভর্তি হোন'), findsOneWidget);
    });

    testWidgets('CourseDetailsView renders "শেখা শুরু করুন" and unlocks modules when user is enrolled',
        (tester) async {
      final enrolledJson = Map<String, dynamic>.from(sampleCourse6DetailsJson);
      enrolledJson['data'] = Map<String, dynamic>.from(sampleCourse6DetailsJson['data'] as Map);
      enrolledJson['data']['user_access'] = {
        "is_authenticated": true,
        "is_enrolled": true,
        "enrollment": {"id": 60}
      };
      final parsedDetails = CourseDetailsModel.fromJson(enrolledJson);
      final mockRepo = _MockCoursesRepository(
        courseDetailsToReturn: parsedDetails,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coursesRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) => const MaterialApp(
              home: CourseDetailsView(courseId: 6, initialIsEnrolled: true),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Should show "শেখা শুরু করুন" button
      expect(find.text('শেখা শুরু করুন'), findsOneWidget);

      // 2. Should NOT show "এখনই ভর্তি হোন" button
      expect(find.text('এখনই ভর্তি হোন'), findsNothing);
    });
  });
}

