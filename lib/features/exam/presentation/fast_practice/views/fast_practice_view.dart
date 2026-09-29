import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/features/study_material/study_material.dart';
import 'package:lokkha/core/theme/theme_extensions.dart';
import 'package:lokkha/core/theme/text_style.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/core/network/api_call_status.dart';

class FastPracticeView extends GetView<HomeController> {
  const FastPracticeView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Scaffold(
      body: Obx(
        () {
          switch (controller.subjectSectionApiStatus.value) {
            case ApiCallStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case ApiCallStatus.success:
              return Padding(
                padding: EdgeInsets.all(8.0.r),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 4,
                  ),
                  itemCount: controller
                          .subjectSectionModel.value.subjectSections?.length ??
                      0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final data = controller
                        .subjectSectionModel.value.subjectSections![index];
                    return GestureDetector(
                      onTap: () async {
                        MySharedPref.clearSubjectSection();
                        Get.to(
                          SubjectSectionView(
                            subject: controller.subjectSectionModel.value
                                .subjectSections![index].subject,
                          ),
                        );
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
                          ).paddingSymmetric(
                              horizontal: 2.00.w, vertical: 5.00.h),
                        ),
                      ),
                    );
                  },
                ),
              );
            case ApiCallStatus.error:
              return const Center(
                  child: Text("কিছু ভুল হয়েছে, আবার চেষ্টা করুন"));

            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}
