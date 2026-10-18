import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/app/theme/app_colors.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/about_model.dart';

class AboutCtaSection extends StatelessWidget {
  final AboutCtaModel cta;

  const AboutCtaSection({super.key, required this.cta});

  void _handleButtonAction(BuildContext context, AboutButtonItem? button) {
    if (button == null) return;
    final url = button.url.trim();

    if (url.startsWith('http://') || url.startsWith('https://')) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    if (url == '/exam' || url == 'exam' || url.contains('exam')) {
      context.go(Routes.examCategory);
    } else if (url == '/register' || url == 'register' || url.contains('register')) {
      if (isLoggedIn.value) {
        context.go(Routes.dashboardPortal);
      } else {
        context.pushNamed(Routes.authGateway);
      }
    } else {
      context.push(url.startsWith('/') ? url : '/$url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            LightThemeColors.primaryColor,
            Color(0xFF1E6B54),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: LightThemeColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rocket_launch_rounded,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            cta.heading.isNotEmpty
                ? cta.heading
                : 'আজই শুরু করুন আপনার সফল ক্যারিয়ার যাত্রা!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          if (cta.subheading.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              cta.subheading,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ],
          SizedBox(height: 20.h),

          // Primary Button
          if (cta.buttonPrimary != null && cta.buttonPrimary!.text.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleButtonAction(context, cta.buttonPrimary),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: LightThemeColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  cta.buttonPrimary!.text,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: LightThemeColors.primaryColor,
                  ),
                ),
              ),
            ),

          // Secondary Button
          if (cta.buttonSecondary != null && cta.buttonSecondary!.text.isNotEmpty) ...[
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _handleButtonAction(context, cta.buttonSecondary),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 1.2),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  cta.buttonSecondary!.text,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
