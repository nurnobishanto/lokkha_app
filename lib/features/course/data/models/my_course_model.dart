
import 'dart:convert';
MyCourseModel myCourseModelFromJson(String str) => MyCourseModel.fromJson(json.decode(str));
String myCourseModelToJson(MyCourseModel data) => json.encode(data.toJson());

class MyCourseModel {
  final bool? status;
  final List<Package>? packages;

  MyCourseModel({
    this.status,
    this.packages,
  });

  factory MyCourseModel.fromJson(Map<String, dynamic> json) => MyCourseModel(
    status: json["status"],
    packages: json["packages"] == null ? [] : List<Package>.from(json["packages"]!.map((x) => Package.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "packages": packages == null ? [] : List<dynamic>.from(packages!.map((x) => x.toJson())),
  };
}

class Package {
  final int? id;
  final int? courseId;
  final int? userId;
  final bool? lifetimeAccess;
  final DateTime? accessExpiry;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Course? course;
  final User? user;

  Package({
    this.id,
    this.courseId,
    this.userId,
    this.lifetimeAccess,
    this.accessExpiry,
    this.createdAt,
    this.updatedAt,
    this.course,
    this.user,
  });

  factory Package.fromJson(Map<String, dynamic> json) => Package(
    id: json["id"],
    courseId: json["course_id"],
    userId: json["user_id"],
    lifetimeAccess: json["lifetime_access"] == null
        ? null
        : (json["lifetime_access"] is bool
            ? json["lifetime_access"]
            : (json["lifetime_access"] == 1 || json["lifetime_access"] == "1" || json["lifetime_access"] == "true")),
    accessExpiry: json["access_expiry"] == null ? null : DateTime.parse(json["access_expiry"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    course: json["course"] == null ? null : Course.fromJson(json["course"]),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "course_id": courseId,
    "user_id": userId,
    "lifetime_access": lifetimeAccess,
    "access_expiry": accessExpiry?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "course": course?.toJson(),
    "user": user?.toJson(),
  };
}

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
  final String? meetLink;
  final dynamic whatsappGroupLink;
  final String? facebookGroup;
  final dynamic zoomLink;
  final String? youtubePlaylist;
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
  final List<dynamic>? suggestions;
  final bool? isEnrolled;
  final int? usersCount;

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
    this.suggestions,
    this.isEnrolled,
    this.usersCount,
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
    publishDate: json["publish_date"] == null ? null : DateTime.parse(json["publish_date"]),
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
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    suggestions: json["suggestions"] == null ? [] : List<dynamic>.from(json["suggestions"]!.map((x) => x)),
    isEnrolled: json["is_enrolled"] == null
        ? null
        : (json["is_enrolled"] is bool
            ? json["is_enrolled"]
            : (json["is_enrolled"] == 1 || json["is_enrolled"] == "1" || json["is_enrolled"] == "true")),
    usersCount: json["users_count"],
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
    "publish_date": "${publishDate!.year.toString().padLeft(4, '0')}-${publishDate!.month.toString().padLeft(2, '0')}-${publishDate!.day.toString().padLeft(2, '0')}",
    "status": status,
    "promotion_video": promotionVideo,
    "routine_file": routineFile,
    "is_exam_batch": isExamBatch,
    "lifetime_access": lifetimeAccess,
    "featured": featured,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "suggestions": suggestions == null ? [] : List<dynamic>.from(suggestions!.map((x) => x)),
    "is_enrolled": isEnrolled,
    "users_count": usersCount,
  };
}

class User {
  final int? id;
  final String? name;
  final dynamic email;
  final String? phone;
  final dynamic emailVerifiedAt;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? occupation;
  final dynamic organization;
  final dynamic referralCode;
  final String? userId;
  final dynamic image;
  final dynamic addressLine1;
  final dynamic addressLine2;
  final dynamic city;
  final dynamic state;
  final dynamic zipCode;
  final dynamic country;
  final int? points;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;
  final String? jwtToken;
  final dynamic googleId;
  final dynamic facebookId;
  final dynamic githubId;
  final dynamic linkedinId;
  final dynamic twitterId;
  final dynamic avatar;
  final dynamic provider;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.emailVerifiedAt,
    this.dateOfBirth,
    this.gender,
    this.occupation,
    this.organization,
    this.referralCode,
    this.userId,
    this.image,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.points,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.jwtToken,
    this.googleId,
    this.facebookId,
    this.githubId,
    this.linkedinId,
    this.twitterId,
    this.avatar,
    this.provider,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    emailVerifiedAt: json["email_verified_at"],
    dateOfBirth: json["date_of_birth"] == null ? null : DateTime.parse(json["date_of_birth"]),
    gender: json["gender"],
    occupation: json["occupation"],
    organization: json["organization"],
    referralCode: json["referral_code"],
    userId: json["user_id"],
    image: json["image"],
    addressLine1: json["address_line_1"],
    addressLine2: json["address_line_2"],
    city: json["city"],
    state: json["state"],
    zipCode: json["zip_code"],
    country: json["country"],
    points: json["points"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    jwtToken: json["jwt_token"],
    googleId: json["google_id"],
    facebookId: json["facebook_id"],
    githubId: json["github_id"],
    linkedinId: json["linkedin_id"],
    twitterId: json["twitter_id"],
    avatar: json["avatar"],
    provider: json["provider"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "email_verified_at": emailVerifiedAt,
    "date_of_birth": "${dateOfBirth!.year.toString().padLeft(4, '0')}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}",
    "gender": gender,
    "occupation": occupation,
    "organization": organization,
    "referral_code": referralCode,
    "user_id": userId,
    "image": image,
    "address_line_1": addressLine1,
    "address_line_2": addressLine2,
    "city": city,
    "state": state,
    "zip_code": zipCode,
    "country": country,
    "points": points,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "jwt_token": jwtToken,
    "google_id": googleId,
    "facebook_id": facebookId,
    "github_id": githubId,
    "linkedin_id": linkedinId,
    "twitter_id": twitterId,
    "avatar": avatar,
    "provider": provider,
  };
}
