import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/contest/contest.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LatestContestView extends ConsumerWidget {
  const LatestContestView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoggedIn.value != true) {
      return const AuthGatewayView();
    }

    final state = ref.watch(latestContestNotifierProvider);
    final notifier = ref.read(latestContestNotifierProvider.notifier);
    final contest = state.contestModel?.contest;

    return Scaffold(
      floatingActionButton: state.status == "ongoing" && contest?.id != null
          ? FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
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
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        child: const Text('বাতিল'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogCtx).pop();
                          if (MySharedPref.getUserToken().isNotEmpty) {
                            notifier.startContest(context, contest!.id!.toInt());
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AuthGatewayView(),
                              ),
                            );
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
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LatestContestWidget(),
                    if (contest?.description != null)
                      HtmlWidget(
                        contest!.description.toString(),
                      ),
                    if (contest?.sponsorImage != null)
                      Column(
                        children: [
                          SizedBox(height: 10.0.h),
                          InkWell(
                            onTap: () {
                              if (contest?.sponsorUrl != null) {
                                launchUrlString(contest!.sponsorUrl.toString());
                              }
                            },
                            child: Image.network(
                              AppConstants.storageUrl + contest!.sponsorImage!,
                            ),
                          ),
                          SizedBox(height: 10.0.h),
                          if (contest.sponsorDetails != null)
                            HtmlWidget(
                              contest.sponsorDetails.toString(),
                            ),
                        ],
                      ),
                    SizedBox(height: 10.0.h),
                    if (contest?.prizeDetails != null)
                      HtmlWidget(
                        contest!.prizeDetails!,
                      ),
                    SizedBox(height: 10.0.h),
                    if (contest?.contestPolicy != null)
                      HtmlWidget(
                        contest!.contestPolicy!,
                      ),
                    SizedBox(height: 80.0.h),
                  ],
                ),
              ),
      ),
    );
  }
}
