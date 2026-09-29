import 'dart:convert';
import 'package:lokkha/shared/models/lecture_sheet.dart';

LectureSheetDetailsModel lectureSheetDetailsModelFromJson(String str) =>
    LectureSheetDetailsModel.fromJson(json.decode(str));
String lectureSheetDetailsModelToJson(LectureSheetDetailsModel data) =>
    json.encode(data.toJson());

class LectureSheetDetailsModel {
  final bool? status;
  final LectureSheet? lectureSheet;

  LectureSheetDetailsModel({
    this.status,
    this.lectureSheet,
  });

  factory LectureSheetDetailsModel.fromJson(Map<String, dynamic> json) =>
      LectureSheetDetailsModel(
        status: json["status"],
        lectureSheet: json["lecturesheet"] == null
            ? null
            : LectureSheet.fromJson(json["lecturesheet"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "lecturesheet": lectureSheet?.toJson(),
      };
}
