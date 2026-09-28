import 'package:flutter/material.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import 'package:lokkha/styles/text_style.dart';
import 'package:lokkha/core/theme/light_theme_colors.dart';

class DecisionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget? leadingWidget; // Accepts Icon, Image, or any Widget
  final Color? borderColor;
  final double? height;

  const DecisionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leadingWidget, // Optional widget (icon/image/custom widget)
    this.borderColor,
    this.height = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: borderColor ?? LightThemeColors.primaryColor,
            width: 2, // Border width
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingWidget != null) ...[
              leadingWidget!,
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: AppTextStyles.body1.copyWith(color: context.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
