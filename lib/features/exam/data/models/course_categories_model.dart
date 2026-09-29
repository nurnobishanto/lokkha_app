import 'dart:convert';
import 'package:lokkha/shared/models/course_category.dart';

CourseCategoriesModel courseCategoriesModelFromJson(String str) =>
    CourseCategoriesModel.fromJson(json.decode(str));

String courseCategoriesModelToJson(CourseCategoriesModel data) =>
    json.encode(data.toJson());

class CourseCategoriesModel {
  final bool? status;
  final List<CourseCategory>? courseCategories;

  CourseCategoriesModel({
    this.status,
    this.courseCategories,
  });

  factory CourseCategoriesModel.fromJson(Map<String, dynamic> json) =>
      CourseCategoriesModel(
        status: json["status"],
        courseCategories: json["course_categories"] == null
            ? []
            : List<CourseCategory>.from(json["course_categories"]!
                .map((x) => CourseCategory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "course_categories": courseCategories == null
            ? []
            : List<dynamic>.from(courseCategories!.map((x) => x.toJson())),
      };
}
