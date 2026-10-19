import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/home/presentation/home/components/home_section_header.dart';

class HomeQuestionBanksSection extends StatelessWidget {
  final HomeQuestionBanksModel questionBanks;

  const HomeQuestionBanksSection({
    super.key,
    required this.questionBanks,
  });

  @override
  Widget build(BuildContext context) {
    final popular = questionBanks.popularBanks;
    final subjectWise = questionBanks.subjectWiseBanks;

    if (popular.isEmpty && subjectWise.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: 'জনপ্রিয় প্রশ্নব্যাংক',
          subtitle: 'বিগত বছরের ও বিষয়ভিত্তিক সমৃদ্ধ প্রশ্ন ভাণ্ডার',
          icon: Icons.auto_stories_rounded,
          onSeeAll: () {
            if (GoRouter.maybeOf(context) != null) {
              context.push(Routes.questionBank);
            }
          },
        ),

        // ─── Popular Banks Grid ──────────────────────────────────────────────
        if (popular.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: popular.take(4).length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                childAspectRatio: 2.1,
              ),
              itemBuilder: (context, index) {
                final bank = popular[index];
                return GestureDetector(
                  onTap: () {
                    if (GoRouter.maybeOf(context) != null) {
                      context.push(Routes.questionBank);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: context.borderColor.withValues(alpha: 0.6),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(5.r),
                              decoration: BoxDecoration(
                                color: context.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Icon(
                                Icons.folder_open_rounded,
                                size: 14.sp,
                                color: context.primaryColor,
                              ),
                            ),
                            const Spacer(),
                            if (bank.badge != null && bank.badge!.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 1.5.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  bank.badge!,
                                  style: TextStyle(
                                    fontSize: 8.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          bank.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        if (bank.questionCountFormatted != null ||
                            bank.questionCount > 0) ...[
                          SizedBox(height: 2.h),
                          Text(
                            bank.questionCountFormatted ??
                                '${bank.questionCount}টি প্রশ্ন',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        // ─── Subject Wise Banks Horizontal List ──────────────────────────────
        if (subjectWise.isNotEmpty) ...[
          SizedBox(height: 6.h),
          SizedBox(
            height: 38.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: subjectWise.take(6).length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final subject = subjectWise[index];
                return ActionChip(
                  label: Text(
                    subject.title,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                      color: context.primaryColor,
                    ),
                  ),
                  avatar: Icon(
                    Icons.bookmark_outline_rounded,
                    size: 14.sp,
                    color: context.primaryColor,
                  ),
                  backgroundColor: context.primaryColor.withValues(alpha: 0.08),
                  side: BorderSide(
                    color: context.primaryColor.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  onPressed: () {
                    if (GoRouter.maybeOf(context) != null) {
                      context.push(Routes.questionBank);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
