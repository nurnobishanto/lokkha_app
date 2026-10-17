import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_colors.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/constants/app_images.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/about_model.dart';

class AboutTestimonialsSection extends StatelessWidget {
  final AboutTestimonialsModel testimonials;

  const AboutTestimonialsSection({super.key, required this.testimonials});

  Future<void> _playVideo(String? videoUrl) async {
    if (videoUrl == null || videoUrl.isEmpty) return;
    final uri = Uri.tryParse(videoUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasVideos = testimonials.videoTestimonials.isNotEmpty;
    final hasTexts = testimonials.textTestimonials.isNotEmpty;
    if (!hasVideos && !hasTexts) return const SizedBox.shrink();

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
                testimonials.heading.isNotEmpty
                    ? testimonials.heading
                    : 'শিক্ষার্থীদের অভিজ্ঞতা ও মতামত',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ),
          ],
        ),
        if (testimonials.subheading.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            testimonials.subheading,
            style: TextStyle(
              fontSize: 12.5.sp,
              color: context.textSecondary,
              height: 1.4,
            ),
          ),
        ],
        SizedBox(height: 14.h),

        // Video Testimonials / Reels Carousel or Horizontal List
        if (hasVideos) ...[
          SizedBox(
            height: 245.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: testimonials.videoTestimonials.length,
              separatorBuilder: (_, __) => SizedBox(width: 14.w),
              itemBuilder: (context, index) {
                final video = testimonials.videoTestimonials[index];
                final targetUrl = video.videoUrl ??
                    (video.youtubeId != null
                        ? 'https://www.youtube.com/watch?v=${video.youtubeId}'
                        : video.videoEmbedUrl);

                return InkWell(
                  onTap: () => _playVideo(targetUrl),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    width: 200.w,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video Thumbnail with Play Button
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CachedNetworkImage(
                              imageUrl: video.avatarUrl,
                              height: 115.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 115.h,
                                color: isDark ? Colors.grey[850] : const Color(0xFFF1F5F9),
                                child: const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 115.h,
                                color: const Color(0xFFE2E8F0),
                                child: Image.asset(AssetImagePaths.logo, fit: BoxFit.contain),
                              ),
                            ),
                            Container(
                              height: 115.h,
                              color: Colors.black.withValues(alpha: 0.25),
                            ),
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF0000),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 24.sp,
                              ),
                            ),
                            if (video.videoDuration != null)
                              Positioned(
                                bottom: 6.h,
                                right: 6.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    video.videoDuration!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Title & Rating
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(10.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  video.name,
                                  style: TextStyle(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: context.textPrimary,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    ...List.generate(
                                      5,
                                      (starIdx) => Icon(
                                        starIdx < video.rating.round()
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        size: 13.sp,
                                        color: const Color(0xFFF59E0B),
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'ভিডিও দেখুন',
                                      style: TextStyle(
                                        fontSize: 10.5.sp,
                                        color: LightThemeColors.primaryColor,
                                        fontWeight: FontWeight.w700,
                                      ),
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
                );
              },
            ),
          ),
        ],

        // Text Testimonials
        if (hasTexts) ...[
          SizedBox(height: 14.h),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: testimonials.textTestimonials.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final item = testimonials.textTestimonials[index];
              return Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16.r,
                          backgroundImage: item.avatarUrl.isNotEmpty
                              ? CachedNetworkImageProvider(item.avatarUrl)
                              : null,
                          child: item.avatarUrl.isEmpty
                              ? Text(item.name.isNotEmpty ? item.name[0] : 'S')
                              : null,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: context.textPrimary,
                                ),
                              ),
                              if (item.designation.isNotEmpty)
                                Text(
                                  item.designation,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: context.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (item.reviewText != null && item.reviewText!.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Text(
                        item.reviewText!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: context.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
