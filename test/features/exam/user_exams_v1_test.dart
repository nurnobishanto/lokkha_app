import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/features/exam/data/models/user_exam_v1_model.dart';
import 'package:lokkha/features/exam/domain/repositories/exam_repository.dart';
import 'package:lokkha/features/exam/domain/usecases/get_user_exams_usecase.dart';
import 'package:lokkha/features/home/presentation/see_all_items/controllers/see_all_items_controller.dart';

class MockExamRepository implements ExamRepository {
  UserExamsV1Response? responseToReturn;
  String? lastFilter;
  int? lastPage;

  @override
  Future<UserExamsV1Response> getUserExams({
    int page = 1,
    int perPage = 10,
    String? filter,
    String? search,
  }) async {
    lastPage = page;
    lastFilter = filter;
    return responseToReturn ??
        UserExamsV1Response(
          success: true,
          items: [],
          meta: UserExamV1Meta(
            currentPage: 1,
            lastPage: 1,
            perPage: 10,
            total: 0,
            from: 0,
            to: 0,
            hasMore: false,
          ),
        );
  }
}

void main() {
  group('User Exams V1 Model & Clean Architecture Tests', () {
    final sampleJson = {
      "success": true,
      "message": "Exams retrieved successfully.",
      "data": {
        "items": [
          {
            "id": 954,
            "name": "সাম্প্রতিক বিষয়াবলী পরীক্ষা -02",
            "slug": "samprtik-bishzablee-preeksha-02",
            "image_url": null,
            "duration_minutes": 6,
            "positive_mark": 1,
            "negative_mark": 0.25,
            "total_questions": 10,
            "total_marks": 10,
            "is_paid": false,
            "user_attempted": false,
            "user_attempts_count": 5,
            "created_at": "2026-10-03 18:28:51",
            "category": {"name": "University Admission"}
          },
          {
            "id": 953,
            "name": "সাম্প্রতিক বিষয়াবলী পরীক্ষা -০১",
            "slug": "samprtik-bishzablee-preeksha-01",
            "image_url": "https://lokkha.com/uploads/exam.png",
            "duration_minutes": 5,
            "positive_mark": 1,
            "negative_mark": 0.25,
            "total_questions": 15,
            "total_marks": 15,
            "is_paid": true,
            "user_attempted": true,
            "user_attempts_count": 22,
            "created_at": "2026-10-03 17:48:42"
          }
        ]
      },
      "meta": {
        "current_page": 1,
        "last_page": 5,
        "per_page": 10,
        "total": 50,
        "from": 1,
        "to": 10,
        "has_more": true
      }
    };

    test('UserExamsV1Response.fromJson correctly parses items and meta', () {
      final response = UserExamsV1Response.fromJson(sampleJson);

      expect(response.success, true);
      expect(response.message, "Exams retrieved successfully.");
      expect(response.items.length, 2);

      final item1 = response.items[0];
      expect(item1.id, 954);
      expect(item1.name, "সাম্প্রতিক বিষয়াবলী পরীক্ষা -02");
      expect(item1.durationMinutes, 6);
      expect(item1.positiveMark, 1.0);
      expect(item1.negativeMark, 0.25);
      expect(item1.totalQuestions, 10);
      expect(item1.totalMarks, 10.0);
      expect(item1.isPaid, false);
      expect(item1.userAttempted, false);
      expect(item1.userAttemptsCount, 5);
      expect(item1.categoryName, "University Admission");

      final item2 = response.items[1];
      expect(item2.id, 953);
      expect(item2.imageUrl, "https://lokkha.com/uploads/exam.png");
      expect(item2.isPaid, true);
      expect(item2.userAttempted, true);
      expect(item2.userAttemptsCount, 22);

      expect(response.meta.currentPage, 1);
      expect(response.meta.lastPage, 5);
      expect(response.meta.total, 50);
      expect(response.meta.hasMore, true);
    });

    test('UserExamV1Item.toExam converts model accurately to Exam entity', () {
      final response = UserExamsV1Response.fromJson(sampleJson);
      final exam = response.items[0].toExam();

      expect(exam.id, 954);
      expect(exam.name, "সাম্প্রতিক বিষয়াবলী পরীক্ষা -02");
      expect(exam.duration, 6);
      expect(exam.questionsCount, 10);
      expect(exam.possibleMark, 10);
      expect(exam.attempted, false);
      expect(exam.examResultsCount, 5);
      expect(exam.examCategory?.name, "University Admission");
    });

    test('GetUserExamsUseCase passes pagination and filter correctly', () async {
      final mockRepo = MockExamRepository();
      mockRepo.responseToReturn = UserExamsV1Response.fromJson(sampleJson);

      final useCase = GetUserExamsUseCase(repository: mockRepo);
      final result = await useCase(page: 2, filter: 'attempted');

      expect(mockRepo.lastPage, 2);
      expect(mockRepo.lastFilter, 'attempted');
      expect(result.items.length, 2);
    });

    test('SeeAllItemsController fetches exams and toggles filters', () async {
      final mockRepo = MockExamRepository();
      mockRepo.responseToReturn = UserExamsV1Response.fromJson(sampleJson);
      final useCase = GetUserExamsUseCase(repository: mockRepo);

      final controller = SeeAllItemsController(getUserExamsUseCase: useCase);
      await controller.fetchAllExams(page: 1);

      expect(controller.examApiCallStatus.value, ApiCallStatus.success);
      expect(controller.examsList.length, 2);
      expect(controller.currentExamPage.value, 1);
      expect(controller.totalExamPages.value, 5);

      // Filter toggle testing
      controller.setFilter('attempted');
      expect(controller.selectedFilter.value, 'attempted');
      expect(mockRepo.lastFilter, 'attempted');

      // Toggling same filter resets to 'all'
      controller.setFilter('attempted');
      expect(controller.selectedFilter.value, 'all');
      expect(mockRepo.lastFilter, null);
    });
  });
}
