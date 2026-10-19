import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/auth/presentation/providers/central_auth_notifier.dart';
import 'package:lokkha/shared/models/user.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CentralAuthNotifier & Riverpod Auth State Tests', () {
    late ProviderContainer container;

    setUp(() {
      isLoggedIn.value = false;
      havePackage.value = false;
      myUser = User();
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state reflects logged out when no session exists', () {
      final authState = container.read(centralAuthStateProvider);
      expect(authState.isLoggedIn, isFalse);
      expect(container.read(isLoggedInProvider), isFalse);
      expect(container.read(hasPackageProvider), isFalse);
      expect(container.read(currentUserProvider), isNull);
    });

    test('setAuthenticated updates Riverpod state and synchronizes global.dart',
        () {
      final testUser = User(
        id: 101,
        name: 'Sadman Sakib',
        phone: '01712345678',
        email: 'sadman@test.com',
      );

      container
          .read(centralAuthStateProvider.notifier)
          .setAuthenticated(testUser, hasPackageStatus: true);

      final state = container.read(centralAuthStateProvider);
      expect(state.isLoggedIn, isTrue);
      expect(state.hasPackage, isTrue);
      expect(state.user?.name, 'Sadman Sakib');

      // Check Riverpod convenience selectors
      expect(container.read(isLoggedInProvider), isTrue);
      expect(container.read(hasPackageProvider), isTrue);
      expect(container.read(currentUserProvider)?.phone, '01712345678');

      // Check legacy global synchronization
      expect(isLoggedIn.value, isTrue);
      expect(havePackage.value, isTrue);
      expect(myUser.name, 'Sadman Sakib');
    });

    test('Legacy bridge synchronizes when global.dart ValueNotifier changes',
        () {
      // Container reads notifier to activate listeners
      container.read(centralAuthStateProvider);

      // Simulate legacy code modifying isLoggedIn directly
      isLoggedIn.value = true;
      expect(container.read(isLoggedInProvider), isTrue);

      // Simulate legacy code modifying havePackage directly
      havePackage.value = true;
      expect(container.read(hasPackageProvider), isTrue);
    });

    test('updatePackageStatus updates package access reactively', () {
      final notifier = container.read(centralAuthStateProvider.notifier);

      notifier.updatePackageStatus(true);
      expect(container.read(hasPackageProvider), isTrue);
      expect(havePackage.value, isTrue);

      notifier.updatePackageStatus(false);
      expect(container.read(hasPackageProvider), isFalse);
      expect(havePackage.value, isFalse);
    });

    test('logout resets both Riverpod state and global ValueNotifiers',
        () async {
      final notifier = container.read(centralAuthStateProvider.notifier);
      final testUser = User(id: 102, name: 'User 2', phone: '01812345678');

      notifier.setAuthenticated(testUser, hasPackageStatus: true);
      expect(container.read(isLoggedInProvider), isTrue);

      await notifier.logout();

      expect(container.read(isLoggedInProvider), isFalse);
      expect(container.read(hasPackageProvider), isFalse);
      expect(container.read(currentUserProvider), isNull);
      expect(isLoggedIn.value, isFalse);
      expect(havePackage.value, isFalse);
    });
  });
}
