import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/components/custom_action_button.dart';
import 'package:lokkha/app/components/custom_snackbar.dart';
import 'package:lokkha/app/data/local/my_shared_pref.dart';

import 'package:lokkha/app/modules/grid_views/latest_test/controllers/add_more_topic_controller.dart';
import 'package:lokkha/app/modules/grid_views/latest_test/views/add_more_topic.dart';
import 'package:lokkha/app/modules/grid_views/latest_test/views/set_time_view.dart';
import 'package:lokkha/config/extensions/common_extension.dart';
import 'package:lokkha/config/theme/light_theme_colors.dart';
import '../../../../../styles/text_style.dart';
import '../../../../components/custom_text_field.dart';
import '../../../../models/mock_subject_select_model.dart';
import '../../../../models/subject.dart';

class TopicSelectionView extends StatelessWidget {
  final Subject subject;
  const TopicSelectionView({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final setNumberController = TextEditingController(text: "10");
    final controller = AddMoreTopicController();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          "নির্বাচিত বিষয়গুলি",
          style: AppTextStyles.heading4.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: LightThemeColors.white),
        centerTitle: true,
        backgroundColor: LightThemeColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 20.00),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomExpandSubject(
                      subject: subject,
                      topic: subject,
                      padding: 0,
                      initialExpand: true,
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "প্রশ্ন সংখ্যা সেট করুন",
                  style: TextStyle(color: context.textPrimary),
                ),
                CustomTextField(
                  controller: setNumberController,
                  hintText: "প্রশ্ন সংখ্যা",
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "This field is required";
                    }
                    final parsedValue = int.tryParse(val);
                    if (parsedValue == null) {
                      return "please enter valid number";
                    } else if (parsedValue < 5) {
                      return "Must be at least 10";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.00),
                Row(
                  children: [
                    Expanded(
                      child: CustomActionButton(
                        text: "আরও বিষয় যোগ করুন",
                        onPressed: () async {
                          if (setNumberController.text.isNotEmpty) {
                            MockSubjectSelect newSubject = MockSubjectSelect(
                              id: subject.id,
                              name: subject.name,
                              quantity: min(
                                  int.tryParse(setNumberController.text)!
                                      .toInt(),
                                  subject.questionCount!.toInt()),
                            );
                            await MySharedPref.addOrUpdateMockSubjectSelect(
                                newSubject);

                            controller.getSubjects();

                            Get.to(const AddMoreTopic());
                          } else {
                            CustomSnackBar.showCustomErrorToast(
                                message: "please enter number of question!");
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8.00),
                    Expanded(
                      child: CustomActionButton(
                        text: "পরীক্ষা শুরু করুন",
                        onPressed: () async {
                          if (setNumberController.text.isNotEmpty) {
                            MockSubjectSelect newSubject = MockSubjectSelect(
                              id: subject.id,
                              name: subject.name,
                              quantity: min(
                                  int.tryParse(setNumberController.text)!
                                      .toInt(),
                                  subject.questionCount!.toInt()),
                            );
                            await MySharedPref.addOrUpdateMockSubjectSelect(
                                newSubject);

                            controller.getSubjects();

                            Get.to(const SetTimeView());
                          } else {
                            CustomSnackBar.showCustomErrorToast(
                                message: "please enter number of question!");
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomExpandSubject extends StatelessWidget {
  final Subject subject;
  final Subject topic;
  final double padding;
  final bool initialExpand;

  const CustomExpandSubject(
      {super.key,
      required this.subject,
      required this.topic,
      required this.padding,
      required this.initialExpand});

  @override
  Widget build(BuildContext context) {
    final isExpanded = false.obs;
    return FutureBuilder<bool>(
      future: MySharedPref.isMockSubjectExist(topic.id!.toInt()),
      builder: (context, snapshot) {
        final isChecked = (snapshot.data ?? false).obs;
        return Obx(() {
          return Container(
            margin: EdgeInsets.only(left: padding),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: context.borderColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                // backgroundColor: Colors.blue,
                minTileHeight: 0.00,
                showTrailingIcon: false,
                visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
                initiallyExpanded: initialExpand,
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                onExpansionChanged: (expanded) => isExpanded.value = expanded,
                title: Container(
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(7.r),
                    border: Border.all(color: context.borderColor, width: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: context.isDark ? Colors.transparent : Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  // padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 8.h),
                  child: Row(
                    children: [
                      Checkbox(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        side: BorderSide(
                          color: isChecked.value
                              ? context.primaryColor
                              : context.borderColor,
                          width: 1.5,
                        ),
                        value: isChecked.value,
                        onChanged: (value) {
                          debugPrint("Checked Box: $value");
                          isChecked.value = value!;
                          MockSubjectSelect newSubject = MockSubjectSelect(
                              id: topic.id,
                              name: topic.name,
                              parentId: subject.id,
                              max: topic.questionCount!.toInt());
                          if (value) {
                            MySharedPref.addOrUpdateMockSubjectSelect(
                                newSubject);
                          } else {
                            MySharedPref.removeMockSubjectSelect(newSubject);
                          }
                        },
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      2.0.w.width,
                      Expanded(
                        child: Text(
                          topic.name.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: AppTextStyles.body2.copyWith(color: context.textPrimary),
                        ),
                      ),
                      Obx(() => AnimatedRotation(
                            turns: isExpanded.value ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(Icons.keyboard_arrow_down, color: context.textMuted),
                          )),
                    ],
                  ),
                ),
                children: topic.children!
                    .map((child) => CustomExpandSubject(
                          subject: subject,
                          topic: child,
                          padding: 10,
                          initialExpand: false,
                        ))
                    .toList(),
              ),
            ),
          );
        });
      },
    );
  }
}
