import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';

class HomeProLeaderboardSection extends StatelessWidget {
  final HomeContestHubModel? contestHub;

  const HomeProLeaderboardSection({
    super.key,
    this.contestHub,
  });

  @override
  Widget build(BuildContext context) {
    final topUsers = contestHub?.topLeaderboard ?? [];
    final countText = contestHub?.leaderboardCount != null
        ? '${contestHub!.leaderboardCount} Users >'
        : '1.1k Users >';

    final displayUsers = (topUsers.isNotEmpty
            ? topUsers
            : [
                HomeLeaderboardUser(
                  rank: 1,
                  userId: 64,
                  userName: 'Tonmoy',
                  userPhoneMasked: '880****0036',
                  correctAnswers: 8,
                  incorrectAnswers: 12,
                  totalMarks: 0,
                  completeDurationSeconds: 23,
                ),
                HomeLeaderboardUser(
                  rank: 2,
                  userId: 2728,
                  userName: 'Tamanna Akter',
                  userPhoneMasked: '880****0776',
                  userAvatar:
                      'https://lh3.googleusercontent.com/a/ACg8ocKLsf9WtAI0qQwSB_ucyX8LF7uE7IS8y4tYcxdRSzwOim7AHU55kg=s96-c',
                  correctAnswers: 5,
                  incorrectAnswers: 15,
                  totalMarks: 0,
                  completeDurationSeconds: 190,
                ),
                HomeLeaderboardUser(
                  rank: 3,
                  userId: 378,
                  userName: 'dider kanon',
                  userPhoneMasked: '880****4034',
                  userAvatar:
                      'https://lh3.googleusercontent.com/a/ACg8ocLwalUTLvf-bXES3UYsarNPKz_ncC31oYINF9Xszwzbw4O9E1o=s96-c',
                  correctAnswers: 4,
                  incorrectAnswers: 16,
                  totalMarks: 0,
                  completeDurationSeconds: 28,
                ),
              ])
        .take(3)
        .toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header: লিডারবোর্ড । প্রো লীগ + See All ─────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'লিডারবোর্ড । প্রো লীগ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.sectionTitle,
                ),
              ),
              InkWell(
                onTap: () {
                  if (GoRouter.maybeOf(context) != null) {
                    context.push(Routes.allContest);
                  }
                },
                child: Text(
                  'See All',
                  style: context.chipText.copyWith(
                    color: const Color(0xFF006A4E),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // ─── Leaderboard Card ──────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: context.isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF1F5F9),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: context.isDark ? 0.35 : 0.06,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: context.isDark ? 0.2 : 0.02,
                  ),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Header: Top Performers + Count Pill
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006A4E),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(13.r),
                      topRight: Radius.circular(13.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              size: 18,
                              color: Color(0xFFFFD166),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                'Top Performers',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.5.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          countText,
                          style: TextStyle(
                            color: const Color(0xFF006A4E),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Performer Rows
                ...displayUsers.asMap().entries.map((entry) {
                  final isLast = entry.key == displayUsers.length - 1;
                  return _buildPerformerRow(
                    context,
                    entry.value,
                    isLast: isLast,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformerRow(
    BuildContext context,
    HomeLeaderboardUser user, {
    bool isLast = false,
  }) {
    // Rank Styling
    Widget rankWidget;

    if (user.rank == 1) {
      rankWidget = Container(
        width: 22.r,
        height: 22.r,
        decoration: const BoxDecoration(
          color: Color(0xFFFEF3C7),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '🥇',
            style: TextStyle(fontSize: 12.sp),
          ),
        ),
      );
    } else if (user.rank == 2) {
      rankWidget = Container(
        width: 22.r,
        height: 22.r,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '🥈',
            style: TextStyle(fontSize: 12.sp),
          ),
        ),
      );
    } else if (user.rank == 3) {
      rankWidget = Container(
        width: 22.r,
        height: 22.r,
        decoration: const BoxDecoration(
          color: Color(0xFFFFEDD5),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '🥉',
            style: TextStyle(fontSize: 12.sp),
          ),
        ),
      );
    } else {
      rankWidget = SizedBox(
        width: 22.r,
        child: Text(
          '#${user.rank}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.bold,
            color: context.textSecondary,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: context.borderColor.withValues(alpha: 0.35),
                  width: 0.5,
                ),
              ),
      ),
      child: Row(
        children: [
          // Rank Badge
          rankWidget,
          SizedBox(width: 8.w),

          // Avatar
          CircleAvatar(
            radius: 16.r,
            backgroundColor: const Color(0xFF006A4E).withValues(alpha: 0.1),
            backgroundImage: user.userAvatar != null &&
                    user.userAvatar!.isNotEmpty
                ? CachedNetworkImageProvider(user.userAvatar!)
                : null,
            child: user.userAvatar == null || user.userAvatar!.isEmpty
                ? Text(
                    user.userName.isNotEmpty
                        ? user.userName.characters.first.toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF006A4E),
                    ),
                  )
                : null,
          ),
          SizedBox(width: 10.w),

          // User Info & Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 2.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (user.userPhoneMasked != null &&
                        user.userPhoneMasked!.isNotEmpty)
                      Text(
                        user.userPhoneMasked!,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: context.textSecondary,
                        ),
                      ),
                    if (user.correctAnswers > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '${user.correctAnswers} সঠিক',
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Duration & Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (user.completeDurationSeconds > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: context.borderColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    '${user.completeDurationSeconds}s',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: context.textSecondary,
                    ),
                  ),
                ),
              SizedBox(height: 2.h),
              Text(
                '${user.totalMarks.toInt()} Marks',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF006A4E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
