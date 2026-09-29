import 'dart:convert';
import 'package:lokkha/shared/models/tag.dart';

LatestExamModel latestExamModelFromJson(String str) =>
    LatestExamModel.fromJson(json.decode(str));
String latestExamModelToJson(LatestExamModel data) =>
    json.encode(data.toJson());

class LatestExamModel {
  final bool? status;
  final LatestExams? latestExams;

  LatestExamModel({
    this.status,
    this.latestExams,
  });

  factory LatestExamModel.fromJson(Map<String, dynamic> json) =>
      LatestExamModel(
        status: json["status"],
        latestExams: json["latest_exams"] == null
            ? null
            : LatestExams.fromJson(json["latest_exams"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "latest_exams": latestExams?.toJson(),
      };
}

class LatestExams {
  final int? currentPage;
  final List<LatestExam>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<Link>? links;
  final dynamic nextPageUrl;
  final String? path;
  final int? perPage;
  final dynamic prevPageUrl;
  final int? to;
  final int? total;

  LatestExams({
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

  factory LatestExams.fromJson(Map<String, dynamic> json) => LatestExams(
        currentPage: json["current_page"],
        data: json["data"] == null
            ? []
            : List<LatestExam>.from(
                json["data"]!.map((x) => LatestExam.fromJson(x))),
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

class LatestExam {
  final int id;
  final String title;
  final DateTime date;
  final String? type;
  final bool? status;
  final int? tagId;
  final Tag? tag;

  LatestExam({
    required this.id,
    required this.title,
    required this.date,
    this.type,
    this.status,
    this.tagId,
    this.tag,
  });

  factory LatestExam.fromJson(Map<String, dynamic> json) => LatestExam(
        id: json["id"],
        title: json["title"]!,
        date: DateTime.parse(json["date"]),
        type: json["type"],
        status: json["status"],
        tagId: json["tag_id"],
        tag: json["tag"] == null ? null : Tag.fromJson(json["tag"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "date": date,
        "type": type,
        "status": status,
        "tag_id": tagId,
        "tag": tag?.toJson(),
      };
}

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
