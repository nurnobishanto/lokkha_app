import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';

class HomePromoBanner extends StatelessWidget {
  const HomePromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE8F5E9), // Light mint green
            Color(0xFFC8E6C9),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFF81C784).withOpacity(0.5),
          width: 0.8,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (GoRouter.maybeOf(context) != null) {
            context.push(Routes.courses);
          }
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'অপরাজিতা',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'স্পেশাল ব্যাচে ভর্তি চলছে',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_rounded,
                size: 28.sp,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
