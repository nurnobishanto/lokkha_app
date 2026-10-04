import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/course/presentation/courses/controllers/courses_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    Get.reset();
  });

  group('CoursesController Arguments & Parameters Extraction Tests', () {
    test('Initializes safely when Get.arguments is null without throwing NoSuchMethodError', () {
      // Simulate null arguments and empty parameters
      Get.parameters = {};

      expect(() {
        final controller = CoursesController();
        controller.onInit();
        expect(controller.id, isNull);
      }, returnsNormally);
    });

    test('Extracts course_category_id from Map arguments (int)', () {
      Get.parameters = {};
      // Set arguments as Map with int
      Get.routing.args = {'course_category_id': 12};

      final controller = CoursesController();
      controller.onInit();
      expect(controller.id, 12);
    });

    test('Extracts course_category_id from Map arguments (string)', () {
      Get.parameters = {};
      // Set arguments as Map with string
      Get.routing.args = {'course_category_id': '15'};

      final controller = CoursesController();
      controller.onInit();
      expect(controller.id, 15);
    });

    test('Extracts course_category_id from direct integer argument', () {
      Get.parameters = {};
      Get.routing.args = 7;

      final controller = CoursesController();
      controller.onInit();
      expect(controller.id, 7);
    });

    test('Extracts course_category_id from URL parameters (e.g. /courses?course_category_id=5)', () {
      Get.routing.args = null;
      Get.parameters = {'course_category_id': '5'};

      final controller = CoursesController();
      controller.onInit();
      expect(controller.id, 5);
    });
  });
}
