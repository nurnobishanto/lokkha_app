import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/contest/contest.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/routes/routes.dart';
import 'package:lokkha/features/course/course.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/features/study_material/study_material.dart';
import 'package:lokkha/features/app_system/app_system.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    final ExamCategoryController examController = Get.find();
    Future<void> onRefresh() async {
      await controller.refreshHomeViewData();
      await AppUpdateService().fetchAppInfoAndCheckVersion();
      AppUpdateService().showInAppAnnouncementIfAvailable(force: true);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService().showInAppAnnouncementIfAvailable();
    });

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              AssetImagePaths.appIconHorizontal,
              scale: 5,
            ),
            SizedBox(width: 8.w),
            Text(
              "সঠিক পথে, স্বল্প সময়ে",
              style: AppTextStyles.custom(fontSize: 16.sp).copyWith(
                color: context.isDark
                    ? context.textPrimary
                    : Get.theme.indicatorColor,
              ),
            ),
          ],
        ),
        centerTitle: false,

        ///  Notification Icon with Badge
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {
                  Get.toNamed(Routes.NOTIFICATIONS);
                },
                icon: const Icon(Icons.notifications, size: 28),
              ),

              /// Red Badge
              Positioned(
                right: 6,
                top: 6,
                child: Obx(() {
                  // if (unReadNotificationCount.value == 0) {
                  //   return const SizedBox.shrink();
                  // }
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unReadNotificationCount.value.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],

        bottom: PreferredSize(
          preferredSize: Size.fromHeight(Get.height / 20 + 5),
          child: _SearchBar(
            onTap: () => Get.to(const ComingSoonPage()),
          ).paddingOnly(bottom: 5),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: EdgeInsets.fromLTRB(8.r, 2.h, 8.r, 16.h),
          children: [
            const PromoBarWidget(),
            3.h.height,
            _SliderSection(
              controller: controller,
              onTap: () {
                debugPrint("asssss");
              },
            ),
            8.h.height,
            _ShortcutGrid(controller: controller),
            8.h.height,
            RandomQuestionSelector(),
            8.h.height,
            SectionTitleWithSeeAll(
                title: "প্রিমিয়াম পরীক্ষা সমূহ",
                onSeeAllPressed: () {
                  Get.toNamed(Routes.ALL_COURSES);
                }),
            SizedBox(height: 8.h),
            _PremiumExamSection(),
            10.h.height,
            SectionTitleWithSeeAll(
                title: "ফ্রি পরীক্ষা সমূহ",
                onSeeAllPressed: () {
                  Get.toNamed(Routes.ALL_EXAM);
                }),
            SizedBox(height: 8.h),
            _FreeExamSection(examController: examController),
            8.h.height,
            const LatestContestWidget(),
            const LastContestResultWidget(),
            8.h.height,
            Obx(() {
              final overview = controller.dashboardOverview.value;
              final points = overview?.data?.accuracyPoints;
              if (points != null && points.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: AccuracyChartWidget(
                    points: points,
                    currentAccuracy: overview?.data?.accuracyRate ?? 0.0,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            Center(
              child: Text(
                "জনপ্রিয় প্রশ্নব্যাংক",
                style: AppTextStyles.custom(
                  fontSize: 17.00.sp,
                  fontWeight: FontWeight.w600,
                ).copyWith(color: context.textPrimary),
              ),
            ),
            SizedBox(height: 8.h),
            _SubjectSection(controller: controller),
            Divider(color: context.borderColor),
            SocialLinksScreen(),
            8.h.height,
          ],
        ),
      ),
    );
  }
}

class SectionTitleWithSeeAll extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllPressed;
  final Color? color;
  final double fontSize;
  final double dividerHeight;
  final EdgeInsetsGeometry padding;

  const SectionTitleWithSeeAll({
    super.key,
    required this.title,
    this.onSeeAllPressed,
    this.color,
    this.fontSize = 18,
    this.dividerHeight = 1.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 2),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.primaryColor;
    return InkWell(
      onTap: onSeeAllPressed,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: effectiveColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: transparentDivider(
                    beginTransparent: false,
                    height: dividerHeight,
                  ),
                ),
                TextButton(
                  onPressed: onSeeAllPressed,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'See All',
                    style: TextStyle(
                      fontSize: fontSize * 0.85,
                      color: effectiveColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------- Small extracted widgets -------------------------

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: Get.height / 20,
        decoration: BoxDecoration(
          color: context.primaryColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.r),
            bottomRight: Radius.circular(10.r),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.5.h),
        child: TextFormField(
          enabled: false,
          decoration: InputDecoration(
            hintText: "অনুসন্ধান করুন",
            hintStyle: TextStyle(color: context.textMuted),
            prefixIcon: Icon(Icons.search, color: context.textMuted),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide(color: context.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide(color: context.primaryColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
            filled: true,
            fillColor: context.cardColor,
          ),
        ),
      ),
    );
  }
}

class _SliderSection extends StatelessWidget {
  final HomeController controller;
  final void Function()? onTap;
  const _SliderSection({required this.controller, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.sliderApiStatus.value) {
        case ApiCallStatus.loading:
          return const Center(child: CircularProgressIndicator());
        case ApiCallStatus.error:
          return const Center(child: Text("Slider loading failed"));
        case ApiCallStatus.holding:
          return const SizedBox.shrink();
        case ApiCallStatus.success:
          final sliders = controller.sliderModel.value.sliders ?? [];
          if (sliders.isEmpty) return const SizedBox.shrink();

          return CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 14 / 4,
              enlargeCenterPage: true,
              enlargeStrategy: CenterPageEnlargeStrategy.height,
              autoPlay: true,
              viewportFraction: 1.0,
              onPageChanged: (currentIndex, reason) {
                controller.dotsCount = currentIndex;
              },
            ),
            items: sliders.map((sliderItem) {
              final imageUrl =
                  AppConstants.storageUrl + (sliderItem.image ?? '');
              if (kDebugMode) debugPrint('URL IMAGE : $imageUrl');
              return ClipRRect(
                borderRadius: BorderRadius.circular(7.0),
                child: InkWell(
                  onTap: () {
                    final page = sliderItem.page ?? "";
                    final link = sliderItem.link ?? "";
                    final param = sliderItem.param ?? "";

                    if (page.isNotEmpty) {
                      // Navigate to internal page
                      if (param.isNotEmpty) {
                        try {
                          // Decode JSON param and pass as direct GetX arguments
                          final decoded = jsonDecode(param); // JSON -> Map
                          Get.toNamed(page, arguments: decoded);
                        } catch (e) {
                          // If JSON fails → pass raw string fallback
                          Get.toNamed(page, arguments: {"param": param});
                        }
                      } else {
                        // Simple navigation without param
                        Get.toNamed(page);
                      }
                    } else if (link.isNotEmpty) {
                      final uri = Uri.tryParse(link);
                      if (uri != null && uri.path.isNotEmpty) {
                        final extractedPage = uri.path;

                        final segments = uri.pathSegments;
                        if (segments.isNotEmpty) {
                          final last = segments.last;

                          if (int.tryParse(last) != null) {
                            final id = int.parse(last);

                            // Build route without ID
                            final baseRoute =
                                "/${segments.sublist(0, segments.length - 1).join("/")}";

                            // Navigate with ID
                            Get.toNamed(baseRoute, arguments: id);
                            return;
                          }
                        }
                        if (isAppRoute(extractedPage)) {
                          final queryParams = uri.queryParameters;
                          debugPrint("3. $queryParams");
                          final Map<String, dynamic> parsedParams = {};

                          queryParams.forEach((key, value) {
                            final lowerKey = key.toLowerCase();

                            // Rule 1: keys like id, user_id, course_id etc → ALWAYS INT
                            final isIdField = lowerKey.endsWith("id") ||
                                lowerKey.contains("_id");

                            if (isIdField) {
                              parsedParams[key] = int.tryParse(value) ?? 0;
                            }
                            // Rule 2: value is purely numeric → convert to int
                            else if (int.tryParse(value) != null) {
                              parsedParams[key] = int.parse(value);
                            }
                            // Rule 3: fallback → keep as string
                            else {
                              parsedParams[key] = value;
                            }
                          });

                          if (parsedParams.isNotEmpty) {
                            Get.toNamed(extractedPage, arguments: parsedParams);
                          } else {
                            Get.toNamed(extractedPage);
                          }
                        } else {
                          debugPrint("4......");
                          // No matching route → open external link
                          openAppOrWebView(link);
                        }
                      } else {
                        debugPrint("5......");
                        // Invalid link fallback
                        openAppOrWebView(link);
                      }
                    }
                  },
                  child: Container(
                    height: 120.h,
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (c, u) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (c, u, e) =>
                            const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        case ApiCallStatus.empty:
          // TODO: Handle this case.
          throw UnimplementedError();
        case ApiCallStatus.cache:
          // TODO: Handle this case.
          throw UnimplementedError();
        case ApiCallStatus.refresh:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    });
  }
}

class _ShortcutGrid extends StatelessWidget {
  final HomeController controller;
  const _ShortcutGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < controller.gridViewTitle.length; i += 2) ...[
          if (i > 0) SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildItem(
                  context,
                  controller.gridViewTitle[i],
                  controller.gridViewRoutePage[i],
                ),
              ),
              if (i + 1 < controller.gridViewTitle.length) ...[
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildItem(
                    context,
                    controller.gridViewTitle[i + 1],
                    controller.gridViewRoutePage[i + 1],
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildItem(BuildContext context, String title, Widget route) {
    return GestureDetector(
      onTap: () => Get.to(route),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: context.isDark ? context.cardColor : LightThemeColors.softBg, // soft premium look
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: context.isDark
                ? context.borderColor
                : LightThemeColors.primaryColor.withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: context.isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: AppTextStyles.heading5.copyWith(
              color: context.isDark
                  ? context.textPrimary
                  : LightThemeColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _PremiumExamSection extends StatelessWidget {
  const _PremiumExamSection();

  @override
  Widget build(BuildContext context) {
    Get.put(SeeAllItemsController());
    final controller = Get.find<SeeAllItemsController>();

    return Obx(() {
      if (controller.courseApiCallStatus.value == ApiCallStatus.loading) {
        return SizedBox(
          height: 200.h,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      final courses = controller.allCourseModel.value.courses?.data ?? [];

      if (courses.isEmpty) {
        return const SizedBox.shrink();
      }

      return SizedBox(
        height: 140.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: courses.length,
          separatorBuilder: (_, __) => SizedBox(width: 7.w),
          itemBuilder: (_, index) {
            final course = courses[index];

            return SizedBox(
              width: 140.w,
              child: CustomCourseCard(
                imageUrl: AppConstants.storageUrl + course.image.toString(),
                title: course.title ?? "",
                regularPrice: course.regularPrice.toString(),
                salePrice: course.salePrice.toString(),
                rating: '5',
                onPressed: () {
                  Get.toNamed(
                    Routes.COURSE_DETAILS,
                    arguments: {'course_id': course.id},
                  );
                },
              ),
            );
          },
        ),
      );
    });
  }
}

class _FreeExamSection extends StatelessWidget {
  final ExamCategoryController examController;
  const _FreeExamSection({required this.examController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final exams = examController.model.value.examCategories ?? [];
      if (exams.isEmpty) return const SizedBox.shrink();
      return SizedBox(
        height: Get.height / 15,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: exams.length,
          separatorBuilder: (_, __) => SizedBox(width: 12.w),
          itemBuilder: (_, x) {
            final exam = exams[x];
            return ExamCategoryCard(
              title: exam.name ?? '',
              onTap: () {
                if (exam.id != null) {
                  Get.toNamed(Routes.EXAM_CATEGORY_DETAILS, arguments: {
                    "category_id": exam.id,
                    "category_name": exam.name,
                  });
                }
              },
              borderColor: context.isDark
                  ? context.borderColor
                  : LightThemeColors.primaryColor.withValues(alpha: 0.4),
              iconColor: context.primaryColor,
            );
          },
        ),
      );
    });
  }
}

class _SubjectSection extends StatelessWidget {
  final HomeController controller;
  const _SubjectSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.subjectSectionApiStatus.value) {
        case ApiCallStatus.loading:
          return const Center(child: CircularProgressIndicator());
        case ApiCallStatus.error:
          return const Center(child: Text("কিছু ভুল হয়েছে, আবার চেষ্টা করুন"));
        case ApiCallStatus.success:
          final list =
              controller.subjectSectionModel.value.subjectSections ?? [];
          if (list.isEmpty) return const SizedBox.shrink();
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 4,
            ),
            padding: EdgeInsets.zero,
            itemCount: list.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final data = list[index];
              return GestureDetector(
                onTap: () {
                  MySharedPref.clearSubjectSection();
                  Get.to(SubjectSectionView(subject: data.subject));
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
                    ).paddingSymmetric(horizontal: 2.00.w, vertical: 5.00.h),
                  ),
                ),
              );
            },
          );
        default:
          return const SizedBox.shrink();
      }
    });
  }
}
