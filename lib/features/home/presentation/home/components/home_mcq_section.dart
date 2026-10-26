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
    final isDark = context.isDark;
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
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      padding: EdgeInsets.fromLTRB(12.w, 11.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.28 : 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── 1. Minimal Professional Header ────────────────────────────────
          Row(
            children: [
              Container(
                width: 3.5.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A8D6F),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  'কারেন্ট অ্যাফেয়ার্স',
                  style: context.sectionTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Refresh Button
              InkWell(
                borderRadius: BorderRadius.circular(8.r),
                onTap: () {
                  setState(() {
                    _fallbackSelectedIndex = null;
                  });
                  ref
                      .read(randomQuestionNotifierProvider.notifier)
                      .fetchRandomQuestion(refresh: true);
                },
                child: Container(
                  padding: EdgeInsets.all(5.r),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 16.r,
                    color: context.textSecondary,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              // MCQ Pill Tag
              InkWell(
                borderRadius: BorderRadius.circular(8.r),
                onTap: () {
                  if (GoRouter.maybeOf(context) != null) {
                    context.push(Routes.currentAffairs);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 9.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A8D6F).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: const Color(0xFF2A8D6F).withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5.r,
                        height: 5.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2A8D6F),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'MCQ',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF006A4E),
                          letterSpacing: 0.3,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 9.h),

          // ─── 2. Clean Highlighted Question Box ─────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A).withValues(alpha: 0.65)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155).withValues(alpha: 0.7)
                    : const Color(0xFFF1F5F9),
                width: 1,
              ),
            ),
            child: HtmlWidget(
              HtmlSanitizer.formatForDisplay(
                questionText,
                isDark: isDark,
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
          ),

          SizedBox(height: 9.h),

          // ─── 3. Minimal Outlined Options List ──────────────────────────────
          ...List.generate(options.length, (index) {
            final isSelected = selectedOptionIndex == index;
            final isCorrect = index == rightAnswerIndex;

            Color tileBg = isDark
                ? const Color(0xFF1E293B)
                : Colors.white;
            Color tileBorder = isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0);
            Color textColor = context.textPrimary;

            if (isAnswerRevealed) {
              if (isSelected && isCorrect) {
                tileBg = const Color(0xFF10B981)
                    .withValues(alpha: isDark ? 0.18 : 0.1);
                tileBorder = const Color(0xFF10B981);
                textColor = isDark
                    ? const Color(0xFF6EE7B7)
                    : const Color(0xFF065F46);
              } else if (isSelected && !isCorrect) {
                tileBg = const Color(0xFFEF4444)
                    .withValues(alpha: isDark ? 0.18 : 0.08);
                tileBorder = const Color(0xFFEF4444);
                textColor = isDark
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFF991B1B);
              } else if (isCorrect) {
                tileBg = const Color(0xFF10B981)
                    .withValues(alpha: isDark ? 0.12 : 0.07);
                tileBorder = const Color(0xFF10B981).withValues(alpha: 0.65);
                textColor = isDark
                    ? const Color(0xFF6EE7B7)
                    : const Color(0xFF065F46);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == options.length - 1 ? 0 : 6.h,
              ),
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
                borderRadius: BorderRadius.circular(9.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 11.w,
                    vertical: 9.h,
                  ),
                  decoration: BoxDecoration(
                    color: tileBg,
                    borderRadius: BorderRadius.circular(9.r),
                    border: Border.all(
                      color: tileBorder,
                      width: isAnswerRevealed && (isSelected || isCorrect)
                          ? 1.2
                          : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: HtmlWidget(
                          HtmlSanitizer.formatForDisplay(
                            options[index],
                            isDark: isDark,
                          ),
                          textStyle: context.bodyPrimary.copyWith(
                            fontSize: 13.sp,
                            fontWeight: isAnswerRevealed &&
                                    (isSelected || isCorrect)
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: textColor,
                            height: 1.25,
                          ),
                          customStylesBuilder: (element) {
                            if (element.localName == 'p') {
                              return {'margin': '0', 'padding': '0'};
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 8.w),
                      if (isAnswerRevealed && isCorrect)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16.sp,
                          color: const Color(0xFF10B981),
                        )
                      else if (isAnswerRevealed && isSelected && !isCorrect)
                        Icon(
                          Icons.cancel_rounded,
                          size: 16.sp,
                          color: const Color(0xFFEF4444),
                        )
                      else
                        Container(
                          width: 15.r,
                          height: 15.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF475569)
                                  : const Color(0xFFCBD5E1),
                              width: 1.3,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // ─── 4. Explanation Box (if available and answered) ────────────────
          if (isAnswerRevealed &&
              explanationText != null &&
              explanationText.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isDark
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
                        size: 13.5.sp,
                        color: const Color(0xFFF59E0B),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'ব্যাখ্যা',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  HtmlWidget(
                    HtmlSanitizer.formatForDisplay(
                      explanationText,
                      isDark: isDark,
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

          // ─── 5. Next Question Prompt on Answer ─────────────────────────────
          if (isAnswerRevealed) ...[
            SizedBox(height: 6.h),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                borderRadius: BorderRadius.circular(7.r),
                onTap: () {
                  setState(() {
                    _fallbackSelectedIndex = null;
                  });
                  ref
                      .read(randomQuestionNotifierProvider.notifier)
                      .fetchRandomQuestion(refresh: true);
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A8D6F).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'পরবর্তী প্রশ্ন',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF006A4E),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 13.sp,
                        color: isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF006A4E),
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
