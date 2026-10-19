import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/study_material/data/models/current_affairs_v1_models.dart';
import 'package:lokkha/features/study_material/presentation/providers/current_affairs_hub_notifier.dart';
import 'package:lokkha/features/study_material/presentation/current_affairs/widgets/current_affairs_detail_sheet.dart';
import 'package:lokkha/shared/shared.dart';

class CurrentAffairsQuestionCard extends ConsumerWidget {
  final CurrentAffairsFeedItem item;
  final int? serialNumber;
  final bool showDateHeader;
  final bool showOptions;

  const CurrentAffairsQuestionCard({
    super.key,
    required this.item,
    this.serialNumber,
    this.showDateHeader = false,
    this.showOptions = false,
  });

  static String _toBengaliNumber(int number) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final s = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final code = s.codeUnitAt(i);
      if (code >= 48 && code <= 57) {
        buffer.write(bengaliDigits[code - 48]);
      } else {
        buffer.write(s[i]);
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(currentAffairsHubNotifierProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBookmarked = item.isBookmarked;

    // Resolve correct answer text (e.g. "খ). ২৪ মে ২০১১")
    String correctAnswerText = item.answer != null
        ? CurrentAffairsFeedItem.stripHtmlToPlainText(item.answer!)
        : '';
    if (correctAnswerText.isEmpty && item.options.isNotEmpty) {
      final correctOpt = item.options.firstWhere(
        (o) => o.isCorrect,
        orElse: () => item.options.first,
      );
      correctAnswerText = '${correctOpt.displayLabel}). ${correctOpt.displayValue}';
    } else if (item.options.isNotEmpty) {
      final match = item.options.firstWhere(
        (o) => o.isCorrect || o.displayValue.trim() == correctAnswerText.trim() || o.value.trim() == correctAnswerText.trim(),
        orElse: () => item.options.first,
      );
      correctAnswerText = '${match.displayLabel}). ${match.displayValue}';
    }

    final numberPrefix = serialNumber != null ? '${_toBengaliNumber(serialNumber!)}. ' : '';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Question Title with HtmlWidget (clean, fast, readable)
          InkWell(
            onTap: () {
              if (checkUserHasPackage()) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => CurrentAffairsDetailSheet(questionId: item.id),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (_) => const PackageRequiredPopup(),
                );
              }
            },
            child: IgnorePointer(
              child: HtmlWidget(
                item.buildSanitizedHtmlTitle(
                  prefix: numberPrefix,
                  isDark: isDark,
                ),
                textStyle: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  height: 1.45,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                customStylesBuilder: (element) {
                  if (element.localName == 'p') {
                    return {'margin': '0', 'padding': '0'};
                  }
                  return null;
                },
              ),
            ),
          ),

          // Question Image if present
          if (item.resolvedQuestionImage != null && item.resolvedQuestionImage!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                item.resolvedQuestionImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],

          SizedBox(height: 10.h),

          // 2. Compact 2-column MCQ Options Grid (matching Reader UI)
          if (showOptions && item.options.isNotEmpty) ...[
            _buildOptionsGrid(item.options, isDark),
            SizedBox(height: 10.h),
          ],

          // 3. Correct Answer Pill + Bookmark & Share Actions
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F9F0),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'সঠিক উত্তরঃ $correctAnswerText',
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF065F46),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Bookmark Button
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'বুকমার্ক',
                icon: Icon(
                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  size: 20.sp,
                  color: isBookmarked ? const Color(0xFF059669) : (isDark ? Colors.white60 : const Color(0xFF94A3B8)),
                ),
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  final token = MySharedPref.getUserToken();
                  if (token.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('বুকমার্ক করতে অনুগ্রহ করে লগইন করুন'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  await notifier.toggleBookmark(item.id);
                },
              ),
              SizedBox(width: 14.w),
              // Share Button
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'শেয়ার করুন',
                icon: Icon(
                  Icons.share_outlined,
                  size: 19.sp,
                  color: isDark ? Colors.white60 : const Color(0xFF94A3B8),
                ),
                onPressed: () {
                  final shareText = '''
[কারেন্ট অ্যাফেয়ার্স]
${item.displayTitle}

উত্তর: $correctAnswerText

${item.explanation != null && item.explanation!.isNotEmpty ? "ব্যাখ্যা: ${item.explanation}\n" : ""}
লক্ষ্য অ্যাপে আরও জানুন: https://lokkha.com
''';
                  ShareHelper.share(shareText.trim(), context: context);
                },
              ),
            ],
          ),

          // 4. Explanation Expand/Collapse Toggle & Box
          if ((item.explanation != null && item.explanation!.trim().isNotEmpty) ||
              (item.explanationHtml != null && item.explanationHtml!.trim().isNotEmpty)) ...[
            SizedBox(height: 8.h),
            InkWell(
              borderRadius: BorderRadius.circular(6.r),
              onTap: () {
                HapticFeedback.lightImpact();
                final isExpanded = ref
                    .read(currentAffairsHubNotifierProvider)
                    .expandedExplanations
                    .contains(item.id);
                if (isExpanded) {
                  notifier.toggleExplanation(item.id);
                  return;
                }

                if (!checkUserHasPackage()) {
                  showDialog(
                    context: context,
                    builder: (_) => const PackageRequiredPopup(),
                  );
                  return;
                }
                notifier.toggleExplanation(item.id);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      ref.watch(currentAffairsHubNotifierProvider.select((s) => s.expandedExplanations.contains(item.id)))
                          ? Icons.menu_book_rounded
                          : Icons.menu_book_outlined,
                      size: 13.5.sp,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      ref.watch(currentAffairsHubNotifierProvider.select((s) => s.expandedExplanations.contains(item.id)))
                          ? 'ব্যাখ্যা লুকান'
                          : 'ব্যাখ্যা দেখুন',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                    if (!checkUserHasPackage()) ...[
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.lock_rounded,
                        size: 12.sp,
                        color: const Color(0xFFD97706),
                      ),
                    ],
                    SizedBox(width: 4.w),
                    Icon(
                      ref.watch(currentAffairsHubNotifierProvider.select((s) => s.expandedExplanations.contains(item.id)))
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 15.sp,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ),
            if (ref.watch(currentAffairsHubNotifierProvider.select((s) => s.expandedExplanations.contains(item.id)))) ...[
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ব্যাখ্যা:',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    if (item.explanationHtml != null && item.explanationHtml!.trim().isNotEmpty)
                      HtmlWidget(
                        item.explanationHtml!,
                        textStyle: TextStyle(
                          fontSize: 12.5.sp,
                          height: 1.5,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                      )
                    else
                      Text(
                        item.explanation!,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          height: 1.5,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                      ),
                    if (item.reference != null && item.reference!.trim().isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'সূত্রঃ ${item.reference!}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.white54 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],

          SizedBox(height: 14.h),
          Divider(color: Colors.grey.withValues(alpha: 0.18), height: 1),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(List<CurrentAffairsOptionItem> options, bool isDark) {
    if (options.length == 4) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildOptionText(options[0], isDark)),
              SizedBox(width: 8.w),
              Expanded(child: _buildOptionText(options[1], isDark)),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildOptionText(options[2], isDark)),
              SizedBox(width: 8.w),
              Expanded(child: _buildOptionText(options[3], isDark)),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((opt) {
        return Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: _buildOptionText(opt, isDark),
        );
      }).toList(),
    );
  }

  Widget _buildOptionText(CurrentAffairsOptionItem opt, bool isDark) {
    return Text(
      '${opt.displayLabel}). ${opt.displayValue}',
      style: TextStyle(
        fontSize: 13.5.sp,
        height: 1.35,
        color: isDark ? Colors.white70 : const Color(0xFF334155),
      ),
    );
  }
}
