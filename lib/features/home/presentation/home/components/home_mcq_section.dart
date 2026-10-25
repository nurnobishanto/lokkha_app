import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/question_bank/presentation/providers/random_question_notifier.dart';

class HomeMcqSection extends ConsumerStatefulWidget {
  final HomeCurrentAffairsModel? currentAffairs;

  const HomeMcqSection({
    super.key,
    this.currentAffairs,
  });

  @override
  ConsumerState<HomeMcqSection> createState() => _HomeMcqSectionState();
}

class _HomeMcqSectionState extends ConsumerState<HomeMcqSection> {
  int? _fallbackSelectedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(randomQuestionNotifierProvider).question == null) {
        ref.read(randomQuestionNotifierProvider.notifier).fetchRandomQuestion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final randomState = ref.watch(randomQuestionNotifierProvider);
    final question = randomState.question;

    final affairItem = widget.currentAffairs?.nationalItems.isNotEmpty == true
        ? widget.currentAffairs!.nationalItems.first
        : (widget.currentAffairs?.internationalItems.isNotEmpty == true
            ? widget.currentAffairs!.internationalItems.first
            : null);

    // Question text: priority to random question from API, then fallback to affairItem / default
    final String questionText;
    final List<String> options;
    final int rightAnswerIndex;
    final int? selectedOptionIndex;
    final bool isAnswerRevealed;
    final String? explanationText;

    if (question != null && question.options.isNotEmpty) {
      questionText = question.title.trim().isNotEmpty
          ? question.title
          : (question.cleanTitle.isNotEmpty
              ? question.cleanTitle
              : 'দুদক-এর পূর্ণরূপ কী?');
      options = question.options.map((e) => e.displayOption).toList();
      rightAnswerIndex = question.rightAnswerIndex ?? 0;
      selectedOptionIndex = randomState.selectedOptionIndex;
      isAnswerRevealed = randomState.isAnswerRevealed;
      explanationText = question.explanation;
    } else {
      questionText = (affairItem?.question != null &&
              affairItem!.question!.trim().isNotEmpty)
          ? affairItem.question!
          : 'দুদক-এর পূর্ণরূপ কী?';

      options = [
        (affairItem?.option1 != null && affairItem!.option1!.isNotEmpty)
            ? affairItem.option1!
            : 'A) দুর্নীতি দমন কমিশন',
        (affairItem?.option2 != null && affairItem!.option2!.isNotEmpty)
            ? affairItem.option2!
            : 'B) দুর্যোগ উন্নয়ন কেন্দ্র',
        (affairItem?.option3 != null && affairItem!.option3!.isNotEmpty)
            ? affairItem.option3!
            : 'C) দুর্নীতি উন্নয়ন কমিটি',
        (affairItem?.option4 != null && affairItem!.option4!.isNotEmpty)
            ? affairItem.option4!
            : 'D) দুর্যোগ দমন কমিশন',
      ];

      rightAnswerIndex = (affairItem?.rightAnswer != null &&
              affairItem!.rightAnswer! >= 1 &&
              affairItem.rightAnswer! <= 4)
          ? (affairItem.rightAnswer! - 1)
          : 0;
      selectedOptionIndex = _fallbackSelectedIndex;
      isAnswerRevealed = _fallbackSelectedIndex != null;
      explanationText = affairItem?.explanation;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: context.isDark
              ? const Color(0xFF334155)
              : const Color(0xFFF1F5F9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDark ? 0.35 : 0.06,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDark ? 0.2 : 0.02,
            ),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header: Title + Reload + MCQ Badge ────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'কারেন্ট অ্যাফেয়ার্স',
                  style: context.sectionTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Refresh / Next Random Question icon button
                  InkWell(
                    borderRadius: BorderRadius.circular(20.r),
                    onTap: () {
                      setState(() {
                        _fallbackSelectedIndex = null;
                      });
                      ref
                          .read(randomQuestionNotifierProvider.notifier)
                          .fetchRandomQuestion(refresh: true);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 4.h,
                      ),
                      child: Icon(
                        Icons.refresh_rounded,
                        size: 18.r,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  InkWell(
                    onTap: () {
                      if (GoRouter.maybeOf(context) != null) {
                        context.push(Routes.currentAffairs);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'MCQ',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // ─── Question Text ─────────────────────────────────────────────────
          HtmlWidget(
            HtmlSanitizer.formatForDisplay(
              questionText,
              isDark: context.isDark,
            ),
            textStyle: context.body1.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
            customStylesBuilder: (element) {
              if (element.localName == 'p') {
                return {'margin': '0', 'padding': '0'};
              }
              return null;
            },
          ),

          SizedBox(height: 12.h),

          // ─── Options ───────────────────────────────────────────────────────
          ...List.generate(options.length, (index) {
            final isSelected = selectedOptionIndex == index;
            final isCorrect = index == rightAnswerIndex;

            Color btnBgColor = context.isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9);
            Color borderColor = Colors.transparent;
            Color textColor = context.textPrimary;

            if (isAnswerRevealed) {
              if (isSelected && isCorrect) {
                btnBgColor = const Color(0xFF10B981).withValues(alpha: 0.15);
                borderColor = const Color(0xFF10B981);
                textColor = const Color(0xFF047857);
              } else if (isSelected && !isCorrect) {
                btnBgColor = const Color(0xFFEF4444).withValues(alpha: 0.15);
                borderColor = const Color(0xFFEF4444);
                textColor = const Color(0xFFB91C1C);
              } else if (isCorrect) {
                btnBgColor = const Color(0xFF10B981).withValues(alpha: 0.1);
                borderColor = const Color(0xFF10B981).withValues(alpha: 0.5);
                textColor = const Color(0xFF047857);
              }
            }

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: InkWell(
                onTap: () {
                  if (question != null) {
                    ref
                        .read(randomQuestionNotifierProvider.notifier)
                        .selectOption(index);
                  } else {
                    setState(() {
                      _fallbackSelectedIndex = index;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: btnBgColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: HtmlWidget(
                          HtmlSanitizer.formatForDisplay(
                            options[index],
                            isDark: context.isDark,
                          ),
                          textStyle: context.bodyPrimary.copyWith(
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                          customStylesBuilder: (element) {
                            final styles = <String, String>{
                              'text-align': 'center',
                            };
                            if (element.localName == 'p') {
                              styles['margin'] = '0';
                              styles['padding'] = '0';
                            }
                            return styles;
                          },
                        ),
                      ),
                      if (isAnswerRevealed && isCorrect) ...[
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16.sp,
                          color: const Color(0xFF10B981),
                        ),
                      ] else if (isAnswerRevealed && isSelected && !isCorrect) ...[
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.cancel_rounded,
                          size: 16.sp,
                          color: const Color(0xFFEF4444),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),

          // ─── Explanation Box (if available and answered) ───────────────────
          if (isAnswerRevealed &&
              explanationText != null &&
              explanationText.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: context.isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: context.borderColor.withValues(alpha: 0.5),
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 14.sp,
                        color: const Color(0xFFF59E0B),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        'ব্যাখ্যা',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  HtmlWidget(
                    HtmlSanitizer.formatForDisplay(
                      explanationText,
                      isDark: context.isDark,
                    ),
                    textStyle: TextStyle(
                      fontSize: 11.5.sp,
                      color: context.textSecondary,
                      height: 1.35,
                    ),
                    customStylesBuilder: (element) {
                      if (element.localName == 'p') {
                        return {'margin': '0', 'padding': '0'};
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],

          // ─── Next Question Prompt on Answer ────────────────────────────────
          if (isAnswerRevealed) ...[
            SizedBox(height: 4.h),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                borderRadius: BorderRadius.circular(8.r),
                onTap: () {
                  setState(() {
                    _fallbackSelectedIndex = null;
                  });
                  ref
                      .read(randomQuestionNotifierProvider.notifier)
                      .fetchRandomQuestion(refresh: true);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'পরবর্তী প্রশ্ন',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF059669),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14.sp,
                        color: const Color(0xFF059669),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
