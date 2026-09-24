import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../config/theme/light_theme_colors.dart';
import '../../../../../styles/text_style.dart';
import 'package:lokkha/app/data/models/dashboard_overview_model.dart';

class AccuracyChartWidget extends StatelessWidget {
  final List<AccuracyPoint> points;
  final double currentAccuracy;

  const AccuracyChartWidget({
    super.key,
    required this.points,
    required this.currentAccuracy,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "পরীক্ষার নির্ভুলতা (Accuracy Rate)",
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.bold,
                color: LightThemeColors.black,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "পর্যাপ্ত পরীক্ষা দিলে এখানে আপনার অগ্রগতির গ্রাফ দেখা যাবে।",
              style: AppTextStyles.body2.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final spots = points.map((p) => FlSpot(p.x, p.y)).toList();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "পরীক্ষার নির্ভুলতা (Accuracy Rate)",
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: LightThemeColors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: LightThemeColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  "${currentAccuracy.toStringAsFixed(1)}%",
                  style: TextStyle(
                    color: LightThemeColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 140.h,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30.w,
                      interval: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "${value.toInt()}%",
                          style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22.h,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < points.length) {
                          return Text(
                            points[index].label ?? "E${index + 1}",
                            style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: LightThemeColors.primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: LightThemeColors.primaryColor.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
