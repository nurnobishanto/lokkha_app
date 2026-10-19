import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/quick_practice/data/models/quick_practice_models.dart';
import 'package:lokkha/features/quick_practice/presentation/providers/quick_practice_providers.dart';
import 'package:lokkha/shared/widgets/web_exam_view.dart';

class SubjectExamSetupView extends ConsumerStatefulWidget {
  final int subjectId;
  final String subjectTitle;
  final int? availableQuestions;

  const SubjectExamSetupView({
    super.key,
    required this.subjectId,
    required this.subjectTitle,
    this.availableQuestions,
  });

  @override
  ConsumerState<SubjectExamSetupView> createState() =>
      _SubjectExamSetupViewState();
}

class _SubjectExamSetupViewState extends ConsumerState<SubjectExamSetupView> {
  int _questionCount = 10;
  bool _enableTimer = true;
  int _durationMinutes = 15;
  bool _enableNegativeMark = true;
  double _negativeMark = 0.25;
  String _questionOption = 'random'; // random, latest, unanswered

  @override
  void initState() {
    super.initState();
    // If available questions are fewer than 10, default to available count
    if (widget.availableQuestions != null && widget.availableQuestions! > 0) {
      if (widget.availableQuestions! < 10) {
        _questionCount = widget.availableQuestions!;
      }
    }
  }

  Future<void> _handleStartExam() async {
    if (!isLoggedIn.value) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AuthGatewayView()),
      );
      return;
    }

    final request = SubjectStartExamRequest(
      questionCount: _questionCount,
      enableTimer: _enableTimer,
      time: _enableTimer ? _durationMinutes : 0,
      enableNegativeMark: _enableNegativeMark,
      negativeMark: _enableNegativeMark ? _negativeMark : 0.0,
      questionOption: _questionOption,
    );

    final session =
        await ref.read(subjectExamSetupNotifierProvider.notifier).startExam(
              subjectId: widget.subjectId,
              request: request,
            );

    if (session != null && mounted) {
      final startUrl = session.startUrl;
      if (startUrl != null && startUrl.isNotEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WebExamView(
              title: widget.subjectTitle,
              url: startUrl,
              examId: session.examId,
              mode: ExamWebViewMode.start,
              isExamRunning: true,
            ),
          ),
        );
      } else {
        CustomSnackBar.showCustomErrorSnackBar(
          title: 'ত্রুটি',
          message: 'পরীক্ষার লিংক পাওয়া যায়নি। পুনরায় চেষ্টা করুন।',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(subjectExamSetupNotifierProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: CustomAppBar(
        title: widget.subjectTitle,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Topic Header Card
                    _buildTopicHeaderCard(context),

                    SizedBox(height: 16.h),

                    // Section 1: Question Count
                    _buildCardSection(
                      context: context,
                      icon: Icons.format_list_numbered_rounded,
                      title: 'প্রশ্ন সংখ্যা',
                      subtitle: 'পরীক্ষায় মোট কতটি প্রশ্ন থাকবে তা নির্বাচন করুন',
                      child: _buildQuestionCountSelector(context),
                    ),

                    SizedBox(height: 14.h),

                    // Section 2: Timer & Duration
                    _buildCardSection(
                      context: context,
                      icon: Icons.timer_outlined,
                      title: 'পরীক্ষার সময়সীমা',
                      trailing: Switch.adaptive(
                        value: _enableTimer,
                        activeThumbColor: context.primaryColor,
                        onChanged: (val) => setState(() => _enableTimer = val),
                      ),
                      child: _enableTimer
                          ? _buildDurationSelector(context)
                          : Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                'টাইমার ছাড়া আনলিমিটেড সময়ে পরীক্ষা দিতে পারবেন।',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: context.textMuted,
                                ),
                              ),
                            ),
                    ),

                    SizedBox(height: 14.h),

                    // Section 3: Negative Marking
                    _buildCardSection(
                      context: context,
                      icon: Icons.remove_circle_outline_rounded,
                      title: 'নেগেটিভ মার্কিং',
                      trailing: Switch.adaptive(
                        value: _enableNegativeMark,
                        activeThumbColor: context.primaryColor,
                        onChanged: (val) =>
                            setState(() => _enableNegativeMark = val),
                      ),
                      child: _enableNegativeMark
                          ? _buildNegativeMarkSelector(context)
                          : Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                'ভুল উত্তরের জন্য কোনো নম্বর কাটা যাবে না।',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: context.textMuted,
                                ),
                              ),
                            ),
                    ),

                    SizedBox(height: 14.h),

                    // Section 4: Question Filter Mode
                    _buildCardSection(
                      context: context,
                      icon: Icons.tune_rounded,
                      title: 'প্রশ্ন বাছাইয়ের নিয়ম',
                      subtitle: 'কোন ধরনের প্রশ্ন নিয়ে পরীক্ষা দিতে চান?',
                      child: _buildQuestionOptionSelector(context),
                    ),

                    SizedBox(height: 14.h),

                    // Section 5: Guidelines Card
                    _buildGuidelinesCard(context),

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),

            // Bottom Sticky CTA
            _buildBottomActionBar(context, setupState),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(
                alpha: context.isDark ? 0.25 : 0.1,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.quiz_rounded,
              color: context.primaryColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subjectTitle,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? const Color(0xFF064E3B)
                            : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'অনুশীলন পরীক্ষা সেটআপ',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: context.primaryColor,
                        ),
                      ),
                    ),
                    if (widget.availableQuestions != null &&
                        widget.availableQuestions! > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '${widget.availableQuestions}টি প্রশ্ন উপলব্ধ',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
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
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.sp, color: context.primaryColor),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 3.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: context.textMuted,
              ),
            ),
          ],
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }

  Widget _buildQuestionCountSelector(BuildContext context) {
    final available = widget.availableQuestions;
    final options = <int>[10, 15, 20, 30];

    // If available questions count is custom, add it if relevant
    if (available != null && available > 0 && !options.contains(available)) {
      if (available <= 50) {
        options.add(available);
        options.sort();
      }
    }

    return Row(
      children: options.map((count) {
        final isSelected = _questionCount == count;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: _buildChoiceChip(
              label: '$countটি',
              isSelected: isSelected,
              onTap: () => setState(() => _questionCount = count),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDurationSelector(BuildContext context) {
    return Row(
      children: [10, 15, 20, 30].map((mins) {
        final isSelected = _durationMinutes == mins;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: _buildChoiceChip(
              label: '$mins মিনিট',
              isSelected: isSelected,
              onTap: () => setState(() => _durationMinutes = mins),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNegativeMarkSelector(BuildContext context) {
    return Row(
      children: [
        {'label': '০.২৫ নম্বর', 'value': 0.25},
        {'label': '০.৫০ নম্বর', 'value': 0.50},
      ].map((item) {
        final val = item['value'] as double;
        final label = item['label'] as String;
        final isSelected = _negativeMark == val;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _buildChoiceChip(
              label: label,
              isSelected: isSelected,
              onTap: () => setState(() => _negativeMark = val),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionOptionSelector(BuildContext context) {
    final modes = [
      {'key': 'random', 'label': 'র‍্যান্ডম প্রশ্ন'},
      {'key': 'latest', 'label': 'সর্বশেষ প্রশ্ন'},
      {'key': 'unanswered', 'label': 'নতুন প্রশ্ন'},
    ];

    return Row(
      children: modes.map((m) {
        final key = m['key']!;
        final label = m['label']!;
        final isSelected = _questionOption == key;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: _buildChoiceChip(
              label: label,
              isSelected: isSelected,
              onTap: () => setState(() => _questionOption = key),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGuidelinesCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: context.isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 15.sp,
                color: context.primaryColor,
              ),
              SizedBox(width: 6.w),
              Text(
                'নির্দেশনাবলী',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          _buildBullet('নির্ধারিত সময় শেষ হলে পরীক্ষা স্বয়ংক্রিয়ভাবে সমাপ্ত হবে।'),
          _buildBullet('ভুল উত্তরের জন্য নির্ধারিত নেগেটিভ নম্বর কাটা যাবে।'),
          _buildBullet('পরীক্ষা শেষে লাইভ রেজাল্ট ও নির্ভুল ব্যাখ্যা দেখতে পাবেন।'),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 12.sp,
              color: context.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: context.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 9.h),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primaryColor.withValues(
                  alpha: context.isDark ? 0.25 : 0.1,
                )
              : (context.isDark
                  ? context.surfaceColor
                  : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? context.primaryColor : context.borderColor,
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? context.primaryColor : context.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    SubjectExamSetupState setupState,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(
          top: BorderSide(
            color: context.borderColor.withValues(alpha: 0.6),
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: ElevatedButton(
          onPressed: setupState.isStarting ? null : _handleStartExam,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primaryColor,
            disabledBackgroundColor:
                context.primaryColor.withValues(alpha: 0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          child: setupState.isStarting
              ? SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'পরীক্ষা শুরু করুন',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
