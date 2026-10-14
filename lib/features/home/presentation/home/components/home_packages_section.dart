import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/home/presentation/home/components/home_section_header.dart';

class HomePackagesSection extends StatelessWidget {
  final List<HomePackageItem> packages;

  const HomePackagesSection({
    super.key,
    required this.packages,
  });

  String _formatBanglaPrice(num price) {
    const enToBn = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
    };
    final formatted = price.toInt().toString();
    return formatted.split('').map((c) => enToBn[c] ?? c).join();
  }

  @override
  Widget build(BuildContext context) {
    if (packages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: 'প্রিমিয়াম প্যাকেজ সমূহ',
          subtitle: 'সীমাহীন মডেল টেস্ট ও মেন্টর সাপোর্টের সেরা সুযোগ',
          icon: Icons.diamond_outlined,
          onSeeAll: () {
            if (GoRouter.maybeOf(context) != null) {
              context.push(Routes.packages);
            }
          },
        ),
        SizedBox(
          height: 245.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            itemCount: packages.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final pkg = packages[index];
              return Container(
                width: 250.w,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: pkg.isPopular
                        ? context.primaryColor
                        : context.borderColor.withOpacity(0.6),
                    width: pkg.isPopular ? 1.5 : 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: pkg.isPopular
                          ? context.primaryColor.withOpacity(0.08)
                          : Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pkg.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                        if (pkg.isPopular)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: context.primaryColor,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'জনপ্রিয়',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            pkg.durationLabel,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: context.primaryColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (pkg.regularPrice > pkg.discountedPrice) ...[
                          Text(
                            '৳${_formatBanglaPrice(pkg.regularPrice)}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              decoration: TextDecoration.lineThrough,
                              color: context.textSecondary,
                            ),
                          ),
                          SizedBox(width: 6.w),
                        ],
                        Text(
                          '৳${_formatBanglaPrice(pkg.discountedPrice)}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: context.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 14),
                    Expanded(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pkg.features.take(3).length,
                        itemBuilder: (context, fIndex) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 13.sp,
                                  color: const Color(0xFF10B981),
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    pkg.features[fIndex],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 6.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (GoRouter.maybeOf(context) != null) {
                            context.push(Routes.packages);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pkg.isPopular
                              ? context.primaryColor
                              : context.primaryColor.withOpacity(0.12),
                          foregroundColor: pkg.isPopular
                              ? Colors.white
                              : context.primaryColor,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          'প্যাকেজটি বেছে নিন',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
