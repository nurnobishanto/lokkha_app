import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/data/local/my_shared_pref.dart';
import 'package:lokkha/app/modules/grid_views/latest_test/views/topic_selection_view.dart';
import 'package:lokkha/config/theme/light_theme_colors.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import 'package:lokkha/styles/text_style.dart';
import '../../../../models/mock_subject_select_model.dart';
import '../../../../services/api_call_status.dart';
import '../controllers/test_controller.dart';

class LatestSubjectTestView extends GetView<TestController> {
  const LatestSubjectTestView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TestController());
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          "সর্বশেষ সাবজেক্ট অনুযায়ী তথ্যাদি",
          style: AppTextStyles.heading4.copyWith(color: LightThemeColors.white),
        ),
      ),
      body: Obx(() {
        switch (controller.apiCallStatus.value) {
          case ApiCallStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case ApiCallStatus.success:
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                          border: Border.all(color: context.borderColor),
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
