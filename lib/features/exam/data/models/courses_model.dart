import 'dart:convert';
import 'package:lokkha/shared/models/courses.dart';

CoursesModel coursesModelFromJson(String str) =>
    CoursesModel.fromJson(json.decode(str));
String coursesModelToJson(CoursesModel data) => json.encode(data.toJson());

class CoursesModel {
  final bool? status;
  final Courses? courses;

  CoursesModel({
    this.status,
    this.courses,
  });

  factory CoursesModel.fromJson(Map<String, dynamic> json) => CoursesModel(
        status: json["status"],
        courses:
            json["courses"] == null ? null : Courses.fromJson(json["courses"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "courses": courses?.toJson(),
      };
}
