import 'package:lokkha/features/exam/data/models/courses_model.dart';
import 'package:lokkha/shared/models/courses.dart';
import 'v1_course_model.dart';

class CoursesPaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  const CoursesPaginationMeta({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 12,
    this.total = 0,
    this.hasMore = false,
  });

  factory CoursesPaginationMeta.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return CoursesPaginationMeta(
      currentPage: parseInt(json['current_page']),
      lastPage: parseInt(json['last_page']),
      perPage: parseInt(json['per_page']),
      total: parseInt(json['total']),
      hasMore: json['has_more'] == true,
    );
  }
}

class V1CoursesResponse {
  final bool success;
  final String? message;
  final List<V1CourseModel> items;
  final int totalCourses;
  final CoursesPaginationMeta meta;

  const V1CoursesResponse({
    this.success = true,
    this.message,
    this.items = const [],
    this.totalCourses = 0,
    this.meta = const CoursesPaginationMeta(),
  });

  factory V1CoursesResponse.fromJson(Map<String, dynamic> json) {
    final bool success =
        json['success'] == true || json['status'] == true || json['status'] == 'success';
    final String? message = json['message']?.toString();

    final List<V1CourseModel> parsedItems = [];

    // Format 1: V1 response -> data.items
    if (json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      if (dataMap['items'] is List) {
        for (final item in dataMap['items']) {
          if (item is Map<String, dynamic>) {
            parsedItems.add(V1CourseModel.fromJson(item));
          }
        }
      }
    } else if (json['data'] is List) {
      // Format 2: Direct list in data
      for (final item in json['data']) {
        if (item is Map<String, dynamic>) {
          parsedItems.add(V1CourseModel.fromJson(item));
        }
      }
    } else if (json['courses'] is Map<String, dynamic>) {
      // Format 3: Legacy format courses.data
      final coursesMap = json['courses'] as Map<String, dynamic>;
      if (coursesMap['data'] is List) {
        for (final item in coursesMap['data']) {
          if (item is Map<String, dynamic>) {
            parsedItems.add(V1CourseModel.fromJson(item));
          }
        }
      }
    }

    final int total = json['data'] is Map<String, dynamic>
        ? (json['data']['total_courses'] is int
            ? json['data']['total_courses']
            : int.tryParse(json['data']['total_courses']?.toString() ?? '0') ?? parsedItems.length)
        : parsedItems.length;

    final CoursesPaginationMeta meta = json['meta'] is Map<String, dynamic>
        ? CoursesPaginationMeta.fromJson(json['meta'])
        : CoursesPaginationMeta(total: total);

    return V1CoursesResponse(
      success: success,
      message: message,
      items: parsedItems,
      totalCourses: total,
      meta: meta,
    );
  }

  /// Converts to legacy CoursesModel for backwards compatibility
  CoursesModel toLegacyCoursesModel() {
    return CoursesModel(
      status: success,
      courses: Courses(
        currentPage: meta.currentPage,
        lastPage: meta.lastPage,
        perPage: meta.perPage,
        total: totalCourses,
        data: items.map((e) => e.toCourse()).toList(),
      ),
    );
  }
}
