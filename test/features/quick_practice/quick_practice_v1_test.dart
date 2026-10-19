import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/features/quick_practice/quick_practice.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleSubjectsJson = {
    "success": true,
    "message": "Top-level subjects retrieved successfully.",
    "data": [
      {
        "id": 17,
        "name": "৯ম-২০তম গ্রেড",
        "slug": "9m-20tm-gred",
        "parent_id": null,
        "status": true,
        "show_app": true,
        "questions_count": 114,
        "children_count": 2,
        "question_count": 114
      },
      {
        "id": 1263,
        "name": "Bank Analytical skill",
        "slug": "bank-analytical-skill",
        "status": true,
        "show_app": false,
        "questions_count": 0,
        "children_count": 0,
        "question_count": 0
      },
      {
        "id": 2,
        "name": "BCS Preli",
        "slug": "bcs-preli",
        "status": true,
        "show_app": true,
        "questions_count": 5575,
        "children_count": 44,
        "question_count": 5575
      },
      {
        "id": 1272,
        "name": "Group verb",
        "slug": "group-verb",
        "status": true,
        "show_app": true,
        "questions_count": 118,
        "children_count": 0,
        "question_count": 118
      }
    ]
  };

  const sampleChildrenJson = {
    "success": true,
    "message": "Subject children retrieved successfully.",
    "data": {
      "items": [
        {
          "id": 1190,
          "name": "বাংলাদেশ পরমাণু শক্তি কমিশন - জেনারেল অ্যাটেনডেন্ট(২৭-০৯-২০২৫)",
          "slug": "banglades-prmanu-skti-kmisn-jenarel-ozatendent27-09-2025",
          "questions_count": 39
        },
        {
          "id": 1178,
          "name": "বাংলাদেশ পরমাণু শক্তি কমিশন কম্পিউটার টাইপিস্ট (২৭-০৯-২৫)",
          "slug": "banglades-prmanu-skti-kmisn-kmpiutar-taipist-27-09-25",
          "questions_count": 76
        }
      ]
    },
    "meta": {
      "current_page": 1,
      "last_page": 1,
      "per_page": 24,
      "total": 2,
      "from": 1,
      "to": 2,
      "has_more": false
    }
  };

  const sampleQuestionsJson = {
    "success": true,
    "message": "Subject questions retrieved successfully.",
    "data": {
      "items": [
        {
          "id": 59422,
          "title": "<p>2πr<sup>2</sup> + 2πrh হলে ১/২ আবার √54564</p>",
          "description": "<p>গণিত সমাধান</p>",
          "question_image": null,
          "explanation_image": null,
          "explanation": "<p>এটি একটি পরিমিতির সূত্র।</p>",
          "options": [
            {
              "key": 0,
              "letter": "A",
              "value": "54654",
              "is_correct": false
            },
            {
              "key": 1,
              "letter": "B",
              "value": "ু33",
              "is_correct": true
            }
          ],
          "correct_letter": "B"
        },
        {
          "id": 53654,
          "title": "পদ্মা সেতু কোন দুটি জেলাকে সংযুক্ত করেছে?",
          "description": null,
          "question_image": null,
          "explanation_image": null,
          "explanation": null,
          "options": [
            {
              "key": 0,
              "letter": "A",
              "value": "মানিকগঞ্জ ও শরিয়তপুর",
              "is_correct": false
            },
            {
              "key": 1,
              "letter": "B",
              "value": "মুন্সিগঞ্জ ও ফরিদপুর",
              "is_correct": false
            },
            {
              "key": 2,
              "letter": "C",
              "value": "মুন্সিগঞ্জ ও শরিয়তপুর",
              "is_correct": true
            },
            {
              "key": 3,
              "letter": "D",
              "value": "মানিকগঞ্জ ও ফরিদপুর",
              "is_correct": false
            }
          ],
          "correct_letter": "C"
        }
      ]
    },
    "meta": {
      "current_page": 1,
      "last_page": 1,
      "per_page": 15,
      "total": 2,
      "from": 1,
      "to": 2,
      "has_more": false
    }
  };

  group('Quick Practice V1 Models Tests', () {
    test('QuickPracticeSubject parses top-level subject JSON correctly', () {
      final res = QuickPracticeSubjectsResponse.fromJson(sampleSubjectsJson);
      expect(res.success, true);
      expect(res.subjects.length, 4);

      final grade9 = res.subjects[0];
      expect(grade9.id, 17);
      expect(grade9.name, "৯ম-২০তম গ্রেড");
      expect(grade9.questionsCount, 114);
      expect(grade9.childrenCount, 2);
      expect(grade9.hasChildren, true);
      expect(grade9.showApp, true);

      final bankAnalytic = res.subjects[1];
      expect(bankAnalytic.showApp, false);

      final bcs = res.subjects[2];
      expect(bcs.id, 2);
      expect(bcs.formattedQuestionsCount, "5.6k");
      expect(bcs.childrenCount, 44);
    });

    test('SubjectChild and SubjectChildrenResponse parse children list correctly', () {
      final res = SubjectChildrenResponse.fromJson(sampleChildrenJson);
      expect(res.success, true);
      expect(res.items.length, 2);

      final child1 = res.items[0];
      expect(child1.id, 1190);
      expect(child1.name.contains("বাংলাদেশ পরমাণু শক্তি কমিশন"), true);
      expect(child1.questionsCount, 39);
      expect(child1.formattedQuestionsCount, "39");

      expect(res.meta.total, 2);
      expect(res.meta.hasMore, false);
    });

    test('PracticeQuestion and SubjectQuestionsResponse parse question options and letters', () {
      final res = SubjectQuestionsResponse.fromJson(sampleQuestionsJson);
      expect(res.success, true);
      expect(res.items.length, 2);

      final q1 = res.items[0];
      expect(q1.id, 59422);
      expect(q1.options.length, 2);
      expect(q1.options[0].letter, "A");
      expect(q1.options[0].bengaliLetter, "ক");
      expect(q1.options[1].letter, "B");
      expect(q1.options[1].bengaliLetter, "খ");
      expect(q1.options[1].isCorrect, true);
      expect(q1.correctLetter, "B");
      expect(q1.bengaliCorrectLetter, "খ");

      final q2 = res.items[1];
      expect(q2.id, 53654);
      expect(q2.options.length, 4);
      expect(q2.options[2].bengaliLetter, "গ");
      expect(q2.options[2].isCorrect, true);
      expect(q2.bengaliCorrectLetter, "গ");
    });

    test('PracticeQuestionOption handles String keys gracefully like in Medical part API', () {
      final json = {
        "key": "A",
        "letter": "A",
        "value": "Filariasis",
        "is_correct": true
      };
      final option = PracticeQuestionOption.fromJson(json);
      expect(option.key, "A");
      expect(option.letter, "A");
      expect(option.value, "Filariasis");
      expect(option.isCorrect, true);
    });
  });

  group('Quick Practice Repository & Notifier Tests', () {
    test('QuickPracticeSubjectsNotifier loads subjects and filters show_app: false', () async {
      final mockRepo = _MockQuickPracticeRepo();
      final container = ProviderContainer(
        overrides: [
          quickPracticeRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      final notifier = container.read(quickPracticeSubjectsNotifierProvider.notifier);
      await notifier.fetchSubjects();

      final state = container.read(quickPracticeSubjectsNotifierProvider);
      expect(state.isLoading, false);
      expect(state.subjects.length, 4);
      // filteredSubjects removes showApp: false
      expect(state.filteredSubjects.length, 3);
      expect(state.filteredSubjects.any((s) => s.name == "Bank Analytical skill"), false);
      expect(state.filteredSubjects.any((s) => s.name == "৯ম-২০তম গ্রেড"), true);

      // Search query filtering
      notifier.setSearchQuery("bcs");
      final searched = container.read(quickPracticeSubjectsNotifierProvider).filteredSubjects;
      expect(searched.length, 1);
      expect(searched.first.name, "BCS Preli");
    });
  });

  group('Quick Practice Widgets Tests', () {
    testWidgets('QuickPracticeSubjectsView renders clean cards with badges', (tester) async {
      final mockRepo = _MockQuickPracticeRepo();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quickPracticeRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => const MaterialApp(
              home: Scaffold(
                body: QuickPracticeSubjectsView(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('সকল বিষয় ও সেকশন'), findsOneWidget);
      expect(find.text('৯ম-২০তম গ্রেড'), findsOneWidget);
      expect(find.text('BCS Preli'), findsOneWidget);
      expect(find.text('Group verb'), findsOneWidget);
      expect(find.text('২টি টপিক'), findsOneWidget);
      expect(find.text('৪৪টি টপিক'), findsOneWidget);
    });

    testWidgets('PracticeQuestionCard reveals correct and wrong answer on tap', (tester) async {
      final dataMap = sampleQuestionsJson['data'] as Map<String, dynamic>;
      final question = PracticeQuestion.fromJson(
        (dataMap['items'] as List)[1] as Map<String, dynamic>,
      );

      int? selectedKey;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return ScreenUtilInit(
              designSize: const Size(375, 812),
              builder: (context, child) => MaterialApp(
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: PracticeQuestionCard(
                      question: question,
                      index: 0,
                      selectedOptionKey: selectedKey,
                      isExplanationExpanded: false,
                      isBookmarked: false,
                      onSelectOption: (key) {
                        setState(() {
                          selectedKey = key;
                        });
                      },
                      onToggleExplanation: () {},
                      onToggleBookmark: () {},
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      // Check question title via HtmlWidget RichText finder
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('পদ্মা সেতু'),
        ),
        findsOneWidget,
      );
      expect(find.text('প্রশ্ন ১'), findsOneWidget);

      final optionFinder = find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('মুন্সিগঞ্জ ও শরিয়তপুর'),
      );
      expect(optionFinder, findsOneWidget);

      // Tap on correct option (C: key 2)
      await tester.tap(optionFinder);
      await tester.pumpAndSettle();

      expect(find.text('সঠিক উত্তর: গ'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });
}

class _MockQuickPracticeRepo implements QuickPracticeRepository {
  @override
  Future<List<QuickPracticeSubject>> getTopLevelSubjects({String? search}) async {
    return [
      const QuickPracticeSubject(
        id: 17,
        name: "৯ম-২০তম গ্রেড",
        slug: "9m-20tm-gred",
        questionsCount: 114,
        childrenCount: 2,
        showApp: true,
      ),
      const QuickPracticeSubject(
        id: 1263,
        name: "Bank Analytical skill",
        slug: "bank-analytical-skill",
        questionsCount: 0,
        childrenCount: 0,
        showApp: false,
      ),
      const QuickPracticeSubject(
        id: 2,
        name: "BCS Preli",
        slug: "bcs-preli",
        questionsCount: 5575,
        childrenCount: 44,
        showApp: true,
      ),
      const QuickPracticeSubject(
        id: 1272,
        name: "Group verb",
        slug: "group-verb",
        questionsCount: 118,
        childrenCount: 0,
        showApp: true,
      ),
    ];
  }

  @override
  Future<SubjectChildrenResponse> getSubjectChildren(
    int subjectId, {
    int page = 1,
    int perPage = 24,
    String? search,
  }) async {
    return const SubjectChildrenResponse(
      success: true,
      items: [
        SubjectChild(
          id: 1190,
          name: "বাংলাদেশ পরমাণু শক্তি কমিশন - জেনারেল অ্যাটেনডেন্ট(২৭-০৯-২০২৫)",
          questionsCount: 39,
        ),
      ],
      meta: PaginationMeta(total: 1),
    );
  }

  @override
  Future<SubjectQuestionsResponse> getSubjectQuestions(
    int subjectId, {
    int page = 1,
    int perPage = 15,
  }) async {
    return const SubjectQuestionsResponse(
      success: true,
      items: [
        PracticeQuestion(
          id: 53654,
          title: "পদ্মা সেতু কোন দুটি জেলাকে সংযুক্ত করেছে?",
          options: [
            PracticeQuestionOption(
              key: 0,
              letter: "A",
              value: "মানিকগঞ্জ ও শরিয়তপুর",
              isCorrect: false,
            ),
            PracticeQuestionOption(
              key: 2,
              letter: "C",
              value: "মুন্সিগঞ্জ ও শরিয়তপুর",
              isCorrect: true,
            ),
          ],
          correctLetter: "C",
        ),
      ],
      meta: PaginationMeta(total: 1),
    );
  }
}
