import 'package:flutter/material.dart';
import 'package:lokkha/core/core.dart';

class CourseLearnAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CourseLearnAppBar({super.key, this.title = ''});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        backgroundColor: LightThemeColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 15.5),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
