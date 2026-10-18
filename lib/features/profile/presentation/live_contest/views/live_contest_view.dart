import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';
import '../riverpod/live_contest_notifier.dart';
import '../widgets/live_contest_item_card.dart';
import '../widgets/live_contest_summary_header.dart';
import '../widgets/saved_question_item_card.dart';

class LiveContestView extends ConsumerWidget {
  const LiveContestView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveContestNotifierProvider);
    final notifier = ref.read(liveContestNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: CustomAppBar(
        title: 'লাইভ কনটেস্ট ও সেভড প্রশ্ন',
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => notifier.loadContentHistory(refresh: true),
            icon: Icon(
              Icons.refresh_rounded,
              size: 22.sp,
              color: Colors.white,
            ),
            tooltip: 'রিফ্রেশ করুন',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.loadContentHistory(refresh: true),
        color: context.primaryColor,
        child: _buildBody(context, state, notifier),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    LiveContestState state,
    LiveContestNotifier notifier,
  ) {
    if (state.isLoading && state.contentHistory == null) {
      return _buildLoadingState(context);
    }

    if (state.errorMessage != null && state.contentHistory == null) {
      return _buildErrorState(context, state.errorMessage!, notifier);
    }

    final showContests = state.activeFilter == 'all' || state.activeFilter == 'contests';
    final showSaved = state.activeFilter == 'all' || state.activeFilter == 'saved';

    final contestList = state.recentContests;
    final savedList = state.recentSavedQuestions;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 28.h),
      children: [
        // ---------------------------------------------------------------------
        // 1. Summary Header (Overview metrics, CTA banner, and filter chips)
        // ---------------------------------------------------------------------
        LiveContestSummaryHeader(
          totalContests: state.totalContests,
          totalSavedQuestions: state.totalSavedQuestions,
          activeFilter: state.activeFilter,
          onFilterChanged: notifier.setFilter,
          onBrowseContests: () => notifier.openLiveContests(context),
        ),

        // ---------------------------------------------------------------------
        // 2. Live Contest Section
        // ---------------------------------------------------------------------
        if (showContests) ...[
          SizedBox(height: 20.h),
          _buildSectionHeader(
            context: context,
            title: "লাইভ কনটেস্ট হিস্ট্রি",
            icon: const FaIcon(
              FontAwesomeIcons.trophy,
              size: 16,
              color: Color(0xFFD97706),
            ),
            badgeText: "${contestList.length} টি",
            badgeColor: const Color(0xFFD97706),
          ),
          SizedBox(height: 10.h),
          if (contestList.isEmpty)
            _buildEmptyStateCard(
              context: context,
              icon: const FaIcon(
                FontAwesomeIcons.trophy,
                size: 32,
                color: Color(0xFF94A3B8),
              ),
              title: "কোনো লাইভ কনটেস্ট হিস্ট্রি পাওয়া যায়নি",
              subtitle: "নতুন কনটেস্টে অংশ নিয়ে আপনার জ্ঞান ও মেধা যাচাই করুন।",
              actionLabel: "কনটেস্টে অংশ নিন",
              onAction: () => notifier.openLiveContests(context),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: contestList.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final item = contestList[index];
                return LiveContestItemCard(
                  item: item,
                  onViewRanking: () => notifier.viewContestRanking(context, item),
                  onViewResult: () => notifier.viewContestResult(context, item),
                );
              },
            ),
        ],

        // ---------------------------------------------------------------------
        // 3. Saved Questions Section
        // ---------------------------------------------------------------------
        if (showSaved) ...[
          SizedBox(height: 24.h),
          _buildSectionHeader(
            context: context,
            title: "সংরক্ষিত প্রশ্নসমূহ",
            icon: const Icon(
              Icons.bookmark_added_rounded,
              size: 20,
              color: Color(0xFF059669),
            ),
            badgeText: "${savedList.length} টি",
            badgeColor: const Color(0xFF059669),
          ),
          SizedBox(height: 10.h),
          if (savedList.isEmpty)
            _buildEmptyStateCard(
              context: context,
              icon: const Icon(
                Icons.bookmark_outline_rounded,
                size: 36,
                color: Color(0xFF94A3B8),
              ),
              title: "কোনো সংরক্ষিত প্রশ্ন পাওয়া যায়নি",
              subtitle: "পরীক্ষা বা পড়ার সময় গুরুত্বপূর্ণ প্রশ্ন বুকমার্ক করে রাখুন।",
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: savedList.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final item = savedList[index];
                final isRemoving = state.togglingQuestionIds.contains(item.questionId);
                return SavedQuestionItemCard(
                  item: item,
                  isRemoving: isRemoving,
                  onRemove: () => notifier.removeSavedQuestion(context, item),
                );
              },
            ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required Widget icon,
    required String badgeText,
    required Color badgeColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              icon,
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            badgeText,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateCard({
    required BuildContext context,
    required Widget icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Center(
        child: Column(
          children: [
            icon,
            SizedBox(height: 10.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: context.textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 12.h),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 28.h),
      children: [
        Row(
          children: [
            Expanded(child: _buildSkeletonCard(context, height: 75.h)),
            SizedBox(width: 12.w),
            Expanded(child: _buildSkeletonCard(context, height: 75.h)),
          ],
        ),
        SizedBox(height: 14.h),
        _buildSkeletonCard(context, height: 60.h),
        SizedBox(height: 20.h),
        _buildSkeletonCard(context, height: 160.h),
        SizedBox(height: 14.h),
        _buildSkeletonCard(context, height: 160.h),
      ],
    );
  }

  Widget _buildSkeletonCard(BuildContext context, {required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Center(
        child: SizedBox(
          width: 22.r,
          height: 22.r,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(context.primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String error,
    LiveContestNotifier notifier,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: const Color(0xFFDC2626),
            ),
            SizedBox(height: 12.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () => notifier.loadContentHistory(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text("পুনরায় চেষ্টা করুন"),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
}
