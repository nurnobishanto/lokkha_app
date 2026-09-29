import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';
import 'package:lokkha/features/contest/presentation/controllers/latest_contest_controller.dart';
import 'package:lokkha/features/contest/presentation/views/contest_result_view.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:lokkha/core/theme/light_theme_colors.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/shared/models/contest.dart';
import 'package:lokkha/features/auth/auth.dart';

class ContestDetailsView extends StatelessWidget {
  final Contest contest;
  const ContestDetailsView({super.key, required this.contest});

  @override
  Widget build(BuildContext context) {
    final timerModel = ContestTimerModel();
    timerModel.start(
      DateTime.parse(contest.startDatetime!.toString()),
      DateTime.parse(contest.endDatetime!.toString()),
    );
    return Scaffold(
      appBar: CustomAppBar(title: contest.name.toString()),
      floatingActionButton: Obx(() {
        if (timerModel.status.value == "ongoing") {
          return FloatingActionButton.extended(
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    "নিশ্চিত?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text('আপনি কি নিশ্চিতভাবে চালিয়ে যেতে চান?'),
                  actionsPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  actionsAlignment: MainAxisAlignment.end,
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text('বাতিল'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (MySharedPref.getUserToken() != '' ||
                            MySharedPref.getUserToken().isNotEmpty) {
                          Get.find<LatestContestController>()
                              .startContest(contest.id!.toInt());
                          Get.back();
                        } else {
                          Get.to(const AuthGatewayView());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('ঠিক আছে'),
                    ),
                  ],
                ),
              );
            },
            label: const Text(
              "কনটেস্ট শুরু করুন",
              style: TextStyle(color: Colors.white),
            ),
            icon: const Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),
            backgroundColor: LightThemeColors.primaryColor,
          );
        } else if (timerModel.status.value == 'ended') {
          return FloatingActionButton.extended(
            onPressed: () {
              Get.to(
                ContestResultView(
                  contestResults: contest.results!.toList(),
                ),
              );
            },
            label: const Text(
              "রেজাল্ট দেখুন",
              style: TextStyle(color: Colors.white),
            ),
            icon: const Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),
            backgroundColor: LightThemeColors.primaryColor,
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(7.0.r),
                child: Stack(
                  children: [
                    Image.network(
                      AppConstants.storageUrl + contest.image.toString(),
                      height: 110.0.h,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                    Positioned(
                      top: 8.0,
                      left: 8.0,
                      child: Obx(() {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: timerModel.status.value == 'timer'
                              ? Text(
                                  "${timerModel.hours.value.toString().padLeft(2, '0')}:"
                                  "${timerModel.minutes.value.toString().padLeft(2, '0')}:"
                                  "${timerModel.seconds.value.toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12.sp),
                                )
                              : timerModel.status.value == 'ongoing'
                                  ? const Text("🟡 Ongoing",
                                      style: TextStyle(color: Colors.white))
                                  : const Text("🔴 Ended",
                                      style: TextStyle(color: Colors.white)),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              contest.description != null
                  ? HtmlWidget(
                      contest.description.toString(),
                    )
                  : const SizedBox.shrink(),
              contest.sponsorImage != null
                  ? Column(
                      children: [
                        SizedBox(height: 10.0.h),
                        InkWell(
                          onTap: () {
                            launchUrlString(contest.sponsorUrl.toString());
                          },
                          child: Image.network(
                            AppConstants.storageUrl + contest.sponsorImage!,
                          ),
                        ),
                        SizedBox(height: 10.0.h),
                        contest.sponsorDetails != null
                            ? HtmlWidget(
                                contest.sponsorDetails.toString(),
                              )
                            : const SizedBox.shrink(),
                      ],
                    )
                  : const SizedBox.shrink(),
              SizedBox(height: 10.0.h),
              contest.prizeDetails != null
                  ? HtmlWidget(
                      contest.prizeDetails.toString(),
                    )
                  : const SizedBox.shrink(),
              SizedBox(height: 10.0.h),
              contest.contestPolicy != null
                  ? HtmlWidget(
                      contest.contestPolicy.toString(),
                    )
                  : const SizedBox.shrink(),
              SizedBox(height: 80.0.h),
            ],
          ),
        ),
      ),
    );
  }
}

class ContestTimerModel {
  RxInt hours = 0.obs;
  RxInt minutes = 0.obs;
  RxInt seconds = 0.obs;
  RxString status = 'timer'.obs;
  Timer? timer;

  void start(DateTime startTime, DateTime endTime) {
    final now = DateTime.now();

    if (startTime.isAfter(now)) {
      int totalSeconds = startTime.difference(now).inSeconds;

      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (totalSeconds > 0) {
          totalSeconds--;

          hours.value = totalSeconds ~/ 3600;
          minutes.value = (totalSeconds % 3600) ~/ 60;
          seconds.value = totalSeconds % 60;
        } else {
          status.value = 'ongoing';

          t.cancel();
        }
      });
    } else if (now.isBefore(endTime)) {
      status.value = 'ongoing';
    } else {
      status.value = 'ended';
    }
  }

  void dispose() {
    timer?.cancel();
  }
}
