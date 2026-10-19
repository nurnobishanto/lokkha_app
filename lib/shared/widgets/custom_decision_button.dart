import 'package:flutter/material.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/widgets/app_button.dart';

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
    return AppButton.outline(
      text: text,
      onPressed: onPressed,
      icon: leadingWidget,
      borderColor: borderColor ?? context.primaryColor,
      backgroundColor: context.cardColor,
      textColor: context.textPrimary,
      height: height,
      borderRadius: 20.0,
      isFullWidth: true,
      textStyle: AppTextStyles.body1.copyWith(color: context.textPrimary),
    );
  }
}

