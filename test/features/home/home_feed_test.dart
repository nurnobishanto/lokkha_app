import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/di/home_provider.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/home/domain/repositories/home_repository.dart';
import 'package:lokkha/features/home/domain/usecases/get_home_feed_usecase.dart';
import 'package:lokkha/features/home/presentation/home/components/home_categories_section.dart';
import 'package:lokkha/features/home/presentation/home/components/home_courses_section.dart';
import 'package:lokkha/features/home/presentation/home/components/home_mcq_section.dart';
import 'package:lokkha/features/home/presentation/home/components/home_notice_ticker.dart';
import 'package:lokkha/features/home/presentation/home/components/home_pro_leaderboard_section.dart';
import 'package:lokkha/features/home/presentation/home/components/home_quick_links_section.dart';
import 'package:lokkha/features/home/presentation/home/components/home_today_learning_section.dart';
import 'package:lokkha/features/home/presentation/home/components/home_top_actions_grid.dart';
import 'package:lokkha/features/home/presentation/home/riverpod/home_feed_notifier.dart';

class _MockHomeRepository implements HomeRepository {
  bool shouldSucceed = true;
  String? lastSections;
  String? lastSliderType;

  final HomeFeedModel mockFeed = HomeFeedModel(
    success: true,
    message: 'Home feed data retrieved successfully.',
    data: HomeFeedData(
      appMeta: AppMetaModel(
        appName: 'Lokkha',
        appTagline: 'সঠিক পথে, স্বল্প সময়ে',
        webUrl: 'https://lokkha.com',
      ),
      userContext: UserContextModel(
        isAuthenticated: true,
        userId: 105,
        name: 'Mahmudur Rahman',
        hasActivePackage: true,
      ),
      sliders: [
        HomeSliderItem(
          id: 18,
          type: 'app',
          imageUrl: 'https://lokkha.com/uploads/sliders/slider_1.jpg',
          sorting: 1,
        ),
      ],
      stats: HomeStatsModel(
        highlights: [
          HomeStatHighlight(
            key: 'students',
            countFormatted: '১০ হাজার+',
            label: 'আমাদের সন্তুষ্ট ছাত্র',
            icon: 'users',
          ),
          HomeStatHighlight(
            key: 'mentors',
            countFormatted: '12 জন+',
            label: 'অভিজ্ঞ মেন্টর',
            icon: 'teacher',
          ),
        ],
      ),
      contestHub: HomeContestHubModel(
        activeContest: HomeActiveContest(
          id: 54,
          name: '৪৬তম বিসিএস স্পেশাল মেগা লাইভ কনটেস্ট',
          slug: '46th-bcs-special-mega-live-contest',
          durationMinutes: 60,
          countdownSeconds: 3600,
          prizeDetails: '১ম পুরস্কার: ১০,০০০ টাকা',
          isLive: false,
          isUpcoming: true,
        ),
        lastContestName: '৪৪তম বিসিএস মেগা কনটেস্ট',
        topLeaderboard: [
          HomeLeaderboardUser(
            rank: 1,
            userId: 89,
            userName: 'সাকিব',
            totalMarks: 564.0,
          ),
        ],
      ),
      courseCategories: [
        HomeCourseCategoryItem(
          id: 1,
          title: 'বিসিএস প্রিলিমিনারি পূর্ণাঙ্গ কোর্স',
          slug: 'bcs-preliminary',
          coursesCount: 12,
        ),
      ],
      examCategories: [
        HomeExamCategoryItem(
          id: 1,
          name: 'বিসিএস প্রস্তুতি',
          slug: 'bcs-preparation',
          examsCount: 45,
        ),
      ],
      careerAndUpdates: HomeCareerUpdatesModel(
        jobSectors: [
          HomeJobSectorItem(
            id: 'ministry',
            title: 'মন্ত্রণালয় ও সরকারি অধিদপ্তর',
            badgeColor: 'blue',
          ),
        ],
        latestJobs: [
          HomeLatestJobItem(
            id: 12,
            title: 'বাংলাদেশ ব্যাংক সহকারী পরিচালক',
            slug: 'bangladesh-bank-ad',
            deadlineBn: '১৫/১১/২০২৬',
          ),
        ],
        latestExams: [
          HomeLatestExamItem(
            id: 18,
            title: '৪৫তম বিসিএস প্রিলিমিনারি সমাধান',
            dateBn: '১৯/০৫/২০২৬',
          ),
        ],
        noticeTicker:
            'নতুন সার্কুলার প্রকাশের সাথে সাথেই নোটিফিকেশন পেতে অ্যাপে যুক্ত থাকুন।',
      ),
      currentAffairs: HomeCurrentAffairsModel(
        nationalItems: [
          HomeCurrentAffairItem(
            id: 101,
            question: 'গ্রুপ এর পূর্ণরূপ কী?',
            option1: 'A) দুর্নীতি দমন কমিশন',
            option2: 'B) দুর্নীতি উদ্ধার সেল',
            option3: 'C) দুর্নীতি দমন কমিটি',
            option4: 'D) দুর্যোগ দমন কমিশন',
            rightAnswer: 1,
            explanation: 'বাংলাদেশ পরিসংখ্যান ব্যুরোর সর্বশেষ তথ্য অনুযায়ী।',
            dateBn: '০১/১০/২০২৬',
          ),
        ],
      ),
      vocabulary: HomeVocabularyModel(
        items: [
          HomeVocabularyItem(
            id: 1,
            word: 'Abundant',
            details: 'বিদ্যমান বা প্রচুর পরিমাণে উপলব্ধ',
            synonyms: 'plentiful, copious',
            antonyms: 'scarce, rare',
            type: 'adjective',
            category: 'BCS',
          ),
        ],
      ),
      questionBanks: HomeQuestionBanksModel(
        popularBanks: [
          HomeQuestionBankItem(
            id: 1,
            title: 'বিসিএস প্রিলিমিনারি বিগত বছরের প্রশ্ন',
            questionCountFormatted: '৪,২০০টি প্রশ্ন',
            badge: '১০ম-৪৬তম',
          ),
        ],
      ),
      packages: [
        HomePackageItem(
          id: 1,
          name: 'অল-ইন-ওয়ান মেগা বান্ডেল',
          slug: 'all-in-one-mega-bundle',
          regularPrice: 2500,
          discountedPrice: 1499,
          durationLabel: '১ বছর',
          isPopular: true,
          features: ['সকল লাইভ পরীক্ষা', '২৪/৭ সাপোর্ট'],
        ),
      ],
      hallOfFame: [
        HomeHallOfFameItem(
          id: 1,
          name: 'সাবরিনা আক্তার',
          designation: 'সহকারী কমিশনার (প্রশাসন)',
          rating: 5.0,
          reviewText: 'লক্ষ অ্যাপের নিয়মিত প্রস্তুতি আমার যাত্রা সহজ করেছে।',
        ),
      ],
      keyFeatures: HomeKeyFeaturesModel(
        heading: 'কেন লক্ষ অ্যাপ সেরা?',
        items: [
          HomeKeyFeatureItem(
            id: 1,
            numberBadge: '০১',
            title: 'স্মার্ট এক্সাম সিস্টেম',
            desc: 'বাস্তব পরীক্ষার অভিজ্ঞতা',
          ),
        ],
      ),
      communitySupport: HomeCommunitySupportModel(
        sectionTitle: 'সাপোর্ট এবং কমিউনিটি',
        hotlinePhonePrimary: '+8801332804290',
        officeHours: 'সকাল ৯টা - রাত ১০টা',
      ),
    ),
  );

  @override
  Future<HomeFeedModel> getHomeFeed({
    String sections = 'all',
    String sliderType = 'app',
  }) async {
    lastSections = sections;
    lastSliderType = sliderType;
    if (shouldSucceed) {
      return mockFeed;
    }
    return HomeFeedModel(
      success: false,
      message: 'Failed to fetch home feed.',
    );
  }

  @override
  Future<HomeContestHubModel?> getContests() async => mockFeed.data?.contestHub;

  @override
  Future<HomeQuestionBanksModel?> getQuestionBanks() async =>
      mockFeed.data?.questionBanks;

  @override
  Future<HomeCareerUpdatesModel?> getJobsExams() async =>
      mockFeed.data?.careerAndUpdates;

  @override
  Future<HomeStatsModel?> getStats() async => mockFeed.data?.stats;

  @override
  Future<HomeVocabularyModel?> getVocabulary() async =>
      mockFeed.data?.vocabulary;

  @override
  Future<List<HomeHallOfFameItem>> getTestimonials() async =>
      mockFeed.data?.hallOfFame ?? const [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Module 23: Home Feed Model Serialization & Domain', () {
    test('HomeFeedModel parses all 14 sections correctly from JSON', () {
      final sampleJson = {
        'success': true,
        'message': 'Home feed retrieved successfully.',
        'data': {
          'app_meta': {
            'app_name': 'Lokkha',
            'app_tagline': 'সঠিক পথে, স্বল্প সময়ে',
          },
          'user_context': {
            'is_authenticated': true,
            'user_id': 42,
            'name': 'Test User',
            'has_active_package': true,
          },
          'sliders': [
            {
              'id': 10,
              'type': 'app',
              'image_url': 'https://lokkha.com/uploads/sliders/sample.jpg',
            }
          ],
          'stats': {
            'highlights': [
              {
                'key': 'students',
                'count_formatted': '১০ হাজার+',
                'label': 'শিক্ষার্থী',
                'icon': 'users',
              }
            ],
          },
          'contest_hub': {
            'active_contest': {
              'id': 1,
              'name': 'বিসিএস মেগা কনটেস্ট',
              'countdown_seconds': 120,
              'duration_minutes': 60,
              'is_live': false,
              'is_upcoming': true,
            },
            'top_leaderboard': [
              {
                'rank': 1,
                'user_id': 1,
                'user_name': 'র‍্যাংক ১',
                'total_marks': 95.0,
              }
            ],
          },
          'course_categories': [
            {'id': 1, 'title': 'বিসিএস', 'courses_count': 5}
          ],
          'exam_categories': [
            {'id': 1, 'name': 'বিসিএস', 'exams_count': 10}
          ],
          'career_and_updates': {
            'notice_ticker': 'নতুন সার্কুলার প্রকাশিত হয়েছে',
            'latest_jobs': [
              {'id': 1, 'title': 'সহকারী পরিচালক', 'slug': 'ad-job'}
            ],
          },
          'current_affairs': {
            'national_items': [
              {'id': 1, 'question': 'প্রশ্ন ১', 'date_bn': '০১/১০/২০২৬'}
            ],
          },
          'vocabulary': {
            'items': [
              {
                'id': 1,
                'word': 'Fast',
                'details': 'দ্রুত',
                'synonyms': ['quick', 'rapid'],
                'antonyms': ['slow'],
              }
            ],
          },
          'question_banks': {
            'popular_banks': [
              {'id': 1, 'title': '১০ম-৪৬তম বিসিএস'}
            ],
          },
          'packages': [
            {
              'id': 1,
              'name': 'প্রিমিয়াম প্যাকেজ',
              'slug': 'premium',
              'regular_price': 1000,
              'discounted_price': 500,
              'duration_label': '১ বছর',
              'features': ['ফিচার ১', 'ফিচার ২'],
            }
          ],
          'hall_of_fame': [
            {
              'id': 1,
              'name': 'আহমেদ',
              'rating': 5.0,
              'review_text': 'দারুণ অ্যাপ',
            }
          ],
          'key_features': {
            'heading': 'ফিচার',
            'items': [
              {
                'id': 1,
                'number_badge': '১',
                'title': 'স্মার্ট এক্সাম',
                'desc': 'বিবরণ'
              }
            ],
          },
          'community_support': {
            'hotline_phone_primary': '+8801700000000',
            'whatsapp_chat_url': 'https://wa.me/8801700000000',
          },
        },
      };

      final model = HomeFeedModel.fromJson(sampleJson);

      expect(model.success, isTrue);
      expect(model.data, isNotNull);
      expect(model.data!.appMeta?.appName, 'Lokkha');
      expect(model.data!.userContext?.isAuthenticated, isTrue);
      expect(model.data!.sliders.length, 1);
      expect(model.data!.stats?.highlights.length, 1);
      expect(model.data!.contestHub?.activeContest?.name, 'বিসিএস মেগা কনটেস্ট');
      expect(model.data!.courseCategories.first.title, 'বিসিএস');
      expect(model.data!.examCategories.first.name, 'বিসিএস');
      expect(model.data!.careerAndUpdates?.noticeTicker,
          'নতুন সার্কুলার প্রকাশিত হয়েছে');
      expect(
          model.data!.currentAffairs?.nationalItems.first.question, 'প্রশ্ন ১');
      expect(model.data!.vocabulary?.items.first.word, 'Fast');
      expect(model.data!.vocabulary?.items.first.synonyms, 'quick, rapid');
      expect(model.data!.questionBanks?.popularBanks.first.title, '১০ম-৪৬তম বিসিএস');
      expect(model.data!.packages.first.discountedPrice, 500.0);
      expect(model.data!.hallOfFame.first.name, 'আহমেদ');
      expect(model.data!.keyFeatures?.items.first.title, 'স্মার্ট এক্সাম');
      expect(
          model.data!.communitySupport?.hotlinePhonePrimary, '+8801700000000');
    });

    test('HomeFeedModel parses Module 23 official API sample response correctly', () {
      final module23Json = {
        'success': true,
        'message': 'Home feed data retrieved successfully.',
        'data': {
          'app_meta': {
            'app_name': 'Lokkha',
            'app_tagline': 'সঠিক পথে, স্বল্প সময়ে',
            'app_description': 'ঘরে বসে চাকরির প্রস্তুতির অনলাইন প্ল্যাটফর্ম',
            'play_store_url': 'https://play.google.com/store/apps/details?id=com.techyfo.lokkha',
            'apple_store_url': 'https://apps.apple.com/app/lokkha/id6739908123',
            'web_url': 'https://lokkha.com',
            'api_version': 'v1',
            'response_time': '2026-10-13 18:50:00',
          },
          'user_context': {
            'is_authenticated': true,
            'user_id': 105,
            'name': 'Mahmudur Rahman',
            'phone': '01712345678',
            'avatar': 'https://lokkha.com/uploads/users/avatar.jpg',
            'has_active_package': true,
          },
          'sliders': [
            {
              'id': 18,
              'type': 'app',
              'image_url': 'https://lokkha.com/uploads/sliders/slider_1788083003_XLKO9m.jpg',
              'image_sm_url': 'https://lokkha.com/uploads/sliders/slider_sm_1788072833_FmM4DE.webp',
              'link': null,
              'navigation': {'page': 'packages', 'params': null, 'has_action': true},
              'sorting': 1,
            }
          ],
          'stats': {
            'highlights': [
              {'key': 'students', 'count': 10000, 'count_formatted': '১০ হাজার+', 'label': 'আমাদের সন্তুষ্ট ছাত্র', 'icon': 'users'},
              {'key': 'mentors', 'count': 12, 'count_formatted': '12 জন+', 'label': 'অভিজ্ঞ মেন্টর', 'icon': 'teacher'},
            ],
            'database_counts': {
              'total_mcq_questions': 22450,
              'total_mcq_formatted': '২২,৪৫০+',
              'total_exams': 520,
              'total_exams_formatted': '৫২০+',
            },
            'visitor_stats': {
              'today': 1420,
              'today_formatted': '১,৪২০',
              'yesterday': 1890,
              'yesterday_formatted': '১,৮৯০',
              'total': 542000,
              'total_formatted': '৫,৪২,০০০',
            },
          },
          'contest_hub': {
            'active_contest': {
              'id': 54,
              'name': '৪৬তম বিসিএস স্পেশাল মেগা লাইভ কনটেস্ট',
              'slug': '46th-bcs-special-mega-live-contest',
              'duration_minutes': 60,
              'status': 'upcoming',
              'is_live': false,
              'is_upcoming': true,
              'countdown_seconds': 172800,
              'prize_details': '১ম পুরস্কার: ১০,০০০ টাকা + ১ বছরের প্রিমিয়াম প্যাকেজ',
            },
            'last_contest_id': 53,
            'last_contest_name': '৪৪তম বিসিএস সাধারণ জ্ঞান মেগা কনটেস্ট',
            'leaderboard_count': 10,
            'top_leaderboard': [
              {
                'rank': 1,
                'user_id': 89,
                'user_name': 'তানভীর আহমেদ',
                'user_phone_masked': '017****5678',
                'correct_answers': 94,
                'total_marks': 92.0,
                'complete_duration_seconds': 2140,
              }
            ],
          },
          'career_and_updates': {
            'job_sectors': [
              {'id': 'ministry', 'title': 'মন্ত্রণালয় ও সরকারি অধিদপ্তর', 'icon': 'building', 'badge_color': 'blue'},
            ],
            'latest_jobs': [
              {
                'id': 12,
                'title': 'বাংলাদেশ ব্যাংক সহকারী পরিচালক (সাধারণ)',
                'slug': 'bangladesh-bank-ad-general-2026',
                'is_featured': true,
                'is_expired': false,
              }
            ],
            'latest_exams': [
              {
                'id': 18,
                'title': '৪৫তম বিসিএস প্রিলিমিনারি প্রশ্ন সমাধান',
                'questions_count': 200,
              }
            ],
            'notice_ticker': 'নতুন সার্কুলার প্রকাশের সাথে সাথেই সরাসরি আবেদন লিঙ্ক ও বিগত প্রশ্ন সমাধানসহ আপডেট করা হয়।',
          },
          'current_affairs': {
            'national_items': [
              {
                'id': 4521,
                'question': 'বাংলাদেশের বর্তমান জাতীয় সংসদ নির্বাচন পদ্ধতি কোন অনুচ্ছেদে বর্ণিত?',
                'options': {
                  'option_1': 'অনুচ্ছেদ ১১৮',
                  'option_2': 'অনুচ্ছেদ ১২১',
                  'option_3': 'অনুচ্ছেদ ৬৫',
                  'option_4': 'অনুচ্ছেদ ১২৪',
                },
                'right_answer': 'option_3',
                'explanation': 'সংবিধানের ৬৫ অনুচ্ছেদ অনুযায়ী জাতীয় সংসদ গঠিত হয়।',
              }
            ],
            'international_items': [],
          },
          'vocabulary': {
            'types': [{'id': 1, 'name': 'Noun'}, {'id': 2, 'name': 'Adjective'}],
            'categories': [{'id': 1, 'name': 'BCS Important'}],
            'alphabets': ['A', 'B', 'C'],
            'items': [
              {
                'id': 102,
                'word': 'Benevolent',
                'details': 'দয়ালু, পরোপকারী (Kind and well-meaning)',
                'synonyms': ['Kind', 'Generous'],
                'antonyms': ['Malevolent'],
                'type': 'Adjective',
                'category': 'BCS Important',
              }
            ],
          },
          'question_banks': {
            'popular_banks': [
              {'id': 2, 'title': 'বিসিএস প্রিলিমিনারি', 'badge': '১০ম-৪৬তম', 'theme_color': 'emerald', 'icon': 'bank', 'action': 'subject_exam'},
            ],
            'subject_wise_banks': [
              {'id': 1, 'name': 'বাংলা ভাষা ও সাহিত্য', 'slug': 'bangla-language-literature', 'question_count': 3450},
            ],
          },
          'packages': [
            {
              'id': 1,
              'name': '3-মাসিক প্রিমিয়াম প্যাকেজ',
              'regular_price': 399.0,
              'discounted_price': 299.0,
              'duration_label': '3 মাস',
              'features': [{'text': 'Live Exam', 'included': true}],
            }
          ],
          'hall_of_fame': [
            {
              'id': 3,
              'name': 'মেহেদী হাসান',
              'designation': 'সহকারী কমিশনার (প্রশাসন)',
              'rating': 5,
              'youtube_id': 'dQw4w9WgXcQ',
            }
          ],
          'key_features': [
            {'id': 1, 'number_badge': '১', 'title': '২২০০০+ প্রশ্ন সম্ভার', 'desc': 'MCQ প্রশ্ন ব্যাংক'}
          ],
          'about_section': {
            'heading': 'Lokkha কী এবং কেন ব্যবহার করবেন?',
            'tagline': 'স্মার্ট প্রস্তুতি, নিশ্চিত চাকরি',
          },
          'community_support': {
            'hotline_phone_primary': '(+880) 1334-260543',
            'whatsapp_chat_url': 'https://wa.me/8801334260543',
          },
        },
        'meta': {
          'cached_at': '2026-10-13T18:50:00+06:00',
          'sections_delivered': ['all'],
          'requested_sections': 'all',
        },
      };

      final model = HomeFeedModel.fromJson(module23Json);
      expect(model.success, isTrue);
      expect(model.data?.appMeta?.appName, 'Lokkha');
      expect(model.data?.userContext?.name, 'Mahmudur Rahman');
      expect(model.data?.sliders.length, 1);
      expect(model.data?.contestHub?.activeContest?.durationMinutes, 60);
      expect(model.data?.contestHub?.topLeaderboard.first.userName, 'তানভীর আহমেদ');
      expect(model.data?.currentAffairs?.nationalItems.first.rightAnswer, 3);
      expect(model.data?.currentAffairs?.nationalItems.first.option3, 'অনুচ্ছেদ ৬৫');
      expect(model.data?.vocabulary?.types, contains('Noun'));
      expect(model.data?.vocabulary?.types, contains('Adjective'));
      expect(model.data?.vocabulary?.categories, contains('BCS Important'));
      expect(model.data?.vocabulary?.items.first.word, 'Benevolent');
      expect(model.data?.questionBanks?.popularBanks.first.title, 'বিসিএস প্রিলিমিনারি');
      expect(model.data?.hallOfFame.first.name, 'মেহেদী হাসান');
      expect(model.meta?.cachedAt, '2026-10-13T18:50:00+06:00');
    });

    test('GetHomeFeedUseCase delegates parameters to repository', () async {
      final mockRepo = _MockHomeRepository();
      final useCase = GetHomeFeedUseCase(mockRepo);

      final result =
          await useCase(sections: 'sliders,stats', sliderType: 'app');

      expect(result.success, isTrue);
      expect(mockRepo.lastSections, 'sliders,stats');
      expect(mockRepo.lastSliderType, 'app');
    });
  });

  group('Module 23: Riverpod HomeFeedNotifier State', () {
    test('fetchHomeFeed updates state and triggers countdown', () async {
      final mockRepo = _MockHomeRepository();
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(homeFeedNotifierProvider.notifier);

      expect(container.read(homeFeedNotifierProvider).isLoading, isFalse);
      expect(container.read(homeFeedNotifierProvider).hasData, isFalse);

      await notifier.fetchHomeFeed();

      final state = container.read(homeFeedNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.hasData, isTrue);
      expect(state.feed?.data?.appMeta?.appName, 'Lokkha');
      expect(state.contestCountdownSeconds, 3600);
      expect(state.contestCountdownParts.hours, 1);
    });

    test('fetchHomeFeed handles failure gracefully', () async {
      final mockRepo = _MockHomeRepository()..shouldSucceed = false;
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(homeFeedNotifierProvider.notifier);
      await notifier.fetchHomeFeed();

      final state = container.read(homeFeedNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.hasData, isFalse);
      expect(state.errorMessage, 'Failed to fetch home feed.');
    });
  });

  group('Module 23: Image 3 Redesigned Home UI Component Tests', () {
    setUp(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.physicalSize =
          const Size(390 * 3, 844 * 3);
      binding.platformDispatcher.views.first.devicePixelRatio = 3.0;
    });

    tearDown(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.resetPhysicalSize();
      binding.platformDispatcher.views.first.resetDevicePixelRatio();
    });

    Widget createWidgetForTesting(Widget child) {
      return ScreenUtilInit(
        designSize: const Size(360, 800),
        minTextAdapt: true,
        builder: (context, _) => ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: child,
              ),
            ),
          ),
        ),
      );
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

    testWidgets('HomeTopActionsGrid renders 6 action items correctly',
        (tester) async {
      await tester.pumpWidget(createWidgetForTesting(const HomeTopActionsGrid()));
      await tester.pumpAndSettle();

      expect(find.text('Vocabulary Game'), findsOneWidget);
      expect(find.text('GK'), findsOneWidget);
      expect(find.text('কুইক প্র্যাকটিস'), findsOneWidget);
      expect(find.text('ভিডিও ক্লাস'), findsOneWidget);
      expect(find.text('জনপ্রিয় প্রশ্নব্যাংক'), findsOneWidget);
      expect(find.text('চাকরি ও ক্যারিয়ার'), findsOneWidget);
    });

    testWidgets('HomeMcqSection renders question and options correctly',
        (tester) async {
      await tester.pumpWidget(createWidgetForTesting(const HomeMcqSection()));
      await tester.pumpAndSettle();

      expect(find.text('কারেন্ট অ্যাফেয়ার্স'), findsOneWidget);
      expect(find.text('MCQ'), findsOneWidget);
      expect(findTextOrRich('A) দুর্নীতি দমন কমিশন'), findsOneWidget);

      // Tap on an option
      await tester.tap(findTextOrRich('A) দুর্নীতি দমন কমিশন'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('HomeQuickLinksSection renders Quick Links with 10 links',
        (tester) async {
      await tester
          .pumpWidget(createWidgetForTesting(const HomeQuickLinksSection()));
      await tester.pumpAndSettle();

      expect(find.text('Quick Links'), findsOneWidget);
      expect(find.text('বিষয়ভিত্তিক পরীক্ষা'), findsOneWidget);
      expect(find.text('PDF Section'), findsOneWidget);
      expect(find.text('মডেল টেস্ট'), findsOneWidget);
      expect(find.text('Live Exam'), findsOneWidget);
      expect(find.text('সর্বশেষ নিয়োগ বিজ্ঞপ্তি'), findsOneWidget);
    });

    testWidgets('HomeTodayLearningSection renders stats and action buttons',
        (tester) async {
      await tester
          .pumpWidget(createWidgetForTesting(const HomeTodayLearningSection()));
      await tester.pumpAndSettle();

      expect(find.text("Today's Learning"), findsOneWidget);
      expect(find.text('Total Free Exams: 04 | Remaining: 10'), findsOneWidget);
      expect(find.text('প্র্যাকটিস কুইজ'), findsWidgets);
      expect(find.text('লাইভ পরীক্ষায় অংশ দিন'), findsWidgets);
    });

    testWidgets('HomeProLeaderboardSection renders Top Performers list',
        (tester) async {
      await tester
          .pumpWidget(createWidgetForTesting(const HomeProLeaderboardSection()));
      await tester.pumpAndSettle();

      expect(find.text('লিডারবোর্ড । প্রো লীগ'), findsOneWidget);
      expect(find.text('Top Performers'), findsOneWidget);
      expect(find.text('1.1k Users >'), findsOneWidget);
      expect(find.text('Tonmoy'), findsOneWidget);
      expect(find.text('Tamanna Akter'), findsOneWidget);
      expect(find.text('dider kanon'), findsOneWidget);
      expect(find.text('BillalvHosaain'), findsNothing);
      expect(find.text('লক্ষ্য'), findsNothing);
    });

    testWidgets('HomeCoursesSection renders our courses list and enroll button',
        (tester) async {
      await tester.pumpWidget(
          createWidgetForTesting(const HomeCoursesSection(courseCategories: [])));
      await tester.pumpAndSettle();

      expect(find.text('আমাদের কোর্সসমূহ'), findsOneWidget);
      expect(find.text('See All'), findsOneWidget);
      expect(find.text('ভর্তি হন'), findsWidgets);
    });

    testWidgets('HomeNoticeTicker renders announcement text', (tester) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          const HomeNoticeTicker(
              noticeText: 'বিশেষ নোটিশ: আজ লাইভ পরীক্ষা শুরু হবে'),
        ),
      );
      await tester.pump();

      expect(find.text('বিশেষ নোটিশ: আজ লাইভ পরীক্ষা শুরু হবে'), findsOneWidget);
      expect(find.text('নোটিশ'), findsOneWidget);
    });

    testWidgets('HomeCategoriesSection initially shows 4 categories and expands on সব দেখুন tap', (tester) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          HomeCategoriesSection(
            examCategories: HomeCategoriesSection.defaultExamCategories,
            courseCategories: HomeCategoriesSection.defaultCourseCategories,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Titles
      expect(find.text('ফ্রি পরীক্ষা সমূহ'), findsOneWidget);
      expect(find.text('প্রিমিয়াম পরীক্ষা সমূহ'), findsOneWidget);

      // Initially shows first 4 exam categories
      expect(find.text('১৯ তম শিক্ষক নিবন্ধন  ( স্কুল ও কলেজ)'), findsOneWidget);
      expect(find.text('৫১ তম BCS'), findsOneWidget);
      expect(find.text('Bank Preparation'), findsOneWidget);
      expect(find.text('প্রাইমারি  শিক্ষক নিয়োগ'), findsOneWidget);

      // 5th item should not be shown yet
      expect(find.text('৫০ তম  BCS'), findsNothing);

      // Tap 'সব দেখুন' for Free Exams to expand
      final seeAllButtons = find.text('সব দেখুন');
      expect(seeAllButtons, findsNWidgets(2)); // Free exams and courses
      await tester.tap(seeAllButtons.first);
      await tester.pumpAndSettle();

      // Now expanded: 5th item is visible, and toggle says 'কম দেখুন'
      expect(find.text('৫০ তম  BCS'), findsOneWidget);
      expect(find.text('কম দেখুন'), findsOneWidget);

      // Tap 'কম দেখুন' to collapse back to 4
      await tester.tap(find.text('কম দেখুন'));
      await tester.pumpAndSettle();

      // Collapsed: 5th item hidden again, toggle back to 'সব দেখুন'
      expect(find.text('৫০ তম  BCS'), findsNothing);
      expect(find.text('সব দেখুন'), findsNWidgets(2));
    });
  });
}
