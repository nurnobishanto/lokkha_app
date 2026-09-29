

import 'package:flutter_test/flutter_test.dart';

import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/features/exam/exam.dart';

void main() {
  test('Subject and Course models parse JSON properly with boolean/int types', () {
    final subjectJson = {
      "id": 1,
      "name": "Test Subject",
      "status": true,
      "show_app": true,
      "question_count": 10,
    };
    final subject = Subject.fromJson(subjectJson);
    expect(subject.showApp, isTrue);

    final courseJson = {
      "id": 6,
      "title": "Course Test",
      "is_exam_batch": true,
      "lifetime_access": true,
      "featured": false,
      "status": true,
      "is_enrolled": false,
    };
    final course = Course.fromJson(courseJson);
    expect(course.isExamBatch, isTrue);
    expect(course.lifetimeAccess, isTrue);
    expect(course.featured, isFalse);

    final packageJson = {
      "id": 6,
      "name": "Package Test",
      "is_featured": false,
      "is_mega": false,
      "is_female": false,
      "features": ["f1"],
      "is_trial": false,
      "status": true,
    };
    final package = Package.fromJson(packageJson);
    expect(package.isFeatured, isFalse);
    expect(package.status, isTrue);

    final examCategoriesJson = {
      "status": true,
      "exam-categories": [
        {
          "id": 45,
          "name": "19th NTRCA",
          "slug": "ntrca",
          "free_exams_count": 91
        }
      ]
    };
    final examCategoriesModel = ExamCategoriesModel.fromJson(examCategoriesJson);
    expect(examCategoriesModel.examCategories, isNotEmpty);
    expect(examCategoriesModel.examCategories!.first.name, "19th NTRCA");
    expect(examCategoriesModel.examCategories!.first.freeExamsCount, 91);
  });
}
