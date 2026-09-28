import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lokkha/config/theme/light_theme_colors.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import 'package:lokkha/styles/text_style.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.onTap,
    this.validator,
    this.readOnly = false,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      onTap: onTap,
      validator: validator,
      readOnly: readOnly,
      cursorColor: LightThemeColors.primaryColor,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(color: context.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10.0),
        isDense: true,
        hintText: hintText,
        hintStyle: AppTextStyles.body1.copyWith(color: context.textMuted),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: context.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: context.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: context.primaryColor, width: 1.5),
        ),
      ),
    );
  }
}
