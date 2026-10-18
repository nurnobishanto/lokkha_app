import 'package:flutter/material.dart';
import '../../live_contest/views/live_contest_view.dart';

/// Legacy adapter for backward compatibility. Delegates to [LiveContestView].
class ContestHistoryView extends StatelessWidget {
  const ContestHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const LiveContestView();
  }
}
