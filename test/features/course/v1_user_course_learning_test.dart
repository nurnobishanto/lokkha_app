import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/features/course/course.dart';

void main() {
  const v1UserCoursePayload = {
    "success": true,
    "message": "Course enrollment details retrieved successfully.",
    "data": {
      "enrollment_id": 65,
      "course_id": 6,
      "title": "প্রধান শিক্ষক নিয়োগ পরীক্ষা -১",
      "slug": "prdhan-sikshk-niyog-preeksha-2",
      "image_url": "https://lokkha.com/uploads/files/shares/Paid Exam/Primary course cover (1).jpg",
      "lifetime_access": true,
      "access_expiry": null,
      "is_expired": false,
      "days_remaining": null,
      "enrolled_at": "2026-10-19 17:20:23",
      "progress_percent": 9,
      "total_lessons": 0,
      "classroom_url": "https://lokkha.com/api/v1/user/learning/6",
      "details": "<div class=\"container py-5\"><h2>প্রধান শিক্ষক নিয়োগ পরীক্ষা</h2></div>",
      "duration": "120 days",
      "routine_file_url": "https://lokkha.com/uploads/files/shares/Paid Exam/প্রধান শিক্ষক নিয়োগ পরীক্ষা Routin -03.pdf",
      "community_links": {
        "whatsapp_group": null,
        "telegram_group": null,
        "facebook_group": "https://www.facebook.com/groups/lokkha",
        "zoom_link": null,
        "meet_link": "https://www.facebook.com/lokkhabd"
      },
      "teachers": [
        {
          "id": 2,
          "name": "লক্ষ্য",
          "designation": "All",
          "image_url": null
        }
      ],
      "resume_item_id": 46
    }
  };

  const v1UserLearningPayload = {
    "success": true,
    "message": "Classroom content loaded successfully.",
    "data": {
      "course": {
        "id": 6,
        "title": "প্রধান শিক্ষক নিয়োগ পরীক্ষা -১",
        "slug": "prdhan-sikshk-niyog-preeksha-2",
        "routine_file_url": "https://lokkha.com/uploads/files/shares/Paid Exam/প্রধান শিক্ষক নিয়োগ পরীক্ষা Routin -03.pdf",
        "progress_percent": 9,
        "total_lessons": 76,
        "completed_lessons": 7,
        "is_completed": false
      },
      "current_item": {
        "id": 46,
        "module_id": 8,
        "module_title": "বাংলা",
        "title": "পরীক্ষা- 01 বাংলা  ব্যাকরণ",
        "type": [
          "exam"
        ],
        "is_free": false,
        "is_completed": true,
        "last_watched_second": 0,
        "image_url": null,
        "youtube_video_id": null,
        "youtube_video_url": null,
        "video_url": null,
        "pdf_url": null,
        "file_url": null,
        "external_url": null,
        "button_name": null,
        "details_html": "<span style=\"font-family: Inter;\"><b>বাংলা ভাষা + বাংলা সাহিত্যের ইতিহাস ও ব্যাকরণ</b></span>",
        "exam_info": {
          "exam_id": 345,
          "title": "বাংলা ভাষা + বাংলা সাহিত্যের ইতিহাস ও ব্যাকরণ",
          "duration": 15,
          "positive_mark": 1,
          "negative_mark": 0.5,
          "has_attempted": true,
          "latest_result": {
            "result_id": 14746,
            "score": -4,
            "score_percent": -20,
            "result_status": "Failed",
            "total_questions": 20,
            "correct_answers": 0,
            "incorrect_answers": 8,
            "attempted_at": "2026-10-19 17:20:57"
          },
          "portal_url": "https://lokkha.com/api/v1/user/exams/345"
        }
      },
      "navigation": {
        "prev_item_id": null,
        "next_item_id": 47
      },
      "syllabus": [
        {
          "module_id": 8,
          "title": "বাংলা",
          "type": "current",
          "description": null,
          "order": 1,
          "items": [
            {
              "id": 46,
              "title": "পরীক্ষা- 01 বাংলা  ব্যাকরণ",
              "type": [
                "exam"
              ],
              "is_free": false,
              "order": 1,
              "is_active": true,
              "is_completed": true,
              "has_exam": true
            },
            {
              "id": 47,
              "title": "পরীক্ষা-02  বাংলা   ব্যাকরণ",
              "type": [
                "exam"
              ],
              "is_free": false,
              "order": 2,
              "is_active": false,
              "is_completed": false,
              "has_exam": true
            }
          ]
        },
        {
          "module_id": 9,
          "title": "ইংরেজী",
          "type": "current",
          "description": null,
          "order": 2,
          "items": [
            {
              "id": 12,
              "title": "ইংরেজী ১",
              "type": [
                "exam"
              ],
              "is_free": false,
              "order": 0,
              "is_active": false,
              "is_completed": false,
              "has_exam": true
            }
          ]
        }
      ]
    }
  };

  group('V1 User Course & Learning Model Tests', () {
    test('1. CourseDetailsModel parses V1 user course enrollment payload', () {
      final model = CourseDetailsModel.fromJson(v1UserCoursePayload);
      expect(model.status, isTrue);
      expect(model.course, isNotNull);

      final course = model.course!;
      expect(course.id, equals(6));
      expect(course.title, equals("প্রধান শিক্ষক নিয়োগ পরীক্ষা -১"));
      expect(course.enrollmentId, equals(65));
      expect(course.isEnrolled, isTrue);
      expect(course.lifetimeAccess, isTrue);
      expect(course.progressPercent, equals(9));
      expect(course.resumeItemId, equals(46));
      expect(course.classroomUrl, equals("https://lokkha.com/api/v1/user/learning/6"));
      expect(course.routineFile, contains("Routin -03.pdf"));
      expect(course.facebookGroup, equals("https://www.facebook.com/groups/lokkha"));
      expect(course.meetLink, equals("https://www.facebook.com/lokkhabd"));
      expect(course.teachers?.length, equals(1));
      expect(course.teachers?.first.name, equals("লক্ষ্য"));
    });

    test('2. CourseLearningModel parses V1 classroom content and exam_info', () {
      final learning = CourseLearningModel.fromJson(v1UserLearningPayload);
      expect(learning.status, isTrue);
      expect(learning.data, isNotNull);

      final data = learning.data!;
      expect(data.course?.id, equals(6));
      expect(data.course?.progressPercent, equals(9));
      expect(data.course?.totalLessons, equals(76));
      expect(data.course?.completedLessons, equals(7));

      // Navigation test
      expect(data.prevItemId, isNull);
      expect(data.nextItemId, equals(47));

      // Syllabus test
      expect(data.syllabus.length, equals(2));
      expect(data.syllabus.first.id, equals(8));
      expect(data.syllabus.first.title, equals("বাংলা"));
      expect(data.syllabus.first.items?.length, equals(2));
      expect(data.syllabus.first.items?.first.hasExam, isTrue);
      expect(data.syllabus.first.items?.first.isCompleted, isTrue);

      // Current Item & Exam Info test
      final currentItem = data.currentItem;
      expect(currentItem, isNotNull);
      expect(currentItem!.id, equals(46));
      expect(currentItem.hasExam, isTrue);
      expect(currentItem.examId, equals(345));
      expect(currentItem.isCompleted, isTrue);
      expect(currentItem.moduleTitle, equals("বাংলা"));

      final examInfo = currentItem.examInfo;
      expect(examInfo, isNotNull);
      expect(examInfo!.examId, equals(345));
      expect(examInfo.duration, equals(15));
      expect(examInfo.positiveMark, equals(1));
      expect(examInfo.negativeMark, equals(0.5));
      expect(examInfo.hasAttempted, isTrue);
      expect(examInfo.portalUrl, equals("https://lokkha.com/api/v1/user/exams/345"));

      final result = examInfo.latestResult;
      expect(result, isNotNull);
      expect(result!.resultId, equals(14746));
      expect(result.score, equals(-4));
      expect(result.scorePercent, equals(-20));
      expect(result.resultStatus, equals("Failed"));
      expect(result.totalQuestions, equals(20));
      expect(result.correctAnswers, equals(0));
      expect(result.incorrectAnswers, equals(8));
    });
  });

  group('V1 Classroom UI & Widgets Tests', () {
    testWidgets('3. CourseLearnBody renders V1 classroom exam card with score, negative mark, and actions',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final learning = CourseLearningModel.fromJson(v1UserLearningPayload);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: CourseLearnBody(
                  model: learning,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verified Module and Exam titles
      expect(find.text("বাংলা"), findsOneWidget);
      expect(find.text("বাংলা ভাষা + বাংলা সাহিত্যের ইতিহাস ও ব্যাকরণ"), findsWidgets);

      // Verified status and metrics
      expect(find.text("সম্পন্ন"), findsOneWidget);
      expect(find.text("15 মিনিট"), findsOneWidget);
      expect(find.text("20 টি প্রশ্ন"), findsOneWidget);
      expect(find.text("নেগেটিভ: -0.5"), findsOneWidget);

      // Verified latest result banner
      expect(find.text("সর্বশেষ ফলাফল: Failed"), findsOneWidget);
      expect(find.text("প্রাপ্ত নম্বর: -4"), findsOneWidget);
      expect(find.text("সঠিক: 0 | ভুল: 8"), findsOneWidget);

      // Verified Interactive action buttons
      expect(find.text("আবার পরীক্ষা দিন"), findsOneWidget);
      expect(find.text("ফলাফল"), findsOneWidget);
    });

    testWidgets('4. CourseDetailsView renders enrolled progress, routine button, and smart resume button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final courseModel = CourseDetailsModel.fromJson(v1UserCoursePayload);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            courseDetailsNotifierProvider(6).overrideWith(() => _FakeCourseDetailsNotifier(courseModel)),
            myCoursesNotifierProvider.overrideWith(() => _FakeMyCoursesNotifier()),
          ],
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) => const MaterialApp(
              home: CourseDetailsView(courseId: 6, initialIsEnrolled: true),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Enrolled banner & progress
      expect(find.text("আপনার এনরোলমেন্ট সক্রিয়"), findsOneWidget);
      expect(find.text("9% সম্পন্ন"), findsOneWidget);
      expect(find.text("লাইফটাইম"), findsOneWidget);

      // Routine file button
      expect(find.text("কোর্স রুটিন"), findsOneWidget);
      expect(find.text("রুটিন দেখুন (PDF / Image)"), findsOneWidget);

      // Community links
      expect(find.text("কমিউনিটি ও ক্লাস লিংক"), findsOneWidget);
      expect(find.text("ফেসবুক গ্রুপ"), findsOneWidget);
      expect(find.text("লাইভ ক্লাস (Meet)"), findsOneWidget);

      // Smart resume button
      expect(find.text("পড়া চালিয়ে যান"), findsOneWidget);
    });
  });
}

class _FakeCourseDetailsNotifier extends CourseDetailsNotifier {
  final CourseDetailsModel fixedModel;
  _FakeCourseDetailsNotifier(this.fixedModel) : super(6);

  @override
  CourseDetailsState build() {
    return CourseDetailsState(model: fixedModel, isLoading: false);
  }

  @override
  Future<void> fetchCourseDetails(int id) async {}
}

class _FakeMyCoursesNotifier extends MyCoursesNotifier {
  @override
  MyCoursesState build() {
    return MyCoursesState(model: MyCourseModel.fromJson({}));
  }

  @override
  Future<void> fetchMyCourses({bool isRefresh = false}) async {}
}
