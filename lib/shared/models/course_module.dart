import 'package:lokkha/shared/models/course_item.dart';

class CourseModule {
  final int? id;
  final dynamic parentId;
  final String? type;
  final int? courseId;
  final String? title;
  final int? order;
  final dynamic description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;
  final List<CourseItem>? items;

  CourseModule({
    this.id,
    this.parentId,
    this.type,
    this.courseId,
    this.title,
    this.order,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.items,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) => CourseModule(
        id: json["id"],
        parentId: json["parent_id"],
        type: json["type"],
        courseId: json["course_id"],
        title: json["title"],
        order: json["order"],
        description: json["description"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        items: json["items"] == null
            ? []
            : List<CourseItem>.from(
                json["items"]!.map((x) => CourseItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "parent_id": parentId,
        "type": type,
        "course_id": courseId,
        "title": title,
        "order": order,
        "description": description,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}
