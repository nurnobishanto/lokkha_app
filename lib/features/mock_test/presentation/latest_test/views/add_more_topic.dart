import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/mock_test/mock_test.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/models/mock_subject_select_model.dart';
import '../controllers/add_more_topic_controller.dart';
import '../controllers/test_controller.dart';

class AddMoreTopic extends StatelessWidget {
  const AddMoreTopic({super.key});

  @override
  Widget build(BuildContext context) {
    final AddMoreTopicController controller = Get.put(AddMoreTopicController());
    final TestController testController = Get.find<TestController>();

    return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(
            "আরও বিষয়",
            style: AppTextStyles.heading4.copyWith(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: LightThemeColors.white),
          centerTitle: true,
          backgroundColor: LightThemeColors.primaryColor,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(
                  testController.model.value.subjects?.length ?? 0, (index) {
                final subject = testController.model.value.subjects![index];

                final isSelected =
                    controller.selectedSubjects.any((s) => s.id == subject.id);

                if (isSelected) {
                  return const SizedBox.shrink(); // skip if already selected
                }

                return InkWell(
                  onTap: () async {
                    MockSubjectSelect newSubject = MockSubjectSelect(
                        id: subject.id,
                        name: subject.name,
                        quantity: min(15, subject.questionCount!.toInt()),
                        max: subject.questionCount!.toInt());
                    await MySharedPref.addOrUpdateMockSubjectSelect(newSubject);
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
        ));
  }
}
