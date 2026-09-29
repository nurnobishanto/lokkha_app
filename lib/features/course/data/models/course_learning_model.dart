import 'dart:convert';

import 'package:lokkha/shared/models/course_item.dart';

import 'package:lokkha/shared/models/course.dart';

CourseLearningModel courseLearningModelFromJson(String str) =>
    CourseLearningModel.fromJson(json.decode(str));
String courseLearningModelToJson(CourseLearningModel data) =>
    json.encode(data.toJson());

class CourseLearningModel {
  final bool? status;
  final String? message;
  final Data? data;

  CourseLearningModel({
    this.status,
    this.message,
    this.data,
  });

  factory CourseLearningModel.fromJson(Map<String, dynamic> json) =>
      CourseLearningModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  final Course? course;
  final CourseItem? currentItem;
  final int? nextItemId;
  final dynamic prevItemId;
  final dynamic progressPercent;

  Data({
    this.course,
    this.currentItem,
    this.nextItemId,
    this.prevItemId,
    this.progressPercent,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        course: json["course"] == null ? null : Course.fromJson(json["course"]),
        currentItem: json["current_item"] == null
            ? null
            : CourseItem.fromJson(json["current_item"]),
        nextItemId: json["next_item_id"],
        prevItemId: json["prev_item_id"],
        progressPercent: json["progress_percent"],
      );

  Map<String, dynamic> toJson() => {
        "course": course?.toJson(),
        "current_item": currentItem?.toJson(),
        "next_item_id": nextItemId,
        "prev_item_id": prevItemId,
        "progress_percent": progressPercent,
      };
}
