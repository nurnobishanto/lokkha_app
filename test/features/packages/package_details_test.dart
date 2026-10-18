import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/features/packages/data/models/package_detail_response_model.dart';
import 'package:lokkha/features/packages/presentation/providers/package_details_notifier.dart';
import 'package:lokkha/features/packages/presentation/views/package_details_view.dart';
import 'package:lokkha/shared/models/package.dart';

void main() {
  group('Package Details Model Tests', () {
    test('PackageDetailResponseModel parses direct data object', () {
      final jsonMap = {
        "success": true,
        "message": "Package retrieved successfully.",
        "data": {
          "id": 10,
          "name": "সম্পূর্ণ প্রিমিয়াম মাস্টার",
          "description": "সকল মডেল টেস্ট ও জব সলিউশন পরীক্ষার সম্পূর্ণ সুবিধা।",
          "regular_price": 100.0,
          "discount": 30.0,
          "effective_price": 70.0,
          "duration_days": 60,
          "formatted_duration": "2 Months (60 Days)",
          "is_trial": true,
          "can_claim_trial": true,
          "trial_duration_days": 3,
          "features": [
            {"text": "আনলিমিটেড মডেল টেস্ট", "included": true},
            {"text": "অফলাইন ডাউনলোড", "included": false}
          ],
          "terms_and_conditions": [
            "মেয়াদ শেষ হলে পুনরায় নবায়ন করতে হবে।",
            "কোনো রিফান্ড প্রযোজ্য নয়।"
          ]
        }
      };

      final model = PackageDetailResponseModel.fromJson(jsonMap);
      expect(model.success, isTrue);
      expect(model.package, isNotNull);
      expect(model.package!.id, 10);
      expect(model.package!.name, "সম্পূর্ণ প্রিমিয়াম মাস্টার");
      expect(model.package!.effectivePrice, 70.0);
      expect(model.package!.featureList?.length, 2);
      expect(model.package!.featureList?[0].text, "আনলিমিটেড মডেল টেস্ট");
      expect(model.package!.featureList?[0].included, isTrue);
      expect(model.package!.featureList?[1].included, isFalse);
      expect(model.package!.termsList?.length, 2);
      expect(model.package!.termsList?[0], "মেয়াদ শেষ হলে পুনরায় নবায়ন করতে হবে।");
      expect(model.package!.canClaimTrial, isTrue);
      expect(model.package!.trialDurationDays, 3);
    });

    test('PackageDetailResponseModel parses nested data.package object', () {
      final jsonMap = {
        "success": true,
        "message": "Package details retrieved.",
        "data": {
          "package": {
            "id": 25,
            "name": "বিসিএস স্পেশাল",
            "regular_price": 500,
            "effective_price": 350,
            "features": [
              {"text": "সকল বিসিএস প্রশ্ন সমাধান", "included": true}
            ]
          }
        }
      };

      final model = PackageDetailResponseModel.fromJson(jsonMap);
      expect(model.success, isTrue);
      expect(model.package?.id, 25);
      expect(model.package?.name, "বিসিএস স্পেশাল");
    });
  });

  group('PackageDetailsView Widget Tests', () {
    final testPackage = Package(
      id: 1,
      name: "মাস্টার এক্সপ্রেস প্যাকেজ",
      description: "এই প্যাকেজে সকল প্রিমিয়াম কন্টেন্ট উন্মুক্ত থাকবে।",
      regularPrice: "500",
      discount: "20",
      discountedPrice: "400",
      effectivePrice: 400.0,
      durationDays: 30,
      formattedDuration: "1 মাস (30 দিন)",
      isCurrentlyActive: true,
      isTrial: true,
      canClaimTrial: true,
      trialDurationDays: 3,
      featureList: [
        PackageFeature(text: "লাইভ মডেল টেস্ট", included: true),
        PackageFeature(text: "আনলিমিটেড আর্কাইভ এক্সেস", included: true),
        PackageFeature(text: "ব্যক্তিগত মেন্টর সাপোর্ট", included: false),
      ],
      termsList: [
        "প্যাকেজটি একক ব্যবহারকারীর জন্য প্রযোজ্য।",
        "সাবস্ক্রিপশন সক্রিয় থাকা সাপেক্ষে পরীক্ষা দেওয়া যাবে।",
      ],
    );

    testWidgets('renders all package details sections accurately',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            packageDetailsNotifierProvider(1).overrideWith(
              () => _TestPackageDetailsNotifier(testPackage),
            ),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => MaterialApp(
              home: PackageDetailsView(
                packageId: 1,
                initialPackage: testPackage,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify App Bar and Title
      expect(find.text("প্যাকেজ বিস্তারিত"), findsOneWidget);
      expect(find.text("মাস্টার এক্সপ্রেস প্যাকেজ"), findsOneWidget);
      expect(find.text("1 মাস (30 দিন)"), findsOneWidget);
      expect(find.text("সক্রিয়"), findsOneWidget);

      // 2. Verify Pricing Card
      expect(find.text("প্যাকেজ মূল্য"), findsOneWidget);
      expect(find.textContaining("400"), findsWidgets);
      expect(find.textContaining("500"), findsWidgets);
      expect(find.text("20% ছাড়"), findsOneWidget);

      // 3. Verify Description
      expect(find.text("প্যাকেজ বিবরণ"), findsOneWidget);
      expect(
        find.text("এই প্যাকেজে সকল প্রিমিয়াম কন্টেন্ট উন্মুক্ত থাকবে।"),
        findsOneWidget,
      );

      // 4. Verify Trial Offer
      expect(find.text("ফ্রি ট্রায়াল অফার!"), findsOneWidget);
      expect(find.textContaining("3 দিনের ফ্রি ট্রায়াল নিন"), findsOneWidget);

      // 5. Verify Features List
      expect(find.text("প্যাকেজের অন্তর্ভুক্ত সুবিধাসমূহ"), findsOneWidget);
      expect(find.text("লাইভ মডেল টেস্ট"), findsOneWidget);
      expect(find.text("ব্যক্তিগত মেন্টর সাপোর্ট"), findsOneWidget);

      // 6. Verify Terms List (Scroll into view)
      await tester.scrollUntilVisible(
        find.text("শর্তাবলী ও নীতিমালা"),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text("শর্তাবলী ও নীতিমালা"), findsOneWidget);
      expect(
        find.text("প্যাকেজটি একক ব্যবহারকারীর জন্য প্রযোজ্য।"),
        findsOneWidget,
      );

      // 7. Verify Sticky Bottom Bar
      expect(find.text("রিনিউ / আপগ্রেড করুন"), findsOneWidget);
    });

    testWidgets(
        'does NOT render terms & conditions card when terms are null, "null", or empty',
        (tester) async {
      final packageWithoutTerms = Package(
        id: 2,
        name: "ফিচারসমূহ",
        description: "এই প্যাকেজটি ৩৬৫ দিনের জন্য প্রযোজ্য।",
        regularPrice: "365",
        discount: "17.81",
        discountedPrice: "300",
        effectivePrice: 300.0,
        durationDays: 365,
        formattedDuration: "365 Days",
        isCurrentlyActive: true,
        termsList: ["null", " ", "<p>null</p>"], // simulates backend sending null
      );

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            packageDetailsNotifierProvider(2).overrideWith(
              () => _TestPackageDetailsNotifier(packageWithoutTerms),
            ),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => MaterialApp(
              home: PackageDetailsView(
                packageId: 2,
                initialPackage: packageWithoutTerms,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Card should NOT be displayed
      expect(find.text("শর্তাবলী ও নীতিমালা"), findsNothing);
      // Literal "null" should NEVER be displayed
      expect(find.text("• null"), findsNothing);
      expect(find.text("null"), findsNothing);
      // Other contents should be displayed normally
      expect(find.text("ফিচারসমূহ"), findsOneWidget);
      expect(find.text("365 Days"), findsOneWidget);
      expect(find.text("প্যাকেজ বিবরণ"), findsOneWidget);
    });
  });

  group('Package Terms Sanitization Unit Tests', () {
    test('filters out null, "null", and whitespace in terms_and_conditions list',
        () {
      final json = {
        "id": 99,
        "name": "টেস্ট",
        "terms_and_conditions": [null, "null", "  ", "<p>null</p>"]
      };

      final pkg = Package.fromJson(json);
      expect(pkg.termsList, isNull);
    });

    test('retains only valid terms when mixed with nulls', () {
      final json = {
        "id": 100,
        "name": "টেস্ট ২",
        "terms_and_conditions": [
          "বৈধ শর্ত ১",
          null,
          "null",
          "বৈধ শর্ত ২",
          ""
        ]
      };

      final pkg = Package.fromJson(json);
      expect(pkg.termsList, isNotNull);
      expect(pkg.termsList!.length, 2);
      expect(pkg.termsList![0], "বৈধ শর্ত ১");
      expect(pkg.termsList![1], "বৈধ শর্ত ২");
    });

    test('handles string terms_and_conditions with "null"', () {
      final json = {
        "id": 101,
        "name": "টেস্ট ৩",
        "terms_and_conditions": "null"
      };

      final pkg = Package.fromJson(json);
      expect(pkg.termsList, isNull);
    });
  });

  group('Package Details Loading & First Render Tests', () {
    testWidgets(
        'shows loading spinner when package has incomplete details and does not display premature ৳ 0',
        (tester) async {
      final incompletePackage = Package(
        id: 3,
        name: "মাস্টার এক্সপ্রেস",
      );

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            packageDetailsNotifierProvider(3).overrideWith(
              () => _TestLoadingPackageDetailsNotifier(incompletePackage),
            ),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => MaterialApp(
              home: PackageDetailsView(
                packageId: 3,
                initialPackage: incompletePackage,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should show progress indicator, NOT empty ৳ 0
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text("৳ 0"), findsNothing);
    });
  });
}

class _TestPackageDetailsNotifier extends PackageDetailsNotifier {
  final Package _pkg;

  _TestPackageDetailsNotifier(this._pkg) : super(1);

  @override
  PackageDetailsState build() {
    return PackageDetailsState(
      package: _pkg,
      isLoading: false,
      hasError: false,
    );
  }

  @override
  Future<void> fetchPackageDetails(int id, {bool isRefresh = false}) async {}
}

class _TestLoadingPackageDetailsNotifier extends PackageDetailsNotifier {
  final Package _pkg;

  _TestLoadingPackageDetailsNotifier(this._pkg) : super(3);

  @override
  PackageDetailsState build() {
    return PackageDetailsState(
      package: _pkg,
      isLoading: true,
      hasError: false,
    );
  }

  @override
  Future<void> fetchPackageDetails(int id, {bool isRefresh = false}) async {}
}
