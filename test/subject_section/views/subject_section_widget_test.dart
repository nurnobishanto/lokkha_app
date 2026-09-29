import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HomeController controller;

  Widget createTestableWidget() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              switch (controller.subjectSectionApiStatus.value) {
                case ApiCallStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                case ApiCallStatus.success:
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 4,
                    ),
                    itemCount: controller.subjectSectionModel.value
                            .subjectSections?.length ??
                        0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final data = controller
                          .subjectSectionModel.value.subjectSections![index];
                      return Container(
                        color: Colors.white,
                        child: Center(child: Text(data.name ?? '')),
                      );
                    },
                  );
                case ApiCallStatus.error:
                  return const Center(
                      child: Text("কিছু ভুল হয়েছে, আবার চেষ্টা করুন"));
                default:
                  return const SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }

  setUp(() {
    Get.reset();
    controller = HomeController();
    Get.put(controller);
  });

  tearDown(() {
    Get.reset();
  });

  group('SubjectSection Grid Widget', () {
    testWidgets('displays loading indicator', (tester) async {
      controller.subjectSectionApiStatus.value = ApiCallStatus.loading;

      await tester.pumpWidget(createTestableWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays grid items on success', (tester) async {
      controller.subjectSectionModel.value =
          SubjectSectionModel(subjectSections: [
        SubjectSection(name: "বিসিএস", subject: Subject()),
        SubjectSection(name: "বার কাউন্সিল", subject: Subject()),
      ]);
      controller.subjectSectionApiStatus.value = ApiCallStatus.success;

      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text("বিসিএস"), findsOneWidget);
      expect(find.text("বার কাউন্সিল"), findsOneWidget);
    });

    testWidgets('displays error message', (tester) async {
      controller.subjectSectionApiStatus.value = ApiCallStatus.error;

      await tester.pumpWidget(createTestableWidget());

      expect(find.text("কিছু ভুল হয়েছে, আবার চেষ্টা করুন"), findsOneWidget);
    });
  });
}
