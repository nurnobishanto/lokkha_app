# 📊 Lokkha App — Project Analysis Report

**Generated:** 2026-06-22  
**Version Analyzed:** 2.03.07+24  
**Branch Analyzed:** `web-exams`  
**Flutter SDK:** `>=3.0.5 <4.0.0`  
**Architecture:** GetX MVC (Feature-Module based)

---

## 1. Project Overview

**App Name:** Lokkha (`lokkha`)  
**Package ID:** `com.lokkha.*`  
**Author:** Techyfo  
**Type:** EdTech — Bangla Exam Preparation Platform  
**Description:** A competitive exam preparation app targeting Bangla-speaking users, offering courses, mock tests, exam categories, vocabulary, current affairs, contests, jobs, and premium packages.

---

## 2. Architecture Pattern

### Pattern: GetX MVC — Feature-Module Architecture

The project follows a **GetX-based MVC pattern** organized around feature modules. Each module contains its own `views/`, `controllers/`, and `bindings/` folders.

```
lib/
├── app/                      # Core app domain
│   ├── bindings/             # GetX initial dependency injection
│   ├── components/           # Global reusable widgets
│   ├── controllers/          # App-level controllers (StartExam)
│   ├── data/                 # Local persistence (SharedPrefs + GetStorage)
│   ├── enums/                # App-wide enums (QuestionType)
│   ├── helper/               # Global utilities, helpers
│   ├── models/               # Data models (27 model files)
│   ├── modules/              # Feature modules (31 modules)
│   ├── routes/               # GetX routing (AppPages + AppRoutes)
│   ├── services/             # API layer (BaseClient, AuthService, etc.)
│   └── views/                # Shared/cross-module views & widgets
├── config/
│   ├── constants/            # App images, strings
│   ├── extensions/           # Widget/decoration extensions
│   ├── theme/                # Theme system (light/dark)
│   └── translations/         # Localization (en_US, bn_BD)
├── my_app/                   # Root app widget + controller
│   ├── bindings/
│   ├── controllers/          # App lifecycle, deep links
│   └── views/                # MyApp root widget
├── styles/                   # Standalone text styles
├── utils/                    # Constants (API endpoints)
└── main.dart                 # Entry point
```

---

## 3. State Management

- **Package:** `get: ^4.6.6` (GetX)
- **Pattern:** `GetxController` + `GetBuilder` / `Obx`
- **Usage:**
  - `GetBuilder` — rebuilds on `update()` call (used in navbar, splash, etc.)
  - `Obx` — reactive stream for `RxX` variables (slider, exams, user auth)
  - `Get.put()` + `Get.lazyPut()` via `Bindings` — per-module DI
  - `Get.find<Controller>()` — controller lookup
- **Global State:** `global.dart` — contains `RxBool isLoggedIn`, `RxBool havePackage`, `RxInt unReadNotificationCount`, reactive user state, etc.
- **Permanent controllers (InitialBindings):**
  - `MyAppController` — permanent
  - `HomeController` — permanent
  - `NavbarController` — permanent

---

## 4. Routing System

- **Package:** GetX named routing via `GetMaterialApp`
- **Files:** `app_pages.dart` + `app_routes.dart` (using `part` directive)
- **Pattern:** Route constants in `Routes` class → path strings in `_Paths` class
- **Total Named Routes:** ~55 routes
- **Initial Route:** `Routes.SPLASH` (`/splash`)
- **Deep Link Handling:** `MyAppController` handles `app_links` for cold start + foreground

### ⚠️ Route Issue Found:
```dart
// In routes.dart — bug: double concatenation
static const MY_PACKAGES = _Paths.MY_PACKAGES + _Paths.MY_PACKAGES;
static const MY_ORDERS   = _Paths.MY_ORDERS + _Paths.MY_ORDERS;
// Results in: '/my-packages/my-packages' and '/my-orders/my-orders'
```

### Commented-Out Routes:
- `TOPIC_SELECTION` — disabled
- `MY_APP` — disabled  
- `SUBJECT_SECTION` — disabled
- `MODEL_TEST` — disabled
- `COURSE_CHECKOUT` — disabled

---

## 5. API Layer

- **HTTP Client:** `dio: ^5.7.0` (single static `Dio` instance)
- **Logging:** `pretty_dio_logger: ^1.4.0` (debug-only)
- **Base Client:** `lib/app/services/base_client.dart`
  - Static `safeApiCall()` method — supports GET, POST, PUT, DELETE
  - Centralized error handling: `DioException`, `SocketException`, `TimeoutException`
  - Shows `CustomSnackBar` on unhandled errors
- **Auth Headers:** Bearer token passed per-call via header map
- **Base URL:** Loaded from `.env` via `flutter_dotenv` → `API_BASE_URL`

### ⚠️ API Layer Issues:
- No request interceptor for auth token injection — token is manually added per-call
- No refresh token mechanism
- `TODO` comment for Firebase Crashlytics remote error logging (not implemented)
- The old commented-out `BaseClient` code (~240 lines) is still present in the file
- No response caching strategy
- Hardcoded `storageUrl` (`https://lokkha.com/uploads/`) — not from `.env`

---

## 6. Repository Layer

- **Assessment:** ❌ No formal Repository layer exists
- API calls are made **directly inside controllers** via `BaseClient.safeApiCall()`
- No Repository interface abstraction between Controller and API
- This tightly couples controllers to the API service, making testing and future changes harder

---

## 7. Models

**Location:** `lib/app/models/` (27 model files)

| Model | Description |
|---|---|
| `user.dart` | User profile model |
| `course.dart` | Course with modules, sections |
| `courses.dart` | Paginated course list |
| `exam.dart` | Exam model |
| `exam_category.dart` | Exam category |
| `question.dart` | MCQ question model |
| `contest.dart` | Contest model |
| `contest_result.dart` | Contest result |
| `package.dart` | Premium package |
| `order.dart` | Purchase order |
| `vocabulary.dart` | Vocabulary item |
| `lecture_sheet.dart` | Lecture sheet |
| `paginator.dart` | Generic pagination |
| `category.dart` | Generic category |
| `subject.dart` | Subject model |
| `tag.dart` | Tag model |
| `teacher.dart` | Teacher/instructor model |
| `review.dart` | Course review |
| `payment.dart` | Payment model |
| `coupon.dart` | Discount coupon |
| `start_exam_model.dart` | Exam start payload |
| `get_subjects.dart` | Subjects response |
| `course_item.dart` | Course item |
| `course_module.dart` | Course module |
| `course_category.dart` | Course category |
| `mock_subject_select_model.dart` | Local mock subject selection |
| `subject_model.dart` | Subject (simplified) |

- **Serialization:** `json_annotation: ^4.9.0` + `json_serializable: ^6.9.5`
- **Generation:** `build_runner: ^2.4.15`

---

## 8. Services

| Service | Responsibility |
|---|---|
| `base_client.dart` | HTTP client with Dio |
| `auth_service.dart` | Auth check + session management |
| `google_auth_service.dart` | Google Sign-In wrapper |
| `in_app_purchase_service.dart` | IAP for subscriptions |
| `app_update_service.dart` | Force/optional update check |
| `api_call_status.dart` | Enum for API states |
| `api_exceptions.dart` | Exception model |

---

## 9. Dependency Injection

- **Package:** GetX DI (`Get.put`, `Get.lazyPut`, `Bindings`)
- **InitialBindings:** `MyAppController`, `HomeController`, `NavbarController` — permanent
- **Per-Module Bindings:** Each module has its own `*_binding.dart` with `Get.lazyPut()`
- **Some modules use inline BindingsBuilder:** e.g., `MockTestTabView` registers two controllers
- **Module in SplashView:** `Get.put(SplashController())` called directly inside `build()` — anti-pattern

---

## 10. Local Persistence

| Storage | Package | Usage |
|---|---|---|
| `MySharedPref` | `shared_preferences: ^2.3.5` | Token, theme, language, mock subjects, subject sections, OTP counter |
| `MyGetStorage` | `get_storage: ^2.1.1` | User profile cache (`meUser`) |

- **Dual storage:** Both SharedPreferences and GetStorage used for different concerns
- **Type:** Non-encrypted (no sensitive encryption for token)
- **Token storage:** Plain string in SharedPreferences — consider secure storage for production

---

## 11. Localization

- **Package:** GetX translations
- **Languages Supported:** `en_US`, `bn_BD` (Bangla + English)
- **Default Language:** `bn` (Bangla)
- **Font Family:** `BalooDa2` used for both languages
- **Files:**
  - `config/translations/localization_service.dart` — service class
  - `config/translations/strings_enum.dart` — string keys
  - `config/translations/bn_BD/bn_bd_translation.dart`
  - `config/translations/en_US/en_us_translation.dart`
- **Usage:** `Strings.someKey.tr` pattern via GetX
- **⚠️ Issue:** `home_view.dart` and `navbar_view.dart` contain **hard-coded Bangla text** (e.g., `"হোম"`, `"পরীক্ষা"`, `"প্রিমিয়াম"`) not using the localization system

---

## 12. Theme System

**Files:** `config/theme/`

| File | Role |
|---|---|
| `my_theme.dart` | `ThemeData` builder + theme switcher |
| `light_theme_colors.dart` | Light mode color palette |
| `dark_theme_colors.dart` | Dark mode color palette |
| `my_styles.dart` | `AppBarTheme`, `TextTheme`, `ChipTheme`, `ElevatedButtonTheme` |
| `my_fonts.dart` | Font sizes + font family routing |
| `styles/text_style.dart` | Named `AppTextStyles` (heading1–6, body1–2, caption, button, chip) |

**Issues:**
- Material3 enabled (`useMaterial3: true`) but `ColorScheme` is **commented out** — many Material3 components will use fallback colors
- `DarkThemeColors` has a different primary (`Color(0xFF307BFF)` — blue) inconsistent with light theme brand color (`#2A8D6F` — green)
- `accentColor` on `DarkThemeColors` uses `Colors.blueAccent` (non-const)
- `canvasColor` is used for `accentColor` semantic — deprecated pattern
- `appBarTheme` in dark mode uses `Colors.black` — no branding consistency
- `ChipTheme` has hardcoded `selectedColor: Colors.black`, `disabledColor: Colors.green`, `secondarySelectedColor: Colors.purple` — likely leftover placeholder values
- Two parallel text style systems: `MyFonts`+`my_styles.dart` AND `AppTextStyles` in `styles/text_style.dart`

---

## 13. Reusable Widgets / Components

### Global Components (`lib/app/components/`)

| Widget | Purpose |
|---|---|
| `custom_action_button.dart` | Action button |
| `custom_app_bar.dart` | App-wide AppBar |
| `custom_decision_button.dart` | Two-option button (Yes/No) |
| `custom_drawer.dart` | Side navigation drawer |
| `custom_drop_down_button.dart` | Styled dropdown |
| `custom_loading_overlay.dart` | Full-screen loading |
| `custom_network_image_card.dart` | Cached image card |
| `custom_search_bar.dart` | Search input |
| `custom_snackbar.dart` | Toast/snackbar system |
| `custom_text_field.dart` | Input field |
| `custom_text_form_field.dart` | Form input field |
| `custom_transparent_divider.dart` | Gradient divider |
| `login_required_dialog.dart` | Auth gate dialog |
| `my_widgets_animator.dart` | Loading/error/success animator |
| `premium_courses_card.dart` | Premium course card |

### App-Level Views (`lib/app/views/`)

| Widget | Purpose |
|---|---|
| `exam_process_view.dart` | Full exam-taking screen |
| `exam_result_view.dart` | Exam result display (1 byte — effectively empty) |
| `onboarding_view.dart` | 346 bytes — stub |
| `pdf_viewer.dart` | Syncfusion PDF viewer |
| `base_webview.dart` | In-app WebView |
| `exam_custom_button.dart` | Exam option button |
| `explanation_dialog.dart` | Answer explanation popup |
| `image_preview.dart` | Full-screen image viewer |
| `mathml_converter.dart` | MathML → HTML converter (LaTeX rendering) |
| `package_required_popup.dart` | Premium upsell popup |
| `web_exam_view.dart` | WebView-based exam runner |

### Extensions (`lib/config/extensions/`)
- `widget_extensions.dart` — `padding`, `visible`, `cornerRadius`, `center`, `onTap`, etc.
- `common_extension.dart` — String, int, double utilities
- `decorations_extensions.dart` — `BoxDecoration` helpers

---

## 14. Modules Inventory (31 Modules)

| Module | Description | Status |
|---|---|---|
| `splash` | Splash screen + app init | Active |
| `navbar` | Bottom navigation bar (5 tabs) | Active |
| `nav_bar_views/home` | Home screen with sliders, grid, courses, exams | Active |
| `nav_bar_views/contest` | Contest listing + all contests | Active |
| `nav_bar_views/blog` | Blog listing | Active |
| `nav_bar_views/question_bank` | Question bank | Active |
| `auth_views/signin` | Phone/password sign-in | Active |
| `auth_views/sign_up` | Registration | Active |
| `auth_views/verify_otp` | OTP verification | Active |
| `auth_views/forget_password` | Password reset | Active |
| `auth_views/auth_gateway` | Auth entry point | Active |
| `auth_views/terms_condition` | Terms page | Active |
| `profile_module/profile` | User profile | Active |
| `profile_module/profile_update` | Profile editing | Active |
| `profile_module/profile_history` | Profile change history | Active |
| `profile_module/my_orders` | Order history | Active |
| `profile_module/my_packages` | Active packages | Active |
| `profile_update_required` | Force profile update gate | Active |
| `courses` | Course listing | Active |
| `course_details` | Course detail page | Active |
| `course_learn` | Course learning player | Active |
| `course_checkout` | Purchase flow | Commented-out route |
| `exam` | Exam module | Active |
| `exam_category` | Exam categories | Active |
| `exam_category_details` | Category drill-down | Active |
| `fast_practice` | Quick practice mode | Active |
| `random_question` | Random question selector | Active (Home widget) |
| `grid_views/mock_test_tab` | Mock test tabs | Active |
| `grid_views/jobs` | Jobs listing + details | Active |
| `current_affairs` | National/international news | Active |
| `latest_exam` | Latest exams section | Active |
| `lecture_sheet` | Study material PDFs | Active |
| `premium_packages` | Package purchase | Active |
| `notifications` | Push notification list | Active |
| `my_courses` | Enrolled courses | Active |
| `subject_sections` | Subject drill-down | Active |
| `vocabulary` | Word learning | Active |
| `drawer_pages` | Privacy, Terms, About pages | Active |
| `sponsor_ads` | Sponsor advertisement view | Active |
| `messanger_redirect` | Facebook Messenger deep link | Active |
| `maintenance_mode` | Maintenance page | Active |
| `app_update` | Force update page | Active |
| `see_all_items` | Generic "see all" list | Active (all courses, all exams) |
| `contest/all_contest` | All contests list | Active |

---

## 15. Design Patterns

- **GetView<Controller>** — most views extend `GetView<T>` for direct controller access
- **StatelessWidget** — used for views that don't need direct controller binding
- **Private widget classes** — home_view uses `_SearchBar`, `_SliderSection`, `_ShortcutGrid`, etc. for decomposition
- **Widget extensions** — `.paddingAll()`, `.paddingSymmetric()`, `.center()` used throughout
- **Reactive globals** — `isLoggedIn.obs`, `havePackage.obs` shared across app

---

## 16. Key Dependencies Summary

| Dependency | Version | Purpose |
|---|---|---|
| `get` | ^4.6.6 | State management, routing, DI |
| `dio` | ^5.7.0 | HTTP client |
| `flutter_screenutil` | ^5.9.3 | Responsive sizing |
| `shared_preferences` | ^2.3.5 | Local key-value storage |
| `get_storage` | ^2.1.1 | Local storage (GetX native) |
| `cached_network_image` | ^3.4.1 | Network image caching |
| `pinput` | ^5.0.1 | OTP input field |
| `carousel_slider` | ^5.0.0 | Home banners |
| `flutter_dotenv` | ^5.2.1 | Environment config |
| `onesignal_flutter` | ^5.3.0 | Push notifications |
| `google_sign_in` | ^7.2.0 | Google OAuth |
| `in_app_purchase` | ^3.2.3 | IAP (iOS/Android) |
| `syncfusion_flutter_pdfviewer` | ^29.1.39 | PDF rendering |
| `webview_flutter` | ^4.13.0 | In-app WebView |
| `youtube_player_flutter` | ^9.1.2 | YouTube embed |
| `lottie` | ^3.3.2 | Lottie animations |
| `flutter_tex` | ^5.1.10 | LaTeX rendering |
| `flutter_math_fork` | ^0.7.4 | Math equations |
| `xml` | ^6.6.1 | XML/MathML parsing |
| `app_links` | ^7.0.0 | Deep links |
| `permission_handler` | ^12.0.1 | Runtime permissions |
| `share_plus` | ^11.0.0 | Native share |
| `image_picker` | ^1.1.2 | Camera/gallery |
| `image_cropper` | ^9.1.0 | Image cropping |
| `intl` | ^0.20.2 | Date formatting |
| `url_launcher` | ^6.3.1 | External URL opening |
| `logger` | ^2.5.0 | Logging |
| `device_info_plus` | ^11.4.0 | Device info |
| `package_info_plus` | ^8.3.0 | App version info |

---

## 17. Technical Debt Identified

### 🔴 Critical Issues

| Issue | Location | Impact |
|---|---|---|
| Route path concatenation bug | `app_routes.dart:36-37` | `MY_PACKAGES` and `MY_ORDERS` routes are broken (double path) |
| `exam_result_view.dart` is 1 byte (empty) | `app/views/views/` | Dead file — result screen likely missing |
| `onboarding_view.dart` is 346 bytes (stub) | `app/views/views/` | Onboarding not implemented |
| `SplashController` instantiated twice inside `build()` | `splash_view.dart:14,19` | Memory leak risk — controller created twice |
| No auth token interceptor | `base_client.dart` | Auth headers must be manually added to every API call |
| User token stored unencrypted | `my_shared_pref.dart` | Security risk for production |

### 🟡 Major Issues

| Issue | Location | Impact |
|---|---|---|
| No Repository layer | Entire app | Controllers directly call API — untestable, violates SRP |
| 240 lines of commented-out code | `base_client.dart:244-479` | Dead code bloat |
| `simple_subscription_page.dart` fully commented out | `lib/simple_subscription_page.dart` | Dead file (115 lines, all comments) |
| Hard-coded Bangla strings in widgets | `navbar_view.dart`, `home_view.dart` | Bypasses localization system |
| Material3 ColorScheme not defined | `my_theme.dart` | Commented-out ColorScheme causes inconsistent M3 colors |
| Dark theme uses blue primary (inconsistent with brand) | `dark_theme_colors.dart` | Brand inconsistency |
| `canvasColor` used as `accentColor` | `my_theme.dart:31` | Deprecated/incorrect semantic use |
| Placeholder values in ChipTheme | `my_styles.dart:103-106` | Purple, black, green placeholders in production |
| `Get.find<NavbarController>()` in AuthService | `auth_service.dart` | Service directly depends on a UI controller |

### 🟠 Minor Issues

| Issue | Location | Impact |
|---|---|---|
| Duplicate text style systems | `styles/text_style.dart` + `config/theme/my_styles.dart` | Inconsistency in style usage |
| `print()` used instead of `debugPrint()` | `my_app_controller.dart:30,39` | Logs appear in release builds |
| `isDebugMode = true` hardcoded | `global.dart:31` | Debug mode always on |
| `isProduction = false` hardcoded | `global.dart:32` | No environment toggle |
| `defaultPaddingHorizontal` uses `8.0.w` at file level | `global.dart:76` | Can fail before ScreenUtil init |
| `defaultMargin` uses `EdgeInsets.all(8.0.r)` at file level | `global.dart:77` | Same ScreenUtil init issue |
| Hardcoded `storageUrl` constant | `constants.dart:10` | Not configurable via `.env` |
| `sponsorAds` URL from `bdtaxation.com` | `constants.dart:11` | Possibly unrelated domain |
| `http_mock_adapter` in production dependencies | `pubspec.yaml:16` | Should be in `dev_dependencies` |
| `rename_app` in production dependencies | `pubspec.yaml:19` | Should be in `dev_dependencies` |
| Commented routes still defined in Routes class | `app_routes.dart` | Dead constants — `TOPIC_SELECTION`, `MODEL_TEST`, etc. |
| `MockTestView` imported but route commented out | `app_pages.dart:35` | Unused import risk |
| `withVisibility()` marked `@Deprecated` | `widget_extensions.dart:98` | Deprecated code still present |
| `withRoundedCorners()` marked `@deprecated` | `widget_extensions.dart:186` | Deprecated code still present |
| `withShadow()` marked `@deprecated` | `widget_extensions.dart:210` | Deprecated code still present |
| `withScroll()` marked `@deprecated` | `widget_extensions.dart:265` | Deprecated code still present |
| `tooltip()` marked `@Deprecated` | `widget_extensions.dart:307` | Deprecated code still present |
| No unit tests | `test/` directory | No test coverage |
| `GlobalKey`, `navigatorKey` referenced in comments | `app_pages.dart:231` | Stale comment |

---

## 18. Unused / Dead Code

| File | Status | Notes |
|---|---|---|
| `lib/simple_subscription_page.dart` | 100% commented | Entire file is dead — 115 lines |
| `lib/app/views/views/exam_result_view.dart` | 1 byte | Effectively empty file |
| `lib/app/views/views/onboarding_view.dart` | Stub (346 bytes) | Only returns `Container()` |
| `base_client.dart` (lines 244–479) | Commented-out code | Old version of BaseClient |
| `AppConstants.sponsorAds` | Points to external `bdtaxation.com` | May be unused or should be `.env` |
| Commented route `TOPIC_SELECTION` | Route defined but disabled | `TopicSelectionView` likely exists but unused |
| Commented route `MODEL_TEST` | Route defined but disabled | `ModelTestView` commented out |
| Commented route `COURSE_CHECKOUT` | Route defined but disabled | `CourseCheckoutView` commented out |
| Commented route `MY_APP` | Route defined but disabled | `MyApp` page route — likely never needed |
| Commented route `SUBJECT_SECTION` | Route defined but disabled | `SubjectSectionView` accessible via `Get.to()` instead |
| `key/` directory | Unknown — likely keystore files | Should not be in version control |
| Deprecated widget extensions (5 methods) | `@deprecated` annotated | Should be removed |

---

## 19. Unused Assets (Suspected)

| Asset | Notes |
|---|---|
| `assets/images/apple.jpeg` | Apple logo — possibly Apple Sign-In placeholder, not referenced in any view |
| `assets/images/coming_soon_slider.png` | 415KB — large; may be used in `ComingSoonPage` or slider |
| `assets/images/seamless_pattern.png` | 262KB — used in splash background |
| `assets/vectors/fire.svg` | 1 file — verify usage |

---

## 20. Performance Observations

| Observation | Impact |
|---|---|
| `HomeView` is 655 lines in a single file | Medium — decomposition needed |
| `exam_process_view.dart` is 16KB | High — complex exam logic in one file |
| Home uses nested `GridView` inside `ListView` (shrinkWrap) | Medium — performance risk on long lists |
| No image caching strategy or max cache size defined | Low — may cause memory bloat |
| `Random()` in `NameAvatar.generateAvatarColor()` called on every build | Low — should use `const` seed or stable color |
| `Get.height / 20` hardcoded ratio calculations | Low — not fully ScreenUtil standardized |
| `SeeAllItemsController` put inside `HomeView.build()` | Medium — controller re-created on rebuild |
| Slider has unimplemented states: `ApiCallStatus.empty`, `.cache`, `.refresh` | Medium — throws `UnimplementedError` at runtime |

---

## 21. Security Observations

| Concern | Details |
|---|---|
| Auth token in plain SharedPreferences | Should use `flutter_secure_storage` for tokens |
| `.env` file tracked in assets | API keys exposed in app bundle — acceptable for public URLs, risky for secrets |
| No certificate pinning | API calls have no SSL pinning |
| `key/` directory in project root | Keystore files should never be in version control |

---

## 22. Current Git Status

```
Branch:     web-exams (up to date with origin/web-exams)
Uncommitted: iOS Podfile (untracked only — no uncommitted source changes)

Remote branches:
  main
  web-exams (current)
  feature/api-integration
  sadman_ui
  v1.0.2
  v1.0.4
  web-exam
```

> **✅ SAFE TO CREATE NEW BRANCH** — Working directory is clean (no staged/modified files).

---

## 23. Summary Scorecard

| Category | Rating | Notes |
|---|---|---|
| Architecture | ⭐⭐⭐ / 5 | GetX MVC is solid but missing Repository layer |
| Code Quality | ⭐⭐⭐ / 5 | Good structure, but dead code and inconsistencies present |
| State Management | ⭐⭐⭐⭐ / 5 | GetX used correctly in most places |
| Routing | ⭐⭐⭐ / 5 | Route bug (double path) exists; several commented routes |
| Theme/Design System | ⭐⭐ / 5 | Incomplete M3 ColorScheme; inconsistent dark/light branding |
| Localization | ⭐⭐⭐ / 5 | Framework exists but hard-coded strings found |
| Security | ⭐⭐ / 5 | Token unencrypted; keystore in repo |
| Performance | ⭐⭐⭐ / 5 | Some nested scrollable issues; mostly acceptable |
| Test Coverage | ⭐ / 5 | No meaningful unit tests |
| Documentation | ⭐⭐ / 5 | Minimal inline comments; no API documentation |

---

## 24. Recommended Priorities for V2

1. **Fix route concatenation bug** in `app_routes.dart`
2. **Add Repository layer** to decouple controllers from API
3. **Complete ColorScheme** for Material3 compliance
4. **Unified design system** — single source of truth for colors, typography, spacing
5. **Secure token storage** — move to `flutter_secure_storage`
6. **Remove all dead/commented code**
7. **Fix SplashView controller anti-pattern**
8. **Add auth interceptor** to `BaseClient` via `Dio.interceptors`
9. **Standardize localization** — remove hard-coded Bangla strings
10. **Extract `HomeView`** into smaller, testable components

---

*Report generated by Senior Flutter Analysis — Phase 1 Complete*  
*No files were modified during this analysis.*
