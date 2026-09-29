import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/constants/app_constants.dart';

import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/contest/contest.dart';
import 'contest_details_view.dart';

class AllContestView extends StatelessWidget {
  const AllContestView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LatestContestController>();
    return isLoggedIn.value != true
        ? const AuthGatewayView()
        : Scaffold(
            body: Obx(() {
              return controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: EdgeInsets.all(8.0.r),
                      child: RefreshIndicator(
                        onRefresh: () async {
                          return await controller.fetchAllContest();
                        },
                        child: ListView.separated(
                          itemCount:
                              controller.allContestModel.value.contests!.length,
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (_, index) {
                            final contest = controller
                                .allContestModel.value.contests![index];
                            final timerModel =
                                controller.contestTimers[contest.id];
                            return InkWell(
                              onTap: () {
                                Get.to(
                                    () => ContestDetailsView(contest: contest));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7.0.r),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      AppConstants.storageUrl +
                                          contest.sponsorImage.toString(),
                                      height: 110.0.h,
                                      width: double.infinity,
                                      fit: BoxFit.fitWidth,
                                    ),
                                    Positioned(
                                      top: 8.0,
                                      left: 8.0,
                                      child: Obx(() {
                                        if (timerModel == null) {
                                          return const SizedBox();
                                        }
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4.0),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          child: timerModel.status.value ==
                                                  'timer'
                                              ? Text(
                                                  "${timerModel.hours.value.toString().padLeft(2, '0')}:"
                                                  "${timerModel.minutes.value.toString().padLeft(2, '0')}:"
                                                  "${timerModel.seconds.value.toString().padLeft(2, '0')}",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.sp),
                                                )
                                              : timerModel.status.value ==
                                                      'ongoing'
                                                  ? const Text("🟡 Ongoing",
                                                      style: TextStyle(
                                                          color: Colors.white))
                                                  : const Text("🔴 Ended",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                        );
                                      }),
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
            }),
          );
  }
}
