import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_colors.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/utils/global.dart';
import '../providers/about_notifier.dart';
import '../widgets/about_app_showcase_section.dart';
import '../widgets/about_cta_section.dart';
import '../widgets/about_hero_section.dart';
import '../widgets/about_metrics_section.dart';
import '../widgets/about_pillars_section.dart';
import '../widgets/about_support_section.dart';
import '../widgets/about_testimonials_section.dart';

class AboutUsView extends ConsumerWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aboutNotifierProvider);
    final notifier = ref.read(aboutNotifierProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(
          state.data?.seo?.title.isNotEmpty == true
              ? 'আমাদের সম্পর্কে'
              : 'আমাদের সম্পর্কে',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: LightThemeColors.primaryColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.fetchAboutData(isRefresh: true),
        color: LightThemeColors.primaryColor,
        child: _buildBody(context, state, notifier, isDark),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AboutState state,
    AboutNotifier notifier,
    bool isDark,
  ) {
    if (state.isLoading && state.data == null) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(LightThemeColors.primaryColor),
        ),
      );
    }

    if (state.errorMessage != null && state.data == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 54.sp,
                color: Colors.redAccent,
              ),
              SizedBox(height: 16.h),
              Text(
                'তথ্য লোড করতে সমস্যা হয়েছে',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: context.textSecondary,
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: () => notifier.fetchAboutData(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('আবার চেষ্টা করুন'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LightThemeColors.primaryColor,
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

    final data = state.data;
    if (data == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      children: [
        // 1. Hero Section
        if (data.hero != null) ...[
          AboutHeroSection(hero: data.hero!),
          SizedBox(height: 20.h),
        ],

        // 2. Metrics Section (4 Impact Counters)
        if (data.metrics.isNotEmpty) ...[
          AboutMetricsSection(metrics: data.metrics),
          SizedBox(height: 20.h),
        ],

        // 3. Pillars Section (Mission, Vision, Values)
        if (data.pillars != null && data.pillars!.items.isNotEmpty) ...[
          AboutPillarsSection(pillars: data.pillars!),
          SizedBox(height: 20.h),
        ],

        // 4. App Showcase Section
        if (data.appShowcase != null) ...[
          AboutAppShowcaseSection(appShowcase: data.appShowcase!),
          SizedBox(height: 20.h),
        ],

        // 5. Community & Support Section
        if (data.communityAndSupport != null) ...[
          AboutSupportSection(communityAndSupport: data.communityAndSupport!),
          SizedBox(height: 20.h),
        ],

        // 6. Testimonials Section (Video Reels & Text)
        if (data.testimonials != null) ...[
          AboutTestimonialsSection(testimonials: data.testimonials!),
          SizedBox(height: 20.h),
        ],

        // 7. CTA Banner Section
        if (data.cta != null) ...[
          AboutCtaSection(cta: data.cta!),
          SizedBox(height: 24.h),
        ],

        // Footer App info
        Center(
          child: Column(
            children: [
              Text(
                '© 2025 Lokkha. All rights reserved.',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: context.textMuted,
                ),
              ),
              if (appVersion.value.isNotEmpty) ...[
                SizedBox(height: 3.h),
                Text(
                  'অ্যাপ ভার্শন: ${appVersion.value}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: context.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
