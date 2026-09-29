import 'dart:convert';
import 'package:lokkha/shared/models/paginator.dart';
import 'package:lokkha/shared/models/category.dart';

LectureSheetListCategoriesModel lectureSheetCategoriesFromJson(String str) =>
    LectureSheetListCategoriesModel.fromJson(json.decode(str));
String lectureSheetCategoriesToJson(LectureSheetListCategoriesModel data) =>
    json.encode(data.toJson());

class LectureSheetListCategoriesModel {
  final bool? status;
  final Paginator<Category>? categories;

  LectureSheetListCategoriesModel({
    this.status,
    this.categories,
  });

  factory LectureSheetListCategoriesModel.fromJson(Map<String, dynamic> json) =>
      LectureSheetListCategoriesModel(
        status: json["status"],
        categories: json["categories"] == null
            ? null
            : Paginator<Category>.fromJson(
                json["categories"], (x) => Category.fromJson(x)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "categories": categories?.toJson((x) => (x).toJson()),
      };
}
