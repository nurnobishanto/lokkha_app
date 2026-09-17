import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Page record summary text
          Flexible(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                ),
                children: [
                  const TextSpan(text: "পৃষ্ঠা "),
                  TextSpan(
                    text: "$currentPage",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const TextSpan(text: " / "),
                  TextSpan(
                    text: "$totalPages",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const TextSpan(text: " (মোট "),
                  TextSpan(
                    text: "$totalRecords",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const TextSpan(text: " টি রেকর্ড)"),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Right: Page controls (< 1 2 3 >)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Previous button
              _buildNavButton(
                icon: Icons.chevron_left_rounded,
                enabled: currentPage > 1,
                onTap: () {
                  if (currentPage > 1) {
                    onPageChanged(currentPage - 1);
                  }
                },
              ),
              SizedBox(width: 4.w),

              // Page numbers
              for (int i = 1; i <= totalPages; i++) ...[
                _buildPageNumberButton(page: i, isSelected: currentPage == i),
                if (i < totalPages) SizedBox(width: 4.w),
              ],
              SizedBox(width: 4.w),

              // Next button
              _buildNavButton(
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
        ],
      );
  }

  Widget _buildNavButton({
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 0.9,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 18.sp,
            color: enabled ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
          ),
        ),
      ),
    );
  }

  Widget _buildPageNumberButton({
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
          color: isSelected ? const Color(0xFF14532D) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE2E8F0), width: 0.9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF14532D).withValues(alpha: 0.25),
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
              color: isSelected ? Colors.white : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }
}
