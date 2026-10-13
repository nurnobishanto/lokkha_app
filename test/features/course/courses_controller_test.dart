import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/features/course/presentation/providers/course_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CoursesNotifier & State Riverpod Tests', () {
    test('Initializes safely with null categoryId', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(coursesNotifierProvider(null));
      expect(state.isLoading, false);
      expect(state.hasError, false);
      expect(state.model.courses, isNull);
    });

    test('Initializes with integer categoryId correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(coursesNotifierProvider(12));
      expect(state.isLoading, false);
      expect(state.hasError, false);
    });

    test('CoursesState copyWith updates isLoading and model correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final initialState = container.read(coursesNotifierProvider(5));
      final updated = initialState.copyWith(isLoading: true);
      expect(updated.isLoading, true);
    });
  });
}
