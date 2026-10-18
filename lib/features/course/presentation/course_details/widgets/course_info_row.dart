import 'package:flutter/material.dart';

class CourseInfoRow extends StatelessWidget {
  final String title;
  final int? enrolledCount;
  final int? examCount;
  final String? duration;
  final bool lifetimeAccess;
  final Color iconColor;

  const CourseInfoRow({
    super.key,
    required this.title,
    this.enrolledCount,
    this.examCount,
    this.duration,
    required this.lifetimeAccess,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [];

    if ((enrolledCount ?? 0) > 0) {
      items.add(_infoIconText(Icons.people_outline_rounded, "$enrolledCount জন ভর্তি"));
    }

    if ((examCount ?? 0) > 0) {
      items.add(_infoIconText(Icons.assignment_outlined, "$examCount টি পরীক্ষা"));
    }

    if ((duration?.isNotEmpty ?? false) || lifetimeAccess) {
      final text = lifetimeAccess ? "আজীবন মেয়াদ" : duration ?? '';
      items.add(_infoIconText(Icons.access_time_rounded, text));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items,
        ),
      ],
    );
  }

  Widget _infoIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
