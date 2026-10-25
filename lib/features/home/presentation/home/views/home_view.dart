import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/course/course.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/features/notifications/notifications.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 1. Fetch unified Module 23 Home Feed
      ref.read(homeFeedNotifierProvider.notifier).fetchHomeFeed();

      // 2. Fetch initial data for other background caches and drawer overview
      ref.read(homeNotifierProvider.notifier).fetchInitialData();

      // 3. Fetch real unread notifications count in background
      ref.read(notificationsNotifierProvider.notifier).fetchNotifications();

      // 4. Check for In-App announcement popups
      if (mounted) {
        AppUpdateService().showInAppAnnouncementIfAvailable(context: context);
      }
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref
          .read(homeFeedNotifierProvider.notifier)
          .fetchHomeFeed(isRefresh: true),
      ref.read(homeNotifierProvider.notifier).refreshHomeViewData(),
      ref.read(coursesNotifierProvider(null).notifier).fetchCourses(null, refresh: true),
      ref.read(notificationsNotifierProvider.notifier).fetchNotifications(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(homeFeedNotifierProvider);
    final homeState = ref.watch(homeNotifierProvider);
    final data = feedState.data;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.isDark ? const Color(0xFF0F172A) : Colors.white,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006A4E),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(
            Icons.menu_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AssetImagePaths.appIconHorizontal,
              height: 22.h,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Text(
                'লক্ষ্য',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              data?.appMeta?.appTagline ?? "সঠিক পথে, স্বল্প সময়ে",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (GoRouter.maybeOf(context) != null) {
                    context.push(Routes.notifications);
                  }
                },
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: ValueListenableBuilder<int>(
                  valueListenable: unReadNotificationCount,
                  builder: (context, count, _) {
                    if (count <= 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _buildBody(context, feedState, homeState),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    HomeFeedState feedState,
    HomeState homeState,
  ) {
    // 1. Initial Loading Skeleton
    if (feedState.isLoading && !feedState.hasData) {
      return ListView(
        padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 20.h),
        children: const [
          _HomeSkeletonLoader(),
        ],
      );
    }

    // 2. Error State (only if no data)
    if (!feedState.hasData && feedState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 54.sp,
                color: context.textSecondary,
              ),
              SizedBox(height: 12.h),
              Text(
                feedState.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(homeFeedNotifierProvider.notifier).fetchHomeFeed(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('আবার চেষ্টা করুন'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006A4E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final data = feedState.data;
    final examCatState = ref.watch(examCategoriesNotifierProvider);
    final effectiveExamCategories = _resolveExamCategories(
      data?.examCategories,
      examCatState,
    );
    final effectiveCourseCategories = _resolveCourseCategories(
      data?.courseCategories,
      examCatState,
    );

    return ListView(
      padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 24.h),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // ── Notice Ticker (if available) ─────────────────────────────────────
        if (data?.careerAndUpdates?.noticeTicker != null &&
            data!.careerAndUpdates!.noticeTicker!.isNotEmpty) ...[
          HomeNoticeTicker(
            noticeText: data.careerAndUpdates!.noticeTicker!,
          ),
          SizedBox(height: 6.h),
        ],

        // ── 1. Sliders Carousel Banner ──────────────────────────────────────
        if (data != null && data.sliders.isNotEmpty)
          HomeSliderSection(sliders: data.sliders)
        else
          const _SliderFallbackSection(),

        SizedBox(height: 10.h),

        // ── 2. Top 6 Action Buttons Grid (Vocabulary Game, GK, কুইজ, etc.) ───
        const HomeTopActionsGrid(),

        SizedBox(height: 10.h),

        // ── 3. কারেন্ট অ্যাফেয়ার্স Interactive MCQ Card ─────────────────────
        HomeMcqSection(
          currentAffairs: data?.currentAffairs,
        ),

        SizedBox(height: 10.h),

        // ── 4. পরীক্ষা ও কোর্স ক্যাটাগরি (Exam & Course Categories) ─────────
        HomeCategoriesSection(
          examCategories: effectiveExamCategories,
          courseCategories: effectiveCourseCategories,
        ),

        SizedBox(height: 10.h),

        // ── 5. কনটেস্ট হাব লিডারবোর্ড (Contest Hub Leaderboard) ──────────────
        HomeProLeaderboardSection(
          contestHub: data?.contestHub,
        ),

        SizedBox(height: 10.h),

        // ── 6. আমাদের কোর্সসমূহ (Horizontal Scrollable All Courses List) ────
        const HomeCoursesSection(),

        SizedBox(height: 16.h),
      ],
    );
  }

  List<HomeExamCategoryItem> _resolveExamCategories(
    List<HomeExamCategoryItem>? feedItems,
    ExamCategoriesState examCatState,
  ) {
    final legacyList = examCatState.examCategoriesModel?.examCategories ?? [];
    final legacyImageById = <int, String>{};
    final legacyImageBySlug = <String, String>{};
    for (final c in legacyList) {
      final url = c.imageUrl ?? Endpoints.resolveImageUrl(c.image);
      if (url.isNotEmpty) {
        if (c.id != null) legacyImageById[c.id!] = url;
        if (c.slug != null && c.slug!.isNotEmpty) {
          legacyImageBySlug[c.slug!.toLowerCase()] = url;
        }
      }
    }

    if (feedItems != null && feedItems.isNotEmpty) {
      return feedItems.map((item) {
        if (item.imageUrl != null && item.imageUrl!.isNotEmpty) return item;
        final fallbackUrl = legacyImageById[item.id] ??
            legacyImageBySlug[item.slug.toLowerCase()];
        if (fallbackUrl == null || fallbackUrl.isEmpty) return item;
        return HomeExamCategoryItem(
          id: item.id,
          name: item.name,
          slug: item.slug,
          description: item.description,
          imageUrl: fallbackUrl,
          examsCount: item.examsCount,
          theme: item.theme,
        );
      }).toList();
    }

    if (legacyList.isNotEmpty) {
      return legacyList
          .map(
            (c) => HomeExamCategoryItem(
              id: c.id ?? 0,
              name: c.name ?? '',
              slug: c.slug ?? '',
              description: c.description,
              imageUrl: c.imageUrl ?? Endpoints.resolveImageUrl(c.image),
              examsCount: c.freeExamsCount ?? 0,
            ),
          )
          .toList();
    }

    return HomeCategoriesSection.defaultExamCategories;
  }

  List<HomeCourseCategoryItem> _resolveCourseCategories(
    List<HomeCourseCategoryItem>? feedItems,
    ExamCategoriesState examCatState,
  ) {
    final legacyList =
        examCatState.courseCategoriesModel?.courseCategories ?? [];
    final legacyImageById = <int, String>{};
    final legacyImageBySlug = <String, String>{};
    for (final c in legacyList) {
      final url = c.imageUrl ?? Endpoints.resolveImageUrl(c.image);
      if (url.isNotEmpty) {
        if (c.id != null) legacyImageById[c.id!] = url;
        if (c.slug != null && c.slug!.isNotEmpty) {
          legacyImageBySlug[c.slug!.toLowerCase()] = url;
        }
      }
    }

    if (feedItems != null && feedItems.isNotEmpty) {
      return feedItems.map((item) {
        if (item.imageUrl != null && item.imageUrl!.isNotEmpty) return item;
        final fallbackUrl = legacyImageById[item.id] ??
            legacyImageBySlug[item.slug.toLowerCase()];
        if (fallbackUrl == null || fallbackUrl.isEmpty) return item;
        return HomeCourseCategoryItem(
          id: item.id,
          title: item.title,
          slug: item.slug,
          description: item.description,
          imageUrl: fallbackUrl,
          coursesCount: item.coursesCount,
          theme: item.theme,
        );
      }).toList();
    }

    if (legacyList.isNotEmpty) {
      return legacyList
          .map(
            (c) => HomeCourseCategoryItem(
              id: c.id ?? 0,
              title: c.title ?? '',
              slug: c.slug ?? '',
              description: c.description?.toString(),
              imageUrl: c.imageUrl ?? Endpoints.resolveImageUrl(c.image),
              coursesCount: c.coursesCount ?? 0,
            ),
          )
          .toList();
    }

    return HomeCategoriesSection.defaultCourseCategories;
  }
}

// ─── Fallback Slider Section ─────────────────────────────────────────────────
class _SliderFallbackSection extends ConsumerWidget {
  const _SliderFallbackSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeNotifierProvider);
    final sliders = homeState.sliderModel.sliders ?? [];
    if (sliders.isEmpty) return const SizedBox.shrink();

    return HomeSliderSection(
      sliders: sliders
          .map(
            (e) => HomeSliderItem(
              id: e.id ?? 0,
              type: 'app',
              imageUrl: Endpoints.storageUrl + (e.image ?? ''),
              link: e.link,
              navigation: HomeSliderNavigation(
                page: e.page,
                hasAction: true,
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── Loading Skeleton Placeholder ────────────────────────────────────────────
class _HomeSkeletonLoader extends StatelessWidget {
  const _HomeSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 140.h,
          decoration: BoxDecoration(
            color: context.borderColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: List.generate(
            2,
            (index) => Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                height: 48.h,
                decoration: BoxDecoration(
                  color: context.borderColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          height: 180.h,
          decoration: BoxDecoration(
            color: context.borderColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ],
    );
  }
}
