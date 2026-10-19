import 'package:lokkha/shared/models/course_module.dart';
import 'package:lokkha/shared/models/review.dart';
import 'package:lokkha/shared/models/teacher.dart';
import 'package:lokkha/shared/models/user.dart';

class Course {
  final int? id;
  final int? accessDuration;
  final String? title;
  final String? slug;
  final String? details;
  final String? duration;
  final int? courseCategoryId;
  final String? image;
  final String? regularPrice;
  final String? salePrice;
  final dynamic meetLink;
  final dynamic whatsappGroupLink;
  final dynamic facebookGroup;
  final dynamic zoomLink;
  final dynamic youtubePlaylist;
  final dynamic telegramGroup;
  final int? order;
  final DateTime? publishDate;
  final bool? status;
  final dynamic promotionVideo;
  final String? routineFile;
  final bool? isExamBatch;
  final bool? lifetimeAccess;
  final bool? featured;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;
  final int? modulesCount;
  final int? itemsCount;
  final int? teachersCount;
  final int? reviewsCount;
  final int? usersCount;
  final bool? isEnrolled;
  final List<CourseModule>? modules;
  final List<Teacher>? teachers;
  final List<Review>? reviews;
  final List<User>? users;

  Course({
    this.id,
    this.accessDuration,
    this.title,
    this.slug,
    this.details,
    this.duration,
    this.courseCategoryId,
    this.image,
    this.regularPrice,
    this.salePrice,
    this.meetLink,
    this.whatsappGroupLink,
    this.facebookGroup,
    this.zoomLink,
    this.youtubePlaylist,
    this.telegramGroup,
    this.order,
    this.publishDate,
    this.status,
    this.promotionVideo,
    this.routineFile,
    this.isExamBatch,
    this.lifetimeAccess,
    this.featured,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.modulesCount,
    this.itemsCount,
    this.teachersCount,
    this.reviewsCount,
    this.usersCount,
    this.isEnrolled,
    this.modules,
    this.teachers,
    this.reviews,
    this.users,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final comm = json["community_links"] is Map<String, dynamic>
        ? json["community_links"] as Map<String, dynamic>
        : null;
    final stats = json["stats"] is Map<String, dynamic>
        ? json["stats"] as Map<String, dynamic>
        : null;
    final pricing = json["pricing"] is Map<String, dynamic>
        ? json["pricing"] as Map<String, dynamic>
        : null;
    final userAccess = json["user_access"] is Map<String, dynamic>
        ? json["user_access"] as Map<String, dynamic>
        : null;
    final category = json["category"] is Map<String, dynamic>
        ? json["category"] as Map<String, dynamic>
        : null;

    final parsedId = json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? '');

    bool? determineEnrolled() {
      final candidates = [
        json["is_enrolled"],
        userAccess?["is_enrolled"],
        json["enrolled"],
        userAccess?["enrolled"],
        json["is_purchased"],
        userAccess?["is_purchased"],
        json["has_access"],
        userAccess?["has_access"],
        json["can_access"],
        userAccess?["can_access"],
      ];
      for (final c in candidates) {
        if (c == true || c == 1 || c == "1" || c == "true") return true;
      }
      final enrollment = userAccess?["enrollment"] ?? json["enrollment"] ?? json["user_enrollment"];
      if (enrollment is Map && enrollment.isNotEmpty) return true;
      for (final c in candidates) {
        if (c == false || c == 0 || c == "0" || c == "false") return false;
      }
      return null;
    }

    final rawModules = json["modules"] ?? json["syllabus"];
    final rawTeachers = json["teachers"] ?? json["instructors"];

    return Course(
      id: parsedId,
      accessDuration: json["access_duration"] is int
          ? json["access_duration"]
          : int.tryParse(json["access_duration"]?.toString() ?? ''),
      title: json["title"]?.toString(),
      slug: json["slug"]?.toString(),
      details: json["details"]?.toString(),
      duration: json["duration"]?.toString(),
      courseCategoryId: json["course_category_id"] is int
          ? json["course_category_id"]
          : (category != null && category["id"] is int
              ? category["id"]
              : int.tryParse(json["course_category_id"]?.toString() ?? '')),
      image: json["image"]?.toString() ?? json["image_url"]?.toString(),
      regularPrice: (json["regular_price"] ?? pricing?["regular_price"])?.toString(),
      salePrice: (json["sale_price"] ?? pricing?["sale_price"])?.toString(),
      meetLink: json["meet_link"] ?? comm?["meet_link"],
      whatsappGroupLink: json["whatsapp_group_link"] ?? comm?["whatsapp_group"],
      facebookGroup: json["facebook_group"] ?? comm?["facebook_group"],
      zoomLink: json["zoom_link"] ?? comm?["zoom_link"],
      youtubePlaylist: json["youtube_playlist"] ?? comm?["youtube_playlist"],
      telegramGroup: json["telegram_group"] ?? comm?["telegram_group"],
      order: json["order"] is int ? json["order"] : int.tryParse(json["order"]?.toString() ?? ''),
      publishDate: json["publish_date"] == null
          ? null
          : DateTime.tryParse(json["publish_date"].toString()),
      status: json["status"] == null
          ? null
          : (json["status"] is bool
              ? json["status"]
              : (json["status"] == 1 || json["status"] == "1" || json["status"] == "true")),
      promotionVideo: json["promotion_video"] ?? json["promo_video_url"],
      routineFile: json["routine_file"]?.toString() ?? json["routine_file_url"]?.toString(),
      isExamBatch: json["is_exam_batch"] == null
          ? null
          : (json["is_exam_batch"] is bool
              ? json["is_exam_batch"]
              : (json["is_exam_batch"] == 1 || json["is_exam_batch"] == "1" || json["is_exam_batch"] == "true")),
      lifetimeAccess: json["lifetime_access"] == null
          ? null
          : (json["lifetime_access"] is bool
              ? json["lifetime_access"]
              : (json["lifetime_access"] == 1 || json["lifetime_access"] == "1" || json["lifetime_access"] == "true")),
      featured: json["featured"] == null
          ? null
          : (json["featured"] is bool
              ? json["featured"]
              : (json["featured"] == 1 || json["featured"] == "1" || json["featured"] == "true")),
      createdAt: json["created_at"] == null
          ? null
          : DateTime.tryParse(json["created_at"].toString()),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.tryParse(json["updated_at"].toString()),
      deletedAt: json["deleted_at"],
      modulesCount: json["modules_count"] is int
          ? json["modules_count"]
          : (stats?["total_modules"] is int
              ? stats!["total_modules"]
              : int.tryParse(json["modules_count"]?.toString() ?? '')),
      itemsCount: json["items_count"] is int
          ? json["items_count"]
          : (stats?["total_items"] is int
              ? stats!["total_items"]
              : int.tryParse(json["items_count"]?.toString() ?? '')),
      teachersCount: json["teachers_count"] is int
          ? json["teachers_count"]
          : int.tryParse(json["teachers_count"]?.toString() ?? ''),
      reviewsCount: json["reviews_count"] is int
          ? json["reviews_count"]
          : (stats?["total_reviews"] is int
              ? stats!["total_reviews"]
              : int.tryParse(json["reviews_count"]?.toString() ?? '')),
      usersCount: json["users_count"] is int
          ? json["users_count"]
          : (stats?["enrolled_students"] is int
              ? stats!["enrolled_students"]
              : int.tryParse(json["users_count"]?.toString() ?? '')),
      isEnrolled: determineEnrolled(),
      modules: rawModules is List
          ? List<CourseModule>.from(
              rawModules.whereType<Map<String, dynamic>>().map((x) => CourseModule.fromJson(x)))
          : [],
      teachers: rawTeachers is List
          ? List<Teacher>.from(
              rawTeachers.whereType<Map<String, dynamic>>().map((x) => Teacher.fromJson(x)))
          : [],
      reviews: json["reviews"] is List
          ? List<Review>.from(
              (json["reviews"] as List).whereType<Map<String, dynamic>>().map((x) => Review.fromJson(x)))
          : [],
      users: json["users"] is List
          ? List<User>.from(
              (json["users"] as List).whereType<Map<String, dynamic>>().map((x) => User.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "access_duration": accessDuration,
        "title": title,
        "slug": slug,
        "details": details,
        "duration": duration,
        "course_category_id": courseCategoryId,
        "image": image,
        "regular_price": regularPrice,
        "sale_price": salePrice,
        "meet_link": meetLink,
        "whatsapp_group_link": whatsappGroupLink,
        "facebook_group": facebookGroup,
        "zoom_link": zoomLink,
        "youtube_playlist": youtubePlaylist,
        "telegram_group": telegramGroup,
        "order": order,
        "publish_date":
            "${publishDate!.year.toString().padLeft(4, '0')}-${publishDate!.month.toString().padLeft(2, '0')}-${publishDate!.day.toString().padLeft(2, '0')}",
        "status": status,
        "promotion_video": promotionVideo,
        "routine_file": routineFile,
        "is_exam_batch": isExamBatch,
        "lifetime_access": lifetimeAccess,
        "featured": featured,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
        "modules_count": modulesCount,
        "items_count": itemsCount,
        "teachers_count": teachersCount,
        "reviews_count": reviewsCount,
        "users_count": usersCount,
        "is_enrolled": isEnrolled,
        "modules": modules == null
            ? []
            : List<dynamic>.from(modules!.map((x) => x.toJson())),
        "teachers": teachers == null
            ? []
            : List<dynamic>.from(teachers!.map((x) => x.toJson())),
        "reviews": reviews == null
            ? []
            : List<dynamic>.from(reviews!.map((x) => x.toJson())),
        "users": users == null ? [] : List<dynamic>.from(users!.map((x) => x)),
      };

  Course copyWith({
    int? id,
    int? accessDuration,
    String? title,
    String? slug,
    String? details,
    String? duration,
    int? courseCategoryId,
    String? image,
    String? regularPrice,
    String? salePrice,
    dynamic meetLink,
    dynamic whatsappGroupLink,
    dynamic facebookGroup,
    dynamic zoomLink,
    dynamic youtubePlaylist,
    dynamic telegramGroup,
    int? order,
    DateTime? publishDate,
    bool? status,
    String? promotionVideo,
    String? routineFile,
    bool? isExamBatch,
    bool? lifetimeAccess,
    bool? featured,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic deletedAt,
    int? modulesCount,
    int? itemsCount,
    int? teachersCount,
    int? reviewsCount,
    int? usersCount,
    bool? isEnrolled,
    List<CourseModule>? modules,
    List<Teacher>? teachers,
    List<Review>? reviews,
    List<User>? users,
  }) {
    return Course(
      id: id ?? this.id,
      accessDuration: accessDuration ?? this.accessDuration,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      details: details ?? this.details,
      duration: duration ?? this.duration,
      courseCategoryId: courseCategoryId ?? this.courseCategoryId,
      image: image ?? this.image,
      regularPrice: regularPrice ?? this.regularPrice,
      salePrice: salePrice ?? this.salePrice,
      meetLink: meetLink ?? this.meetLink,
      whatsappGroupLink: whatsappGroupLink ?? this.whatsappGroupLink,
      facebookGroup: facebookGroup ?? this.facebookGroup,
      zoomLink: zoomLink ?? this.zoomLink,
      youtubePlaylist: youtubePlaylist ?? this.youtubePlaylist,
      telegramGroup: telegramGroup ?? this.telegramGroup,
      order: order ?? this.order,
      publishDate: publishDate ?? this.publishDate,
      status: status ?? this.status,
      promotionVideo: promotionVideo ?? this.promotionVideo,
      routineFile: routineFile ?? this.routineFile,
      isExamBatch: isExamBatch ?? this.isExamBatch,
      lifetimeAccess: lifetimeAccess ?? this.lifetimeAccess,
      featured: featured ?? this.featured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      modulesCount: modulesCount ?? this.modulesCount,
      itemsCount: itemsCount ?? this.itemsCount,
      teachersCount: teachersCount ?? this.teachersCount,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      usersCount: usersCount ?? this.usersCount,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      modules: modules ?? this.modules,
      teachers: teachers ?? this.teachers,
      reviews: reviews ?? this.reviews,
      users: users ?? this.users,
    );
  }
}
