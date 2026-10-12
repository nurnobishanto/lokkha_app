# 🏗️ Lokkha App — V2 Architecture Plan

**Branch:** `feature/v2-major-redesign`  
**Base Branch:** `web-exams`  
**Date:** 2026-06-22  
**Status:** Awaiting Approval — No code changes made yet

---

## Executive Summary

This document covers 5 priority areas:
1. **Premium Access Security Bug Fix** — Centralized entitlement validation
2. **GoRouter Migration** — Replace GetX named routing
3. **Theme System Refactor** — Material3-compliant design system
4. **Dependency Injection Audit** — Remove anti-patterns
5. **Architecture Improvements** — Repository layer, auth interceptor, secure storage

> [!IMPORTANT]
> No implementation will begin until this document is reviewed and explicitly approved.

---

## User Review Required

> [!CAUTION]
> **Priority #1 (Premium Security)** involves touching the auth flow, `havePackage` global state, and `AuthService`. This requires careful, incremental changes. Any mistake here could lock out legitimate paying users.

> [!WARNING]
> **GoRouter Migration** is the highest-risk change in this plan. GetX and GoRouter have fundamentally different philosophies around navigation state. All deep links, push notification navigation, and back-stack behavior must be retested after migration.

> [!WARNING]
> The `PremiumPackageCheckoutController` currently accesses `NavbarController` directly during field initialization (not in `onInit`). This creates a crash if NavbarController's profile data is null. This must be fixed before GoRouter migration.

---

## Open Questions

> [!IMPORTANT]
> **Q1:** Does "premium access" mean the user has ANY active package, or a specific package tier? The current `havePackage` flag is a single boolean — is this intentional, or should different package tiers unlock different features?

> [!IMPORTANT]
> **Q2:** After a user's package expires, should they see a paywall immediately, or should they be allowed to complete their current session? This impacts the entitlement check frequency.

> [!IMPORTANT]
> **Q3:** The IAP service maps product IDs to "credit days" (90/180/365). Is this the source of truth for expiry, or does the backend track expiry independently?

> [!IMPORTANT]
> **Q4:** The `PaymentWebView` redirects to `order-details` URL to indicate payment success. After this redirect, should the app re-call `authCheck` to refresh the `havePackage` status? There is currently NO post-payment entitlement refresh.

> [!IMPORTANT]
> **Q5:** GoRouter does not support `Get.offAll()` / `Get.back()` / `Get.dialog()` patterns. Do you want to keep GetX dialogs and snackbars, or migrate those too?

---

## Part 1: Premium Access Security Analysis

### 1.1 Current Implementation — What Exists

```
Global State:     global.dart → RxBool havePackage = false.obs
Set in:           AuthService.authCheck() → havePackage.value = response["havePackage"]
Also set in:      NavbarController.getMeProfileInfo() → does NOT set havePackage
Guard mechanism:  PackageRequiredPopup shown manually in individual controllers/views
IAP flow:         InAppPurchaseService._verifyAndDeliver() → calls onDelivered callback
Post-payment:     PaymentWebView → 'order-details' URL → OrderDetailsScreen
                  → havePackage is NEVER refreshed after web payment completes
```

### 1.2 Identified Security Vulnerabilities

#### 🔴 CRITICAL — havePackage Never Refreshed After Web Payment
```
User → PremiumPackagesView → makePayment() → PaymentWebView → order-details URL
                                                                       ↓
                                                       havePackage stays FALSE
                                                       User must restart app to get access
```

#### 🔴 CRITICAL — No Premium Gate in CourseLearnController
```dart
// CourseLearnController.onInit() only checks isLoggedIn:
if (!isLoggedIn.value) {
  Get.offAllNamed(Routes.AUTH_GATEWAY);
  return;
}
// ❌ NEVER checks havePackage — any logged-in user can watch premium content
```

#### 🔴 CRITICAL — havePackage Not Re-Validated on Screen Return
```
When user navigates back to a premium screen:
 - Controller is still in memory
 - havePackage.value is the old cached value from app start
 - No re-validation occurs
 - User sees premium content even if their package has expired
```

#### 🟡 MAJOR — AuthService.authCheck() Not Called Periodically
```
authCheck() is only called:
  1. Once on NavbarController.onInit() (app start)
  2. On manual trigger only
  → No periodic re-validation (unlike AppUpdateService which polls every minute)
```

#### 🟡 MAJOR — PremiumPackageCheckoutController CRASH RISK
```dart
// Field initializer runs BEFORE onInit — DI may not be ready:
final Rx<TextEditingController> nameController = TextEditingController(
  text: Get.find<NavbarController>().profileDataModel.value!.user!.name ?? '',
  //                                                             ^ NULL CRASH
).obs;
```

#### 🟡 MAJOR — IAP _verifyAndDeliver() Has No Server Verification
```
_verifyAndDeliver calls onDelivered(productId, credits)
Caller's callback is responsible for updating backend
If callback fails silently → local credits delivered but server not updated
No retry mechanism
```

#### 🟠 MINOR — havePackage Has No Expiry Timestamp
```
RxBool havePackage = false.obs;
→ Only true/false — no expiry date
→ Cannot check "expires in 3 days"
→ Cannot auto-expire at midnight
```

### 1.3 Proposed Solution — PremiumEntitlementService

```dart
/// lib/app/services/premium_entitlement_service.dart
class PremiumEntitlementService extends GetxService {
  // Single source of truth
  final RxBool hasActivePremium = false.obs;
  final Rx<DateTime?> packageExpiresAt = Rx<DateTime?>(null);
  final RxString activePackageName = ''.obs;

  DateTime? _lastValidated;
  static const _cacheDuration = Duration(minutes: 5);

  /// Call on app start, app resume, and after any purchase
  Future<void> validateEntitlement() async { ... }

  /// True only if premium AND not expired
  bool get isPremiumValid => hasActivePremium.value && _isNotExpired();

  /// Call after PaymentWebView order-details redirect
  Future<void> refreshAfterPurchase() async { ... }

  /// Use in route guards and controller onInit
  void assertPremiumAccess({VoidCallback? onDenied}) { ... }
}
```

**Integration Points:**
- `SplashController.onInit()` → call `validateEntitlement()`
- `PaymentWebView.onNavigationRequest()` on `order-details` → call `refreshAfterPurchase()`
- `InAppPurchaseService._verifyAndDeliver()` → call `refreshAfterPurchase()`
- `AppLifecycleService` (app resume) → call `validateEntitlement()`
- Every premium controller `onInit()` → call `assertPremiumAccess()`

---

## Part 2: GoRouter Migration Plan

### 2.1 Current Navigation — What Exists

```
Package:       get: ^4.6.6 → GetMaterialApp + GetPage routing
Initial Route: Routes.SPLASH (/splash)
Total routes:  ~55 named routes (some commented-out / broken)
Deep links:    Manual via MyAppController + app_links package
Guards:        NONE — auth/premium checks are in-controller, not at route level
Pattern:       Get.toNamed(), Get.offAllNamed(), Get.back(), Get.to()
Nested routes: 1 case only (AllContest child of Contest)
```

### 2.2 Why GoRouter

| Concern | GetX Routing | GoRouter |
|---|---|---|
| Type safety | ❌ String routes | ✅ Typed route objects |
| Deep link support | ⚠️ Manual via app_links | ✅ Built-in URI matching |
| Auth guard | ❌ Manual per-controller | ✅ `redirect` callback |
| Premium guard | ❌ Manual per-controller | ✅ `redirect` callback |
| Nested navigation | ⚠️ Limited | ✅ `ShellRoute` |
| Back stack | ⚠️ GetX-managed | ✅ Browser/platform native |
| Testing | ⚠️ Hard | ✅ Testable router state |

### 2.3 New File Structure

```
lib/app/router/
├── app_router.dart          # GoRouter instance + redirect logic
├── app_routes.dart          # Route path constants
├── guards/
│   ├── auth_guard.dart
│   ├── premium_guard.dart
│   ├── update_guard.dart
│   └── maintenance_guard.dart
└── route_params/
    ├── course_route_params.dart
    └── exam_route_params.dart
```

### 2.4 Guard Architecture

```dart
// router.dart
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  refreshListenable: GoRouterRefreshStream(
    CombinedChangeNotifier([entitlementService, appUpdateService]),
  ),
  redirect: (context, state) {
    // 1. Maintenance guard (highest priority)
    if (isMaintenanceMode.value) return AppRoutes.maintenanceMode;
    // 2. Force update guard
    if (updateRequired) return AppRoutes.appUpdate;
    // 3. Auth guard
    final isProtectedRoute = _protectedRoutes.contains(state.matchedLocation);
    if (isProtectedRoute && !isLoggedIn.value) return AppRoutes.authGateway;
    // 4. Premium guard
    final isPremiumRoute = _premiumRoutes.contains(state.matchedLocation);
    if (isPremiumRoute && !entitlementService.isPremiumValid)
      return AppRoutes.premiumPackages;
    return null;
  },
  routes: [ ... ],
);
```

### 2.5 Route Hierarchy

```
/splash
/auth-gateway
  /sign-up
  /verify-otp
  /forget-password
  /terms-condition
/app                              ← StatefulShellRoute (NavBar)
  /home
  /exam-category
  /messenger
  /premium-packages
  /profile
    /update
    /history
    /my-orders
    /my-packages
    /my-courses
/course/:courseId                 ← Outside shell (full screen)
  /learn/:itemId
/exam-category/:categoryId/details/:examId
/contest / /contest/all
/jobs / /jobs/:jobId
/current-affairs
/vocabulary
/lecture-sheet / /lecture-sheet/:sheetId
/notifications
/latest-exam
/fast-practice
/see-all/courses / /see-all/exams
/maintenance / /app-update / /sponsor-ads
```

### 2.6 GetX Compatibility

```
GetX state management (Rx, Obx, GetBuilder)  → KEPT — unchanged
GetX DI (Get.put, Get.lazyPut, Bindings)     → KEPT — unchanged
GetX snackbars & dialogs                      → KEPT
GetX navigation (Get.toNamed, Get.back, etc.) → REPLACED by GoRouter
GetMaterialApp                                → REPLACED by MaterialApp.router
```

### 2.7 Navigation Translation Table

| GetX | GoRouter Equivalent |
|---|---|
| `Get.toNamed(Routes.X)` | `context.push(AppRoutes.x)` |
| `Get.offAllNamed(Routes.X)` | `context.go(AppRoutes.x)` |
| `Get.offNamed(Routes.X)` | `context.pushReplacement(AppRoutes.x)` |
| `Get.back()` | `context.pop()` |
| `Get.to(Widget())` | `context.push(AppRoutes.x)` (must be named) |
| `Get.arguments` | `state.extra` or `state.pathParameters` |

---

## Part 3: Theme System Refactor

### 3.1 Current Issues

| Issue | File | Severity |
|---|---|---|
| `ColorScheme` commented out — M3 incomplete | `my_theme.dart:72-84` | 🔴 High |
| Dark primary is blue; light is green — inconsistent brand | `dark_theme_colors.dart` | 🟡 Medium |
| Two parallel text style systems | `styles/text_style.dart` + `my_styles.dart` | 🟡 Medium |
| `canvasColor` used as `accentColor` (deprecated) | `my_theme.dart:31` | 🟡 Medium |
| ChipTheme has placeholder purple/black/green | `my_styles.dart:103-106` | 🟠 Low |
| `bodyLarge` incorrectly has `FontWeight.bold` | `my_styles.dart:39` | 🟠 Low |

### 3.2 New Theme Structure

```
config/theme/
├── app_colors.dart      # Full M3 ColorScheme (light + dark)
├── app_typography.dart  # Single TextTheme — replaces both style systems
├── app_spacing.dart     # Padding/margin design tokens
├── app_radius.dart      # BorderRadius design tokens
├── app_shadows.dart     # BoxShadow design tokens
├── app_theme.dart       # ThemeData builder (replaces my_theme.dart)
└── theme_manager.dart   # Theme toggle logic (replaces MyTheme)
```

### 3.3 AppColors — Brand Consistency

```dart
class AppColors {
  // Brand (consistent across light AND dark mode)
  static const Color primary    = Color(0xFF2A8D6F);  // Teal green
  static const Color primary600 = Color(0xFF236B55);  // Darker
  static const Color primary100 = Color(0xFFD9EDE1);  // Soft accent
  static const Color primary50  = Color(0xFFEEF4F2);  // Background tint

  // Dark mode variant (lighter green for contrast, still green — not blue)
  static const Color primaryDark = Color(0xFF4DB89A);

  // Full M3 ColorScheme for light + dark
  static ColorScheme get lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: primary100,
    onPrimaryContainer: primary600,
    surface: Color(0xFFFFFBFB),
    onSurface: Color(0xFF1A1A1A),
    error: Color(0xFFB00020),
    onError: Colors.white,
    outline: Color(0xFFE0E0E0),
    secondary: primary100,
    onSecondary: primary,
    tertiary: Color(0xFF40A76A),
    onTertiary: Colors.white,
  );

  static ColorScheme get darkColorScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: primaryDark,
    onPrimary: Colors.black,
    primaryContainer: Color(0xFF1A3D31),
    onPrimaryContainer: Color(0xFF9FEAD0),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFE8E8E8),
    error: Color(0xFFCF6679),
    onError: Colors.black,
    outline: Color(0xFF444444),
    secondary: Color(0xFF1A3D31),
    onSecondary: primaryDark,
    tertiary: Color(0xFF4DB89A),
    onTertiary: Colors.black,
  );
}
```

### 3.4 AppTypography — Single Source of Truth

```dart
// REPLACES: my_fonts.dart + AppTextStyles (styles/text_style.dart) + MyStyles.getTextTheme()
class AppTypography {
  static const String fontFamily = 'BalooDa2';

  static TextTheme get textTheme => const TextTheme(
    displayLarge:   TextStyle(fontSize: 32, fontWeight: FontWeight.bold,   fontFamily: fontFamily),
    displayMedium:  TextStyle(fontSize: 24, fontWeight: FontWeight.bold,   fontFamily: fontFamily),
    displaySmall:   TextStyle(fontSize: 19, fontWeight: FontWeight.w700,   fontFamily: fontFamily),
    headlineMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,   fontFamily: fontFamily),
    headlineSmall:  TextStyle(fontSize: 13, fontWeight: FontWeight.w600,   fontFamily: fontFamily),
    titleLarge:     TextStyle(fontSize: 11, fontWeight: FontWeight.w500,   fontFamily: fontFamily),
    bodyLarge:      TextStyle(fontSize: 14, fontWeight: FontWeight.normal, fontFamily: fontFamily),
    bodyMedium:     TextStyle(fontSize: 13, fontWeight: FontWeight.normal, fontFamily: fontFamily),
    bodySmall:      TextStyle(fontSize: 12, fontWeight: FontWeight.w400,   fontFamily: fontFamily),
    labelLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w600,   fontFamily: fontFamily),
    labelSmall:     TextStyle(fontSize: 10, fontWeight: FontWeight.w500,   fontFamily: fontFamily),
  );
}
```

### 3.5 Migration Strategy — Non-Breaking

1. Create new files first
2. Keep old classes as `@Deprecated` shims that redirect to new values
3. Migrate screens incrementally
4. Remove old files only after 100% migration

```dart
// Backward compatibility (temporary bridge):
@Deprecated('Use AppColors.primary')
class LightThemeColors {
  static const Color primaryColor = AppColors.primary;
  static const Color softBg = AppColors.primary50;
  // ... etc
}
```

---

## Part 4: DI Audit Results

### 4.1 Anti-Patterns Found

| Location | Pattern | Fix |
|---|---|---|
| `SplashView.build()` | `Get.put(SplashController())` + `init: SplashController()` = double creation | Remove both; use `SplashBinding` |
| `HomeView.build()` | `Get.put<SeeAllItemsController>(SeeAllItemsController())` | Move to `HomeBinding` |
| `NavbarController.onInit()` | `Get.lazyPut(() => ProfileController())` etc. | Move to `NavbarBinding` |
| `PremiumPackageCheckoutController` | `Get.find<NavbarController>().profileDataModel.value!.user!.name` in field initializer | Move to `onInit()` with null safety |
| `HomeController.onInit()` | `Get.put(LatestContestController(), permanent: true)` | Permanent controller inside non-permanent |
| `AppUpdateService` | `Get.offAll(AppUpdateView(...))` — UI navigation in a service | Move to GoRouter redirect |

### 4.2 What Stays — DI Patterns That Are Correct

| Pattern | Location | Assessment |
|---|---|---|
| `Get.put(MyAppController(), permanent: true)` | `InitialBindings` | ✅ Correct |
| `Get.put(HomeController(), permanent: true)` | `InitialBindings` | ✅ Correct |
| `Get.put(NavbarController(), permanent: true)` | `InitialBindings` | ✅ Correct |
| Per-module `Bindings` with `Get.lazyPut` | All modules | ✅ Correct |
| `GetxService` for app-wide services | (proposed pattern) | ✅ Best practice |

---

## Part 5: Architecture Improvements

### 5.1 Auth Interceptor

```dart
// Add to BaseClient._dio initialization:
..interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    final token = MySharedPref.getUserToken();
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  },
  onError: (error, handler) {
    if (error.response?.statusCode == 401) {
      isLoggedIn.value = false; // GoRouter redirect handles navigation
    }
    handler.next(error);
  },
))
```

**After this:** Remove all manual `headers: {'Authorization': 'Bearer $token'}` from every controller.

### 5.2 Secure Storage Migration

```yaml
# pubspec.yaml addition:
flutter_secure_storage: ^9.0.0
```

```dart
// lib/app/data/local/secure_storage.dart
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static Future<void> setToken(String t) async => _storage.write(key: 'auth_token', value: t);
  static Future<String?> getToken() async => _storage.read(key: 'auth_token');
  static Future<void> clearToken() async => _storage.delete(key: 'auth_token');
}
```

Migration: Check secure storage first, then SharedPrefs fallback, then migrate old token.

### 5.3 Repository Layer (Incremental)

```
lib/app/data/repositories/
├── auth_repository.dart      # signin, signup, OTP, authCheck, logout
├── premium_repository.dart   # packages, order, coupon
└── course_repository.dart    # courses, details, learn, enroll
```

Priority: Auth first (most critical), then Premium (security-critical), then Courses.

### 5.4 App Lifecycle Service

```dart
class AppLifecycleService extends GetxService with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Get.find<PremiumEntitlementService>().validateEntitlement();
    }
  }
}
```

---

## Part 6: Risk Matrix

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| GoRouter breaks back-stack on complex flows | 🔴 High | 🟡 Medium | Map every navigation path before migration |
| `Get.arguments` → `state.extra` breaks data passing | 🔴 High | 🔴 High | Audit all 55 routes before migration |
| `PackageCheckoutController` null crash | 🔴 High | 🔴 High | Fix in Phase A before anything else |
| EntitlementService incorrectly denies paying users | 🟡 Medium | 🔴 Critical | Test with real IAP test purchases |
| Theme migration breaks existing UI | 🟡 Medium | 🟠 Low | Keep deprecated shims; visual testing |
| `AppUpdateService` breaks without GetX navigation | 🟡 Medium | 🟡 Medium | Migrate to GoRouter redirect before removing |
| Deep links break | 🟠 Low | 🔴 High | GoRouter handles them natively — test all |

---

## Part 7: What Must Remain Unchanged

| Component | Reason |
|---|---|
| All 27 data models | Live API contract |
| All API endpoints in `constants.dart` | Production URLs |
| `BaseClient.safeApiCall()` interface | Used by all 31 modules |
| GetX state management (Rx, Obx, GetBuilder) | In 31 modules — too risky to change |
| All controller business logic | Architecture only — no logic changes |
| Localization system (`en_US`, `bn_BD`) | Production content |
| IAP product ID map | Live App Store/Play Store products |
| OneSignal push notification setup | Production push system |
| `MySharedPref` for language/theme | User preferences must persist |
| All existing screen UIs (Phase A-D) | Visual redesign is a later phase |
| Android/iOS native configuration | Build configs untouched |

---

## Part 8: Implementation Roadmap

### Phase A — Bug Fixes (2-3 days) — ZERO risk ✅
- Fix `PremiumPackageCheckoutController` null crash
- Fix `SplashView` double controller creation
- Fix `HomeView` controller in build()
- Fix route path concatenation bug (MY_PACKAGES, MY_ORDERS)
- Move lazyPuts from `NavbarController.onInit()` to `NavbarBinding`
- Move `pubspec.yaml` dev packages to dev_dependencies
- Remove dead commented code from `base_client.dart`

### Phase B — PremiumEntitlementService (3-4 days) — Medium risk
- Create `PremiumEntitlementService` as `GetxService`
- Wire into SplashController, PaymentWebView, IAP service
- Add entitlement check to CourseLearnController
- Add `AppLifecycleService`
- Test all premium flows

### Phase C — Auth Interceptor + Secure Storage (2-3 days) — Low risk
- Add Dio auth interceptor
- Remove manual Bearer tokens from controllers
- Add `flutter_secure_storage`
- Create `SecureStorage` with SharedPref fallback
- Test all authenticated API calls

### Phase D — Theme Refactor (3-4 days) — Low risk
- Create `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`, `AppShadows`
- Create `AppTheme` / `ThemeManager`
- Add deprecated shims on old classes
- Visual verification in light and dark mode

### Phase E — GoRouter Migration (7-10 days) — HIGH risk
- Audit ALL `Get.toNamed()`, `Get.offAllNamed()`, `Get.arguments` usages
- Add `go_router` dependency
- Create `app_router.dart` with all routes and guards
- Replace `GetMaterialApp` with `MaterialApp.router`
- Migrate navigation calls screen by screen
- Implement `StatefulShellRoute` for bottom navbar
- Remove old `app_pages.dart` / `app_routes.dart`
- Full navigation QA

### Phase F — Repository Layer (3-4 days) — Low-Medium risk
- `AuthRepository`, `PremiumRepository`, `CourseRepository`
- Refactor selected controllers
- Unit tests for repositories

**Total Estimate: 20-28 days**

---

## Part 9: Rollback Strategy

| Phase | Rollback |
|---|---|
| A (Bug Fixes) | `git revert` individual commits |
| B (Entitlement) | Feature flag: `const useLegacyHavePackage = true` |
| C (Secure Storage) | SharedPref fallback remains for one release cycle |
| D (Theme) | Deprecated shims → revert theme assignment in `main.dart` |
| E (GoRouter) | Most invasive — `web-exams` branch is the reference baseline |
| F (Repos) | Controllers retain direct calls as fallback |

### Branch Strategy
```
main                        ← production (DO NOT TOUCH)
web-exams                   ← current stable (DO NOT TOUCH)
feature/v2-major-redesign   ← all V2 work here
```

---

## Approval Checklist

- [ ] Phase A (Bug Fixes) — approved to start immediately
- [ ] Phase B (PremiumEntitlementService) — approach confirmed
- [ ] Phase C (Secure Storage) — migration approved
- [ ] Phase D (Theme) — scope confirmed
- [ ] Phase E (GoRouter) — migration approved
- [ ] Phase F (Repositories) — scope confirmed
- [ ] Q1-Q5 (Open Questions) — answered

---

*No code has been changed. Branch `feature/v2-major-redesign` created from `web-exams`. Awaiting approval.*
