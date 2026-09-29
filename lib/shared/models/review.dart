class Review {
  final int? id;
  final int? userId;
  final int? courseId;
  final dynamic parentId;
  final String? body;
  final dynamic image;
  final dynamic date;
  final int? rating;
  final DateTime? publishedAt;
  final bool? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;

  Review({
    this.id,
    this.userId,
    this.courseId,
    this.parentId,
    this.body,
    this.image,
    this.date,
    this.rating,
    this.publishedAt,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"],
        userId: json["user_id"],
        courseId: json["course_id"],
        parentId: json["parent_id"],
        body: json["body"],
        image: json["image"],
        date: json["date"],
        rating: json["rating"],
        publishedAt: json["published_at"] == null
            ? null
            : DateTime.parse(json["published_at"]),
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "course_id": courseId,
        "parent_id": parentId,
        "body": body,
        "image": image,
        "date": date,
        "rating": rating,
        "published_at": publishedAt?.toIso8601String(),
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
      };
}
