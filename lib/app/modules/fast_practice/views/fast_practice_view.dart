import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/modules/nav_bar_views/home/controllers/home_controller.dart';
import 'package:lokkha/app/modules/subject_sections/views/subject_sections_view.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import '../../../../styles/text_style.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../services/api_call_status.dart';

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
      // body: Obx(() {
      //   switch (controller.apiCallStatus.value) {
      //     case ApiCallStatus.loading:
      //       return const Center(child: CircularProgressIndicator());
      //     case ApiCallStatus.success:
      //       return SingleChildScrollView(
      //         child: Padding(
      //           padding: EdgeInsets.only(
      //             top: 16.0,
      //             bottom: 8.0.h,
      //             left: 8.0.h,
      //             right: 8.0.h,
      //           ),
      //           child: Center(
      //             child: Wrap(
      //               spacing: 10,
      //               runSpacing: 8,
      //               alignment: WrapAlignment.center,
      //               children: List.generate(
      //                   controller.model.value.subjects?.length ?? 0, (index) {
      //                 final subject = controller.model.value.subjects![index];
      //                 return InkWell(
      //                   onTap: () async {
      //                     MySharedPref.clearSubjectSection();
      //                     Get.to(SubjectSectionView(subject: subject));
      //                   },
      //                   child: Container(
      //                     padding: EdgeInsets.symmetric(
      //                         horizontal: 10.00.w, vertical: 8.00.h),
      //                     decoration: BoxDecoration(
      //                       color: LightThemeColors.white,
      //                       borderRadius: BorderRadius.circular(8),
      //                       border: Border.all(
      //                           color: LightThemeColors.primaryColor,
      //                           width: .2),
      //                       boxShadow: [
      //                         BoxShadow(
      //                           color: Colors.black.withValues(alpha: 0.05),
      //                           spreadRadius: 1,
      //                           blurRadius: 5,
      //                           offset: const Offset(0, 2),
      //                         ),
      //                       ],
      //                     ),
      //                     child: Text(
      //                       subject.name.toString(),
      //                       textAlign: TextAlign.center,
      //                       style: AppTextStyles.body2,
      //                     ),
      //                   ),
      //                 );
      //               }),
      //             ),
      //           ),
      //         ),
      //       );
      //     case ApiCallStatus.error:
      //       return const Center(child: Text("Failed to load data. Try again."));
      //     case ApiCallStatus.holding:
      //     default:
      //       return const SizedBox.shrink();
      //   }
      // }),
    );
  }
}
