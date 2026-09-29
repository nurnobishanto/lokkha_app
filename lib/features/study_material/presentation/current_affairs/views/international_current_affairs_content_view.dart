import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/study_material/study_material.dart';

import 'package:lokkha/shared/shared.dart';

class InternationalCurrentAffairsContentView extends StatelessWidget {
  const InternationalCurrentAffairsContentView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InternationalCurrentAffairsController());

    return Scaffold(
      floatingActionButton: CircleAvatar(
        backgroundColor: LightThemeColors.primaryColor,
        radius: 28,
        child: IconButton(
          icon: const Icon(Icons.calendar_month, color: Colors.white),
          onPressed: () async {
            if (havePackage.value) {
              DateTime? pickedDate = await showDatePicker(
                context: Get.context!,
                initialDate: null,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                String formattedDate =
                    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                controller.fetchCurrentAffairs("", date: formattedDate);
              }
            } else {
              Get.dialog(PackageRequiredPopup());
            }
          },
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = controller.model.value.currentAffairs?.data;

        if (items!.isEmpty) {
          return const Center(child: Text('No Data Found'));
        }

        return ListView.builder(
          itemCount: items.length + 1, // +1 for Load More
          itemBuilder: (context, index) {
            if (index == items.length) {
              // Load More button
              if (controller.currentPage.value <
                  (controller.model.value.currentAffairs?.lastPage ?? 0)) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        controller.fetchCurrentAffairs(
                          "",
                          page: controller.currentPage.value + 1,
                        );
                      },
                      child: Container(
                        height: 40,
                        width: Get.width / 2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: LightThemeColors.primaryColor,
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'আরও দেখুন',
                            style: TextStyle(
                              color: LightThemeColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }

            final data = items[index];
            final bool isLocked = !havePackage.value && index > 0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header (always visible)
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      10.0.w.width,
                      Center(
                        child: Text(
                          data.date ?? "",
                          style: AppTextStyles.heading4.copyWith(color: context.textPrimary),
                        ),
                      ),
                      10.0.w.width,
                      const Expanded(child: Divider()),
                    ],
                  ),
                  10.0.h.height,

                  // Questions
                  Column(
                    children: List.generate(
                      data.questions?.length ?? 0,
                      (i) {
                        var question = data.questions![i];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Question title
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.arrow_right,
                                  size: 15.0,
                                  color: context.textSecondary,
                                ),
                                const SizedBox(width: 5.0),
                                Expanded(
                                  child: HtmlWidget(
                                    question.title ?? "",
                                    textStyle: AppTextStyles.heading5.copyWith(color: context.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Correct answers (blur only the answer value)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: question.options
                                      ?.where(
                                          (option) => option.isCorrect == true)
                                      .map(
                                        (option) => Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 4.0),
                                            child: RichText(
                                              text: TextSpan(
                                                style: AppTextStyles.body1
                                                    .copyWith(
                                                  color: context.textPrimary,
                                                ),
                                                children: [
                                                  // Label always visible
                                                  TextSpan(
                                                    text: 'উত্তর: ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: context.textPrimary),
                                                  ),

                                                  // Answer text (blurred if locked)
                                                  WidgetSpan(
                                                    child: isLocked
                                                        ? Stack(
                                                            children: [
                                                              Text(
                                                                option.value ??
                                                                    "",
                                                                style:
                                                                    AppTextStyles
                                                                        .body1.copyWith(color: context.textSecondary),
                                                              ),
                                                              Positioned.fill(
                                                                child:
                                                                    ClipRRect(
                                                                  child:
                                                                      BackdropFilter(
                                                                    filter: ImageFilter.blur(
                                                                        sigmaX:
                                                                            5,
                                                                        sigmaY:
                                                                            5),
                                                                    child:
                                                                        Container(
                                                                      color: Colors
                                                                          .transparent,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : Text(
                                                            option.value ?? "",
                                                            style: AppTextStyles
                                                                .body1.copyWith(color: context.textSecondary),
                                                          ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList() ??
                                  [],
                            ),

                            // Explanation link
                            if (question.explanation != null)
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () {
                                    if (havePackage.value) {
                                      ExplanationDialog.show(question);
                                    } else {
                                      Get.dialog(PackageRequiredPopup());
                                    }
                                  },
                                  child: Text(
                                    "ব্যাখ্যা দেখুন →",
                                    style: AppTextStyles.body1.copyWith(
                                      color: LightThemeColors.primaryColor,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(height: 10.0),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
