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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: borderColor ??
                  (context.isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: context.isDark ? 0.35 : 0.06,
                ),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: context.isDark ? 0.2 : 0.02,
                ),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isIcon == true) ...[
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: imageUrl!,
                    width: 28.r,
                    height: 28.r,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => _buildSvgWidget(svgString),
                    errorWidget: (_, __, ___) => _buildSvgWidget(svgString),
                  )
                else
                  _buildSvgWidget(svgString),
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
    );
  }

  Widget _buildSvgWidget(String svgString) {
    return SizedBox(
      width: 28.r,
      height: 28.r,
      child: SvgPicture.string(
        svgString,
        width: 28.r,
        height: 28.r,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => Icon(
          Icons.school_rounded,
          size: 24.sp,
          color: const Color(0xFF006A4E),
        ),
      ),
    );
  }
}
