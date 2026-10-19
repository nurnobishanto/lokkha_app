import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/features/packages/data/models/premium_package_model.dart';
import 'package:lokkha/features/packages/packages.dart';
import 'package:lokkha/shared/models/package.dart';

void main() {
  group('Package V1 Model Unit Tests', () {
    test('Package.fromJson parses V1 normalized features and pricing', () {
      final json = {
        "id": 1,
        "name": "সম্পূর্ণ ফিচারসমূহ",
        "description": "সকল মডেল টেস্ট ও প্র্যাকটিস পরীক্ষার সুবিধা।",
        "regular_price": 50.0,
        "discount": 20.0,
        "discounted_price": 30.0,
        "effective_price": 30.0,
        "duration_days": 30,
        "formatted_duration": "1 Month (30 Days)",
        "features": [
          {"text": "আনলিমিটেড মডেল টেস্ট", "included": true},
          {"text": "উত্তরপত্র ও নির্ভুল ব্যাখ্যা", "included": true},
          {"text": "লাইভ লিডারবোর্ড র‍্যাংকিং", "included": false}
        ],
        "terms_and_conditions": [
          "প্যাকেজটি কেনার পর কোনো রিফান্ড প্রযোজ্য নয়।"
        ],
        "is_featured": true,
        "is_mega": false,
        "is_female": false,
        "is_trial": true,
        "trial_duration_days": 3,
        "can_claim_trial": true,
        "is_currently_active": false,
        "user_subscription": null,
      };

      final pkg = Package.fromJson(json);

      expect(pkg.id, 1);
      expect(pkg.name, "সম্পূর্ণ ফিচারসমূহ");
      expect(pkg.regularPrice, "50.0");
      expect(pkg.discountedPrice, "30.0");
      expect(pkg.effectivePrice, 30.0);
      expect(pkg.durationDays, 30);
      expect(pkg.formattedDuration, "1 Month (30 Days)");
      expect(pkg.isTrial, true);
      expect(pkg.trialDurationDays, 3);
      expect(pkg.canClaimTrial, true);
      expect(pkg.isCurrentlyActive, false);

      expect(pkg.featureList?.length, 3);
      expect(pkg.featureList?[0].text, "আনলিমিটেড মডেল টেস্ট");
      expect(pkg.featureList?[0].included, true);
      expect(pkg.featureList?[2].included, false);

      expect(pkg.featureTexts.length, 3);
      expect(pkg.termsList?.length, 1);
    });

    test('Package.fromJson gracefully falls back for legacy feature formats', () {
      final jsonStringFeatures = {
        "id": 2,
        "name": "Legacy String Package",
        "regular_price": "100",
        "features": "Feature 1\nFeature 2",
      };

      final pkg1 = Package.fromJson(jsonStringFeatures);
      expect(pkg1.featureList?.length, 2);
      expect(pkg1.featureList?[0].text, "Feature 1");
      expect(pkg1.featureList?[1].text, "Feature 2");

      final jsonListStrings = {
        "id": 3,
        "name": "Legacy List Package",
        "regular_price": "200",
        "features": ["Feature A", "Feature B"],
      };

      final pkg2 = Package.fromJson(jsonListStrings);
      expect(pkg2.featureList?.length, 2);
      expect(pkg2.featureList?[0].text, "Feature A");
      expect(pkg2.featureList?[1].text, "Feature B");
    });
  });

  group('PremiumPackageModel V1 Catalog Tests', () {
    test('PremiumPackageModel.fromJson parses catalog response with meta and trial eligibility', () {
      final responseJson = {
        "success": true,
        "message": "Packages retrieved successfully.",
        "data": {
          "items": [
            {
              "id": 1,
              "name": "সম্পূর্ণ ফিচারসমূহ",
              "regular_price": 50.0,
              "discounted_price": 30.0,
              "effective_price": 30.0,
              "duration_days": 30,
              "formatted_duration": "1 Month",
              "features": [
                {"text": "আনলিমিটেড মডেল টেস্ট", "included": true}
              ],
              "is_trial": true,
              "can_claim_trial": true,
              "is_currently_active": false
            }
          ],
          "can_claim_free_trial": true,
          "active_user_package_id": 10,
          "is_authenticated": true,
          "meta": {
            "current_page": 1,
            "last_page": 2,
            "total": 12,
            "per_page": 10
          }
        }
      };

      final model = PremiumPackageModel.fromJson(responseJson);

      expect(model.success, true);
      expect(model.message, "Packages retrieved successfully.");
      expect(model.packages.length, 1);
      expect(model.canClaimFreeTrial, true);
      expect(model.activeUserPackageId, 10);
      expect(model.isAuthenticated, true);
      expect(model.meta?.total, 12);
      expect(model.meta?.lastPage, 2);
      expect(model.meta?.currentPage, 1);
    });
  });

  group('PremiumPackagesView Widget Tests', () {
    testWidgets('renders modern hero banner, clean cards, and trust footer', (tester) async {
      final mockRepo = _MockTestPackagesRepo();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            premiumPackagesNotifierProvider.overrideWith(
              () => PremiumPackagesNotifier(repository: mockRepo),
            ),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) => const MaterialApp(
              home: PremiumPackagesView(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // 1. Verify AppBar and Hero
      expect(find.text('প্রিমিয়াম প্যাকেজ'), findsOneWidget);
      expect(find.text('লক্ষ্য প্রো সাবস্ক্রিপশন'), findsOneWidget);
      expect(find.text('সকল মডেল টেস্ট, বিষয়ভিত্তিক পরীক্ষা ও নির্ভুল ব্যাখ্যা'), findsOneWidget);

      // 2. Verify First Package rendered as card
      await tester.scrollUntilVisible(find.text('ফিচারসমূহ'), 100);
      expect(find.text('ফিচারসমূহ'), findsOneWidget);
      expect(find.text('৳150'), findsOneWidget);

      // 3. Scroll to second package
      await tester.scrollUntilVisible(find.text('অপরাজিতা এক্সপ্রেস'), 100);
      expect(find.text('অপরাজিতা এক্সপ্রেস'), findsOneWidget);
      expect(find.text('অপরাজিতা স্পেশাল • 40.1% ছাড়'), findsOneWidget);
      expect(find.text('৳899'), findsOneWidget);

      // 4. Scroll to Trust footer
      await tester.scrollUntilVisible(find.text('১০০% নিরাপদ পেমেন্ট'), 100);
      expect(find.text('১০০% নিরাপদ পেমেন্ট'), findsOneWidget);
    });
  });
}

class _MockTestPackagesRepo implements PackagesRepository {
  @override
  Future<PackageDetailResponseModel?> getPackageDetails(int packageId) async => null;

  @override
  Future<PremiumPackageModel?> getPremiumPackages({
    int page = 1,
    int perPage = 15,
    String? search,
    bool? isFeatured,
    bool? isTrial,
    String? sortBy,
  }) async {
    return PremiumPackageModel(
      success: true,
      packages: [
        Package(
          id: 1,
          name: "ফিচারসমূহ",
          duration: 180,
          regularPrice: "180",
          discountedPrice: "150",
          discount: "16.67",
        ),
        Package(
          id: 2,
          name: "অপরাজিতা এক্সপ্রেস",
          duration: 365,
          regularPrice: "1500",
          discountedPrice: "899",
          discount: "40.07",
          isFemale: true,
        ),
      ],
    );
  }

  @override
  Future<Map<String, dynamic>?> claimFreeTrial(int packageId) async => null;
}

