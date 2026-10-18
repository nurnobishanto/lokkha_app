import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  String _cleanPrice(String price) {
    var p = price.trim();
    if (p.contains('.')) {
      p = p.replaceAll(RegExp(r'\.0+$'), '');
    }
    return p.isEmpty ? '0' : p;
  }

  @override
  Widget build(BuildContext context) {
    final cleanRegular = _cleanPrice(regularPrice);
    final cleanSale = _cleanPrice(salePrice);

    final double? regVal = double.tryParse(cleanRegular);
    final double? saleVal = double.tryParse(cleanSale);
    final bool showDiscount = regVal != null && saleVal != null && regVal > saleVal && saleVal > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(
            color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
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
                blurRadius: 10,
                offset: const Offset(0, 3),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Course Banner Image
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                child: AspectRatio(
                  aspectRatio: 13 / 9,
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: context.isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF1F5F9),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: context.isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            child: Center(
                              child: Icon(
                                Icons.school_rounded,
                                size: 32.sp,
                                color: const Color(0xFF006A4E),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: context.isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                          child: Center(
                            child: Icon(
                              Icons.school_rounded,
                              size: 32.sp,
                              color: const Color(0xFF006A4E),
                            ),
                          ),
                        ),
                ),
              ),

              // 2. Title and Price Section
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Course Title (2 lines max)
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          color: context.textPrimary,
                        ),
                      ),

                      // Pricing & Star Rating Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (showDiscount) ...[
                                  Flexible(
                                    child: Text(
                                      '৳$cleanRegular',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10.5.sp,
                                        color: const Color(0xFF94A3B8),
                                        decoration: TextDecoration.lineThrough,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                ],
                                Text(
                                  '৳$cleanSale',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: const Color(0xFFF59E0B),
                                size: 15.sp,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                rating.trim().isEmpty ? '5' : rating.trim(),
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
