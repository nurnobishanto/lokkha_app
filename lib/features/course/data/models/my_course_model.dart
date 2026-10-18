import 'dart:convert';
import 'package:lokkha/core/network/endpoints.dart';

MyCourseModel myCourseModelFromJson(String str) =>
    MyCourseModel.fromJson(json.decode(str) as Map<String, dynamic>);

String myCourseModelToJson(MyCourseModel data) => json.encode(data.toJson());

/// Typedef aliases for backward compatibility and Clean Architecture
typedef EnrolledCoursesResponseModel = MyCourseModel;
typedef Package = EnrolledCourseItem;

/// Root response model for My Enrolled Courses V1 API:
/// GET /api/v1/user/courses
class MyCourseModel {
  final bool success;
  final String? message;
  final List<EnrolledCourseItem> courses;
  final CoursePaginationMeta? meta;

  MyCourseModel({
    this.success = false,
    this.message,
    this.courses = const [],
    this.meta,
  });

  /// Compatibility getters
  List<EnrolledCourseItem> get items => courses;
  List<EnrolledCourseItem> get packages => courses;
  bool? get status => success;

  factory MyCourseModel.fromJson(Map<String, dynamic> json) {
    List<EnrolledCourseItem> parsedItems = [];

    final rawData = json['data'];
    if (rawData is Map<String, dynamic> && rawData['items'] is List) {
      parsedItems = (rawData['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map(EnrolledCourseItem.fromJson)
          .toList();
    } else if (rawData is List) {
      parsedItems = rawData
          .whereType<Map<String, dynamic>>()
          .map(EnrolledCourseItem.fromJson)
          .toList();
    } else if (json['items'] is List) {
      parsedItems = (json['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map(EnrolledCourseItem.fromJson)
          .toList();
    } else if (json['packages'] is List) {
      // Legacy format fallback: { status: true, packages: [...] }
      parsedItems = (json['packages'] as List)
          .whereType<Map<String, dynamic>>()
          .map(EnrolledCourseItem.fromLegacyJson)
          .toList();
    }

    CoursePaginationMeta? meta;
    if (json['meta'] is Map<String, dynamic>) {
      meta = CoursePaginationMeta.fromJson(json['meta'] as Map<String, dynamic>);
    } else if (rawData is Map<String, dynamic> &&
        rawData['meta'] is Map<String, dynamic>) {
      meta = CoursePaginationMeta.fromJson(
          rawData['meta'] as Map<String, dynamic>);
    }

    final isSuccess = json['success'] == true ||
        json['status'] == true ||
        (json['status']?.toString().toLowerCase() == 'success');

    return MyCourseModel(
      success: isSuccess,
      message: json['message']?.toString(),
      courses: parsedItems,
      meta: meta,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': {
          'items': courses.map((x) => x.toJson()).toList(),
        },
        if (meta != null) 'meta': meta!.toJson(),
      };
}

/// Individual Enrolled Course item in V1 API
class EnrolledCourseItem {
  final int enrollmentId;
  final int courseId;
  final String title;
  final String? slug;
  final String? imageUrl;
  final bool lifetimeAccess;
  final DateTime? accessExpiry;
  final bool isExpired;
  final int? remainingDays;
  final DateTime? enrolledAt;

  EnrolledCourseItem({
    required this.enrollmentId,
    required this.courseId,
    required this.title,
    this.slug,
    this.imageUrl,
    this.lifetimeAccess = false,
    this.accessExpiry,
    this.isExpired = false,
    this.remainingDays,
    this.enrolledAt,
  });

  // Backward compatibility getters for existing UI
  int get id => courseId;
  EnrolledCourseItem get course => this;
  String? get image => imageUrl;

  factory EnrolledCourseItem.fromJson(Map<String, dynamic> json) {
    final enrollmentId = int.tryParse(json['enrollment_id']?.toString() ?? '') ??
        int.tryParse(json['id']?.toString() ?? '') ??
        0;

    final courseId = int.tryParse(json['course_id']?.toString() ?? '') ??
        int.tryParse(json['id']?.toString() ?? '') ??
        enrollmentId;

    final title = json['title']?.toString() ??
        json['name']?.toString() ??
        '';

    final slug = json['slug']?.toString();

    final rawImage = json['image_url']?.toString() ??
        json['image']?.toString() ??
        json['thumbnail']?.toString();

    final lifetime = json['lifetime_access'] == true ||
        json['lifetime_access'] == 1 ||
        json['lifetime_access']?.toString() == '1' ||
        json['lifetime_access']?.toString().toLowerCase() == 'true';

    DateTime? expiry;
    if (json['access_expiry'] != null &&
        json['access_expiry'].toString().isNotEmpty) {
      expiry = DateTime.tryParse(json['access_expiry'].toString());
    }

    final expired = json['is_expired'] == true ||
        json['is_expired'] == 1 ||
        json['is_expired']?.toString() == '1' ||
        json['is_expired']?.toString().toLowerCase() == 'true' ||
        (!lifetime && expiry != null && DateTime.now().isAfter(expiry));

    int? remDays;
    if (json['remaining_days'] != null) {
      remDays = int.tryParse(json['remaining_days'].toString());
    } else if (!lifetime && expiry != null) {
      final diff = expiry.difference(DateTime.now()).inDays;
      remDays = diff >= 0 ? diff : 0;
    }

    DateTime? enrolled;
    if (json['enrolled_at'] != null &&
        json['enrolled_at'].toString().isNotEmpty) {
      enrolled = DateTime.tryParse(json['enrolled_at'].toString());
    }

    return EnrolledCourseItem(
      enrollmentId: enrollmentId,
      courseId: courseId,
      title: title,
      slug: slug,
      imageUrl: rawImage,
      lifetimeAccess: lifetime,
      accessExpiry: expiry,
      isExpired: expired,
      remainingDays: remDays,
      enrolledAt: enrolled,
    );
  }

  factory EnrolledCourseItem.fromLegacyJson(Map<String, dynamic> json) {
    final courseJson = json['course'] is Map<String, dynamic>
        ? json['course'] as Map<String, dynamic>
        : json;

    final enrollmentId = int.tryParse(json['id']?.toString() ?? '') ?? 0;
    final courseId = int.tryParse(courseJson['id']?.toString() ?? '') ??
        int.tryParse(json['course_id']?.toString() ?? '') ??
        enrollmentId;

    final title = courseJson['title']?.toString() ?? '';
    final slug = courseJson['slug']?.toString();
    final rawImage = courseJson['image']?.toString() ??
        courseJson['image_url']?.toString();

    final lifetime = json['lifetime_access'] == true ||
        json['lifetime_access'] == 1 ||
        courseJson['lifetime_access'] == true ||
        courseJson['lifetime_access'] == 1;

    DateTime? expiry;
    if (json['access_expiry'] != null) {
      expiry = DateTime.tryParse(json['access_expiry'].toString());
    }

    DateTime? enrolled;
    if (json['created_at'] != null) {
      enrolled = DateTime.tryParse(json['created_at'].toString());
    }

    final expired = !lifetime && expiry != null && DateTime.now().isAfter(expiry);

    int? remDays;
    if (!lifetime && expiry != null) {
      final diff = expiry.difference(DateTime.now()).inDays;
      remDays = diff >= 0 ? diff : 0;
    }

    return EnrolledCourseItem(
      enrollmentId: enrollmentId,
      courseId: courseId,
      title: title,
      slug: slug,
      imageUrl: rawImage,
      lifetimeAccess: lifetime,
      accessExpiry: expiry,
      isExpired: expired,
      remainingDays: remDays,
      enrolledAt: enrolled,
    );
  }

  Map<String, dynamic> toJson() => {
        'enrollment_id': enrollmentId,
        'course_id': courseId,
        'title': title,
        'slug': slug,
        'image_url': imageUrl,
        'lifetime_access': lifetimeAccess,
        'access_expiry': accessExpiry?.toIso8601String(),
        'is_expired': isExpired,
        'remaining_days': remainingDays,
        'enrolled_at': enrolledAt?.toIso8601String(),
      };

  /// Resolves image URL to full URI
  String get resolvedImageUrl {
    if (imageUrl == null || imageUrl!.trim().isEmpty) return '';
    final clean = imageUrl!.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return clean;
    }
    final base = Endpoints.imageBaseUrl.endsWith('/')
        ? Endpoints.imageBaseUrl
        : '${Endpoints.imageBaseUrl}/';
    final path = clean.startsWith('/') ? clean.substring(1) : clean;
    return '$base$path';
  }

  /// Human-friendly validity badge string in Bengali
  String get validityBadgeText {
    if (lifetimeAccess) {
      return 'লাইফটাইম';
    }
    if (isExpired) {
      return 'মেয়াদ শেষ';
    }
    if (remainingDays != null && remainingDays! > 0) {
      return '$remainingDays দিন বাকি';
    }
    if (accessExpiry != null) {
      return '${accessExpiry!.day}/${accessExpiry!.month}/${accessExpiry!.year} পর্যন্ত';
    }
    return 'চলমান';
  }

  /// Whether the course access expires in 7 days or fewer
  bool get isExpiringSoon =>
      !lifetimeAccess &&
      !isExpired &&
      remainingDays != null &&
      remainingDays! <= 7;
}

/// Pagination metadata for enrolled courses
class CoursePaginationMeta {
  final int currentPage;
  final int lastPage;
  final int total;
  final int? perPage;

  CoursePaginationMeta({
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.perPage,
  });

  factory CoursePaginationMeta.fromJson(Map<String, dynamic> json) =>
      CoursePaginationMeta(
        currentPage: int.tryParse(json['current_page']?.toString() ?? '') ?? 1,
        lastPage: int.tryParse(json['last_page']?.toString() ?? '') ?? 1,
        total: int.tryParse(json['total']?.toString() ?? '') ?? 0,
        perPage: int.tryParse(json['per_page']?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'last_page': lastPage,
        'total': total,
        if (perPage != null) 'per_page': perPage,
      };
}
