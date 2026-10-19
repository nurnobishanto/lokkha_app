import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extension to streamline rendering UI from Riverpod AsyncValue.
extension AsyncValueUI<T> on AsyncValue<T> {
  /// Renders standard data, loading and error states cleanly.
  Widget whenStandard({
    required Widget Function(T data) data,
    Widget Function()? loading,
    Widget Function(Object error, StackTrace stackTrace)? error,
  }) {
    return when(
      data: data,
      loading: loading ??
          () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              ),
      error: error ??
          (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    err.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
    );
  }
}
