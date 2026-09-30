import 'dart:convert';

import 'package:lokkha/shared/models/question.dart';

CurrentAffairsModel currentAffairsModelFromJson(String str) =>
    CurrentAffairsModel.fromJson(json.decode(str));

String currentAffairsModelToJson(CurrentAffairsModel data) =>
    json.encode(data.toJson());

class CurrentAffairsModel {
  final bool? status;
  final String? message;
  final CurrentAffairs? currentAffairs;

  CurrentAffairsModel({
    this.status,
    this.message,
    this.currentAffairs,
  });

  factory CurrentAffairsModel.fromJson(Map<String, dynamic> json) =>
      CurrentAffairsModel(
        status: json["status"],
        message: json["message"],
        currentAffairs: json["current_affairs"] == null
            ? null
            : CurrentAffairs.fromJson(json["current_affairs"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "current_affairs": currentAffairs?.toJson(),
      };
}

int? _safeInt(dynamic val) {
  if (val == null) return null;
  if (val is int) return val;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val);
  return null;
}

class CurrentAffairs {
  final List<Datum>? data;
  final int? currentPage;
  final int? perPage;
  final int? total;
  final int? lastPage;
  final int? from;
  final int? to;

  CurrentAffairs({
    this.data,
    this.currentPage,
    this.perPage,
    this.total,
    this.lastPage,
    this.from,
    this.to,
  });

  factory CurrentAffairs.fromJson(Map<String, dynamic> json) => CurrentAffairs(
        data: json["data"] == null
            ? []
            : List<Datum>.from((json["data"] as List).map((x) =>
                Datum.fromJson(
                    x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x)))),
        currentPage: _safeInt(json["current_page"]),
        perPage: _safeInt(json["per_page"]),
        total: _safeInt(json["total"]),
        lastPage: _safeInt(json["last_page"]),
        from: _safeInt(json["from"]),
        to: _safeInt(json["to"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "current_page": currentPage,
        "per_page": perPage,
        "total": total,
        "last_page": lastPage,
        "from": from,
        "to": to,
      };
}

class Datum {
  final String? date;
  final List<Question>? questions;

  Datum({
    this.date,
    this.questions,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        date: json["date"]?.toString(),
        questions: json["questions"] == null
            ? []
            : List<Question>.from((json["questions"] as List).map((x) =>
                Question.fromJson(
                    x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x)))),
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "questions": questions == null
            ? []
            : List<dynamic>.from(questions!.map((x) => x.toJson())),
      };
}
