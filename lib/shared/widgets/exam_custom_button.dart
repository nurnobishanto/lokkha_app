import 'package:flutter/material.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/widgets/app_button.dart';

class ExamCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? btnBackgroundColor;
  final Color? borderColor;
  final double? height;

  const ExamCustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.btnBackgroundColor = LightThemeColors.primaryColor,
    this.borderColor = LightThemeColors.primaryColor,
    this.height = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: btnBackgroundColor,
      borderColor: borderColor != LightThemeColors.primaryColor ? borderColor : null,
      height: height,
      borderRadius: 5.0,
      size: AppButtonSize.sm,
      isFullWidth: true,
      textStyle: const TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}

