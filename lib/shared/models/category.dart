class Category {
  final int? id;
  final String? name;
  final String? slug;
  final dynamic parentId;
  final String? image;
  final String? description;
  final bool? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? lecturesheetsCount;
  final String? details;
  final String? file;
  final dynamic files;
  Category({
    this.id,
    this.name,
    this.slug,
    this.parentId,
    this.image,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.lecturesheetsCount,
    this.details,
    this.file,
    this.files,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        parentId: json["parent_id"],
        image: json["image"],
        description: json["description"],
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        lecturesheetsCount: json["lecturesheets_count"],
        details: json["details"],
        file: json["file"],
        files: json["files"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "parent_id": parentId,
        "image": image,
        "description": description,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "lecturesheets_count": lecturesheetsCount,
        "details": details,
        "file": file,
        "files": files,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Category && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
