import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/exam/exam.dart';

class LatestExamStartDialog extends ConsumerStatefulWidget {
  final LatestExam latestExam;

  const LatestExamStartDialog({super.key, required this.latestExam});

  @override
  ConsumerState<LatestExamStartDialog> createState() =>
      _LatestExamStartDialogState();
}

class _LatestExamStartDialogState
    extends ConsumerState<LatestExamStartDialog> {
  late TextEditingController examTimeController;
  late String selectedNegativeMark;

  @override
  void initState() {
    super.initState();
    examTimeController = TextEditingController(
        text: widget.latestExam.tag!.questionCount.toString());
    selectedNegativeMark = '0.25';
  }

  @override
  void dispose() {
    examTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionCount = widget.latestExam.tag?.questionCount ?? 0;
    final state = ref.watch(latestExamNotifierProvider);

    return Dialog(
      backgroundColor: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.orange, size: 60),
            const SizedBox(height: 16),
            Text(
              'আপনি ${widget.latestExam.title} পরীক্ষায় দিতে চলেছেন',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _readOnlyField(
                    context: context,
                    label: 'প্রশ্ন',
                    value: questionCount.toString()),
                const SizedBox(width: 12),
                _editableField(
                    context: context,
                    label: 'পরীক্ষার সময়',
                    controller: examTimeController),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'প্রতিটি প্রশ্নের মান সমান ১',
                style: TextStyle(fontSize: 14, color: context.textMuted),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _button('পরীক্ষা শুরু', Colors.redAccent, Colors.white, () {
                  ref.read(latestExamNotifierProvider.notifier).fetchTagQuestions(
                        tag: widget.latestExam.tag!,
                        isStartExam: true,
                        duration:
                            int.tryParse(examTimeController.text) ?? 60,
                        selectedNegativeMark: selectedNegativeMark,
                        context: context,
                      );
                }),
                const SizedBox(width: 8),
                _button('পড়ুন', Colors.green, Colors.white, () {
                  ref.read(latestExamNotifierProvider.notifier).fetchTagQuestions(
                        tag: widget.latestExam.tag!,
                        isStartExam: false,
                        duration:
                            int.tryParse(examTimeController.text) ?? 60,
                        selectedNegativeMark: selectedNegativeMark,
                        context: context,
                      );
                }),
                const SizedBox(width: 8),
                _button(
                    'বাতিল',
                    context.isDark
                        ? context.subtleSurfaceColor
                        : Colors.grey.shade300,
                    context.textPrimary, () {
                  Navigator.pop(context);
                }),
              ],
            ),
            if (state.isLoadingQuestion) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _readOnlyField(
      {required BuildContext context,
      required String label,
      required String value}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: context.textPrimary)),
          const SizedBox(height: 6),
          TextField(
            readOnly: true,
            style: TextStyle(color: context.textPrimary),
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
              fillColor: context.subtleSurfaceColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.borderColor)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.borderColor)),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _editableField(
      {required BuildContext context,
      required String label,
      required TextEditingController controller}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: context.textPrimary)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            style: TextStyle(color: context.textPrimary),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              fillColor: context.subtleSurfaceColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.borderColor)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.borderColor)),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(
    String label,
    Color bgColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: AppTextStyles.body1.copyWith(color: textColor),
        ),
      ),
    );
  }
}
