import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/course/data/models/course_details_model.dart';
import 'package:lokkha/features/course/data/models/course_learning_model.dart';
import 'package:lokkha/features/course/data/models/v1_course_category_model.dart';
import 'package:lokkha/features/course/data/models/v1_courses_response.dart';
import 'package:lokkha/features/course/domain/repositories/courses_repository.dart';

final coursesRepositoryProvider = Provider<CoursesRepository>((ref) {
  return CoursesRepositoryImpl();
});

class CoursesRepositoryImpl implements CoursesRepository {
  final RestClient _client;

  CoursesRepositoryImpl({RestClient? client}) : _client = client ?? RestClient();

  Map<String, String> _buildHeaders() {
    var token = MySharedPref.getUserToken();
    if (token.isEmpty && myUser.jwtToken != null && myUser.jwtToken!.isNotEmpty) {
      token = myUser.jwtToken!;
    }
    return {
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  @override
  Future<List<V1CourseCategoryModel>> getCourseCategories() async {
    try {
      final response = await _client.get(
        Endpoints.v1CourseCategories,
        headers: _buildHeaders(),
      );

      final rawData = response.data;
      if (rawData != null &&
          (rawData['success'] == true || rawData['status'] == true)) {
        final list = rawData['data'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map((e) => V1CourseCategoryModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching v1 course categories: $e');
      // Fallback to legacy endpoint if available
      try {
        final legacyRes = await _client.get(
          Endpoints.courseCategories,
          headers: _buildHeaders(),
        );
        if (legacyRes.data != null && legacyRes.data['data'] is List) {
          return (legacyRes.data['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => V1CourseCategoryModel.fromJson(e))
              .toList();
        }
      } catch (_) {}
    }
    return const [];
  }

  @override
  Future<V1CoursesResponse> getCourses({
    int? categoryId,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (categoryId != null && categoryId > 0) {
      queryParams['category_id'] = categoryId;
      queryParams['course_category_id'] = categoryId;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final publicHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final response = await _client.get(
        Endpoints.v1Courses,
        queryParameters: queryParams,
        headers: publicHeaders,
        options: Options(extra: {'skipAuth': true}),
      );

      final rawData = response.data;
      if (rawData != null &&
          (rawData['success'] == true ||
              rawData['status'] == true ||
              rawData['data'] != null)) {
        final parsed = V1CoursesResponse.fromJson(rawData as Map<String, dynamic>);
        if (categoryId != null && categoryId > 0) {
          final filtered = parsed.items.where((c) {
            return c.category?.id == categoryId;
          }).toList();
          return V1CoursesResponse(
            success: parsed.success,
            message: parsed.message,
            items: filtered,
            totalCourses: filtered.length,
            meta: parsed.meta,
          );
        }
        return parsed;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching v1 courses: $e');

      // Fallback to legacy endpoint
      try {
        final legacyParams = <String, dynamic>{
          'page': page,
          if (categoryId != null && categoryId > 0) 'category_id': categoryId,
          if (search != null && search.isNotEmpty) 'search': search,
        };
        final legacyRes = await _client.get(
          Endpoints.courses,
          queryParameters: legacyParams,
          headers: publicHeaders,
          options: Options(extra: {'skipAuth': true}),
        );
        if (legacyRes.data != null) {
          final parsed = V1CoursesResponse.fromJson(legacyRes.data as Map<String, dynamic>);
          if (categoryId != null && categoryId > 0) {
            final filtered = parsed.items.where((c) {
              return c.category?.id == categoryId;
            }).toList();
            return V1CoursesResponse(
              success: parsed.success,
              message: parsed.message,
              items: filtered,
              totalCourses: filtered.length,
              meta: parsed.meta,
            );
          }
          return parsed;
        }
      } catch (_) {}
    }

    return const V1CoursesResponse(
      success: false,
      items: [],
      totalCourses: 0,
    );
  }

  @override
  Future<CourseDetailsModel?> getUserCourseDetails(int courseId) async {
    try {
      final response = await _client.get(
        Endpoints.v1UserCourseDetails(courseId),
        headers: _buildHeaders(),
      );
      if (response.data != null &&
          (response.data['status'] == true ||
              response.data['success'] == true ||
              response.data['data'] != null)) {
        final model = CourseDetailsModel.fromJson(response.data as Map<String, dynamic>);
        return model;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching user course details for $courseId: $e');
    }
    return null;
  }

  @override
  Future<CourseLearningModel?> getCourseLearning(int courseId, {int? itemId}) async {
    final queryParams = <String, dynamic>{
      if (itemId != null) 'item': itemId,
    };

    try {
      final response = await _client.get(
        Endpoints.v1UserLearning(courseId),
        queryParameters: queryParams,
        headers: _buildHeaders(),
      );
      if (response.data != null &&
          (response.data['status'] == true ||
              response.data['success'] == true ||
              response.data['data'] != null)) {
        return CourseLearningModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching v1 course learning for $courseId: $e');
      // Fallback to legacy endpoint
      try {
        String legacyUrl = '${Endpoints.courseLearn}/$courseId';
        if (itemId != null) {
          legacyUrl = '$legacyUrl?item=$itemId';
        }
        final legacyRes = await _client.get(
          legacyUrl,
          headers: _buildHeaders(),
        );
        if (legacyRes.data != null) {
          return CourseLearningModel.fromJson(legacyRes.data as Map<String, dynamic>);
        }
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<CourseDetailsModel?> getCourseDetails(int courseId) async {
    final token = MySharedPref.getUserToken();
    final bool isLoggedIn = token.isNotEmpty;

    // 1. If user is logged in, first attempt to fetch enrolled course details
    if (isLoggedIn) {
      try {
        final userModel = await getUserCourseDetails(courseId);
        if (userModel != null && userModel.course != null && userModel.course!.id != null) {
          // If the course does not have syllabus modules loaded, fetch them from classroom
          var course = userModel.course!;
          if (course.modules == null || course.modules!.isEmpty) {
            try {
              final learningModel = await getCourseLearning(courseId);
              if (learningModel?.data != null && learningModel!.data!.syllabus.isNotEmpty) {
                course = course.copyWith(modules: learningModel.data!.syllabus);
              }
            } catch (_) {}
          }
          return CourseDetailsModel(
            status: true,
            course: course,
          );
        }
      } catch (e) {
        if (kDebugMode) debugPrint('User course details check skipped/failed for $courseId: $e');
      }
    }

    // 2. Fetch public course details
    try {
      final response = await _client.get(
        Endpoints.v1CourseDetails(courseId),
        headers: _buildHeaders(),
      );
      if (response.data != null &&
          (response.data['status'] == true ||
              response.data['success'] == true ||
              response.data['data'] != null)) {
        final model = CourseDetailsModel.fromJson(response.data as Map<String, dynamic>);
        return model;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching v1 course details: $e');
      // Fallback to legacy endpoint if available
      try {
        final legacyRes = await _client.get(
          '${Endpoints.courseDetails}/$courseId',
          headers: _buildHeaders(),
        );
        if (legacyRes.data != null) {
          final model = CourseDetailsModel.fromJson(legacyRes.data as Map<String, dynamic>);
          return model;
        }
      } catch (_) {}
    }
    return null;
  }
}
