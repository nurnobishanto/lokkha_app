import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/features/study_material/presentation/providers/current_affairs_hub_notifier.dart';

class CurrentAffairsDetailSheet extends ConsumerStatefulWidget {
  final int questionId;

  const CurrentAffairsDetailSheet({
    super.key,
    required this.questionId,
  });

  @override
  ConsumerState<CurrentAffairsDetailSheet> createState() =>
      _CurrentAffairsDetailSheetState();
}

class _CurrentAffairsDetailSheetState extends ConsumerState<CurrentAffairsDetailSheet> {
  int? _activeQuestionId;

  @override
  void initState() {
    super.initState();
    _activeQuestionId = widget.questionId;
    Future.microtask(() {
      ref.read(currentAffairsHubNotifierProvider.notifier).fetchQuestionDetail(_activeQuestionId);
    });
  }

  void _loadQuestion(int id) {
    setState(() {
      _activeQuestionId = id;
    });
    ref.read(currentAffairsHubNotifierProvider.notifier).fetchQuestionDetail(id);
  }

  @override
  Widget build(BuildContext context) {
    final hubState = ref.watch(currentAffairsHubNotifierProvider);
    final notifier = ref.read(currentAffairsHubNotifierProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    final detail = hubState.questionDetail;
    final question = detail?.question;
    final related = detail?.relatedQuestions ?? [];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
            width: 44.w,
            height: 4.5.h,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'প্রশ্ন ও বিস্তারিত ব্যাখ্যা',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (question != null)
                  IconButton(
                    icon: Icon(
                      question.isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: question.isBookmarked ? primaryColor : (isDark ? Colors.white60 : Colors.black45),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      notifier.toggleBookmark(question.id);
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: hubState.isDetailLoading
                ? const Center(child: CircularProgressIndicator())
                : question == null
                    ? Center(
                        child: Text(
                          'প্রশ্নের তথ্য লোড করা যায়নি',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                      )
                    : ListView(
                        padding: EdgeInsets.all(16.w),
                        children: [
                          // Category & Date Badge
                          Row(
                            children: [
                              if (question.category != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Text(
                                    question.category!.name,
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              if (question.dateBn != null) ...[
                                SizedBox(width: 8.w),
                                Text(
                                  question.dateBn!,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          SizedBox(height: 14.h),

                          // Question Title with HtmlWidget (clean, fast, readable)
                          HtmlWidget(
                            question.buildSanitizedHtmlTitle(isDark: isDark),
                            textStyle: TextStyle(
                              fontSize: 16.sp,
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

                          if (question.resolvedQuestionImage != null &&
                              question.resolvedQuestionImage!.isNotEmpty) ...[
                            SizedBox(height: 12.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.network(
                                question.resolvedQuestionImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                          ],

                          SizedBox(height: 16.h),

                          // Options
                          if (question.options.isNotEmpty) ...[
                            Text(
                              'বিকল্পসমূহ:',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : const Color(0xFF475569),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Column(
                              children: question.options.map((opt) {
                                final isCorrect = opt.isCorrect;
                                return Container(
                                  margin: EdgeInsets.only(bottom: 8.h),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? const Color(0xFF10B981).withOpacity(0.12)
                                        : (isDark
                                            ? const Color(0xFF0F172A)
                                            : const Color(0xFFF8FAFC)),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: isCorrect
                                          ? const Color(0xFF10B981)
                                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                      width: isCorrect ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24.w,
                                        height: 24.w,
                                        decoration: BoxDecoration(
                                          color: isCorrect
                                              ? const Color(0xFF10B981)
                                              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          opt.displayLabel,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color: isCorrect ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Text(
                                          opt.displayValue,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w400,
                                            color: isCorrect
                                                ? const Color(0xFF065F46)
                                                : (isDark ? Colors.white70 : const Color(0xFF334155)),
                                          ),
                                        ),
                                      ),
                                      if (isCorrect)
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: const Color(0xFF10B981),
                                          size: 20.sp,
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 12.h),
                          ],

                          // Detailed Explanation Box
                          Container(
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded, color: primaryColor, size: 18.sp),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'বিশদ ব্যাখ্যা',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                if (question.explanationHtml != null && question.explanationHtml!.isNotEmpty)
                                  HtmlWidget(
                                    question.explanationHtml!,
                                    textStyle: TextStyle(
                                      fontSize: 13.5.sp,
                                      height: 1.5,
                                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                                    ),
                                  )
                                else if (question.explanation != null && question.explanation!.isNotEmpty)
                                  Text(
                                    question.explanation!,
                                    style: TextStyle(
                                      fontSize: 13.5.sp,
                                      height: 1.5,
                                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                                    ),
                                  ),
                                if (question.resolvedExplanationImage != null &&
                                    question.resolvedExplanationImage!.isNotEmpty) ...[
                                  SizedBox(height: 10.h),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Image.network(question.resolvedExplanationImage!),
                                  ),
                                ],
                                if (question.reference != null && question.reference!.isNotEmpty) ...[
                                  SizedBox(height: 10.h),
                                  Text(
                                    'তথ্যসূত্র: ${question.reference}',
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Related Questions
                          if (related.isNotEmpty) ...[
                            SizedBox(height: 24.h),
                            Text(
                              'সম্পর্কিত অন্যান্য প্রশ্ন',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Column(
                              children: related.map((rel) {
                                return Card(
                                  elevation: 0,
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    side: BorderSide(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  margin: EdgeInsets.only(bottom: 8.h),
                                  child: ListTile(
                                    title: Text(
                                      rel.displayTitle,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'উত্তর: ${rel.answer ?? (rel.options.isNotEmpty ? rel.options.firstWhere((o) => o.isCorrect, orElse: () => rel.options.first).value : '')}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: const Color(0xFF10B981),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                                    onTap: () {
                                      _loadQuestion(rel.id);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
