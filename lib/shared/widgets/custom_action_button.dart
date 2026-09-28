import 'package:flutter/material.dart';
import 'package:lokkha/core/theme/light_theme_colors.dart';

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
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: btnBackgroundColor,
          borderRadius: BorderRadius.circular(7.0),
          border: Border.all(
            color: borderColor!,
            width: 0,
          ),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : FittedBox(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
