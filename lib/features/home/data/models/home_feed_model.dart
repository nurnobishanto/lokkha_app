import 'package:lokkha/core/network/endpoints.dart';

/// Root model for Home Feed response (`/api/v1/home`).
class HomeFeedModel {
  final bool success;
  final String? message;
  final HomeFeedData? data;
  final HomeFeedMeta? meta;

  HomeFeedModel({
    required this.success,
    this.message,
    this.data,
    this.meta,
  });

  factory HomeFeedModel.fromJson(Map<String, dynamic> json) {
    return HomeFeedModel(
      success: json['success'] == true,
      message: json['message'] as String?,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? HomeFeedData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      meta: json['meta'] != null && json['meta'] is Map<String, dynamic>
          ? HomeFeedMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Metadata about caching and delivered sections
class HomeFeedMeta {
  final String? cachedAt;
  final List<String> sectionsDelivered;
  final List<String> requestedSections;

  HomeFeedMeta({
    this.cachedAt,
    this.sectionsDelivered = const [],
    this.requestedSections = const [],
  });

  factory HomeFeedMeta.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      if (raw is String && raw.isNotEmpty) {
        return raw.split(',').map((e) => e.trim()).toList();
      }
      return const [];
    }

    return HomeFeedMeta(
      cachedAt: json['cached_at'] as String?,
      sectionsDelivered: parseStringList(json['sections_delivered']),
      requestedSections: parseStringList(json['requested_sections']),
    );
  }
}

/// Consolidates all 14+ sections into a single strongly-typed data object
class HomeFeedData {
  final AppMetaModel? appMeta;
  final UserContextModel? userContext;
  final List<HomeSliderItem> sliders;
  final HomeStatsModel? stats;
  final HomeContestHubModel? contestHub;
  final List<HomeCourseCategoryItem> courseCategories;
  final List<HomeExamCategoryItem> examCategories;
  final HomeCareerUpdatesModel? careerAndUpdates;
  final HomeCurrentAffairsModel? currentAffairs;
  final HomeVocabularyModel? vocabulary;
  final HomeQuestionBanksModel? questionBanks;
  final List<HomePackageItem> packages;
  final List<HomeHallOfFameItem> hallOfFame;
  final HomeKeyFeaturesModel? keyFeatures;
  final HomeAboutSectionModel? aboutSection;
  final HomeCommunitySupportModel? communitySupport;
  final HomeAppDownloadModel? appDownload;
  final HomeCtaSectionModel? ctaSection;

  HomeFeedData({
    this.appMeta,
    this.userContext,
    this.sliders = const [],
    this.stats,
    this.contestHub,
    this.courseCategories = const [],
    this.examCategories = const [],
    this.careerAndUpdates,
    this.currentAffairs,
    this.vocabulary,
    this.questionBanks,
    this.packages = const [],
    this.hallOfFame = const [],
    this.keyFeatures,
    this.aboutSection,
    this.communitySupport,
    this.appDownload,
    this.ctaSection,
  });

  factory HomeFeedData.fromJson(Map<String, dynamic> json) {
    // Sliders
    List<HomeSliderItem> parsedSliders = [];
    if (json['sliders'] is List) {
      parsedSliders = (json['sliders'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => HomeSliderItem.fromJson(e))
          .toList();
    }

    // Course Categories
    List<HomeCourseCategoryItem> parsedCourseCategories = [];
    if (json['course_categories'] is List) {
      parsedCourseCategories = (json['course_categories'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => HomeCourseCategoryItem.fromJson(e))
          .toList();
    }

    // Exam Categories
    List<HomeExamCategoryItem> parsedExamCategories = [];
    if (json['exam_categories'] is List) {
      parsedExamCategories = (json['exam_categories'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => HomeExamCategoryItem.fromJson(e))
          .toList();
    }

    // Packages
    List<HomePackageItem> parsedPackages = [];
    if (json['packages'] is List) {
      parsedPackages = (json['packages'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => HomePackageItem.fromJson(e))
          .toList();
    }

    // Hall of Fame
    List<HomeHallOfFameItem> parsedHallOfFame = [];
    if (json['hall_of_fame'] is List) {
      parsedHallOfFame = (json['hall_of_fame'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => HomeHallOfFameItem.fromJson(e))
          .toList();
    }

    return HomeFeedData(
      appMeta: json['app_meta'] is Map<String, dynamic>
          ? AppMetaModel.fromJson(json['app_meta'] as Map<String, dynamic>)
          : null,
      userContext: json['user_context'] is Map<String, dynamic>
          ? UserContextModel.fromJson(json['user_context'] as Map<String, dynamic>)
          : null,
      sliders: parsedSliders,
      stats: json['stats'] is Map<String, dynamic>
          ? HomeStatsModel.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      contestHub: json['contest_hub'] is Map<String, dynamic>
          ? HomeContestHubModel.fromJson(json['contest_hub'] as Map<String, dynamic>)
          : null,
      courseCategories: parsedCourseCategories,
      examCategories: parsedExamCategories,
      careerAndUpdates: json['career_and_updates'] is Map<String, dynamic>
          ? HomeCareerUpdatesModel.fromJson(json['career_and_updates'] as Map<String, dynamic>)
          : null,
      currentAffairs: json['current_affairs'] is Map<String, dynamic>
          ? HomeCurrentAffairsModel.fromJson(json['current_affairs'] as Map<String, dynamic>)
          : null,
      vocabulary: json['vocabulary'] is Map<String, dynamic>
          ? HomeVocabularyModel.fromJson(json['vocabulary'] as Map<String, dynamic>)
          : null,
      questionBanks: json['question_banks'] is Map<String, dynamic>
          ? HomeQuestionBanksModel.fromJson(json['question_banks'] as Map<String, dynamic>)
          : null,
      packages: parsedPackages,
      hallOfFame: parsedHallOfFame,
      keyFeatures: json['key_features'] is Map<String, dynamic>
          ? HomeKeyFeaturesModel.fromJson(json['key_features'] as Map<String, dynamic>)
          : (json['key_features'] is List
              ? HomeKeyFeaturesModel(
                  items: (json['key_features'] as List)
                      .whereType<Map<String, dynamic>>()
                      .map((e) => HomeKeyFeatureItem.fromJson(e))
                      .toList(),
                )
              : null),
      aboutSection: json['about_section'] is Map<String, dynamic>
          ? HomeAboutSectionModel.fromJson(json['about_section'] as Map<String, dynamic>)
          : null,
      communitySupport: json['community_support'] is Map<String, dynamic>
          ? HomeCommunitySupportModel.fromJson(json['community_support'] as Map<String, dynamic>)
          : null,
      appDownload: json['app_download'] is Map<String, dynamic>
          ? HomeAppDownloadModel.fromJson(json['app_download'] as Map<String, dynamic>)
          : null,
      ctaSection: json['cta_section'] is Map<String, dynamic>
          ? HomeCtaSectionModel.fromJson(json['cta_section'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ─── 1. App Meta ─────────────────────────────────────────────────────────────
class AppMetaModel {
  final String appName;
  final String? appTagline;
  final String? appDescription;
  final String? playStoreUrl;
  final String? appleStoreUrl;
  final String? webUrl;
  final String? apiVersion;
  final String? responseTime;

  AppMetaModel({
    required this.appName,
    this.appTagline,
    this.appDescription,
    this.playStoreUrl,
    this.appleStoreUrl,
    this.webUrl,
    this.apiVersion,
    this.responseTime,
  });

  factory AppMetaModel.fromJson(Map<String, dynamic> json) {
    return AppMetaModel(
      appName: json['app_name'] as String? ?? 'Lokkha',
      appTagline: json['app_tagline'] as String?,
      appDescription: json['app_description'] as String?,
      playStoreUrl: json['play_store_url'] as String?,
      appleStoreUrl: json['apple_store_url'] as String?,
      webUrl: json['web_url'] as String?,
      apiVersion: json['api_version'] as String?,
      responseTime: json['response_time'] as String?,
    );
  }
}

// ─── 2. User Context ───────────────────────────────────────────────────────────
class UserContextModel {
  final bool isAuthenticated;
  final int? userId;
  final String? name;
  final String? phone;
  final String? avatar;
  final bool hasActivePackage;

  UserContextModel({
    this.isAuthenticated = false,
    this.userId,
    this.name,
    this.phone,
    this.avatar,
    this.hasActivePackage = false,
  });

  factory UserContextModel.fromJson(Map<String, dynamic> json) {
    return UserContextModel(
      isAuthenticated: json['is_authenticated'] == true,
      userId: json['user_id'] is num ? (json['user_id'] as num).toInt() : null,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      avatar: Endpoints.resolveImageUrl(json['avatar'] as String?),
      hasActivePackage: json['has_active_package'] == true,
    );
  }
}

// ─── 3. Sliders ───────────────────────────────────────────────────────────────
class HomeSliderItem {
  final int id;
  final String type;
  final String imageUrl;
  final String? imageSmUrl;
  final String? link;
  final HomeSliderNavigation? navigation;
  final int sorting;

  HomeSliderItem({
    required this.id,
    this.type = 'app',
    required this.imageUrl,
    this.imageSmUrl,
    this.link,
    this.navigation,
    this.sorting = 0,
  });

  factory HomeSliderItem.fromJson(Map<String, dynamic> json) {
    return HomeSliderItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      type: json['type'] as String? ?? 'app',
      imageUrl: Endpoints.resolveImageUrl(json['image_url'] as String?),
      imageSmUrl: Endpoints.resolveImageUrl(json['image_sm_url'] as String?),
      link: json['link'] as String?,
      navigation: json['navigation'] is Map<String, dynamic>
          ? HomeSliderNavigation.fromJson(json['navigation'] as Map<String, dynamic>)
          : null,
      sorting: json['sorting'] is num ? (json['sorting'] as num).toInt() : 0,
    );
  }
}

class HomeSliderNavigation {
  final String? page;
  final dynamic params;
  final bool hasAction;

  HomeSliderNavigation({
    this.page,
    this.params,
    this.hasAction = false,
  });

  factory HomeSliderNavigation.fromJson(Map<String, dynamic> json) {
    return HomeSliderNavigation(
      page: json['page'] as String?,
      params: json['params'],
      hasAction: json['has_action'] == true,
    );
  }
}

// ─── 4. Stats ────────────────────────────────────────────────────────────────
class HomeStatsModel {
  final List<HomeStatHighlight> highlights;
  final Map<String, dynamic>? databaseCounts;
  final Map<String, dynamic>? visitorStats;

  HomeStatsModel({
    this.highlights = const [],
    this.databaseCounts,
    this.visitorStats,
  });

  factory HomeStatsModel.fromJson(Map<String, dynamic> json) {
    List<HomeStatHighlight> parsedHighlights = [];
    if (json['highlights'] is List) {
      parsedHighlights = (json['highlights'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => HomeStatHighlight.fromJson(e))
          .toList();
    }

    return HomeStatsModel(
      highlights: parsedHighlights,
      databaseCounts: json['database_counts'] as Map<String, dynamic>?,
      visitorStats: json['visitor_stats'] as Map<String, dynamic>?,
    );
  }
}

class HomeStatHighlight {
  final String key;
  final String? rawValue;
  final String? unit;
  final String countFormatted;
  final String label;
  final String icon;

  HomeStatHighlight({
    required this.key,
    this.rawValue,
    this.unit,
    required this.countFormatted,
    required this.label,
    required this.icon,
  });

  factory HomeStatHighlight.fromJson(Map<String, dynamic> json) {
    return HomeStatHighlight(
      key: json['key'] as String? ?? '',
      rawValue: json['raw_value']?.toString(),
      unit: json['unit']?.toString(),
      countFormatted: json['count_formatted'] as String? ??
          (json['count'] != null ? json['count'].toString() : ''),
      label: json['label'] as String? ?? '',
      icon: json['icon'] as String? ?? 'star',
    );
  }
}

// ─── 5. Contest Hub ──────────────────────────────────────────────────────────
class HomeContestHubModel {
  final HomeActiveContest? activeContest;
  final int? lastContestId;
  final String? lastContestName;
  final int leaderboardCount;
  final List<HomeLeaderboardUser> topLeaderboard;

  HomeContestHubModel({
    this.activeContest,
    this.lastContestId,
    this.lastContestName,
    this.leaderboardCount = 0,
    this.topLeaderboard = const [],
  });

  factory HomeContestHubModel.fromJson(Map<String, dynamic> json) {
    List<HomeLeaderboardUser> parsedLeaderboard = [];
    if (json['top_leaderboard'] is List) {
      parsedLeaderboard = (json['top_leaderboard'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => HomeLeaderboardUser.fromJson(e))
          .toList();
    }

    return HomeContestHubModel(
      activeContest: json['active_contest'] is Map<String, dynamic>
          ? HomeActiveContest.fromJson(json['active_contest'] as Map<String, dynamic>)
          : null,
      lastContestId: json['last_contest_id'] is num
          ? (json['last_contest_id'] as num).toInt()
          : null,
      lastContestName: json['last_contest_name'] as String?,
      leaderboardCount: json['leaderboard_count'] is num
          ? (json['leaderboard_count'] as num).toInt()
          : 0,
      topLeaderboard: parsedLeaderboard,
    );
  }
}

class HomeActiveContest {
  final int id;
  final String name;
  final String slug;
  final String? imageUrl;
  final String? description;
  final int durationMinutes;
  final double positiveMark;
  final double negativeMark;
  final int autoQuestionCount;
  final String? startDatetime;
  final String? endDatetime;
  final String? startFormatted;
  final String? endFormatted;
  final String status;
  final bool isLive;
  final bool isUpcoming;
  final bool isEnded;
  final int countdownSeconds;
  final String? prizeDetails;
  final String? sponsorName;
  final String? sponsorImageUrl;

  HomeActiveContest({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
    this.description,
    this.durationMinutes = 0,
    this.positiveMark = 1.0,
    this.negativeMark = 0.5,
    this.autoQuestionCount = 0,
    this.startDatetime,
    this.endDatetime,
    this.startFormatted,
    this.endFormatted,
    this.status = 'upcoming',
    this.isLive = false,
    this.isUpcoming = false,
    this.isEnded = false,
    this.countdownSeconds = 0,
    this.prizeDetails,
    this.sponsorName,
    this.sponsorImageUrl,
  });

  factory HomeActiveContest.fromJson(Map<String, dynamic> json) {
    return HomeActiveContest(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      imageUrl: Endpoints.resolveImageUrl(json['image_url'] as String?),
      description: json['description'] as String?,
      durationMinutes: json['duration_minutes'] is num
          ? (json['duration_minutes'] as num).toInt()
          : 0,
      positiveMark: json['positive_mark'] is num
          ? (json['positive_mark'] as num).toDouble()
          : 1.0,
      negativeMark: json['negative_mark'] is num
          ? (json['negative_mark'] as num).toDouble()
          : 0.5,
      autoQuestionCount: json['auto_question_count'] is num
          ? (json['auto_question_count'] as num).toInt()
          : 0,
      startDatetime: json['start_datetime'] as String?,
      endDatetime: json['end_datetime'] as String?,
      startFormatted: json['start_formatted'] as String?,
      endFormatted: json['end_formatted'] as String?,
      status: json['status'] as String? ?? 'upcoming',
      isLive: json['is_live'] == true,
      isUpcoming: json['is_upcoming'] == true,
      isEnded: json['is_ended'] == true,
      countdownSeconds: json['countdown_seconds'] is num
          ? (json['countdown_seconds'] as num).toInt()
          : 0,
      prizeDetails: json['prize_details'] as String?,
      sponsorName: json['sponsor_name'] as String?,
      sponsorImageUrl: Endpoints.resolveImageUrl(json['sponsor_image_url'] as String?),
    );
  }
}

class HomeLeaderboardUser {
  final int rank;
  final int userId;
  final String userName;
  final String? userPhoneMasked;
  final String? userAvatar;
  final int correctAnswers;
  final int incorrectAnswers;
  final double totalMarks;
  final int completeDurationSeconds;

  HomeLeaderboardUser({
    required this.rank,
    required this.userId,
    required this.userName,
    this.userPhoneMasked,
    this.userAvatar,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.totalMarks = 0.0,
    this.completeDurationSeconds = 0,
  });

  factory HomeLeaderboardUser.fromJson(Map<String, dynamic> json) {
    return HomeLeaderboardUser(
      rank: json['rank'] is num ? (json['rank'] as num).toInt() : 0,
      userId: json['user_id'] is num ? (json['user_id'] as num).toInt() : 0,
      userName: json['user_name'] as String? ?? '',
      userPhoneMasked: json['user_phone_masked'] as String?,
      userAvatar: Endpoints.resolveImageUrl(json['user_avatar'] as String?),
      correctAnswers: json['correct_answers'] is num
          ? (json['correct_answers'] as num).toInt()
          : 0,
      incorrectAnswers: json['incorrect_answers'] is num
          ? (json['incorrect_answers'] as num).toInt()
          : 0,
      totalMarks: json['total_marks'] is num
          ? (json['total_marks'] as num).toDouble()
          : 0.0,
      completeDurationSeconds: json['complete_duration_seconds'] is num
          ? (json['complete_duration_seconds'] as num).toInt()
          : 0,
    );
  }
}

// ─── 6. Course & Exam Categories ─────────────────────────────────────────────
class HomeThemeConfig {
  final String? gradient;
  final String? icon;
  final String? shadow;

  HomeThemeConfig({this.gradient, this.icon, this.shadow});

  factory HomeThemeConfig.fromJson(Map<String, dynamic> json) {
    return HomeThemeConfig(
      gradient: json['gradient'] as String?,
      icon: json['icon'] as String?,
      shadow: json['shadow'] as String?,
    );
  }
}

class HomeCourseCategoryItem {
  final int id;
  final String title;
  final String slug;
  final String? description;
  final String? imageUrl;
  final int coursesCount;
  final HomeThemeConfig? theme;

  HomeCourseCategoryItem({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.imageUrl,
    this.coursesCount = 0,
    this.theme,
  });

  factory HomeCourseCategoryItem.fromJson(Map<String, dynamic> json) {
    final rawImageUrl = json['image_url']?.toString().trim();
    final rawImage = json['image']?.toString().trim();
    final effectiveRaw = (rawImageUrl != null && rawImageUrl.isNotEmpty)
        ? rawImageUrl
        : ((rawImage != null && rawImage.isNotEmpty) ? rawImage : null);
    final resolvedUrl = effectiveRaw != null
        ? Endpoints.resolveImageUrl(effectiveRaw)
        : null;

    return HomeCourseCategoryItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: (resolvedUrl != null && resolvedUrl.isNotEmpty)
          ? resolvedUrl
          : null,
      coursesCount: json['courses_count'] is num
          ? (json['courses_count'] as num).toInt()
          : 0,
      theme: json['theme'] is Map<String, dynamic>
          ? HomeThemeConfig.fromJson(json['theme'] as Map<String, dynamic>)
          : null,
    );
  }
}

class HomeExamCategoryItem {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final int examsCount;
  final HomeThemeConfig? theme;

  HomeExamCategoryItem({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    this.examsCount = 0,
    this.theme,
  });

  factory HomeExamCategoryItem.fromJson(Map<String, dynamic> json) {
    final rawImageUrl = json['image_url']?.toString().trim();
    final rawImage = json['image']?.toString().trim();
    final effectiveRaw = (rawImageUrl != null && rawImageUrl.isNotEmpty)
        ? rawImageUrl
        : ((rawImage != null && rawImage.isNotEmpty) ? rawImage : null);
    final resolvedUrl = effectiveRaw != null
        ? Endpoints.resolveImageUrl(effectiveRaw)
        : null;

    return HomeExamCategoryItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: (resolvedUrl != null && resolvedUrl.isNotEmpty)
          ? resolvedUrl
          : null,
      examsCount: json['exams_count'] is num
          ? (json['exams_count'] as num).toInt()
          : 0,
      theme: json['theme'] is Map<String, dynamic>
          ? HomeThemeConfig.fromJson(json['theme'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ─── 7. Career and Updates ───────────────────────────────────────────────────
class HomeCareerUpdatesModel {
  final List<HomeJobSectorItem> jobSectors;
  final List<HomeLatestJobItem> latestJobs;
  final List<HomeLatestExamItem> latestExams;
  final String? noticeTicker;

  HomeCareerUpdatesModel({
    this.jobSectors = const [],
    this.latestJobs = const [],
    this.latestExams = const [],
    this.noticeTicker,
  });

  factory HomeCareerUpdatesModel.fromJson(Map<String, dynamic> json) {
    List<HomeJobSectorItem> parsedJobSectors = [];
    if (json['job_sectors'] is List) {
      parsedJobSectors = (json['job_sectors'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => HomeJobSectorItem.fromJson(e))
          .toList();
    }

    List<HomeLatestJobItem> parsedLatestJobs = [];
    if (json['latest_jobs'] is List) {
      parsedLatestJobs = (json['latest_jobs'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => HomeLatestJobItem.fromJson(e))
          .toList();
    }

    List<HomeLatestExamItem> parsedLatestExams = [];
    if (json['latest_exams'] is List) {
      parsedLatestExams = (json['latest_exams'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => HomeLatestExamItem.fromJson(e))
          .toList();
    }

    return HomeCareerUpdatesModel(
      jobSectors: parsedJobSectors,
      latestJobs: parsedLatestJobs,
      latestExams: parsedLatestExams,
      noticeTicker: json['notice_ticker'] as String?,
    );
  }
}

class HomeJobSectorItem {
  final String id;
  final String title;
  final String? subtitle;
  final String icon;
  final String badgeColor;

  HomeJobSectorItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon = 'building',
    this.badgeColor = 'blue',
  });

  factory HomeJobSectorItem.fromJson(Map<String, dynamic> json) {
    return HomeJobSectorItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      icon: json['icon'] as String? ?? 'building',
      badgeColor: json['badge_color'] as String? ?? 'blue',
    );
  }
}

class HomeLatestJobItem {
  final int id;
  final String title;
  final String slug;
  final String? companyName;
  final String? deadline;
  final String? deadlineBn;
  final String? publishedDate;
  final bool isFeatured;
  final bool isExpired;

  HomeLatestJobItem({
    required this.id,
    required this.title,
    required this.slug,
    this.companyName,
    this.deadline,
    this.deadlineBn,
    this.publishedDate,
    this.isFeatured = false,
    this.isExpired = false,
  });

  factory HomeLatestJobItem.fromJson(Map<String, dynamic> json) {
    return HomeLatestJobItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      companyName: json['company_name'] as String?,
      deadline: json['deadline'] as String?,
      deadlineBn: json['deadline_bn'] as String?,
      publishedDate: json['published_date'] as String?,
      isFeatured: json['is_featured'] == true,
      isExpired: json['is_expired'] == true,
    );
  }
}

class HomeLatestExamItem {
  final int id;
  final String title;
  final String? date;
  final String? dateBn;
  final int? tagId;
  final String? tagName;
  final int questionsCount;

  HomeLatestExamItem({
    required this.id,
    required this.title,
    this.date,
    this.dateBn,
    this.tagId,
    this.tagName,
    this.questionsCount = 0,
  });

  factory HomeLatestExamItem.fromJson(Map<String, dynamic> json) {
    return HomeLatestExamItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      title: json['title'] as String? ?? '',
      date: json['date'] as String?,
      dateBn: json['date_bn'] as String?,
      tagId: json['tag_id'] is num ? (json['tag_id'] as num).toInt() : null,
      tagName: json['tag_name'] as String?,
      questionsCount: json['questions_count'] is num
          ? (json['questions_count'] as num).toInt()
          : 0,
    );
  }
}

// ─── 8. Current Affairs ───────────────────────────────────────────────────────
class HomeCurrentAffairsModel {
  final List<HomeCurrentAffairItem> nationalItems;
  final List<HomeCurrentAffairItem> internationalItems;
  final List<String> tabs;

  HomeCurrentAffairsModel({
    this.nationalItems = const [],
    this.internationalItems = const [],
    this.tabs = const [],
  });

  factory HomeCurrentAffairsModel.fromJson(Map<String, dynamic> json) {
    List<HomeCurrentAffairItem> parseList(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map((e) => HomeCurrentAffairItem.fromJson(e))
            .toList();
      }
      return const [];
    }

    return HomeCurrentAffairsModel(
      nationalItems: parseList(json['national_items']),
      internationalItems: parseList(json['international_items']),
      tabs: (json['tabs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class HomeCurrentAffairItem {
  final int id;
  final String? question;
  final String? option1;
  final String? option2;
  final String? option3;
  final String? option4;
  final int? rightAnswer;
  final String? explanation;
  final String? date;
  final String? dateBn;
  final List<String> subjects;

  HomeCurrentAffairItem({
    required this.id,
    this.question,
    this.option1,
    this.option2,
    this.option3,
    this.option4,
    this.rightAnswer,
    this.explanation,
    this.date,
    this.dateBn,
    this.subjects = const [],
  });

  factory HomeCurrentAffairItem.fromJson(Map<String, dynamic> json) {
    String? opt1 = json['option_1'] as String?;
    String? opt2 = json['option_2'] as String?;
    String? opt3 = json['option_3'] as String?;
    String? opt4 = json['option_4'] as String?;

    if (json['options'] is Map<String, dynamic>) {
      final opts = json['options'] as Map<String, dynamic>;
      opt1 = opts['option_1'] as String? ?? opt1;
      opt2 = opts['option_2'] as String? ?? opt2;
      opt3 = opts['option_3'] as String? ?? opt3;
      opt4 = opts['option_4'] as String? ?? opt4;
    }

    return HomeCurrentAffairItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      question: json['question'] as String?,
      option1: opt1,
      option2: opt2,
      option3: opt3,
      rightAnswer: () {
        final raw = json['right_answer'];
        if (raw is num) return raw.toInt();
        if (raw is String) {
          if (raw.startsWith('option_')) {
            final parsed = int.tryParse(raw.replaceAll('option_', ''));
            if (parsed != null) return parsed;
          }
          final parsed = int.tryParse(raw);
          if (parsed != null) return parsed;
        }
        return null;
      }(),
      explanation: json['explanation'] as String?,
      date: json['date'] as String?,
      dateBn: json['date_bn'] as String?,
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

// ─── 9. Vocabulary ───────────────────────────────────────────────────────────
class HomeVocabularyModel {
  final List<String> types;
  final List<String> categories;
  final List<String> alphabets;
  final List<HomeVocabularyItem> items;

  HomeVocabularyModel({
    this.types = const [],
    this.categories = const [],
    this.alphabets = const [],
    this.items = const [],
  });

  factory HomeVocabularyModel.fromJson(Map<String, dynamic> json) {
    List<HomeVocabularyItem> parsedItems = [];
    if (json['items'] is List) {
      parsedItems = (json['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => HomeVocabularyItem.fromJson(e))
          .toList();
    }

    List<String> parseNames(dynamic raw) {
      if (raw is List) {
        return raw.map((e) {
          if (e is Map<String, dynamic>) {
            return e['name']?.toString() ?? e['title']?.toString() ?? '';
          }
          return e.toString();
        }).where((s) => s.isNotEmpty).toList();
      }
      return const [];
    }

    return HomeVocabularyModel(
      types: parseNames(json['types']),
      categories: parseNames(json['categories']),
      alphabets: (json['alphabets'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      items: parsedItems,
    );
  }
}

class HomeVocabularyItem {
  final int id;
  final String word;
  final String details;
  final String synonyms;
  final String antonyms;
  final String? type;
  final String? category;

  HomeVocabularyItem({
    required this.id,
    required this.word,
    required this.details,
    this.synonyms = '',
    this.antonyms = '',
    this.type,
    this.category,
  });

  factory HomeVocabularyItem.fromJson(Map<String, dynamic> json) {
    String parseStrings(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).join(', ');
      }
      return val?.toString() ?? '';
    }

    return HomeVocabularyItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      word: json['word'] as String? ?? '',
      details: json['details'] as String? ?? '',
      synonyms: parseStrings(json['synonyms']),
      antonyms: parseStrings(json['antonyms']),
      type: json['type'] as String?,
      category: json['category'] as String?,
    );
  }
}

// ─── 10. Question Banks ──────────────────────────────────────────────────────
class HomeQuestionBanksModel {
  final List<HomeQuestionBankItem> popularBanks;
  final List<HomeQuestionBankItem> subjectWiseBanks;

  HomeQuestionBanksModel({
    this.popularBanks = const [],
    this.subjectWiseBanks = const [],
  });

  factory HomeQuestionBanksModel.fromJson(Map<String, dynamic> json) {
    List<HomeQuestionBankItem> parseList(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map((e) => HomeQuestionBankItem.fromJson(e))
            .toList();
      }
      return const [];
    }

    return HomeQuestionBanksModel(
      popularBanks: parseList(json['popular_banks']),
      subjectWiseBanks: parseList(json['subject_wise_banks']),
    );
  }
}

class HomeQuestionBankItem {
  final int id;
  final String title;
  final String? subtitle;
  final String? slug;
  final String? badge;
  final String? themeColor;
  final String? icon;
  final int questionCount;
  final String? questionCountFormatted;
  final String? action;

  HomeQuestionBankItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.slug,
    this.badge,
    this.themeColor,
    this.icon,
    this.questionCount = 0,
    this.questionCountFormatted,
    this.action,
  });

  factory HomeQuestionBankItem.fromJson(Map<String, dynamic> json) {
    return HomeQuestionBankItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      title: (json['title'] ?? json['name']) as String? ?? '',
      subtitle: json['subtitle'] as String?,
      slug: json['slug'] as String?,
      badge: json['badge'] as String?,
      themeColor: json['theme_color'] as String?,
      icon: json['icon'] as String?,
      questionCount: json['question_count'] is num
          ? (json['question_count'] as num).toInt()
          : 0,
      questionCountFormatted: json['question_count_formatted'] as String?,
      action: json['action'] as String?,
    );
  }
}

// ─── 11. Packages ────────────────────────────────────────────────────────────
class HomePackageItem {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final double regularPrice;
  final double discountedPrice;
  final int duration;
  final String? durationType;
  final String durationLabel;
  final bool isFree;
  final bool isPopular;
  final bool isTrial;
  final int? trialDays;
  final List<String> features;

  HomePackageItem({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.regularPrice = 0.0,
    this.discountedPrice = 0.0,
    this.duration = 0,
    this.durationType,
    required this.durationLabel,
    this.isFree = false,
    this.isPopular = false,
    this.isTrial = false,
    this.trialDays,
    this.features = const [],
  });

  factory HomePackageItem.fromJson(Map<String, dynamic> json) {
    return HomePackageItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      regularPrice: json['regular_price'] is num
          ? (json['regular_price'] as num).toDouble()
          : 0.0,
      discountedPrice: json['discounted_price'] is num
          ? (json['discounted_price'] as num).toDouble()
          : 0.0,
      duration: json['duration'] is num ? (json['duration'] as num).toInt() : 0,
      durationType: json['duration_type'] as String?,
      durationLabel: json['duration_label'] as String? ?? '',
      isFree: json['is_free'] == true,
      isPopular: json['is_popular'] == true,
      isTrial: json['is_trial'] == true,
      trialDays: json['trial_days'] is num ? (json['trial_days'] as num).toInt() : null,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

// ─── 12. Hall of Fame ────────────────────────────────────────────────────────
class HomeHallOfFameItem {
  final int id;
  final String name;
  final String? designation;
  final String? institution;
  final String? avatarUrl;
  final String? reviewText;
  final double rating;
  final String? videoUrl;
  final String? youtubeId;
  final String? youtubeThumbnail;

  HomeHallOfFameItem({
    required this.id,
    required this.name,
    this.designation,
    this.institution,
    this.avatarUrl,
    this.reviewText,
    this.rating = 5.0,
    this.videoUrl,
    this.youtubeId,
    this.youtubeThumbnail,
  });

  factory HomeHallOfFameItem.fromJson(Map<String, dynamic> json) {
    return HomeHallOfFameItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      name: json['name'] as String? ?? '',
      designation: json['designation'] as String?,
      institution: json['institution'] as String?,
      avatarUrl: Endpoints.resolveImageUrl(json['avatar_url'] as String?),
      reviewText: json['review_text'] as String?,
      rating: json['rating'] is num ? (json['rating'] as num).toDouble() : 5.0,
      videoUrl: json['video_url'] as String?,
      youtubeId: json['youtube_id'] as String?,
      youtubeThumbnail: Endpoints.resolveImageUrl(json['youtube_thumbnail'] as String?),
    );
  }
}

// ─── 13. Key Features ────────────────────────────────────────────────────────
class HomeKeyFeaturesModel {
  final String? heading;
  final String? subheading;
  final List<HomeKeyFeatureItem> items;

  HomeKeyFeaturesModel({
    this.heading,
    this.subheading,
    this.items = const [],
  });

  factory HomeKeyFeaturesModel.fromJson(Map<String, dynamic> json) {
    List<HomeKeyFeatureItem> parsedItems = [];
    if (json['items'] is List) {
      parsedItems = (json['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => HomeKeyFeatureItem.fromJson(e))
          .toList();
    }

    return HomeKeyFeaturesModel(
      heading: json['heading'] as String?,
      subheading: json['subheading'] as String?,
      items: parsedItems,
    );
  }
}

class HomeKeyFeatureItem {
  final int id;
  final String numberBadge;
  final String title;
  final String desc;

  HomeKeyFeatureItem({
    required this.id,
    required this.numberBadge,
    required this.title,
    required this.desc,
  });

  factory HomeKeyFeatureItem.fromJson(Map<String, dynamic> json) {
    return HomeKeyFeatureItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      numberBadge: json['number_badge']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      desc: json['desc'] as String? ?? '',
    );
  }
}

// ─── 14. About & Journey Section ─────────────────────────────────────────────
class HomeAboutSectionModel {
  final String? subLabel;
  final String? heading;
  final String? subheading;
  final String? tagline;
  final String? journeyTitle;
  final String? journeyHighlight;
  final String? journeyParagraph;
  final List<HomeTrustBadgeItem> trustBadges;
  final List<HomeWhyChooseUsItem> whyChooseUs;

  HomeAboutSectionModel({
    this.subLabel,
    this.heading,
    this.subheading,
    this.tagline,
    this.journeyTitle,
    this.journeyHighlight,
    this.journeyParagraph,
    this.trustBadges = const [],
    this.whyChooseUs = const [],
  });

  factory HomeAboutSectionModel.fromJson(Map<String, dynamic> json) {
    List<HomeTrustBadgeItem> parsedBadges = [];
    if (json['trust_badges'] is List) {
      parsedBadges = (json['trust_badges'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => HomeTrustBadgeItem.fromJson(e))
          .toList();
    }

    List<HomeWhyChooseUsItem> parsedWhy = [];
    if (json['why_choose_us'] is List) {
      parsedWhy = (json['why_choose_us'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => HomeWhyChooseUsItem.fromJson(e))
          .toList();
    }

    return HomeAboutSectionModel(
      subLabel: json['sub_label'] as String?,
      heading: json['heading'] as String?,
      subheading: json['subheading'] as String?,
      tagline: json['tagline'] as String?,
      journeyTitle: json['journey_title'] as String?,
      journeyHighlight: json['journey_highlight'] as String?,
      journeyParagraph: json['journey_paragraph'] as String?,
      trustBadges: parsedBadges,
      whyChooseUs: parsedWhy,
    );
  }
}

class HomeTrustBadgeItem {
  final String label;
  final String? color;

  HomeTrustBadgeItem({required this.label, this.color});

  factory HomeTrustBadgeItem.fromJson(Map<String, dynamic> json) {
    return HomeTrustBadgeItem(
      label: json['label'] as String? ?? '',
      color: json['color'] as String?,
    );
  }
}

class HomeWhyChooseUsItem {
  final int id;
  final String title;
  final String desc;

  HomeWhyChooseUsItem({required this.id, required this.title, required this.desc});

  factory HomeWhyChooseUsItem.fromJson(Map<String, dynamic> json) {
    return HomeWhyChooseUsItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      title: json['title'] as String? ?? '',
      desc: json['desc'] as String? ?? '',
    );
  }
}

// ─── 15. Community Support ───────────────────────────────────────────────────
class HomeCommunitySupportModel {
  final String? sectionTitle;
  final String? sectionSubtitle;
  final String? hotlinePhonePrimary;
  final String? hotlinePhoneSecondary;
  final String? email;
  final String? whatsappChatUrl;
  final String? facebookPageUrl;
  final String? facebookGroupUrl;
  final String? youtubeChannelUrl;
  final String? telegramChannelUrl;
  final String? callCardTitle;
  final String? callCardSubtitle;
  final String? officeHours;

  HomeCommunitySupportModel({
    this.sectionTitle,
    this.sectionSubtitle,
    this.hotlinePhonePrimary,
    this.hotlinePhoneSecondary,
    this.email,
    this.whatsappChatUrl,
    this.facebookPageUrl,
    this.facebookGroupUrl,
    this.youtubeChannelUrl,
    this.telegramChannelUrl,
    this.callCardTitle,
    this.callCardSubtitle,
    this.officeHours,
  });

  factory HomeCommunitySupportModel.fromJson(Map<String, dynamic> json) {
    return HomeCommunitySupportModel(
      sectionTitle: json['section_title'] as String?,
      sectionSubtitle: json['section_subtitle'] as String?,
      hotlinePhonePrimary: json['hotline_phone_primary'] as String?,
      hotlinePhoneSecondary: json['hotline_phone_secondary'] as String?,
      email: json['email'] as String?,
      whatsappChatUrl: json['whatsapp_chat_url'] as String?,
      facebookPageUrl: json['facebook_page_url'] as String?,
      facebookGroupUrl: json['facebook_group_url'] as String?,
      youtubeChannelUrl: json['youtube_channel_url'] as String?,
      telegramChannelUrl: json['telegram_channel_url'] as String?,
      callCardTitle: json['call_card_title'] as String?,
      callCardSubtitle: json['call_card_subtitle'] as String?,
      officeHours: json['office_hours'] as String?,
    );
  }
}

// ─── 16. App Download ────────────────────────────────────────────────────────
class HomeAppDownloadModel {
  final String? badge;
  final String? title;
  final String? description;
  final String? playStoreUrl;
  final String? appStoreUrl;

  HomeAppDownloadModel({
    this.badge,
    this.title,
    this.description,
    this.playStoreUrl,
    this.appStoreUrl,
  });

  factory HomeAppDownloadModel.fromJson(Map<String, dynamic> json) {
    return HomeAppDownloadModel(
      badge: json['badge'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      playStoreUrl: json['play_store_url'] as String?,
      appStoreUrl: json['app_store_url'] as String?,
    );
  }
}

// ─── 17. CTA Section ─────────────────────────────────────────────────────────
class HomeCtaSectionModel {
  final String? badge;
  final String? title;
  final String? description;
  final String? buttonText;
  final String? buttonUrl;
  final List<String> featurePills;

  HomeCtaSectionModel({
    this.badge,
    this.title,
    this.description,
    this.buttonText,
    this.buttonUrl,
    this.featurePills = const [],
  });

  factory HomeCtaSectionModel.fromJson(Map<String, dynamic> json) {
    return HomeCtaSectionModel(
      badge: json['badge'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      buttonText: json['button_text'] as String?,
      buttonUrl: json['button_url'] as String?,
      featurePills: (json['feature_pills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
