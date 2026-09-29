import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import '../controllers/blog_detail_controller.dart';
import 'package:lokkha/features/blog/blog.dart';

class BlogDetailView extends GetView<BlogDetailController> {
  const BlogDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final post = controller.post.value;
      final baseBodyFontSize = 15.sp + controller.fontSizeDelta.value;

      return Scaffold(
        backgroundColor: context.scaffoldColor,
        appBar: AppBar(
          title: Text(post?.category ?? 'ব্লগ বিস্তারিত'),
          centerTitle: true,
        ),
        body: post == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: controller.scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main Article Card
                          Container(
                            decoration: BoxDecoration(
                              color: context.cardColor,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: context.borderColor,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x08000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Tag
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B6B50),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    post.category,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),

                                // Article Title
                                Text(
                                  post.title,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimary,
                                    height: 1.35,
                                  ),
                                ),
                                SizedBox(height: 12.h),

                                // Metadata Row
                                _buildMetadataRow(context, post),
                                SizedBox(height: 14.h),

                                Divider(
                                  color: context.borderColor,
                                  height: 1,
                                ),
                                SizedBox(height: 14.h),

                                // Reading & Social Controls
                                _buildReadingAndSocialRow(context),
                                SizedBox(height: 16.h),

                                // Featured Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: CachedNetworkImage(
                                    imageUrl: post.imageUrl,
                                    width: double.infinity,
                                    height: 220.h,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      height: 220.h,
                                      color: context.surfaceColor,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      height: 220.h,
                                      color: context.surfaceColor,
                                      child: const Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),

                                // Article Sections
                                ...post.sections.map((section) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 18.h),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (section.title != null &&
                                            section.title!.isNotEmpty) ...[
                                          Text(
                                            section.title!,
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              color: context.textPrimary,
                                              height: 1.35,
                                            ),
                                          ),
                                          SizedBox(height: 10.h),
                                        ],
                                        Text(
                                          section.content,
                                          style: TextStyle(
                                            fontSize: baseBodyFontSize,
                                            color: context.textSecondary,
                                            height: 1.7,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),

                                // Source Attribution
                                if (post.source != null &&
                                    post.source!.isNotEmpty) ...[
                                  SizedBox(height: 10.h),
                                  Text(
                                    'সূত্র: ${post.source}',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: context.textMuted,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                ],

                                // Author / Mentor Card
                                _buildMentorCard(context, post),
                              ],
                            ),
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),

                    // Scroll to Top FAB
                    if (controller.showScrollToTop.value)
                      Positioned(
                        bottom: 20.h,
                        right: 16.w,
                        child: FloatingActionButton.small(
                          onPressed: controller.scrollToTop,
                          backgroundColor: const Color(0xFF1B6B50),
                          elevation: 4,
                          child: const Icon(
                            Icons.keyboard_arrow_up,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      );
    });
  }

  Widget _buildMetadataRow(BuildContext context, BlogPost post) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Mentor
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: 15.sp,
              color: const Color(0xFF1B6B50),
            ),
            SizedBox(width: 4.w),
            Text(
              post.mentor,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
        Text('•', style: TextStyle(color: context.textMuted, fontSize: 14.sp)),

        // Date & Time
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 13.sp,
              color: context.textSecondary,
            ),
            SizedBox(width: 4.w),
            Text(
              post.publishTime != null
                  ? '${post.publishDate} · ${post.publishTime}'
                  : post.publishDate,
              style: TextStyle(
                fontSize: 12.sp,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        Text('•', style: TextStyle(color: context.textMuted, fontSize: 14.sp)),

        // Views
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.remove_red_eye_outlined,
              size: 14.sp,
              color: const Color(0xFF1B6B50),
            ),
            SizedBox(width: 4.w),
            Text(
              post.views,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF1B6B50),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text('•', style: TextStyle(color: context.textMuted, fontSize: 14.sp)),

        // Read Time
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time,
              size: 13.sp,
              color: context.textSecondary,
            ),
            SizedBox(width: 4.w),
            Text(
              post.readTime,
              style: TextStyle(
                fontSize: 12.sp,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadingAndSocialRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Font Size Switcher
          Row(
            children: [
              Text(
                'T ফন্ট সাইজ: ',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
              SizedBox(width: 4.w),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: context.borderColor),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    _buildFontSizeButton(context, 'A-', -2.0),
                    _buildFontSizeButton(context, 'A', 0.0),
                    _buildFontSizeButton(context, 'A+', 2.0),
                    _buildFontSizeButton(context, 'A++', 4.0),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(width: 14.w),

          // Social Share Icons
          Row(
            children: [
              _buildSocialIconButton(
                context: context,
                child: FaIcon(
                  FontAwesomeIcons.facebookF,
                  size: 14,
                  color: context.textSecondary,
                ),
                onTap: controller.shareOnFacebook,
              ),
              SizedBox(width: 6.w),
              _buildSocialIconButton(
                context: context,
                child: FaIcon(
                  FontAwesomeIcons.whatsapp,
                  size: 15,
                  color: context.textSecondary,
                ),
                onTap: controller.shareOnWhatsApp,
              ),
              SizedBox(width: 6.w),
              _buildSocialIconButton(
                context: context,
                child: FaIcon(
                  FontAwesomeIcons.xTwitter,
                  size: 14,
                  color: context.textSecondary,
                ),
                onTap: controller.shareOnX,
              ),
              SizedBox(width: 6.w),
              _buildSocialIconButton(
                context: context,
                child: Icon(
                  Icons.link,
                  size: 16,
                  color: context.textSecondary,
                ),
                onTap: controller.copyLink,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeButton(BuildContext context, String label, double delta) {
    return Obx(() {
      final isSelected = controller.fontSizeDelta.value == delta;
      return InkWell(
        onTap: () => controller.setFontSizeDelta(delta),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1B6B50) : Colors.transparent,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : context.textSecondary,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSocialIconButton({
    required BuildContext context,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: context.borderColor),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _buildMentorCard(BuildContext context, BlogPost post) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              color: Color(0xFF1B6B50),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'লক্ষ্য শিক্ষক ও মেন্টর প্যানেল',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'বিসিএস, ব্যাংক ও সরকারি চাকরির পরীক্ষা প্রস্তুতি সংক্রান্ত নিয়মিত বিশ্লেষণ ও বিষয়ভিত্তিক সহায়িকা।',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
