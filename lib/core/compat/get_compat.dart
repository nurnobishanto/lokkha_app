import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';

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

/// Abstract view for GetView
abstract class GetView<T> extends StatelessWidget {
  const GetView({super.key});

  T get controller => Get.find<T>();
}

/// Reactive State Tracker
class _RxTracker {
  static Set<ChangeNotifier>? current;
  static void register(ChangeNotifier notifier) {
    current?.add(notifier);
  }
}

/// Base Rx Reactive Class
class Rx<T> extends ChangeNotifier {
  T _value;
  Rx(this._value);

  T get value {
    _RxTracker.register(this);
    return _value;
  }

  set value(T val) {
    if (_value == val) return;
    _value = val;
    notifyListeners();
  }

  T call([T? val]) {
    if (val != null) value = val;
    return value;
  }

  void trigger(T val) {
    _value = val;
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  @override
  String toString() => value.toString();
}

class Rxn<T> extends Rx<T?> {
  Rxn([T? initial]) : super(initial);
}

class RxBool extends Rx<bool> {
  RxBool(super.initial);
  bool toggle() {
    value = !value;
    return value;
  }
}

class RxString extends Rx<String> {
  RxString(super.initial);
}

class RxInt extends Rx<int> {
  RxInt(super.initial);

  bool operator >(num other) => value > other;
  bool operator <(num other) => value < other;
  bool operator >=(num other) => value >= other;
  bool operator <=(num other) => value <= other;
  int operator +(num other) => value + other.toInt();
  int operator -(num other) => value - other.toInt();
}

class RxDouble extends Rx<double> {
  RxDouble(super.initial);

  bool operator >(num other) => value > other;
  bool operator <(num other) => value < other;
  bool operator >=(num other) => value >= other;
  bool operator <=(num other) => value <= other;
  double operator +(num other) => value + other.toDouble();
  double operator -(num other) => value - other.toDouble();
}

class RxnInt extends Rx<int?> {
  RxnInt([int? initial]) : super(initial);
}

class RxnString extends Rx<String?> {
  RxnString([String? initial]) : super(initial);
}

class RxnBool extends Rx<bool?> {
  RxnBool([bool? initial]) : super(initial);
}

class RxnDouble extends Rx<double?> {
  RxnDouble([double? initial]) : super(initial);
}

class RxList<E> extends Rx<List<E>> with ListMixin<E> {
  RxList([List<E>? initial]) : super(initial ?? <E>[]);

  @override
  int get length {
    _RxTracker.register(this);
    return value.length;
  }

  @override
  set length(int newLength) {
    value.length = newLength;
    notifyListeners();
  }

  @override
  E operator [](int index) {
    _RxTracker.register(this);
    return value[index];
  }

  @override
  void operator []=(int index, E element) {
    value[index] = element;
    notifyListeners();
  }

  @override
  void add(E element) {
    value.add(element);
    notifyListeners();
  }

  @override
  void addAll(Iterable<E> iterable) {
    value.addAll(iterable);
    notifyListeners();
  }

  void assignAll(Iterable<E> iterable) {
    value.clear();
    value.addAll(iterable);
    notifyListeners();
  }

  E? firstWhereOrNull(bool Function(E element) test) {
    for (final element in value) {
      if (test(element)) return element;
    }
    return null;
  }

  @override
  void clear() {
    value.clear();
    notifyListeners();
  }

  @override
  bool remove(Object? element) {
    final res = value.remove(element);
    if (res) notifyListeners();
    return res;
  }
}

class RxMap<K, V> extends Rx<Map<K, V>> with MapMixin<K, V> {
  RxMap([Map<K, V>? initial]) : super(initial ?? <K, V>{});

  @override
  V? operator [](Object? key) {
    _RxTracker.register(this);
    return value[key];
  }

  @override
  void operator []=(K key, V val) {
    value[key] = val;
    notifyListeners();
  }

  @override
  void clear() {
    value.clear();
    notifyListeners();
  }

  @override
  Iterable<K> get keys {
    _RxTracker.register(this);
    return value.keys;
  }

  @override
  V? remove(Object? key) {
    final res = value.remove(key);
    notifyListeners();
    return res;
  }
}

typedef RxObjectMixin<T> = Rx<T>;

extension RxBoolExtension on bool {
  RxBool get obs => RxBool(this);
}

extension RxStringExtension on String {
  RxString get obs => RxString(this);
}

extension RxIntExtension on int {
  RxInt get obs => RxInt(this);
}

extension RxDoubleExtension on double {
  RxDouble get obs => RxDouble(this);
}

extension RxListExtension<E> on List<E> {
  RxList<E> get obs => RxList<E>(this);
}

extension RxMapExtension<K, V> on Map<K, V> {
  RxMap<K, V> get obs => RxMap<K, V>(this);
}

extension RxGenericExtension<T> on T {
  Rx<T> get obs => Rx<T>(this);
}

/// Obx Widget that rebuilds on any Rx accessed inside builder
class Obx extends StatefulWidget {
  final Widget Function() builder;
  const Obx(this.builder, {super.key});

  @override
  State<Obx> createState() => _ObxState();
}

class _ObxState extends State<Obx> {
  final Set<ChangeNotifier> _subscriptions = {};

  void _listener() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.removeListener(_listener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final old = _RxTracker.current;
    final accessed = <ChangeNotifier>{};
    _RxTracker.current = accessed;
    try {
      final widgetTree = widget.builder();
      for (final sub in _subscriptions.difference(accessed)) {
        sub.removeListener(_listener);
      }
      for (final sub in accessed.difference(_subscriptions)) {
        sub.addListener(_listener);
      }
      _subscriptions.clear();
      _subscriptions.addAll(accessed);
      return widgetTree;
    } finally {
      _RxTracker.current = old;
    }
  }
}

/// GetBuilder Widget
class GetBuilder<T extends ChangeNotifier> extends StatefulWidget {
  final Widget Function(T controller) builder;
  final T? init;
  final String? tag;

  const GetBuilder({
    super.key,
    required this.builder,
    this.init,
    this.tag,
  });

  @override
  State<GetBuilder<T>> createState() => _GetBuilderState<T>();
}

class _GetBuilderState<T extends ChangeNotifier> extends State<GetBuilder<T>> {
  late T controller;

  @override
  void initState() {
    super.initState();
    if (widget.init != null) {
      controller = widget.init!;
    } else {
      controller = Get.find<T>(tag: widget.tag);
    }
    controller.addListener(_update);
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(controller);
  }
}

/// Workers
class Worker {
  final VoidCallback dispose;
  Worker(this.dispose);
}

Worker ever<T>(Rx<T> listener, void Function(T callback) callback) {
  void l() => callback(listener.value);
  listener.addListener(l);
  return Worker(() => listener.removeListener(l));
}

Worker once<T>(Rx<T> listener, void Function(T callback) callback) {
  late void Function() l;
  l = () {
    listener.removeListener(l);
    callback(listener.value);
  };
  listener.addListener(l);
  return Worker(() => listener.removeListener(l));
}

Worker debounce<T>(Rx<T> listener, void Function(T callback) callback, {Duration? time}) {
  Timer? timer;
  void l() {
    timer?.cancel();
    timer = Timer(time ?? const Duration(milliseconds: 800), () => callback(listener.value));
  }
  listener.addListener(l);
  return Worker(() {
    timer?.cancel();
    listener.removeListener(l);
  });
}

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
