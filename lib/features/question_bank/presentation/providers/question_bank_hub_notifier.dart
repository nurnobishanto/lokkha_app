import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/di/home_provider.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/home/domain/repositories/home_repository.dart';
import 'package:lokkha/features/home/presentation/home/riverpod/home_feed_notifier.dart';

class QuestionBankHubState {
  final List<HomeQuestionBankItem> popularBanks;
  final List<HomeQuestionBankItem> subjectBanks;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final String searchQuery;

  const QuestionBankHubState({
    this.popularBanks = const [],
    this.subjectBanks = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  QuestionBankHubState copyWith({
    List<HomeQuestionBankItem>? popularBanks,
    List<HomeQuestionBankItem>? subjectBanks,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    String? searchQuery,
  }) {
    return QuestionBankHubState(
      popularBanks: popularBanks ?? this.popularBanks,
      subjectBanks: subjectBanks ?? this.subjectBanks,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<HomeQuestionBankItem> get filteredPopularBanks {
    if (searchQuery.trim().isEmpty) return popularBanks;
    final q = searchQuery.trim().toLowerCase();
    return popularBanks.where((item) {
      return item.title.toLowerCase().contains(q) ||
          (item.subtitle?.toLowerCase().contains(q) ?? false) ||
          (item.badge?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  List<HomeQuestionBankItem> get filteredSubjectBanks {
    if (searchQuery.trim().isEmpty) return subjectBanks;
    final q = searchQuery.trim().toLowerCase();
    return subjectBanks.where((item) {
      return item.title.toLowerCase().contains(q) ||
          (item.slug?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
}

class QuestionBankHubNotifier extends Notifier<QuestionBankHubState> {
  HomeRepository get _repository => ref.read(homeRepositoryProvider);

  static final List<HomeQuestionBankItem> defaultPopularBanks = [
    HomeQuestionBankItem(
      id: 2,
      title: 'বিসিএস প্রিলিমিনারি',
      subtitle: '১০ম থেকে ৪৬তম বিসিএস বিগত সকল পরীক্ষার ব্যাখ্যাসহ প্রশ্নব্যাংক',
      badge: '১০ম-৪৬তম',
      themeColor: 'emerald',
      icon: 'bank',
      action: 'subject_exam',
      questionCount: 4200,
    ),
    HomeQuestionBankItem(
      id: 887,
      title: 'শিক্ষক নিবন্ধন (NTRCA)',
      subtitle: 'স্কুল ও কলেজ পর্যায়ের বিগত সকল নিবন্ধন পরীক্ষার নির্ভুল সমাধান',
      badge: '১ম-১৮তম',
      themeColor: 'sky',
      icon: 'award',
      action: 'subject_exam',
      questionCount: 2800,
    ),
    HomeQuestionBankItem(
      id: 902,
      title: 'প্রাথমিক সহকারী শিক্ষক নিয়োগ',
      subtitle: 'প্রাইমারি সহকারী শিক্ষক নিয়োগ প্রিলিমিনারি বিগত সকল ধাপের প্রশ্নব্যাংক',
      badge: 'প্রাইমারি স্পেশাল',
      themeColor: 'rose',
      icon: 'graduation-cap',
      action: 'subject_exam',
      questionCount: 3500,
    ),
    HomeQuestionBankItem(
      id: 3,
      title: 'সমন্বিত ব্যাংক নিয়োগ পরীক্ষা',
      subtitle: 'বাংলাদেশ ব্যাংক ও সরকারি ব্যাংকগুলোর বিগত অফিসার ও ক্যাশ প্রশ্নব্যাংক',
      badge: 'ব্যাংক স্পেশাল',
      themeColor: 'amber',
      icon: 'coins',
      action: 'subject_exam',
      questionCount: 3100,
    ),
  ];

  static final List<HomeQuestionBankItem> defaultSubjectBanks = [
    HomeQuestionBankItem(
      id: 1,
      title: 'বাংলা',
      slug: 'bangla',
      questionCount: 21464,
    ),
    HomeQuestionBankItem(
      id: 3,
      title: 'English Language',
      slug: 'english-language',
      questionCount: 16908,
    ),
    HomeQuestionBankItem(
      id: 4,
      title: 'English Literature',
      slug: 'english-literature',
      questionCount: 2312,
    ),
    HomeQuestionBankItem(
      id: 11,
      title: 'গাণিতিক যুক্তি',
      slug: 'ganitik-zukti',
      questionCount: 5021,
    ),
    HomeQuestionBankItem(
      id: 10,
      title: 'মানসিক দক্ষতা',
      slug: 'mansik-dkshta',
      questionCount: 259,
    ),
    HomeQuestionBankItem(
      id: 5,
      title: 'বাংলাদেশ বিষয়াবলী',
      slug: 'clman-bishyablee',
      questionCount: 10595,
    ),
    HomeQuestionBankItem(
      id: 8,
      title: 'আন্তর্জাতিক বিষয়াবলী',
      slug: 'antrjatik-bishyablee',
      questionCount: 11953,
    ),
    HomeQuestionBankItem(
      id: 14,
      title: 'কম্পিউটার ও তথ্য প্রযুক্তি',
      slug: 'kmpiutar-oo-tthz-przukti',
      questionCount: 3361,
    ),
    HomeQuestionBankItem(
      id: 12,
      title: 'সাধারণ বিজ্ঞান',
      slug: 'sadharn-bijngan',
      questionCount: 4299,
    ),
    HomeQuestionBankItem(
      id: 9,
      title: 'ভূগোল',
      slug: 'vuugol',
      questionCount: 1236,
    ),
    HomeQuestionBankItem(
      id: 13,
      title: 'নৈতিকতা, মূল্যবোধ ও সু-শাসন',
      slug: 'noitikta-muulzbodh-oo-su-sasn',
      questionCount: 164,
    ),
    HomeQuestionBankItem(
      id: 495,
      title: 'কমন টপিক For All',
      slug: 'kmn-tpik-for-all',
      questionCount: 16,
    ),
    HomeQuestionBankItem(
      id: 506,
      title: 'টেকনিক্যাল বিষয়সমূহ',
      slug: 'teknikzal-bishysmuuh',
      questionCount: 3,
    ),
  ];

  @override
  QuestionBankHubState build() {
    // Initial check from HomeFeed cache
    final homeState = ref.watch(homeFeedNotifierProvider);
    final cachedQBanks = homeState.data?.questionBanks;

    final initialPopular = (cachedQBanks?.popularBanks.isNotEmpty == true)
        ? cachedQBanks!.popularBanks
        : defaultPopularBanks;

    final initialSubjects = (cachedQBanks?.subjectWiseBanks.isNotEmpty == true)
        ? cachedQBanks!.subjectWiseBanks
        : defaultSubjectBanks;

    return QuestionBankHubState(
      popularBanks: initialPopular,
      subjectBanks: initialSubjects,
      isLoading: false,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> fetchQuestionBanks({bool isRefresh = false}) async {
    state = state.copyWith(
      isLoading: !isRefresh && state.popularBanks.isEmpty,
      isRefreshing: isRefresh,
    );

    try {
      final result = await _repository.getQuestionBanks();
      if (result != null &&
          (result.popularBanks.isNotEmpty || result.subjectWiseBanks.isNotEmpty)) {
        state = state.copyWith(
          popularBanks: result.popularBanks.isNotEmpty
              ? result.popularBanks
              : state.popularBanks,
          subjectBanks: result.subjectWiseBanks.isNotEmpty
              ? result.subjectWiseBanks
              : state.subjectBanks,
          isLoading: false,
          isRefreshing: false,
        );
      } else {
        state = state.copyWith(isLoading: false, isRefreshing: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final questionBankHubNotifierProvider =
    NotifierProvider<QuestionBankHubNotifier, QuestionBankHubState>(
  QuestionBankHubNotifier.new,
);
