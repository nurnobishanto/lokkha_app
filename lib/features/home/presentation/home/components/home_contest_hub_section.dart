import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/home/presentation/home/components/home_section_header.dart';
import 'package:lokkha/features/home/presentation/home/riverpod/home_feed_notifier.dart';

class HomeContestHubSection extends ConsumerWidget {
  final HomeContestHubModel contestHub;

  const HomeContestHubSection({
    super.key,
    required this.contestHub,
  });

  String _formatBanglaNumber(int n) {
    const enToBn = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
    };
    final str = n.toString().padLeft(2, '0');
    return str.split('').map((c) => enToBn[c] ?? c).join();
  }

  Widget _buildTimeBox(BuildContext context, String value, String unit) {
    return Container(
      width: 44.w,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: context.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: context.primaryColor.withOpacity(0.25),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: context.primaryColor,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 9.sp,
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = contestHub.activeContest;
    final countdown = ref.watch(
      homeFeedNotifierProvider.select((s) => s.contestCountdownParts),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: 'মেগা লাইভ কনটেস্ট',
          subtitle: 'সারাদেশের প্রতিযোগীদের সাথে লাইভ লড়াই',
          icon: Icons.emoji_events_rounded,
          onSeeAll: () {
            if (GoRouter.maybeOf(context) != null) {
              context.push(Routes.allContest);
            }
          },
        ),
        if (active != null)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: context.isDark
                    ? [
                        const Color(0xFF1E293B),
                        const Color(0xFF0F172A),
                      ]
                    : [
                        const Color(0xFFF0FDF4),
                        const Color(0xFFDCFCE7),
                      ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: active.isLive
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            active.isLive ? 'লাইভ চলছে' : 'আসন্ন কনটেস্ট',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (active.durationMinutes > 0)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 13.sp,
                              color: context.textSecondary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${_formatBanglaNumber(active.durationMinutes)} মিনিট',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: context.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  active.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                if (active.description != null && active.description!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    active.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.textSecondary,
                    ),
                  ),
                ],
                if (active.prizeDetails != null && active.prizeDetails!.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                        width: 0.6,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.military_tech_rounded,
                          size: 16.sp,
                          color: const Color(0xFFD97706),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            active.prizeDetails!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildTimeBox(
                            context, _formatBanglaNumber(countdown.days), 'দিন'),
                        SizedBox(width: 4.w),
                        _buildTimeBox(
                            context, _formatBanglaNumber(countdown.hours), 'ঘণ্টা'),
                        SizedBox(width: 4.w),
                        _buildTimeBox(
                            context, _formatBanglaNumber(countdown.minutes), 'মিনিট'),
                        SizedBox(width: 4.w),
                        _buildTimeBox(
                            context, _formatBanglaNumber(countdown.seconds), 'সেকেন্ড'),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (GoRouter.maybeOf(context) != null) {
                          context.push(Routes.contest);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: active.isLive
                            ? const Color(0xFFEF4444)
                            : context.primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        active.isLive ? 'লাইভ অংশ নিন' : 'অংশ নিন',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (contestHub.topLeaderboard.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Row(
              children: [
                Text(
                  contestHub.lastContestName != null
                      ? 'সর্বশেষ ফলাফল: ${contestHub.lastContestName}'
                      : 'সেরা পারফর্মারদের তালিকা',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          SizedBox(
            height: 88.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: contestHub.topLeaderboard.take(3).length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final user = contestHub.topLeaderboard[index];
                return Container(
                  width: 140.w,
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: context.borderColor.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 18.r,
                            backgroundColor: context.primaryColor.withOpacity(0.1),
                            backgroundImage: user.userAvatar != null &&
                                    user.userAvatar!.isNotEmpty
                                ? CachedNetworkImageProvider(user.userAvatar!)
                                : null,
                            child: user.userAvatar == null || user.userAvatar!.isEmpty
                                ? Icon(Icons.person,
                                    size: 18.sp, color: context.primaryColor)
                                : null,
                          ),
                          Positioned(
                            top: -4.r,
                            right: -4.r,
                            child: Container(
                              padding: EdgeInsets.all(3.r),
                              decoration: BoxDecoration(
                                color: index == 0
                                    ? const Color(0xFFF59E0B)
                                    : (index == 1
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFFB45309)),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${user.rank}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'মার্কস: ${user.totalMarks.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: context.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
