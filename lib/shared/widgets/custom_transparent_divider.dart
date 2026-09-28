import 'package:flutter/material.dart';
import 'package:lokkha/config/extensions/common_extension.dart';
import 'package:lokkha/config/theme/light_theme_colors.dart';

class SectionTitleWithDivider extends StatelessWidget {
  final String title;
  final Color? color;
  final double fontSize;
  final double dividerHeight;
  final EdgeInsetsGeometry padding;

  const SectionTitleWithDivider({
    super.key,
    required this.title,
    this.color,
    this.fontSize = 18,
    this.dividerHeight = 1.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.primaryColor;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: transparentDivider(
              beginTransparent: true,
              height: dividerHeight,
              baseColor: effectiveColor,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Text(
              title,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: effectiveColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: transparentDivider(
              beginTransparent: false,
              height: dividerHeight,
              baseColor: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

Widget transparentDivider(
    {required bool beginTransparent, double height = 1.5, Color? baseColor}) {
  final primary = baseColor ?? LightThemeColors.primaryColor;
  final colors = beginTransparent
      ? [
          Colors.transparent,
          primary.withValues(alpha: 0.3),
          primary.withValues(alpha: 0.6),
        ]
      : [
          primary.withValues(alpha: 0.6),
          primary.withValues(alpha: 0.3),
          Colors.transparent,
        ];

  return Container(
    height: height,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors),
    ),
  );
}
