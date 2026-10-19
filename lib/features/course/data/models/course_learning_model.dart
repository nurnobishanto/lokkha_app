import 'dart:convert';

import 'package:lokkha/shared/models/course_item.dart';

import 'package:lokkha/shared/models/course.dart';

import 'package:lokkha/shared/models/course_module.dart';

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
        status: json["status"] == true || json["success"] == true,
        message: json["message"]?.toString(),
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
  final List<CourseModule> syllabus;

  Data({
    this.course,
    this.currentItem,
    this.nextItemId,
    this.prevItemId,
    this.progressPercent,
    this.syllabus = const [],
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    final rawSyllabus = json["syllabus"] ?? json["modules"];
    List<CourseModule> parsedModules = [];
    if (rawSyllabus is List) {
      parsedModules = rawSyllabus
          .whereType<Map<String, dynamic>>()
          .map((x) => CourseModule.fromJson(x))
          .toList();
    }

    Course? parsedCourse =
        json["course"] == null ? null : Course.fromJson(json["course"]);
    if (parsedCourse != null &&
        parsedModules.isNotEmpty &&
        (parsedCourse.modules == null || parsedCourse.modules!.isEmpty)) {
      parsedCourse = parsedCourse.copyWith(modules: parsedModules);
    }

    final nav = json["navigation"] is Map<String, dynamic>
        ? json["navigation"] as Map<String, dynamic>
        : null;

    final parsedNextId = nav != null
        ? nav["next_item_id"]
        : json["next_item_id"];
    final parsedPrevId = nav != null
        ? nav["prev_item_id"]
        : json["prev_item_id"];

    final parsedProgress = json["progress_percent"] ??
        (json["course"] is Map ? json["course"]["progress_percent"] : null);

    return Data(
      course: parsedCourse,
      currentItem: json["current_item"] == null
          ? null
          : CourseItem.fromJson(json["current_item"]),
      nextItemId: parsedNextId is int ? parsedNextId : int.tryParse(parsedNextId?.toString() ?? ''),
      prevItemId: parsedPrevId,
      progressPercent: parsedProgress,
      syllabus: parsedModules,
    );
  }

  Map<String, dynamic> toJson() => {
        "course": course?.toJson(),
        "current_item": currentItem?.toJson(),
        "next_item_id": nextItemId,
        "prev_item_id": prevItemId,
        "progress_percent": progressPercent,
        "syllabus": syllabus.map((x) => x.toJson()).toList(),
      };
}
