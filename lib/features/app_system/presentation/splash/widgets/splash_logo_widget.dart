import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/constants/app_images.dart';

class SplashLogoWidget extends StatelessWidget {
  final double iconSize;

  const SplashLogoWidget({
    super.key,
    this.iconSize = 135,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Squircle App Icon Badge with Book Tag
        SizedBox(
          width: (iconSize + 16).w,
          height: (iconSize + 16).w,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main Green Squircle Icon Badge
              Container(
                width: iconSize.w,
                height: iconSize.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B5D41),
                  borderRadius: BorderRadius.circular(36.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B5D41).withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32.r),
                    child: Image.asset(
                      AssetImagePaths.appIcon,
                      width: iconSize.w,
                      height: iconSize.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Attached White Circular Badge with Open Book Icon
              Positioned(
                bottom: 2.h,
                right: 2.w,
                child: Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: const Color(0xFF0B5D41),
                      size: 22.r,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 18.h),

        // Brand Name (Bengali: লক্ষ্য)
        Text(
          'লক্ষ্য',
          style: TextStyle(
            fontSize: 34.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'BalooDa2',
            color: const Color(0xFF0F172A),
            height: 1.1,
            letterSpacing: 0.5,
          ),
        ),

        SizedBox(height: 6.h),

        // Tagline (Bengali: সঠিক পথে, স্বল্প সময়ে)
        Text(
          'সঠিক পথে, স্বল্প সময়ে',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'BalooDa2',
            color: const Color(0xFF0B5D41),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
