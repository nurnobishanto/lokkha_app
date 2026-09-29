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
  });
}
