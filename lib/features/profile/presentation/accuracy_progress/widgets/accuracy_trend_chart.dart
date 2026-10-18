import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/features/profile/data/models/accuracy_response_model.dart';
import 'package:lokkha/features/profile/data/models/accuracy_trend_point_model.dart';

class AccuracyTrendChart extends StatelessWidget {
  final AccuracyChartDataModel? chart;
  final List<AccuracyTrendPointModel>? points;
  final String avgAccuracy;
  final String highestAccuracy;

  const AccuracyTrendChart({
    super.key,
    this.chart,
    this.points,
    required this.avgAccuracy,
    required this.highestAccuracy,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Resolve spots, labels, titles
    List<FlSpot> spots = [];
    List<String> labels = [];
    List<String> titles = [];

    if (chart != null && (chart!.points.isNotEmpty || chart!.data.isNotEmpty)) {
      spots = chart!.flSpots;
      labels = chart!.labels;
      titles = chart!.titles;
    } else if (points != null && points!.isNotEmpty) {
      spots = points!
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value.percentage.clamp(0.0, 100.0)))
          .toList();
      labels = points!.map((e) => e.date).toList();
    }

    final hasData = spots.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Icon + Title + Exam Count)
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                size: 20.sp,
                color: const Color(0xFF059669),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "নির্ভুলতা ও পারফরম্যান্স ট্রেন্ড গ্রাফ",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
              ),
              if (spots.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? const Color(0xFF064E3B).withValues(alpha: 0.3)
                        : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFA7F3D0), width: 0.8),
                  ),
                  child: Text(
                    "${spots.length} টি পরীক্ষা",
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 3.h),
          Text(
            spots.length > 6
                ? "আপনার সর্বশেষ পরীক্ষাগুলোর নির্ভুলতার শতকরা হার (%) • ডানে স্ক্রোল করুন ↔"
                : "আপনার সর্বশেষ পরীক্ষাগুলোর নির্ভুলতার শতকরা হার (%)",
            style: TextStyle(
              fontSize: 11.5.sp,
              color: context.textSecondary,
            ),
          ),

          SizedBox(height: 12.h),

          // 2. Badges Row (গড় & সর্বোচ্চ)
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              // গড় Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? const Color(0xFF064E3B).withValues(alpha: 0.3)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.adjust_rounded,
                      size: 13.sp,
                      color: const Color(0xFF059669),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "গড়: $avgAccuracy",
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),

              // সর্বোচ্চ Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF065F46),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events_rounded,
                      size: 13.sp,
                      color: const Color(0xFFFEF08A),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "সর্বোচ্চ: $highestAccuracy",
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 18.h),

          // 3. Chart Area (fl_chart or empty state)
          if (!hasData)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_graph_rounded,
                      size: 36.sp,
                      color: context.textSecondary.withValues(alpha: 0.3),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "পর্যাপ্ত পরীক্ষা দিলে এখানে আপনার নির্ভুলতার গ্রাফ দেখা যাবে।",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: context.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 200.h,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final minWidth = constraints.maxWidth;
                  // If many spots, allow smooth horizontal scroll
                  final neededWidth = math.max(minWidth, spots.length * 48.w);
                  final isScrollable = neededWidth > minWidth;

                  final chartWidget = SizedBox(
                    width: neededWidth,
                    height: 200.h,
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 100,
                        minX: 0,
                        maxX: (spots.length > 1 ? spots.length - 1 : 1).toDouble(),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 25,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: context.borderColor.withValues(alpha: 0.6),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40.w,
                              interval: 25,
                              getTitlesWidget: (value, meta) {
                                if (value % 25 != 0) return const SizedBox.shrink();
                                return Padding(
                                  padding: EdgeInsets.only(right: 6.w),
                                  child: Text(
                                    "${value.toInt()}%",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: context.textSecondary,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28.h,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < labels.length) {
                                  return Padding(
                                    padding: EdgeInsets.only(top: 8.h),
                                    child: Text(
                                      labels[index],
                                      style: TextStyle(
                                        color: context.textSecondary,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22.h,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < spots.length) {
                                  final val = spots[index].y;
                                  if (val > 0) {
                                    final valStr = val % 1 == 0
                                        ? "${val.toInt()}%"
                                        : "${val.toStringAsFixed(1)}%";
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 2.h),
                                      child: Text(
                                        valStr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF059669),
                                          fontSize: 9.5.sp,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    );
                                  }
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineTouchData: LineTouchData(
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => const Color(0xFF065F46),
                            tooltipRoundedRadius: 8.r,
                            tooltipPadding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final idx = spot.x.toInt();
                                final title = (idx >= 0 &&
                                        idx < titles.length &&
                                        titles[idx].isNotEmpty)
                                    ? titles[idx]
                                    : (idx >= 0 && idx < labels.length
                                        ? labels[idx]
                                        : "পরীক্ষা ${idx + 1}");
                                return LineTooltipItem(
                                  "$title\n${spot.y.toStringAsFixed(1)}%",
                                  TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.5.sp,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: spots.length > 1,
                            curveSmoothness: 0.35,
                            color: const Color(0xFF059669),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                final isNonZero = spot.y > 0;
                                return FlDotCirclePainter(
                                  radius: isNonZero ? 5.0 : 3.5,
                                  color: isNonZero ? const Color(0xFF059669) : Colors.white,
                                  strokeWidth: isNonZero ? 2.0 : 2.5,
                                  strokeColor: isNonZero ? Colors.white : const Color(0xFF059669),
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFF059669).withValues(alpha: 0.25),
                                  const Color(0xFF059669).withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (isScrollable) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: chartWidget,
                    );
                  }
                  return chartWidget;
                },
              ),
            ),
        ],
      ),
    );
  }
}
