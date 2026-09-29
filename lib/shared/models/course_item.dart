import 'package:lokkha/core/enums/question_type.dart';
import 'exam.dart';

class CourseItem {
  final int? id;
  final int? courseId;
  final int? courseModuleId;
  final String? title;
  final String? details;
  final int? order;
  final dynamic video;
  final dynamic image;
  final String? file;
  final int? examId;
  final dynamic youtubeVideo;
  final dynamic url;
  final dynamic btnName;
  final dynamic youtubePlaylist;
  final String? pdf;
  final bool? status;
  final bool? isFree;
  final List<Type>? type;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;
  final Exam? exam;

  CourseItem({
    this.id,
    this.courseId,
    this.courseModuleId,
    this.title,
    this.details,
    this.order,
    this.video,
    this.image,
    this.file,
    this.examId,
    this.youtubeVideo,
    this.url,
    this.btnName,
    this.youtubePlaylist,
    this.pdf,
    this.status,
    this.isFree,
    this.type,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.exam,
  });

  factory CourseItem.fromJson(Map<String, dynamic> json) => CourseItem(
        id: json["id"],
        courseId: json["course_id"],
        courseModuleId: json["course_module_id"],
        title: json["title"],
        details: json["details"],
        order: json["order"],
        video: json["video"],
        image: json["image"],
        file: json["file"],
        examId: json["exam_id"],
        youtubeVideo: json["youtube_video"],
        url: json["url"],
        btnName: json["btn_name"],
        youtubePlaylist: json["youtube_playlist"],
        pdf: json["pdf"],
        status: json["status"] == null
            ? null
            : (json["status"] is bool
                ? json["status"]
                : (json["status"] == 1 || json["status"] == "1" || json["status"] == "true")),
        isFree: json["is_free"] == null
            ? null
            : (json["is_free"] is bool
                ? json["is_free"]
                : (json["is_free"] == 1 || json["is_free"] == "1" || json["is_free"] == "true")),
        type: json["type"] == null
            ? []
            : List<Type>.from(json["type"]!.map((x) => typeValues.map[x]!)),
        publishedAt: json["published_at"] == null
            ? null
            : DateTime.parse(json["published_at"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        exam: json["exam"] == null ? null : Exam.fromJson(json["exam"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "course_id": courseId,
        "course_module_id": courseModuleId,
        "title": title,
        "details": details,
        "order": order,
        "video": video,
        "image": image,
        "file": file,
        "exam_id": examId,
        "youtube_video": youtubeVideo,
        "url": url,
        "btn_name": btnName,
        "youtube_playlist": youtubePlaylist,
        "pdf": pdf,
        "status": status,
        "is_free": isFree,
        "type": type == null
            ? []
            : List<dynamic>.from(type!.map((x) => typeValues.reverse[x])),
        "published_at": publishedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
        "exam": exam?.toJson(),
      };
}

enum Type {
  TEXT,
  EXAM,
  FILE,
  PDF,
  YOUTUBE_VIDEO,
  YOUTUBE_PLAYLIST,
  VIDEO,
  EXTERNAL_LINK,
}

final typeValues = EnumValues({
  "text": Type.TEXT,
  "exam": Type.EXAM,
  "file": Type.FILE,
  "pdf": Type.PDF,
  "youtube_video": Type.YOUTUBE_VIDEO,
  "youtube_playlist": Type.YOUTUBE_PLAYLIST,
  "video": Type.VIDEO,
  "external_link": Type.EXTERNAL_LINK,
});
