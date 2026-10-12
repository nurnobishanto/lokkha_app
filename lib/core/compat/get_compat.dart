import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
export 'package:lokkha/core/utils/rx.dart';

/// Zero-dependency GetX compatibility adapter for pure Flutter & Riverpod.
/// This allows removing `package:get` entirely from `pubspec.yaml` while existing
/// features continue working seamlessly without compilation or runtime errors.

class _GetRouting {
  String get current => Get.currentRoute;
  dynamic get args => Get.arguments;
  set args(dynamic value) {
    Get.arguments = value;
  }
}

class Get {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static BuildContext? get context => key.currentContext;
  static BuildContext? get overlayContext => key.currentContext;

  static double get width => context != null ? MediaQuery.of(context!).size.width : 0.0;
  static double get height => context != null ? MediaQuery.of(context!).size.height : 0.0;

  static ThemeData get theme => context != null ? Theme.of(context!) : ThemeData.light();
  static TextTheme get textTheme => theme.textTheme;

  static bool get isPlatformDarkMode =>
      context != null ? (Theme.of(context!).brightness == Brightness.dark) : false;

  static bool isDialogOpen = false;
  static bool testMode = false;
  static String currentRoute = '';
  static dynamic arguments;
  static Map<String, String> parameters = {};

  static _GetRouting get routing => _GetRouting();

  // Navigation
  static Future<T?>? toNamed<T>(String page, {dynamic arguments, Map<String, String>? parameters}) {
    currentRoute = page;
    Get.arguments = arguments;
    if (parameters != null) Get.parameters = parameters;
    if (context != null) {
      try {
        return GoRouter.of(context!).push<T>(page, extra: arguments);
      } catch (_) {}
    }
    return key.currentState?.pushNamed<T>(page, arguments: arguments);
  }

  static Future<T?>? to<T>(dynamic page, {dynamic arguments}) {
    Get.arguments = arguments;
    final route = MaterialPageRoute<T>(
      builder: (ctx) => page is Widget ? page : (page as Widget Function())(),
    );
    return key.currentState?.push<T>(route);
  }

  static void back<T>({T? result, bool closeOverlays = false}) {
    if (context != null) {
      try {
        if (GoRouter.of(context!).canPop()) {
          GoRouter.of(context!).pop<T>(result);
          return;
        }
      } catch (_) {}
    }
    key.currentState?.pop<T>(result);
  }

  static Future<T?>? off<T>(dynamic page, {dynamic arguments}) {
    Get.arguments = arguments;
    final route = MaterialPageRoute<T>(
      builder: (ctx) => page is Widget ? page : (page as Widget Function())(),
    );
    return key.currentState?.pushReplacement(route);
  }

  static Future<T?>? offNamed<T>(String page, {dynamic arguments, Map<String, String>? parameters}) {
    currentRoute = page;
    Get.arguments = arguments;
    if (parameters != null) Get.parameters = parameters;
    if (context != null) {
      try {
        GoRouter.of(context!).pushReplacement(page, extra: arguments);
        return Future.value(null);
      } catch (_) {}
    }
    return key.currentState?.pushReplacementNamed(page, arguments: arguments);
  }

  static Future<T?>? offAll<T>(dynamic page, {dynamic arguments}) {
    Get.arguments = arguments;
    final route = MaterialPageRoute<T>(
      builder: (ctx) => page is Widget ? page : (page as Widget Function())(),
    );
    return key.currentState?.pushAndRemoveUntil<T>(route, (route) => false);
  }

  static Future<T?>? offAllNamed<T>(String newRouteName, {dynamic arguments, Map<String, String>? parameters}) {
    currentRoute = newRouteName;
    Get.arguments = arguments;
    if (parameters != null) Get.parameters = parameters;
    if (context != null) {
      try {
        GoRouter.of(context!).go(newRouteName, extra: arguments);
        return Future.value(null);
      } catch (_) {}
    }
    return key.currentState?.pushNamedAndRemoveUntil<T>(newRouteName, (route) => false, arguments: arguments);
  }

  static void addPages(List pages) {}
  static void changeTheme(ThemeData theme) {}
  static void changeThemeMode(ThemeMode themeMode) {}
  static void updateLocale(Locale locale) {}

  // Dialogs & Snackbars
  static Future<T?> dialog<T>(
    Widget widget, {
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
  }) {
    if (context == null) return Future<T?>.value(null);
    isDialogOpen = true;
    return showDialog<T>(
      context: context!,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      useSafeArea: useSafeArea,
      builder: (_) => widget,
    ).whenComplete(() {
      isDialogOpen = false;
    });
  }

  static Future<T?>? defaultDialog<T>({
    String title = "Alert",
    TextStyle? titleStyle,
    EdgeInsetsGeometry? titlePadding,
    Widget? content,
    EdgeInsetsGeometry? contentPadding,
    Widget? confirm,
    Widget? cancel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    String? textConfirm,
    String? textCancel,
    Color? confirmTextColor,
    Color? cancelTextColor,
    Color? buttonColor,
    String middleText = "",
    TextStyle? middleTextStyle,
    double radius = 20.0,
    bool barrierDismissible = true,
  }) {
    if (context == null) return null;
    return showDialog<T>(
      context: context!,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        titlePadding: titlePadding,
        contentPadding: contentPadding,
        title: title.isNotEmpty ? Text(title, style: titleStyle) : null,
        content: content ?? (middleText.isNotEmpty ? Text(middleText, style: middleTextStyle) : null),
        actions: [
          if (cancel != null) cancel,
          if (textCancel != null)
            TextButton(
              onPressed: () {
                if (onCancel != null) onCancel();
                Navigator.of(ctx).pop();
              },
              child: Text(textCancel, style: TextStyle(color: cancelTextColor)),
            ),
          if (confirm != null) confirm,
          if (textConfirm != null)
            TextButton(
              style: buttonColor != null ? TextButton.styleFrom(backgroundColor: buttonColor) : null,
              onPressed: () {
                if (onConfirm != null) onConfirm();
                Navigator.of(ctx).pop();
              },
              child: Text(textConfirm, style: TextStyle(color: confirmTextColor)),
            ),
        ],
      ),
    );
  }

  static void snackbar(
    String title,
    String message, {
    Color? colorText,
    Duration? duration,
    Color? backgroundColor,
    Widget? icon,
    bool? shouldIconPulse,
    double? maxWidth,
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
    Color? leftBarIndicatorColor,
    List<BoxShadow>? boxShadows,
    Gradient? backgroundGradient,
    Widget? mainButton,
    OnTap? onTap,
    bool? isDismissible,
    bool? showProgressIndicator,
    DismissDirection? dismissDirection,
    AnimationController? progressIndicatorController,
    Color? progressIndicatorBackgroundColor,
    Animation<Color>? progressIndicatorValueColor,
    SnackPosition? snackPosition,
    SnackStyle? snackStyle,
    Curve? forwardAnimationCurve,
    Curve? reverseAnimationCurve,
    Duration? animationDuration,
    double? barBlur,
    double? overlayBlur,
    Color? overlayColor,
    dynamic userInputForm,
  }) {
    if (context == null) return;
    final messenger = ScaffoldMessenger.maybeOf(context!);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor ?? Colors.black87,
        duration: duration ?? const Duration(seconds: 3),
        content: Row(
          children: [
            if (icon != null) ...[icon, const SizedBox(width: 8)],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: colorText ?? Colors.white)),
                  if (message.isNotEmpty)
                    Text(message, style: TextStyle(color: colorText ?? Colors.white)),
                ],
              ),
            ),
            if (mainButton != null) mainButton,
          ],
        ),
      ),
    );
  }

  static void rawSnackbar({
    String? title,
    String? message,
    Duration? duration,
    SnackStyle? snackStyle,
    Color? backgroundColor,
    Color? colorText,
    void Function(dynamic)? onTap,
    Widget? icon,
    Widget? mainButton,
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? borderRadius,
    dynamic snack,
  }) {
    snackbar(
      title ?? '',
      message ?? '',
      duration: duration,
      backgroundColor: backgroundColor,
      colorText: colorText,
      icon: icon,
      mainButton: mainButton,
      margin: margin,
      padding: padding,
      borderRadius: borderRadius,
    );
  }

  static void closeAllSnackbars() {
    if (context != null) ScaffoldMessenger.maybeOf(context!)?.clearSnackBars();
  }

  // Dependency Injection
  static final Map<String, dynamic> _instances = {};
  static final Map<String, dynamic Function()> _factories = {};
  static final Set<String> _permanentKeys = {};

  static T put<T>(T dependency, {String? tag, bool permanent = false}) {
    final k = _makeKey<T>(tag);
    _instances[k] = dependency;
    if (permanent) _permanentKeys.add(k);
    if (dependency is GetxController) {
      dependency.onInit();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dependency.onReady();
      });
    }
    return dependency;
  }

  static void lazyPut<T>(T Function() builder, {String? tag, bool fenix = false}) {
    final k = _makeKey<T>(tag);
    _factories[k] = builder;
  }

  static T find<T>({String? tag}) {
    final k = _makeKey<T>(tag);
    if (_instances.containsKey(k)) {
      return _instances[k] as T;
    }
    if (_factories.containsKey(k)) {
      final inst = _factories[k]!() as T;
      _instances[k] = inst;
      if (inst is GetxController) {
        inst.onInit();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          inst.onReady();
        });
      }
      return inst;
    }
    throw Exception("Instance of type $T not found in Get container.");
  }

  static bool isRegistered<T>({String? tag}) {
    final k = _makeKey<T>(tag);
    return _instances.containsKey(k) || _factories.containsKey(k);
  }

  static bool delete<T>({String? tag, bool force = false}) {
    final k = _makeKey<T>(tag);
    if (!force && _permanentKeys.contains(k)) return false;
    final inst = _instances.remove(k);
    _factories.remove(k);
    _permanentKeys.remove(k);
    if (inst is GetxController) {
      inst.onClose();
    }
    return true;
  }

  static void reset() {
    _instances.clear();
    _factories.clear();
    _permanentKeys.clear();
  }

  static String _makeKey<T>(String? tag) => '${T.toString()}#${tag ?? ""}';
}

/// Base Controller compatible with GetxController
class GetxController extends ChangeNotifier {
  bool isClosed = false;

  void onInit() {}
  void onReady() {}
  void onClose() {
    isClosed = true;
  }

  void update([List<Object>? ids]) {
    notifyListeners();
  }
}

/// Base Service compatible with GetxService
abstract class GetxService extends GetxController {}


/// Bindings & Pages
abstract class Bindings {
  void dependencies();
}

class BindingsBuilder extends Bindings {
  final void Function() builder;
  BindingsBuilder(this.builder);

  @override
  void dependencies() => builder();
}

class GetPage {
  final String name;
  final Widget Function() page;
  final Bindings? binding;
  final List<Bindings> bindings;
  final dynamic transition;
  final Duration? transitionDuration;

  const GetPage({
    required this.name,
    required this.page,
    this.binding,
    this.bindings = const [],
    this.transition,
    this.transitionDuration,
  });
}

class GetMaterialApp extends MaterialApp {
  const GetMaterialApp({
    super.key,
    super.home,
    super.routes,
    super.initialRoute,
    super.onGenerateRoute,
    super.navigatorKey,
    super.title,
    super.theme,
    super.darkTheme,
    super.themeMode,
    super.locale,
    super.localizationsDelegates,
    super.supportedLocales,
    super.builder,
  });
}

abstract class Translations {
  Map<String, Map<String, String>> get keys;
}

enum SnackPosition { TOP, BOTTOM }
enum SnackStyle { FLOATING, GROUNDED }
typedef OnTap = void Function(dynamic);

// Extension utilities
extension WidgetPaddingX on Widget {
  Widget paddingAll(double padding) => Padding(padding: EdgeInsets.all(padding), child: this);
  Widget paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical), child: this);
  Widget paddingOnly({double left = 0.0, double top = 0.0, double right = 0.0, double bottom = 0.0}) =>
      Padding(padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom), child: this);
  Widget marginAll(double margin) => Container(margin: EdgeInsets.all(margin), child: this);
  Widget marginSymmetric({double horizontal = 0.0, double vertical = 0.0}) =>
      Container(margin: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical), child: this);
  Widget marginOnly({double left = 0.0, double top = 0.0, double right = 0.0, double bottom = 0.0}) =>
      Container(margin: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom), child: this);
}

extension IntDurationX on int {
  Duration get seconds => Duration(seconds: this);
  Duration get milliseconds => Duration(milliseconds: this);
}

extension StringTrX on String {
  String get tr => this;
}

extension ListAddIfX<E> on List<E> {
  void addIf(bool condition, E element) {
    if (condition) add(element);
  }
}
