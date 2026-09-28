import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/modules/subject_sections/controllers/sub_sec_set_time_controller.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import '../../../../config/theme/light_theme_colors.dart';
import '../../../../styles/text_style.dart';
import '../../../components/custom_action_button.dart';
import '../../../components/custom_text_field.dart';
import '../../../helper/global.dart';
import '../../../routes/app_pages.dart';

class SubSectionsSetTimeView extends GetView {
  const SubSectionsSetTimeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubSecSetTimeController());
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'সময় নির্ধারণ',
          style: AppTextStyles.heading4.copyWith(color: LightThemeColors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: LightThemeColors.primaryColor,
      ),
      body: Obx(() {
        List<Map<String, String>> dropdownItems =
            controller.questionType.entries.map((entry) {
          return {
            'key': entry.key,
            'value': entry.value,
          };
        }).toList();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'সময় নির্ধারণ করুন',
                              style: AppTextStyles.body1.copyWith(color: context.textPrimary),
                            ),
                            const SizedBox(width: 5.00),
                            Container(
                              constraints: const BoxConstraints(
                                maxWidth: 100,
                                maxHeight: 40,
                              ),
                              padding: EdgeInsets.zero,
                              width: 40,
                              height: 30,
                              child: Transform.scale(
                                scale: 0.7,
                                child: Switch.adaptive(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: controller.isSetTime.value,
                                  onChanged: (value) {
                                    controller.isSetTime.value = value;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        controller.isSetTime.value
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16.00),
                                  const Text(
                                    'মিনিটে সময় নির্ধারণ করুন',
                                  ),
                                  const SizedBox(height: 3.00),
                                  CustomTextField(
                                    controller: controller.setTimeCon,
                                    hintText: "মিনিটে সময় নির্ধারণ",
                                    keyboardType: TextInputType.number,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return "this field is required";
                                      }
                                      final parsedValue = int.tryParse(val);
                                      if (parsedValue == null) {
                                        return 'please enter A valid number';
                                      } else if (parsedValue < 10) {
                                        return 'Must be at least 10';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(height: 6.00),
                        // Negative Mark
                        Row(
                          children: [
                            Text(
                              "নেগেটিভ মার্কিং",
                              style: AppTextStyles.body1.copyWith(color: context.textPrimary),
                            ),
                            const SizedBox(width: 3.00),
                            Container(
                              constraints: const BoxConstraints(
                                maxWidth: 100,
                                maxHeight: 40,
                              ),
                              padding: EdgeInsets.zero,
                              width: 40,
                              height: 30,
                              child: Transform.scale(
                                scale: 0.7,
                                child: Switch.adaptive(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: controller.isNegativeMarkChecked.value,
                                  onChanged: (value) {
                                    controller.isNegativeMarkChecked.value =
                                        value;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 5.00),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                color: context.isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(color: context.isDark ? const Color(0xFFEF4444).withValues(alpha: 0.5) : Colors.red.withValues(alpha: 0.3)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                "প্রতিটি ভুলের জন্য ০.২৫ নম্বর কাটা যাবে",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body1.copyWith(
                                  fontSize: 12.sp,
                                  color: context.isDark ? const Color(0xFFFCA5A5) : Colors.red.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15.00),
                        Text(
                          "প্রশ্নের ধরন নির্বাচন করুন",
                          style: AppTextStyles.body1.copyWith(color: context.textPrimary),
                        ),
                        const SizedBox(height: 3.00),
                        GridView.builder(
                          shrinkWrap:
                              true, // To make sure it takes only the required space
                          physics:
                              const NeverScrollableScrollPhysics(), // To prevent scrolling inside the grid
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Number of columns
                            crossAxisSpacing:
                                2, // Horizontal space between items
                            mainAxisSpacing: 2, // Vertical space between items
                            childAspectRatio: 6.5,
                          ),
                          itemCount: dropdownItems.length,
                          itemBuilder: (context, index) {
                            final item = dropdownItems[index];
                            return Obx(() => InkWell(
                                  onTap: () {
                                    controller.selectedKey.value =
                                        item['key'] ?? '';
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Radio<String>(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                        value: item['key'] ?? '',
                                        groupValue:
                                            controller.selectedKey.value,
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            controller.selectedKey.value =
                                              newValue;
                                          }
                                        },
                                      ),
                                      Text(
                                        item['value'] ?? '',
                                        style: TextStyle(color: context.textPrimary),
                                      ),
                                    ],
                                  ),
                                ));
                          },
                        ),

                        const SizedBox(height: 50.00),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: context.borderColor),
                            ),
                            const SizedBox(width: 10.00),
                            Text(
                              "নির্বাচিত বিষয়",
                              style: AppTextStyles.body1.copyWith(color: context.textPrimary),
                            ),
                            const SizedBox(width: 10.00),
                            Expanded(
                              child: Divider(color: context.borderColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Center(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children:
                                controller.selectedSubjects.map((subject) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
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
                                    )
                                  ],
                                ),
                                child: Text(
                                  subject.name.toString(),
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                controller.isLoading.value
                    ? CircularProgressIndicator()
                    : Row(
                        children: [
                          Expanded(
                            child: CustomActionButton(
                              text: "প্রশ্ন পড়ুন",
                              onPressed: () async {
                                if (isLoggedIn.value) {
                                  await controller.testExamStart(isExam: false);
                                } else {
                                  Get.toNamed(Routes.AUTH_GATEWAY);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8.00),
                          Expanded(
                            child: CustomActionButton(
                              text: "পরীক্ষা শুরু করুন",
                              onPressed: () async {
                                if (isLoggedIn.value) {
                                  controller.testExamStart(isExam: true);
                                } else {
                                  Get.toNamed(Routes.AUTH_GATEWAY);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
