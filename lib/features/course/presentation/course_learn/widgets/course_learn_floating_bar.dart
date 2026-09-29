import 'package:flutter/material.dart';

import 'package:lokkha/shared/models/course.dart';
import 'course_module_learn_expansion.dart';

class CourseLearnFloatingBar extends StatelessWidget {
  final BuildContext context;
  final Course course;

  const CourseLearnFloatingBar({
    super.key,
    required this.context,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              maxChildSize: 0.95,
              minChildSize: 0.4,
              builder: (context, scrollController) => SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Course Module",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...course.modules!
                        .where((module) => (module.items ?? []).any((item) =>
                            item.youtubeVideo != null ||
                            item.video != null ||
                            item.pdf != null ||
                            item.image != null ||
                            item.file != null ||
                            item.details != null ||
                            item.url != null))
                        .map((module) => CourseModuleLearnExpansion(
                              title: module.title ?? 'Untitled Module',
                              items: module.items ?? [],
                              isEnrolled: course.isEnrolled ?? false,
                            )),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          },
        );
      },
      icon: const Icon(Icons.menu_book, color: Colors.white),
      label: Text(
        "Module",
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
    );
  }
}
