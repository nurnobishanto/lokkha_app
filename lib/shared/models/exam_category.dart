import 'package:lokkha/core/network/endpoints.dart';

class ExamCategory {
  final int? id;
  final String? name;
  final String? slug;
  final dynamic parentId;
  final String? image;
  final String? imageUrl;
  final String? description;
  final bool? status;
  final int? freeExamsCount;

  ExamCategory({
    this.id,
    this.name,
    this.slug,
    this.parentId,
    this.image,
    this.imageUrl,
    this.description,
    this.status,
    this.freeExamsCount,
  });

  factory ExamCategory.fromJson(Map<String, dynamic> json) {
    final rawImageUrl = json["image_url"]?.toString().trim();
    final rawImage = json["image"]?.toString().trim();
    final effectiveRaw = (rawImageUrl != null && rawImageUrl.isNotEmpty)
        ? rawImageUrl
        : ((rawImage != null && rawImage.isNotEmpty) ? rawImage : null);
    final resolvedUrl = effectiveRaw != null
        ? Endpoints.resolveImageUrl(effectiveRaw)
        : null;

    return ExamCategory(
      id: json["id"],
      name: json["name"],
      slug: json["slug"],
      parentId: json["parent_id"],
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
      freeExamsCount: json["free_exams_count"] ?? json["exams_count"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "parent_id": parentId,
        "image": image,
        "image_url": imageUrl,
        "description": description,
        "status": status,
        "free_exams_count": freeExamsCount,
      };
}
