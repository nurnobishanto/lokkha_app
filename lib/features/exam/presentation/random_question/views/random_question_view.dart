import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/exam/presentation/providers/exam_notifier.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/shared/widgets/custom_action_button.dart';
import 'package:lokkha/shared/widgets/custom_transparent_divider.dart';
import 'package:lokkha/shared/widgets/explanation_dialog.dart';

class RandomQuestionSelector extends ConsumerStatefulWidget {
  const RandomQuestionSelector({super.key});

  @override
  ConsumerState<RandomQuestionSelector> createState() =>
      _RandomQuestionSelectorState();
}

class _RandomQuestionSelectorState
    extends ConsumerState<RandomQuestionSelector> {
  int _selectedOptionIndex = -1;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(randomQuestionNotifierProvider);
    final question = state.randomQuestionModel?.question;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (question == null) {
      return const Center(child: Text("লক্ষ্য প্রিমিয়াম প্রয়োজন"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitleWithDivider(title: 'এখনি উত্তর দিন'),
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
                : LightThemeColors.softBg,
          ),
          child: Column(
            children: [
              HtmlWidget(
                HtmlSanitizer.formatForDisplay(
                  question.title ?? '',
                  isDark: context.isDark,
                ),
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
                  final isSelected = _selectedOptionIndex == index;
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(randomQuestionNotifierProvider.notifier)
                              .setIsAnswerSelected(true);
                          setState(() {
                            _selectedOptionIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 3.4),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: isSelected
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
                                  HtmlSanitizer.formatForDisplay(
                                    option.value ?? '',
                                    isDark: context.isDark,
                                  ),
                                  textStyle: AppTextStyles.body1.copyWith(
                                    color: isSelected
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
                  );
                }),
            ],
          ),
        ),
        8.h.height,
        if (_selectedOptionIndex != -1 &&
            question.options != null &&
            _selectedOptionIndex < question.options!.length) ...[
          Builder(
            builder: (context) {
              final selectedOption =
                  question.options![_selectedOptionIndex];
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
                          setState(() {
                            _selectedOptionIndex = -1;
                          });
                          ref
                              .read(randomQuestionNotifierProvider.notifier)
                              .getRandomQuestion(forceNew: true);
                          int check =
                              await MySharedPref.getRandomQuestionCheck();
                          if (!isLoggedIn.value) {
                            ref
                                .read(randomQuestionNotifierProvider.notifier)
                                .getRandomQuestion(forceNew: true);
                          } else if (check <= 3) {
                            ref
                                .read(randomQuestionNotifierProvider.notifier)
                                .getRandomQuestion(forceNew: true);
                          } else {
                            // package navigation
                          }
                        },
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ],
    );
  }
}
