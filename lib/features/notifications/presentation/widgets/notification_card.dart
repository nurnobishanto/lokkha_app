import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/network/endpoints.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final String? image;
  final bool isRead;
  final String humanTime;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.title,
    required this.body,
    this.image,
    required this.isRead,
    required this.humanTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String? resolvedImageUrl =
        image != null && image!.isNotEmpty ? Endpoints.resolveUrl(image) : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: isRead
                ? context.cardColor
                : (context.isDark
                    ? const Color(0xFF006A4E).withOpacity(0.12)
                    : const Color(0xFF006A4E).withOpacity(0.04)),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isRead
                  ? context.borderColor.withOpacity(0.6)
                  : const Color(0xFF006A4E).withOpacity(0.35),
              width: isRead ? 0.8 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Icon / Avatar / Image
              ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: resolvedImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: resolvedImageUrl,
                        height: 46.r,
                        width: 46.r,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          height: 46.r,
                          width: 46.r,
                          color: const Color(0xFF006A4E).withOpacity(0.1),
                          child: const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => _buildFallbackIcon(context),
                      )
                    : _buildFallbackIcon(context),
              ),

              SizedBox(width: 12.w),

              /// Content (Title, Body, Human Time)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              color: context.textPrimary,
                              fontWeight:
                                  isRead ? FontWeight.w500 : FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                        ),
                        if (!isRead) ...[
                          SizedBox(width: 6.w),
                          Container(
                            margin: EdgeInsets.only(top: 4.h),
                            height: 8.r,
                            width: 8.r,
                            decoration: const BoxDecoration(
                              color: Color(0xFF006A4E),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: context.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    if (humanTime.isNotEmpty) ...[
                      SizedBox(height: 5.h),
                      Text(
                        humanTime,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: context.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(BuildContext context) {
    return Container(
      height: 46.r,
      width: 46.r,
      decoration: BoxDecoration(
        color: isRead
            ? context.borderColor.withOpacity(0.25)
            : const Color(0xFF006A4E).withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.notifications_rounded,
        size: 24.sp,
        color: isRead ? context.textSecondary : const Color(0xFF006A4E),
      ),
    );
  }
}
