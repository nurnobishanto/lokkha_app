import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/contest/presentation/widgets/latest_contest_widget.dart';
import 'package:lokkha/core/theme/light_theme_colors.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:lokkha/features/contest/contest.dart';

class LatestContestView extends StatelessWidget {
  const LatestContestView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LatestContestController());
    return isLoggedIn.value != true
        ? const AuthGatewayView()
        : Scaffold(
            floatingActionButton: Obx(() {
              if (controller.status.value == "ongoing") {
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
                        content:
                            const Text('আপনি কি নিশ্চিতভাবে চালিয়ে যেতে চান?'),
                        actionsPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        actionsAlignment: MainAxisAlignment.end,
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            child: const Text('বাতিল'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (MySharedPref.getUserToken() != '' ||
                                  MySharedPref.getUserToken().isNotEmpty) {
                                controller.startContest(controller
                                    .contestModel.value.contest!.id!
                                    .toInt());

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
              } else {
                return const SizedBox.shrink();
              }
            }),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: controller.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const LatestContestWidget(),
                          controller.contestModel.value.contest!.description !=
                                  null
                              ? HtmlWidget(
                                  controller
                                      .contestModel.value.contest!.description
                                      .toString(),
                                )
                              : const SizedBox.shrink(),
                          controller.contestModel.value.contest!.sponsorImage !=
                                  null
                              ? Column(
                                  children: [
                                    SizedBox(height: 10.0.h),
                                    InkWell(
                                      onTap: () {
                                        launchUrlString(controller.contestModel
                                            .value.contest!.sponsorUrl
                                            .toString());
                                      },
                                      child: Image.network(
                                        AppConstants.storageUrl +
                                            controller.contestModel.value
                                                .contest!.sponsorImage!,
                                      ),
                                    ),
                                    SizedBox(height: 10.0.h),
                                    controller.contestModel.value.contest!
                                                .sponsorDetails !=
                                            null
                                        ? HtmlWidget(
                                            controller.contestModel.value
                                                .contest!.sponsorDetails
                                                .toString(),
                                          )
                                        : const SizedBox.shrink(),
                                  ],
                                )
                              : const SizedBox.shrink(),
                          SizedBox(height: 10.0.h),
                          controller.contestModel.value.contest!.prizeDetails !=
                                  null
                              ? HtmlWidget(
                                  controller
                                      .contestModel.value.contest!.prizeDetails,
                                )
                              : const SizedBox.shrink(),
                          SizedBox(height: 10.0.h),
                          controller.contestModel.value.contest!
                                      .contestPolicy !=
                                  null
                              ? HtmlWidget(
                                  controller.contestModel.value.contest!
                                      .contestPolicy,
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
