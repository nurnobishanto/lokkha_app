import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/shared/models/course_item.dart';
import '../controllers/course_learn_controller.dart';

class CourseModuleLearnExpansion extends StatelessWidget {
  final String title;
  final List<CourseItem> items;
  final bool initiallyExpanded;
  final bool isEnrolled;

  const CourseModuleLearnExpansion({
    super.key,
    required this.title,
    required this.items,
    this.initiallyExpanded = false,
    this.isEnrolled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final borderColor = Colors.grey.shade300;
    final bgColor = Colors.grey.shade100;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 10),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 6),
          initiallyExpanded: initiallyExpanded,
          children: items.map((item) {
            final isFree = item.isFree == true;
            final isAccessible = isFree || isEnrolled;

            // Determine content type
            Icon leadingIcon;
            if (item.youtubeVideo != null) {
              leadingIcon =
                  const Icon(Icons.ondemand_video, color: Colors.blue);
            } else if (item.video != null) {
              leadingIcon = const Icon(Icons.play_circle_outline,
                  color: Colors.deepPurple);
            } else if (item.pdf != null) {
              leadingIcon = const Icon(Icons.picture_as_pdf, color: Colors.red);
            } else if (item.image != null) {
              leadingIcon =
                  const Icon(Icons.image_outlined, color: Colors.purple);
            } else if (item.file != null) {
              leadingIcon =
                  const Icon(Icons.insert_drive_file, color: Colors.grey);
            } else if (item.url != null && item.url!.isNotEmpty) {
              leadingIcon = const Icon(Icons.link, color: Colors.blue);
            } else if (item.details != null && item.details!.isNotEmpty) {
              leadingIcon =
                  const Icon(Icons.description, color: Colors.blueGrey);
            } else {
              // Skip unknown/empty types
              return const SizedBox.shrink();
            }

            return ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -4),
              contentPadding: const EdgeInsets.symmetric(horizontal: 6),
              leading: leadingIcon,
              title: Text(
                item.title ?? 'No title',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
              ),
              trailing: isAccessible
                  ? const Icon(Icons.remove_red_eye,
                      color: Colors.green, size: 18)
                  : const Text('🔒', style: TextStyle(fontSize: 16)),
              onTap: isAccessible
                  ? () {
                      Navigator.of(context).pop();
                      final courseId = item.courseId;
                      final itemId = item.id;
                      Get.find<CourseLearnController>()
                          .fetchCourseItem(courseId!, itemID: itemId);
                    }
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }
}
