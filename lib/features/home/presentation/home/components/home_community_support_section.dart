import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/home/presentation/home/components/home_section_header.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeCommunitySupportSection extends StatelessWidget {
  final HomeCommunitySupportModel? communitySupport;
  final HomeAboutSectionModel? aboutSection;

  const HomeCommunitySupportSection({
    super.key,
    this.communitySupport,
    this.aboutSection,
  });

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.trim().isEmpty) return;
    try {
      final uri = Uri.parse(urlString.trim());
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _callPhone(String? phone) async {
    if (phone == null || phone.trim().isEmpty) return;
    try {
      final uri = Uri.parse('tel:${phone.trim()}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final support = communitySupport;
    if (support == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: support.sectionTitle ?? 'সাপোর্ট এবং কমিউনিটি',
          subtitle: support.sectionSubtitle ?? 'আপনার শিক্ষা যাত্রায় আমরা আছি আপনার সাথে',
          icon: Icons.support_agent_rounded,
        ),

        // ─── Direct Call Card ─────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: context.isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
              ),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone_in_talk_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        support.callCardTitle ?? 'হটলাইনে কল করুন সরাসরি',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      if (support.officeHours != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          'অফিস সময়: ${support.officeHours}',
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (support.hotlinePhonePrimary != null)
                  ElevatedButton(
                    onPressed: () => _callPhone(support.hotlinePhonePrimary),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 6.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'কল করুন',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ─── Social and Messaging Quick Access ────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
          child: Row(
            children: [
              if (support.whatsappChatUrl != null)
                Expanded(
                  child: _SocialPillButton(
                    label: 'WhatsApp',
                    icon: FontAwesomeIcons.whatsapp,
                    color: const Color(0xFF25D366),
                    onTap: () => _launchUrl(support.whatsappChatUrl),
                  ),
                ),
              SizedBox(width: 8.w),
              if (support.facebookPageUrl != null)
                Expanded(
                  child: _SocialPillButton(
                    label: 'Facebook',
                    icon: FontAwesomeIcons.facebookF,
                    color: const Color(0xFF1877F2),
                    onTap: () => _launchUrl(support.facebookPageUrl),
                  ),
                ),
              SizedBox(width: 8.w),
              if (support.youtubeChannelUrl != null)
                Expanded(
                  child: _SocialPillButton(
                    label: 'YouTube',
                    icon: FontAwesomeIcons.youtube,
                    color: const Color(0xFFFF0000),
                    onTap: () => _launchUrl(support.youtubeChannelUrl),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SocialPillButton extends StatelessWidget {
  final String label;
  final dynamic icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialPillButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon is IconData)
              Icon(icon as IconData, size: 14.sp, color: color)
            else
              FaIcon(icon, size: 14.sp, color: color),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
