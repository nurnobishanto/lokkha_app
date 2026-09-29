class CourseCategory {
  final int? id;
  final String? title;
  final String? slug;
  final String? image;
  final dynamic description;
  final bool? status;
  final int? coursesCount;

  CourseCategory({
    this.id,
    this.title,
    this.slug,
    this.image,
    this.description,
    this.status,
    this.coursesCount,
  });

  factory CourseCategory.fromJson(Map<String, dynamic> json) => CourseCategory(
        id: json["id"],
        title: json["title"],
        slug: json["slug"],
        image: json["image"],
        description: json["description"],
        status: json["status"],
        coursesCount: json["courses_count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "slug": slug,
        "image": image,
        "description": description,
        "status": status,
        "courses_count": coursesCount,
      };
}
