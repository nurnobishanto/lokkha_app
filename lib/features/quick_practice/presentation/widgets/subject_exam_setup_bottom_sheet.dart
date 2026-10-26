import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/quick_practice/data/models/quick_practice_models.dart';
import 'package:lokkha/features/quick_practice/presentation/providers/quick_practice_providers.dart';
import 'package:lokkha/shared/widgets/web_exam_view.dart';

class SubjectExamSetupBottomSheet extends ConsumerStatefulWidget {
  final int subjectId;
  final String subjectTitle;
  final int? availableQuestions;

  const SubjectExamSetupBottomSheet({
    super.key,
    required this.subjectId,
    required this.subjectTitle,
    this.availableQuestions,
  });

  static Future<void> show(
    BuildContext context, {
    required int subjectId,
    required String subjectTitle,
    int? availableQuestions,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SubjectExamSetupBottomSheet(
        subjectId: subjectId,
        subjectTitle: subjectTitle,
        availableQuestions: availableQuestions,
      ),
    );
  }

  @override
  ConsumerState<SubjectExamSetupBottomSheet> createState() =>
      _SubjectExamSetupBottomSheetState();
}

class _SubjectExamSetupBottomSheetState
    extends ConsumerState<SubjectExamSetupBottomSheet> {
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
      Navigator.of(context).pop();
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

    if (session != null && mounted) {
      final startUrl = session.startUrl;
      if (startUrl != null && startUrl.isNotEmpty) {
        Navigator.of(context).pop();
        Navigator.of(context).push(
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(subjectExamSetupNotifierProvider);
    final available = widget.availableQuestions;
    final options = <int>[10, 15, 20, 30];
    if (available != null &&
        available > 0 &&
        available <= 50 &&
        !options.contains(available)) {
      options.add(available);
      options.sort();
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        14.w,
        10.h,
        14.w,
        MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Header Title + Subject
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(7.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006A4E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Icon(
                    Icons.quiz_outlined,
                    color: const Color(0xFF006A4E),
                    size: 19.sp,
                  ),
                ),
                SizedBox(width: 9.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'অনুশীলন পরীক্ষা সেটআপ',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        widget.subjectTitle,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: context.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 19.sp),
                  color: context.textMuted,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            Divider(height: 16.h, color: context.borderColor),

            // 1. Question Count Selection + Custom Input
            Text(
              'প্রশ্ন সংখ্যা',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
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
            SizedBox(height: 7.h),
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
                  final maxQ =
                      (available != null && available > 0) ? available : 200;
                  setState(() {
                    _questionCount = parsed.clamp(1, maxQ);
                  });
                }
              },
            ),

            SizedBox(height: 10.h),

            // 2. Timer & Duration (Disabled initially)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'পরীক্ষার সময়সীমা',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                Transform.scale(
                  scale: 0.88,
                  child: Switch.adaptive(
                    value: _enableTimer,
                    activeThumbColor: const Color(0xFF006A4E),
                    onChanged: (val) => setState(() => _enableTimer = val),
                  ),
                ),
              ],
            ),
            if (_enableTimer) ...[
              SizedBox(height: 4.h),
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
              SizedBox(height: 7.h),
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

            SizedBox(height: 10.h),

            // 3. Negative Marking (Disabled initially)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'নেগেটিভ মার্কিং',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                Transform.scale(
                  scale: 0.88,
                  child: Switch.adaptive(
                    value: _enableNegativeMark,
                    activeThumbColor: const Color(0xFF006A4E),
                    onChanged: (val) =>
                        setState(() => _enableNegativeMark = val),
                  ),
                ),
              ],
            ),
            if (_enableNegativeMark) ...[
              SizedBox(height: 4.h),
              Row(
                children: [
                  {'label': '০.২৫ নম্বর', 'value': 0.25},
                  {'label': '০.৫০ নম্বর', 'value': 0.50},
                  {'label': '১.০০ নম্বর', 'value': 1.00},
                ].map((item) {
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
              SizedBox(height: 7.h),
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

            SizedBox(height: 10.h),

            // 4. Question Filter Mode (All 6 API options)
            Text(
              'প্রশ্ন বাছাইয়ের নিয়ম',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            GridView.builder(
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
                final item = _questionFilterModes[index];
                final val = item['key']!;
                final label = item['label']!;
                final isSelected = _questionOption == val;
                return _buildChoiceChip(
                  label: label,
                  isSelected: isSelected,
                  onTap: () => setState(() => _questionOption = val),
                );
              },
            ),

            SizedBox(height: 14.h),

            // Error notice if any
            if (setupState.errorMessage != null) ...[
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: const Color(0xFFE11D48),
                      size: 16.sp,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        setupState.errorMessage!,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: const Color(0xFFBE123C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
            ],

            // Start Exam CTA Button
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: ElevatedButton(
                onPressed: setupState.isStarting ? null : _handleStartExam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006A4E),
                  disabledBackgroundColor:
                      const Color(0xFF006A4E).withValues(alpha: 0.6),
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
          ],
        ),
      ),
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
            size: 15.5.sp,
            color: context.textSecondary,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: context.textSecondary,
              ),
            ),
          ),
          _buildStepIconButton(
            context: context,
            icon: Icons.remove_rounded,
            onTap: onDecrement,
          ),
          SizedBox(width: 5.w),
          SizedBox(
            width: 54.w,
            height: 27.h,
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
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF006A4E),
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
                  borderSide: const BorderSide(
                    color: Color(0xFF006A4E),
                    width: 1.2,
                  ),
                ),
              ),
              onChanged: onChanged,
            ),
          ),
          SizedBox(width: 5.w),
          _buildStepIconButton(
            context: context,
            icon: Icons.add_rounded,
            onTap: onIncrement,
          ),
          SizedBox(width: 5.w),
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
        width: 25.r,
        height: 25.r,
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
          size: 13.5.sp,
          color: context.textPrimary,
        ),
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
              ? const Color(0xFF006A4E).withValues(
                  alpha: context.isDark ? 0.22 : 0.09,
                )
              : (context.isDark
                  ? context.surfaceColor
                  : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF006A4E) : context.borderColor,
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
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color:
                    isSelected ? const Color(0xFF006A4E) : context.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
