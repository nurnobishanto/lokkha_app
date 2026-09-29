import 'dart:convert';

import 'package:lokkha/shared/models/exam.dart';

AllExamModel allExamModelFromJson(String str) =>
    AllExamModel.fromJson(json.decode(str));

String allExamModelToJson(AllExamModel data) => json.encode(data.toJson());

class AllExamModel {
  final bool? status;
  final Exams? exams;

  AllExamModel({
    this.status,
    this.exams,
  });

  factory AllExamModel.fromJson(Map<String, dynamic> json) => AllExamModel(
        status: json["status"],
        exams: json["exams"] == null ? null : Exams.fromJson(json["exams"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "exams": exams?.toJson(),
      };
}

class Exams {
  final int? currentPage;
  final List<Exam>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<Link>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final dynamic prevPageUrl;
  final int? to;
  final int? total;

  Exams({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory Exams.fromJson(Map<String, dynamic> json) => Exams(
        currentPage: json["current_page"],
        data: json["data"] == null
            ? []
            : List<Exam>.from(json["data"]!.map((x) => Exam.fromJson(x))),
        firstPageUrl: json["first_page_url"],
        from: json["from"],
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        links: json["links"] == null
            ? []
            : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
        nextPageUrl: json["next_page_url"],
        path: json["path"],
        perPage: json["per_page"],
        prevPageUrl: json["prev_page_url"],
        to: json["to"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "links": links == null
            ? []
            : List<dynamic>.from(links!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
      };
}

enum Status { APPROVED }

final statusValues = EnumValues({"approved": Status.APPROVED});

class Link {
  final String? url;
  final String? label;
  final bool? active;

  Link({
    this.url,
    this.label,
    this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"],
        label: json["label"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
