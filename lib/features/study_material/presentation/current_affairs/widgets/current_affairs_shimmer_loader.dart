import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CurrentAffairsShimmerLoader extends StatefulWidget {
  const CurrentAffairsShimmerLoader({super.key});

  @override
  State<CurrentAffairsShimmerLoader> createState() => _CurrentAffairsShimmerLoaderState();
}

class _CurrentAffairsShimmerLoaderState extends State<CurrentAffairsShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC);

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            // Date Banner Shimmer
            Container(
              margin: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  _buildShimmerBox(
                    width: 160.w,
                    height: 28.h,
                    borderRadius: 8.r,
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                  ),
                ],
              ),
            ),

            // Question Card Shimmers
            ...List.generate(3, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Shimmer (2 lines)
                    _buildShimmerBox(
                      width: double.infinity,
                      height: 16.h,
                      borderRadius: 4.r,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                    ),
                    SizedBox(height: 8.h),
                    _buildShimmerBox(
                      width: 200.w,
                      height: 16.h,
                      borderRadius: 4.r,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                    ),
                    SizedBox(height: 14.h),

                    // Options Shimmer (2x2 grid)
                    Row(
                      children: [
                        Expanded(
                          child: _buildShimmerBox(
                            width: double.infinity,
                            height: 14.h,
                            borderRadius: 4.r,
                            baseColor: baseColor,
                            highlightColor: highlightColor,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildShimmerBox(
                            width: double.infinity,
                            height: 14.h,
                            borderRadius: 4.r,
                            baseColor: baseColor,
                            highlightColor: highlightColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildShimmerBox(
                            width: double.infinity,
                            height: 14.h,
                            borderRadius: 4.r,
                            baseColor: baseColor,
                            highlightColor: highlightColor,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildShimmerBox(
                            width: double.infinity,
                            height: 14.h,
                            borderRadius: 4.r,
                            baseColor: baseColor,
                            highlightColor: highlightColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Correct Answer Pill & Action Icons Shimmer
                    Row(
                      children: [
                        _buildShimmerBox(
                          width: 140.w,
                          height: 24.h,
                          borderRadius: 6.r,
                          baseColor: baseColor,
                          highlightColor: highlightColor,
                        ),
                        const Spacer(),
                        _buildShimmerBox(
                          width: 22.w,
                          height: 22.h,
                          borderRadius: 4.r,
                          baseColor: baseColor,
                          highlightColor: highlightColor,
                        ),
                        SizedBox(width: 12.w),
                        _buildShimmerBox(
                          width: 22.w,
                          height: 22.h,
                          borderRadius: 4.r,
                          baseColor: baseColor,
                          highlightColor: highlightColor,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Divider(color: Colors.grey.withValues(alpha: 0.15), height: 1),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
    required Color baseColor,
    required Color highlightColor,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            baseColor,
            highlightColor,
            baseColor,
          ],
          stops: [
            (_shimmerController.value - 0.3).clamp(0.0, 1.0),
            _shimmerController.value.clamp(0.0, 1.0),
            (_shimmerController.value + 0.3).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }
}
