import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/shared/shared.dart';
import '../controllers/onboarding_notifier.dart';
import '../widgets/onboarding_bottom_bar.dart';
import '../widgets/onboarding_curved_header.dart';
import '../widgets/onboarding_page_indicator.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onComplete() {
    ref.read(onboardingNotifierProvider.notifier).completeOnboarding();
    context.goNamed(Routes.home);
  }

  void _onNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingNotifierProvider);
    final items = state.items;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Page View: Each slide includes its own decorative curved header
          // so swiping gestures translate the header naturally with the illustration and text.
          PageView.builder(
            controller: _pageController,
            itemCount: items.length,
            onPageChanged: (index) {
              ref
                  .read(onboardingNotifierProvider.notifier)
                  .onPageChanged(index);
            },
            itemBuilder: (context, index) {
              final item = items[index];
              return Stack(
                children: [
                  // Top Curved Decorative Background for THIS slide (moves with swipe)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: OnboardingCurvedHeader(
                      pageIndex: index,
                      height: 290.h,
                    ),
                  ),

                  // Slide Content
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 120.h),

                          // Illustration Image (SVG)
                          SizedBox(
                            height: 240.h,
                            child: AppSvgImage(
                              item.imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),

                          SizedBox(height: 36.h),

                          // Page Indicator (Dots / Pill)
                          OnboardingPageIndicator(
                            count: items.length,
                            currentIndex: state.currentPage,
                          ),

                          SizedBox(height: 24.h),

                          // Heading
                          if (item.highlightTitle.isNotEmpty)
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'BalooDa2',
                                ),
                                children: [
                                  TextSpan(
                                    text: item.titlePrefix,
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  TextSpan(
                                    text: item.highlightTitle,
                                    style: const TextStyle(
                                      color: Color(0xFF1F7D61),
                                    ),
                                  ),
                                  if (item.titleSuffix.isNotEmpty)
                                    TextSpan(
                                      text: item.titleSuffix,
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          else
                            Text(
                              item.fullTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                                fontFamily: 'BalooDa2',
                              ),
                            ),

                          SizedBox(height: 12.h),

                          // Subtitle
                          Text(
                            item.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF475569),
                              height: 1.5,
                              fontWeight: FontWeight.normal,
                            ),
                          ),

                          // Bottom spacing to prevent overlap with floating action bar
                          SizedBox(height: 80.h),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Bottom Action Bar (fixed at bottom over PageView)
          Positioned(
            left: 24.w,
            right: 24.w,
            bottom: 24.h,
            child: SafeArea(
              top: false,
              child: OnboardingBottomBar(
                isLastPage: state.isLastPage,
                onSkip: _onComplete,
                onNext: _onNext,
                onGetStarted: _onComplete,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
