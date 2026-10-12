import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/features/contest/contest.dart';

class LatestContestWidget extends ConsumerWidget {
  const LatestContestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(latestContestNotifierProvider);

    if (state.contestModel?.contest == null) {
      return const SizedBox.shrink();
    }

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ContestTabView()),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7.0),
        child: Stack(
          children: [
            Image.network(
              state.imageUrl,
              height: 110.0.h,
              width: double.infinity,
              fit: BoxFit.fitWidth,
              errorBuilder: (_, __, ___) => Container(
                height: 110.0.h,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            Positioned(
              top: 8.0,
              left: 8.0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: state.status == 'timer'
                    ? Text(
                        "${state.hours.toString().padLeft(2, '0')}:"
                        "${state.minutes.toString().padLeft(2, '0')}:"
                        "${state.seconds.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : state.status == 'ongoing'
                        ? const Text(
                            "🟡 Ongoing",
                            style: TextStyle(color: Colors.white),
                          )
                        : const Text(
                            '🔴 Ended',
                            style: TextStyle(color: Colors.white),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
