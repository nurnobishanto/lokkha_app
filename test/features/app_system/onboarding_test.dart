import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/features/app_system/domain/models/onboarding_item.dart';
import 'package:lokkha/features/app_system/domain/usecases/get_onboarding_items_usecase.dart';
import 'package:lokkha/features/app_system/presentation/onboarding/riverpod/onboarding_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding Clean Architecture Tests', () {
    test('OnboardingItem entity returns fullTitle correctly', () {
      const item1 = OnboardingItem(
        index: 0,
        imagePath: 'path1',
        titlePrefix: 'স্মার্টভাবে ',
        highlightTitle: 'প্রস্তুতি নাও',
        subtitle: 'সাবটাইটেল ১',
      );
      expect(item1.fullTitle, 'স্মার্টভাবে প্রস্তুতি নাও');

      const item2 = OnboardingItem(
        index: 1,
        imagePath: 'path2',
        titlePrefix: 'তোমার লক্ষ্য অর্জন করো',
        subtitle: 'সাবটাইটেল ২',
      );
      expect(item2.fullTitle, 'তোমার লক্ষ্য অর্জন করো');
    });

    test('GetOnboardingItemsUseCase returns 3 items matching UI specs', () {
      const useCase = GetOnboardingItemsUseCase();
      final items = useCase();

      expect(items.length, 3);
      expect(items[0].imagePath.endsWith('.svg'), isTrue);
      expect(items[0].highlightTitle, 'প্রস্তুতি নাও');
      expect(items[1].titlePrefix, 'তোমার লক্ষ্য অর্জন করো');
      expect(items[2].titlePrefix, 'তোমার অগ্রগতি ট্র্যাক করো');
    });

    test('OnboardingNotifier initializes and handles page changes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialState = container.read(onboardingNotifierProvider);
      expect(initialState.currentPage, 0);
      expect(initialState.items.length, 3);
      expect(initialState.isLastPage, false);

      container.read(onboardingNotifierProvider.notifier).onPageChanged(1);
      expect(container.read(onboardingNotifierProvider).currentPage, 1);
      expect(container.read(onboardingNotifierProvider).isLastPage, false);

      container.read(onboardingNotifierProvider.notifier).onPageChanged(2);
      expect(container.read(onboardingNotifierProvider).currentPage, 2);
      expect(container.read(onboardingNotifierProvider).isLastPage, true);
    });
  });
}
