import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/profile/data/models/my_packages_model.dart';
import 'package:lokkha/features/profile/presentation/my_packages/riverpod/my_packages_notifier.dart';
import 'package:lokkha/features/profile/presentation/my_packages/views/my_packages_view.dart';

class _FakeMyPackagesNotifier extends MyPackagesNotifier {
  final MyPackagesState _initialState;
  _FakeMyPackagesNotifier(this._initialState);

  @override
  MyPackagesState build() => _initialState;

  @override
  Future<void> fetchMyPackages({bool isRefresh = false}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    isLoggedIn.value = true;
  });

  group('MyPackages V1 Model Tests', () {
    test('Parses V1 user packages response with items and dates', () {
      final json = {
        "success": true,
        "message": "User subscriptions retrieved successfully.",
        "data": {
          "items": [
            {
              "id": 101,
              "package_id": 1,
              "status": "active",
              "package": {
                "id": 1,
                "name": "সম্পূর্ণ ফিচারসমূহ",
                "description": "সকল মডেল টেস্ট ও প্র্যাকটিস পরীক্ষার সুবিধা।",
                "regular_price": "50.0",
                "discount": "20.0",
                "discounted_price": "30.0"
              },
              "subscribed_at": "2026-10-01T10:00:00Z",
              "cancelled_at": "2026-11-01T10:00:00Z",
              "created_at": "2026-10-01T10:00:00Z"
            }
          ]
        }
      };

      final model = MyPackagesModel.fromJson(json);

      expect(model.success, isTrue);
      expect(model.packages.length, 1);
      final item = model.packages.first;
      expect(item.id, 101);
      expect(item.packageId, 1);
      expect(item.packageName, "সম্পূর্ণ ফিচারসমূহ");
      expect(item.status, "active");
      expect(item.isActive, isTrue);
      expect(item.formattedStartDate, isNotEmpty);
      expect(item.formattedEndDate, isNotEmpty);
    });

    test('Endpoints contains userPackages and alias', () {
      expect(Endpoints.userPackages, '/api/v1/user/packages');
      expect(Endpoints.myPackages, '/api/v1/user/packages');
    });
  });

  group('MyPackagesView Widget Tests', () {
    Widget buildTestWidget({required MyPackagesState state}) {
      return ProviderScope(
        overrides: [
          myPackagesNotifierProvider.overrideWith(
            () => _FakeMyPackagesNotifier(state),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: MyPackagesView(),
          ),
        ),
      );
    }

    testWidgets('Renders empty state when user has no active packages',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          state: MyPackagesState(
            isLoading: false,
            model: MyPackagesModel(success: true, packages: []),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Packages'), findsWidgets);
      expect(find.text('আপনার কোনো সক্রিয় প্যাকেজ নেই'), findsOneWidget);
      expect(find.text('নতুন প্যাকেজ কিনুন'), findsOneWidget);
    });

    testWidgets('Renders active package card matching design screenshot',
        (tester) async {
      final pkg = PackageElement(
        id: 1,
        packageId: 5,
        name: "সম্পূর্ণ ফিচারসমূহ",
        status: "active",
        subscribedAt: DateTime(2026, 10, 1),
        cancelledAt: DateTime(2026, 11, 1),
      );

      await tester.pumpWidget(
        buildTestWidget(
          state: MyPackagesState(
            isLoading: false,
            model: MyPackagesModel(success: true, packages: [pkg]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('সম্পূর্ণ ফিচারসমূহ'), findsOneWidget);
      expect(find.text('সক্রিয়'), findsOneWidget);
      expect(find.text('নতুন প্যাকেজ'), findsOneWidget);
      expect(find.text('রিনিউ / আপগ্রেড'), findsOneWidget);
      expect(find.text('শুরু:'), findsOneWidget);
      expect(find.text('মেয়াদ:'), findsOneWidget);
    });

    testWidgets('Renders error state with retry button on error',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          state: MyPackagesState(
            isLoading: false,
            hasError: true,
            errorMessage: 'সার্ভার সংযোগে সমস্যা হয়েছে',
            model: MyPackagesModel(packages: []),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('সার্ভার সংযোগে সমস্যা হয়েছে'), findsOneWidget);
      expect(find.text('আবার চেষ্টা করুন'), findsOneWidget);
    });
  });
}
