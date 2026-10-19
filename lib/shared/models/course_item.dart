// ignore_for_file: constant_identifier_names
import 'package:lokkha/core/enums/question_type.dart';
import 'exam.dart';

class CourseItem {
  final int? id;
  final int? courseId;
  final int? courseModuleId;
  final int? moduleId;
  final String? moduleTitle;
  final String? title;
  final String? details;
  final String? detailsHtml;
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
  final bool? isCompleted;
  final bool? isActive;
  final int? lastWatchedSecond;
  final List<Type>? type;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;
  final Exam? exam;
  final CourseItemExamInfo? examInfo;
  final bool? hasExam;

  CourseItem({
    this.id,
    this.courseId,
    this.courseModuleId,
    this.moduleId,
    this.moduleTitle,
    this.title,
    this.details,
    this.detailsHtml,
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
    this.isCompleted,
    this.isActive,
    this.lastWatchedSecond,
    this.type,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.exam,
    this.examInfo,
    this.hasExam,
  });

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    final parsedModuleId = json["module_id"] is int
        ? json["module_id"]
        : (json["course_module_id"] is int
            ? json["course_module_id"]
            : int.tryParse(json["module_id"]?.toString() ?? json["course_module_id"]?.toString() ?? ''));

    final parsedExamInfo = json["exam_info"] is Map<String, dynamic>
        ? CourseItemExamInfo.fromJson(json["exam_info"] as Map<String, dynamic>)
        : null;

    final parsedExamId = json["exam_id"] is int
        ? json["exam_id"]
        : (parsedExamInfo?.examId ?? int.tryParse(json["exam_id"]?.toString() ?? ''));

    List<Type> parsedTypes = [];
    if (json["type"] is List) {
      parsedTypes = (json["type"] as List).map((x) {
        final key = x.toString().toLowerCase().trim();
        return typeValues.map[key];
      }).whereType<Type>().toList();
    } else if (json["type"] is String) {
      final t = typeValues.map[json["type"].toString().toLowerCase().trim()];
      if (t != null) parsedTypes.add(t);
    }

    final bool hasExamCheck = json["has_exam"] == true ||
        parsedExamInfo != null ||
        parsedExamId != null ||
        parsedTypes.contains(Type.EXAM) ||
        (json["type"] is List && (json["type"] as List).any((t) => t.toString().toLowerCase() == 'exam'));

    return CourseItem(
      id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? ''),
      courseId: json["course_id"] is int ? json["course_id"] : int.tryParse(json["course_id"]?.toString() ?? ''),
      courseModuleId: parsedModuleId,
      moduleId: parsedModuleId,
      moduleTitle: json["module_title"]?.toString(),
      title: json["title"]?.toString(),
      details: json["details"]?.toString() ?? json["details_html"]?.toString(),
      detailsHtml: json["details_html"]?.toString() ?? json["details"]?.toString(),
      order: json["order"] is int ? json["order"] : int.tryParse(json["order"]?.toString() ?? ''),
      video: json["video"] ?? json["video_url"],
      image: json["image"] ?? json["image_url"],
      file: (json["file"] ?? json["file_url"])?.toString(),
      examId: parsedExamId,
      youtubeVideo: json["youtube_video"] ?? json["youtube_video_url"] ?? json["youtube_video_id"],
      url: json["url"] ?? json["external_url"],
      btnName: json["btn_name"] ?? json["button_name"],
      youtubePlaylist: json["youtube_playlist"],
      pdf: (json["pdf"] ?? json["pdf_url"])?.toString(),
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
      isCompleted: json["is_completed"] == true || json["is_completed"] == 1 || json["is_completed"] == "1",
      isActive: json["is_active"] == true || json["is_active"] == 1 || json["is_active"] == "1",
      lastWatchedSecond: json["last_watched_second"] is int
          ? json["last_watched_second"]
          : int.tryParse(json["last_watched_second"]?.toString() ?? ''),
      type: parsedTypes,
      publishedAt: json["published_at"] == null
          ? null
          : DateTime.tryParse(json["published_at"].toString()),
      createdAt: json["created_at"] == null
          ? null
          : DateTime.tryParse(json["created_at"].toString()),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.tryParse(json["updated_at"].toString()),
      deletedAt: json["deleted_at"],
      exam: json["exam"] == null ? null : Exam.fromJson(json["exam"]),
      examInfo: parsedExamInfo,
      hasExam: hasExamCheck,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "course_id": courseId,
        "course_module_id": courseModuleId,
        "module_id": moduleId,
        "module_title": moduleTitle,
        "title": title,
        "details": details,
        "details_html": detailsHtml,
        "order": order,
        "video": video,
        "image": image,
        "file": file,
        "exam_id": examId,
        "has_exam": hasExam,
        "youtube_video": youtubeVideo,
        "url": url,
        "btn_name": btnName,
        "youtube_playlist": youtubePlaylist,
        "pdf": pdf,
        "status": status,
        "is_free": isFree,
        "is_completed": isCompleted,
        "is_active": isActive,
        "last_watched_second": lastWatchedSecond,
        "type": type == null
            ? []
            : List<dynamic>.from(type!.map((x) => typeValues.reverse[x])),
        "published_at": publishedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
        "exam": exam?.toJson(),
        "exam_info": examInfo?.toJson(),
      };
}

class CourseItemExamInfo {
  final int? examId;
  final String? title;
  final int? duration;
  final num? positiveMark;
  final num? negativeMark;
  final bool hasAttempted;
  final ExamLatestResult? latestResult;
  final String? portalUrl;

  const CourseItemExamInfo({
    this.examId,
    this.title,
    this.duration,
    this.positiveMark,
    this.negativeMark,
    this.hasAttempted = false,
    this.latestResult,
    this.portalUrl,
  });

  factory CourseItemExamInfo.fromJson(Map<String, dynamic> json) => CourseItemExamInfo(
        examId: json["exam_id"] is int ? json["exam_id"] : int.tryParse(json["exam_id"]?.toString() ?? ''),
        title: json["title"]?.toString(),
        duration: json["duration"] is int ? json["duration"] : int.tryParse(json["duration"]?.toString() ?? ''),
        positiveMark: json["positive_mark"] is num ? json["positive_mark"] : num.tryParse(json["positive_mark"]?.toString() ?? ''),
        negativeMark: json["negative_mark"] is num ? json["negative_mark"] : num.tryParse(json["negative_mark"]?.toString() ?? ''),
        hasAttempted: json["has_attempted"] == true || json["has_attempted"] == 1 || json["has_attempted"] == "1",
        latestResult: json["latest_result"] is Map<String, dynamic>
            ? ExamLatestResult.fromJson(json["latest_result"] as Map<String, dynamic>)
            : null,
        portalUrl: json["portal_url"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "exam_id": examId,
        "title": title,
        "duration": duration,
        "positive_mark": positiveMark,
        "negative_mark": negativeMark,
        "has_attempted": hasAttempted,
        "latest_result": latestResult?.toJson(),
        "portal_url": portalUrl,
      };
}

class ExamLatestResult {
  final int? resultId;
  final num? score;
  final num? scorePercent;
  final String? resultStatus;
  final int? totalQuestions;
  final int? correctAnswers;
  final int? incorrectAnswers;
  final String? attemptedAt;

  const ExamLatestResult({
    this.resultId,
    this.score,
    this.scorePercent,
    this.resultStatus,
    this.totalQuestions,
    this.correctAnswers,
    this.incorrectAnswers,
    this.attemptedAt,
  });

  factory ExamLatestResult.fromJson(Map<String, dynamic> json) => ExamLatestResult(
        resultId: json["result_id"] is int ? json["result_id"] : int.tryParse(json["result_id"]?.toString() ?? ''),
        score: json["score"] is num ? json["score"] : num.tryParse(json["score"]?.toString() ?? ''),
        scorePercent: json["score_percent"] is num ? json["score_percent"] : num.tryParse(json["score_percent"]?.toString() ?? ''),
        resultStatus: json["result_status"]?.toString(),
        totalQuestions: json["total_questions"] is int ? json["total_questions"] : int.tryParse(json["total_questions"]?.toString() ?? ''),
        correctAnswers: json["correct_answers"] is int ? json["correct_answers"] : int.tryParse(json["correct_answers"]?.toString() ?? ''),
        incorrectAnswers: json["incorrect_answers"] is int ? json["incorrect_answers"] : int.tryParse(json["incorrect_answers"]?.toString() ?? ''),
        attemptedAt: json["attempted_at"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "result_id": resultId,
        "score": score,
        "score_percent": scorePercent,
        "result_status": resultStatus,
        "total_questions": totalQuestions,
        "correct_answers": correctAnswers,
        "incorrect_answers": incorrectAnswers,
        "attempted_at": attemptedAt,
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
