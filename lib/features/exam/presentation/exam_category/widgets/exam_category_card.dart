import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  /// Zero-size Material Icon fallback when backend `image_url` is null/empty or loading.
  static IconData getFallbackIconData({
    String? slug,
    String? title,
    String? themeIcon,
  }) {
    final s = (slug ?? '').toLowerCase();
    final t = (title ?? '').toLowerCase();

    if (s.contains('bcs') || t.contains('bcs')) {
      return Icons.menu_book_rounded;
    }
    if (s.contains('primary') ||
        s.contains('praimari') ||
        t.contains('primary') ||
        t.contains('প্রাইমারি')) {
      return Icons.auto_stories_rounded;
    }
    if (s.contains('ntrca') ||
        s.contains('nibndhn') ||
        t.contains('ntrca') ||
        t.contains('নিবন্ধন') ||
        t.contains('শিক্ষক')) {
      return Icons.military_tech_rounded;
    }
    if (s.contains('bank') || t.contains('bank') || t.contains('ব্যাংক')) {
      return Icons.account_balance_rounded;
    }
    if (s.contains('grade') || t.contains('grade') || t.contains('গ্রেড')) {
      return Icons.school_rounded;
    }
    if (s.contains('smprti') ||
        s.contains('affair') ||
        t.contains('সাম্প্রতিক')) {
      return Icons.event_note_rounded;
    }
    if (s.contains('university') ||
        t.contains('university') ||
        t.contains('বিশ্ববিদ্যালয়')) {
      return Icons.emoji_events_rounded;
    }

    switch (themeIcon) {
      case 'ri-book-open-fill':
        return Icons.menu_book_rounded;
      case 'ri-award-fill':
        return Icons.military_tech_rounded;
      case 'ri-medal-fill':
        return Icons.workspace_premium_rounded;
      case 'ri-graduation-cap-fill':
        return Icons.school_rounded;
      case 'ri-trophy-fill':
        return Icons.emoji_events_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallbackIcon = getFallbackIconData(
      slug: slug,
      title: title,
      themeIcon: themeIcon,
    );
    final palette = _getCategoryPalette(
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
              ? [
                  palette.primary.withValues(alpha: 0.18),
                  const Color(0xFF1E293B),
                ]
              : palette.cardGradientLight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: borderColor ??
              (isDark
                  ? palette.primary.withValues(alpha: 0.5)
                  : palette.borderLight),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(
              alpha: isDark ? 0.20 : 0.10,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.25 : 0.02,
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
                              width: 36.r,
                              height: 36.r,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          palette.primary.withValues(alpha: 0.30),
                                          palette.primary.withValues(alpha: 0.18),
                                        ]
                                      : palette.iconBoxGradientLight,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: palette.primary.withValues(
                                    alpha: isDark ? 0.45 : 0.38,
                                  ),
                                  width: 0.8,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: _buildIcon(
                                fallbackIcon,
                                size: 24.r,
                                effectiveIconColor: iconColor ?? palette.primary,
                              ),
                            )
                          else
                            _buildIcon(
                              fallbackIcon,
                              size: 26.r,
                              effectiveIconColor:
                                  iconColor ?? const Color(0xFF006A4E),
                            ),
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

  Widget _buildIcon(
    IconData fallbackIcon, {
    required double size,
    required Color effectiveIconColor,
  }) {
    final fallbackWidget = _buildFallbackIcon(
      fallbackIcon,
      size: size,
      color: effectiveIconColor,
    );
    final resolvedUrl = Endpoints.resolveImageUrl(imageUrl);
    if (resolvedUrl.isNotEmpty) {
      final uri = Uri.tryParse(resolvedUrl);
      final isSvg = (uri?.path.toLowerCase().endsWith('.svg') ?? false) ||
          resolvedUrl.toLowerCase().split('?').first.endsWith('.svg');

      if (isSvg) {
        return _NetworkSvgIcon(
          url: resolvedUrl,
          size: size,
          fallback: fallbackWidget,
        );
      }

      // Supports PNG, JPG, JPEG, WEBP, GIF, BMP, and falls back to SVG check if extensionless SVG
      return SizedBox(
        width: size,
        height: size,
        child: CachedNetworkImage(
          imageUrl: resolvedUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          placeholder: (_, __) => fallbackWidget,
          errorWidget: (_, __, ___) => _NetworkSvgIcon(
            url: resolvedUrl,
            size: size,
            fallback: fallbackWidget,
          ),
        ),
      );
    }
    return fallbackWidget;
  }

  Widget _buildFallbackIcon(
    IconData iconData, {
    required double size,
    required Color color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Icon(
          iconData,
          size: size,
          color: color,
        ),
      ),
    );
  }

  static _CategoryPalette _getCategoryPalette({
    String? slug,
    String? title,
    String? themeIcon,
  }) {
    final s = (slug ?? '').toLowerCase();
    final t = (title ?? '').toLowerCase();

    // 1. BCS -> Royal Blue / Indigo
    if (s.contains('bcs') || t.contains('bcs')) {
      return const _CategoryPalette(
        primary: Color(0xFF2563EB),
        cardGradientLight: [Color(0xFFF8FAFF), Color(0xFFEFF6FF)],
        borderLight: Color(0xFF93C5FD),
        iconBoxGradientLight: [Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
      );
    }

    // 2. Primary -> Emerald / Teal
    if (s.contains('primary') ||
        s.contains('praimari') ||
        t.contains('primary') ||
        t.contains('প্রাইমারি')) {
      return const _CategoryPalette(
        primary: Color(0xFF0D9488),
        cardGradientLight: [Color(0xFFF6FEFC), Color(0xFFE6FFFA)],
        borderLight: Color(0xFF5EEAD4),
        iconBoxGradientLight: [Color(0xFFCCFBF1), Color(0xFF99F6E4)],
      );
    }

    // 3. NTRCA / Teacher -> Violet / Purple
    if (s.contains('ntrca') ||
        s.contains('nibndhn') ||
        t.contains('ntrca') ||
        t.contains('নিবন্ধন') ||
        t.contains('শিক্ষক')) {
      return const _CategoryPalette(
        primary: Color(0xFF7C3AED),
        cardGradientLight: [Color(0xFFFAF8FF), Color(0xFFF3E8FF)],
        borderLight: Color(0xFFC4B5FD),
        iconBoxGradientLight: [Color(0xFFEDE9FE), Color(0xFFDDD6FE)],
      );
    }

    // 4. Bank Preparation -> Warm Amber / Orange
    if (s.contains('bank') || t.contains('bank') || t.contains('ব্যাংক')) {
      return const _CategoryPalette(
        primary: Color(0xFFD97706),
        cardGradientLight: [Color(0xFFFFFDF7), Color(0xFFFFF7ED)],
        borderLight: Color(0xFFFCD34D),
        iconBoxGradientLight: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
      );
    }

    // 5. 11-20 Grade -> Rose / Crimson
    if (s.contains('11-20') || t.contains('11-20')) {
      return const _CategoryPalette(
        primary: Color(0xFFE11D48),
        cardGradientLight: [Color(0xFFFFF8F9), Color(0xFFFFE4E6)],
        borderLight: Color(0xFFFDA4AF),
        iconBoxGradientLight: [Color(0xFFFFE4E6), Color(0xFFFECDD3)],
      );
    }

    // 6. 9-10 Grade / Other Grades -> Sky / Cyan
    if (s.contains('grade') || t.contains('grade') || t.contains('গ্রেড')) {
      return const _CategoryPalette(
        primary: Color(0xFF0284C7),
        cardGradientLight: [Color(0xFFF5FBFF), Color(0xFFE0F2FE)],
        borderLight: Color(0xFF7DD3FC),
        iconBoxGradientLight: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
      );
    }

    // 7. University Admission -> Fuchsia / Deep Purple
    if (s.contains('university') ||
        t.contains('university') ||
        t.contains('বিশ্ববিদ্যালয়')) {
      return const _CategoryPalette(
        primary: Color(0xFF9333EA),
        cardGradientLight: [Color(0xFFFDF8FF), Color(0xFFFAE8FF)],
        borderLight: Color(0xFFE879F9),
        iconBoxGradientLight: [Color(0xFFFAE8FF), Color(0xFFF5D0FE)],
      );
    }

    // Default -> Warm Amber
    return const _CategoryPalette(
      primary: Color(0xFFD97706),
      cardGradientLight: [Color(0xFFFFFDF7), Color(0xFFFFF7ED)],
      borderLight: Color(0xFFFCD34D),
      iconBoxGradientLight: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
    );
  }
}

class _CategoryPalette {
  final Color primary;
  final List<Color> cardGradientLight;
  final Color borderLight;
  final List<Color> iconBoxGradientLight;

  const _CategoryPalette({
    required this.primary,
    required this.cardGradientLight,
    required this.borderLight,
    required this.iconBoxGradientLight,
  });
}

class _NetworkSvgIcon extends StatefulWidget {
  final String url;
  final double size;
  final Widget fallback;

  const _NetworkSvgIcon({
    required this.url,
    required this.size,
    required this.fallback,
  });

  static final Map<String, String> _svgCache = {};

  @override
  State<_NetworkSvgIcon> createState() => _NetworkSvgIconState();
}

class _NetworkSvgIconState extends State<_NetworkSvgIcon> {
  String? _svgContent;

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  @override
  void didUpdateWidget(covariant _NetworkSvgIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _svgContent = null;
      _loadSvg();
    }
  }

  Future<void> _loadSvg() async {
    final cached = _NetworkSvgIcon._svgCache[widget.url];
    if (cached != null) {
      if (mounted) {
        setState(() => _svgContent = cached);
      }
      return;
    }

    try {
      final uri = Uri.tryParse(widget.url);
      if (uri == null) return;

      final client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        if (body.contains('<svg')) {
          _NetworkSvgIcon._svgCache[widget.url] = body;
          if (mounted) {
            setState(() => _svgContent = body);
          }
        }
      }
    } catch (_) {
      // Fallback icon will remain displayed
    }
  }

  @override
  Widget build(BuildContext context) {
    final svg = _svgContent;
    if (svg != null && svg.isNotEmpty) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: SvgPicture.string(
          svg,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => widget.fallback,
          errorBuilder: (_, __, ___) => widget.fallback,
        ),
      );
    }
    return widget.fallback;
  }
}
