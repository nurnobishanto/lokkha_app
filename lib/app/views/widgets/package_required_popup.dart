import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';

import '../../components/custom_action_button.dart';
import '../../routes/app_pages.dart';

class PackageRequiredPopup extends StatelessWidget {
  const PackageRequiredPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: context.borderColor),
      ),
      backgroundColor: context.cardColor,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.isDark
                    ? const Color(0xFF6B21A8).withValues(alpha: 0.25)
                    : Colors.purple.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium,
                size: 50,
                color: context.isDark ? const Color(0xFFC084FC) : Colors.purple.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "প্রিমিয়াম মেম্বারশিপ প্রয়োজন",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.isDark ? const Color(0xFFE9D5FF) : Colors.purple.shade900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "অ্যাপের সকল ফিচার ব্যবহার করতে হলে আপনাকে আমাদের প্রিমিয়াম মেম্বার হতে হবে। আপনার জন্য যেকোনো একটি প্যাকেজ বেছে নিন।",
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomActionButton(
              text: "প্যাকেজ নিন",
              onPressed: () {
                Get.back();
                Get.toNamed(Routes.PREMIUM_PACKAGES);
              },
            ),
          ],
        ),
      ),
    );
  }
}
