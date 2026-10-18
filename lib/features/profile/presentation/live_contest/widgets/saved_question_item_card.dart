import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/utils/html_sanitizer.dart';
import 'package:lokkha/features/profile/data/models/content_history_model.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class SavedQuestionItemCard extends StatefulWidget {
  final UserSavedQuestionModel item;
  final VoidCallback onRemove;
  final bool isRemoving;

  const SavedQuestionItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    this.isRemoving = false,
  });

  @override
  State<SavedQuestionItemCard> createState() => _SavedQuestionItemCardState();
}

class _SavedQuestionItemCardState extends State<SavedQuestionItemCard> {
  bool _isExplanationExpanded = true;

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            const Icon(Icons.bookmark_remove_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8.w),
            const Text("বুকমার্ক মুছে ফেলবেন?"),
          ],
        ),
        content: const Text(
          "আপনি কি নিশ্চিত যে এই প্রশ্নটি আপনার সংরক্ষিত তালিকা থেকে অপসারণ করতে চান?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "বাতিল",
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onRemove();
            },
            child: const Text("অপসারণ করুন"),
          ),
        ],
      ),
    );
  }

  void _copyQuestionText() {
    final title = widget.item.cleanTitle;
    final explanation = widget.item.explanation != null
        ? widget.item.explanation!.replaceAll(RegExp(r'<[^>]*>'), '')
        : '';
    final textToCopy = 'প্রশ্ন: $title\n\nব্যাখ্যা: $explanation';
    Clipboard.setData(ClipboardData(text: textToCopy));
    CustomSnackBar.showCustomToast(message: 'প্রশ্ন ও ব্যাখ্যা কপি করা হয়েছে');
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasExplanation = item.explanation != null && item.explanation!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------------------------
          // 1. Header Row (Question ID, Saved Date, Unsave Button)
          // -------------------------------------------------------------------
          Row(
            children: [
              // Emerald Bookmark Chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? const Color(0xFF064E3B).withValues(alpha: 0.25)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: context.isDark
                        ? const Color(0xFF059669)
                        : const Color(0xFFA7F3D0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bookmark_rounded,
                      size: 13,
                      color: Color(0xFF059669),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "#${item.questionId}",
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: context.isDark
                            ? const Color(0xFF6EE7B7)
                            : const Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // Saved Date
              Icon(
                Icons.calendar_today_outlined,
                size: 13.sp,
                color: context.textSecondary,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  item.formattedSavedDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Unsave Button
              if (widget.isRemoving)
                SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              else
                InkWell(
                  onTap: () => _confirmDelete(context),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Icon(
                      Icons.bookmark_remove_outlined,
                      size: 20.sp,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 10.h),

          // -------------------------------------------------------------------
          // 2. Question Title (HTML Rendered)
          // -------------------------------------------------------------------
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: context.isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: context.borderColor),
            ),
            child: HtmlWidget(
              HtmlSanitizer.convertMathMlToHtml(item.title),
              textStyle: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
                height: 1.4,
              ),
              customStylesBuilder: (element) {
                if (element.localName == 'p') {
                  return {
                    'margin': '0',
                    'padding': '0',
                    'line-height': '1.45',
                  };
                }
                return null;
              },
            ),
          ),

          // -------------------------------------------------------------------
          // 3. Explanation Section (HTML Rendered)
          // -------------------------------------------------------------------
          if (hasExplanation) ...[
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.isDark
                    ? const Color(0xFF0F2537).withValues(alpha: 0.4)
                    : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: context.isDark
                      ? const Color(0xFF047857).withValues(alpha: 0.4)
                      : const Color(0xFFBBF7D0),
                ),
              ),
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isExplanationExpanded = !_isExplanationExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(6.r),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 16.sp,
                              color: const Color(0xFF059669),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              "ব্যাখ্যা ও বিস্তারিত",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          _isExplanationExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18.sp,
                          color: const Color(0xFF059669),
                        ),
                      ],
                    ),
                  ),
                  if (_isExplanationExpanded) ...[
                    SizedBox(height: 6.h),
                    const Divider(height: 1, thickness: 0.5),
                    SizedBox(height: 6.h),
                    HtmlWidget(
                      HtmlSanitizer.convertMathMlToHtml(item.explanation!),
                      textStyle: TextStyle(
                        fontSize: 12.sp,
                        color: context.textSecondary,
                        height: 1.45,
                      ),
                      customStylesBuilder: (element) {
                        if (element.localName == 'p') {
                          return {'margin': '0 0 4px 0'};
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],

          SizedBox(height: 12.h),

          // -------------------------------------------------------------------
          // 4. Action Bar (কপি করুন ও প্র্যাকটিস)
          // -------------------------------------------------------------------
          Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              // Copy Button
              TextButton.icon(
                onPressed: _copyQuestionText,
                icon: Icon(
                  Icons.copy_rounded,
                  size: 14.sp,
                  color: context.textSecondary,
                ),
                label: Text(
                  "কপি করুন",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),

              SizedBox(width: 8.w),

              // Practice Button
              ElevatedButton.icon(
                onPressed: () {
                  CustomSnackBar.showCustomToast(
                    message: "প্রশ্ন #${item.questionId} প্র্যাকটিস মোড লোড হচ্ছে...",
                  );
                },
                icon: const Icon(Icons.play_circle_outline_rounded, size: 14),
                label: Text(
                  "প্র্যাকটিস করুন",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
