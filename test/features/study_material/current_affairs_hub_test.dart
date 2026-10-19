import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/study_material/study_material.dart';
import 'package:lokkha/shared/shared.dart';

class MockCurrentAffairsRepository implements CurrentAffairsRepository {
  CurrentAffairsFeedResponse feedResponse = const CurrentAffairsFeedResponse();
  CurrentAffairsMonthlyDigestResponse digestResponse =
      const CurrentAffairsMonthlyDigestResponse(month: '2026-05', monthName: 'মে ২০২৬');
  List<CurrentAffairsMonthItem> monthsList = [];
  CurrentAffairsCategoriesResponse categoriesResponse =
      const CurrentAffairsCategoriesResponse();
  CurrentAffairsLatestResponse latestResponse =
      const CurrentAffairsLatestResponse();
  CurrentAffairsDetailResponse detailResponse =
      const CurrentAffairsDetailResponse();
  CurrentAffairsBookmarkResponse bookmarkResponse =
      const CurrentAffairsBookmarkResponse(isBookmarked: true);

  @override
  Future<CurrentAffairsFeedResponse> getFeed({
    String? type,
    String? search,
    String? date,
    String? fromDate,
    String? toDate,
    String? month,
    int? year,
    int? subjectId,
    String? sortBy,
    int perPage = 20,
    int page = 1,
  }) async {
    return feedResponse;
  }

  @override
  Future<CurrentAffairsMonthlyDigestResponse> getMonthlyDigest({
    String? month,
    String? format,
    int? subjectId,
  }) async {
    return digestResponse;
  }

  @override
  Future<List<CurrentAffairsMonthItem>> getMonths() async {
    return monthsList;
  }

  @override
  Future<CurrentAffairsCategoriesResponse> getCategories() async {
    return categoriesResponse;
  }

  @override
  Future<CurrentAffairsLatestResponse> getLatest() async {
    return latestResponse;
  }

  @override
  Future<CurrentAffairsDetailResponse> getQuestionDetail(dynamic id) async {
    return detailResponse;
  }

  @override
  Future<CurrentAffairsBookmarkResponse> toggleBookmark(dynamic id) async {
    return bookmarkResponse;
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

  group('Current Affairs V1 Model Serialization Tests', () {
    test('Feed Response parses items, grouped_by_date, and pagination accurately', () {
      final json = {
        "success": true,
        "message": "Current Affairs feed retrieved successfully.",
        "data": {
          "items": [
            {
              "id": 70575,
              "custom_id": "M-2026-05-09-001",
              "title": "রূপপুর পারমাণবিক প্রকল্পে ‘অটোমেটেড প্রসেস কন্ট্রোল সিস্টেম’ প্রযুক্তি সরবরাহকারী প্রতিষ্ঠান কোনটি?",
              "clean_title": "রূপপুর পারমাণবিক প্রকল্পে ‘অটোমেটেড প্রসেস কন্ট্রোল সিস্টেম’ প্রযুক্তি সরবরাহকারী প্রতিষ্ঠান কোনটি?",
              "description": null,
              "question_type": "multiple_choice",
              "category": {
                "id": 5,
                "name": "বাংলাদেশ বিষয়াবলী",
                "type": "bangladesh"
              },
              "date": "2026-05-09",
              "date_formatted": "May 9, 2026",
              "date_bn": "০৯ মে ২০২৬, শনিবার",
              "answer": "রসাটম অটোমেটেড কন্ট্রোল সিস্টেমস",
              "answers": ["রসাটম অটোমেটেড কন্ট্রোল সিস্টেমস"],
              "options": [
                {
                  "key": "A",
                  "label_bn": "ক",
                  "value": "রসাটম অটোমেটেড কন্ট্রোল সিস্টেমস",
                  "is_correct": true
                },
                {
                  "key": "B",
                  "label_bn": "খ",
                  "value": "সিমেন্স এনার্জি",
                  "is_correct": false
                }
              ],
              "explanation": "রাশিয়ার রাষ্ট্রীয় পরমাণু শক্তি করপোরেশন রসাটমের নিয়ন্ত্রণাধীন প্রতিষ্ঠান ‘আরএএসইউ’ এই স্বয়ংক্রিয় নিয়ন্ত্রণ ব্যবস্থা স্থাপন করে।",
              "explanation_html": "<p>রাশিয়ার রাষ্ট্রীয় পরমাণু শক্তি করপোরেশন রসাটমের নিয়ন্ত্রণাধীন প্রতিষ্ঠান...</p>",
              "note": null,
              "reference": "দৈনিক প্রথম আলো",
              "question_image": null,
              "explanation_image": null,
              "is_bookmarked": false,
              "subjects": [
                {
                  "id": 5,
                  "name": "বাংলাদেশ বিষয়াবলী",
                  "slug": "bangladesh-affairs",
                  "parent_id": null
                }
              ],
              "tags": [
                {
                  "id": 12,
                  "name": "বিদ্যুৎ ও জ্বালানি"
                }
              ]
            }
          ],
          "grouped_by_date": [
            {
              "date": "2026-05-09",
              "date_formatted": "May 9, 2026",
              "date_bn": "০৯ মে ২০২৬, শনিবার",
              "total_questions": 1,
              "questions": [
                {
                  "id": 70575,
                  "title": "রূপপুর পারমাণবিক প্রকল্প",
                  "options": []
                }
              ]
            }
          ],
          "pagination": {
            "current_page": 1,
            "last_page": 5,
            "per_page": 20,
            "total": 95,
            "has_more": true
          }
        }
      };

      final response = CurrentAffairsFeedResponse.fromJson(json);
      expect(response.success, true);
      expect(response.items.length, 1);
      final item = response.items.first;
      expect(item.id, 70575);
      expect(item.customId, "M-2026-05-09-001");
      expect(item.category?.name, "বাংলাদেশ বিষয়াবলী");
      expect(item.category?.type, "bangladesh");
      expect(item.dateBn, "০৯ মে ২০২৬, শনিবার");
      expect(item.answer, "রসাটম অটোমেটেড কন্ট্রোল সিস্টেমস");
      expect(item.options.length, 2);
      expect(item.options.first.displayLabel, "ক");
      expect(item.options.first.isCorrect, true);
      expect(item.options[1].displayLabel, "খ");
      expect(item.options[1].isCorrect, false);
      expect(item.reference, "দৈনিক প্রথম আলো");
      expect(item.isBookmarked, false);

      expect(response.groupedByDate.length, 1);
      expect(response.groupedByDate.first.dateBn, "০৯ মে ২০২৬, শনিবার");
      expect(response.groupedByDate.first.totalQuestions, 1);

      expect(response.pagination.currentPage, 1);
      expect(response.pagination.lastPage, 5);
      expect(response.pagination.total, 95);
      expect(response.pagination.hasMore, true);
    });

    test('Monthly Digest parses locked prompt and free preview limits properly', () {
      final json = {
        "success": true,
        "message": "Monthly digest retrieved successfully.",
        "data": {
          "month": "2026-05",
          "month_name": "মে ২০২৬",
          "month_name_en": "May 2026",
          "is_locked": true,
          "subscription_prompt": {
            "title": "সম্পূর্ণ মাসিক ডাইজেস্ট পড়তে সাবস্ক্রিপশন প্রয়োজন",
            "message": "মাসিক কারেন্ট অ্যাফেয়ার্স ডাইজেস্ট...",
            "action_text": "সাবস্ক্রাইব করুন",
            "upgrade_url": "/packages"
          },
          "statistics": {
            "total_questions": 120,
            "bangladesh": 65,
            "international": 55
          },
          "downloads": {
            "with_options_pdf": "https://lokkha.com/pdf/with-options.pdf",
            "without_options_pdf": "https://lokkha.com/pdf/without-options.pdf"
          },
          "categories": [
            {
              "id": 5,
              "name": "বাংলাদেশ বিষয়াবলী",
              "slug": "bangladesh-affairs",
              "total_questions": 65,
              "questions": [
                {
                  "id": 101,
                  "title": "নমুনা প্রশ্ন",
                  "options": []
                }
              ]
            }
          ]
        }
      };

      final digest = CurrentAffairsMonthlyDigestResponse.fromJson(json);
      expect(digest.success, true);
      expect(digest.month, "2026-05");
      expect(digest.monthName, "মে ২০২৬");
      expect(digest.isLocked, true);
      expect(digest.subscriptionPrompt?.title, "সম্পূর্ণ মাসিক ডাইজেস্ট পড়তে সাবস্ক্রিপশন প্রয়োজন");
      expect(digest.subscriptionPrompt?.actionText, "সাবস্ক্রাইব করুন");
      expect(digest.statistics.totalQuestions, 120);
      expect(digest.statistics.bangladesh, 65);
      expect(digest.statistics.international, 55);
      expect(digest.downloads.withOptionsPdf, "https://lokkha.com/pdf/with-options.pdf");
      expect(digest.categories.length, 1);
      expect(digest.categories.first.totalQuestions, 65);
      expect(digest.categories.first.questions.length, 1);
    });

    test('Months Archive Response parses correctly', () {
      final json = {
        "success": true,
        "message": "Available months retrieved successfully.",
        "data": [
          {
            "month": "2026-05",
            "label_bn": "মে ২০২৬",
            "label_en": "May 2026",
            "year": 2026,
            "month_number": 5,
            "total_questions": 120
          },
          {
            "month": "2026-04",
            "label_bn": "এপ্রিল ২০২৬",
            "label_en": "April 2026",
            "year": 2026,
            "month_number": 4,
            "total_questions": 115
          }
        ]
      };

      final list = (json['data'] as List)
          .map((e) => CurrentAffairsMonthItem.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(list.length, 2);
      expect(list.first.month, "2026-05");
      expect(list.first.labelBn, "মে ২০২৬");
      expect(list.first.totalQuestions, 120);
      expect(list[1].month, "2026-04");
      expect(list[1].monthNumber, 4);
    });

    test('Months Archive Response parses real API format with items, value, and count correctly', () {
      final json = {
        "success": true,
        "message": "Available Current Affairs months retrieved successfully.",
        "data": {
          "items": [
            {
              "value": "2026-10",
              "year": 2026,
              "month": 10,
              "label_bn": "অক্টোবর ২০২৬",
              "label_en": "October 2026",
              "count": 19,
              "count_bn": "১৯",
              "display": "অক্টোবর ২০২৬ (October 2026) — ১৯টি প্রশ্ন"
            }
          ],
          "total": 1
        }
      };

      final items = (json['data'] as Map)['items'] as List;
      final list = items
          .map((e) => CurrentAffairsMonthItem.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(list.length, 1);
      expect(list.first.month, "2026-10");
      expect(list.first.labelBn, "অক্টোবর ২০২৬");
      expect(list.first.monthNumber, 10);
      expect(list.first.totalQuestions, 19);
      expect(list.first.display, "অক্টোবর ২০২৬ (October 2026) — ১৯টি প্রশ্ন");
    });

    test('Topic Categories and Latest Highlights parse correctly', () {
      final catJson = {
        "success": true,
        "message": "Categories retrieved",
        "data": {
          "bangladesh": [
            {
              "id": 5,
              "name": "বাংলাদেশ বিষয়াবলী",
              "slug": "bangladesh-affairs",
              "questions_count": 450,
              "children": [
                {
                  "id": 12,
                  "name": "মুক্তিযুদ্ধ ও ইতিহাস",
                  "slug": "liberation-war",
                  "questions_count": 80,
                  "children": []
                }
              ]
            }
          ],
          "international": [
            {
              "id": 8,
              "name": "আন্তর্জাতিক বিষয়াবলী",
              "slug": "international-affairs",
              "questions_count": 380,
              "children": []
            }
          ]
        }
      };

      final categories = CurrentAffairsCategoriesResponse.fromJson(catJson);
      expect(categories.success, true);
      expect(categories.bangladesh.length, 1);
      expect(categories.bangladesh.first.children.length, 1);
      expect(categories.bangladesh.first.children.first.name, "মুক্তিযুদ্ধ ও ইতিহাস");
      expect(categories.international.length, 1);

      final latestJson = {
        "success": true,
        "message": "Latest current affairs retrieved",
        "data": {
          "bangladesh": [
            {"id": 1, "title": "বাংলাদেশ আপডেট ১", "options": []}
          ],
          "international": [
            {"id": 2, "title": "আন্তর্জাতিক আপডেট ১", "options": []}
          ]
        }
      };

      final latest = CurrentAffairsLatestResponse.fromJson(latestJson);
      expect(latest.success, true);
      expect(latest.bangladesh.length, 1);
      expect(latest.international.length, 1);
    });

    test('Single Question Detail and Bookmark Toggle parse correctly', () {
      final detailJson = {
        "success": true,
        "message": "Question retrieved",
        "data": {
          "question": {
            "id": 70575,
            "title": "রূপপুর প্রকল্প প্রশ্ন",
            "is_bookmarked": true,
            "options": []
          },
          "related_questions": [
            {"id": 70576, "title": "সম্পর্কিত প্রশ্ন ১", "options": []}
          ]
        }
      };

      final detail = CurrentAffairsDetailResponse.fromJson(detailJson);
      expect(detail.success, true);
      expect(detail.question?.id, 70575);
      expect(detail.question?.isBookmarked, true);
      expect(detail.relatedQuestions.length, 1);

      final bookmarkJson = {
        "success": true,
        "message": "Question bookmarked successfully.",
        "data": {
          "is_bookmarked": true
        }
      };

      final bookmark = CurrentAffairsBookmarkResponse.fromJson(bookmarkJson);
      expect(bookmark.success, true);
      expect(bookmark.isBookmarked, true);
    });
  });

  group('CurrentAffairsHubNotifier State Tests', () {
    test('fetchFeed populates feedItems and dateGroups', () async {
      final mockRepo = MockCurrentAffairsRepository();
      mockRepo.feedResponse = CurrentAffairsFeedResponse(
        success: true,
        items: [
          const CurrentAffairsFeedItem(
            id: 1,
            title: 'টেস্ট প্রশ্ন',
            answer: 'উত্তর',
            options: [
              CurrentAffairsOptionItem(key: 'A', labelBn: 'ক', value: 'অপশন ১', isCorrect: true),
              CurrentAffairsOptionItem(key: 'B', labelBn: 'খ', value: 'অপশন ২', isCorrect: false),
            ],
          ),
        ],
        groupedByDate: [
          const CurrentAffairsDateGroup(
            date: '2026-05-09',
            dateBn: '০৯ মে ২০২৬, শনিবার',
            totalQuestions: 1,
            questions: [
              CurrentAffairsFeedItem(
                id: 1,
                title: 'টেস্ট প্রশ্ন',
                options: [],
              ),
            ],
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          currentAffairsRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      final notifier = container.read(currentAffairsHubNotifierProvider.notifier);
      await notifier.init();

      final state = container.read(currentAffairsHubNotifierProvider);
      expect(state.feedItems.length, 1);
      expect(state.dateGroups.length, 1);
      expect(state.dateGroups.first.dateBn, '০৯ মে ২০২৬, শনিবার');

      // Test option selection and answer reveal
      notifier.selectOption(1, 'A');
      final stateAfterSelect = container.read(currentAffairsHubNotifierProvider);
      expect(stateAfterSelect.userSelectedAnswers[1], 'A');
      expect(stateAfterSelect.revealedAnswers.contains(1), true);

      // Test explanation toggle
      notifier.toggleExplanation(1);
      expect(container.read(currentAffairsHubNotifierProvider).expandedExplanations.contains(1), true);
      notifier.toggleExplanation(1);
      expect(container.read(currentAffairsHubNotifierProvider).expandedExplanations.contains(1), false);
    });

    test('toggleBookmark performs optimistic update and retains state on success', () async {
      final mockRepo = MockCurrentAffairsRepository();
      mockRepo.feedResponse = CurrentAffairsFeedResponse(
        success: true,
        items: [
          const CurrentAffairsFeedItem(
            id: 10,
            title: 'বুকমার্ক টেস্ট প্রশ্ন',
            isBookmarked: false,
            options: [],
          ),
        ],
        groupedByDate: [
          const CurrentAffairsDateGroup(
            date: '2026-05-09',
            questions: [
              CurrentAffairsFeedItem(
                id: 10,
                title: 'বুকমার্ক টেস্ট প্রশ্ন',
                isBookmarked: false,
                options: [],
              ),
            ],
          ),
        ],
      );
      mockRepo.bookmarkResponse = const CurrentAffairsBookmarkResponse(
        success: true,
        isBookmarked: true,
      );

      final container = ProviderContainer(
        overrides: [
          currentAffairsRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      final notifier = container.read(currentAffairsHubNotifierProvider.notifier);
      await notifier.init();

      expect(container.read(currentAffairsHubNotifierProvider).feedItems.first.isBookmarked, false);
      final result = await notifier.toggleBookmark(10);
      expect(result, true);
      final updatedState = container.read(currentAffairsHubNotifierProvider);
      expect(updatedState.feedItems.first.isBookmarked, true);
      expect(updatedState.dateGroups.first.questions.first.isBookmarked, true);
    });
  });

  group('CurrentAffairs UI Widget Tests', () {
    testWidgets('CurrentAffairsQuestionCard renders question title, options, and reacts to clicks', (tester) async {
      final item = const CurrentAffairsFeedItem(
        id: 99,
        title: 'বাংলাদেশের প্রথম রাষ্ট্রপতির নাম কী?',
        answer: 'বঙ্গবন্ধু শেখ মুজিবুর রহমান',
        category: CurrentAffairsCategoryInfo(
          id: 5,
          name: 'বাংলাদেশ বিষয়াবলী',
          type: 'bangladesh',
        ),
        options: [
          CurrentAffairsOptionItem(
            key: 'A',
            labelBn: 'ক',
            value: 'বঙ্গবন্ধু শেখ মুজিবুর রহমান',
            isCorrect: true,
          ),
          CurrentAffairsOptionItem(
            key: 'B',
            labelBn: 'খ',
            value: 'সৈয়দ নজরুল ইসলাম',
            isCorrect: false,
          ),
        ],
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: CurrentAffairsQuestionCard(item: item),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(findTextOrRich('বাংলাদেশের প্রথম রাষ্ট্রপতির নাম কী?'), findsOneWidget);
      // Options are hidden by default per user requirement
      expect(find.text('ক). বঙ্গবন্ধু শেখ মুজিবুর রহমান'), findsNothing);
      expect(find.text('খ). সৈয়দ নজরুল ইসলাম'), findsNothing);
      // Correct answer is still prominently displayed
      expect(find.textContaining('সঠিক উত্তরঃ ক). বঙ্গবন্ধু শেখ মুজিবুর রহমান'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    });

    testWidgets('CurrentAffairsQuestionCard sanitizes dirty HTML and renders clean title via HtmlWidget without raw tags', (tester) async {
      const dirtyTitle = '<p>বাংলাদেশে বিভাগ কয়টি?</p>\r\n<p></p>\r\n<p></p>\r\n<p></p>\r\n<p>';
      const dirtyCleanTitle = 'বাংলাদেশে বিভাগ কয়টি?</p>\r\n<p></p>\r\n<p></p>\r\n<p></p>\r\n<p>';

      final item = CurrentAffairsFeedItem(
        id: 82295,
        title: dirtyTitle,
        cleanTitle: dirtyCleanTitle,
        date: '2026-09-17',
        dateBn: '১৭ সেপ্টেম্বর ২০২৬, বৃহস্পতিবার',
        answer: '৮টি',
        options: const [
          CurrentAffairsOptionItem(key: 'A', labelBn: 'ক', value: '<p>৪টি</p>', isCorrect: false),
          CurrentAffairsOptionItem(key: 'B', labelBn: 'খ', value: '<p>৬টি</p>', isCorrect: false),
          CurrentAffairsOptionItem(key: 'C', labelBn: 'গ', value: '<p>৭টি</p>', isCorrect: false),
          CurrentAffairsOptionItem(key: 'D', labelBn: 'ঘ', value: '<p>৮টি</p>', isCorrect: true),
        ],
      );

      // Verify model level sanitization
      expect(item.displayTitle, 'বাংলাদেশে বিভাগ কয়টি?');
      expect(
        item.buildSanitizedHtmlTitle(prefix: '১৭. '),
        '<span style="color: #059669; font-weight: bold;">১৭. </span> বাংলাদেশে বিভাগ কয়টি?',
      );
      expect(item.options[0].displayValue, '৪টি');
      expect(item.options[3].displayValue, '৮টি');

      // Verify widget rendering
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: CurrentAffairsQuestionCard(
                    item: item,
                    serialNumber: 17,
                    showOptions: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Expect HtmlWidget to be present
      expect(find.byType(HtmlWidget), findsWidgets);

      // Verify no raw unescaped HTML tags appear on screen
      expect(findTextOrRich('</p>'), findsNothing);
      expect(findTextOrRich('<p></p>'), findsNothing);
      expect(findTextOrRich('<p>'), findsNothing);

      // Verify clean question title is found
      expect(findTextOrRich('বাংলাদেশে বিভাগ কয়টি?'), findsOneWidget);

      // Verify options are cleaned from HTML
      expect(find.text('ক). ৪টি'), findsOneWidget);
      expect(find.text('ঘ). ৮টি'), findsOneWidget);
      expect(find.textContaining('সঠিক উত্তরঃ ঘ). ৮টি'), findsOneWidget);
    });

    testWidgets('CurrentAffairsDigestView renders month selector, full reader button and category pills', (tester) async {
      final mockRepo = MockCurrentAffairsRepository();
      mockRepo.monthsList = [
        const CurrentAffairsMonthItem(
          month: '2026-10',
          labelBn: 'অক্টোবর ২০২৬',
          labelEn: 'October 2026',
          year: 2026,
          monthNumber: 10,
          totalQuestions: 370,
        ),
      ];
      mockRepo.digestResponse = const CurrentAffairsMonthlyDigestResponse(
        month: '2026-10',
        monthName: 'অক্টোবর ২০২৬',
        monthNameEn: 'October 2026',
        statistics: CurrentAffairsDigestStatistics(
          totalQuestions: 370,
          bangladesh: 189,
          international: 181,
        ),
        downloads: CurrentAffairsDigestDownloads(
          withOptionsPdf: 'https://lokkha.com/with.pdf',
          withoutOptionsPdf: 'https://lokkha.com/without.pdf',
        ),
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => ProviderScope(
            overrides: [
              currentAffairsRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: CurrentAffairsDigestView(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('মাস নির্বাচন করুন'), findsOneWidget);
      expect(find.text('প্রদর্শন ফরম্যাট'), findsOneWidget);
      expect(find.text('পড়ুন (Full Reader)'), findsOneWidget);
      expect(find.text('PDF (Without Options)'), findsOneWidget);
      expect(find.text('PDF (With Options)'), findsOneWidget);
      expect(find.text('বাংলাদেশ বিষয়াবলি'), findsWidgets);
      expect(find.text('আন্তর্জাতিক বিষয়াবলি'), findsWidgets);
      await tester.scrollUntilVisible(find.text('সব বিষয়াবলি'), 100);
      expect(find.text('সব বিষয়াবলি'), findsOneWidget);
    });

    testWidgets('CurrentAffairsReaderView renders serialized Bengali question, 2-column options and explanation box for package holder', (tester) async {
      havePackage.value = true;
      addTearDown(() => havePackage.value = false);

      final mockRepo = MockCurrentAffairsRepository();
      mockRepo.digestResponse = const CurrentAffairsMonthlyDigestResponse(
        month: '2026-10',
        monthName: 'অক্টোবর ২০২৬',
        categories: [
          CurrentAffairsDigestCategory(
            id: 5,
            name: 'সাম্প্রতিক বাংলাদেশ বিষয়াবলি',
            totalQuestions: 1,
            questions: [
              CurrentAffairsFeedItem(
                id: 86887,
                title: 'কতটি পৌরসভা ও গ্রামীণ উপজেলায় ডিজিটাল ভূমি ব্যবস্থাপনা পদ্ধতি স্থাপনের পাইলট প্রকল্প গ্রহণ করা হয়েছে?',
                cleanTitle: 'কতটি পৌরসভা ও গ্রামীণ উপজেলায় ডিজিটাল ভূমি ব্যবস্থাপনা পদ্ধতি স্থাপনের পাইলট প্রকল্প গ্রহণ করা হয়েছে?',
                date: '2026-10-01',
                dateBn: '০১ অক্টোবর ২০২৬, বৃহস্পতিবার',
                answer: '১টি পৌরসভা ও ২টি গ্রামীণ উপজেলা',
                options: [
                  CurrentAffairsOptionItem(key: 'A', labelBn: 'ক', value: '১টি পৌরসভা ও ২টি গ্রামীণ উপজেলা', isCorrect: true),
                  CurrentAffairsOptionItem(key: 'B', labelBn: 'খ', value: '২টি পৌরসভা ও ৩টি গ্রামীণ উপজেলা', isCorrect: false),
                  CurrentAffairsOptionItem(key: 'C', labelBn: 'গ', value: '৩টি পৌরসভা ও ১টি গ্রামীণ উপজেলা', isCorrect: false),
                  CurrentAffairsOptionItem(key: 'D', labelBn: 'ঘ', value: '৫টি পৌরসভা ও ৫টি গ্রামীণ উপজেলা', isCorrect: false),
                ],
                explanation: 'ডিজিটাল ভূমি ব্যবস্থাপনা পদ্ধতি স্থাপনের জন্য ভূমি মন্ত্রণালয়ের অনুমোদিত প্রকল্পে ১টি পৌরসভা ও ২টি গ্রামীণ উপজেলা অন্তর্ভুক্ত রয়েছে।',
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => ProviderScope(
            overrides: [
              currentAffairsRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const MaterialApp(
              home: CurrentAffairsReaderView(
                categoryTitle: 'সাম্প্রতিক বাংলাদেশ বিষয়াবলি',
                categoryId: 5,
                withOptions: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('সাম্প্রতিক বাংলাদেশ বিষয়াবলি'), findsWidgets);
      expect(findTextOrRich('কতটি পৌরসভা ও গ্রামীণ উপজেলায়'), findsOneWidget);
      expect(find.text('ক). ১টি পৌরসভা ও ২টি গ্রামীণ উপজেলা'), findsOneWidget);
      expect(find.text('খ). ২টি পৌরসভা ও ৩টি গ্রামীণ উপজেলা'), findsOneWidget);
      expect(find.text('গ). ৩টি পৌরসভা ও ১টি গ্রামীণ উপজেলা'), findsOneWidget);
      expect(find.text('ঘ). ৫টি পৌরসভা ও ৫টি গ্রামীণ উপজেলা'), findsOneWidget);
      expect(find.textContaining('সঠিক উত্তরঃ'), findsOneWidget);
      expect(find.text('ব্যাখ্যা:'), findsOneWidget);
    });

    testWidgets('CurrentAffairsReaderView hides explanation when user has no package and hides options when withOptions is false', (tester) async {
      havePackage.value = false;
      final mockRepo = MockCurrentAffairsRepository();
      mockRepo.digestResponse = const CurrentAffairsMonthlyDigestResponse(
        month: '2026-10',
        monthName: 'অক্টোবর ২০২৬',
        categories: [
          CurrentAffairsDigestCategory(
            id: 5,
            name: 'সাম্প্রতিক বাংলাদেশ বিষয়াবলি',
            totalQuestions: 1,
            questions: [
              CurrentAffairsFeedItem(
                id: 86887,
                title: 'কতটি পৌরসভা ও গ্রামীণ উপজেলায় ডিজিটাল ভূমি ব্যবস্থাপনা পদ্ধতি স্থাপনের পাইলট প্রকল্প গ্রহণ করা হয়েছে?',
                date: '2026-10-01',
                answer: '১টি পৌরসভা ও ২টি গ্রামীণ উপজেলা',
                options: [
                  CurrentAffairsOptionItem(key: 'A', labelBn: 'ক', value: '১টি পৌরসভা ও ২টি গ্রামীণ উপজেলা', isCorrect: true),
                ],
                explanation: 'ডিজিটাল ভূমি ব্যবস্থাপনা পদ্ধতি স্থাপনের জন্য পাইলট প্রকল্প।',
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => ProviderScope(
            overrides: [
              currentAffairsRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const MaterialApp(
              home: CurrentAffairsReaderView(
                categoryTitle: 'সাম্প্রতিক বাংলাদেশ বিষয়াবলি',
                categoryId: 5,
                withOptions: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(findTextOrRich('কতটি পৌরসভা ও গ্রামীণ উপজেলায়'), findsOneWidget);
      expect(find.text('ক). ১টি পৌরসভা ও ২টি গ্রামীণ উপজেলা'), findsNothing);
      expect(find.textContaining('সঠিক উত্তরঃ'), findsOneWidget);
      // Explanation is NOT shown because user has no package!
      expect(find.text('ব্যাখ্যা:'), findsNothing);
    });

    testWidgets('CurrentAffairsView renders tabs without "সকল" - only বাংলাদেশ, আন্তর্জাতিক, মাসিক ডাইজেস্ট', (tester) async {
      final mockRepo = MockCurrentAffairsRepository();
      mockRepo.feedResponse = const CurrentAffairsFeedResponse(
        success: true,
        items: [],
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => ProviderScope(
            overrides: [
              currentAffairsRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const MaterialApp(
              home: CurrentAffairsView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('সকল'), findsNothing);
      expect(find.text('বাংলাদেশ'), findsOneWidget);
      expect(find.text('আন্তর্জাতিক'), findsOneWidget);
      expect(find.text('মাসিক ডাইজেস্ট'), findsOneWidget);
    });

    test('setDateFilter and setMonthFilter properly set and cleanly clear filters to null', () async {
      final mockRepo = MockCurrentAffairsRepository();
      mockRepo.feedResponse = const CurrentAffairsFeedResponse(
        success: true,
        items: [],
      );

      final container = ProviderContainer(
        overrides: [
          currentAffairsRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      final notifier = container.read(currentAffairsHubNotifierProvider.notifier);
      await notifier.init();

      // Initially null
      expect(container.read(currentAffairsHubNotifierProvider).selectedDate, isNull);
      expect(container.read(currentAffairsHubNotifierProvider).selectedMonth, isNull);

      // Set date
      notifier.setDateFilter('2026-05-09');
      expect(container.read(currentAffairsHubNotifierProvider).selectedDate, '2026-05-09');
      expect(container.read(currentAffairsHubNotifierProvider).selectedMonth, isNull);

      // Clear date
      notifier.setDateFilter(null);
      expect(container.read(currentAffairsHubNotifierProvider).selectedDate, isNull);

      // Set month
      notifier.setMonthFilter('2026-05');
      expect(container.read(currentAffairsHubNotifierProvider).selectedMonth, '2026-05');
      expect(container.read(currentAffairsHubNotifierProvider).selectedDate, isNull);

      // Clear month
      notifier.setMonthFilter(null);
      expect(container.read(currentAffairsHubNotifierProvider).selectedMonth, isNull);
    });

    testWidgets('CurrentAffairsView renders floating calendar bar and clears active date filter on chip tap', (tester) async {
      final mockRepo = MockCurrentAffairsRepository();
      mockRepo.feedResponse = const CurrentAffairsFeedResponse(
        success: true,
        items: [],
      );

      final container = ProviderContainer(
        overrides: [
          currentAffairsRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      final notifier = container.read(currentAffairsHubNotifierProvider.notifier);
      await notifier.init();

      // Set date filter
      notifier.setDateFilter('2026-05-09');

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: CurrentAffairsView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Floating calendar bar is rendered
      expect(find.text('2026-05-09'), findsWidgets);
      expect(find.text('মাস বাছুন'), findsOneWidget);

      // Active Filter Chip is rendered
      expect(find.text('তারিখ: 2026-05-09'), findsOneWidget);

      // Tap on the chip to clear the date filter
      await tester.tap(find.text('তারিখ: 2026-05-09'));
      await tester.pumpAndSettle();

      // Filter should now be cleanly cleared
      expect(container.read(currentAffairsHubNotifierProvider).selectedDate, isNull);
      expect(find.text('তারিখ: 2026-05-09'), findsNothing);
      expect(find.text('তারিখ বাছুন'), findsOneWidget);
    });

    testWidgets('CurrentAffairsQuestionCard renders extremely long answer without horizontal overflow', (tester) async {
      final item = const CurrentAffairsFeedItem(
        id: 101,
        title: 'দীর্ঘ উত্তরবিশিষ্ট একটি নমুনা সাধারণ জ্ঞান প্রশ্ন?',
        answer: 'রাশিয়ার রাষ্ট্রীয় পরমাণু শক্তি করপোরেশন রসাটমের নিয়ন্ত্রণাধীন প্রতিষ্ঠান আরএএসইউ কর্তৃক সফলভাবে প্রযুক্তি সরবরাহকৃত দীর্ঘ নামীয় প্রকল্প',
        options: [
          CurrentAffairsOptionItem(
            key: 'A',
            labelBn: 'ক',
            value: 'রাশিয়ার রাষ্ট্রীয় পরমাণু শক্তি করপোরেশন রসাটমের নিয়ন্ত্রণাধীন প্রতিষ্ঠান আরএএসইউ কর্তৃক সফলভাবে প্রযুক্তি সরবরাহকৃত দীর্ঘ নামীয় প্রকল্প',
            isCorrect: true,
          ),
        ],
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: SizedBox(
                    width: 320, // narrow screen
                    child: CurrentAffairsQuestionCard(item: item),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.textContaining('সঠিক উত্তরঃ'), findsOneWidget);
    });

    test('switching category tab clears selected month/date filter and old feed items', () async {
      final mockRepo = MockCurrentAffairsRepository();
      mockRepo.feedResponse = const CurrentAffairsFeedResponse(
        success: true,
        items: [],
      );

      final container = ProviderContainer(
        overrides: [
          currentAffairsRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      final notifier = container.read(currentAffairsHubNotifierProvider.notifier);
      await notifier.init();

      // User selects a month on bangladesh tab
      notifier.setMonthFilter('2026-10');
      expect(container.read(currentAffairsHubNotifierProvider).selectedMonth, '2026-10');

      // User switches to international tab
      notifier.setCategoryType('international');

      final state = container.read(currentAffairsHubNotifierProvider);
      expect(state.activeType, 'international');
      // Month and date filters should be cleared on tab switch
      expect(state.selectedMonth, isNull);
      expect(state.selectedDate, isNull);
    });

    testWidgets('CurrentAffairsQuestionCard explanation is collapsed initially and expands on tap for package holder', (tester) async {
      havePackage.value = true;
      addTearDown(() => havePackage.value = false);

      final item = const CurrentAffairsFeedItem(
        id: 202,
        title: 'কোন তারিখে রোকেয়া সাখাওয়াত হোসেনের মৃত্যু দিবস?',
        answer: '৯ ডিসেম্বর',
        explanation: 'রোকেয়া সাখাওয়াত হোসেন ১৮৮০ সালের ৯ ডিসেম্বর জন্মগ্রহণ করেন এবং ১৯৩২ সালের ৯ ডিসেম্বর মৃত্যুবরণ করেন।',
        reference: 'দৈনিক ইত্তেফাক',
        options: [
          CurrentAffairsOptionItem(key: 'A', labelBn: 'ক', value: '৯ ডিসেম্বর', isCorrect: true),
        ],
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: CurrentAffairsQuestionCard(item: item),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // "ব্যাখ্যা দেখুন" button is visible initially
      expect(find.text('ব্যাখ্যা দেখুন'), findsOneWidget);
      // Explanation text is NOT visible initially
      expect(find.text('ব্যাখ্যা:'), findsNothing);
      expect(find.textContaining('রোকেয়া সাখাওয়াত হোসেন ১৮৮০ সালের ৯ ডিসেম্বর'), findsNothing);

      // Tap on "ব্যাখ্যা দেখুন"
      await tester.tap(find.text('ব্যাখ্যা দেখুন'));
      await tester.pumpAndSettle();

      // Explanation is now expanded!
      expect(find.text('ব্যাখ্যা লুকান'), findsOneWidget);
      expect(find.text('ব্যাখ্যা:'), findsOneWidget);
      expect(find.textContaining('রোকেয়া সাখাওয়াত হোসেন ১৮৮০ সালের ৯ ডিসেম্বর'), findsOneWidget);

      // Tap on "ব্যাখ্যা লুকান" to collapse
      await tester.tap(find.text('ব্যাখ্যা লুকান'));
      await tester.pumpAndSettle();

      // Explanation is collapsed again
      expect(find.text('ব্যাখ্যা দেখুন'), findsOneWidget);
      expect(find.text('ব্যাখ্যা:'), findsNothing);
    });

    testWidgets('CurrentAffairsQuestionCard tapping explanation without package shows PackageRequiredPopup', (tester) async {
      havePackage.value = false;

      final item = const CurrentAffairsFeedItem(
        id: 203,
        title: 'কোন তারিখে রোকেয়া সাখাওয়াত হোসেনের মৃত্যু দিবস?',
        answer: '৯ ডিসেম্বর',
        explanation: 'রোকেয়া সাখাওয়াত হোসেন ১৮৮০ সালের ৯ ডিসেম্বর জন্মগ্রহণ করেন এবং ১৯৩২ সালের ৯ ডিসেম্বর মৃত্যুবরণ করেন।',
        options: [
          CurrentAffairsOptionItem(key: 'A', labelBn: 'ক', value: '৯ ডিসেম্বর', isCorrect: true),
        ],
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: CurrentAffairsQuestionCard(item: item),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ব্যাখ্যা দেখুন'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);

      await tester.tap(find.text('ব্যাখ্যা দেখুন'));
      await tester.pumpAndSettle();

      // Explanation text is NOT expanded
      expect(find.text('ব্যাখ্যা:'), findsNothing);
      // PackageRequiredPopup dialog is shown!
      expect(find.byType(PackageRequiredPopup), findsOneWidget);
      expect(find.text('প্রিমিয়াম মেম্বারশিপ প্রয়োজন'), findsOneWidget);
      expect(find.text('প্যাকেজ নিন'), findsOneWidget);
    });
  });
}
