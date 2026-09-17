import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/accuracy_trend_point_model.dart';

class AccuracyTrendChart extends StatelessWidget {
  final List<AccuracyTrendPointModel> points;
  final String avgAccuracy;
  final String highestAccuracy;

  const AccuracyTrendChart({
    super.key,
    required this.points,
    required this.avgAccuracy,
    required this.highestAccuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
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
          // 1. Header (Icon + Title)
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                size: 20.sp,
                color: const Color(0xFF059669),
              ),
              SizedBox(width: 8.w),
              Text(
                "নির্ভুলতা ও পারফরম্যান্স ট্রেন্ড গ্রাফ",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),
          Text(
            "আপনার সর্বশেষ পরীক্ষাগুলোর নির্ভুলতার শতকরা হার (%)",
            style: TextStyle(
              fontSize: 11.5.sp,
              color: const Color(0xFF64748B),
            ),
          ),

          SizedBox(height: 12.h),

          // 2. Badges Row (গড় & সর্বোচ্চ)
          Row(
            children: [
              // গড় Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
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

              SizedBox(width: 8.w),

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

          // 3. Custom-Painted Interactive Chart
          SizedBox(
            height: 220.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Y-Axis Labels
                SizedBox(
                  width: 38.w,
                  height: 165.h,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      _AxisLabel(text: "100%"),
                      _AxisLabel(text: "75%"),
                      _AxisLabel(text: "50%"),
                      _AxisLabel(text: "25%"),
                      _AxisLabel(text: "0%"),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                // Scrollable Plot Area
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: points.length * 48.w > 280.w ? points.length * 48.w : 280.w,
                      child: CustomPaint(
                        painter: _TrendChartPainter(points: points),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  final String text;
  const _AxisLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF64748B),
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<AccuracyTrendPointModel> points;

  _TrendChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double plotHeight = 165.h;
    final double stepX = size.width / (points.length > 1 ? (points.length - 1) : 1);

    // 1. Draw dashed grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 4; i++) {
      final double y = (plotHeight / 4) * i;
      _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Compute point coordinates
    final List<Offset> coords = [];
    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      // 0% at y = plotHeight, 100% at y = 0
      final double pct = points[i].percentage.clamp(0, 100);
      final y = plotHeight - (pct / 100.0) * plotHeight;
      coords.add(Offset(x, y));
    }

    // 3. Draw gradient fill under curve
    final fillPath = Path();
    fillPath.moveTo(coords.first.dx, plotHeight);
    fillPath.lineTo(coords.first.dx, coords.first.dy);

    for (int i = 0; i < coords.length - 1; i++) {
      final p0 = coords[i];
      final p1 = coords[i + 1];
      final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY1 = p0.dy;
      final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY2 = p1.dy;
      fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
    }

    fillPath.lineTo(coords.last.dx, plotHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF059669).withValues(alpha: 0.25),
          const Color(0xFF059669).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, plotHeight));

    canvas.drawPath(fillPath, fillPaint);

    // 4. Draw smooth bezier curve line
    final linePath = Path();
    linePath.moveTo(coords.first.dx, coords.first.dy);

    for (int i = 0; i < coords.length - 1; i++) {
      final p0 = coords[i];
      final p1 = coords[i + 1];
      final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY1 = p0.dy;
      final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY2 = p1.dy;
      linePath.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
    }

    final linePaint = Paint()
      ..color = const Color(0xFF059669)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // 5. Draw point dots and badges
    final dotBgPaint = Paint()..color = Colors.white;
    final dotBorderPaint = Paint()
      ..color = const Color(0xFF059669)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < coords.length; i++) {
      final pt = coords[i];
      final val = points[i].percentage;

      // Circle dot
      canvas.drawCircle(pt, 4.5, dotBgPaint);
      canvas.drawCircle(pt, 4.5, dotBorderPaint);

      // Value Chip Pill Badge
      _drawValueBadge(canvas, pt, "${val.toInt()}%");

      // X-Axis Date label rotated
      _drawRotatedDateText(canvas, Offset(pt.dx, plotHeight + 14.h), points[i].date);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 4.0;
    const double dashSpace = 4.0;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(
        Offset(startX, p1.dy),
        Offset((startX + dashWidth).clamp(p1.dx, p2.dx), p1.dy),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  void _drawValueBadge(Canvas canvas, Offset point, String text) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: 9.sp,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeWidth = textPainter.width + 8.w;
    final badgeHeight = textPainter.height + 4.h;
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(point.dx, point.dy - 12.h),
        width: badgeWidth,
        height: badgeHeight,
      ),
      Radius.circular(6.r),
    );

    final badgePaint = Paint()..color = const Color(0xFF065F46);
    canvas.drawRRect(badgeRect, badgePaint);

    textPainter.paint(
      canvas,
      Offset(
        point.dx - (textPainter.width / 2),
        point.dy - 12.h - (textPainter.height / 2),
      ),
    );
  }

  void _drawRotatedDateText(Canvas canvas, Offset center, String date) {
    final textSpan = TextSpan(
      text: date,
      style: TextStyle(
        fontSize: 9.5.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF475569),
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.785); // -45 degrees
    textPainter.paint(canvas, Offset(-textPainter.width, -textPainter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
