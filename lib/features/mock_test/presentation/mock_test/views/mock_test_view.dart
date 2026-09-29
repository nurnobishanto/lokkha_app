import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/mock_test/mock_test.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/shared/models/mock_subject_select_model.dart';
import '../controllers/mock_test_controller.dart';

class MockTestView extends GetView<MockTestController> {
  const MockTestView({super.key});


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MockTestController());
    return Scaffold(
      body: Obx(() {
        switch (controller.apiCallStatus.value) {
          case ApiCallStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case ApiCallStatus.success:
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 16.0,
                  bottom: 8.0.h,
                  left: 8.0.h,
                  right: 8.0.h,
                ),
                child: Center(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                        controller.model.value.subjects?.length ?? 0, (index) {
                      final subject = controller.model.value.subjects![index];
                      return InkWell(
                        onTap: () async {
                          MySharedPref.clearMockSubjects();
                          MockSubjectSelect newSubject = MockSubjectSelect(
                              id: subject.id,
                              name: subject.name,
                              quantity: min(15, subject.questionCount!.toInt()),
                              max: subject.questionCount!.toInt());
                          await MySharedPref.addOrUpdateMockSubjectSelect(
                              newSubject);

                          Get.to(TopicSelectionView(subject: subject));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.00.w, vertical: 8.00.h),
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: context.isDark
                                    ? context.borderColor
                                    : context.primaryColor.withValues(alpha: 0.3),
                                width: context.isDark ? 0.8 : 0.4),
                            boxShadow: [
                              BoxShadow(
                                color: context.isDark
                                    ? Colors.black.withValues(alpha: 0.2)
                                    : Colors.black.withValues(alpha: 0.05),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            subject.name.toString(),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body2.copyWith(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            );
          case ApiCallStatus.error:
            return const Center(child: Text("Failed to load data. Try again."));
          case ApiCallStatus.holding:
          default:
            return const SizedBox.shrink();
        }
      }),
    );
  }
}
