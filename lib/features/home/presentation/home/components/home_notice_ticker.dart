import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';

class HomeNoticeTicker extends StatefulWidget {
  final String noticeText;

  const HomeNoticeTicker({
    super.key,
    required this.noticeText,
  });

  @override
  State<HomeNoticeTicker> createState() => _HomeNoticeTickerState();
}

class _HomeNoticeTickerState extends State<HomeNoticeTicker> {
  late final ScrollController _scrollController;
  Timer? _scrollTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleScrolling());
  }

  void _scheduleScrolling() {
    if (_isDisposed || !mounted) return;
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(milliseconds: 1500), () => _startScrolling());
  }

  void _startScrolling() async {
    if (_isDisposed || !mounted || !_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    final duration =
        Duration(milliseconds: (maxScroll * 40).toInt().clamp(3000, 30000));

    try {
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          maxScroll,
          duration: duration,
          curve: Curves.linear,
        );
      }
      if (_isDisposed || !mounted) return;
      _scrollTimer?.cancel();
      _scrollTimer = Timer(const Duration(milliseconds: 1000), () {
        if (_scrollController.hasClients && !_isDisposed) {
          _scrollController.jumpTo(0.0);
          _scheduleScrolling();
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.noticeText.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: context.primaryColor.withOpacity(0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: context.primaryColor,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.campaign_rounded,
                  color: Colors.white,
                  size: 14.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  'নোটিশ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Text(
                widget.noticeText,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w500,
                  color: context.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
