import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/question_bank/presentation/providers/question_bank_hub_notifier.dart';
import 'package:lokkha/features/quick_practice/quick_practice.dart';

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
      body: _buildQuestionBankCollection(popularBanks, hubState),
    );
  }

  Widget _buildQuestionBankCollection(
    List<HomeQuestionBankItem> popularBanks,
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
                color: context.borderColor.withValues(alpha: 0.6),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
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

          // ─── Popular Banks Header ─────────────────────────────────────────
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
                          color: const Color(0xFF006A4E).withValues(alpha: 0.12),
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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006A4E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '${popularBanks.length}টি প্রশ্নব্যাংক',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF006A4E),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ...popularBanks.map((bank) => _buildPopularBankCard(bank)),
          ],

          // ─── Empty Search State ───────────────────────────────────────────
          if (popularBanks.isEmpty) ...[
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
                    'অন্য কোনো নাম লিখে চেষ্টা করুন।',
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

  // ─── Neat, Clean, Minimal & Professional Popular Bank Card ─────────────────
  Widget _buildPopularBankCard(HomeQuestionBankItem bank) {
    Color themeColor;
    IconData iconData;

    switch (bank.themeColor) {
      case 'sky':
        themeColor = const Color(0xFF0284C7);
        iconData = Icons.verified_user_rounded;
        break;
      case 'rose':
        themeColor = const Color(0xFFE11D48);
        iconData = Icons.school_rounded;
        break;
      case 'amber':
        themeColor = const Color(0xFFD97706);
        iconData = Icons.account_balance_wallet_rounded;
        break;
      case 'emerald':
      default:
        themeColor = const Color(0xFF006A4E);
        iconData = Icons.account_balance_rounded;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 11.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: context.borderColor.withValues(alpha: context.isDark ? 0.7 : 0.8),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDark ? 0.25 : 0.03,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openPopularBank(context, bank),
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Clean Themed Icon Box
                Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: themeColor.withValues(
                      alpha: context.isDark ? 0.22 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Icon(
                    iconData,
                    color: themeColor,
                    size: 21.sp,
                  ),
                ),
                SizedBox(width: 12.w),

                // Center Column: Badges, Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge & Question Count Wrap
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 4.h,
                        children: [
                          if (bank.badge != null && bank.badge!.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.5.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(5.r),
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
                          if (bank.questionCount > 0)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.5.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: context.isDark
                                    ? const Color(0xFF064E3B)
                                    : const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              child: Text(
                                '${_formatBanglaNumber(bank.questionCount)}টি প্রশ্ন',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: context.primaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        bank.title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (bank.subtitle != null && bank.subtitle!.isNotEmpty) ...[
                        SizedBox(height: 3.h),
                        Text(
                          bank.subtitle!,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: context.textSecondary,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),

                // Clean Action Button matching Quick Practice
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'অনুশীলন',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Icon(
                        Icons.play_arrow_rounded,
                        size: 14.sp,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openPopularBank(BuildContext context, HomeQuestionBankItem bank) {
    final subject = QuickPracticeSubject(
      id: bank.id,
      name: bank.title,
      slug: bank.slug,
      questionsCount: bank.questionCount,
      childrenCount: 1, // Opens children topic view from production API
      showApp: true,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubjectChildrenView(subject: subject),
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
