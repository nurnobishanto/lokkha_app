import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/blog_controller.dart';

class BlogView extends StatelessWidget {
  const BlogView({super.key});

  BlogController get controller => Get.isRegistered<BlogController>()
      ? Get.find<BlogController>()
      : Get.put(BlogController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('ব্লগ ও ক্যারিয়ার গাইড'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: controller.scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Hero Headline Section
                  _buildHeroSection(),
                  SizedBox(height: 14.h),

                  // 2. Search Bar
                  _buildSearchBar(),
                  SizedBox(height: 14.h),

                  // 3. Horizontal Category Filter Tabs
                  _buildCategoryChips(),
                  SizedBox(height: 14.h),

                  // 4. Categories & Most Read Bar with Menu Button
                  _buildCategoryMenuBar(context),
                  SizedBox(height: 12.h),

                  // 5. Article Count & Sort Row
                  _buildCountAndSortRow(),
                  SizedBox(height: 14.h),

                  // 6. Featured Article Card
                  _buildFeaturedCard(),
                  SizedBox(height: 20.h),

                  // 7. Recent Study Guides Section
                  _buildRecentGuidesSection(),
                  SizedBox(height: 18.h),

                  // 8. General Articles List
                  _buildGeneralArticlesList(),
                  SizedBox(height: 60.h),
                ],
              ),
            ),

            // Scroll to Top FAB
            Obx(() {
              if (!controller.showScrollToTop.value) {
                return const SizedBox.shrink();
              }
              return Positioned(
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
              );
            }),
          ],
        ),
      ),
    );
  }

  // 1. Hero Section
  Widget _buildHeroSection() {
    return Center(
      child: Column(
        children: [
          // Mint Pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFD9EDE1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 15.sp,
                  color: const Color(0xFF1B6B50),
                ),
                SizedBox(width: 6.w),
                Text(
                  'পরীক্ষা প্রস্তুতি ও ক্যারিয়ার সহায়িকা',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B6B50),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // Main Title
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'লক্ষ্য ',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                ),
                TextSpan(
                  text: 'স্টাডি ও ক্যারিয়ার ব্লগ',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B6B50),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),

          // Subtitle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              'বিসিএস, ব্যাংক, প্রাইমারি শিক্ষক নিয়োগ ও সরকারি চাকরির প্রস্তুতি টিপস ও গাইডলাইন।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Search Bar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Icon(
              Icons.search,
              color: const Color(0xFF6B7280),
              size: 20.sp,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              onSubmitted: controller.onSearchSubmitted,
              decoration: InputDecoration(
                hintText: 'স্টাডি আর্টিকেল বা বিষয় খুঁজুন...',
                hintStyle: TextStyle(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 13.sp,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          InkWell(
            onTap: () => controller
                .onSearchSubmitted(controller.searchController.text),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1B6B50),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(7.r),
                  bottomRight: Radius.circular(7.r),
                ),
              ),
              child: Text(
                'অনুসন্ধান',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Horizontal Category Chips
  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() {
        return Row(
          children: controller.categories.map((cat) {
            final isSelected = controller.selectedCategory.value == cat;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: InkWell(
                onTap: () => controller.onCategorySelected(cat),
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1B6B50)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1B6B50)
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  // 4. Categories & Most Read Bar
  Widget _buildCategoryMenuBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.menu_book,
                  color: const Color(0xFF1B6B50),
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'ক্যাটেগরি ও সর্বাধিক পঠিত আর্টিকেল',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          InkWell(
            onTap: () => controller.openCategoryBottomSheet(context),
            borderRadius: BorderRadius.circular(6.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1B6B50),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                'মেনু',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Article Count & Sort Row
  Widget _buildCountAndSortRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Article Count Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1B6B50),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.book_outlined,
                color: Colors.white,
                size: 13.sp,
              ),
              SizedBox(width: 6.w),
              Obx(() => Text(
                    'মোট ${controller.filteredPosts.length} টি আর্টিকেল',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
            ],
          ),
        ),

        // Sort Dropdown
        Obx(() {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedSort.value,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF4B5563),
                  size: 18,
                ),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF374151),
                  fontWeight: FontWeight.w600,
                ),
                onChanged: controller.onSortChanged,
                items: controller.sortOptions.map((opt) {
                  return DropdownMenuItem<String>(
                    value: opt,
                    child: Text(opt),
                  );
                }).toList(),
              ),
            ),
          );
        }),
      ],
    );
  }

  // 6. Featured Article Card
  Widget _buildFeaturedCard() {
    final featured = controller.featuredPost;
    if (featured == null) return const SizedBox.shrink();

    return InkWell(
      onTap: () => controller.openPostDetails(featured),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Featured Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: featured.imageUrl,
                    height: 180.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180.h,
                      color: const Color(0xFFE5E7EB),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 180.h,
                      color: const Color(0xFFE5E7EB),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 13,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'ফিচার্ড স্টাডি গাইড',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Card Body
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Category Tag on left, Views on right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9EDE1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          featured.category,
                          style: TextStyle(
                            color: const Color(0xFF1B6B50),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            size: 13.sp,
                            color: const Color(0xFF1B6B50),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            featured.views,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF1B6B50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Row 2: Date & Read Time (responsive Wrap - zero overflow)
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6.w,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12.sp,
                            color: const Color(0xFF6B7280),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            featured.publishDate,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      Text('•',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 12.sp)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12.sp,
                            color: const Color(0xFF6B7280),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            featured.readTime,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // Title
                  Text(
                    featured.title,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Excerpt
                  Text(
                    featured.excerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'মেন্টর: ',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF4B5563),
                              ),
                            ),
                            TextSpan(
                              text: featured.mentor,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: const Color(0xFF1B6B50)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'সম্পূর্ণ পড়ুন',
                              style: TextStyle(
                                color: const Color(0xFF1B6B50),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_forward,
                              size: 13.sp,
                              color: const Color(0xFF1B6B50),
                            ),
                          ],
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

  // 7. Recent Study Guides Section
  Widget _buildRecentGuidesSection() {
    final recentGuides = controller.recentGuides;
    if (recentGuides.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 13,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'প্রস্তুতি সহায়িকা',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'সাম্প্রতিক গুরুত্বপূর্ণ স্টাডি গাইড',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                '${recentGuides.length} টি',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Recent Guides Cards
        ...recentGuides.map((guide) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: InkWell(
              onTap: () => controller.openPostDetails(guide),
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: guide.imageUrl,
                        width: 85.w,
                        height: 70.h,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 85.w,
                          height: 70.h,
                          color: const Color(0xFFE5E7EB),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 85.w,
                          height: 70.h,
                          color: const Color(0xFFE5E7EB),
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${guide.category} · ${guide.publishDate}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1B6B50),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            guide.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Text(
                                'টিপস পড়ুন',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1B6B50),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.arrow_forward,
                                size: 12.sp,
                                color: const Color(0xFF1B6B50),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // 8. General Articles List
  Widget _buildGeneralArticlesList() {
    return Obx(() {
      final posts = controller.generalPosts;
      if (posts.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: posts.map((post) {
          return Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: InkWell(
              onTap: () => controller.openPostDetails(post),
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x05000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Image
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(14.r),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: post.imageUrl,
                        width: double.infinity,
                        height: 160.h,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 160.h,
                          color: const Color(0xFFE5E7EB),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 160.h,
                          color: const Color(0xFFE5E7EB),
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 36,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    // Body
                    Padding(
                      padding: EdgeInsets.all(14.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Meta Row (Date on left, Views on right)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 12.sp,
                                    color: const Color(0xFF6B7280),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    post.publishDate,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: 13.sp,
                                    color: const Color(0xFF1B6B50),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    post.views,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: const Color(0xFF1B6B50),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),

                          // Title
                          Text(
                            post.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111827),
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Excerpt
                          Text(
                            post.excerpt,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'মেন্টর: ',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: const Color(0xFF4B5563),
                                      ),
                                    ),
                                    TextSpan(
                                      text: post.mentor,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'পড়ুন',
                                    style: TextStyle(
                                      color: const Color(0xFF1B6B50),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 12.sp,
                                    color: const Color(0xFF1B6B50),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}
