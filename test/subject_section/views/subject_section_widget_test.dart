import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/core/enums/api_call_status.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ValueNotifier<ApiCallStatus> apiStatusNotifier;
  late ValueNotifier<SubjectSectionModel> sectionModelNotifier;

  Widget createTestableWidget() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<ApiCallStatus>(
            valueListenable: apiStatusNotifier,
            builder: (context, status, _) {
              switch (status) {
                case ApiCallStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                case ApiCallStatus.success:
                  return ValueListenableBuilder<SubjectSectionModel>(
                    valueListenable: sectionModelNotifier,
                    builder: (context, model, _) {
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 4,
                        ),
                        itemCount: model.subjectSections?.length ?? 0,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final data = model.subjectSections![index];
                          return Container(
                            color: Colors.white,
                            child: Center(child: Text(data.name ?? '')),
                          );
                        },
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
    apiStatusNotifier = ValueNotifier<ApiCallStatus>(ApiCallStatus.holding);
    sectionModelNotifier = ValueNotifier<SubjectSectionModel>(SubjectSectionModel());
  });

  group('SubjectSection Grid Widget', () {
    testWidgets('displays loading indicator', (tester) async {
      apiStatusNotifier.value = ApiCallStatus.loading;

      await tester.pumpWidget(createTestableWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays grid items on success', (tester) async {
      sectionModelNotifier.value =
          SubjectSectionModel(subjectSections: [
        SubjectSection(name: "বিসিএস", subject: Subject()),
        SubjectSection(name: "বার কাউন্সিল", subject: Subject()),
      ]);
      apiStatusNotifier.value = ApiCallStatus.success;

      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text("বিসিএস"), findsOneWidget);
      expect(find.text("বার কাউন্সিল"), findsOneWidget);
    });

    testWidgets('displays error message', (tester) async {
      apiStatusNotifier.value = ApiCallStatus.error;

      await tester.pumpWidget(createTestableWidget());

      expect(find.text("কিছু ভুল হয়েছে, আবার চেষ্টা করুন"), findsOneWidget);
    });
  });
}
