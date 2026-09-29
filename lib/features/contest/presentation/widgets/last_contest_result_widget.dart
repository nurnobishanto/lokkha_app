import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/contest/presentation/controllers/latest_contest_controller.dart';
import 'package:lokkha/core/theme/theme_extensions.dart';
import 'package:lokkha/core/theme/text_style.dart';
import 'package:lokkha/features/home/home.dart';
import '../views/contest_result_view.dart';

class LastContestResultWidget extends StatelessWidget {
  const LastContestResultWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LatestContestController());
    return Obx(() {
      return Column(
        children: [
          controller.rankUsers.isNotEmpty
              ? Text(
                  "সর্বশেষ বিজয়ীদের তালিকা",
                  style: AppTextStyles.custom(
                    fontSize: 16.00.sp,
                    fontWeight: FontWeight.w600,
                  ).copyWith(color: context.textPrimary),
                )
              : const SizedBox(),
          controller.isResultLoading.value
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : InkWell(
                  onTap: () {
                    Get.to(ContestResultView(
                        contestResults: controller
                            .lastContestResultModel.value.contestResults!
                            .toList()));
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
                        controller.rankUsers.length >= 3
                            ? 3
                            : controller.rankUsers.length,
                        (index) {
                          int displayRank = controller.rankUsers[index]
                              .rank; // can change this based on actual data
                          double topPadding = index == 1 ? 1.h : 30.h;
                          return Padding(
                            padding: EdgeInsets.only(top: topPadding),
                            child: topRankedUser(
                                imagePath: controller.rankUsers[index].image
                                    .toString(),
                                id: controller.rankUsers[index].userId
                                    .toString(),
                                rank: displayRank,
                                isFirst: displayRank == 1,
                                user: controller.rankUsers[index].user),
                          );
                        },
                      ),
                    ),
                  ),
                ),
        ],
      );
    });
  }
}
