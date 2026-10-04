import 'package:intl/intl.dart';
import 'package:lokkha/shared/models/exam.dart';
import 'package:lokkha/shared/models/exam_category.dart';

double _parseDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  if (val is String) {
    return double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  }
  return 0.0;
}

int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is num) return val.toInt();
  if (val is String) {
    return int.tryParse(val) ?? 0;
  }
  return 0;
}

/// Response model for GET /api/v1/user/exams
class UserExamsV1Response {
  final bool success;
  final String? message;
  final List<UserExamV1Item> items;
  final UserExamV1Meta meta;

  UserExamsV1Response({
    this.success = true,
    this.message,
    required this.items,
    required this.meta,
  });

  factory UserExamsV1Response.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final rawItems = data['items'] as List<dynamic>? ?? [];
    final rawMeta = json['meta'] as Map<String, dynamic>? ?? {};

    return UserExamsV1Response(
      success: json['success'] == true || json['status'] == true,
      message: json['message']?.toString(),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map((e) => UserExamV1Item.fromJson(e))
          .toList(),
      meta: UserExamV1Meta.fromJson(rawMeta),
    );
  }
}

/// Single Exam item from GET /api/v1/user/exams
class UserExamV1Item {
  final int id;
  final String name;
  final String slug;
  final String? imageUrl;
  final int durationMinutes;
  final double positiveMark;
  final double negativeMark;
  final int totalQuestions;
  final double totalMarks;
  final bool isPaid;
  final bool userAttempted;
  final int userAttemptsCount;
  final String? createdAt;
  final String? categoryName;

  UserExamV1Item({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
    required this.durationMinutes,
    required this.positiveMark,
    required this.negativeMark,
    required this.totalQuestions,
    required this.totalMarks,
    required this.isPaid,
    required this.userAttempted,
    required this.userAttemptsCount,
    this.createdAt,
    this.categoryName,
  });

  factory UserExamV1Item.fromJson(Map<String, dynamic> json) {
    String? catName;
    if (json['category'] != null && json['category'] is Map) {
      catName = json['category']['name']?.toString();
    } else if (json['category_name'] != null) {
      catName = json['category_name']?.toString();
    }

    return UserExamV1Item(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? json['image']?.toString(),
      durationMinutes: _parseInt(json['duration_minutes'] ?? json['duration']),
      positiveMark: _parseDouble(json['positive_mark']),
      negativeMark: _parseDouble(json['negative_mark']),
      totalQuestions: _parseInt(json['total_questions'] ?? json['questions_count']),
      totalMarks: _parseDouble(json['total_marks'] ?? json['possible_mark']),
      isPaid: json['is_paid'] == true,
      userAttempted: json['user_attempted'] == true || json['attempted'] == true,
      userAttemptsCount: _parseInt(json['user_attempts_count'] ?? json['exam_results_count']),
      createdAt: json['created_at']?.toString() ?? json['published_at']?.toString(),
      categoryName: catName,
    );
  }

  /// Format date to readable e.g. "Sep 22, 2026"
  String get formattedPublishedDate {
    if (createdAt == null || createdAt!.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt!);
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {
      return createdAt!;
    }
  }

  /// Conversion to shared Exam model for 100% compatibility with existing ExamCard and ExamDetailsDialog
  Exam toExam() {
    DateTime? parsedDate;
    if (createdAt != null && createdAt!.isNotEmpty) {
      parsedDate = DateTime.tryParse(createdAt!);
    }

    return Exam(
      id: id,
      name: name,
      slug: slug,
      image: imageUrl,
      duration: durationMinutes,
      positiveMark: positiveMark.toInt(),
      negativeMark: negativeMark,
      questionsCount: totalQuestions,
      possibleMark: totalMarks.toInt(),
      isPaid: isPaid,
      attempted: userAttempted,
      examResultsCount: userAttemptsCount,
      publishedAt: parsedDate,
      examCategory: categoryName != null ? ExamCategory(name: categoryName) : null,
    );
  }
}

/// Metadata model for pagination in GET /api/v1/user/exams
class UserExamV1Meta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;
  final bool hasMore;

  UserExamV1Meta({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 10,
    this.total = 0,
    this.from = 1,
    this.to = 1,
    this.hasMore = false,
  });

  factory UserExamV1Meta.fromJson(Map<String, dynamic> json) {
    final curPage = _parseInt(json['current_page']);
    final lPage = _parseInt(json['last_page']);

    return UserExamV1Meta(
      currentPage: curPage == 0 ? 1 : curPage,
      lastPage: lPage == 0 ? 1 : lPage,
      perPage: _parseInt(json['per_page']) == 0 ? 10 : _parseInt(json['per_page']),
      total: _parseInt(json['total']),
      from: _parseInt(json['from']) == 0 ? 1 : _parseInt(json['from']),
      to: _parseInt(json['to']),
      hasMore: json['has_more'] == true || (lPage > curPage && curPage > 0),
    );
  }
}
