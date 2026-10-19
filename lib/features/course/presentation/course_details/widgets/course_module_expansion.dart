import 'package:flutter/material.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/models/course_item.dart';
import 'package:lokkha/app/router/router.dart';

class CourseModuleExpansion extends StatelessWidget {
  final int? courseId;
  final String title;
  final List<CourseItem> items;
  final bool initiallyExpanded;
  final bool isEnrolled;

  const CourseModuleExpansion({
    super.key,
    this.courseId,
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
            if (item.examId != null || item.hasExam == true || item.type?.contains(Type.EXAM) == true) {
              icon = const Icon(Icons.assignment_outlined, color: Color(0xFF006A4E));
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
              icon = const Icon(Icons.check_circle_outline, color: Color(0xFF006A4E));
              label = 'আইটেম';
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
                      ?.copyWith(fontSize: 14, color: context.textPrimary),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 12, color: context.textSecondary),
                    ),
                    if (isFree) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006A4E).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ফ্রি',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF006A4E),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: isAccessible
                    ? const Icon(Icons.arrow_forward_ios_rounded,
                        color: Color(0xFF006A4E), size: 14)
                    : const Text('🔒', style: TextStyle(fontSize: 15)),
                onTap: () async {
                  if (isAccessible) {
                    final targetCourseId = item.courseId ?? courseId;
                    final itemId = item.id;
                    context.pushNamed(
                      Routes.courseLearn,
                      extra: {'id': targetCourseId, 'item_id': itemId},
                    );
                  } else {
                    CustomSnackBar.showCustomToast(
                      message: 'কোর্সটিতে এনরোল করে পরীক্ষাটি শুরু করুন',
                    );
                  }
                });
          }).toList(),
        ),
      ),
    );
  }
}
