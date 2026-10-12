import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Lightweight, pure Flutter reactive state wrappers based on standard [ValueNotifier].
/// This completely replaces external GetX Rx types with 0 third-party dependencies.

class Rx<T> extends ValueNotifier<T> {
  Rx(super.value);

  T call([T? val]) {
    if (val != null) value = val;
    return value;
  }

  void trigger(T val) {
    value = val;
  }

  void refresh() {
    notifyListeners();
  }

  @override
  String toString() => value.toString();
}

class Rxn<T> extends Rx<T?> {
  Rxn([super.initial]);
}

class RxBool extends Rx<bool> {
  RxBool(super.value);

  bool toggle() {
    value = !value;
    return value;
  }
}

class RxString extends Rx<String> {
  RxString(super.value);
}

class RxInt extends Rx<int> {
  RxInt(super.value);

  bool operator >(num other) => value > other;
  bool operator <(num other) => value < other;
  bool operator >=(num other) => value >= other;
  bool operator <=(num other) => value <= other;
  int operator +(num other) => value + other.toInt();
  int operator -(num other) => value - other.toInt();
}

class RxDouble extends Rx<double> {
  RxDouble(super.value);

  bool operator >(num other) => value > other;
  bool operator <(num other) => value < other;
  bool operator >=(num other) => value >= other;
  bool operator <=(num other) => value <= other;
  double operator +(num other) => value + other.toDouble();
  double operator -(num other) => value - other.toDouble();
}

class RxnInt extends Rx<int?> {
  RxnInt([super.initial]);
}

class RxnString extends Rx<String?> {
  RxnString([super.initial]);
}

class RxnBool extends Rx<bool?> {
  RxnBool([super.initial]);
}

class RxnDouble extends Rx<double?> {
  RxnDouble([super.initial]);
}

class RxList<E> extends Rx<List<E>> with ListMixin<E> {
  RxList([List<E>? initial]) : super(initial ?? <E>[]);

  @override
  int get length => value.length;

  @override
  set length(int newLength) {
    value.length = newLength;
    notifyListeners();
  }

  @override
  E operator [](int index) => value[index];

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
  V? operator [](Object? key) => value[key];

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
  Iterable<K> get keys => value.keys;

  @override
  V? remove(Object? key) {
    final res = value.remove(key);
    notifyListeners();
    return res;
  }
}

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
