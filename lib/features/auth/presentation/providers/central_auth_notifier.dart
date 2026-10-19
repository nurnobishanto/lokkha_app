import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/services/storage/app_storage_cache.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/core/services/storage/secure_storage_service.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/di/auth_provider.dart';
import 'package:lokkha/shared/models/user.dart';

/// Central Immutable State for Authentication & User Session
class CentralAuthState {
  final User? user;
  final bool isLoggedIn;
  final bool hasPackage;
  final bool isLoading;
  final String? errorMessage;

  const CentralAuthState({
    this.user,
    this.isLoggedIn = false,
    this.hasPackage = false,
    this.isLoading = false,
    this.errorMessage,
  });

  CentralAuthState copyWith({
    User? Function()? user,
    bool? isLoggedIn,
    bool? hasPackage,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return CentralAuthState(
      user: user != null ? user() : this.user,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      hasPackage: hasPackage ?? this.hasPackage,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CentralAuthState &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          isLoggedIn == other.isLoggedIn &&
          hasPackage == other.hasPackage &&
          isLoading == other.isLoading &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      user.hashCode ^
      isLoggedIn.hashCode ^
      hasPackage.hashCode ^
      isLoading.hashCode ^
      errorMessage.hashCode;
}

/// Central Riverpod Notifier for Single Source of Truth Auth State.
/// Also bridges and synchronizes with legacy global.dart ValueNotifiers for 100% backward compatibility.
class CentralAuthNotifier extends Notifier<CentralAuthState> {
  VoidCallback? _loginListener;
  VoidCallback? _packageListener;

  @override
  CentralAuthState build() {
    // 1. Initial hydration from cache
    final cached = _hydrateFromCache();

    // 2. Set up legacy bridge listener to keep Riverpod in sync if legacy code alters ValueNotifiers
    _setupLegacyBridge();

    ref.onDispose(() {
      if (_loginListener != null) {
        isLoggedIn.removeListener(_loginListener!);
      }
      if (_packageListener != null) {
        havePackage.removeListener(_packageListener!);
      }
    });

    return cached;
  }

  CentralAuthState _hydrateFromCache() {
    try {
      final cachedUserRaw = MyGetStorage.readCache(MyGetStorage.meUser);
      User? cachedUser;
      if (cachedUserRaw is User) {
        cachedUser = cachedUserRaw;
      } else if (cachedUserRaw is Map<String, dynamic>) {
        cachedUser = User.fromJson(cachedUserRaw);
      }

      final prefToken = MySharedPref.getUserToken();
      final bool hasToken = prefToken.isNotEmpty || isLoggedIn.value;
      final bool pkgActive = havePackage.value ||
          (cachedUser?.hasActiveSubscription == true) ||
          (cachedUser?.isSubscribed == true) ||
          (cachedUser?.activePackage != null);

      if (cachedUser != null) {
        myUser = cachedUser;
      }

      return CentralAuthState(
        user: cachedUser,
        isLoggedIn: hasToken,
        hasPackage: pkgActive,
      );
    } catch (e) {
      log('⚠️ CentralAuthNotifier hydration error: $e');
      return const CentralAuthState();
    }
  }

  void _setupLegacyBridge() {
    _loginListener = () {
      if (state.isLoggedIn != isLoggedIn.value) {
        state = state.copyWith(isLoggedIn: isLoggedIn.value);
      }
    };
    isLoggedIn.addListener(_loginListener!);

    _packageListener = () {
      if (state.hasPackage != havePackage.value) {
        state = state.copyWith(hasPackage: havePackage.value);
      }
    };
    havePackage.addListener(_packageListener!);
  }

  /// Sets authenticated user upon login or register
  void setAuthenticated(User user, {bool? hasPackageStatus}) {
    final bool isPkg = hasPackageStatus ??
        (user.hasActiveSubscription == true) ||
        (user.isSubscribed == true) ||
        (user.activePackage != null);

    // Update global state and cache
    myUser = user;
    isLoggedIn.value = true;
    havePackage.value = isPkg;
    MyGetStorage.writeCacheData(MyGetStorage.meUser, user);

    state = state.copyWith(
      user: () => user,
      isLoggedIn: true,
      hasPackage: isPkg,
      isLoading: false,
      errorMessage: () => null,
    );
  }

  /// Updates premium package status reactively
  void updatePackageStatus(bool isPremium) {
    havePackage.value = isPremium;
    state = state.copyWith(hasPackage: isPremium);
  }

  /// Refresh latest user profile from API
  Future<void> refreshProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final res = await authRepo.getCurrentUser();

      if (res != null && res.status && res.user != null) {
        setAuthenticated(res.user!, hasPackageStatus: res.havePackage);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      log('❌ Failed to refresh profile: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => e.toString(),
      );
    }
  }

  /// Logs out user cleanly across all storages and states
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      final logoutUseCase = ref.read(logoutUseCaseProvider);
      await logoutUseCase();
    } catch (_) {}

    // Clear storages safely
    try {
      await SecureStorageService.clearAuthData();
    } catch (_) {}
    try {
      await MySharedPref.removeUserToken();
    } catch (_) {}
    try {
      await MyGetStorage.removeCache(MyGetStorage.meUser);
    } catch (_) {}

    // Clear global variables
    myUser = User();
    isLoggedIn.value = false;
    havePackage.value = false;

    state = const CentralAuthState(
      user: null,
      isLoggedIn: false,
      hasPackage: false,
      isLoading: false,
    );
  }
}

/// ── Central Providers ────────────────────────────────────────────────────────

/// 1. Main State Notifier Provider
final centralAuthStateProvider =
    NotifierProvider<CentralAuthNotifier, CentralAuthState>(
        CentralAuthNotifier.new);

/// 2. Current User Provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(centralAuthStateProvider).user;
});

/// 3. Is Logged In Provider (Boolean reactive state)
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(centralAuthStateProvider).isLoggedIn;
});

/// 4. Has Package / Premium Access Provider
final hasPackageProvider = Provider<bool>((ref) {
  return ref.watch(centralAuthStateProvider).hasPackage;
});
