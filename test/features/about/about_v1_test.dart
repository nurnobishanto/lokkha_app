import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/di/about_provider.dart';
import 'package:lokkha/features/about/about.dart';
import 'package:lokkha/shared/widgets/custom_drawer.dart';

class _MockAboutRepository implements AboutRepository {
  AboutDataModel? dataToReturn;
  bool shouldThrow = false;

  _MockAboutRepository({this.dataToReturn, this.shouldThrow = false});

  @override
  Future<AboutDataModel> getAboutData() async {
    if (shouldThrow) {
      throw Exception('Network connection failed');
    }
    return dataToReturn ?? AboutDataModel();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleAboutJson = {
    "success": true,
    "message": "About page content retrieved successfully.",
    "data": {
      "seo": {
        "title": "আমাদের সম্পর্কে - লক্ষ্য",
        "description": "লক্ষ্য প্ল্যাটফর্ম",
        "keywords": ["লক্ষ্য", "বিসিএস"]
      },
      "hero": {
        "tagline": "লক্ষ্য · সঠিক পথে, স্বল্প সময়ে",
        "heading": "লক্ষ্য সম্পর্কে জানুন",
        "subheading": "সঠিক দিকনির্দেশনা ও প্রযুক্তির মেলবন্ধনে",
        "description_1": "লক্ষ্য একটি নির্ভরযোগ্য অনলাইন এক্সাম প্ল্যাটফর্ম।",
        "description_2": "আমরা শিক্ষার্থীদের সর্বোচ্চ সাফল্য অর্জনে সাহায্য করি।",
        "image_url": "",
        "features": [
          "সারাদেশের শিক্ষার্থীদের সাথে লাইভ মেধা তালিকা",
          "বিগত সালের প্রশ্নব্যাংক ও নির্ভুল ব্যাখ্যা"
        ],
        "floating_badges": {
          "top": {
            "title": "৯৮% সন্তুষ্টির হার",
            "subtitle": "বিশ্বস্ত প্ল্যাটফর্ম",
            "icon": "star"
          },
          "bottom": {
            "number": "৫০,০০০+",
            "label": "সফল শিক্ষার্থী",
            "icon": "school"
          }
        }
      },
      "metrics": null, // Testing fallback to the 4 impact counters
      "pillars": {
        "section_title": "আমরা যেভাবে আপনার স্বপ্ন বাস্তবায়নে পাশে থাকি",
        "section_subtitle": "লক্ষ্য কেবল একটি প্ল্যাটফর্ম নয়",
        "items": [
          {
            "id": "mission",
            "title": "আমাদের মিশন",
            "description": "সাশ্রয়ী মূল্যে সর্বোচ্চ মানের প্রশ্ন পৌঁছে দেওয়া।",
            "icon": "track_changes",
            "theme": "emerald"
          },
          {
            "id": "vision",
            "title": "আমাদের ভিশন",
            "description": "ক্যারিয়ার প্রতিযোগিতার প্রস্তুতিকে সহজ করা।",
            "icon": "lightbulb",
            "theme": "amber"
          }
        ]
      },
      "app_showcase": {
        "heading": "মোবাইলেই সেরা ক্যারিয়ার প্রস্তুতি",
        "subheading": "যেকোনো সময়ে অনুশীলন করুন",
        "image_url": "",
        "download_url": "https://play.google.com/store/apps/details?id=com.techyfo.lokkha",
        "features": [
          {
            "title": "লাইভ এক্সাম অ্যালার্ট",
            "description": "পুশ নোটিফিকেশন অ্যালার্ট।",
            "icon": "notifications_active"
          }
        ]
      },
      "community_and_support": {
        "helpline": {
          "heading": "যেকোনো প্রয়োজনে কল করুন এখনই",
          "subheading": "আমাদের হেল্পলাইনে যোগাযোগ করুন।",
          "active_hours": "সকাল ৯ টা - রাত ১০ টা",
          "primary_phone": "(+880) 1334-260543",
          "phones": ["(+880) 1334-260543"],
          "primary_email": "support@lokkha.com",
          "emails": ["support@lokkha.com"],
          "address": "মিরপুর ১, ঢাকা - ১২১৬"
        },
        "social_channels": {
          "facebook_page": {
            "title": "ফেসবুক পেজ",
            "subtitle": "আপডেট ও নোটিস",
            "url": "https://www.facebook.com/lokkhabd"
          },
          "youtube": {
            "title": "ইউটিউব",
            "subtitle": "ফ্রি ক্লাস",
            "url": "https://www.youtube.com/@lokkhabd"
          }
        }
      },
      "testimonials": {
        "heading": "শিক্ষার্থীদের অভিজ্ঞতা ও মতামত",
        "subheading": "সফল শিক্ষার্থীদের সত্য গল্প।",
        "video_testimonials": [
          {
            "id": 1,
            "type": "video",
            "name": "রাকিব হাসান",
            "designation": "Student",
            "rating": 5,
            "avatar_url": "",
            "video_url": "https://www.youtube.com/watch?v=crXDg2-tOFc",
            "youtube_id": "crXDg2-tOFc"
          }
        ]
      },
      "cta": {
        "heading": "আজই শুরু করুন আপনার সফল ক্যারিয়ার যাত্রা!",
        "subheading": "হাজারো সফল শিক্ষার্থীর কাতারে যুক্ত হন।",
        "button_primary": {
          "text": "কোর্স ও পরীক্ষা ব্রাউজ করুন",
          "url": "/exam"
        },
        "button_secondary": {
          "text": "ফ্রি অ্যাকাউন্ট খুলুন",
          "url": "/register"
        }
      }
    }
  };

  group('AboutModel Parsing Tests', () {
    test('Parses full about response successfully with all sections', () {
      final model = AboutResponseModel.fromJson(sampleAboutJson);
      expect(model.success, isTrue);
      expect(model.data, isNotNull);

      final data = model.data!;
      // Section 1: Hero
      expect(data.hero?.heading, 'লক্ষ্য সম্পর্কে জানুন');
      expect(data.hero?.tagline, 'লক্ষ্য · সঠিক পথে, স্বল্প সময়ে');
      expect(data.hero?.features.length, 2);
      expect(data.hero?.floatingBadges?.top?.displayTitle, '৯৮% সন্তুষ্টির হার');
      expect(data.hero?.floatingBadges?.bottom?.displayTitle, '৫০,০০০+');

      // Section 2: Metrics (Default fallback to 4 impact counters)
      expect(data.metrics.length, 4);
      expect(data.metrics[0].title, 'মোট শিক্ষার্থী');
      expect(data.metrics[0].value, '৫০,০০০+');
      expect(data.metrics[2].title, 'সফলতার হার');
      expect(data.metrics[2].value, '৯৮%');

      // Section 3: Pillars
      expect(data.pillars?.items.length, 2);
      expect(data.pillars?.items[0].title, 'আমাদের মিশন');

      // Section 4: App Showcase
      expect(data.appShowcase?.heading, 'মোবাইলেই সেরা ক্যারিয়ার প্রস্তুতি');
      expect(data.appShowcase?.features.first.title, 'লাইভ এক্সাম অ্যালার্ট');

      // Section 5: Helpline & Social
      expect(data.communityAndSupport?.helpline?.primaryPhone, '(+880) 1334-260543');
      expect(data.communityAndSupport?.helpline?.primaryEmail, 'support@lokkha.com');
      expect(data.communityAndSupport?.socialChannels?.facebookPage?.title, 'ফেসবুক পেজ');

      // Section 6: Testimonials
      expect(data.testimonials?.videoTestimonials.length, 1);
      expect(data.testimonials?.videoTestimonials.first.name, 'রাকিব হাসান');

      // Section 7: CTA
      expect(data.cta?.heading, 'আজই শুরু করুন আপনার সফল ক্যারিয়ার যাত্রা!');
      expect(data.cta?.buttonPrimary?.text, 'কোর্স ও পরীক্ষা ব্রাউজ করুন');
    });
  });

  group('AboutNotifier & UseCase Tests', () {
    test('AboutNotifier loads data successfully', () async {
      final parsedData = AboutDataModel.fromJson(sampleAboutJson['data'] as Map<String, dynamic>);
      final mockRepo = _MockAboutRepository(dataToReturn: parsedData);
      final useCase = GetAboutContentUseCase(mockRepo);

      final container = ProviderContainer(
        overrides: [
          aboutRepositoryProvider.overrideWithValue(mockRepo),
          getAboutContentUseCaseProvider.overrideWithValue(useCase),
        ],
      );

      final notifier = container.read(aboutNotifierProvider.notifier);
      await notifier.fetchAboutData();

      final state = container.read(aboutNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.data?.hero?.heading, 'লক্ষ্য সম্পর্কে জানুন');
    });

    test('AboutNotifier handles error state properly', () async {
      final mockRepo = _MockAboutRepository(shouldThrow: true);
      final useCase = GetAboutContentUseCase(mockRepo);

      final container = ProviderContainer(
        overrides: [
          aboutRepositoryProvider.overrideWithValue(mockRepo),
          getAboutContentUseCaseProvider.overrideWithValue(useCase),
        ],
      );

      final notifier = container.read(aboutNotifierProvider.notifier);
      await notifier.fetchAboutData();

      final state = container.read(aboutNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, contains('Network connection failed'));
    });
  });

  group('AboutUsView Widget Tests', () {
    testWidgets('Renders all 7 dynamic sections in AboutUsView', (tester) async {
      final parsedData = AboutDataModel.fromJson(sampleAboutJson['data'] as Map<String, dynamic>);
      final mockRepo = _MockAboutRepository(dataToReturn: parsedData);
      final useCase = GetAboutContentUseCase(mockRepo);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aboutRepositoryProvider.overrideWithValue(mockRepo),
            getAboutContentUseCaseProvider.overrideWithValue(useCase),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) => const MaterialApp(
              home: AboutUsView(),
            ),
          ),
        ),
      );

      // Initial pumps to resolve microtask and async usecase
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify AppBar
      expect(find.text('আমাদের সম্পর্কে'), findsWidgets);

      // Verify Hero Section
      expect(find.text('লক্ষ্য সম্পর্কে জানুন'), findsOneWidget);

      // Scroll to Metrics Section
      await tester.scrollUntilVisible(
        find.text('আমাদের অর্জন ও প্রভাব'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('আমাদের অর্জন ও প্রভাব'), findsOneWidget);
      expect(find.text('মোট শিক্ষার্থী'), findsOneWidget);

      // Scroll to Pillars Section
      await tester.scrollUntilVisible(
        find.text('আমাদের মিশন'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('আমাদের মিশন'), findsOneWidget);

      // Scroll to App Showcase
      await tester.scrollUntilVisible(
        find.text('মোবাইলেই সেরা ক্যারিয়ার প্রস্তুতি'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('মোবাইলেই সেরা ক্যারিয়ার প্রস্তুতি'), findsOneWidget);

      // Scroll to Helpline & Support
      await tester.scrollUntilVisible(
        find.text('যোগাযোগ ও হেল্পলাইন'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('যোগাযোগ ও হেল্পলাইন'), findsOneWidget);

      // Scroll to CTA
      await tester.scrollUntilVisible(
        find.text('আজই শুরু করুন আপনার সফল ক্যারিয়ার যাত্রা!'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('আজই শুরু করুন আপনার সফল ক্যারিয়ার যাত্রা!'), findsOneWidget);
    });
  });

  group('CustomDrawer Widget Tests', () {
    testWidgets('CustomDrawer renders modern layout and contains About Us', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) => const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: CustomDrawer(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Header
      expect(find.text('লক্ষ্য'), findsWidgets);
      expect(find.text('সঠিক পথে, স্বল্প সময়ে'), findsOneWidget);

      // Scroll to and verify Drawer content
      await tester.scrollUntilVisible(find.text('আমাদের সম্পর্কে'), 100);
      expect(find.text('আমাদের সম্পর্কে'), findsOneWidget);
      expect(find.text('কাস্টমার সাপোর্ট'), findsOneWidget);
      expect(find.text('শেয়ার করুন'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('প্রাইভেসি পলিসি'), 100);
      expect(find.text('প্রাইভেসি পলিসি'), findsOneWidget);
      expect(find.text('টার্মস এন্ড কন্ডিশন'), findsOneWidget);
    });
  });
}
