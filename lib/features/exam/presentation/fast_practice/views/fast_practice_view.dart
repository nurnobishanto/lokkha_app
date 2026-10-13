import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/features/study_material/study_material.dart';

class FastPracticeView extends ConsumerWidget {
  const FastPracticeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeNotifierProvider);

    if (homeState.isSubjectSectionLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (homeState.isSubjectSectionError) {
      return const Center(child: Text("কিছু ভুল হয়েছে, আবার চেষ্টা করুন"));
    }

    final sections = homeState.subjectSectionModel.subjectSections ?? [];
    return Padding(
      padding: EdgeInsets.all(8.0.r),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 4,
        ),
        itemCount: sections.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final data = sections[index];
          return GestureDetector(
            onTap: () async {
              await MySharedPref.clearSubjectSection();
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SubjectSectionView(
                      subject: data.subject,
                    ),
                  ),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(7.0),
                border: Border.all(
                  color: context.borderColor,
                  width: 0.8.w,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 2.00.w, vertical: 5.00.h),
                  child: Text(
                    data.name.toString(),
                    style: AppTextStyles.body2.copyWith(
                      height: 1.1.h,
                      fontSize: 12.sp,
                      color: context.textPrimary,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
