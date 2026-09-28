import 'package:flutter/material.dart';
import '../../config/theme/light_theme_colors.dart';
import '../../styles/text_style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final double? fontSize;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor,
    this.fontSize,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ??
        Theme.of(context).appBarTheme.backgroundColor ??
        LightThemeColors.primaryColor;

    return AppBar(
      backgroundColor: effectiveBg,
      centerTitle: centerTitle,
      actions: actions,
      title: Text(
        title,
        style: AppTextStyles.heading4
            .copyWith(color: Colors.white, fontSize: fontSize),
      ),
    );
  }
}
