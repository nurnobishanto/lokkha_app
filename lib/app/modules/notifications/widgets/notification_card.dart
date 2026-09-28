import 'package:flutter/material.dart';
import 'package:lokkha/config/theme/light_theme_colors.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';

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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isRead
                ? context.cardColor
                : (context.isDark
                    ? context.surfaceColor
                    : LightThemeColors.primaryColor.withValues(alpha: 0.04)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead
                  ? context.borderColor
                  : context.primaryColor.withValues(alpha: 0.3),
              width: 0.8,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///  Icon / Image
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: image != null
                    ? Image.network(
                        image!,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 50,
                        width: 50,
                        color:
                            LightThemeColors.primaryColor.withValues(alpha: .2),
                        child: const Icon(
                          Icons.notifications,
                          color: LightThemeColors.primaryColor,
                        ),
                      ),
              ),

              const SizedBox(width: 12),

              /// Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 15,
                        color: context.textPrimary,
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 13,
                        overflow: TextOverflow.ellipsis,
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      humanTime,
                      style: TextStyle(fontSize: 12, color: context.textMuted),
                    ),
                  ],
                ),
              ),

              ///  Unread dot
              if (!isRead)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  height: 10,
                  width: 10,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
