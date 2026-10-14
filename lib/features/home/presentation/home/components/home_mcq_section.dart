import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';

class HomeMcqSection extends StatefulWidget {
  final HomeCurrentAffairsModel? currentAffairs;

  const HomeMcqSection({
    super.key,
    this.currentAffairs,
  });

  @override
  State<HomeMcqSection> createState() => _HomeMcqSectionState();
}

class _HomeMcqSectionState extends State<HomeMcqSection> {
  int? _selectedOptionIndex;

  @override
  Widget build(BuildContext context) {
    final affairItem = widget.currentAffairs?.nationalItems.isNotEmpty == true
        ? widget.currentAffairs!.nationalItems.first
        : (widget.currentAffairs?.internationalItems.isNotEmpty == true
            ? widget.currentAffairs!.internationalItems.first
            : null);

    // Fallback question & options matching Image 3 if API item doesn't have options
    final questionText = (affairItem?.question != null &&
            affairItem!.question!.trim().isNotEmpty)
        ? affairItem.question!
        : 'দুদক-এর পূর্ণরূপ কী?';

    final options = [
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

    final rightAnswerIndex = (affairItem?.rightAnswer != null &&
            affairItem!.rightAnswer! >= 1 &&
            affairItem.rightAnswer! <= 4)
        ? (affairItem.rightAnswer! - 1)
        : 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: context.borderColor.withOpacity(0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header: Title + MCQ Badge ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'কারেন্ট অ্যাফেয়ার্স',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (GoRouter.maybeOf(context) != null) {
                    context.push(Routes.currentAffairs);
                  }
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.4),
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

          SizedBox(height: 10.h),

          // ─── Question Text ─────────────────────────────────────────────────
          Text(
            questionText,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
              height: 1.35,
            ),
          ),

          SizedBox(height: 12.h),

          // ─── 4 Options ─────────────────────────────────────────────────────
          ...List.generate(options.length, (index) {
            final isSelected = _selectedOptionIndex == index;
            final isAnswerRevealed = _selectedOptionIndex != null;
            final isCorrect = index == rightAnswerIndex;

            Color btnBgColor = context.isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9);
            Color borderColor = Colors.transparent;
            Color textColor = context.textPrimary;

            if (isAnswerRevealed) {
              if (isSelected && isCorrect) {
                btnBgColor = const Color(0xFF10B981).withOpacity(0.15);
                borderColor = const Color(0xFF10B981);
                textColor = const Color(0xFF047857);
              } else if (isSelected && !isCorrect) {
                btnBgColor = const Color(0xFFEF4444).withOpacity(0.15);
                borderColor = const Color(0xFFEF4444);
                textColor = const Color(0xFFB91C1C);
              } else if (isCorrect) {
                btnBgColor = const Color(0xFF10B981).withOpacity(0.1);
                borderColor = const Color(0xFF10B981).withOpacity(0.5);
                textColor = const Color(0xFF047857);
              }
            }

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedOptionIndex = index;
                  });
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
                        child: Text(
                          options[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
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
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
