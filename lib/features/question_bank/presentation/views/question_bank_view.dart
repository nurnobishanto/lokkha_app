import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/question_bank/presentation/providers/question_bank_hub_notifier.dart';
import 'package:lokkha/features/question_bank/presentation/widgets/question_bank_exam_sheet.dart';

class QuestionBankView extends ConsumerStatefulWidget {
  const QuestionBankView({super.key});

  @override
  ConsumerState<QuestionBankView> createState() => _QuestionBankViewState();
}

class _QuestionBankViewState extends ConsumerState<QuestionBankView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Dynamic API fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questionBankHubNotifierProvider.notifier).fetchQuestionBanks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hubState = ref.watch(questionBankHubNotifierProvider);
    final popularBanks = hubState.filteredPopularBanks;
    final subjectBanks = hubState.filteredSubjectBanks;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF006A4E),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(Routes.home);
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
        ),
        title: Text(
          'প্রশ্নব্যাংক হাব',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildQuestionBankCollection(popularBanks, subjectBanks, hubState),
    );
  }

  Widget _buildQuestionBankCollection(
    List<HomeQuestionBankItem> popularBanks,
    List<HomeQuestionBankItem> subjectBanks,
    QuestionBankHubState hubState,
  ) {
    return RefreshIndicator(
      color: const Color(0xFF006A4E),
      onRefresh: () async {
        await ref
            .read(questionBankHubNotifierProvider.notifier)
            .fetchQuestionBanks(isRefresh: true);
      },
      child: ListView(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 30.h),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // ─── Clean Minimal Search Bar ─────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: context.borderColor.withOpacity(0.6),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref
                    .read(questionBankHubNotifierProvider.notifier)
                    .setSearchQuery(val.trim());
              },
              decoration: InputDecoration(
                hintText: 'প্রশ্নব্যাংক বা বিষয় খুঁজুন...',
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: context.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF006A4E),
                  size: 22,
                ),
                suffixIcon: hubState.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(questionBankHubNotifierProvider.notifier)
                              .setSearchQuery('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              ),
            ),
          ),

          SizedBox(height: 18.h),

          // ─── 1. Popular Banks Section ─────────────────────────────────────
          if (popularBanks.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006A4E).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: const Icon(
                          Icons.stars_rounded,
                          color: Color(0xFF006A4E),
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'জনপ্রিয় প্রশ্নব্যাংক (Popular Banks)',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${popularBanks.length}টি',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ...popularBanks.map((bank) => _buildPopularBankCard(bank)),
            SizedBox(height: 16.h),
          ],

          // ─── 2. Subject-wise Banks Section ────────────────────────────────
          if (subjectBanks.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: const Icon(
                          Icons.auto_stories_rounded,
                          color: Color(0xFF0D9488),
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'বিষয়ভিত্তিক প্রশ্নব্যাংক',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${subjectBanks.length}টি বিষয়',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subjectBanks.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10.h,
                crossAxisSpacing: 10.w,
                childAspectRatio: 1.85,
              ),
              itemBuilder: (context, index) {
                final item = subjectBanks[index];
                return _buildSubjectBankCard(item);
              },
            ),
          ],

          // Empty Search State
          if (popularBanks.isEmpty && subjectBanks.isEmpty) ...[
            SizedBox(height: 40.h),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 56.r,
                    color: context.textMuted,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'কোনো প্রশ্নব্যাংক পাওয়া যায়নি',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textSecondary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'অন্য কোনো নাম বা বিষয় লিখে চেষ্টা করুন।',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Clean & Minimal Popular Bank Card (No Truncation) ─────────────────────
  Widget _buildPopularBankCard(HomeQuestionBankItem bank) {
    Color themeColor;
    Color lightBg;
    IconData iconData;

    switch (bank.themeColor) {
      case 'sky':
        themeColor = const Color(0xFF0284C7);
        lightBg = const Color(0xFFE0F2FE);
        iconData = Icons.military_tech_rounded;
        break;
      case 'rose':
        themeColor = const Color(0xFFE11D48);
        lightBg = const Color(0xFFFFE4E6);
        iconData = Icons.school_rounded;
        break;
      case 'amber':
        themeColor = const Color(0xFFD97706);
        lightBg = const Color(0xFFFEF3C7);
        iconData = Icons.account_balance_wallet_rounded;
        break;
      case 'emerald':
      default:
        themeColor = const Color(0xFF006A4E);
        lightBg = const Color(0xFFD1FAE5);
        iconData = Icons.account_balance_rounded;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: themeColor.withOpacity(0.25),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => QuestionBankExamSheet.show(context, bank),
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon + Badge + Title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: lightBg,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      iconData,
                      color: themeColor,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (bank.badge != null && bank.badge!.isNotEmpty) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 7.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: themeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              bank.badge!,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                        ],
                        // Title allowed 2 lines without truncation
                        Text(
                          bank.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.textSecondary,
                    size: 22,
                  ),
                ],
              ),

              if (bank.subtitle != null && bank.subtitle!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  bank.subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: context.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],

              SizedBox(height: 12.h),

              // Action Buttons Row (Exam System Integration)
              Row(
                children: [
                  // Start Exam Pill
                  InkWell(
                    onTap: () => QuestionBankExamSheet.show(context, bank),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.play_circle_fill_rounded,
                              size: 14, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(
                            'পরীক্ষা দিন',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Read / Practice Pill
                  InkWell(
                    onTap: () => QuestionBankExamSheet.show(context, bank),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.menu_book_rounded,
                              size: 14, color: themeColor),
                          SizedBox(width: 4.w),
                          Text(
                            'প্রশ্ন সমাধান',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Clean & Minimal Subject Bank Card ─────────────────────────────────────
  Widget _buildSubjectBankCard(HomeQuestionBankItem item) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: context.borderColor.withOpacity(0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => QuestionBankExamSheet.show(context, item),
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF006A4E).withOpacity(0.09),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '${_formatBanglaNumber(item.questionCount)} টি প্রশ্ন',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF006A4E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatBanglaNumber(int number) {
    const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final s = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final ch = s[i];
      final digit = int.tryParse(ch);
      if (digit != null) {
        buffer.write(banglaDigits[digit]);
      } else {
        buffer.write(ch);
      }
    }
    return buffer.toString();
  }
}

