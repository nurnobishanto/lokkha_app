import 'package:lokkha/features/course/data/models/course_details_model.dart';
import 'package:lokkha/features/course/data/models/v1_course_category_model.dart';
import 'package:lokkha/features/course/data/models/v1_courses_response.dart';

abstract class CoursesRepository {
  /// Retrieves list of course categories (/api/v1/courses/categories)
  Future<List<V1CourseCategoryModel>> getCourseCategories();

  /// Retrieves filtered or all courses (/api/v1/courses?course_category_id=...)
  Future<V1CoursesResponse> getCourses({
    int? categoryId,
    String? search,
    int page = 1,
    int perPage = 20,
  });

  /// Retrieves full course details (/api/v1/courses/$id or /api/course/$id)
  Future<CourseDetailsModel?> getCourseDetails(int courseId);
}
