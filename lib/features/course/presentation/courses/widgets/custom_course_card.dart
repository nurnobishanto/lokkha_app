import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/core/core.dart';

class CustomCourseCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String regularPrice;
  final String salePrice;
  final String rating;
  final int? enrolledCount;
  final String? duration;
  final VoidCallback onPressed;

  const CustomCourseCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.regularPrice,
    required this.salePrice,
    required this.rating,
    this.enrolledCount,
    this.duration,
    required this.onPressed,
  });

  String formatPrice(String price) =>
      price.contains('.') ? price.replaceAll('.00', '') : price;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        //width: 0.45.sw,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: context.borderColor,
            width: context.isDark ? 0.8 : 0.4,
          ),
          boxShadow: [
            BoxShadow(
              color: context.isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : Colors.black12,
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
              child: AspectRatio(
                aspectRatio: 17 / 9,
                child: CustomNetworkImageCard(imageUrl: imageUrl),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10.h, left: 5.w, right: 5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.7.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                      color: context.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Text(
                        '৳${formatPrice(regularPrice)}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: context.textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '৳${formatPrice(salePrice)}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.star_rounded,
                          color: Colors.amber, size: 13.sp),
                      SizedBox(width: 2.w),
                      Text(
                        rating.padRight(2),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
