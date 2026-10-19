import 'package:flutter/material.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/shared/widgets/app_button.dart';

class CustomActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? btnBackgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? height;
  final bool isLoading;

  const CustomActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.btnBackgroundColor = LightThemeColors.primaryColor,
    this.borderColor = LightThemeColors.primaryColor,
    this.height = 40.0,
    this.isLoading = false,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: btnBackgroundColor,
      textColor: textColor,
      borderColor: borderColor != LightThemeColors.primaryColor ? borderColor : null,
      height: height,
      isLoading: isLoading,
      isFullWidth: true,
      borderRadius: 7.0,
      textStyle: TextStyle(
        fontSize: 13.0,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}

