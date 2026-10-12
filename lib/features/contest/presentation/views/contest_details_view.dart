import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/contest/contest.dart' hide Contest;
import 'package:lokkha/shared/models/contest.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContestDetailsView extends ConsumerStatefulWidget {
  final Contest contest;
  const ContestDetailsView({super.key, required this.contest});

  @override
  ConsumerState<ContestDetailsView> createState() => _ContestDetailsViewState();
}

class _ContestDetailsViewState extends ConsumerState<ContestDetailsView> {
  Timer? _timer;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  String _status = 'timer';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    final startStr = widget.contest.startDatetime?.toString();
    final endStr = widget.contest.endDatetime?.toString();
    if (startStr == null || endStr == null) return;

    try {
      final startTime = DateTime.parse(startStr);
      final endTime = DateTime.parse(endStr);
      final now = DateTime.now();

      if (startTime.isAfter(now)) {
        int totalSeconds = startTime.difference(now).inSeconds;
        _hours = totalSeconds ~/ 3600;
        _minutes = (totalSeconds % 3600) ~/ 60;
        _seconds = totalSeconds % 60;
        _status = 'timer';

        _timer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (totalSeconds > 0) {
            totalSeconds--;
            if (mounted) {
              setState(() {
                _hours = totalSeconds ~/ 3600;
                _minutes = (totalSeconds % 3600) ~/ 60;
                _seconds = totalSeconds % 60;
              });
            }
          } else {
            t.cancel();
            if (mounted) {
              setState(() {
                _status = 'ongoing';
              });
            }
          }
        });
      } else if (now.isBefore(endTime)) {
        _status = 'ongoing';
      } else {
        _status = 'ended';
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final contest = widget.contest;
    final notifier = ref.read(latestContestNotifierProvider.notifier);

    return Scaffold(
      appBar: CustomAppBar(title: contest.name ?? ''),
      floatingActionButton: _status == "ongoing"
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
                            notifier.startContest(context, contest.id!.toInt());
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
          : _status == 'ended'
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ContestResultView(
                          contestResults: contest.results?.toList() ?? [],
                        ),
                      ),
                    );
                  },
                  label: const Text(
                    "ফলাফল দেখুন",
                    style: TextStyle(color: Colors.white),
                  ),
                  icon: const Icon(
                    Icons.visibility,
                    color: Colors.white,
                  ),
                  backgroundColor: LightThemeColors.primaryColor,
                )
              : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(7.0.r),
                child: Stack(
                  children: [
                    Image.network(
                      AppConstants.resolveUrl(contest.sponsorImage.toString()),
                      height: 110.0.h,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      errorBuilder: (_, __, ___) => Container(
                        height: 110.0.h,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child:
                              Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8.0,
                      left: 8.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: _status == 'timer'
                            ? Text(
                                "${_hours.toString().padLeft(2, '0')}:"
                                "${_minutes.toString().padLeft(2, '0')}:"
                                "${_seconds.toString().padLeft(2, '0')}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12.sp),
                              )
                            : _status == 'ongoing'
                                ? const Text("🟡 Ongoing",
                                    style: TextStyle(color: Colors.white))
                                : const Text("🔴 Ended",
                                    style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              if (contest.description != null) ...[
                SizedBox(height: 10.0.h),
                HtmlWidget(contest.description.toString()),
              ],
              if (contest.sponsorImage != null) ...[
                SizedBox(height: 10.0.h),
                InkWell(
                  onTap: () {
                    if (contest.sponsorUrl != null) {
                      launchUrlString(contest.sponsorUrl.toString());
                    }
                  },
                  child: Image.network(
                    AppConstants.storageUrl + contest.sponsorImage!,
                  ),
                ),
              ],
              if (contest.sponsorDetails != null) ...[
                SizedBox(height: 10.0.h),
                HtmlWidget(contest.sponsorDetails.toString()),
              ],
              if (contest.prizeDetails != null) ...[
                SizedBox(height: 10.0.h),
                HtmlWidget(contest.prizeDetails!),
              ],
              if (contest.contestPolicy != null) ...[
                SizedBox(height: 10.0.h),
                HtmlWidget(contest.contestPolicy!),
              ],
              SizedBox(height: 80.0.h),
            ],
          ),
        ),
      ),
    );
  }
}
