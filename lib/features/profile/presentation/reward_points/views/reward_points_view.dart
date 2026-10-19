import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/profile/presentation/reward_points/riverpod/reward_points_notifier.dart';

class RewardPointsView extends ConsumerStatefulWidget {
  const RewardPointsView({super.key});

  @override
  ConsumerState<RewardPointsView> createState() => _RewardPointsViewState();
}

class _RewardPointsViewState extends ConsumerState<RewardPointsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(rewardPointsNotifierProvider.notifier).loadMore();
    }
  }

  static String _toBengaliNumber(int number) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final s = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final code = s.codeUnitAt(i);
      if (code >= 48 && code <= 57) {
        buffer.write(bengaliDigits[code - 48]);
      } else {
        buffer.write(s[i]);
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rewardPointsNotifierProvider);
    final notifier = ref.read(rewardPointsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: const CustomAppBar(
        title: "রিওয়ার্ড পয়েন্ট",
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: context.primaryColor,
        onRefresh: notifier.refresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Live Balance Hero Card
                    _buildBalanceHeroCard(context, state.balance),

                    SizedBox(height: 12.h),

                    // 2. Metrics Breakdown (4 Cards in 2x2 grid)
                    _buildMetricsGrid(context, state.balance),

                    SizedBox(height: 16.h),

                    // 3. Transactions Section Header & Tabs
                    _buildTransactionsHeader(context, state, notifier),
                  ],
                ),
              ),
            ),

            // 4. Transactions List or Empty / Loading State
            if (state.isLoading && state.transactions.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: context.primaryColor,
                    ),
                  ),
                ),
              )
            else if (state.transactions.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmptyTransactions(context),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 24.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == state.transactions.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          child: Center(
                            child: SizedBox(
                              width: 22.r,
                              height: 22.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.primaryColor,
                              ),
                            ),
                          ),
                        );
                      }
                      final item = state.transactions[index];
                      return _buildTransactionCard(context, item);
                    },
                    childCount: state.transactions.length +
                        (state.isLoadingMore ? 1 : 0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── 1. Live Balance Hero Card ───────────────────────────────────────────
  Widget _buildBalanceHeroCard(BuildContext context, RewardPointsBalance balance) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF064E3B),
            Color(0xFF047857),
            Color(0xFF059669),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.monetization_on_rounded,
                      size: 22.sp,
                      color: const Color(0xFFFBBF24),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'রিওয়ার্ড ব্যালেন্স',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                      Text(
                        '${_toBengaliNumber(balance.balance)} পয়েন্ট',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () => context.push(Routes.referral),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.group_add_rounded,
                        size: 14.sp,
                        color: const Color(0xFF0F172A),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'রেফার করুন',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 13.sp,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'রেফারেল ও বিভিন্ন কার্যক্রমে রিওয়ার্ড পয়েন্ট অর্জন করা যায়।',
                    style: TextStyle(
                      fontSize: 10.8.sp,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. Metrics Breakdown Grid ───────────────────────────────────────────
  Widget _buildMetricsGrid(BuildContext context, RewardPointsBalance balance) {
    return Row(
      children: [
        // সর্বমোট অর্জিত
        Expanded(
          child: _buildMetricTile(
            context: context,
            icon: Icons.trending_up_rounded,
            iconBg: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF16A34A),
            title: 'মোট অর্জিত',
            value: '+${_toBengaliNumber(balance.totalEarned)}',
            valueColor: const Color(0xFF16A34A),
          ),
        ),
        SizedBox(width: 8.w),

        // ব্যবহৃত
        Expanded(
          child: _buildMetricTile(
            context: context,
            icon: Icons.shopping_bag_outlined,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            title: 'ব্যবহৃত',
            value: '-${_toBengaliNumber(balance.totalUsed)}',
            valueColor: const Color(0xFFD97706),
          ),
        ),
        SizedBox(width: 8.w),

        // মেয়াদোত্তীর্ণ
        Expanded(
          child: _buildMetricTile(
            context: context,
            icon: Icons.timer_off_outlined,
            iconBg: const Color(0xFFFEE2E2),
            iconColor: const Color(0xFFDC2626),
            title: 'মেয়াদোত্তীর্ণ',
            value: '-${_toBengaliNumber(balance.totalExpired)}',
            valueColor: const Color(0xFFDC2626),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.8),
          width: 0.85,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDark ? 0.2 : 0.02,
            ),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(icon, size: 14.sp, color: iconColor),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 3. Transactions Section Header & Tabs ───────────────────────────────
  Widget _buildTransactionsHeader(
    BuildContext context,
    RewardPointsState state,
    RewardPointsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'পয়েন্ট লেনদেনের বিবরণী',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
              ),
            ),
            Text(
              'মোট ${state.transactions.length}টি',
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // Segmented filter tabs
        Container(
          padding: EdgeInsets.all(3.r),
          decoration: BoxDecoration(
            color: context.surfaceSubtle,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: context.borderColor.withValues(alpha: 0.6),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              _buildFilterTab(
                context,
                title: 'সকল',
                tabKey: 'all',
                isSelected: state.currentTab == 'all',
                onTap: () => notifier.setTab('all'),
              ),
              _buildFilterTab(
                context,
                title: 'অর্জিত',
                tabKey: 'earned',
                isSelected: state.currentTab == 'earned',
                onTap: () => notifier.setTab('earned'),
              ),
              _buildFilterTab(
                context,
                title: 'ব্যবহৃত',
                tabKey: 'used',
                isSelected: state.currentTab == 'used',
                onTap: () => notifier.setTab('used'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab(
    BuildContext context, {
    required String title,
    required String tabKey,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected ? context.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: context.primaryColor.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : context.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ─── 4. Transaction Card ─────────────────────────────────────────────────
  Widget _buildTransactionCard(BuildContext context, RewardTransactionItem item) {
    final isEarned = item.isEarned;
    final pointsText = isEarned
        ? '+${_toBengaliNumber(item.points.abs())}'
        : '-${_toBengaliNumber(item.points.abs())}';

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.75),
          width: 0.85,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: isEarned ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarned ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              size: 17.sp,
              color: isEarned ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                if (item.createdAt != null && item.createdAt!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    item.createdAt!,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: context.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.5.h),
            decoration: BoxDecoration(
              color: isEarned ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '$pointsText Pts',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: isEarned ? const Color(0xFF059669) : const Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 5. Empty Transactions View ──────────────────────────────────────────
  Widget _buildEmptyTransactions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 58.r,
              height: 58.r,
              decoration: BoxDecoration(
                color: context.surfaceSubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 28.sp,
                color: context.textMuted,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'কোনো লেনদেন রেকর্ড পাওয়া যায়নি',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'বন্ধুদের রেফার করে অথবা পরীক্ষায় অংশগ্রহণ করে রিওয়ার্ড পয়েন্ট অর্জন করুন।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: context.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
