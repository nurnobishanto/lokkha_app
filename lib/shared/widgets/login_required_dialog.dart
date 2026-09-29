import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';

import 'package:lokkha/core/theme/light_theme_colors.dart';
import 'package:lokkha/routes/routes.dart';

class LoginRequiredDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String signInText;

  const LoginRequiredDialog({
    super.key,
    required this.title,
    required this.message,
    required this.cancelText,
    required this.signInText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        children: [
          const Icon(Icons.lock_outline, color: Colors.redAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: context.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(fontSize: 16, color: context.textSecondary),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red[700],
          ),
          child: Text(
            cancelText,
            style: TextStyle(color: LightThemeColors.red),
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(
            Icons.login,
            size: 18,
            color: LightThemeColors.white,
          ),
          label: Text(
            signInText,
            style: const TextStyle(color: LightThemeColors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: LightThemeColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            Get.toNamed(Routes.AUTH_GATEWAY);
          },
        ),
      ],
    );
  }
}
