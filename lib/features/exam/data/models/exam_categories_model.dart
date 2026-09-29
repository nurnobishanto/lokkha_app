import 'dart:convert';

import 'package:lokkha/shared/models/exam_category.dart';

ExamCategoriesModel examCategoriesModelFromJson(String str) =>
    ExamCategoriesModel.fromJson(json.decode(str));
String examCategoriesModelToJson(ExamCategoriesModel data) =>
    json.encode(data.toJson());

class ExamCategoriesModel {
  final bool? status;
  final List<ExamCategory>? examCategories;

  ExamCategoriesModel({
    this.status,
    this.examCategories,
  });

  factory ExamCategoriesModel.fromJson(Map<String, dynamic> json) {
    final categoriesData = json["exam-categories"] ?? json["exam_categories"];
    return ExamCategoriesModel(
      status: json["status"] == null
          ? null
          : (json["status"] is bool
              ? json["status"]
              : (json["status"] == 1 || json["status"] == "1" || json["status"] == "true")),
      examCategories: categoriesData == null
          ? []
          : List<ExamCategory>.from(
              (categoriesData as List).map((x) => ExamCategory.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "exam_categories": examCategories == null
            ? []
            : List<dynamic>.from(examCategories!.map((x) => x.toJson())),
      };
}
