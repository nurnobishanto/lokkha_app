import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/features/study_material/study_material.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/models/category.dart';

class VocabularyView extends StatelessWidget {
  const VocabularyView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VocabularyController());
    return Scaffold(
      appBar: const CustomAppBar(title: 'Vocabulary'),
      body: Obx(() {
        final vocabList = controller.filteredVocab;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              // controller: scrollController,
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        // Search bar
                        CustomSearchBar(
                          controller: controller.searchTextController.value,
                          onChanged: (value) {
                            controller.search.value = value;
                          },
                          hintText: 'Search Vocabulary...',
                        ),
                        10.0.height,
                        FilterRow(vocabularyController: controller),
                        10.0.height,
                        // Alphabets
                        Center(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            alignment: WrapAlignment.center,
                            children: controller.model.value.alphabets
                                    ?.map((char) {
                                  return InkWell(
                                    onTap: () {
                                      controller.selectedAlphabet.value =
                                          char.toString();
                                      controller.currentPage.value = 1;
                                      controller.fetchVocabulary();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4.0.r, horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: char ==
                                                controller
                                                    .selectedAlphabet.value
                                            ? context.primaryColor
                                            : context.cardColor,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: char ==
                                                  controller
                                                      .selectedAlphabet.value
                                              ? context.primaryColor
                                              : context.borderColor,
                                        ),
                                      ),
                                      child: Text(
                                        char,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: char ==
                                                    controller
                                                        .selectedAlphabet.value
                                                ? Colors.white
                                                : context.textPrimary),
                                      ),
                                    ),
                                  );
                                }).toList() ??
                                [],
                          ),
                        ),
                        5.h.height,
                        const Divider(),
                        5.h.height,
                        if (vocabList.isEmpty)
                          const Center(child: Text('Data not found')),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: vocabList.length,
                          itemBuilder: (_, index) {
                            final vocab = vocabList[index];
                            return GestureDetector(
                              onTap: () {
                                if (havePackage.value) {
                                  showDialog(
                                    context: Get.context!,
                                    builder: (_) => AlertDialog(
                                      title: Text(vocab.word ?? 'No Word'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            if (vocab.details != null &&
                                                vocab.details!.isNotEmpty)
                                              Text("Details: ${vocab.details}"),
                                            const SizedBox(height: 10),
                                            if (vocab.synonym != null &&
                                                vocab.synonym!.isNotEmpty)
                                              popupList("Synonyms", vocab.synonym,
                                                  LightThemeColors.primaryColor)
                                            else
                                              const Text("No synonyms found"),
                                            if (vocab.antonym != null &&
                                                vocab.antonym!.isNotEmpty)
                                              popupList("Antonyms", vocab.antonym,
                                                  LightThemeColors.primaryColor)
                                            else
                                              const Text("No antonyms found"),
                                            if (vocab.wrongSynonym != null &&
                                                vocab.wrongSynonym!.isNotEmpty)
                                              popupList("Wrong Synonyms",
                                                  vocab.wrongSynonym, Colors.red)
                                            else
                                              const Text(
                                                  "No wrong synonyms found"),
                                            if (vocab.wrongAntonym != null &&
                                                vocab.wrongAntonym!.isNotEmpty)
                                              popupList("Wrong Antonyms",
                                                  vocab.wrongAntonym, Colors.red)
                                            else
                                              const Text(
                                                  "No wrong antonyms found"),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          child: const Text("Close"),
                                        )
                                      ],
                                    ),
                                  );
                                } else {
                                  Get.dialog(PackageRequiredPopup());
                                }
                              },




                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: context.cardColor,
                                  border:
                                      Border.all(color: context.borderColor),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  vocab.word ?? '',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: context.textPrimary,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            );
                          },
                        ),
                        10.0.height,
                        const Divider(),
                        10.0.height,
                      ],
                    ),
            ),
          ),
        );
      }),

      bottomNavigationBar: Obx(() {
        if (controller.totalPages.value <= 1) return const SizedBox.shrink();

        return SafeArea(
          child: Container(
            color: context.cardColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 25),
                child: Row(
                  children: [
                    // First Page
                    IconButton(
                      icon: Icon(Icons.first_page, color: context.textPrimary),
                      onPressed: controller.currentPage.value > 1
                          ? controller.firstPage
                          : null,
                    ),

                    // Previous
                    IconButton(
                      icon: Icon(Icons.navigate_before, color: context.textPrimary),
                      onPressed: controller.currentPage.value > 1
                          ? controller.previousPage
                          : null,
                    ),

                    // Page Numbers
                    ...List.generate(
                            controller.totalPages.value, (index) => index + 1)
                        .where((page) {
                      int current = controller.currentPage.value;
                      return (page >= current - 2 && page <= current + 2) ||
                          page == 1 ||
                          page == controller.totalPages.value;
                    }).map((page) {
                      bool isActive = page == controller.currentPage.value;
                      return InkWell(
                        onTap: () => controller.goToPage(page),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding:
                              const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          decoration: BoxDecoration(
                            color: isActive
                                ? LightThemeColors.primaryColor
                                : (context.isDark ? context.surfaceColor : Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: isActive ? LightThemeColors.primaryColor : context.borderColor),
                          ),
                          child: Text(
                            page.toString(),
                            style: TextStyle(
                              color: isActive ? Colors.white : context.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }),

                    // Next
                    IconButton(
                      icon: Icon(Icons.navigate_next, color: context.textPrimary),
                      onPressed: controller.currentPage.value <
                              controller.totalPages.value
                          ? controller.nextPage
                          : null,
                    ),

                    // Last
                    IconButton(
                      icon: Icon(Icons.last_page, color: context.textPrimary),
                      onPressed: controller.currentPage.value <
                              controller.totalPages.value
                          ? controller.lastPage
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class FilterRow extends StatelessWidget {
  final VocabularyController vocabularyController;
  const FilterRow({super.key, required this.vocabularyController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // prevent overflow
      child: Row(
        children: [
          Obx(() {
            final types = vocabularyController.model.value.types ?? [];
            final selectedType = vocabularyController.selectedType.value;
            final safeType = types.contains(selectedType) ? selectedType : null;

            return SizedBox(
              height: 35.0.h,
              width: Get.width * 0.45,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  border: Border.all(color: context.borderColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButton<Category>(
                  isExpanded: true,
                  value: safeType,
                  dropdownColor: context.cardColor,
                  hint: Text('Select Type',
                      style: TextStyle(color: context.textMuted)),
                  underline: const SizedBox(),
                  icon: Icon(Icons.arrow_drop_down,
                      color: context.textSecondary),
                  items: types.map((type) {
                    return DropdownMenuItem<Category>(
                      value: type,
                      child: Text(type.name ?? '',
                          style: TextStyle(color: context.textPrimary)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      vocabularyController.currentPage.value = 1;
                      vocabularyController.setType(value);
                      vocabularyController.selectedAlphabet.value = '';
                      vocabularyController.fetchVocabulary();
                    }
                  },
                ),
              ),
            );
          }),
          const SizedBox(width: 10),
          Obx(() {
            final categories =
                vocabularyController.model.value.categories ?? [];
            final selectedCategory =
                vocabularyController.selectedCategory.value;
            final safeCategory =
                categories.contains(selectedCategory) ? selectedCategory : null;

            return SizedBox(
              height: 35.0.h,
              width: Get.width * 0.45,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  border: Border.all(color: context.borderColor),
                  borderRadius: BorderRadius.circular(8.0.r),
                ),
                child: DropdownButton<Category>(
                  isExpanded: true,
                  value: safeCategory,
                  dropdownColor: context.cardColor,
                  hint: Text('Select Category',
                      style: TextStyle(color: context.textMuted)),
                  underline: const SizedBox(),
                  icon: Icon(Icons.arrow_drop_down,
                      color: context.textSecondary),
                  items: categories.map((category) {
                    return DropdownMenuItem<Category>(
                      value: category,
                      child: Text(category.name ?? '',
                          style: TextStyle(color: context.textPrimary)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      vocabularyController.currentPage.value = 1;
                      vocabularyController.setCategory(value);
                      vocabularyController.selectedAlphabet.value = '';
                      vocabularyController.fetchVocabulary();
                    }
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

Widget popupList(String title, List<String?>? items, Color color) {
  // Filter out null and empty strings
  final filteredItems = (items ?? [])
      .where((e) => e != null && e.trim().isNotEmpty)
      .map((e) => e!)
      .toList();

  if (filteredItems.isEmpty) return const SizedBox();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "$title:",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Wrap(
        spacing: 6,
        runSpacing: 4,
        children: filteredItems.asMap().entries.map((entry) {
          int idx = entry.key;
          String e = entry.value;
          bool isLast = idx == filteredItems.length - 1;
          return Text(
            isLast ? e : "$e,",
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          );
        }).toList(),
      ),
      const SizedBox(height: 10),
    ],
  );
}
