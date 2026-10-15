import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/mock_test/mock_test.dart';
import 'package:lokkha/shared/models/mock_subject_select_model.dart';

class MockTestView extends ConsumerWidget {
  const MockTestView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mockTestNotifierProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "ডেটা লোড করা যায়নি, আবার চেষ্টা করুন",
              style: TextStyle(color: context.textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref
                  .read(mockTestNotifierProvider.notifier)
                  .getRootSubjects(isRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text("আবার চেষ্টা করুন"),
            ),
          ],
        ),
      );
    }

    final subjects = state.model?.subjects ?? [];
    return RefreshIndicator(
      color: context.primaryColor,
      onRefresh: () => ref
          .read(mockTestNotifierProvider.notifier)
          .getRootSubjects(isRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(
            top: 16.0,
            bottom: 24.0.h,
            left: 10.0.w,
            right: 10.0.w,
          ),
          child: Center(
            child: Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              alignment: WrapAlignment.center,
              children: List.generate(subjects.length, (index) {
                final subject = subjects[index];
                final qCount = subject.questionCount ?? 0;
                return InkWell(
                  onTap: () async {
                    MySharedPref.clearMockSubjects();
                    MockSubjectSelect newSubject = MockSubjectSelect(
                      id: subject.id,
                      name: subject.name,
                      quantity: min(15, qCount > 0 ? qCount : 15),
                      max: qCount > 0 ? qCount : null,
                    );
                    await MySharedPref.addOrUpdateMockSubjectSelect(
                        newSubject);

                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              TopicSelectionView(subject: subject),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.0.w, vertical: 9.0.h),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: context.isDark
                            ? context.borderColor
                            : context.primaryColor.withValues(alpha: 0.25),
                        width: context.isDark ? 0.8 : 0.6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.isDark
                              ? Colors.black.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.04),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 1.5),
                        ),
                      ],
                    ),
                    child: Text(
                      qCount > 0
                          ? '${subject.name} (${qCount > 999 ? '${(qCount / 1000).toStringAsFixed(1)}k' : '$qCount'})'
                          : subject.name.toString(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body2.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
