import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/di/question_bank_provider.dart';
import 'package:lokkha/features/home/presentation/home/components/home_mcq_section.dart';
import 'package:lokkha/features/question_bank/question_bank.dart';

class _MockQuestionBankRepository implements QuestionBankRepository {
  RandomQuestionModel? questionToReturn;
  int callCount = 0;

  _MockQuestionBankRepository([this.questionToReturn]);

  @override
  Future<RandomQuestionModel?> getRandomQuestion() async {
    callCount++;
    return questionToReturn;
  }
}

Finder findTextOrRich(String pattern) {
  return find.byWidgetPredicate(
    (widget) =>
        (widget is Text &&
            ((widget.data?.contains(pattern) ?? false) ||
                (widget.textSpan?.toPlainText().contains(pattern) ?? false))) ||
        (widget is RichText && widget.text.toPlainText().contains(pattern)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleApiPayload = {
    "success": true,
    "message": "Random question retrieved.",
    "data": {
      "id": 72276,
      "title": "<p>'Belle' শব্দটি কোন Gender?</p>",
      "description": null,
      "question_image": null,
      "question_type": "single_choice",
      "options": [
        {
          "key": "A",
          "value": "Neuter Gender",
          "is_correct": false
        },
        {
          "key": "B",
          "value": "Common Gender",
          "is_correct": false
        },
        {
          "key": "C",
          "value": "Masculine Gender",
          "is_correct": false
        },
        {
          "key": "D",
          "value": "Feminine Gender",
          "is_correct": true
        }
      ],
      "is_favorite": false,
      "subjects": [
        {
          "id": 3,
          "name": "English Language"
        },
        {
          "id": 20,
          "name": "কর্তৃপক্ষ/ফ্যাকাল্টি"
        },
        {
          "id": 1265,
          "name": "যুব উন্নয়ন অধিদপ্তর।পদের নাম: অফিস সহায়ক (২৭.০৬.২০২৬)"
        },
        {
          "id": 136,
          "name": "Parts of Speech"
        },
        {
          "id": 137,
          "name": "Noun and Noun Related"
        },
        {
          "id": 142,
          "name": "The Gender"
        }
      ],
      "tags": [
        {
          "id": 3585,
          "name": "যুব উন্নয়ন অধিদপ্তর।পদের নাম: অফিস সহায়ক (২৭.০৬.২০২৬)"
        }
      ],
      "explanation": "<p>Belle একটি ফরাসি শব্দ যার অর্থ সুন্দরী নারী, তাই এটি Feminine Gender।</p>",
      "explanation_image": null,
      "note": null,
      "reference": null,
      "correct_answer": null
    }
  };

  group('V1 Question Bank Random Endpoints & Model Integration', () {
    test('Endpoints contains valid question-bank/random route', () {
      expect(Endpoints.questionBankRandom, '/api/v1/question-bank/random');
      expect(Endpoints.v1QuestionBankRandom, '/api/v1/question-bank/random');
    });

    test('RandomQuestionResponse parses sample payload accurately', () {
      final response = RandomQuestionResponse.fromJson(sampleApiPayload);

      expect(response.success, isTrue);
      expect(response.message, 'Random question retrieved.');
      expect(response.data, isNotNull);

      final question = response.data!;
      expect(question.id, 72276);
      expect(question.cleanTitle, "'Belle' শব্দটি কোন Gender?");
      expect(question.options.length, 4);
      expect(question.options[0].displayOption, 'A) Neuter Gender');
      expect(question.options[0].isCorrect, isFalse);
      expect(question.options[3].displayOption, 'D) Feminine Gender');
      expect(question.options[3].isCorrect, isTrue);
      expect(question.rightAnswerIndex, 3);
      expect(question.primarySubject, 'English Language');
      expect(question.subjects.length, 6);
      expect(question.tags.length, 1);
      expect(question.explanation, isNotNull);
    });

    test('RandomQuestionModel cleanTitle handles HTML stripping and entities', () {
      final model = RandomQuestionModel(
        id: 1,
        title: '<p>&quot;কুলি&quot; শব্দের স্ত্রী বাচক কোনটি?&nbsp;</p>',
      );

      expect(model.cleanTitle, '"কুলি" শব্দের স্ত্রী বাচক কোনটি?');
    });
  });

  group('V1 Clean Architecture Use Case & Repository', () {
    test('GetRandomQuestionUseCase invokes repository.getRandomQuestion', () async {
      final model = RandomQuestionModel.fromJson(
        sampleApiPayload['data'] as Map<String, dynamic>,
      );
      final mockRepo = _MockQuestionBankRepository(model);
      final useCase = GetRandomQuestionUseCase(mockRepo);

      final result = await useCase();

      expect(result, isNotNull);
      expect(result!.id, 72276);
      expect(mockRepo.callCount, 1);
    });
  });

  group('RandomQuestionNotifier State & Selection Logic', () {
    test('fetchRandomQuestion updates state with retrieved question', () async {
      final model = RandomQuestionModel.fromJson(
        sampleApiPayload['data'] as Map<String, dynamic>,
      );
      final mockRepo = _MockQuestionBankRepository(model);

      final container = ProviderContainer(
        overrides: [
          questionBankRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      final notifier = container.read(randomQuestionNotifierProvider.notifier);
      await notifier.fetchRandomQuestion();

      final state = container.read(randomQuestionNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.question, isNotNull);
      expect(state.question?.id, 72276);
      expect(state.isAnswerRevealed, isFalse);
    });

    test('selectOption reveals answer and prevents subsequent change', () async {
      final model = RandomQuestionModel.fromJson(
        sampleApiPayload['data'] as Map<String, dynamic>,
      );
      final mockRepo = _MockQuestionBankRepository(model);

      final container = ProviderContainer(
        overrides: [
          questionBankRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      final notifier = container.read(randomQuestionNotifierProvider.notifier);
      await notifier.fetchRandomQuestion();

      notifier.selectOption(3);
      var state = container.read(randomQuestionNotifierProvider);
      expect(state.selectedOptionIndex, 3);
      expect(state.isAnswerRevealed, isTrue);

      // Subsequent tap does not override already revealed answer
      notifier.selectOption(1);
      state = container.read(randomQuestionNotifierProvider);
      expect(state.selectedOptionIndex, 3);
    });
  });

  group('HomeMcqSection Dynamic Widget Integration Tests', () {
    Widget buildTestWidget({
      required ProviderContainer container,
    }) {
      return UncontrolledProviderScope(
        container: container,
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, _) => const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: HomeMcqSection(),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('HomeMcqSection renders dynamic question title and options without category badge',
        (tester) async {
      final model = RandomQuestionModel.fromJson(
        sampleApiPayload['data'] as Map<String, dynamic>,
      );
      final mockRepo = _MockQuestionBankRepository(model);

      final container = ProviderContainer(
        overrides: [
          questionBankRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      // Pre-fetch question into container
      await container.read(randomQuestionNotifierProvider.notifier).fetchRandomQuestion();

      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pumpAndSettle();

      // Card Header
      expect(find.text('কারেন্ট অ্যাফেয়ার্স'), findsOneWidget);
      expect(find.text('MCQ'), findsOneWidget);
      expect(find.text('English Language'), findsNothing);

      // Question Title (rendered via HtmlWidget)
      expect(findTextOrRich("'Belle' শব্দটি কোন Gender?"), findsOneWidget);

      // 4 Dynamic Options
      expect(findTextOrRich('A) Neuter Gender'), findsOneWidget);
      expect(findTextOrRich('B) Common Gender'), findsOneWidget);
      expect(findTextOrRich('C) Masculine Gender'), findsOneWidget);
      expect(findTextOrRich('D) Feminine Gender'), findsOneWidget);

      // Tap on correct option (D)
      await tester.tap(findTextOrRich('D) Feminine Gender'));
      await tester.pumpAndSettle();

      // Checkmark icon appears
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      // Explanation box and Next Question button appear
      expect(find.text('ব্যাখ্যা'), findsOneWidget);
      expect(find.text('পরবর্তী প্রশ্ন'), findsOneWidget);
    });

    testWidgets('HomeMcqSection handles incorrect selection with feedback',
        (tester) async {
      final model = RandomQuestionModel.fromJson(
        sampleApiPayload['data'] as Map<String, dynamic>,
      );
      final mockRepo = _MockQuestionBankRepository(model);

      final container = ProviderContainer(
        overrides: [
          questionBankRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      await container.read(randomQuestionNotifierProvider.notifier).fetchRandomQuestion();

      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pumpAndSettle();

      // Tap wrong option (A)
      await tester.tap(findTextOrRich('A) Neuter Gender'));
      await tester.pumpAndSettle();

      // Both Cancel icon (for wrong option) and Check icon (for correct answer) appear
      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });

  group('HtmlSanitizer & MathML Tests', () {
    test('converts MathML into readable HTML superscripts and subscripts', () {
      const raw =
          '0) 24 <math xmlns="http://www.w3.org/1998/Math/MathML"><mi>c</mi><msup><mi>m</mi><mn>2</mn></msup></math>';
      expect(HtmlSanitizer.convertMathMlToHtml(raw), '0) 24 cm<sup>2</sup>');

      const raw2 =
          '1) 12√7 <math xmlns="http://www.w3.org/1998/Math/MathML"><mi>c</mi><msup><mi>m</mi>2</msup></math>';
      expect(HtmlSanitizer.convertMathMlToHtml(raw2), '1) 12√7 cm<sup>2</sup>');
    });

    testWidgets('HomeMcqSection renders MathML option cleanly without raw math tags', (tester) async {
      final mathPayload = {
        "id": 88001,
        "title": "Find the area of an isosceles triangle if its perimeter is 28 cm",
        "question_type": "single_choice",
        "options": [
          {
            "key": "0",
            "value": '24 <math xmlns="http://www.w3.org/1998/Math/MathML"><mi>c</mi><msup><mi>m</mi><mn>2</mn></msup></math>',
            "is_correct": true,
          },
          {
            "key": "1",
            "value": '12√7 <math xmlns="http://www.w3.org/1998/Math/MathML"><mi>c</mi><msup><mi>m</mi><mn>2</mn></msup></math>',
            "is_correct": false,
          },
        ],
        "is_favorite": false,
        "subjects": [
          {"id": 10, "name": "Bank Math"}
        ],
      };

      final model = RandomQuestionModel.fromJson(mathPayload);
      final mockRepo = _MockQuestionBankRepository(model);
      final container = ProviderContainer(
        overrides: [
          questionBankRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      Widget buildTestWidget({required ProviderContainer container}) {
        return UncontrolledProviderScope(
          container: container,
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, _) => const MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: HomeMcqSection(),
                ),
              ),
            ),
          ),
        );
      }

      await container.read(randomQuestionNotifierProvider.notifier).fetchRandomQuestion();
      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pumpAndSettle();

      // Verify no raw <math> or <msup> tags appear
      expect(find.textContaining('<math'), findsNothing);
      expect(find.textContaining('<msup'), findsNothing);
      expect(find.textContaining('xmlns='), findsNothing);

      // Verify rendered math text is found
      expect(findTextOrRich('24'), findsWidgets);
      expect(findTextOrRich('cm'), findsWidgets);
    });

    testWidgets('HomeMcqSection handles extremely long subject badge without horizontal overflow',
        (tester) async {
      final longBadgePayload = {
        "id": 88002,
        "title": "ব্যতিহারিক সর্বনাম কোনটি?",
        "question_type": "single_choice",
        "options": [
          {"key": "A", "value": "ইহারা", "is_correct": false},
          {"key": "B", "value": "যিনি", "is_correct": false},
          {"key": "C", "value": "নিজে নিজে", "is_correct": true},
          {"key": "D", "value": "কেহ", "is_correct": false},
        ],
        "is_favorite": false,
        "subjects": [
          {
            "id": 99,
            "name": "দুর্নীতি দমন কমিশন পদের নাম: উপ-সহকারী পরিচালক পরীক্ষার তারিখ: ০৩.০৫.২০২৪",
          }
        ],
      };

      final model = RandomQuestionModel.fromJson(longBadgePayload);
      final mockRepo = _MockQuestionBankRepository(model);
      final container = ProviderContainer(
        overrides: [
          questionBankRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      Widget buildTestWidget({required ProviderContainer container}) {
        return UncontrolledProviderScope(
          container: container,
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, _) => const MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: HomeMcqSection(),
                ),
              ),
            ),
          ),
        );
      }

      await container.read(randomQuestionNotifierProvider.notifier).fetchRandomQuestion();
      await tester.pumpWidget(buildTestWidget(container: container));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('কারেন্ট অ্যাফেয়ার্স'), findsOneWidget);
      expect(findTextOrRich('ব্যতিহারিক সর্বনাম কোনটি?'), findsOneWidget);
    });
  });
}
