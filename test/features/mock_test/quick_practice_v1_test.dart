import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/features/mock_test/mock_test.dart';
import 'package:lokkha/features/quick_practice/quick_practice.dart';
import 'package:lokkha/shared/shared.dart';

const Map<String, dynamic> sampleV1QuestionBanksJson = {
  "success": true,
  "message": "Question banks retrieved successfully.",
  "data": {
    "popular_banks": [
      {
        "id": 2,
        "title": "বিসিএস প্রিলিমিনারি",
        "badge": "১০ম-৪৬তম",
      }
    ],
    "subject_wise_banks": [
      {
        "id": 1,
        "name": "বাংলা",
        "slug": "bangla",
        "question_count": 21470
      },
      {
        "id": 3,
        "name": "English Language",
        "slug": "english-language",
        "question_count": 16914
      },
      {
        "id": 4,
        "name": "English Literature",
        "slug": "english-literature",
        "question_count": 2312
      },
      {
        "id": 11,
        "name": "গাণিতিক যুক্তি",
        "slug": "ganitik-zukti",
        "question_count": 5031
      },
      {
        "id": 10,
        "name": "মানসিক দক্ষতা",
        "slug": "mansik-dkshta",
        "question_count": 259
      },
      {
        "id": 5,
        "name": "বাংলাদেশ বিষয়াবলী",
        "slug": "clman-bishyablee",
        "question_count": 10602
      },
      {
        "id": 8,
        "name": "আন্তর্জাতিক বিষয়াবলী",
        "slug": "antrjatik-bishyablee",
        "question_count": 11962
      },
      {
        "id": 14,
        "name": "কম্পিউটার ও তথ্য প্রযুক্তি",
        "slug": "kmpiutar-oo-tthz-przukti",
        "question_count": 3362
      },
      {
        "id": 12,
        "name": "সাধারণ বিজ্ঞান",
        "slug": "sadharn-bijngan",
        "question_count": 4299
      },
      {
        "id": 9,
        "name": "ভূগোল",
        "slug": "vuugol",
        "question_count": 1236
      },
      {
        "id": 13,
        "name": "নৈতিকতা, মূল্যবোধ ও সু-শাসন",
        "slug": "noitikta-muulzbodh-oo-su-sasn",
        "question_count": 164
      },
      {
        "id": 495,
        "name": "কমন টপিক For All",
        "slug": "kmn-tpik-for-all",
        "question_count": 16
      },
      {
        "id": 506,
        "name": "টেকনিক্যাল বিষয়সমূহ",
        "slug": "teknikzal-bishysmuuh",
        "question_count": 3
      }
    ]
  }
};

class FakeMockTestNotifier extends MockTestNotifier {
  final MockTestState initialState;
  FakeMockTestNotifier(this.initialState);

  @override
  MockTestState build() {
    return initialState;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Quick Practice & Subject Wise Banks Model Tests', () {
    test('GetSubjectsModel parses subject_wise_banks cleanly from V1 API response', () {
      final model = GetSubjectsModel.fromJson(sampleV1QuestionBanksJson);

      expect(model.status, true);
      expect(model.subjects?.length, 13);

      final bangla = model.subjects!.first;
      expect(bangla.id, 1);
      expect(bangla.name, 'বাংলা');
      expect(bangla.slug, 'bangla');
      expect(bangla.questionCount, 21470);

      final english = model.subjects![1];
      expect(english.id, 3);
      expect(english.name, 'English Language');
      expect(english.questionCount, 16914);

      final bd = model.subjects![5];
      expect(bd.id, 5);
      expect(bd.name, 'বাংলাদেশ বিষয়াবলী');
      expect(bd.questionCount, 10602);

      final tech = model.subjects!.last;
      expect(tech.id, 506);
      expect(tech.name, 'টেকনিক্যাল বিষয়সমূহ');
      expect(tech.questionCount, 3);
    });

    test('Subject parses individual subject_wise_banks item safely', () {
      final rawItem = (sampleV1QuestionBanksJson['data']['subject_wise_banks'] as List)[0];
      final subject = Subject.fromJson(rawItem);

      expect(subject.id, 1);
      expect(subject.name, 'বাংলা');
      expect(subject.slug, 'bangla');
      expect(subject.questionCount, 21470);
    });

    test('GetSubjectsModel maintains backwards compatibility with legacy format', () {
      final legacy = {
        "status": true,
        "message": "success",
        "subjects": [
          {
            "id": 10,
            "name": "Legacy Subject",
            "question_count": 50,
          }
        ]
      };
      final model = GetSubjectsModel.fromJson(legacy);
      expect(model.status, true);
      expect(model.subjects?.length, 1);
      expect(model.subjects?.first.name, 'Legacy Subject');
    });
  });

  group('MockTestView Widget Tests', () {
    testWidgets('MockTestView renders all 13 subjects with chips and badges', (tester) async {
      final model = GetSubjectsModel.fromJson(sampleV1QuestionBanksJson);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => ProviderScope(
            overrides: [
              mockTestNotifierProvider.overrideWith(
                () => FakeMockTestNotifier(
                  MockTestState(
                    isLoading: false,
                    hasError: false,
                    model: model,
                  ),
                ),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: MockTestView(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify subjects are rendered
      expect(find.text('বাংলা (21.5k)'), findsOneWidget);
      expect(find.text('English Language (16.9k)'), findsOneWidget);
      expect(find.text('English Literature (2.3k)'), findsOneWidget);
      expect(find.text('গাণিতিক যুক্তি (5.0k)'), findsOneWidget);
      expect(find.text('মানসিক দক্ষতা (259)'), findsOneWidget);
      expect(find.text('বাংলাদেশ বিষয়াবলী (10.6k)'), findsOneWidget);
      expect(find.text('আন্তর্জাতিক বিষয়াবলী (12.0k)'), findsOneWidget);
      expect(find.text('কম্পিউটার ও তথ্য প্রযুক্তি (3.4k)'), findsOneWidget);
      expect(find.text('সাধারণ বিজ্ঞান (4.3k)'), findsOneWidget);
      expect(find.text('ভূগোল (1.2k)'), findsOneWidget);
      expect(find.text('নৈতিকতা, মূল্যবোধ ও সু-শাসন (164)'), findsOneWidget);
      expect(find.text('কমন টপিক For All (16)'), findsOneWidget);
      expect(find.text('টেকনিক্যাল বিষয়সমূহ (3)'), findsOneWidget);
    });

    testWidgets('MockTestTabView renders directly without TabBar or question bank tab', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => ProviderScope(
            overrides: [
              quickPracticeRepositoryProvider.overrideWithValue(const _MockQuickPracticeRepo()),
            ],
            child: const MaterialApp(
              home: MockTestTabView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('কুইক প্র্যাকটিস'), findsOneWidget);
      expect(find.byType(TabBar), findsNothing);
      expect(find.byType(DefaultTabController), findsNothing);
      expect(find.text('বিষয় সমূহ'), findsNothing);
      expect(find.text('প্রশ্ন ব্যাংক'), findsNothing);
    });
  });
}

class _MockQuickPracticeRepo implements QuickPracticeRepository {
  const _MockQuickPracticeRepo();

  @override
  Future<List<SubjectSectionOverview>> getSubjectSectionsOverview() async {
    return const [];
  }

  @override
  Future<List<QuickPracticeSubject>> getTopLevelSubjects({String? search}) async {
    return const [];
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
      items: [],
      meta: PaginationMeta(total: 0),
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
      items: [],
      meta: PaginationMeta(total: 0),
    );
  }

  @override
  Future<SubjectExamSession> startSubjectExam(
    int subjectId,
    SubjectStartExamRequest request,
  ) async {
    return const SubjectExamSession(
      examId: 1,
      totalQuestions: 10,
      duration: 15,
    );
  }
}
