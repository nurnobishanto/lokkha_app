import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/modules/random_question/controller/random_question_controller.dart';
import 'package:lokkha/app/views/widgets/explanation_dialog.dart';
import 'package:lokkha/config/extensions/common_extension.dart';
import 'package:lokkha/config/theme/light_theme_colors.dart';
import 'package:lokkha/styles/text_style.dart';

import '../../../components/custom_action_button.dart';
import '../../../components/custom_transparent_divider.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../helper/global.dart';

class RandomQuestionSelector extends StatelessWidget {
  final RxInt selectedOptionIndex = RxInt(-1);

  RandomQuestionSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RandomQuestionController());

    return Obx(() {
      final question = controller.randomQuestionModel.value.question;

      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (question == null) {
        return const Center(child: Text("লক্ষ্য প্রিমিয়াম প্রয়োজন"));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitleWithDivider(title: 'এখনি উত্তর দিন'),
          10.h.height,
          Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  border: Border.all(
                    color: context.borderColor,
                    width: 0.8,
                  ),
                  color: context.isDark
                      ? context.cardColor
                      : LightThemeColors.softBg),
              child: Column(
                children: [
                  HtmlWidget(
                    question.title ?? '',
                    textStyle: AppTextStyles.heading4.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 13.sp,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 7),
                  if (question.options != null && question.options!.isNotEmpty)
                    ...List.generate(question.options!.length, (index) {
                      final option = question.options![index];
                      return Obx(() => Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  controller.isAnswerSelected.value = true;
                                  selectedOptionIndex.value = index;
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 3.4),
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: selectedOptionIndex.value == index
                                        ? (option.isCorrect == true
                                            ? (context.isDark
                                                ? const Color(0xFF064E3B)
                                                : Colors.greenAccent.shade100)
                                            : (context.isDark
                                                ? const Color(0xFF7F1D1D)
                                                : Colors.red))
                                        : context.cardColor,
                                    border: Border.all(
                                      color: context.borderColor,
                                      width: 0.8,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: context.isDark
                                            ? Colors.black.withValues(alpha: 0.2)
                                            : Colors.grey.withValues(alpha: 0.1),
                                        spreadRadius: 0,
                                        blurRadius: 1,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: HtmlWidget(
                                          option.value ?? '',
                                          textStyle:
                                              AppTextStyles.body1.copyWith(
                                            color: selectedOptionIndex.value ==
                                                    index
                                                ? (option.isCorrect == true
                                                    ? (context.isDark
                                                        ? Colors.white
                                                        : Colors.black)
                                                    : Colors.white)
                                                : context.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ));
                    }),
                ],
              )),
          8.h.height,
          Obx(() {
            if (selectedOptionIndex.value != -1) {
              final selectedOption =
                  question.options![selectedOptionIndex.value];
              if (selectedOption.isCorrect == true) {
                MySharedPref.incrementRandomQuestionCheck();
                return Row(
                  children: [
                    if (question.explanation?.isNotEmpty ?? false)
                      Expanded(
                        child: CustomActionButton(
                          text: "ব্যাখ্যা দেখুন",
                          onPressed: () {
                            ExplanationDialog.show(question);
                          },
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    10.horizontalSpace,
                    Expanded(
                      child: CustomActionButton(
                        text: "নতুন প্রশ্ন →",
                        onPressed: () async {
                          selectedOptionIndex.value = -1;
                          controller.getRandomQuestion(forceNew: true);
                          int check =
                              await MySharedPref.getRandomQuestionCheck();
                          if (!isLoggedIn.value) {
                            controller.getRandomQuestion(forceNew: true);
                          } else if (check <= 3) {
                            controller.getRandomQuestion(forceNew: true);
                          } else {
                            // Get.to(const AllPackages());
                          }
                        },
                      ),
                    ),
                  ],
                );
              }
            }
            return const SizedBox.shrink();
          }),
        ],
      );
    });
  }
}
