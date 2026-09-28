import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import '../../../models/course_item.dart';
import '../../../routes/app_pages.dart';

class CourseModuleExpansion extends StatelessWidget {
  final String title;
  final List<CourseItem> items;
  final bool initiallyExpanded;
  final bool isEnrolled;

  const CourseModuleExpansion({
    super.key,
    required this.title,
    required this.items,
    this.initiallyExpanded = false,
    this.isEnrolled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();
    final theme = Theme.of(context);
    final borderColor = context.borderColor;
    final bgColor = context.cardColor;
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
              color: context.textPrimary,
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 10),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 6),
          initiallyExpanded: initiallyExpanded,
          children: items.map((item) {
            final isFree = item.isFree == true;
            final isAccessible = isFree || isEnrolled;

            // Determine icon and label
            Icon icon;
            String label;
            if (item.examId != null) {
              icon = const Icon(Icons.description, color: Colors.blueGrey);
              label = 'পরীক্ষা';
            } else if (item.youtubeVideo != null &&
                item.youtubeVideo!.isNotEmpty) {
              icon = const Icon(Icons.ondemand_video, color: Colors.red);
              label = 'ভিডিও';
            } else if (item.video != null && item.video!.isNotEmpty) {
              icon = const Icon(Icons.play_circle_outline,
                  color: Colors.deepPurple);
              label = 'ভিডিও';
            } else if (item.pdf != null && item.pdf!.isNotEmpty) {
              icon = const Icon(Icons.picture_as_pdf, color: Colors.red);
              label = 'পিডিএফ';
            } else if (item.image != null && item.image!.isNotEmpty) {
              icon = const Icon(Icons.image, color: Colors.purple);
              label = 'ইমেজ';
            } else if (item.file != null && item.file!.isNotEmpty) {
              icon = const Icon(Icons.insert_drive_file, color: Colors.grey);
              label = 'ফাইল';
            } else if (item.url != null && item.url!.isNotEmpty) {
              icon = const Icon(Icons.link, color: Colors.blue);
              label = 'লিংক';
            } else if (item.details != null && item.details!.isNotEmpty) {
              icon = const Icon(Icons.description, color: Colors.blueGrey);
              label = 'বিস্তারিত';
            } else {
              // No supported content
              return const SizedBox.shrink();
            }

            return ListTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -4),
                contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                leading: icon,
                title: Text(
                  item.title ?? 'No title',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontSize: 15, color: context.textPrimary),
                ),
                subtitle: Text(
                  label,
                  style: TextStyle(fontSize: 12, color: context.textSecondary),
                ),
                trailing: isAccessible
                    ? const Icon(Icons.remove_red_eye,
                        color: Colors.green, size: 18)
                    : const Text('🔒', style: TextStyle(fontSize: 16)),
                onTap: () async {
                  if (isAccessible) {
                    final courseId = item.courseId;
                    final itemId = item.id;
                    debugPrint("Course id:$courseId $itemId ");
                    //
                    Get.toNamed(Routes.COURSE_LEARN,
                        arguments: {'id': courseId, 'item_id': itemId});
                  }
                });
          }).toList(),
        ),
      ),
    );
  }
}
