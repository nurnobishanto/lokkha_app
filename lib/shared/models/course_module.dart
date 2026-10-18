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
        id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? ''),
        parentId: json["parent_id"],
        type: json["type"]?.toString(),
        courseId: json["course_id"] is int ? json["course_id"] : int.tryParse(json["course_id"]?.toString() ?? ''),
        title: json["title"]?.toString(),
        order: json["order"] is int ? json["order"] : int.tryParse(json["order"]?.toString() ?? ''),
        description: json["description"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"].toString()),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.tryParse(json["updated_at"].toString()),
        deletedAt: json["deleted_at"],
        items: json["items"] == null
            ? []
            : List<CourseItem>.from(
                (json["items"] as List)
                    .whereType<Map<String, dynamic>>()
                    .map((x) => CourseItem.fromJson(x))),
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
