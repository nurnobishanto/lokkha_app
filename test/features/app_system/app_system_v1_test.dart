import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/features/app_system/app_system.dart';

void main() {
  group('App Info & Version Control V1 Model Tests', () {
    const sampleAppInfoJson = {
      "success": true,
      "message": "App information retrieved successfully.",
      "data": {
        "app": {
          "name": "Lokkha - লক্ষ্য",
          "tagline": "সঠিক পথে, স্বল্প সময়ে",
          "description": "অনলাইন এক্সাম ও মডেল টেস্ট প্ল্যাটফর্ম",
          "logo_url": "https://lokkha.com/logo-web.png",
          "logo_light_url": "https://lokkha.com/logo-light.png",
          "favicon_url": "https://lokkha.com/logo-web.png",
          "website_url": "https://lokkha.com",
          "copyright": "স্বত্বাধিকার © 2026 Lokkha - লক্ষ্য | সর্বস্বত্ব সংরক্ষিত।"
        },
        "versions": {
          "android": {
            "latest_version_name": "2.02.02",
            "latest_version_code": "19",
            "force_update": true,
            "maintenance_mode": false,
            "download_url": "https://play.google.com/store/apps/details?id=com.techyfo.lokkha",
            "package_name": "com.techyfo.lokkha"
          },
          "ios": {
            "latest_version_name": "1.0.0",
            "latest_version_code": "1",
            "force_update": false,
            "maintenance_mode": false,
            "download_url": "https://play.google.com/store/apps/details?id=com.techyfo.lokkha&hl=en",
            "bundle_id": "com.techyfo.lokkha"
          }
        },
        "system_status": {
          "is_under_maintenance": false,
          "maintenance_title": "অ্যাপ রক্ষণাবেক্ষণ চলছে",
          "maintenance_message": "আমাদের সিস্টেম আপগ্রেডেশনের কাজ চলছে।"
        },
        "contact": {
          "office_label": "আমাদের অফিস",
          "address": "Plot:3, Road:1, Mirpur 1, Dhaka - 1216",
          "office_hours": "সকাল ৯টা - রাত ১০টা",
          "primary_phone": "(+880) 1334-260543",
          "secondary_phone": null,
          "phones": ["(+880) 1334-260543"],
          "primary_email": "info@lokkha.com",
          "support_email": "support@lokkha.com",
          "emails": ["info@lokkha.com", "support@lokkha.com"]
        },
        "social_links": {
          "facebook_page": "https://www.facebook.com/lokkhabd",
          "facebook_group": "https://www.facebook.com/groups/lokkha",
          "youtube": "https://www.youtube.com/@lokkhabd",
          "whatsapp_number": "+8801334260543",
          "whatsapp_url": "https://wa.me/+8801334260543",
          "telegram": null
        },
        "downloads": {
          "google_play_url": "https://play.google.com/store/apps/details?id=com.techyfo.lokkha",
          "app_store_url": "https://play.google.com/store/apps/details?id=com.techyfo.lokkha&hl=en"
        },
        "legal_links": {
          "privacy_policy": "https://lokkha.com/privacy-policy",
          "terms_and_conditions": "https://lokkha.com/terms-and-conditions",
          "refund_policy": "https://lokkha.com/refund-policy",
          "contest_policy": "https://lokkha.com/contest-policy",
          "about_us": "https://lokkha.com/about",
          "contact_us": "https://lokkha.com/contact"
        },
        "announcements": {
          "top_bar": {
            "enabled": true,
            "title": "লক্ষ্য মোবাইল অ্যাপ ডাউনলোড করুন",
            "subtitle": "ঘরে বসেই লাইভ পরীক্ষা ও মডেল টেস্ট দিতে"
          },
          "promo_bar": {
            "enabled": false,
            "text": "",
            "highlight": "",
            "button_text": "",
            "url": "",
            "target_date": ""
          },
          "in_app_popup": {
            "enabled": true,
            "heading": "১৯তম নিবন্ধন- ২০২৬",
            "details": "Join today's live contest",
            "image_url": "https://lokkha.com/popups/popup_1788085489_506.jpg",
            "button_text": "কোর্সে যুক্ত হোন",
            "target_url": "/courses"
          }
        },
        "client_version_check": {
          "platform": "android",
          "current_version": "10",
          "has_update": true,
          "update_required": true,
          "latest_version_name": "2.02.02",
          "latest_version_code": "19",
          "download_url": "https://play.google.com/store/apps/details?id=com.techyfo.lokkha",
          "maintenance_mode": false,
          "message": "New Version (2.02.02) Available"
        }
      }
    };

    test('AppInfoModel parses complete dynamic system metadata correctly', () {
      final model = AppInfoModel.fromJson(sampleAppInfoJson);

      expect(model.success, true);
      expect(model.message, "App information retrieved successfully.");

      // App identity
      expect(model.data.app.name, "Lokkha - লক্ষ্য");
      expect(model.data.app.tagline, "সঠিক পথে, স্বল্প সময়ে");
      expect(model.data.app.websiteUrl, "https://lokkha.com");

      // Platform versions
      expect(model.data.versions.android.latestVersionName, "2.02.02");
      expect(model.data.versions.android.latestVersionCode, "19");
      expect(model.data.versions.android.forceUpdate, true);
      expect(model.data.versions.ios.forceUpdate, false);

      // System status / maintenance
      expect(model.data.systemStatus.isUnderMaintenance, false);
      expect(model.data.systemStatus.maintenanceTitle, "অ্যাপ রক্ষণাবেক্ষণ চলছে");

      // Contact & Social
      expect(model.data.contact.primaryPhone, "(+880) 1334-260543");
      expect(model.data.socialLinks.whatsappNumber, "+8801334260543");
      expect(model.data.socialLinks.facebookPage, "https://www.facebook.com/lokkhabd");

      // Legal links
      expect(model.data.legalLinks.termsAndConditions, "https://lokkha.com/terms-and-conditions");
      expect(model.data.legalLinks.privacyPolicy, "https://lokkha.com/privacy-policy");

      // Announcements / Popup
      expect(model.data.announcements.inAppPopup.enabled, true);
      expect(model.data.announcements.inAppPopup.heading, "১৯তম নিবন্ধন- ২০২৬");
      expect(model.data.announcements.inAppPopup.targetUrl, "/courses");

      // Smart on-the-fly client version check
      expect(model.data.clientVersionCheck, isNotNull);
      expect(model.data.clientVersionCheck!.hasUpdate, true);
      expect(model.data.clientVersionCheck!.updateRequired, true);
      expect(model.data.clientVersionCheck!.latestVersionCode, "19");
      expect(model.data.clientVersionCheck!.downloadUrl, contains("play.google.com"));
    });

    test('ClientVersionCheckModel parses check-update response correctly', () {
      final checkUpdateJson = {
        "platform": "android",
        "current_version": "19",
        "has_update": false,
        "update_required": false,
        "latest_version_name": "2.02.02",
        "latest_version_code": "19",
        "download_url": null,
        "maintenance_mode": false,
        "message": "You are using the latest version"
      };

      final result = ClientVersionCheckModel.fromJson(checkUpdateJson);
      expect(result.platform, "android");
      expect(result.hasUpdate, false);
      expect(result.updateRequired, false);
      expect(result.downloadUrl, isNull);
    });

    test('AppInfoModel handles empty or null json gracefully', () {
      final empty = AppInfoModel.fromJson({});
      expect(empty.success, false);
      expect(empty.data.app.name, "Lokkha - লক্ষ্য");
      expect(empty.data.systemStatus.isUnderMaintenance, false);
      expect(empty.data.announcements.inAppPopup.enabled, false);
      expect(empty.data.clientVersionCheck, isNull);
    });
  });
}
