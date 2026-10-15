import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/study_material/study_material.dart';
import 'package:lokkha/shared/shared.dart';

class VocabularyView extends ConsumerStatefulWidget {
  const VocabularyView({super.key});

  @override
  ConsumerState<VocabularyView> createState() => _VocabularyViewState();
}

class _VocabularyViewState extends ConsumerState<VocabularyView> {
  late final TextEditingController _searchTextController;

  @override
  void initState() {
    super.initState();
    _searchTextController = TextEditingController();
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vocabState = ref.watch(vocabularyNotifierProvider);
    final notifier = ref.read(vocabularyNotifierProvider.notifier);
    final vocabList = vocabState.filteredVocab;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Vocabulary'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: vocabState.isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    children: [
                      // Search bar
                      CustomSearchBar(
                        controller: _searchTextController,
                        onChanged: (value) {
                          notifier.setSearch(value);
                        },
                        hintText: 'Search Vocabulary...',
                      ),
                      10.0.height,
                      const FilterRow(),
                      10.0.height,
                      // Alphabets
                      Center(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          alignment: WrapAlignment.center,
                          children: (vocabState.alphabets.isNotEmpty
                                  ? vocabState.alphabets
                                  : (vocabState.model?.alphabets ?? []))
                              .map((char) {
                                final isSelected =
                                    char == vocabState.selectedAlphabet;
                                return InkWell(
                                  onTap: () {
                                    notifier.setAlphabet(char.toString());
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4.0.r, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? context.primaryColor
                                          : context.cardColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? context.primaryColor
                                            : context.borderColor,
                                      ),
                                    ),
                                    child: Text(
                                      char,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : context.textPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
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
                                  context: context,
                                  builder: (_) => VocabularyDetailDialog(
                                      vocabulary: vocab),
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      const PackageRequiredPopup(),
                                );
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
      ),
      bottomNavigationBar: vocabState.totalPages <= 1
          ? const SizedBox.shrink()
          : SafeArea(
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
                          icon: Icon(Icons.first_page,
                              color: context.textPrimary),
                          onPressed: vocabState.currentPage > 1
                              ? notifier.firstPage
                              : null,
                        ),

                        // Previous
                        IconButton(
                          icon: Icon(Icons.navigate_before,
                              color: context.textPrimary),
                          onPressed: vocabState.currentPage > 1
                              ? notifier.previousPage
                              : null,
                        ),

                        // Page Numbers
                        ...List.generate(vocabState.totalPages,
                                (index) => index + 1)
                            .where((page) {
                          int current = vocabState.currentPage;
                          return (page >= current - 2 && page <= current + 2) ||
                              page == 1 ||
                              page == vocabState.totalPages;
                        }).map((page) {
                          bool isActive = page == vocabState.currentPage;
                          return InkWell(
                            onTap: () => notifier.goToPage(page),
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 10),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? LightThemeColors.primaryColor
                                    : (context.isDark
                                        ? context.surfaceColor
                                        : Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: isActive
                                        ? LightThemeColors.primaryColor
                                        : context.borderColor),
                              ),
                              child: Text(
                                page.toString(),
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : context.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }),

                        // Next
                        IconButton(
                          icon: Icon(Icons.navigate_next,
                              color: context.textPrimary),
                          onPressed: vocabState.currentPage <
                                  vocabState.totalPages
                              ? notifier.nextPage
                              : null,
                        ),

                        // Last
                        IconButton(
                          icon: Icon(Icons.last_page,
                              color: context.textPrimary),
                          onPressed: vocabState.currentPage <
                                  vocabState.totalPages
                              ? notifier.lastPage
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class FilterRow extends ConsumerWidget {
  const FilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabState = ref.watch(vocabularyNotifierProvider);
    final notifier = ref.read(vocabularyNotifierProvider.notifier);

    final types = vocabState.types.isNotEmpty
        ? vocabState.types
        : (vocabState.model?.types ?? []);
    final selectedType = vocabState.selectedType;
    final safeType = types.any((t) =>
            (t.id != null && t.id == selectedType?.id) ||
            (t.name != null && t.name == selectedType?.name))
        ? types.firstWhere((t) =>
            (t.id != null && t.id == selectedType?.id) ||
            (t.name != null && t.name == selectedType?.name))
        : null;

    final categories = vocabState.categories.isNotEmpty
        ? vocabState.categories
        : (vocabState.model?.categories ?? []);
    final selectedCategory = vocabState.selectedCategory;
    final safeCategory = categories.any((c) =>
            (c.id != null && c.id == selectedCategory?.id) ||
            (c.name != null && c.name == selectedCategory?.name))
        ? categories.firstWhere((c) =>
            (c.id != null && c.id == selectedCategory?.id) ||
            (c.name != null && c.name == selectedCategory?.name))
        : null;

    final width = MediaQuery.of(context).size.width * 0.45;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            height: 35.0.h,
            width: width,
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
                    notifier.setType(value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 35.0.h,
            width: width,
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
                    notifier.setCategory(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VocabularyDetailDialog extends ConsumerStatefulWidget {
  final Vocabulary vocabulary;
  const VocabularyDetailDialog({super.key, required this.vocabulary});

  @override
  ConsumerState<VocabularyDetailDialog> createState() =>
      _VocabularyDetailDialogState();
}

class _VocabularyDetailDialogState
    extends ConsumerState<VocabularyDetailDialog> {
  late Vocabulary _detail;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _detail = widget.vocabulary;
    final hasExtendedDetails = (_detail.synonym != null &&
            _detail.synonym!.isNotEmpty) ||
        (_detail.antonym != null && _detail.antonym!.isNotEmpty) ||
        (_detail.sentenceExample != null &&
            _detail.sentenceExample!.isNotEmpty) ||
        (_detail.notes != null && _detail.notes!.isNotEmpty);

    if (!hasExtendedDetails && widget.vocabulary.id != null) {
      _fetchFullDetail();
    }
  }

  Future<void> _fetchFullDetail() async {
    setState(() => _isLoading = true);
    try {
      final detail = await ref
          .read(vocabularyRepositoryProvider)
          .getVocabularyDetail(widget.vocabulary.id!);
      if (mounted && detail != null) {
        setState(() {
          _detail = detail;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('[VocabularyDetailDialog] Error fetching detail: $e');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vocab = _detail;
    final meaningText = vocab.displayMeaning;

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(vocab.word ?? 'No Word',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          if (vocab.pronunciation != null &&
              vocab.pronunciation!.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              "/${vocab.pronunciation!.trim()}/",
              style: TextStyle(
                fontSize: 14,
                color: context.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 10),
            ],
            if (meaningText != null && meaningText.trim().isNotEmpty) ...[
              Text("Details: $meaningText"),
              const SizedBox(height: 6),
            ],
            if (vocab.meaning != null &&
                vocab.meaning!.trim().isNotEmpty &&
                vocab.banglaMeaning != null &&
                vocab.banglaMeaning!.trim().isNotEmpty &&
                vocab.meaning != vocab.banglaMeaning) ...[
              Text("Meaning: ${vocab.meaning}"),
              const SizedBox(height: 6),
            ],
            if (vocab.typeName != null && vocab.typeName!.isNotEmpty) ...[
              Text("Type: ${vocab.typeName}",
                  style: TextStyle(color: context.textMuted, fontSize: 13)),
              const SizedBox(height: 4),
            ],
            if (vocab.categoryName != null &&
                vocab.categoryName!.isNotEmpty) ...[
              Text("Category: ${vocab.categoryName}",
                  style: TextStyle(color: context.textMuted, fontSize: 13)),
              const SizedBox(height: 6),
            ],
            if (vocab.sentenceExample != null &&
                vocab.sentenceExample!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                "Example: ${vocab.sentenceExample}",
                style: TextStyle(
                  color: context.textPrimary,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
            ],
            if (vocab.notes != null && vocab.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                "Note: ${vocab.notes}",
                style: TextStyle(
                  color: context.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
            ],
            const SizedBox(height: 10),
            if (vocab.synonym != null && vocab.synonym!.isNotEmpty)
              popupList(
                  "Synonyms", vocab.synonym, LightThemeColors.primaryColor)
            else if (!_isLoading)
              const Text("No synonyms found"),
            if (vocab.antonym != null && vocab.antonym!.isNotEmpty)
              popupList(
                  "Antonyms", vocab.antonym, LightThemeColors.primaryColor)
            else if (!_isLoading)
              const Text("No antonyms found"),
            if (vocab.wrongSynonym != null &&
                vocab.wrongSynonym!.isNotEmpty)
              popupList("Wrong Synonyms", vocab.wrongSynonym, Colors.red)
            else if (!_isLoading &&
                (widget.vocabulary.wrongSynonym == null ||
                    widget.vocabulary.wrongSynonym!.isEmpty))
              const Text("No wrong synonyms found"),
            if (vocab.wrongAntonym != null &&
                vocab.wrongAntonym!.isNotEmpty)
              popupList("Wrong Antonyms", vocab.wrongAntonym, Colors.red)
            else if (!_isLoading &&
                (widget.vocabulary.wrongAntonym == null ||
                    widget.vocabulary.wrongAntonym!.isEmpty))
              const Text("No wrong antonyms found"),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        )
      ],
    );
  }
}

Widget popupList(String title, List<String?>? items, Color color) {
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
