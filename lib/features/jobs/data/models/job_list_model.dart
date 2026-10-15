import 'dart:convert';

JobListModel jobListModelFromJson(String str) =>
    JobListModel.fromJson(json.decode(str));

String jobListModelToJson(JobListModel data) => json.encode(data.toJson());

class JobListModel {
  final bool? status;
  final bool? success;
  final String? message;
  final Jobs? jobs;
  final List<JobDepartment>? departments;

  JobListModel({
    this.status,
    this.success,
    this.message,
    this.jobs,
    this.departments,
  });

  factory JobListModel.fromJson(Map<String, dynamic> json) {
    // 1. Check if V1 format: json["data"] is Map with "items"
    if (json["data"] is Map) {
      final dataMap = json["data"] is Map<String, dynamic>
          ? json["data"] as Map<String, dynamic>
          : Map<String, dynamic>.from(json["data"] as Map);

      final rawItems = dataMap["items"];
      List<Job> parsedJobs = [];
      if (rawItems is List) {
        parsedJobs = rawItems
            .whereType<Map>()
            .map((x) => Job.fromJson(
                x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x)))
            .toList();
      }

      final metaMap = (json["meta"] is Map)
          ? (json["meta"] is Map<String, dynamic>
              ? json["meta"] as Map<String, dynamic>
              : Map<String, dynamic>.from(json["meta"] as Map))
          : null;

      final curPage = metaMap?["current_page"] is int
          ? metaMap!["current_page"] as int
          : int.tryParse(metaMap?["current_page"]?.toString() ?? '') ?? 1;
      final lastPage = metaMap?["last_page"] is int
          ? metaMap!["last_page"] as int
          : int.tryParse(metaMap?["last_page"]?.toString() ?? '') ?? 1;
      final perPage = metaMap?["per_page"] is int
          ? metaMap!["per_page"] as int
          : int.tryParse(metaMap?["per_page"]?.toString() ?? '') ??
              parsedJobs.length;
      final total = metaMap?["total"] is int
          ? metaMap!["total"] as int
          : int.tryParse(metaMap?["total"]?.toString() ?? '') ??
              parsedJobs.length;
      final hasMore = metaMap?["has_more"] is bool
          ? metaMap!["has_more"] as bool
          : curPage < lastPage;

      final isSuccess = json["success"] == true || json["status"] == true;

      return JobListModel(
        status: isSuccess,
        success: isSuccess,
        message: json["message"]?.toString(),
        jobs: Jobs(
          currentPage: curPage,
          lastPage: lastPage,
          perPage: perPage,
          total: total,
          hasMore: hasMore,
          data: parsedJobs,
        ),
      );
    }

    // 2. Legacy format: json["jobs"]
    final isSuccess = json["status"] == true || json["success"] == true;
    return JobListModel(
      status: isSuccess,
      success: isSuccess,
      message: json["message"]?.toString(),
      jobs: json["jobs"] == null ? null : Jobs.fromJson(json["jobs"]),
    );
  }

  JobListModel copyWith({
    bool? status,
    bool? success,
    String? message,
    Jobs? jobs,
    List<JobDepartment>? departments,
  }) =>
      JobListModel(
        status: status ?? this.status,
        success: success ?? this.success,
        message: message ?? this.message,
        jobs: jobs ?? this.jobs,
        departments: departments ?? this.departments,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "message": message,
        "jobs": jobs?.toJson(),
        "departments": departments?.map((x) => x.toJson()).toList(),
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
  final bool? hasMore;

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
    this.hasMore,
  });

  factory Jobs.fromJson(Map<String, dynamic> json) => Jobs(
        currentPage: json["current_page"] is int
            ? json["current_page"] as int
            : int.tryParse(json["current_page"]?.toString() ?? ''),
        data: json["data"] == null
            ? []
            : List<Job>.from(
                (json["data"] as List).whereType<Map>().map((x) => Job.fromJson(
                    x is Map<String, dynamic>
                        ? x
                        : Map<String, dynamic>.from(x)))),
        firstPageUrl: json["first_page_url"]?.toString(),
        from: json["from"] is int
            ? json["from"] as int
            : int.tryParse(json["from"]?.toString() ?? ''),
        lastPage: json["last_page"] is int
            ? json["last_page"] as int
            : int.tryParse(json["last_page"]?.toString() ?? ''),
        lastPageUrl: json["last_page_url"]?.toString(),
        links: json["links"] == null
            ? []
            : List<Link>.from((json["links"] as List).whereType<Map>().map(
                (x) => Link.fromJson(x is Map<String, dynamic>
                    ? x
                    : Map<String, dynamic>.from(x)))),
        nextPageUrl: json["next_page_url"],
        path: json["path"]?.toString(),
        perPage: json["per_page"] is int
            ? json["per_page"] as int
            : int.tryParse(json["per_page"]?.toString() ?? ''),
        prevPageUrl: json["prev_page_url"],
        to: json["to"] is int
            ? json["to"] as int
            : int.tryParse(json["to"]?.toString() ?? ''),
        total: json["total"] is int
            ? json["total"] as int
            : int.tryParse(json["total"]?.toString() ?? ''),
        hasMore: json["has_more"] is bool
            ? json["has_more"] as bool
            : null,
      );

  Jobs copyWith({
    int? currentPage,
    List<Job>? data,
    String? firstPageUrl,
    int? from,
    int? lastPage,
    String? lastPageUrl,
    List<Link>? links,
    dynamic nextPageUrl,
    String? path,
    int? perPage,
    dynamic prevPageUrl,
    int? to,
    int? total,
    bool? hasMore,
  }) =>
      Jobs(
        currentPage: currentPage ?? this.currentPage,
        data: data ?? this.data,
        firstPageUrl: firstPageUrl ?? this.firstPageUrl,
        from: from ?? this.from,
        lastPage: lastPage ?? this.lastPage,
        lastPageUrl: lastPageUrl ?? this.lastPageUrl,
        links: links ?? this.links,
        nextPageUrl: nextPageUrl ?? this.nextPageUrl,
        path: path ?? this.path,
        perPage: perPage ?? this.perPage,
        prevPageUrl: prevPageUrl ?? this.prevPageUrl,
        to: to ?? this.to,
        total: total ?? this.total,
        hasMore: hasMore ?? this.hasMore,
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
        "has_more": hasMore,
      };
}

class Job {
  final int? id;
  final String? title;
  final String? slug;
  final String? imageUrl;
  final int? departmentId;
  final String? departmentName;
  final String? companyName;
  final String? source;
  final String? sourceFile;
  final String? details;
  final String? description;
  final String? applicationLink;
  final String? ageLimit;
  final String? salary;
  final String? vacancy;
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
    this.imageUrl,
    this.departmentId,
    this.departmentName,
    this.companyName,
    this.source,
    this.sourceFile,
    this.details,
    this.description,
    this.applicationLink,
    this.ageLimit,
    this.salary,
    this.vacancy,
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

  factory Job.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      final str = val.toString().trim();
      if (str.isEmpty) return null;
      try {
        return DateTime.parse(str);
      } catch (_) {
        return null;
      }
    }

    final id = json["id"] is int
        ? json["id"] as int
        : int.tryParse(json["id"]?.toString() ?? '');

    final deptName = json["department_name"]?.toString() ??
        json["company_name"]?.toString();
    final imgUrl = json["image_url"]?.toString();
    final srcFile = json["source_file"]?.toString() ?? imgUrl;
    final appLink = json["application_link"]?.toString();
    final src = json["source"]?.toString() ?? appLink;
    final desc = json["description"]?.toString();
    final det = json["details"]?.toString() ?? desc;
    final vac = json["vacancy"]?.toString();
    final age = json["age_limit"]?.toString();
    final sal = json["salary"]?.toString();

    final deptId = json["department_id"] is int
        ? json["department_id"] as int
        : int.tryParse(json["department_id"]?.toString() ?? '');

    return Job(
      id: id,
      title: json["title"]?.toString(),
      slug: json["slug"]?.toString(),
      imageUrl: imgUrl,
      departmentId: deptId,
      departmentName: deptName,
      companyName: deptName,
      source: src,
      sourceFile: srcFile,
      details: det,
      description: desc,
      applicationLink: appLink,
      ageLimit: age,
      salary: sal,
      vacancy: vac,
      deadline: parseDate(json["deadline"]),
      publishedDate: parseDate(json["published_date"]),
      isFeatured: json["is_featured"] is bool
          ? json["is_featured"] as bool
          : (json["is_featured"] == 1),
      status: json["status"] is bool
          ? json["status"] as bool
          : (json["status"] == 1),
      views: json["views"] is int
          ? json["views"] as int
          : int.tryParse(json["views"]?.toString() ?? ''),
      approvedAt: json["approved_at"],
      metaTitle: json["meta_title"],
      metaDescription: json["meta_description"],
      metaKeywords: json["meta_keywords"],
      metaImage: json["meta_image"]?.toString(),
      metaAuthor: json["meta_author"],
      metaUrl: json["meta_url"],
      metaData: json["meta_data"],
      headerCode: json["header_code"],
      footerCode: json["footer_code"],
      createdAt: parseDate(json["created_at"]),
      updatedAt: parseDate(json["updated_at"]),
      deletedAt: json["deleted_at"],
    );
  }

  Job copyWith({
    int? id,
    String? title,
    String? slug,
    String? imageUrl,
    int? departmentId,
    String? departmentName,
    String? companyName,
    String? source,
    String? sourceFile,
    String? details,
    String? description,
    String? applicationLink,
    String? ageLimit,
    String? salary,
    String? vacancy,
    DateTime? deadline,
    DateTime? publishedDate,
    bool? isFeatured,
    bool? status,
    int? views,
    dynamic approvedAt,
    dynamic metaTitle,
    dynamic metaDescription,
    dynamic metaKeywords,
    String? metaImage,
    dynamic metaAuthor,
    dynamic metaUrl,
    dynamic metaData,
    dynamic headerCode,
    dynamic footerCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic deletedAt,
  }) =>
      Job(
        id: id ?? this.id,
        title: title ?? this.title,
        slug: slug ?? this.slug,
        imageUrl: imageUrl ?? this.imageUrl,
        departmentId: departmentId ?? this.departmentId,
        departmentName: departmentName ?? this.departmentName,
        companyName: companyName ?? this.companyName,
        source: source ?? this.source,
        sourceFile: sourceFile ?? this.sourceFile,
        details: details ?? this.details,
        description: description ?? this.description,
        applicationLink: applicationLink ?? this.applicationLink,
        ageLimit: ageLimit ?? this.ageLimit,
        salary: salary ?? this.salary,
        vacancy: vacancy ?? this.vacancy,
        deadline: deadline ?? this.deadline,
        publishedDate: publishedDate ?? this.publishedDate,
        isFeatured: isFeatured ?? this.isFeatured,
        status: status ?? this.status,
        views: views ?? this.views,
        approvedAt: approvedAt ?? this.approvedAt,
        metaTitle: metaTitle ?? this.metaTitle,
        metaDescription: metaDescription ?? this.metaDescription,
        metaKeywords: metaKeywords ?? this.metaKeywords,
        metaImage: metaImage ?? this.metaImage,
        metaAuthor: metaAuthor ?? this.metaAuthor,
        metaUrl: metaUrl ?? this.metaUrl,
        metaData: metaData ?? this.metaData,
        headerCode: headerCode ?? this.headerCode,
        footerCode: footerCode ?? this.footerCode,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "slug": slug,
        "image_url": imageUrl,
        "department_id": departmentId,
        "department_name": departmentName,
        "company_name": companyName,
        "source": source,
        "source_file": sourceFile,
        "details": details,
        "description": description,
        "application_link": applicationLink,
        "age_limit": ageLimit,
        "salary": salary,
        "vacancy": vacancy,
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

class JobDepartment {
  final int? id;
  final String? name;
  final String? slug;

  const JobDepartment({
    this.id,
    this.name,
    this.slug,
  });

  factory JobDepartment.fromJson(Map<String, dynamic> json) => JobDepartment(
        id: json["id"] is int
            ? json["id"] as int
            : int.tryParse(json["id"]?.toString() ?? ''),
        name: json["name"]?.toString(),
        slug: json["slug"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobDepartment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
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
        url: json["url"]?.toString(),
        label: json["label"]?.toString(),
        active: json["active"] is bool ? json["active"] as bool : null,
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
      };
}
