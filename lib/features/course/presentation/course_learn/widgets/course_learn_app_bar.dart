import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import '../controllers/course_learn_controller.dart';

class CourseLearnAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CourseLearnAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: GetBuilder<CourseLearnController>(
        builder: (controller) {
          return AppBar(
            backgroundColor: LightThemeColors.primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            title: Text(
              controller.model.value.data?.course?.title ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 15.5),
            ),
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
