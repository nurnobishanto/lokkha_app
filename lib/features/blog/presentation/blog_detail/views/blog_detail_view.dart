import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lokkha/features/blog/blog.dart';

class BlogDetailView extends StatefulWidget {
  final BlogPost? post;
  const BlogDetailView({super.key, this.post});

  @override
  State<BlogDetailView> createState() => _BlogDetailViewState();
}

class _BlogDetailViewState extends State<BlogDetailView> {
  final ScrollController _scrollController = ScrollController();
  late final BlogPost _post;
  double _fontSizeDelta = 0.0;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post ?? BlogPost.samplePosts.first;

    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 300 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setFontSizeDelta(double delta) {
    setState(() => _fontSizeDelta = delta);
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _sharePost() {
    ShareHelper.share(
      '${_post.title}\n\nপড়ুন লক্ষ্য অ্যাপে: https://lokkha.app/blog/${_post.id}',
      context: context,
    );
  }

  Future<void> _shareOnFacebook() async {
    final url = Uri.parse(
      'https://www.facebook.com/sharer/sharer.php?u=https://lokkha.app/blog/${_post.id}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _sharePost();
    }
  }

  Future<void> _shareOnWhatsApp() async {
    final text = Uri.encodeComponent(
      '${_post.title}\nhttps://lokkha.app/blog/${_post.id}',
    );
    final url = Uri.parse('whatsapp://send?text=$text');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _sharePost();
    }
  }

  Future<void> _shareOnX() async {
    final text = Uri.encodeComponent(
      '${_post.title} https://lokkha.app/blog/${_post.id}',
    );
    final url = Uri.parse('https://twitter.com/intent/tweet?text=$text');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _sharePost();
    }
  }

  void _copyLink() {
    final link = 'https://lokkha.app/blog/${_post.id}';
    Clipboard.setData(ClipboardData(text: link));
    CustomSnackBar.showCustomToast(
      title: 'সফল হয়েছে',
      message: 'লিংকটি ক্লিপবোর্ডে কপি করা হয়েছে',
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseBodyFontSize = 15.sp + _fontSizeDelta;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(_post.category),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Article Hero Image
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.r),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: _post.imageUrl,
                            width: double.infinity,
                            height: 200.h,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 200.h,
                              color: context.surfaceColor,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 200.h,
                              color: context.surfaceColor,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Badge & Meta Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD9EDE1),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      _post.category,
                                      style: TextStyle(
                                        color: const Color(0xFF1B6B50),
                                        fontSize: 11.5.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 13.sp,
                                        color: context.textSecondary,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        _post.publishDate,
                                        style: TextStyle(
                                          fontSize: 11.5.sp,
                                          color: context.textSecondary,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Icon(
                                        Icons.remove_red_eye_outlined,
                                        size: 14.sp,
                                        color: const Color(0xFF1B6B50),
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        _post.views,
                                        style: TextStyle(
                                          fontSize: 11.5.sp,
                                          color: const Color(0xFF1B6B50),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),

                              // Title
                              Text(
                                _post.title,
                                style: TextStyle(
                                  fontSize: 18.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimary,
                                  height: 1.35,
                                ),
                              ),
                              SizedBox(height: 10.h),

                              // Excerpt Box
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: context.subtleSurfaceColor,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border(
                                    left: BorderSide(
                                      color: const Color(0xFF1B6B50),
                                      width: 4.w,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  _post.excerpt,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontStyle: FontStyle.italic,
                                    color: context.textSecondary,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                              SizedBox(height: 14.h),

                              // Mentor Info Bar
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: context.subtleSurfaceColor,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18.r,
                                      backgroundColor:
                                          const Color(0xFF1B6B50),
                                      child: Text(
                                        _post.mentor.isNotEmpty
                                            ? _post.mentor[0]
                                            : 'L',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _post.mentor,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.bold,
                                              color: context.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            'বিসিএস ক্যাডার ও স্টাডি কনসালটেন্ট',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: context.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 14.h),

                              // Font Size Toolbar
                              _buildFontSizeBar(context),
                              Divider(
                                height: 24.h,
                                color: context.borderColor,
                              ),

                              // Article Sections
                              ..._post.sections.map((section) {
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
                                          color: context.textPrimary,
                                          height: 1.7,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              SizedBox(height: 20.h),

                              // Social Sharing Section
                              _buildShareSection(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),

            // Scroll to Top FAB
            if (_showScrollToTop)
              Positioned(
                bottom: 20.h,
                right: 16.w,
                child: FloatingActionButton.small(
                  onPressed: _scrollToTop,
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
  }

  Widget _buildFontSizeBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: context.subtleSurfaceColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_size,
                size: 16.sp,
                color: context.textSecondary,
              ),
              SizedBox(width: 6.w),
              Text(
                'ফন্ট সাইজ:',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: context.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildFontButton(
                label: 'A-',
                onTap: () {
                  if (_fontSizeDelta > -4) {
                    _setFontSizeDelta(_fontSizeDelta - 1);
                  }
                },
                context: context,
              ),
              SizedBox(width: 8.w),
              _buildFontButton(
                label: 'Default',
                onTap: () => _setFontSizeDelta(0),
                context: context,
              ),
              SizedBox(width: 8.w),
              _buildFontButton(
                label: 'A+',
                onTap: () {
                  if (_fontSizeDelta < 8) {
                    _setFontSizeDelta(_fontSizeDelta + 1);
                  }
                },
                context: context,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFontButton({
    required String label,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: context.borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B6B50),
          ),
        ),
      ),
    );
  }

  Widget _buildShareSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: context.borderColor),
        SizedBox(height: 8.h),
        Text(
          'আর্টিকেলটি বন্ধুদের সাথে শেয়ার করুন:',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildShareIcon(
              icon: FontAwesomeIcons.facebook,
              color: const Color(0xFF1877F2),
              label: 'Facebook',
              onTap: _shareOnFacebook,
            ),
            _buildShareIcon(
              icon: FontAwesomeIcons.whatsapp,
              color: const Color(0xFF25D366),
              label: 'WhatsApp',
              onTap: _shareOnWhatsApp,
            ),
            _buildShareIcon(
              icon: FontAwesomeIcons.xTwitter,
              color: Colors.black,
              label: 'X',
              onTap: _shareOnX,
            ),
            _buildShareIcon(
              icon: Icons.link,
              color: const Color(0xFF1B6B50),
              label: 'কপি লিংক',
              onTap: _copyLink,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShareIcon({
    required dynamic icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon as IconData, color: color, size: 20.sp),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
