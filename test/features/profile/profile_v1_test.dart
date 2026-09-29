import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/features/profile/profile.dart';
import 'package:lokkha/features/home/data/models/dashboard_overview_model.dart';
import 'package:lokkha/shared/models/user.dart';

void main() {
  group('Profile V1 Models and Entities Tests', () {
    test('User model parses V1 Profile JSON correctly', () {
      final json = {
        "id": 42,
        "user_id": "260900042",
        "name": "Arif Ahmed",
        "phone": "01712345678",
        "email": "arif@gmail.com",
        "photo_url": "https://lokkha.com/uploads/profile/user_66ed.jpg",
        "gender": "male",
        "date_of_birth": "1998-05-14",
        "formatted_dob": "14 May, 1998",
        "occupation": "Student",
        "organization": "Dhaka University",
        "address_line_1": "Flat 4A, Green Road",
        "address_line_2": null,
        "city": "Dhaka",
        "state": "Dhaka",
        "zip_code": "1205",
        "country": "Bangladesh",
        "referral_code": "LK9A8B7C",
        "referral_link": "https://lokkha.com/register?ref=LK9A8B7C",
        "reward_points": 140,
        "has_active_subscription": true
      };

      final user = User.fromJson(json);

      expect(user.id, 42);
      expect(user.userId, "260900042");
      expect(user.name, "Arif Ahmed");
      expect(user.phone, "01712345678");
      expect(user.email, "arif@gmail.com");
      expect(user.photoUrl, "https://lokkha.com/uploads/profile/user_66ed.jpg");
      expect(user.formattedDob, "14 May, 1998");
      expect(user.occupation, "Student");
      expect(user.organization, "Dhaka University");
      expect(user.addressLine1, "Flat 4A, Green Road");
      expect(user.city, "Dhaka");
      expect(user.zipCode, "1205");
      expect(user.referralCode, "LK9A8B7C");
      expect(user.rewardPoints, 140);
      expect(user.hasActiveSubscription, true);
      expect(user.isSubscribed, true);
    });

    test('UserDevicesData and DeviceSessionModel parse V1 Devices JSON correctly', () {
      final json = {
        "active_devices": [
          {
            "id": 81,
            "device_type": "mobile",
            "device_name": "Samsung Galaxy S23",
            "platform": "android",
            "platform_category": "android",
            "platform_category_label": "Android (Mobile App)",
            "ip_address": "103.145.12.8",
            "is_active": true,
            "is_current": true,
            "login_at": "2026-09-21 09:30:00",
            "last_active_at": "2026-09-21 10:45:00"
          },
          {
            "id": 74,
            "device_type": "desktop",
            "device_name": "Windows PC",
            "platform": "windows",
            "platform_category": "windows",
            "platform_category_label": "Windows / PC",
            "ip_address": "103.145.12.8",
            "is_active": true,
            "is_current": false,
            "login_at": "2026-09-20 18:00:00",
            "last_active_at": "2026-09-20 20:15:00"
          }
        ],
        "active_count": 2,
        "max_allowed": 3,
        "history": {
          "items": [],
          "meta": {"current_page": 1, "last_page": 2, "per_page": 15, "total": 19}
        }
      };

      final data = UserDevicesData.fromJson(json);

      expect(data.activeCount, 2);
      expect(data.maxAllowed, 3);
      expect(data.activeDevices.length, 2);

      final d1 = data.activeDevices.first;
      expect(d1.id, 81);
      expect(d1.deviceName, "Samsung Galaxy S23");
      expect(d1.platform, "android");
      expect(d1.platformCategoryLabel, "Android (Mobile App)");
      expect(d1.isCurrent, true);
      expect(d1.isActive, true);

      final d2 = data.activeDevices[1];
      expect(d2.id, 74);
      expect(d2.deviceName, "Windows PC");
      expect(d2.platform, "windows");
      expect(d2.isCurrent, false);
    });

    test('DashboardOverviewModel parses V1 Dashboard Overview JSON correctly', () {
      final json = {
        "success": true,
        "message": "User dashboard overview retrieved successfully.",
        "data": {
          "user": {
            "id": 42,
            "user_id": "260900042",
            "name": "Arif Ahmed",
            "phone": "01712345678",
            "email": "arif@gmail.com",
            "photo_url": "https://lokkha.com/uploads/profile/user_66ed.jpg"
          },
          "active_subscription": {
            "id": 12,
            "package_id": 4,
            "package_name": "BCS & Bank Combo 6 Months",
            "subscribed_at": "2026-06-01 10:30:00",
            "expires_at": "2026-12-31 23:59:59",
            "is_trial": false,
            "days_left": 101,
            "status": "active"
          },
          "counts": {
            "total_orders": 5,
            "total_exams": 24,
            "total_courses": 2,
            "total_packages": 3,
            "total_self_exams": 18,
            "total_contests": 8
          },
          "performance": {
            "total_questions_answered": 1200,
            "total_correct_answers": 960,
            "total_incorrect_answers": 240,
            "accuracy_rate": 80.0,
            "highest_accuracy": 95.0,
            "chart": {
              "labels": ["Ex-1", "Ex-2"],
              "data": [75.0, 85.0]
            }
          },
          "referral": {
            "referral_code": "LK9A8B7C",
            "referral_link": "https://lokkha.com/register?ref=LK9A8B7C",
            "total_referrals": 6,
            "total_points": 600
          },
          "rewards": {
            "balance": 140
          }
        }
      };

      final overview = DashboardOverviewModel.fromJson(json);
      expect(overview.status, true);
      expect(overview.message, "User dashboard overview retrieved successfully.");
      expect(overview.data, isNotNull);

      final d = overview.data!;
      expect(d.user?.name, "Arif Ahmed");
      expect(d.user?.userId, "260900042");
      expect(d.user?.photoUrl, "https://lokkha.com/uploads/profile/user_66ed.jpg");

      expect(d.activeSubscription?.packageName, "BCS & Bank Combo 6 Months");
      expect(d.activeSubscription?.daysLeft, 101);
      expect(d.activeSubscription?.status, "active");

      expect(d.counts?.totalOrders, 5);
      expect(d.counts?.totalExams, 24);
      expect(d.counts?.totalCourses, 2);
      expect(d.counts?.totalPackages, 3);
      expect(d.counts?.totalSelfExams, 18);
      expect(d.counts?.totalContests, 8);

      expect(d.performance?.totalQuestionsAnswered, 1200);
      expect(d.performance?.totalCorrectAnswers, 960);
      expect(d.performance?.totalIncorrectAnswers, 240);
      expect(d.performance?.accuracyRate, 80.0);
      expect(d.performance?.highestAccuracy, 95.0);

      expect(d.referral?.referralCode, "LK9A8B7C");
      expect(d.referral?.totalReferrals, 6);
      expect(d.referral?.totalPoints, 600);

      expect(d.rewards?.balance, 140);
    });

    test('AppConstants.resolveUrl handles full URLs, relative paths, and UI avatars safely', () {
      expect(
        AppConstants.resolveUrl("https://ui-avatars.com/api/?name=was&color=7F9CF5&background=EBF4FF"),
        "https://ui-avatars.com/api/?name=was&color=7F9CF5&background=EBF4FF",
      );
      expect(
        AppConstants.resolveUrl("http://example.com/avatar.png"),
        "http://example.com/avatar.png",
      );
      expect(
        AppConstants.resolveUrl("uploads/profile/user_123.jpg"),
        "https://lokkha.com/uploads/profile/user_123.jpg",
      );
      expect(
        AppConstants.resolveUrl("/uploads/profile/user_123.jpg"),
        "https://lokkha.com/uploads/profile/user_123.jpg",
      );
      expect(
        AppConstants.resolveUrl("profile/user_123.jpg"),
        "https://lokkha.com/uploads/profile/user_123.jpg",
      );
      expect(AppConstants.resolveUrl(null), "");
      expect(AppConstants.resolveUrl(""), "");
    });

    test('ExamHistoryResponseModel and ExamHistoryModel parse V1 Exam History JSON correctly', () {
      final json = {
        "success": true,
        "message": "Exam history retrieved successfully.",
        "data": {
          "items": [
            {
              "id": 431,
              "exam_id": 18,
              "exam_title": "46th BCS Preliminary Mega Model Test",
              "is_practice": false,
              "total_questions": 200,
              "correct_answers": 150,
              "incorrect_answers": 30,
              "attempted": 180,
              "avoided": 20,
              "positive_mark": 1.0,
              "negative_mark": 0.5,
              "score": 135.0,
              "total_marks": 200.0,
              "score_percent": 67.5,
              "result_status": "Passed",
              "submitted_at": "2026-09-15 11:45:30"
            }
          ]
        },
        "meta": { "current_page": 1, "last_page": 3, "total": 24 }
      };

      final response = ExamHistoryResponseModel.fromJson(json);

      expect(response.currentPage, 1);
      expect(response.lastPage, 3);
      expect(response.total, 24);
      expect(response.items.length, 1);

      final item = response.items.first;
      expect(item.id, "#431");
      expect(item.rawId, 431);
      expect(item.numericId, 431);
      expect(item.examId, 18);
      expect(item.title, "46th BCS Preliminary Mega Model Test");
      expect(item.isPractice, false);
      expect(item.totalQuestions, 200);
      expect(item.correctCount, 150);
      expect(item.wrongCount, 30);
      expect(item.attempted, 180);
      expect(item.avoided, 20);
      expect(item.positiveMark, 1.0);
      expect(item.negativeMark, 0.5);
      expect(item.score, 135.0);
      expect(item.totalMarks, 200.0);
      expect(item.scorePercent, 67.5);
      expect(item.resultStatus, "Passed");
      expect(item.isPassed, true);
      expect(item.obtainedMark, "135");
      expect(item.status, "Passed (67.5%)");
      expect(item.date, "15 Sep, 2026 • 11:45 AM");
    });

    test('ExamReviewDetailModel parses question review JSON correctly', () {
      final json = {
        "success": true,
        "message": "Exam review retrieved successfully.",
        "data": {
          "exam": {
            "id": 431,
            "exam_id": 18,
            "exam_title": "46th BCS Preliminary Mega Model Test",
            "score": 135.0,
            "total_marks": 200.0,
            "total_questions": 200,
            "correct_answers": 150,
            "incorrect_answers": 30,
            "avoided": 20,
            "rank": 4,
            "time_taken": "45 মিনিট"
          },
          "questions": [
            {
              "question_number": 1,
              "question_text": "গণতন্ত্রের প্রাণ হলো-",
              "options": ["সরকার", "রাষ্ট্র", "সংবিধান", "নির্বাচন"],
              "correct_answer": 3,
              "student_answer": 3,
              "is_correct": true,
              "explanation": "গণতন্ত্রের মূল ভিত্তি এবং প্রাণ হলো অবাধ নির্বাচন।"
            },
            {
              "question_number": 2,
              "question_text": "স্থানীয় সরকার নয় কোনটি?",
              "options": [
                {"key": 1, "value": "জেলা পরিষদ", "is_correct": false},
                {"key": 2, "value": "উপজেলা প্রশাসন", "is_correct": true},
                {"key": 3, "value": "ইউনিয়ন পরিষদ", "is_correct": false},
                {"key": 4, "value": "সিটি কর্পোরেশন", "is_correct": false}
              ],
              "student_answer": null,
              "is_correct": false,
              "explanation": "উপজেলা প্রশাসন স্থানীয় প্রশাসনের অংশ, স্থানীয় সরকার নয়।"
            }
          ]
        }
      };

      final review = ExamReviewDetailModel.fromJson(json);

      expect(review.id, 431);
      expect(review.examId, 18);
      expect(review.examTitle, "46th BCS Preliminary Mega Model Test");
      expect(review.score, 135.0);
      expect(review.totalMarks, 200.0);
      expect(review.rank, 4);
      expect(review.timeTaken, "45 মিনিট");
      expect(review.questions.length, 2);

      final q1 = review.questions[0];
      expect(q1.questionNumber, 1);
      expect(q1.questionText, "গণতন্ত্রের প্রাণ হলো-");
      expect(q1.options.length, 4);
      expect(q1.correctOptionIndex, 3);
      expect(q1.userSelectedOptionIndex, 3);
      expect(q1.isCorrect, true);
      expect(q1.isAvoided, false);
      expect(q1.isWrong, false);
      expect(q1.explanation, "গণতন্ত্রের মূল ভিত্তি এবং প্রাণ হলো অবাধ নির্বাচন।");

      final q2 = review.questions[1];
      expect(q2.questionNumber, 2);
      expect(q2.questionText, "স্থানীয় সরকার নয় কোনটি?");
      expect(q2.correctOptionIndex, 1);
      expect(q2.userSelectedOptionIndex, null);
      expect(q2.isCorrect, false);
      expect(q2.isAvoided, true);
      expect(q2.isWrong, false);
      expect(q2.explanation, "উপজেলা প্রশাসন স্থানীয় প্রশাসনের অংশ, স্থানীয় সরকার নয়।");
    });

    test('ExamQuestionResultModel handles nested question objects and HTML content', () {
      final nestedJson = {
        "id": 890,
        "question": {
          "id": 140,
          "title": "<p>কৈবর্ত বিদ্রোহ কার আমলে হয়?</p>",
          "options": [
            {"key": 1, "value": "প্রথম মহীপাল", "is_correct": false},
            {"key": 2, "value": "দ্বিতীয় মহীপাল", "is_correct": true},
            {"key": 3, "value": "রামপাল", "is_correct": false},
            {"key": 4, "value": "ধর্মপাল", "is_correct": false}
          ],
          "explanation": "<p><span style=\"color: rgb(51, 51, 51);\">রাজা দ্বিতীয় মহীপালের শাসনামলে কৈবর্ত বিদ্রোহ হয়।</span></p>"
        },
        "user_answer": ["2"],
        "correct_answer": [{"answer": 2}],
        "is_correct": true
      };

      final q = ExamQuestionResultModel.fromJson(nestedJson, index: 1);

      expect(q.questionNumber, 1);
      expect(q.questionText, "<p>কৈবর্ত বিদ্রোহ কার আমলে হয়?</p>");
      expect(q.options.length, 4);
      expect(q.isCorrect, true);
      expect(q.isAvoided, false);
      expect(q.isWrong, false);
      expect(q.explanation?.contains("রাজা দ্বিতীয় মহীপালের"), true);
    });

    test('ExamQuestionResultModel handles real V1 API question_title, stringified answers and fills correct text', () {
      final realBackendJson = {
        "activity_id": 514047,
        "question_id": 38995,
        "question_title": "ভূমিকম্প নির্ণায়ক যন্ত্র হচ্ছে-",
        "options": {
          "option_1": null,
          "option_2": null,
          "option_3": null,
          "option_4": null
        },
        "user_answer": "[[\"1\"]]",
        "correct_answer": "[{\"key\":2,\"value\":\"সিসমোগ্রাফ\"}]",
        "is_correct": false,
        "explanation": "ভূমিকম্প নির্ণায়ক যন্ত্র হলো সিসমোগ্রাফ।"
      };

      final q = ExamQuestionResultModel.fromJson(realBackendJson, index: 3);

      expect(q.questionNumber, 3);
      expect(q.questionText, "ভূমিকম্প নির্ণায়ক যন্ত্র হচ্ছে-");
      expect(q.options.length, 4);
      expect(q.options[2], "সিসমোগ্রাফ");
      expect(q.correctOptionIndex, 2); // Option C
      expect(q.userSelectedOptionIndex, 1); // Option B
      expect(q.isCorrect, false);
      expect(q.isAvoided, false);
      expect(q.isWrong, true);
      expect(q.explanation, "ভূমিকম্প নির্ণায়ক যন্ত্র হলো সিসমোগ্রাফ।");
    });
  });
}
