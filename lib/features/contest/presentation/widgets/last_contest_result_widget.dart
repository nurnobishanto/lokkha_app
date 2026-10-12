import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/contest/contest.dart';
import 'package:lokkha/features/home/home.dart';

class LastContestResultWidget extends ConsumerWidget {
  const LastContestResultWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(latestContestNotifierProvider);

    return Column(
      children: [
        if (state.rankUsers.isNotEmpty)
          Text(
            "সর্বশেষ বিজয়ীদের তালিকা",
            style: AppTextStyles.custom(
              fontSize: 16.00.sp,
              fontWeight: FontWeight.w600,
            ).copyWith(color: context.textPrimary),
          ),
        if (state.isResultLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ContestResultView(
                    contestResults: state.lastContestResultModel?.contestResults
                            ?.toList() ??
                        [],
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: context.isDark
                    ? context.cardColor
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: context.isDark
                      ? context.borderColor
                      : Colors.green.shade100,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  state.rankUsers.length >= 3 ? 3 : state.rankUsers.length,
                  (index) {
                    final rankUser = state.rankUsers[index];
                    int displayRank = rankUser.rank;
                    double topPadding = index == 1 ? 1.h : 30.h;
                    return Padding(
                      padding: EdgeInsets.only(top: topPadding),
                      child: topRankedUser(
                        imagePath: rankUser.image.toString(),
                        id: rankUser.userId.toString(),
                        rank: displayRank,
                        isFirst: displayRank == 1,
                        user: rankUser.user,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
