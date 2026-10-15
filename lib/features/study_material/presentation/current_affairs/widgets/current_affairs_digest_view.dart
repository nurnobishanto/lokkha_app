import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/study_material/presentation/providers/current_affairs_hub_notifier.dart';
import 'package:lokkha/features/study_material/presentation/current_affairs/views/current_affairs_reader_view.dart';

class CurrentAffairsDigestView extends ConsumerStatefulWidget {
  const CurrentAffairsDigestView({super.key});

  @override
  ConsumerState<CurrentAffairsDigestView> createState() =>
      _CurrentAffairsDigestViewState();
}

class _CurrentAffairsDigestViewState extends ConsumerState<CurrentAffairsDigestView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(currentAffairsHubNotifierProvider.notifier);
      final hubState = ref.read(currentAffairsHubNotifierProvider);
      if (hubState.availableMonths.isEmpty) {
        notifier.fetchMonths();
      }
      if (hubState.monthlyDigest == null) {
        notifier.fetchMonthlyDigest();
      }
    });
  }

  Future<void> _openPdf(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openReader({
    required String title,
    int? categoryId,
    required bool withOptions,
  }) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CurrentAffairsReaderView(
          categoryTitle: title,
          categoryId: categoryId,
          withOptions: withOptions,
        ),
      ),
    );
  }

  static String _toBengaliNumber(int number) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final s = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final code = s.codeUnitAt(i);
      if (code >= 48 && code <= 57) {
        buffer.write(bengaliDigits[code - 48]);
      } else {
        buffer.write(s[i]);
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final hubState = ref.watch(currentAffairsHubNotifierProvider);
    final notifier = ref.read(currentAffairsHubNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final digest = hubState.monthlyDigest;

    if (hubState.isDigestLoading && digest == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final months = hubState.availableMonths;
    final activeMonth = hubState.activeDigestMonth ??
        (digest != null && digest.month.isNotEmpty
            ? digest.month
            : (months.isNotEmpty ? months.first.month : ''));
    final format = hubState.digestFormat;
    final isWithOptions = format == 'with_options';

    // Total counts
    final totalCount = digest?.statistics.totalQuestions ??
        (months.any((m) => m.month == activeMonth)
            ? months.firstWhere((m) => m.month == activeMonth).totalQuestions
            : 0);
    final bdCount = digest != null && digest.statistics.bangladesh > 0
        ? digest.statistics.bangladesh
        : (totalCount > 0 ? (totalCount * 0.51).round() : 0);
    final intlCount = digest != null && digest.statistics.international > 0
        ? digest.statistics.international
        : (totalCount - bdCount);

    return RefreshIndicator(
      onRefresh: () async {
        await notifier.fetchMonths();
        await notifier.fetchMonthlyDigest(month: activeMonth, format: format);
      },
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        children: [
          // 1. Month Selector Dropdown (Matching Image 2)
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF059669)),
              SizedBox(width: 6.w),
              Text(
                'মাস নির্বাচন করুন',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFF059669),
                width: 1.5,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: months.any((m) => m.month == activeMonth)
                    ? activeMonth
                    : (months.isNotEmpty ? months.first.month : null),
                isExpanded: true,
                hint: Text(
                  hubState.isMonthsLoading ? 'মাস লোড হচ্ছে...' : 'মাস নির্বাচন করুন',
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                  ),
                ),
                icon: hubState.isMonthsLoading
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                items: months.map((m) {
                  final text = m.display ??
                      '${m.labelBn}${m.labelEn != null ? " (${m.labelEn})" : ""} — ${_toBengaliNumber(m.totalQuestions)}টি';
                  return DropdownMenuItem<String>(
                    value: m.month,
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (newMonth) {
                  if (newMonth != null && newMonth != activeMonth) {
                    HapticFeedback.selectionClick();
                    notifier.fetchMonthlyDigest(month: newMonth, format: format);
                  }
                },
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // 2. Format Selector Dropdown (Matching Image 2)
          Row(
            children: [
              const Icon(Icons.layers_outlined, size: 16, color: Color(0xFF059669)),
              SizedBox(width: 6.w),
              Text(
                'প্রদর্শন ফরম্যাট',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                width: 1.2,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: format,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: const [
                  DropdownMenuItem(
                    value: 'with_options',
                    child: Text(
                      'With Options (MCQ অপশনসহ)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'without_options',
                    child: Text(
                      'Without Options (উত্তরমুক্ত / এক লাইনার)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                onChanged: (newFormat) {
                  if (newFormat != null && newFormat != format) {
                    HapticFeedback.selectionClick();
                    notifier.fetchMonthlyDigest(month: activeMonth, format: newFormat);
                  }
                },
              ),
            ),
          ),

          SizedBox(height: 18.h),

          // 3. Big Green Full Reader Button (Matching Image 2)
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B8A5A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.menu_book_rounded, size: 20),
              label: Text(
                'পড়ুন (Full Reader)',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                _openReader(
                  title: 'মাসিক কারেন্ট অ্যাফেয়ার্স ডাইজেস্ট',
                  withOptions: isWithOptions,
                );
              },
            ),
          ),

          SizedBox(height: 18.h),
          Divider(color: Colors.grey.withOpacity(0.2), height: 1),
          SizedBox(height: 14.h),

          // 4. Statistics Text Row (Matching Image 2)
          Wrap(
            spacing: 12.w,
            runSpacing: 6.h,
            children: [
              RichText(
                text: TextSpan(
                  text: 'মোট প্রশ্ন: ',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                  children: [
                    TextSpan(
                      text: _toBengaliNumber(totalCount),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'বাংলাদেশ বিষয়াবলি: ',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                  children: [
                    TextSpan(
                      text: _toBengaliNumber(bdCount),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'আন্তর্জাতিক বিষয়াবলি: ',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                  children: [
                    TextSpan(
                      text: _toBengaliNumber(intlCount),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // 5. PDF Download Buttons Row (Matching Image 2)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
                    padding: EdgeInsets.symmetric(vertical: 9.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  onPressed: () => _openPdf(digest?.downloads.withoutOptionsPdf),
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: Text(
                    'PDF (Without Options)',
                    style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF059669),
                    side: const BorderSide(color: Color(0xFF059669), width: 1.2),
                    padding: EdgeInsets.symmetric(vertical: 9.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  onPressed: () => _openPdf(digest?.downloads.withOptionsPdf),
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: Text(
                    'PDF (With Options)',
                    style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // 6. Subscription Prompt (if locked)
          if (digest != null && digest.isLocked) ...[
            Container(
              padding: EdgeInsets.all(14.w),
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_rounded, color: Color(0xFFD97706), size: 22),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      digest.subscriptionPrompt?.title ?? 'সম্পূর্ণ ডাইজেস্ট পড়তে সাবস্ক্রিপশন প্রয়োজন',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(Routes.myPackages),
                    child: const Text('সাবস্ক্রাইব', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],

          // 7. Category Navigation Cards (Matching Image 2)
          // 7.1 Red Card: বাংলাদেশ বিষয়াবলি
          _CategoryNavCard(
            title: 'বাংলাদেশ বিষয়াবলি',
            count: bdCount,
            icon: Icons.flag_rounded,
            backgroundColor: const Color(0xFFDC2626),
            textColor: Colors.white,
            badgeBg: Colors.white,
            badgeTextColor: const Color(0xFFDC2626),
            onTap: () {
              _openReader(
                title: 'সাম্প্রতিক বাংলাদেশ বিষয়াবলি',
                categoryId: 5,
                withOptions: isWithOptions,
              );
            },
          ),

          SizedBox(height: 10.h),

          // 7.2 White/Border Card: আন্তর্জাতিক বিষয়াবলি
          _CategoryNavCard(
            title: 'আন্তর্জাতিক বিষয়াবলি',
            count: intlCount,
            icon: Icons.public_rounded,
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            textColor: isDark ? Colors.white : const Color(0xFF0F172A),
            iconColor: const Color(0xFF0284C7),
            badgeBg: const Color(0xFF0F766E),
            badgeTextColor: Colors.white,
            onTap: () {
              _openReader(
                title: 'সাম্প্রতিক আন্তর্জাতিক বিষয়াবলি',
                categoryId: 8,
                withOptions: isWithOptions,
              );
            },
          ),

          SizedBox(height: 10.h),

          // 7.3 White/Border Card: সব বিষয়াবলি
          _CategoryNavCard(
            title: 'সব বিষয়াবলি',
            count: totalCount,
            icon: Icons.layers_rounded,
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            textColor: isDark ? Colors.white : const Color(0xFF0F172A),
            iconColor: const Color(0xFF059669),
            badgeBg: const Color(0xFF64748B),
            badgeTextColor: Colors.white,
            onTap: () {
              _openReader(
                title: 'সকল বিষয়াবলি',
                withOptions: isWithOptions,
              );
            },
          ),

          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}

class _CategoryNavCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color backgroundColor;
  final Color? borderColor;
  final Color textColor;
  final Color? iconColor;
  final Color badgeBg;
  final Color badgeTextColor;
  final VoidCallback onTap;

  const _CategoryNavCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.backgroundColor,
    this.borderColor,
    required this.textColor,
    this.iconColor,
    required this.badgeBg,
    required this.badgeTextColor,
    required this.onTap,
  });

  static String _toBengaliNumber(int number) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final s = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final code = s.codeUnitAt(i);
      if (code >= 48 && code <= 57) {
        buffer.write(bengaliDigits[code - 48]);
      } else {
        buffer.write(s[i]);
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            border: borderColor != null ? Border.all(color: borderColor!, width: 1.2) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 20.sp,
                      color: iconColor ?? textColor,
                    ),
                    SizedBox(width: 10.w),
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Text(
                  _toBengaliNumber(count),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
