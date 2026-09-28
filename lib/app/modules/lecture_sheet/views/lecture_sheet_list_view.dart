import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lokkha/app/modules/lecture_sheet/views/lecture_sheet_list_details_view.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';

import '../../../models/category.dart';
import '../../../services/api_call_status.dart';
import '../controllers/lecture_sheet_list_controller.dart';

class LectureSheetListView extends GetView<LectureSheetListController> {
  const LectureSheetListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LectureSheetListController());
    final scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        controller
            .fetchSheetListCategories(); // Safe fetch handled in controller
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Lecture Sheets")),
      body: Obx(() {
        if (controller.apiCallStatus.value == ApiCallStatus.loading &&
            controller.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: controller.categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 5),
            itemBuilder: (context, index) {
              final item = controller.categories[index];
              return SimpleCategoryCard(
                item: item,
                onTap: () => Get.to(
                    () => LectureSheetListDetailsView(id: item.id!.toInt())),
              );
            },
          ),
        );
      }),
    );
  }
}

class SimpleCategoryCard extends StatelessWidget {
  final Category item;
  final VoidCallback onTap;

  const SimpleCategoryCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = item.description?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent, // Keep Material transparent to show border
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.folder_outlined,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        item.name ?? 'No Name',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),

                        // Description
                        Text(
                          description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: context.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
