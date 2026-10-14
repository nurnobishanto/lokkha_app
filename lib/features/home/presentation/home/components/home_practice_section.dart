import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/home/presentation/home/components/home_section_header.dart';

class HomePracticeSection extends StatelessWidget {
  final HomeCurrentAffairsModel? currentAffairs;
  final HomeVocabularyModel? vocabulary;

  const HomePracticeSection({
    super.key,
    this.currentAffairs,
    this.vocabulary,
  });

  String _cleanHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    final affairItem = currentAffairs?.nationalItems.isNotEmpty == true
        ? currentAffairs!.nationalItems.first
        : (currentAffairs?.internationalItems.isNotEmpty == true
            ? currentAffairs!.internationalItems.first
            : null);

    final vocabItem = vocabulary?.items.isNotEmpty == true
        ? vocabulary!.items.first
        : null;

    if (affairItem == null && vocabItem == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: 'দৈনিক প্রস্তুতি ও শব্দভাণ্ডার',
          subtitle: 'সাম্প্রতিক জ্ঞান ও ভোকাবুলারি নিয়মিত চর্চা করুন',
          icon: Icons.lightbulb_outline_rounded,
        ),

        // ─── Current Affairs Card ───────────────────────────────────────────
        if (affairItem != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.public_rounded,
                              size: 13.sp,
                              color: const Color(0xFF2563EB),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'সাম্প্রতিক বিষয়াবলী',
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (affairItem.dateBn != null)
                        Text(
                          affairItem.dateBn!,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: context.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  if (affairItem.question != null &&
                      affairItem.question!.isNotEmpty)
                    Text(
                      affairItem.question!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                  if (affairItem.explanation != null &&
                      affairItem.explanation!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      _cleanHtml(affairItem.explanation!),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: context.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        if (GoRouter.maybeOf(context) != null) {
                          context.push(Routes.currentAffairs);
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'আরও সাম্প্রতিক তথ্য পড়ুন',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 12.sp,
                            color: const Color(0xFF2563EB),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // ─── Vocabulary Card ─────────────────────────────────────────────────
        if (vocabItem != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.spellcheck_rounded,
                              size: 13.sp,
                              color: const Color(0xFF7C3AED),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'আজকের শব্দ (Vocabulary)',
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF7C3AED),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (vocabItem.category != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: context.borderColor.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            vocabItem.category!,
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.bold,
                              color: context.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        vocabItem.word,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      if (vocabItem.type != null) ...[
                        SizedBox(width: 6.w),
                        Text(
                          '(${vocabItem.type})',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontStyle: FontStyle.italic,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (vocabItem.details.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      vocabItem.details,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w500,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                  if (vocabItem.synonyms.isNotEmpty ||
                      vocabItem.antonyms.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: [
                        if (vocabItem.synonyms.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'Syn: ${vocabItem.synonyms}',
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                color: const Color(0xFF059669),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (vocabItem.antonyms.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'Ant: ${vocabItem.antonyms}',
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                color: const Color(0xFFDC2626),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        if (GoRouter.maybeOf(context) != null) {
                          context.push(Routes.vocabulary);
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'সকল ভোকাবুলারি দেখুন',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF7C3AED),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 12.sp,
                            color: const Color(0xFF7C3AED),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
