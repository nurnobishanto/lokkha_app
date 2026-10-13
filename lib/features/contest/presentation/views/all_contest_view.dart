import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/contest/contest.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';

class AllContestView extends ConsumerWidget {
  final bool showAppBar;
  const AllContestView({super.key, this.showAppBar = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoggedIn.value != true) {
      return const AuthGatewayView();
    }

    final state = ref.watch(latestContestNotifierProvider);
    final notifier = ref.read(latestContestNotifierProvider.notifier);

    return Scaffold(
      appBar: showAppBar ? const CustomAppBar(title: 'সকল কনটেস্ট') : null,
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final contests = state.allContestModel?.contests ?? [];
          if (contests.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                await notifier.fetchAllContest();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 120.h),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events_outlined,
                            size: 52.r, color: Colors.grey.shade400),
                        SizedBox(height: 10.h),
                        Text(
                          "কোনো কনটেস্ট পাওয়া যায়নি",
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.all(8.0.r),
            child: RefreshIndicator(
              onRefresh: () async {
                await notifier.fetchAllContest();
              },
              child: ListView.separated(
                itemCount: contests.length,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (_, index) {
                  final contest = contests[index];
                  final timerData = state.contestTimers[contest.id];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ContestDetailsView(contest: contest),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7.0.r),
                      child: Stack(
                        children: [
                          Image.network(
                            Endpoints.resolveUrl(
                                contest.sponsorImage.toString()),
                            height: 110.0.h,
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                            errorBuilder: (_, __, ___) => Container(
                              height: 110.0.h,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.image_not_supported,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8.0,
                            left: 8.0,
                            child: timerData == null
                                ? const SizedBox.shrink()
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius:
                                          BorderRadius.circular(5.0),
                                    ),
                                    child: timerData.status == 'timer'
                                        ? Text(
                                            "${timerData.hours.toString().padLeft(2, '0')}:"
                                            "${timerData.minutes.toString().padLeft(2, '0')}:"
                                            "${timerData.seconds.toString().padLeft(2, '0')}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.sp),
                                          )
                                        : timerData.status == 'ongoing'
                                            ? const Text("🟡 Ongoing",
                                                style: TextStyle(
                                                    color: Colors.white))
                                            : const Text("🔴 Ended",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => 10.0.h.height,
              ),
            ),
          );
        },
      ),
    );
  }
}
