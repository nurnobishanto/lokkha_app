import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../config/theme/light_theme_colors.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import '../../../../../styles/text_style.dart';
import 'package:lokkha/app/data/models/bookmarked_question_model.dart';
import '../controllers/question_bank_controller.dart';

class QuestionBankView extends GetView<QuestionBankController> {
  const QuestionBankView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'প্রশ্ন ব্যাংক ও বুকমার্ক',
          style: AppTextStyles.heading4.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: LightThemeColors.primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: context.cardColor,
            child: TextField(
              onChanged: controller.onSearchChanged,
              style: TextStyle(color: context.textPrimary, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'প্রশ্ন খুঁজুন...',
                hintStyle: TextStyle(color: context.textMuted, fontSize: 13.sp),
                prefixIcon: Icon(Icons.search, color: context.textMuted),
                contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                fillColor: context.subtleSurfaceColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: context.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: context.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ),

          // 2. Subject Filter Horizontal List
          Container(
            height: 48.h,
            color: context.cardColor,
            child: Obx(() {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                itemCount: controller.subjects.length,
                itemBuilder: (context, index) {
                  final subject = controller.subjects[index];
                  final isSelected = controller.selectedSubject.value == subject;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
                    child: ChoiceChip(
                      label: Text(
                        subject,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isSelected ? Colors.white : context.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: LightThemeColors.primaryColor,
                      backgroundColor: context.subtleSurfaceColor,
                      showCheckmark: false,
                      side: BorderSide(color: isSelected ? Colors.transparent : context.borderColor),
                      onSelected: (_) => controller.onSubjectSelected(subject),
                    ),
                  );
                },
              );
            }),
          ),
          Divider(height: 1, color: context.borderColor),

          // 3. Questions List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final list = controller.filteredQuestions;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 64.w, color: context.textMuted),
                      SizedBox(height: 12.h),
                      Text(
                        'কোন সেভ করা প্রশ্ন পাওয়া যায়নি',
                        style: AppTextStyles.body1.copyWith(
                          color: context.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'পরীক্ষা দেওয়ার সময় প্রশ্ন বুকমার্ক করলে এখানে দেখতে পাবেন।',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body2.copyWith(color: context.textMuted),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchBookmarks,
                child: ListView.builder(
                  padding: EdgeInsets.all(12.w),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _QuestionCard(
                      question: item,
                      index: index + 1,
                      onDelete: () => controller.removeBookmark(item.id),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatefulWidget {
  final BookmarkedQuestion question;
  final int index;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.question,
    required this.index,
    required this.onDelete,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor),
        boxShadow: context.isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Subject Tag & Bookmark Remove
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  widget.question.subject,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.amber),
                onPressed: widget.onDelete,
                tooltip: 'বুকমার্ক সরান',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Question Title
          Text(
            "${widget.index}. ${widget.question.questionText}",
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),

          // Options (if any)
          if (widget.question.options.isNotEmpty)
            ...widget.question.options.map((opt) {
              final isCorrect = _showAnswer && opt.trim() == widget.question.correctAnswer.trim();
              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 6.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? (context.isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.1))
                      : context.subtleSurfaceColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isCorrect ? const Color(0xFF10B981) : context.borderColor,
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isCorrect
                        ? (context.isDark ? const Color(0xFF6EE7B7) : Colors.green.shade800)
                        : context.textPrimary,
                    fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }),

          SizedBox(height: 8.h),

          // Toggle Answer Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showAnswer = !_showAnswer;
                  });
                },
                icon: Icon(
                  _showAnswer ? Icons.visibility_off : Icons.visibility,
                  size: 16.sp,
                  color: Theme.of(context).primaryColor,
                ),
                label: Text(
                  _showAnswer ? "উত্তর লুকান" : "সঠিক উত্তর দেখুন",
                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.sp),
                ),
              ),
              if (_showAnswer && widget.question.correctAnswer.isNotEmpty)
                Text(
                  "উত্তর: ${widget.question.correctAnswer}",
                  style: TextStyle(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
            ],
          ),

          // Explanation (if shown)
          if (_showAnswer &&
              widget.question.explanation != null &&
              widget.question.explanation!.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 8.h),
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: context.isDark ? const Color(0xFF451A03).withValues(alpha: 0.3) : Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: context.isDark ? const Color(0xFFB45309).withValues(alpha: 0.4) : const Color(0xFFFDE68A),
                ),
              ),
              child: Text(
                "ব্যাখ্যা: ${widget.question.explanation}",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: context.isDark ? const Color(0xFFFCD34D) : const Color(0xFF78350F),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
