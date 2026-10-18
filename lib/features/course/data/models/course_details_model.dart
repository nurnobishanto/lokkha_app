import 'dart:convert';
import 'package:lokkha/shared/models/course.dart';

CourseDetailsModel courseDetailsModelFromJson(String str) =>
    CourseDetailsModel.fromJson(json.decode(str));

String courseDetailsModelToJson(CourseDetailsModel data) =>
    json.encode(data.toJson());

class CourseDetailsModel {
  final bool? status;
  final Course? course;

  CourseDetailsModel({
    this.status,
    this.course,
  });

  factory CourseDetailsModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? courseMap;
    if (json["course"] is Map<String, dynamic>) {
      courseMap = json["course"];
    } else if (json["data"] is Map<String, dynamic>) {
      final data = json["data"] as Map<String, dynamic>;
      courseMap = data["course"] is Map<String, dynamic> ? data["course"] : data;
    }

    return CourseDetailsModel(
      status: json["status"] == true || json["success"] == true,
      course: courseMap == null ? null : Course.fromJson(courseMap),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "course": course?.toJson(),
      };
}
