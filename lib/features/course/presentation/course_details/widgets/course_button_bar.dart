import 'package:flutter/material.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/models/course.dart';
import '../../course_checkout/views/course_checkout_view.dart';

class CourseBottomBar extends StatelessWidget {
  final String? price;
  final String regularPrice;
  final Course courseModel;
  final String title;

  const CourseBottomBar({
    super.key,
    required this.title,
    required this.price,
    required this.regularPrice,
    required this.courseModel,
  });

  @override
  Widget build(BuildContext context) {
    final cleanPrice = _cleanPrice(price);
    final cleanRegPrice = _cleanPrice(regularPrice);
    final double? pVal = double.tryParse(cleanPrice);
    final double? regVal = double.tryParse(cleanRegPrice);
    final bool showDiscount = regVal != null && pVal != null && regVal > pVal && pVal > 0;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(color: Color(0xFF006A4E)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Price and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        "৳$cleanPrice",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (showDiscount) ...[
                        const SizedBox(width: 8),
                        Text(
                          "৳$cleanRegPrice",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            decoration: TextDecoration.lineThrough,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Spacer between text and button
            const SizedBox(width: 12),

            // Enroll Button
            ElevatedButton(
              onPressed: () {
                if (isLoggedIn.value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseCheckoutView(course: courseModel),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AuthGatewayView(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF006A4E),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                "এখনই ভর্তি হোন",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _cleanPrice(String? price) {
    if (price == null) return '0';
    var p = price.trim();
    if (p.contains('.')) {
      p = p.replaceAll(RegExp(r'\.0+$'), '');
    }
    return p.isEmpty ? '0' : p;
  }
}
