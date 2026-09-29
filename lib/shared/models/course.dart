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

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json["id"],
        accessDuration: json["access_duration"],
        title: json["title"],
        slug: json["slug"],
        details: json["details"],
        duration: json["duration"],
        courseCategoryId: json["course_category_id"],
        image: json["image"],
        regularPrice: json["regular_price"],
        salePrice: json["sale_price"],
        meetLink: json["meet_link"],
        whatsappGroupLink: json["whatsapp_group_link"],
        facebookGroup: json["facebook_group"],
        zoomLink: json["zoom_link"],
        youtubePlaylist: json["youtube_playlist"],
        telegramGroup: json["telegram_group"],
        order: json["order"],
        publishDate: json["publish_date"] == null
            ? null
            : DateTime.parse(json["publish_date"]),
        status: json["status"] == null
            ? null
            : (json["status"] is bool
                ? json["status"]
                : (json["status"] == 1 || json["status"] == "1" || json["status"] == "true")),
        promotionVideo: json["promotion_video"],
        routineFile: json["routine_file"],
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
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        modulesCount: json["modules_count"],
        itemsCount: json["items_count"],
        teachersCount: json["teachers_count"],
        reviewsCount: json["reviews_count"],
        usersCount: json["users_count"],
        isEnrolled: json["is_enrolled"] == null
            ? null
            : (json["is_enrolled"] is bool
                ? json["is_enrolled"]
                : (json["is_enrolled"] == 1 || json["is_enrolled"] == "1" || json["is_enrolled"] == "true")),
        modules: json["modules"] == null
            ? []
            : List<CourseModule>.from(
                json["modules"]!.map((x) => CourseModule.fromJson(x))),
        teachers: json["teachers"] == null
            ? []
            : List<Teacher>.from(
                json["teachers"]!.map((x) => Teacher.fromJson(x))),
        reviews: json["reviews"] == null
            ? []
            : List<Review>.from(
                json["reviews"]!.map((x) => Review.fromJson(x))),
        users: json["user"] == null
            ? []
            : List<User>.from(json["users"]!.map((x) => User.fromJson(x))),
      );

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
}
