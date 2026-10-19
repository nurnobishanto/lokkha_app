import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokkha/core/constants/app_category_vectors.dart';
import 'package:lokkha/core/core.dart';

class ExamCategoryCard extends StatelessWidget {
  final String title;
  final String? slug;
  final String? imageUrl;
  final String? svgPath;
  final String? themeIcon;
  final Color? borderColor;
  final Color? iconColor;
  final bool? isIcon;
  final bool isPremium;
  final VoidCallback? onTap;

  const ExamCategoryCard({
    super.key,
    required this.title,
    this.slug,
    this.imageUrl,
    this.svgPath,
    this.themeIcon,
    this.borderColor,
    this.iconColor,
    this.isIcon = true,
    this.isPremium = false,
    this.onTap,
  });

  /// Map category slug, title, or theme icon to inline SVG vector string.
  /// Using SvgPicture.string allows instant rendering upon hot reload without restarting the app.
  static String getCategorySvgString({
    String? slug,
    String? title,
    String? themeIcon,
  }) {
    final s = (slug ?? '').toLowerCase();
    final t = (title ?? '').toLowerCase();

    // 1. BCS variations
    if (s.contains('50-bcs') || s.contains('47-bcs')) {
      return AppCategoryVectors.catBookBlue;
    }
    if (s.contains('bcs') || t.contains('bcs')) {
      return AppCategoryVectors.catBookRed;
    }

    // 2. Primary / School
    if (s.contains('primary') ||
        s.contains('praimari') ||
        t.contains('primary') ||
        t.contains('প্রাইমারি')) {
      return AppCategoryVectors.catSchool;
    }

    // 3. NTRCA / Teacher
    if (s.contains('ntrca') ||
        s.contains('nibndhn') ||
        t.contains('ntrca') ||
        t.contains('নিবন্ধন') ||
        t.contains('শিক্ষক')) {
      return AppCategoryVectors.catTeacher;
    }

    // 4. Bank Preparation
    if (s.contains('bank') || t.contains('bank') || t.contains('ব্যাংক')) {
      return AppCategoryVectors.catBank;
    }

    // 5. Grade 9-10 / 11-20
    if (s.contains('grade') || t.contains('grade') || t.contains('গ্রেড')) {
      return AppCategoryVectors.catCap;
    }

    // 6. Current Affairs / সাম্প্রতিক
    if (s.contains('smprti') ||
        s.contains('affair') ||
        t.contains('সাম্প্রতিক')) {
      return AppCategoryVectors.catCurrentAffairs;
    }

    // 7. University Admission
    if (s.contains('university') ||
        t.contains('university') ||
        t.contains('বিশ্ববিদ্যালয়')) {
      return AppCategoryVectors.catUniversity;
    }

    // Fallbacks based on theme icon string
    if (themeIcon == 'ri-book-open-fill') return AppCategoryVectors.catBookRed;
    if (themeIcon == 'ri-award-fill') return AppCategoryVectors.catTeacher;
    if (themeIcon == 'ri-medal-fill') return AppCategoryVectors.catBank;
    if (themeIcon == 'ri-graduation-cap-fill') return AppCategoryVectors.catCap;
    if (themeIcon == 'ri-trophy-fill') return AppCategoryVectors.catUniversity;

    return AppCategoryVectors.catBookRed;
  }

  /// Map category to asset file path as alternative.
  static String getCategorySvgPath({
    String? slug,
    String? title,
    String? themeIcon,
  }) {
    final s = (slug ?? '').toLowerCase();
    final t = (title ?? '').toLowerCase();

    if (s.contains('50-bcs') || s.contains('47-bcs')) {
      return AssetVectorPaths.catBookBlue;
    }
    if (s.contains('bcs') || t.contains('bcs')) {
      return AssetVectorPaths.catBookRed;
    }
    if (s.contains('primary') ||
        s.contains('praimari') ||
        t.contains('primary') ||
        t.contains('প্রাইমারি')) {
      return AssetVectorPaths.catSchool;
    }
    if (s.contains('ntrca') ||
        s.contains('nibndhn') ||
        t.contains('ntrca') ||
        t.contains('নিবন্ধন') ||
        t.contains('শিক্ষক')) {
      return AssetVectorPaths.catTeacher;
    }
    if (s.contains('bank') || t.contains('bank') || t.contains('ব্যাংক')) {
      return AssetVectorPaths.catBank;
    }
    if (s.contains('grade') || t.contains('grade') || t.contains('গ্রেড')) {
      return AssetVectorPaths.catCap;
    }
    if (s.contains('smprti') ||
        s.contains('affair') ||
        t.contains('সাম্প্রতিক')) {
      return AssetVectorPaths.catCurrentAffairs;
    }
    if (s.contains('university') ||
        t.contains('university') ||
        t.contains('বিশ্ববিদ্যালয়')) {
      return AssetVectorPaths.catUniversity;
    }
    return AssetVectorPaths.catBookRed;
  }

  @override
  Widget build(BuildContext context) {
    final svgString = getCategorySvgString(
      slug: slug,
      title: title,
      themeIcon: themeIcon,
    );

    final isDark = context.isDark;

    final BoxDecoration cardDecoration;
    if (isPremium) {
      cardDecoration = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF251C14),
                  Color(0xFF1E2430),
                ]
              : const [
                  Color(0xFFFFFDF7),
                  Color(0xFFFFF7ED),
                ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: borderColor ??
              (isDark
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.45)
                  : const Color(0xFFFBBF24).withValues(alpha: 0.7)),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(
              alpha: isDark ? 0.20 : 0.12,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.25 : 0.03,
            ),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      );
    } else {
      cardDecoration = BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: borderColor ??
              (isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFF1F5F9)),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.35 : 0.06,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.2 : 0.02,
            ),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: cardDecoration,
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 10.w,
                      right: isPremium ? 28.w : 10.w,
                      top: 4.h,
                      bottom: 4.h,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (isIcon == true) ...[
                          if (isPremium)
                            Container(
                              width: 32.r,
                              height: 32.r,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          const Color(0xFF78350F).withValues(alpha: 0.4),
                                          const Color(0xFF451A03).withValues(alpha: 0.3),
                                        ]
                                      : [
                                          const Color(0xFFFEF3C7),
                                          const Color(0xFFFDE68A),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B).withValues(
                                    alpha: isDark ? 0.4 : 0.5,
                                  ),
                                  width: 0.8,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: _buildIcon(svgString, size: 22.r),
                            )
                          else
                            _buildIcon(svgString, size: 28.r),
                          SizedBox(width: 8.w),
                        ],
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isPremium)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF9F1C),
                          Color(0xFFF77F00),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(11.r),
                        bottomLeft: Radius.circular(8.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF77F00).withValues(alpha: 0.35),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          size: 9.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 1.5.w),
                        Text(
                          "PRO",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 7.5.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String svgString, {required double size}) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: (_, __) => _buildSvgWidget(svgString, size: size),
        errorWidget: (_, __, ___) => _buildSvgWidget(svgString, size: size),
      );
    }
    return _buildSvgWidget(svgString, size: size);
  }

  Widget _buildSvgWidget(String svgString, {required double size}) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.string(
        svgString,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => Icon(
          Icons.school_rounded,
          size: (size * 0.85).sp,
          color: const Color(0xFF006A4E),
        ),
      ),
    );
  }
}
