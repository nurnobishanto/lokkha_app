import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/localization/l10n/app_localizations.dart';
import 'package:lokkha/core/network/endpoints.dart';
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
            home: const Scaffold(
              body: SingleChildScrollView(
                child: HomeMcqSection(),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('HomeMcqSection renders dynamic question title, options and subject badge',
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
      expect(find.text('English Language'), findsOneWidget);

      // Question Title (cleaned from HTML)
      expect(find.text("'Belle' শব্দটি কোন Gender?"), findsOneWidget);

      // 4 Dynamic Options
      expect(find.text('A) Neuter Gender'), findsOneWidget);
      expect(find.text('B) Common Gender'), findsOneWidget);
      expect(find.text('C) Masculine Gender'), findsOneWidget);
      expect(find.text('D) Feminine Gender'), findsOneWidget);

      // Tap on correct option (D)
      await tester.tap(find.text('D) Feminine Gender'));
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
      await tester.tap(find.text('A) Neuter Gender'));
      await tester.pumpAndSettle();

      // Both Cancel icon (for wrong option) and Check icon (for correct answer) appear
      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });
}
