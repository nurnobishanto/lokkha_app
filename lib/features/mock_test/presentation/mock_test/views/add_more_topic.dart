import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/mock_test/mock_test.dart';
import 'package:lokkha/shared/models/mock_subject_select_model.dart';

class AddMoreTopic extends ConsumerStatefulWidget {
  const AddMoreTopic({super.key});

  @override
  ConsumerState<AddMoreTopic> createState() => _AddMoreTopicState();
}

class _AddMoreTopicState extends ConsumerState<AddMoreTopic> {
  List<MockSubjectSelect> _selectedSubjects = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedSubjects();
  }

  Future<void> _loadSelectedSubjects() async {
    final list = await MySharedPref.getMockSubjects();
    if (mounted) {
      setState(() {
        _selectedSubjects = list;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mockTestNotifierProvider);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          "আরও বিষয়",
          style: AppTextStyles.heading4.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: LightThemeColors.white),
        centerTitle: true,
        backgroundColor: LightThemeColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(
              state.model?.subjects?.length ?? 0,
              (index) {
                final subject = state.model!.subjects![index];
                final isSelected =
                    _selectedSubjects.any((s) => s.id == subject.id);

                if (isSelected) {
                  return const SizedBox.shrink();
                }

                return InkWell(
                  onTap: () async {
                    MockSubjectSelect newSubject = MockSubjectSelect(
                      id: subject.id,
                      name: subject.name,
                      quantity: min(15, subject.questionCount!.toInt()),
                      max: subject.questionCount!.toInt(),
                    );
                    await MySharedPref.addOrUpdateMockSubjectSelect(newSubject);
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              TopicSelectionView(subject: subject),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.00.w, vertical: 8.00.h),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: context.isDark
                            ? context.borderColor
                            : context.primaryColor.withValues(alpha: 0.3),
                        width: context.isDark ? 0.8 : 0.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.isDark
                              ? Colors.black.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.05),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      subject.name.toString(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body2.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
