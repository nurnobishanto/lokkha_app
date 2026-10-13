import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable SVG image widget that cleanly renders vector assets,
/// network SVGs, and raw SVG strings with built-in loading and error fallbacks.
class AppSvgImage extends StatelessWidget {
  final String? path;
  final String? svgString;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final ColorFilter? colorFilter;
  final AlignmentGeometry alignment;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? semanticsLabel;

  /// Default constructor: renders SVG from local asset or network URL based on path prefix.
  const AppSvgImage(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.colorFilter,
    this.alignment = Alignment.center,
    this.placeholder,
    this.errorWidget,
    this.semanticsLabel,
  }) : svgString = null;

  /// Asset constructor explicitly for local SVG assets.
  const AppSvgImage.asset(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.colorFilter,
    this.alignment = Alignment.center,
    this.placeholder,
    this.errorWidget,
    this.semanticsLabel,
  }) : svgString = null;

  /// Network constructor explicitly for remote SVG files.
  const AppSvgImage.network(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.colorFilter,
    this.alignment = Alignment.center,
    this.placeholder,
    this.errorWidget,
    this.semanticsLabel,
  }) : svgString = null;

  /// String constructor for in-memory SVG strings.
  const AppSvgImage.string(
    this.svgString, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.colorFilter,
    this.alignment = Alignment.center,
    this.placeholder,
    this.errorWidget,
    this.semanticsLabel,
  }) : path = null;

  ColorFilter? _effectiveColorFilter() {
    if (colorFilter != null) return colorFilter;
    if (color != null) {
      return ColorFilter.mode(color!, BlendMode.srcIn);
    }
    return null;
  }

  Widget _defaultErrorWidget() {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.grey.shade400,
          size: (width != null && height != null)
              ? (width! < height! ? width! * 0.5 : height! * 0.5)
              : 24,
        ),
      ),
    );
  }

  Widget _defaultPlaceholder(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = _effectiveColorFilter();

    if (svgString != null && svgString!.isNotEmpty) {
      return SvgPicture.string(
        svgString!,
        width: width,
        height: height,
        fit: fit,
        colorFilter: filter,
        alignment: alignment,
        semanticsLabel: semanticsLabel,
      );
    }

    if (path != null && path!.isNotEmpty) {
      final isNetwork = path!.startsWith('http://') || path!.startsWith('https://');
      if (isNetwork) {
        return SvgPicture.network(
          path!,
          width: width,
          height: height,
          fit: fit,
          colorFilter: filter,
          alignment: alignment,
          semanticsLabel: semanticsLabel,
          placeholderBuilder: (ctx) => placeholder ?? _defaultPlaceholder(ctx),
        );
      } else {
        return SvgPicture.asset(
          path!,
          width: width,
          height: height,
          fit: fit,
          colorFilter: filter,
          alignment: alignment,
          semanticsLabel: semanticsLabel,
          placeholderBuilder: (ctx) => placeholder ?? _defaultPlaceholder(ctx),
        );
      }
    }

    return errorWidget ?? _defaultErrorWidget();
  }
}
