class LectureSheet {
  final int? id;
  final String? name;
  final String? slug;
  final dynamic details;
  final String? file;
  final dynamic files;
  final bool? status;
  final List<LectureSheet>? categories;
  final String? description;

  LectureSheet({
    this.id,
    this.name,
    this.slug,
    this.details,
    this.file,
    this.files,
    this.status,
    this.categories,
    this.description,
  });

  factory LectureSheet.fromJson(Map<String, dynamic> json) => LectureSheet(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        details: json["details"],
        file: json["file"],
        files: json["files"],
        status: json["status"],
        categories: json["categories"] == null
            ? []
            : List<LectureSheet>.from(
                json["categories"]!.map((x) => LectureSheet.fromJson(x))),
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "details": details,
        "file": file,
        "files": files,
        "status": status,
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x.toJson())),
        "description": description,
      };
}
