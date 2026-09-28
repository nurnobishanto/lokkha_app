import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/modules/auth_views/auth_gateway/views/auth_gateway_view.dart';
import 'package:lokkha/config/theme/light_theme_colors.dart';
import '../../../helper/global.dart';
import '../../../models/course.dart';
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
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(color: LightThemeColors.primaryColor),
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
                        "৳$price",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "৳$regularPrice",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          decoration: TextDecoration.lineThrough,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
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
                // TODO: Add enroll logic
                if (isLoggedIn.value) {
                  Get.to(CourseCheckoutView(course: courseModel));
                } else {
                  Get.to(const AuthGatewayView());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: LightThemeColors.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                "Enroll Now",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
