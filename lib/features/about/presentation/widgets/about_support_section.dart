import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lokkha/app/theme/app_colors.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/about_model.dart';

class AboutSupportSection extends StatelessWidget {
  final AboutCommunityAndSupportModel communityAndSupport;

  const AboutSupportSection({
    super.key,
    required this.communityAndSupport,
  });

  Future<void> _launch(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final helpline = communityAndSupport.helpline;
    final social = communityAndSupport.socialChannels;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: LightThemeColors.primaryColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'যোগাযোগ ও হেল্পলাইন',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Helpline Card
        if (helpline != null)
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (helpline.heading.isNotEmpty)
                  Text(
                    helpline.heading,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                if (helpline.subheading.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    helpline.subheading,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: context.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                if (helpline.activeHours.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14.sp,
                          color: const Color(0xFFF59E0B),
                        ),
                        Flexible(
                          child: Text(
                            'সক্রিয় সময়: ${helpline.activeHours}',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 14.h),
                const Divider(height: 1),
                SizedBox(height: 12.h),

                // Phones
                ...helpline.phones.map((phone) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: InkWell(
                      onTap: () => _makePhoneCall(phone),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(7.r),
                              decoration: BoxDecoration(
                                color: LightThemeColors.primaryColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.phone_forwarded_rounded,
                                color: LightThemeColors.primaryColor,
                                size: 16.sp,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                phone,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: LightThemeColors.primaryColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: LightThemeColors.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                'কল করুন',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: LightThemeColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Emails
                ...helpline.emails.map((email) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: InkWell(
                      onTap: () => _sendEmail(email),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(7.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.email_rounded,
                                color: const Color(0xFF3B82F6),
                                size: 16.sp,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                email,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: context.textPrimary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 13.sp,
                              color: context.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Address
                if (helpline.address.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(7.r),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: Colors.grey[700],
                          size: 16.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          helpline.address,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            color: context.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

        SizedBox(height: 16.h),

        // Social Channels
        if (social != null) ...[
          Text(
            'সোশ্যাল কমিউনিটি',
            style: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              // Facebook Page
              if (social.facebookPage?.url.isNotEmpty == true)
                Expanded(
                  child: _SocialChannelCard(
                    icon: FontAwesomeIcons.facebook,
                    iconColor: const Color(0xFF1877F2),
                    title: 'ফেসবুক পেজ',
                    subtitle: 'প্রতিদিনের আপডেট',
                    onTap: () => _launch(social.facebookPage!.url),
                  ),
                ),
              SizedBox(width: 10.w),

              // Facebook Group
              if (social.facebookGroup?.url.isNotEmpty == true)
                Expanded(
                  child: _SocialChannelCard(
                    icon: FontAwesomeIcons.users,
                    iconColor: const Color(0xFF0284C7),
                    title: 'ফেসবুক গ্রুপ',
                    subtitle: 'ডিসকাশন ফোরাম',
                    onTap: () => _launch(social.facebookGroup!.url),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              // YouTube
              if (social.youtube?.url.isNotEmpty == true)
                Expanded(
                  child: _SocialChannelCard(
                    icon: FontAwesomeIcons.youtube,
                    iconColor: const Color(0xFFFF0000),
                    title: 'ইউটিউব',
                    subtitle: 'ফ্রি ক্লাস ও গাইডলাইন',
                    onTap: () => _launch(social.youtube!.url),
                  ),
                ),
              SizedBox(width: 10.w),

              // WhatsApp
              if (social.whatsapp?.url.isNotEmpty == true)
                Expanded(
                  child: _SocialChannelCard(
                    icon: FontAwesomeIcons.whatsapp,
                    iconColor: const Color(0xFF25D366),
                    title: 'হোয়াটসঅ্যাপ',
                    subtitle: 'সরাসরি চ্যাট',
                    onTap: () => _launch(social.whatsapp!.url),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SocialChannelCard extends StatelessWidget {
  final dynamic icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SocialChannelCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: iconColor.withValues(alpha: isDark ? 0.3 : 0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: isDark ? 0.05 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            FaIcon(icon, color: iconColor, size: 22.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: context.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
