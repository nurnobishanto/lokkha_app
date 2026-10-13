import 'package:flutter/material.dart';

class OnboardingCurvedHeader extends StatelessWidget {
  final int pageIndex;
  final double height;
  final Color color;

  const OnboardingCurvedHeader({
    super.key,
    required this.pageIndex,
    this.height = 290,
    this.color = const Color(0xFF288E70),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(MediaQuery.of(context).size.width, height),
          painter: _OnboardingCurvedPainter(
            pageIndex: pageIndex,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _OnboardingCurvedPainter extends CustomPainter {
  final int pageIndex;
  final Color color;

  const _OnboardingCurvedPainter({
    required this.pageIndex,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();

    if (pageIndex == 0) {
      // Slide 1: Deep organic curve sweeping down from top-left to right
      path.lineTo(0, size.height * 0.75);
      path.cubicTo(
        size.width * 0.28,
        size.height * 0.86,
        size.width * 0.68,
        size.height * 0.48,
        size.width,
        size.height * 0.38,
      );
      path.lineTo(size.width, 0);
    } else if (pageIndex == 1) {
      // Slide 2: Inverted arch framing the top
      path.lineTo(0, size.height * 0.35);
      path.cubicTo(
        size.width * 0.20,
        size.height * 0.08,
        size.width * 0.80,
        size.height * 0.08,
        size.width,
        size.height * 0.35,
      );
      path.lineTo(size.width, 0);
    } else {
      // Slide 3: Smooth organic slope sweeping gracefully without pinch or notch glitch
      path.lineTo(0, size.height * 0.45);
      path.quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.82,
        size.width,
        size.height * 0.92,
      );
      path.lineTo(size.width, 0);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OnboardingCurvedPainter oldDelegate) {
    return oldDelegate.pageIndex != pageIndex || oldDelegate.color != color;
  }
}
