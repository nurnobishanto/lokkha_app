import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/study_material/data/models/current_affairs_v1_models.dart';
import 'package:lokkha/features/study_material/presentation/providers/current_affairs_hub_notifier.dart';

class CurrentAffairsReaderView extends ConsumerWidget {
  final String categoryTitle;
  final String? categorySlug;
  final int? categoryId;
  final bool withOptions;
  final List<CurrentAffairsFeedItem>? initialQuestions;

  const CurrentAffairsReaderView({
    super.key,
    required this.categoryTitle,
    this.categorySlug,
    this.categoryId,
    this.withOptions = true,
    this.initialQuestions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hubState = ref.watch(currentAffairsHubNotifierProvider);
    final digest = hubState.monthlyDigest;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    // Filter questions by category if selected, otherwise all digest questions or feed questions
    List<CurrentAffairsFeedItem> questions = [];
    int totalCount = 0;

    if (initialQuestions != null && initialQuestions!.isNotEmpty) {
      questions = initialQuestions!;
      totalCount = questions.length;
    } else if (digest != null && digest.categories.isNotEmpty) {
      if (categoryId != null && categoryId! > 0) {
        final cat = digest.categories.firstWhere(
          (c) => c.id == categoryId,
          orElse: () => digest.categories.first,
        );
        questions = cat.questions;
        totalCount = cat.totalQuestions > 0 ? cat.totalQuestions : questions.length;
      } else {
        // All categories combined
        for (final cat in digest.categories) {
          questions.addAll(cat.questions);
        }
        totalCount = digest.statistics.totalQuestions > 0
            ? digest.statistics.totalQuestions
            : questions.length;
      }
    } else {
      // Fallback to feed items
      questions = hubState.feedItems;
      totalCount = questions.length;
    }

    // Group questions by date for reader date dividers
    final Map<String, List<CurrentAffairsFeedItem>> grouped = {};
    for (final q in questions) {
      final dateKey = q.dateBn ?? q.dateFormatted ?? q.date ?? 'তারিখ বিহীন';
      grouped.putIfAbsent(dateKey, () => []).add(q);
    }

    int globalIndex = 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        title: Text(
          categoryTitle,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: questions.isEmpty
          ? Center(
              child: Text(
                'কোনো প্রশ্ন পাওয়া যায়নি',
                style: TextStyle(fontSize: 15.sp, color: Colors.grey),
              ),
            )
          : ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              children: [
                // 1. Header Banner (matching Image 3)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag_rounded,
                      color: const Color(0xFFDC2626),
                      size: 22.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        categoryTitle,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFDC2626),
                          height: 1.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Text(
                        '${_toBengaliNumber(totalCount)}টি প্রশ্ন',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),
                Divider(color: Colors.grey.withOpacity(0.25), thickness: 1),
                SizedBox(height: 8.h),

                // 2. Questions grouped by date (matching Image 3)
                ...grouped.entries.map((entry) {
                  final dateHeader = entry.key;
                  final dateQuestions = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Banner with green left accent border (matching Image 3)
                      Container(
                        margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFD1FAE5),
                            width: 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Container(
                                width: 4.w,
                                color: const Color(0xFF10B981),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_month_rounded,
                                        size: 15,
                                        color: Color(0xFF059669),
                                      ),
                                      SizedBox(width: 6.w),
                                      Expanded(
                                        child: Text(
                                          dateHeader,
                                          style: TextStyle(
                                            fontSize: 12.5.sp,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF065F46),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF475569),
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          '${_toBengaliNumber(dateQuestions.length)}টি প্রশ্ন',
                                          style: TextStyle(
                                            fontSize: 10.5.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Questions in this date group
                      ...dateQuestions.map((item) {
                        globalIndex++;
                        final questionNumber = _toBengaliNumber(globalIndex);

                        // Find correct option or answer
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

                        return Padding(
                          padding: EdgeInsets.only(bottom: 22.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Question Title with green serial number using HtmlWidget
                              HtmlWidget(
                                item.buildSanitizedHtmlTitle(
                                  prefix: '$questionNumber. ',
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

                              SizedBox(height: 10.h),

                              // Options 2-column or row layout (if withOptions)
                              if (withOptions && item.options.isNotEmpty) ...[
                                _buildOptionsGrid(item.options, isDark),
                                SizedBox(height: 10.h),
                              ],

                              // Correct Answer Pill (matching Image 3)
                              Container(
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
                                ),
                              ),

                              // Explanation Box (matching Image 3)
                              if ((item.explanation != null && item.explanation!.trim().isNotEmpty) ||
                                  (item.explanationHtml != null && item.explanationHtml!.trim().isNotEmpty)) ...[
                                SizedBox(height: 10.h),
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
                                    ],
                                  ),
                                ),
                              ],

                              SizedBox(height: 14.h),
                              Divider(color: Colors.grey.withOpacity(0.18), height: 1),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildOptionsGrid(List<CurrentAffairsOptionItem> options, bool isDark) {
    if (options.length == 4) {
      // 2 rows of 2 options (like Image 3: ক, খ on first row; গ, ঘ on second row)
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
        fontSize: 12.5.sp,
        color: isDark ? Colors.white70 : const Color(0xFF334155),
        height: 1.35,
      ),
    );
  }

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
}
