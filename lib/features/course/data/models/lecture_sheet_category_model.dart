import 'dart:convert';

import 'package:lokkha/shared/models/category.dart';
import 'package:lokkha/shared/models/paginator.dart';

LectureSheetCategory lectureSheetCategoryFromJson(String str) =>
    LectureSheetCategory.fromJson(json.decode(str));
String lectureSheetCategoryToJson(LectureSheetCategory data) =>
    json.encode(data.toJson());

class LectureSheetCategory {
  final bool? status;
  final Category? category;
  final Paginator<Category>? lecturesheets;

  LectureSheetCategory({
    this.status,
    this.category,
    this.lecturesheets,
  });

  factory LectureSheetCategory.fromJson(Map<String, dynamic> json) =>
      LectureSheetCategory(
        status: json["status"],
        category: json["category"] == null
            ? null
            : Category.fromJson(json["category"]),
        lecturesheets: json["lecturesheets"] == null
            ? null
            : Paginator<Category>.fromJson(
                json["lecturesheets"], (x) => Category.fromJson(x)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "category": category?.toJson(),
        "lecturesheets": lecturesheets?.toJson((x) => (x).toJson()),
      };
}
