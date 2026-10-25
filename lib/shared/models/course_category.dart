import 'package:lokkha/core/network/endpoints.dart';

class CourseCategory {
  final int? id;
  final String? title;
  final String? slug;
  final String? image;
  final String? imageUrl;
  final dynamic description;
  final bool? status;
  final int? coursesCount;

  CourseCategory({
    this.id,
    this.title,
    this.slug,
    this.image,
    this.imageUrl,
    this.description,
    this.status,
    this.coursesCount,
  });

  factory CourseCategory.fromJson(Map<String, dynamic> json) {
    final rawImageUrl = json["image_url"]?.toString().trim();
    final rawImage = json["image"]?.toString().trim();
    final effectiveRaw = (rawImageUrl != null && rawImageUrl.isNotEmpty)
        ? rawImageUrl
        : ((rawImage != null && rawImage.isNotEmpty) ? rawImage : null);
    final resolvedUrl = effectiveRaw != null
        ? Endpoints.resolveImageUrl(effectiveRaw)
        : null;

    return CourseCategory(
      id: json["id"],
      title: json["title"],
      slug: json["slug"],
      image: json["image"]?.toString(),
      imageUrl: (resolvedUrl != null && resolvedUrl.isNotEmpty)
          ? resolvedUrl
          : null,
      description: json["description"],
      status: json["status"] == null
          ? null
          : (json["status"] is bool
              ? json["status"]
              : (json["status"] == 1 ||
                  json["status"] == "1" ||
                  json["status"] == "true")),
      coursesCount: json["courses_count"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "slug": slug,
        "image": image,
        "image_url": imageUrl,
        "description": description,
        "status": status,
        "courses_count": coursesCount,
      };
}
