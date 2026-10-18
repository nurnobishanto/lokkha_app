import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/models/course.dart';

class CourseCategoryBrief {
  final int id;
  final String title;
  final String? slug;

  const CourseCategoryBrief({
    required this.id,
    required this.title,
    this.slug,
  });

  factory CourseCategoryBrief.fromJson(Map<String, dynamic> json) {
    return CourseCategoryBrief(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'slug': slug,
      };
}

class CoursePricingModel {
  final double regularPrice;
  final double salePrice;
  final bool isFree;
  final double discountAmount;
  final int discountPercent;
  final String currency;

  const CoursePricingModel({
    this.regularPrice = 0,
    this.salePrice = 0,
    this.isFree = false,
    this.discountAmount = 0,
    this.discountPercent = 0,
    this.currency = 'BDT',
  });

  factory CoursePricingModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return CoursePricingModel(
      regularPrice: parseDouble(json['regular_price']),
      salePrice: parseDouble(json['sale_price']),
      isFree: json['is_free'] == true,
      discountAmount: parseDouble(json['discount_amount']),
      discountPercent: parseInt(json['discount_percent']),
      currency: json['currency']?.toString() ?? 'BDT',
    );
  }

  Map<String, dynamic> toJson() => {
        'regular_price': regularPrice,
        'sale_price': salePrice,
        'is_free': isFree,
        'discount_amount': discountAmount,
        'discount_percent': discountPercent,
        'currency': currency,
      };
}

class CourseStatsModel {
  final int modulesCount;
  final int itemsCount;
  final int enrolledStudents;
  final double averageRating;
  final int totalReviews;

  const CourseStatsModel({
    this.modulesCount = 0,
    this.itemsCount = 0,
    this.enrolledStudents = 0,
    this.averageRating = 0,
    this.totalReviews = 0,
  });

  factory CourseStatsModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double parseDouble(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return CourseStatsModel(
      modulesCount: parseInt(json['modules_count']),
      itemsCount: parseInt(json['items_count']),
      enrolledStudents: parseInt(json['enrolled_students']),
      averageRating: parseDouble(json['average_rating']),
      totalReviews: parseInt(json['total_reviews']),
    );
  }

  Map<String, dynamic> toJson() => {
        'modules_count': modulesCount,
        'items_count': itemsCount,
        'enrolled_students': enrolledStudents,
        'average_rating': averageRating,
        'total_reviews': totalReviews,
      };
}

class CourseTeacherSummaryModel {
  final int id;
  final String name;
  final String? designation;
  final String? imageUrl;

  const CourseTeacherSummaryModel({
    required this.id,
    required this.name,
    this.designation,
    this.imageUrl,
  });

  factory CourseTeacherSummaryModel.fromJson(Map<String, dynamic> json) {
    return CourseTeacherSummaryModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      designation: json['designation']?.toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'designation': designation,
        'image_url': imageUrl,
      };
}

class V1CourseModel {
  final int id;
  final String title;
  final String? slug;
  final CourseCategoryBrief? category;
  final String? imageUrl;
  final String? duration;
  final String? accessDurationText;
  final bool lifetimeAccess;
  final bool isExamBatch;
  final bool featured;
  final bool isUpcoming;
  final bool isOngoing;
  final CoursePricingModel pricing;
  final CourseStatsModel stats;
  final List<CourseTeacherSummaryModel> teachersSummary;
  final bool isEnrolled;

  const V1CourseModel({
    required this.id,
    required this.title,
    this.slug,
    this.category,
    this.imageUrl,
    this.duration,
    this.accessDurationText,
    this.lifetimeAccess = false,
    this.isExamBatch = false,
    this.featured = false,
    this.isUpcoming = false,
    this.isOngoing = true,
    this.pricing = const CoursePricingModel(),
    this.stats = const CourseStatsModel(),
    this.teachersSummary = const [],
    this.isEnrolled = false,
  });

  factory V1CourseModel.fromJson(Map<String, dynamic> json) {
    // Pricing parsing (nested V1 or top-level legacy)
    CoursePricingModel pricing;
    if (json['pricing'] is Map<String, dynamic>) {
      pricing = CoursePricingModel.fromJson(json['pricing']);
    } else {
      double regPrice = 0;
      double salePrice = 0;
      if (json['regular_price'] != null) {
        regPrice = double.tryParse(json['regular_price'].toString()) ?? 0;
      }
      if (json['sale_price'] != null) {
        salePrice = double.tryParse(json['sale_price'].toString()) ?? 0;
      }
      pricing = CoursePricingModel(
        regularPrice: regPrice,
        salePrice: salePrice,
        isFree: salePrice == 0 && regPrice == 0,
      );
    }

    // Stats parsing (nested V1 or top-level legacy)
    CourseStatsModel stats;
    if (json['stats'] is Map<String, dynamic>) {
      stats = CourseStatsModel.fromJson(json['stats']);
    } else {
      stats = CourseStatsModel(
        modulesCount: json['modules_count'] is int
            ? json['modules_count']
            : int.tryParse(json['modules_count']?.toString() ?? '0') ?? 0,
        itemsCount: json['items_count'] is int
            ? json['items_count']
            : int.tryParse(json['items_count']?.toString() ?? '0') ?? 0,
        enrolledStudents: json['users_count'] is int
            ? json['users_count']
            : int.tryParse(json['users_count']?.toString() ?? '0') ?? 0,
        averageRating: 5.0,
      );
    }

    // Teachers parsing
    final teachersList = <CourseTeacherSummaryModel>[];
    if (json['teachers_summary'] is List) {
      for (final t in json['teachers_summary']) {
        if (t is Map<String, dynamic>) {
          teachersList.add(CourseTeacherSummaryModel.fromJson(t));
        }
      }
    }

    final rawImage = json['image_url']?.toString() ?? json['image']?.toString();
    final resolvedImage = (rawImage != null && rawImage.isNotEmpty)
        ? Endpoints.resolveUrl(rawImage)
        : '';

    return V1CourseModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString(),
      category: json['category'] is Map<String, dynamic>
          ? CourseCategoryBrief.fromJson(json['category'])
          : null,
      imageUrl: resolvedImage,
      duration: json['duration']?.toString(),
      accessDurationText: json['access_duration_text']?.toString(),
      lifetimeAccess: json['lifetime_access'] == true,
      isExamBatch: json['is_exam_batch'] == true,
      featured: json['featured'] == true,
      isUpcoming: json['is_upcoming'] == true,
      isOngoing: json['is_ongoing'] != false,
      pricing: pricing,
      stats: stats,
      teachersSummary: teachersList,
      isEnrolled: json['is_enrolled'] == true,
    );
  }

  /// Display string for regular price (e.g. "500", "1000")
  String get displayRegularPrice {
    final price = pricing.regularPrice;
    if (price <= 0) return '0';
    return price.truncateToDouble() == price
        ? price.toInt().toString()
        : price.toStringAsFixed(2);
  }

  /// Display string for sale price (e.g. "299", "499")
  String get displaySalePrice {
    final price = pricing.salePrice;
    if (price <= 0) return '0';
    return price.truncateToDouble() == price
        ? price.toInt().toString()
        : price.toStringAsFixed(2);
  }

  /// Display rating string (defaults to "5" if rating is 0 or null as in reference design)
  String get displayRating {
    if (stats.averageRating > 0) {
      return stats.averageRating.truncateToDouble() == stats.averageRating
          ? stats.averageRating.toInt().toString()
          : stats.averageRating.toStringAsFixed(1);
    }
    return '5';
  }

  /// Checks if the course has a valid discount to display strikethrough price
  bool get hasDiscount =>
      pricing.regularPrice > pricing.salePrice && pricing.salePrice > 0;

  /// Converts to legacy Course model for backward compatibility
  Course toCourse() {
    return Course(
      id: id,
      title: title,
      slug: slug,
      image: imageUrl,
      regularPrice: displayRegularPrice,
      salePrice: displaySalePrice,
      duration: duration,
      isExamBatch: isExamBatch,
      lifetimeAccess: lifetimeAccess,
      featured: featured,
      isEnrolled: isEnrolled,
      courseCategoryId: category?.id,
    );
  }
}
