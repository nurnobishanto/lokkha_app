import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/features/blog/blog.dart';
import '../../providers/blog_notifier.dart';

class BlogView extends ConsumerStatefulWidget {
  const BlogView({super.key});

  @override
  ConsumerState<BlogView> createState() => _BlogViewState();
}

class _BlogViewState extends ConsumerState<BlogView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
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
    _searchController.dispose();
    super.dispose();
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

  void _openPostDetails(BlogPost post) {
    context.pushNamed(Routes.blogDetails, extra: post);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(blogNotifierProvider);
    final notifier = ref.read(blogNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: const Text('ব্লগ ও ক্যারিয়ার গাইড'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Hero Headline Section
                  _buildHeroSection(context),
                  SizedBox(height: 14.h),

                  // 2. Search Bar
                  _buildSearchBar(context, notifier),
                  SizedBox(height: 14.h),

                  // 3. Horizontal Category Filter Tabs
                  _buildCategoryChips(context, state, notifier),
                  SizedBox(height: 14.h),

                  // 4. Categories & Most Read Bar with Menu Button
                  _buildCategoryMenuBar(context, state, notifier),
                  SizedBox(height: 12.h),

                  // 5. Article Count & Sort Row
                  _buildCountAndSortRow(context, state, notifier),
                  SizedBox(height: 14.h),

                  // 6. Featured Article Card
                  if (state.featuredPost != null) ...[
                    _buildFeaturedCard(context, state.featuredPost!),
                    SizedBox(height: 20.h),
                  ],

                  // 7. Recent Study Guides Section
                  if (state.recentGuides.isNotEmpty) ...[
                    _buildRecentGuidesSection(context, state.recentGuides),
                    SizedBox(height: 18.h),
                  ],

                  // 8. General Articles List
                  _buildGeneralArticlesList(context, state.filteredPosts),
                  SizedBox(height: 60.h),
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

  // 1. Hero Section
  Widget _buildHeroSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
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
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'লক্ষ্য ',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              'বিসিএস, ব্যাংক, প্রাইমারি শিক্ষক নিয়োগ ও সরকারি চাকরির প্রস্তুতি টিপস ও গাইডলাইন।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: context.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Search Bar
  Widget _buildSearchBar(BuildContext context, BlogNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Icon(
              Icons.search,
              color: context.textSecondary,
              size: 20.sp,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: notifier.onSearchSubmitted,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 13.sp,
              ),
              decoration: InputDecoration(
                hintText: 'স্টাডি আর্টিকেল বা বিষয় খুঁজুন...',
                hintStyle: TextStyle(
                  color: context.textMuted,
                  fontSize: 13.sp,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          InkWell(
            onTap: () => notifier.onSearchSubmitted(_searchController.text),
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
  Widget _buildCategoryChips(
      BuildContext context, BlogState state, BlogNotifier notifier) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: BlogNotifier.categories.map((cat) {
          final isSelected = state.selectedCategory == cat;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: InkWell(
              onTap: () => notifier.onCategorySelected(cat),
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1B6B50)
                      : context.cardColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1B6B50)
                        : context.borderColor,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : context.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 4. Categories & Most Read Bar
  Widget _buildCategoryMenuBar(
      BuildContext context, BlogState state, BlogNotifier notifier) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: context.borderColor),
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
                Flexible(
                  child: Text(
                    'ক্যাটেগরি: ${state.selectedCategory}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B6B50),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _openCategoryBottomSheet(context, state, notifier),
            borderRadius: BorderRadius.circular(6.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: const Color(0xFFD9EDE1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 14.sp,
                    color: const Color(0xFF1B6B50),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'সব ক্যাটেগরি',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: const Color(0xFF1B6B50),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCategoryBottomSheet(
      BuildContext context, BlogState state, BlogNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'সকল ক্যাটেগরি',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B6B50),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: context.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Divider(color: context.borderColor),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: BlogNotifier.categories.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: context.borderColor),
                    itemBuilder: (context, index) {
                      final cat = BlogNotifier.categories[index];
                      final isSelected = state.selectedCategory == cat;
                      return ListTile(
                        title: Text(
                          cat,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF1B6B50)
                                : context.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: Color(0xFF1B6B50))
                            : null,
                        onTap: () {
                          notifier.onCategorySelected(cat);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 5. Count & Sort Row
  Widget _buildCountAndSortRow(
      BuildContext context, BlogState state, BlogNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'মোট ${state.filteredPosts.length} টি আর্টিকেল',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: context.textSecondary,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: context.borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.selectedSort,
              isDense: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: context.textSecondary,
                size: 20.sp,
              ),
              style: TextStyle(
                fontSize: 12.sp,
                color: context.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: context.cardColor,
              items: BlogNotifier.sortOptions.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
              onChanged: notifier.onSortChanged,
            ),
          ),
        ),
      ],
    );
  }

  // 6. Featured Card
  Widget _buildFeaturedCard(BuildContext context, BlogPost featured) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openPostDetails(featured),
        borderRadius: BorderRadius.circular(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(14.r)),
                  child: CachedNetworkImage(
                    imageUrl: featured.imageUrl,
                    width: double.infinity,
                    height: 180.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180.h,
                      color: context.surfaceColor,
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 180.h,
                      color: context.surfaceColor,
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13.sp,
                            color: context.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            featured.publishDate,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            size: 14.sp,
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
                  Text(
                    featured.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    featured.excerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 12.h),
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
                                color: context.textSecondary,
                              ),
                            ),
                            TextSpan(
                              text: featured.mentor,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
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
                              fontSize: 12.5.sp,
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
  Widget _buildRecentGuidesSection(
      BuildContext context, List<BlogPost> guides) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1B6B50),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'সাম্প্রতিক স্টাডি গাইড',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 240.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: guides.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              return _buildGuideCard(context, guides[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGuideCard(BuildContext context, BlogPost guide) {
    return Container(
      width: 220.w,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openPostDetails(guide),
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: CachedNetworkImage(
                imageUrl: guide.imageUrl,
                height: 110.h,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 110.h,
                  color: context.surfaceColor,
                ),
                errorWidget: (context, url, error) => Container(
                  height: 110.h,
                  color: context.surfaceColor,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9EDE1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      guide.category,
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B6B50),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    guide.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    guide.publishDate,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 8. General Articles List
  Widget _buildGeneralArticlesList(
      BuildContext context, List<BlogPost> posts) {
    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.h),
          child: Text(
            'কোনো আর্টিকেল পাওয়া যায়নি',
            style: TextStyle(
              fontSize: 14.sp,
              color: context.textMuted,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1B6B50),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'সব আর্টিকেল',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...posts.map((post) {
          return Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: _buildArticleListItem(context, post),
          );
        }),
      ],
    );
  }

  Widget _buildArticleListItem(BuildContext context, BlogPost post) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openPostDetails(post),
        borderRadius: BorderRadius.circular(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
              child: CachedNetworkImage(
                imageUrl: post.imageUrl,
                width: double.infinity,
                height: 160.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 160.h,
                  color: context.surfaceColor,
                ),
                errorWidget: (context, url, error) => Container(
                  height: 160.h,
                  color: context.surfaceColor,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    size: 36,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12.sp,
                            color: context.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            post.publishDate,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: context.textSecondary,
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
                  Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    post.excerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 12.h),
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
                                color: context.textSecondary,
                              ),
                            ),
                            TextSpan(
                              text: post.mentor,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
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
    );
  }
}
