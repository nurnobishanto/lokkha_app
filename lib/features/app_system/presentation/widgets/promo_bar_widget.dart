import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/services/app_update_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PromoBarWidget extends StatefulWidget {
  static bool isSessionDismissed = false;

  const PromoBarWidget({super.key});

  @override
  State<PromoBarWidget> createState() => _PromoBarWidgetState();
}

class _PromoBarWidgetState extends State<PromoBarWidget> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _updateRemaining();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateRemaining();
      }
    });
  }

  void _updateRemaining() {
    final promoBar = AppUpdateService().appInfo.value?.data.announcements.promoBar;
    if (promoBar == null || promoBar.targetDate.isEmpty) {
      if (_remaining != Duration.zero) {
        setState(() => _remaining = Duration.zero);
      }
      return;
    }

    final target = DateTime.tryParse(promoBar.targetDate);
    if (target != null) {
      final diff = target.difference(DateTime.now());
      final newRemaining = diff.isNegative ? Duration.zero : diff;
      if (newRemaining.inSeconds != _remaining.inSeconds) {
        setState(() => _remaining = newRemaining);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _toBangla(int val) {
    final str = val.toString().padLeft(2, '0');
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String res = str;
    for (int i = 0; i < 10; i++) {
      res = res.replaceAll(en[i], bn[i]);
    }
    return res;
  }

  Widget _buildTimerPill(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Text(
        "$value $label",
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  void _handleAction(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    if (trimmed.startsWith('/')) {
      try {
        Get.toNamed(trimmed);
      } catch (e) {
        debugPrint('[PromoBarWidget] Failed to navigate to $trimmed: $e');
      }
    } else if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      final uri = Uri.tryParse(trimmed);
      if (uri != null && uri.host.contains('lokkha.com')) {
        final pathWithQuery = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
        if (pathWithQuery.isNotEmpty && pathWithQuery.startsWith('/')) {
          try {
            Get.toNamed(pathWithQuery);
            return;
          } catch (e) {
            debugPrint('[PromoBarWidget] Internal route navigation failed: $e');
          }
        }
      }
      try {
        await launchUrlString(trimmed, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('[PromoBarWidget] Failed to launch $trimmed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (PromoBarWidget.isSessionDismissed) return const SizedBox.shrink();

    return Obx(() {
      final promoBar =
          AppUpdateService().appInfo.value?.data.announcements.promoBar;
      if (promoBar == null || !promoBar.enabled) {
        return const SizedBox.shrink();
      }

      final days = _remaining.inDays;
      final hours = _remaining.inHours % 24;
      final minutes = _remaining.inMinutes % 60;
      final seconds = _remaining.inSeconds % 60;

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF063E30), Color(0xFF042B21)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 34, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text and Highlight Header
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${promoBar.text} ",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        if (promoBar.highlight.isNotEmpty)
                          TextSpan(
                            text: promoBar.highlight,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFBBF24),
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Timer & Action Row
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Countdown Timer Pills
                        _buildTimerPill(_toBangla(days), 'দি'),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3),
                          child: Text(
                            ":",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        _buildTimerPill(_toBangla(hours), 'ঘ'),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3),
                          child: Text(
                            ":",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        _buildTimerPill(_toBangla(minutes), 'মি'),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3),
                          child: Text(
                            ":",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        _buildTimerPill(_toBangla(seconds), 'সে'),

                        if (promoBar.buttonText.isNotEmpty) ...[
                          const SizedBox(width: 14),
                          // Action Button
                          GestureDetector(
                            onTap: () => _handleAction(promoBar.url),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBBF24),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    promoBar.buttonText,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: Color(0xFF0F172A),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Close ('X') Button
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    PromoBarWidget.isSessionDismissed = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
