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

  factory CourseDetailsModel.fromJson(Map<String, dynamic> json) =>
      CourseDetailsModel(
        status: json["status"],
        course: json["course"] == null ? null : Course.fromJson(json["course"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "course": course?.toJson(),
      };
}
