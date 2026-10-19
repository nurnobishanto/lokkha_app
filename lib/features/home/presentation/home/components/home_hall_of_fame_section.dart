import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/home/presentation/home/components/home_section_header.dart';

class HomeHallOfFameSection extends StatelessWidget {
  final List<HomeHallOfFameItem> hallOfFame;
  final HomeKeyFeaturesModel? keyFeatures;

  const HomeHallOfFameSection({
    super.key,
    required this.hallOfFame,
    this.keyFeatures,
  });

  @override
  Widget build(BuildContext context) {
    if (hallOfFame.isEmpty && (keyFeatures == null || keyFeatures!.items.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Hall of Fame (Success Stories) ──────────────────────────────────
        if (hallOfFame.isNotEmpty) ...[
          const HomeSectionHeader(
            title: 'কৃতী শিক্ষার্থীদের অভিজ্ঞতা',
            subtitle: 'লক্ষ অ্যাপ ব্যবহার করে সফল বিসিএস ও ব্যাংক ক্যাডারদের রিভিউ',
            icon: Icons.star_rate_rounded,
          ),
          SizedBox(
            height: 145.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              itemCount: hallOfFame.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                final item = hallOfFame[index];
                return Container(
                  width: 250.w,
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: context.borderColor.withValues(alpha: 0.6),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18.r,
                            backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                            backgroundImage: item.avatarUrl != null &&
                                    item.avatarUrl!.isNotEmpty
                                ? CachedNetworkImageProvider(item.avatarUrl!)
                                : null,
                            child: item.avatarUrl == null || item.avatarUrl!.isEmpty
                                ? Icon(Icons.person,
                                    size: 18.sp, color: context.primaryColor)
                                : null,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimary,
                                  ),
                                ),
                                if (item.designation != null) ...[
                                  SizedBox(height: 1.h),
                                  Text(
                                    item.designation!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: context.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 14.sp,
                                color: const Color(0xFFF59E0B),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                item.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (item.reviewText != null && item.reviewText!.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Expanded(
                          child: Text(
                            '"${item.reviewText!}"',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontStyle: FontStyle.italic,
                              color: context.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],

        // ─── Key Features ────────────────────────────────────────────────────
        if (keyFeatures != null && keyFeatures!.items.isNotEmpty) ...[
          SizedBox(height: 10.h),
          HomeSectionHeader(
            title: keyFeatures!.heading ?? 'কেন লক্ষ অ্যাপ সেরা?',
            subtitle: keyFeatures!.subheading ?? 'আধুনিক ও সমন্বিত প্রযুক্তির অনন্য বৈশিষ্ট্য',
            icon: Icons.verified_outlined,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: keyFeatures!.items.take(4).length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
                childAspectRatio: 2.3,
              ),
              itemBuilder: (context, index) {
                final feat = keyFeatures!.items[index];
                return Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: context.borderColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          feat.numberBadge.isNotEmpty
                              ? feat.numberBadge
                              : '${index + 1}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: context.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              feat.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              feat.desc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
