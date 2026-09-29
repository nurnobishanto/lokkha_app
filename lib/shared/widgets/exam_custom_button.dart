import 'package:flutter/material.dart';
import 'package:lokkha/core/core.dart';

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
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: btnBackgroundColor,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
            color: borderColor!,
            width: 0, // Border width
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
