import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/features/navigation/presentation/controllers/navbar_notifier.dart';

export 'package:lokkha/features/navigation/presentation/controllers/navbar_notifier.dart';

final currentNavIndexProvider = Provider<int>((ref) {
  return ref.watch(navbarNotifierProvider).currentIndex;
});
