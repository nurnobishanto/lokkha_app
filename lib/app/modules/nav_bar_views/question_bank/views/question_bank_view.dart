import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../config/theme/light_theme_colors.dart';
import '../../../../../styles/text_style.dart';
import 'package:lokkha/app/data/models/bookmarked_question_model.dart';
import '../controllers/question_bank_controller.dart';

class QuestionBankView extends GetView<QuestionBankController> {
  const QuestionBankView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
            color: Colors.white,
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'প্রশ্ন খুঁজুন...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                fillColor: const Color(0xFFF1F3F5),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. Subject Filter Horizontal List
          Container(
            height: 48.h,
            color: Colors.white,
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
                          color: isSelected ? Colors.white : LightThemeColors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: LightThemeColors.primaryColor,
                      backgroundColor: const Color(0xFFF1F3F5),
                      showCheckmark: false,
                      onSelected: (_) => controller.onSubjectSelected(subject),
                    ),
                  );
                },
              );
            }),
          ),
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),

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
                      Icon(Icons.bookmark_border, size: 64.w, color: Colors.grey.withValues(alpha: 0.5)),
                      SizedBox(height: 12.h),
                      Text(
                        'কোন সেভ করা প্রশ্ন পাওয়া যায়নি',
                        style: AppTextStyles.body1.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'পরীক্ষা দেওয়ার সময় প্রশ্ন বুকমার্ক করলে এখানে দেখতে পাবেন।',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body2.copyWith(color: Colors.grey),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
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
                  color: LightThemeColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  widget.question.subject,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: LightThemeColors.primaryColor,
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
              color: LightThemeColors.black,
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
                      ? Colors.green.withValues(alpha: 0.1)
                      : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isCorrect ? Colors.green : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isCorrect ? Colors.green.shade800 : Colors.black87,
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
                  color: LightThemeColors.primaryColor,
                ),
                label: Text(
                  _showAnswer ? "উত্তর লুকান" : "সঠিক উত্তর দেখুন",
                  style: TextStyle(color: LightThemeColors.primaryColor, fontSize: 12.sp),
                ),
              ),
              if (_showAnswer && widget.question.correctAnswer.isNotEmpty)
                Text(
                  "উত্তর: ${widget.question.correctAnswer}",
                  style: TextStyle(
                    color: Colors.green.shade700,
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
                color: Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "ব্যাখ্যা: ${widget.question.explanation}",
                style: TextStyle(fontSize: 12.sp, color: Colors.black87),
              ),
            ),
        ],
      ),
    );
  }
}
