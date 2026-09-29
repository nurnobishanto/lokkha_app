// To parse this JSON data, do
//
//     final jobListModel = jobListModelFromJson(jsonString);

import 'dart:convert';

JobListModel jobListModelFromJson(String str) =>
    JobListModel.fromJson(json.decode(str));

String jobListModelToJson(JobListModel data) => json.encode(data.toJson());

class JobListModel {
  final bool? status;
  final Jobs? jobs;

  JobListModel({
    this.status,
    this.jobs,
  });

  factory JobListModel.fromJson(Map<String, dynamic> json) => JobListModel(
        status: json["status"],
        jobs: json["jobs"] == null ? null : Jobs.fromJson(json["jobs"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "jobs": jobs?.toJson(),
      };
}

class Jobs {
  final int? currentPage;
  final List<Job>? data;
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

  Jobs({
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

  factory Jobs.fromJson(Map<String, dynamic> json) => Jobs(
        currentPage: json["current_page"],
        data: json["data"] == null
            ? []
            : List<Job>.from(json["data"]!.map((x) => Job.fromJson(x))),
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

class Job {
  final int? id;
  final String? title;
  final String? slug;
  final int? departmentId;
  final String? companyName;
  final String? source;
  final String? sourceFile;
  final String? details;
  final DateTime? deadline;
  final DateTime? publishedDate;
  final bool? isFeatured;
  final bool? status;
  final int? views;
  final dynamic approvedAt;
  final dynamic metaTitle;
  final dynamic metaDescription;
  final dynamic metaKeywords;
  final String? metaImage;
  final dynamic metaAuthor;
  final dynamic metaUrl;
  final dynamic metaData;
  final dynamic headerCode;
  final dynamic footerCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;

  Job({
    this.id,
    this.title,
    this.slug,
    this.departmentId,
    this.companyName,
    this.source,
    this.sourceFile,
    this.details,
    this.deadline,
    this.publishedDate,
    this.isFeatured,
    this.status,
    this.views,
    this.approvedAt,
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords,
    this.metaImage,
    this.metaAuthor,
    this.metaUrl,
    this.metaData,
    this.headerCode,
    this.footerCode,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) => Job(
        id: json["id"],
        title: json["title"],
        slug: json["slug"],
        departmentId: json["department_id"],
        companyName: json["company_name"],
        source: json["source"],
        sourceFile: json["source_file"],
        details: json["details"],
        deadline:
            json["deadline"] == null ? null : DateTime.parse(json["deadline"]),
        publishedDate: json["published_date"] == null
            ? null
            : DateTime.parse(json["published_date"]),
        isFeatured: json["is_featured"],
        status: json["status"],
        views: json["views"],
        approvedAt: json["approved_at"],
        metaTitle: json["meta_title"],
        metaDescription: json["meta_description"],
        metaKeywords: json["meta_keywords"],
        metaImage: json["meta_image"],
        metaAuthor: json["meta_author"],
        metaUrl: json["meta_url"],
        metaData: json["meta_data"],
        headerCode: json["header_code"],
        footerCode: json["footer_code"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "slug": slug,
        "department_id": departmentId,
        "company_name": companyName,
        "source": source,
        "source_file": sourceFile,
        "details": details,
        "deadline": deadline?.toIso8601String(),
        "published_date": publishedDate?.toIso8601String(),
        "is_featured": isFeatured,
        "status": status,
        "views": views,
        "approved_at": approvedAt,
        "meta_title": metaTitle,
        "meta_description": metaDescription,
        "meta_keywords": metaKeywords,
        "meta_image": metaImage,
        "meta_author": metaAuthor,
        "meta_url": metaUrl,
        "meta_data": metaData,
        "header_code": headerCode,
        "footer_code": footerCode,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
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
