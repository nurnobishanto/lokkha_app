import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../components/custom_app_bar.dart';
import '../../../../components/custom_snackbar.dart';
import '../models/exam_history_model.dart';
import '../models/exam_rank_model.dart';
import '../widgets/exam_rank_card.dart';

class ExamRankView extends StatelessWidget {
  final ExamHistoryModel exam;

  const ExamRankView({
    super.key,
    required this.exam,
  });

  @override
  Widget build(BuildContext context) {
    // Sample rank list matching screenshot
    final List<ExamRankModel> rankList = [
      const ExamRankModel(
        rank: 1,
        name: "নিশি আক্তার",
        studentId: "251000898",
        mark: "28.5(95%)",
        correct: "29(97%)",
        wrong: "1(3 %)",
        avoid: "0 (0 %)",
        isPassed: true,
      ),
      const ExamRankModel(
        rank: 2,
        name: "Farid ud Zaman",
        studentId: "251101321",
        mark: "9.5(31.67%)",
        correct: "16(53%)",
        wrong: "13(43 %)",
        avoid: "1 (3 %)",
        isPassed: false,
      ),
      const ExamRankModel(
        rank: 3,
        name: "মোঃ সাকিব আল হাসান",
        studentId: "250501124",
        mark: "8.0(26.67%)",
        correct: "14(47%)",
        wrong: "12(40 %)",
        avoid: "4 (13 %)",
        isPassed: false,
      ),
      const ExamRankModel(
        rank: 4,
        name: "তানজিনা রহমান",
        studentId: "250900452",
        mark: "7.5(25.00%)",
        correct: "12(40%)",
        wrong: "9(30 %)",
        avoid: "9 (30 %)",
        isPassed: false,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(
        title: 'পরীক্ষার র‍্যাঙ্ক তালিকা',
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 24.h),
        children: [
          // 1. Title with green vertical bar
          Row(
            children: [
              Container(
                width: 4.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "Rank : ${exam.title}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // 3. Download Rank List Button
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: () {
                CustomSnackBar.showCustomToast(
                  message: "র‍্যাঙ্ক তালিকা ডাউনলোড হচ্ছে...",
                );
              },
              icon: Icon(
                Icons.download_rounded,
                size: 16.sp,
                color: Colors.white,
              ),
              label: Text(
                "Download Rank List",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // 4. Rank Cards List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rankList.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              return ExamRankCard(item: rankList[index]);
            },
          ),
        ],
      ),
    );
  }
}
