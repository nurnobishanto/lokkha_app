import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/study_material/data/models/vocabulary_model.dart';
import 'package:lokkha/features/study_material/presentation/providers/study_material_notifier.dart';
import 'package:lokkha/features/study_material/presentation/vocabulary/views/vocabulary_view.dart';
import 'package:lokkha/features/study_material/study_material.dart';
import 'package:lokkha/shared/models/category.dart';
import 'package:lokkha/shared/models/vocabulary.dart';

const Map<String, dynamic> sampleV1VocabularyJson = {
  "success": true,
  "message": "Vocabulary data retrieved successfully.",
  "data": {
    "types": [
      {"id": 1, "name": "One word substitutions"},
      {"id": 2, "name": "Group Verb"},
      {"id": 3, "name": "Phrase and Idioms"},
      {"id": 10, "name": "General Word"}
    ],
    "categories": [
      {"id": 1, "name": "BCS"},
      {"id": 2, "name": "Bank"},
      {"id": 3, "name": "IELTS"},
      {"id": 4, "name": "Others"},
      {"id": 7, "name": "a"}
    ],
    "alphabets": [
      "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
      "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "Y", "Z"
    ],
    "items": [
      {
        "id": 2841,
        "word": "Favoritism",
        "details": "পক্ষপাতিত্ব",
        "synonyms": ["Bias", "Partiality", "Nepotism"],
        "antonyms": ["Fairness", "Impartiality", "Equality"],
        "type": "One word substitutions",
        "category": "BCS"
      },
      {
        "id": 2840,
        "word": "Retaliation",
        "details": "প্রতিশোধ; পাল্টা আঘাত",
        "synonyms": ["Revenge", "Reprisal", "Vengeance"],
        "antonyms": ["Forgiveness", "Mercy", "Pardon"],
        "type": "General Word",
        "category": "BCS"
      },
      {
        "id": 2839,
        "word": "Truce",
        "details": "যুদ্ধবিরতি; সাময়িক সন্ধি",
        "synonyms": ["Innocence", "Obedience", "Virtue"],
        "antonyms": ["War", "Conflict", "Hostility"],
        "type": "General Word",
        "category": "BCS"
      }
    ]
  }
};

class FakeVocabularyRepository implements VocabularyRepository {
  final VocabularyModel model;
  FakeVocabularyRepository(this.model);

  @override
  Future<VocabularyModel> getVocabularies({
    int page = 1,
    int perPage = 30,
    String? alphabet,
    int? typeId,
    int? categoryId,
    String? search,
  }) async =>
      model;

  @override
  Future<List<String>> getAlphabets() async => model.alphabets ?? [];

  @override
  Future<List<Category>> getCategories() async => model.categories ?? [];

  @override
  Future<List<Category>> getTypes() async => model.types ?? [];

  @override
  Future<Vocabulary?> getVocabularyDetail(int id) async {
    return model.vocabularies?.data?.firstWhere((v) => v.id == id);
  }
}

class FakeVocabularyNotifier extends VocabularyNotifier {
  final VocabularyState initialState;
  FakeVocabularyNotifier(this.initialState, {VocabularyRepository? repo})
      : super(repository: repo);

  @override
  VocabularyState build() {
    return initialState;
  }

  @override
  Future<void> fetchVocabulary({bool refresh = false}) async {
    state = state.copyWith(filteredVocab: applyFilters(state.rawVocab));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Vocabulary V1 Model Serialization Tests', () {
    test('Vocabulary parses v1 item with synonyms, antonyms, type and category cleanly', () {
      final rawItem = (sampleV1VocabularyJson['data'] as Map)['items'][0] as Map<String, dynamic>;
      final vocab = Vocabulary.fromJson(rawItem);

      expect(vocab.id, 2841);
      expect(vocab.word, 'Favoritism');
      expect(vocab.details, 'পক্ষপাতিত্ব');
      expect(vocab.synonyms, ['Bias', 'Partiality', 'Nepotism']);
      expect(vocab.synonym, ['Bias', 'Partiality', 'Nepotism']);
      expect(vocab.antonyms, ['Fairness', 'Impartiality', 'Equality']);
      expect(vocab.antonym, ['Fairness', 'Impartiality', 'Equality']);
      expect(vocab.typeName, 'One word substitutions');
      expect(vocab.type, 'One word substitutions');
      expect(vocab.categoryName, 'BCS');
      expect(vocab.category, 'BCS');
    });

    test('VocabularyModel parses v1 response envelope with types, categories, alphabets and items', () {
      final model = VocabularyModel.fromJson(sampleV1VocabularyJson);

      expect(model.success, true);
      expect(model.status, true);
      expect(model.message, 'Vocabulary data retrieved successfully.');
      expect(model.types?.length, 4);
      expect(model.types?.first.name, 'One word substitutions');
      expect(model.categories?.length, 5);
      expect(model.categories?.first.name, 'BCS');
      expect(model.alphabets?.length, 25);
      expect(model.alphabets?.first, 'A');

      expect(model.vocabularies?.data?.length, 3);
      expect(model.vocabularies?.data?.first.word, 'Favoritism');
      expect(model.vocabularies?.data?[1].word, 'Retaliation');
      expect(model.vocabularies?.data?[2].word, 'Truce');
    });

    test('VocabularyModel also maintains backward compatibility with legacy format', () {
      final legacyJson = {
        "status": true,
        "vocabularies": {
          "current_page": 1,
          "last_page": 95,
          "total": 2833,
          "data": [
            {
              "id": 100,
              "word": "LegacyWord",
              "details": "নমুনা শব্দ",
              "synonym": ["OldSyn"],
              "antonym": ["OldAnt"],
              "types": [{"id": 1, "name": "One word substitutions"}],
              "categories": [{"id": 1, "name": "BCS"}]
            }
          ]
        },
        "types": [{"id": 1, "name": "One word substitutions"}],
        "categories": [{"id": 1, "name": "BCS"}],
        "alphabets": ["A", "B", "C"]
      };

      final model = VocabularyModel.fromJson(legacyJson);
      expect(model.status, true);
      expect(model.vocabularies?.lastPage, 95);
      expect(model.vocabularies?.total, 2833);
      expect(model.vocabularies?.data?.first.word, 'LegacyWord');
      expect(model.vocabularies?.data?.first.synonyms, ['OldSyn']);
      expect(model.vocabularies?.data?.first.typeName, 'One word substitutions');
    });
  });

  group('VocabularyNotifier Filter Tests', () {
    test('Filtering by alphabet, type, category, and search works accurately', () {
      final model = VocabularyModel.fromJson(sampleV1VocabularyJson);
      final rawList = model.vocabularies?.data ?? [];
      final repo = FakeVocabularyRepository(model);
      final container = ProviderContainer(
        overrides: [
          vocabularyRepositoryProvider.overrideWithValue(repo),
          vocabularyNotifierProvider.overrideWith(
            () => FakeVocabularyNotifier(
              VocabularyState(
                isLoading: false,
                model: model,
                rawVocab: rawList,
                filteredVocab: rawList,
              ),
              repo: repo,
            ),
          ),
        ],
      );

      final notifier = container.read(vocabularyNotifierProvider.notifier);

      // 1. Filter by Alphabet 'F'
      notifier.setAlphabet('F');
      expect(container.read(vocabularyNotifierProvider).filteredVocab.length, 1);
      expect(container.read(vocabularyNotifierProvider).filteredVocab.first.word, 'Favoritism');

      // Toggling 'F' again clears alphabet filter
      notifier.setAlphabet('F');
      expect(container.read(vocabularyNotifierProvider).filteredVocab.length, 3);

      // 2. Filter by Type 'One word substitutions'
      notifier.setType(Category(id: 1, name: 'One word substitutions'));
      expect(container.read(vocabularyNotifierProvider).filteredVocab.length, 1);
      expect(container.read(vocabularyNotifierProvider).filteredVocab.first.word, 'Favoritism');

      // Reset type
      notifier.setType(null);
      expect(container.read(vocabularyNotifierProvider).filteredVocab.length, 3);

      // 3. Search query 'Retaliation'
      notifier.setSearch('retal');
      expect(container.read(vocabularyNotifierProvider).filteredVocab.length, 1);
      expect(container.read(vocabularyNotifierProvider).filteredVocab.first.word, 'Retaliation');

      // Clear search
      notifier.setSearch('');
      expect(container.read(vocabularyNotifierProvider).filteredVocab.length, 3);
    });
  });

  group('VocabularyView Widget Tests', () {
    testWidgets('VocabularyView renders search, dropdowns, alphabets and word cards', (tester) async {
      havePackage.value = true;
      final model = VocabularyModel.fromJson(sampleV1VocabularyJson);
      final repo = FakeVocabularyRepository(model);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => ProviderScope(
            overrides: [
              vocabularyRepositoryProvider.overrideWithValue(repo),
              vocabularyNotifierProvider.overrideWith(
                () => FakeVocabularyNotifier(
                  VocabularyState(
                    isLoading: false,
                    model: model,
                    rawVocab: model.vocabularies?.data ?? [],
                    filteredVocab: model.vocabularies?.data ?? [],
                    totalPages: 1,
                    currentPage: 1,
                  ),
                  repo: repo,
                ),
              ),
            ],
            child: const MaterialApp(
              home: VocabularyView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify AppBar
      expect(find.text('Vocabulary'), findsOneWidget);

      // Verify Search hint
      expect(find.text('Search Vocabulary...'), findsOneWidget);

      // Verify Type & Category dropdown hints
      expect(find.text('Select Type'), findsOneWidget);
      expect(find.text('Select Category'), findsOneWidget);

      // Verify Alphabet chips
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);

      // Verify Word cards
      expect(find.text('Favoritism'), findsOneWidget);
      expect(find.text('Retaliation'), findsOneWidget);
      expect(find.text('Truce'), findsOneWidget);

      // Tap on 'Favoritism' to open detail dialog
      await tester.tap(find.text('Favoritism'));
      await tester.pumpAndSettle();

      // Verify dialog contents
      expect(find.text('Details: পক্ষপাতিত্ব'), findsOneWidget);
      expect(find.text('Type: One word substitutions'), findsOneWidget);
      expect(find.text('Category: BCS'), findsOneWidget);
      expect(find.text('Synonyms:'), findsOneWidget);
      expect(find.text('Bias,'), findsOneWidget);
      expect(find.text('Partiality,'), findsOneWidget);
      expect(find.text('Nepotism'), findsOneWidget);
      expect(find.text('Antonyms:'), findsOneWidget);
      expect(find.text('Fairness,'), findsOneWidget);
      expect(find.text('Impartiality,'), findsOneWidget);
      expect(find.text('Equality'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Close'), findsNothing);
    });
  });
}
