import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/home/presentation/home/riverpod/home_feed_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeSliderSection extends ConsumerWidget {
  final List<HomeSliderItem> sliders;

  const HomeSliderSection({
    super.key,
    required this.sliders,
  });

  void _onSlideTap(BuildContext context, HomeSliderItem item) async {
    if (item.link != null && item.link!.isNotEmpty) {
      final uri = Uri.tryParse(item.link!);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    if (!context.mounted) return;

    final page = item.navigation?.page?.toLowerCase();
    if (page == null || page.isEmpty) return;

    if (GoRouter.maybeOf(context) == null) return;

    switch (page) {
      case 'packages':
        context.go(Routes.packages);
        break;
      case 'courses':
        context.push(Routes.courses);
        break;
      case 'exams':
      case 'all_exam':
        context.push(Routes.allExam);
        break;
      case 'contests':
      case 'all_contest':
        context.push(Routes.allContest);
        break;
      case 'jobs':
        context.push(Routes.jobs);
        break;
      case 'current_affairs':
        context.push(Routes.currentAffairs);
        break;
      case 'vocabulary':
        context.push(Routes.vocabulary);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sliders.isEmpty) return const SizedBox.shrink();


    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: CarouselSlider.builder(
        itemCount: sliders.length,
        options: CarouselOptions(
          aspectRatio: 16 / 5.2,
          viewportFraction: 0.98,
          enlargeCenterPage: false,
          autoPlay: sliders.length > 1,
          autoPlayInterval: const Duration(seconds: 4),
          autoPlayAnimationDuration: const Duration(milliseconds: 600),
          autoPlayCurve: Curves.easeInOutCubic,
          onPageChanged: (index, reason) {
            ref.read(homeFeedNotifierProvider.notifier).setSliderIndex(index);
          },
        ),
        itemBuilder: (context, index, realIndex) {
          final item = sliders[index];
          return GestureDetector(
            onTap: () => _onSlideTap(context, item),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: context.borderColor.withValues(alpha: 0.2),
                    child: Center(
                      child: SizedBox(
                        width: 22.r,
                        height: 22.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: context.borderColor.withValues(alpha: 0.15),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 28.sp,
                        color: context.textSecondary,
                      ),
                    ),
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
