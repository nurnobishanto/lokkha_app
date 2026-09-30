import 'package:flutter/material.dart';

import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/core/core.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateView extends StatelessWidget {
  final Uri url;
  final String? title;
  final String? message;
  final String? currentVersion;
  final String? latestVersion;

  const AppUpdateView({
    required this.url,
    this.title,
    this.message,
    this.currentVersion,
    this.latestVersion,
    super.key,
  });

  String _formatVersion(String? v) {
    if (v == null) return '';
    final trimmed = v.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.toLowerCase().startsWith('v') ? trimmed : 'v$trimmed';
  }

  @override
  Widget build(BuildContext context) {
    final curVer = (currentVersion != null && currentVersion!.isNotEmpty)
        ? currentVersion!
        : (appVersion.value.isNotEmpty ? appVersion.value : '2.03.12');
    final latVer = (latestVersion != null && latestVersion!.isNotEmpty)
        ? latestVersion!
        : (AppUpdateService().appInfo.value?.data.clientVersionCheck?.latestVersionName.isNotEmpty == true
            ? AppUpdateService().appInfo.value!.data.clientVersionCheck!.latestVersionName
            : (AppUpdateService().appInfo.value?.data.versions.android.latestVersionName.isNotEmpty == true
                ? AppUpdateService().appInfo.value!.data.versions.android.latestVersionName
                : ''));

    final formattedCurrent = _formatVersion(curVer);
    final formattedLatest = _formatVersion(latVer);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              // App icon
              CircleAvatar(
                radius: 50,
                backgroundColor: context.cardColor,
                child: Center(
                  child: Image.asset(
                    AssetImagePaths.appIcon,
                    width: 80,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                title ?? "New Version Available",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitles
              Text(
                message ??
                    "নিরবচ্ছিন্ন সেবা ও নতুন ফিচার উপভোগ করতে অনুগ্রহ করে অ্যাপটি এখনই আপডেট করে নিন।",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: context.textSecondary,
                  height: 1.5,
                ),
              ),
              // Current & Latest Version Badges
              if (formattedCurrent.isNotEmpty || formattedLatest.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: context.surfaceSubtle,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.borderColor.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (formattedCurrent.isNotEmpty) ...[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Current Version",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: context.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedCurrent,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (formattedCurrent.isNotEmpty && formattedLatest.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: context.primaryColor,
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (formattedLatest.isNotEmpty) ...[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Latest Version",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: context.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedLatest,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: context.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 48),
              // Update button
              SizedBox(
                height: 52.0,
                child: CustomActionButton(
                  text: "আপডেট করুন",
                  onPressed: () async {
                    // url lunch
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
