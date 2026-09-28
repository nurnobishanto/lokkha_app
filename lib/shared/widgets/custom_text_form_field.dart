import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lokkha/config/extensions/common_extension.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextStyle? hintStyle;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool autoFocus;
  final Widget? prefixIcon;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.hintStyle,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.autoFocus = false,
    this.prefixIcon,
    this.onTap,
    this.validator,
    this.readOnly = false,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isObscured = ValueNotifier<bool>(obscureText);

    return ValueListenableBuilder<bool>(
      valueListenable: isObscured,
      builder: (context, value, child) {
        return TextFormField(
          autofocus: autoFocus,
          onChanged: onChanged,
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: value,
          onTap: onTap,
          validator: validator,
          readOnly: readOnly,
          cursorColor: context.primaryColor,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(color: context.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: context.cardColor,
            hintText: hintText,
            hintStyle: hintStyle ?? TextStyle(color: context.textMuted),
            prefixIcon: prefixIcon,
            suffixIcon: obscureText
                ? IconButton(
                    icon: Icon(
                      value ? Icons.visibility_off : Icons.visibility,
                      color: context.textMuted,
                    ),
                    onPressed: () {
                      isObscured.value = !isObscured.value;
                    },
                  )
                : null,
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
      },
    );
  }
}
