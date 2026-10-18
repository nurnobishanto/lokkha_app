class V1CourseCategoryModel {
  final int id;
  final String title;
  final String? slug;
  final String? description;
  final String? imageUrl;
  final int coursesCount;

  const V1CourseCategoryModel({
    required this.id,
    required this.title,
    this.slug,
    this.description,
    this.imageUrl,
    this.coursesCount = 0,
  });

  factory V1CourseCategoryModel.fromJson(Map<String, dynamic> json) {
    return V1CourseCategoryModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString(),
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString() ?? json['image']?.toString(),
      coursesCount: json['courses_count'] is int
          ? json['courses_count']
          : int.tryParse(json['courses_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'slug': slug,
        'description': description,
        'image_url': imageUrl,
        'courses_count': coursesCount,
      };
}
