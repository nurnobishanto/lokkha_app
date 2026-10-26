import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _enableTimer = false;
  int _durationMinutes = 15;
  bool _enableNegativeMark = false;
  double _negativeMark = 0.25;
  String _questionOption = 'random';

  late final TextEditingController _questionCountController;
  late final TextEditingController _durationController;
  late final TextEditingController _negativeMarkController;

  static const List<Map<String, String>> _questionFilterModes = [
    {'key': 'random', 'label': 'র‍্যান্ডম প্রশ্ন'},
    {'key': 'latest', 'label': 'সর্বশেষ প্রশ্ন'},
    {'key': 'unanswered', 'label': 'নতুন প্রশ্ন'},
    {'key': 'answered', 'label': 'উত্তর দেওয়া'},
    {'key': 'wrong_answered', 'label': 'ভুল উত্তর'},
    {'key': 'correct_answered', 'label': 'সঠিক উত্তর'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.availableQuestions != null && widget.availableQuestions! > 0) {
      if (widget.availableQuestions! < 10) {
        _questionCount = widget.availableQuestions!;
      }
    }
    _questionCountController =
        TextEditingController(text: _questionCount.toString());
    _durationController =
        TextEditingController(text: _durationMinutes.toString());
    _negativeMarkController =
        TextEditingController(text: _negativeMark.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _questionCountController.dispose();
    _durationController.dispose();
    _negativeMarkController.dispose();
    super.dispose();
  }

  void _selectQuestionCount(int count) {
    final maxQ = (widget.availableQuestions != null &&
            widget.availableQuestions! > 0)
        ? widget.availableQuestions!
        : 200;
    final clamped = count.clamp(1, maxQ);
    setState(() {
      _questionCount = clamped;
      _questionCountController.text = clamped.toString();
      _questionCountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _questionCountController.text.length),
      );
    });
  }

  void _selectDuration(int mins) {
    final clamped = mins.clamp(1, 300);
    setState(() {
      _durationMinutes = clamped;
      _durationController.text = clamped.toString();
      _durationController.selection = TextSelection.fromPosition(
        TextPosition(offset: _durationController.text.length),
      );
    });
  }

  void _selectNegativeMark(double mark) {
    final clamped = mark.clamp(0.05, 5.0);
    setState(() {
      _negativeMark = clamped;
      _negativeMarkController.text = clamped.toStringAsFixed(2);
      _negativeMarkController.selection = TextSelection.fromPosition(
        TextPosition(offset: _negativeMarkController.text.length),
      );
    });
  }

  Future<void> _handleStartExam() async {
    FocusScope.of(context).unfocus();

    if (!isLoggedIn.value) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AuthGatewayView()),
      );
      return;
    }

    final request = SubjectStartExamRequest(
      questionCount: _questionCount,
      enableTimer: _enableTimer,
      time: _enableTimer ? _durationMinutes : null,
      enableNegativeMark: _enableNegativeMark,
      negativeMark: _enableNegativeMark ? _negativeMark : null,
      questionOption: _questionOption,
    );

    final session =
        await ref.read(subjectExamSetupNotifierProvider.notifier).startExam(
              subjectId: widget.subjectId,
              request: request,
            );

    if (!mounted) return;

    if (session != null) {
      final startUrl = session.startUrl;
      if (startUrl != null && startUrl.isNotEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WebExamView(
              title: session.examName?.isNotEmpty == true
                  ? session.examName!
                  : widget.subjectTitle,
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
    } else {
      final errMsg = ref.read(subjectExamSetupNotifierProvider).errorMessage;
      CustomSnackBar.showCustomErrorSnackBar(
        title: 'ত্রুটি',
        message:
            errMsg ?? 'পরীক্ষা তৈরি করা সম্ভব হয়নি। অনুগ্রহ করে পুনরায় চেষ্টা করুন।',
      );
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Minimal Topic Header Card
                      _buildTopicHeaderCard(context),

                      SizedBox(height: 12.h),

                      // Section 1: Question Count (Presets + Custom Input)
                      _buildCardSection(
                        context: context,
                        icon: Icons.format_list_numbered_rounded,
                        title: 'প্রশ্ন সংখ্যা',
                        subtitle:
                            'পরীক্ষায় মোট কতটি প্রশ্ন থাকবে তা নির্বাচন করুন বা লিখুন',
                        child: _buildQuestionCountSelector(context),
                      ),

                      SizedBox(height: 10.h),

                      // Section 2: Timer & Duration (Disabled initially)
                      _buildCardSection(
                        context: context,
                        icon: Icons.timer_outlined,
                        title: 'পরীক্ষার সময়সীমা',
                        trailing: Transform.scale(
                          scale: 0.88,
                          child: Switch.adaptive(
                            value: _enableTimer,
                            activeThumbColor: context.primaryColor,
                            onChanged: (val) =>
                                setState(() => _enableTimer = val),
                          ),
                        ),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: _enableTimer
                              ? _buildDurationSelector(context)
                              : Padding(
                                  padding: EdgeInsets.only(top: 2.h),
                                  child: Text(
                                    'টাইমার ছাড়া আনলিমিটেড সময়ে পরীক্ষা দিতে পারবেন।',
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      color: context.textMuted,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 10.h),

                      // Section 3: Negative Marking (Disabled initially)
                      _buildCardSection(
                        context: context,
                        icon: Icons.remove_circle_outline_rounded,
                        title: 'নেগেটিভ মার্কিং',
                        trailing: Transform.scale(
                          scale: 0.88,
                          child: Switch.adaptive(
                            value: _enableNegativeMark,
                            activeThumbColor: context.primaryColor,
                            onChanged: (val) =>
                                setState(() => _enableNegativeMark = val),
                          ),
                        ),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: _enableNegativeMark
                              ? _buildNegativeMarkSelector(context)
                              : Padding(
                                  padding: EdgeInsets.only(top: 2.h),
                                  child: Text(
                                    'ভুল উত্তরের জন্য কোনো নম্বর কাটা যাবে না।',
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      color: context.textMuted,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 10.h),

                      // Section 4: Question Filter Mode (All 6 API options)
                      _buildCardSection(
                        context: context,
                        icon: Icons.tune_rounded,
                        title: 'প্রশ্ন বাছাইয়ের নিয়ম',
                        subtitle: 'কোন ধরনের প্রশ্ন নিয়ে পরীক্ষা দিতে চান?',
                        child: _buildQuestionOptionSelector(context),
                      ),

                      SizedBox(height: 10.h),

                      // Section 5: Live Guidelines Card
                      _buildGuidelinesCard(context),

                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
              ),

              // Bottom Sticky CTA
              _buildBottomActionBar(context, setupState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              context.borderColor.withValues(alpha: context.isDark ? 0.65 : 0.75),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(
                alpha: context.isDark ? 0.22 : 0.08,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.quiz_outlined,
              color: context.primaryColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subjectTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 5.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? const Color(0xFF064E3B)
                            : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(
                        'অনুশীলন পরীক্ষা সেটআপ',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w600,
                          color: context.primaryColor,
                        ),
                      ),
                    ),
                    if (widget.availableQuestions != null &&
                        widget.availableQuestions! > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Text(
                          '${widget.availableQuestions}টি প্রশ্ন উপলব্ধ',
                          style: TextStyle(
                            fontSize: 10.5.sp,
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              context.borderColor.withValues(alpha: context.isDark ? 0.65 : 0.75),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17.sp, color: context.primaryColor),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.sp,
                color: context.textMuted,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }

  Widget _buildQuestionCountSelector(BuildContext context) {
    final available = widget.availableQuestions;
    final options = <int>[10, 15, 20, 30];

    if (available != null && available > 0 && !options.contains(available)) {
      if (available <= 50) {
        options.add(available);
        options.sort();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preset Chips Row
        Row(
          children: options.map((count) {
            final isSelected = _questionCount == count;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.5.w),
                child: _buildChoiceChip(
                  label: '$countটি',
                  isSelected: isSelected,
                  onTap: () => _selectQuestionCount(count),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 8.h),
        // Custom Question Count Input Row
        _buildCustomNumberInputRow(
          context: context,
          label: 'কাস্টম প্রশ্ন সংখ্যা',
          unit: 'টি',
          controller: _questionCountController,
          isDecimal: false,
          onDecrement: () => _selectQuestionCount(_questionCount - 1),
          onIncrement: () => _selectQuestionCount(_questionCount + 1),
          onChanged: (val) {
            final parsed = int.tryParse(val.trim());
            if (parsed != null && parsed > 0) {
              final maxQ = (available != null && available > 0) ? available : 200;
              setState(() {
                _questionCount = parsed.clamp(1, maxQ);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDurationSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [10, 15, 20, 30].map((mins) {
            final isSelected = _durationMinutes == mins;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.5.w),
                child: _buildChoiceChip(
                  label: '$mins মিনিট',
                  isSelected: isSelected,
                  onTap: () => _selectDuration(mins),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 8.h),
        _buildCustomNumberInputRow(
          context: context,
          label: 'কাস্টম সময়সীমা',
          unit: 'মিনিট',
          controller: _durationController,
          isDecimal: false,
          onDecrement: () => _selectDuration(_durationMinutes - 1),
          onIncrement: () => _selectDuration(_durationMinutes + 1),
          onChanged: (val) {
            final parsed = int.tryParse(val.trim());
            if (parsed != null && parsed > 0) {
              setState(() {
                _durationMinutes = parsed.clamp(1, 300);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildNegativeMarkSelector(BuildContext context) {
    final presets = [
      {'label': '০.২৫ নম্বর', 'value': 0.25},
      {'label': '০.৫০ নম্বর', 'value': 0.50},
      {'label': '১.০০ নম্বর', 'value': 1.00},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: presets.map((item) {
            final val = item['value'] as double;
            final label = item['label'] as String;
            final isSelected = (_negativeMark - val).abs() < 0.001;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.5.w),
                child: _buildChoiceChip(
                  label: label,
                  isSelected: isSelected,
                  onTap: () => _selectNegativeMark(val),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 8.h),
        _buildCustomNumberInputRow(
          context: context,
          label: 'কাস্টম নেগেটিভ মার্ক',
          unit: 'নম্বর',
          controller: _negativeMarkController,
          isDecimal: true,
          onDecrement: () => _selectNegativeMark(_negativeMark - 0.05),
          onIncrement: () => _selectNegativeMark(_negativeMark + 0.05),
          onChanged: (val) {
            final parsed = double.tryParse(val.trim());
            if (parsed != null && parsed > 0) {
              setState(() {
                _negativeMark = parsed.clamp(0.01, 5.0);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildCustomNumberInputRow({
    required BuildContext context,
    required String label,
    required String unit,
    required TextEditingController controller,
    required bool isDecimal,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: context.isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.6)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.65),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 16.sp,
            color: context.textSecondary,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w500,
                color: context.textSecondary,
              ),
            ),
          ),
          // Stepper Minus Button
          _buildStepIconButton(
            context: context,
            icon: Icons.remove_rounded,
            onTap: onDecrement,
          ),
          SizedBox(width: 6.w),
          // Compact Number Input Field
          SizedBox(
            width: 58.w,
            height: 28.h,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
              inputFormatters: [
                if (isDecimal)
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                else
                  FilteringTextInputFormatter.digitsOnly,
              ],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: context.primaryColor,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 5.h),
                filled: true,
                fillColor: context.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: BorderSide(
                    color: context.borderColor,
                    width: 0.8,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: BorderSide(
                    color: context.borderColor,
                    width: 0.8,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: BorderSide(
                    color: context.primaryColor,
                    width: 1.2,
                  ),
                ),
              ),
              onChanged: onChanged,
            ),
          ),
          SizedBox(width: 6.w),
          // Stepper Plus Button
          _buildStepIconButton(
            context: context,
            icon: Icons.add_rounded,
            onTap: onIncrement,
          ),
          SizedBox(width: 6.w),
          Text(
            unit,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: context.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        width: 26.r,
        height: 26.r,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: context.borderColor.withValues(alpha: 0.8),
            width: 0.8,
          ),
        ),
        child: Icon(
          icon,
          size: 14.sp,
          color: context.textPrimary,
        ),
      ),
    );
  }

  Widget _buildQuestionOptionSelector(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _questionFilterModes.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6.h,
        crossAxisSpacing: 6.w,
        mainAxisExtent: 34.h,
      ),
      itemBuilder: (context, index) {
        final mode = _questionFilterModes[index];
        final key = mode['key']!;
        final label = mode['label']!;
        final isSelected = _questionOption == key;
        return _buildChoiceChip(
          label: label,
          isSelected: isSelected,
          onTap: () => setState(() => _questionOption = key),
        );
      },
    );
  }

  Widget _buildGuidelinesCard(BuildContext context) {
    final selectedModeLabel = _questionFilterModes.firstWhere(
      (m) => m['key'] == _questionOption,
      orElse: () => _questionFilterModes.first,
    )['label'];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(11.r),
      decoration: BoxDecoration(
        color: context.isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(11.r),
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
                size: 14.5.sp,
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
          SizedBox(height: 5.h),
          _buildBullet(
            'মোট প্রশ্ন: $_questionCountটি। প্রতিটি সঠিক উত্তরের জন্য ১.০০ নম্বর বরাদ্দ থাকবে।',
          ),
          _buildBullet(
            _enableNegativeMark
                ? 'নেগেটিভ মার্কিং: প্রতিটি ভুল উত্তরের জন্য ${_negativeMark.toStringAsFixed(2)} নম্বর কাটা যাবে।'
                : 'নেগেটিভ মার্কিং: ভুল উত্তরের জন্য কোনো নম্বর কাটা যাবে না।',
          ),
          _buildBullet(
            _enableTimer
                ? 'সময়সীমা: $_durationMinutes মিনিট। নির্ধারিত সময় শেষ হলে পরীক্ষা স্বয়ংক্রিয়ভাবে সমাপ্ত হবে।'
                : 'সময়সীমা: কোনো নির্দিষ্ট সময়সীমা নেই। স্বাচ্ছন্দ্যে নিজের গতিতে অনুশীলন সম্পন্ন করতে পারেন।',
          ),
          _buildBullet('প্রশ্ন বাছাই পদ্ধতি: $selectedModeLabel।'),
          _buildBullet(
            'ফলাফল দেখার পর প্রশ্নভিত্তিক নির্ভুল সমাধান ও ব্যাখ্যা পর্যালোচনা করতে পারবেন।',
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 2.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 11.5.sp,
              color: context.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.sp,
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
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 7.5.h),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primaryColor.withValues(
                  alpha: context.isDark ? 0.22 : 0.09,
                )
              : (context.isDark
                  ? context.surfaceColor
                  : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? context.primaryColor : context.borderColor,
            width: isSelected ? 1.3 : 0.85,
          ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(
          top: BorderSide(
            color: context.borderColor.withValues(alpha: 0.6),
            width: 0.8,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 44.h,
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
                  width: 20.r,
                  height: 20.r,
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
                      size: 20.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'পরীক্ষা শুরু করুন',
                      style: TextStyle(
                        fontSize: 14.sp,
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
