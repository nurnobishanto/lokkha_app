import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_theme.dart';

class ExamHistoryPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final ValueChanged<int> onPageChanged;

  const ExamHistoryPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
    required this.onPageChanged,
  });

  List<int> _buildVisiblePages(int current, int total) {
    if (total <= 5) {
      return List.generate(total, (i) => i + 1);
    }

    final Set<int> pages = {};
    pages.add(1);
    pages.add(total);

    for (int i = current - 1; i <= current + 1; i++) {
      if (i >= 1 && i <= total) {
        pages.add(i);
      }
    }

    if (current <= 3) {
      pages.add(2);
      pages.add(3);
    }

    if (current >= total - 2) {
      pages.add(total - 1);
      pages.add(total - 2);
    }

    final sorted = pages.toList()..sort();
    final List<int> result = [];

    for (int i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) {
        result.add(-1); // -1 represents ellipsis '...'
      }
      result.add(sorted[i]);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final visiblePages = _buildVisiblePages(currentPage, totalPages);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Page record summary text
        Flexible(
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 12.sp,
                color: context.textSecondary,
              ),
              children: [
                const TextSpan(text: "পৃষ্ঠা "),
                TextSpan(
                  text: "$currentPage",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
                const TextSpan(text: " / "),
                TextSpan(
                  text: "$totalPages",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
                const TextSpan(text: " (মোট "),
                TextSpan(
                  text: "$totalRecords",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
                const TextSpan(text: " টি রেকর্ড)"),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        SizedBox(width: 8.w),

        // Right: Page controls (< 1 2 3 ... 11 >) with horizontal scrolling to prevent any overflow
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: false,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Previous button
                _buildNavButton(
                  context: context,
                  icon: Icons.chevron_left_rounded,
                  enabled: currentPage > 1,
                  onTap: () {
                    if (currentPage > 1) {
                      onPageChanged(currentPage - 1);
                    }
                  },
                ),
                SizedBox(width: 4.w),

                // Page numbers & Ellipsis
                for (final page in visiblePages) ...[
                  if (page == -1)
                    _buildEllipsis(context)
                  else
                    _buildPageNumberButton(
                      context: context,
                      page: page,
                      isSelected: currentPage == page,
                    ),
                  SizedBox(width: 4.w),
                ],

                // Next button
                _buildNavButton(
                  context: context,
                  icon: Icons.chevron_right_rounded,
                  enabled: currentPage < totalPages,
                  onTap: () {
                    if (currentPage < totalPages) {
                      onPageChanged(currentPage + 1);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEllipsis(BuildContext context) {
    return Container(
      width: 20.r,
      height: 32.r,
      alignment: Alignment.center,
      child: Text(
        "...",
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          color: context.textMuted,
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 32.r,
        height: 32.r,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: context.borderColor,
            width: 0.9,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 18.sp,
            color: enabled ? context.textPrimary : context.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildPageNumberButton({
    required BuildContext context,
    required int page,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onPageChanged(page),
      borderRadius: BorderRadius.circular(8.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 32.r,
        height: 32.r,
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor : context.cardColor,
          borderRadius: BorderRadius.circular(8.r),
          border: isSelected
              ? null
              : Border.all(color: context.borderColor, width: 0.9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            "$page",
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : context.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
