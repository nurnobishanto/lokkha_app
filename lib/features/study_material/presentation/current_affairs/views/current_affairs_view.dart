import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/features/study_material/data/models/current_affairs_v1_models.dart';
import 'package:lokkha/features/study_material/presentation/providers/current_affairs_hub_notifier.dart';
import 'package:lokkha/features/study_material/presentation/current_affairs/widgets/current_affairs_question_card.dart';
import 'package:lokkha/features/study_material/presentation/current_affairs/widgets/current_affairs_digest_view.dart';
import 'package:lokkha/features/study_material/presentation/current_affairs/widgets/current_affairs_shimmer_loader.dart';

class CurrentAffairsView extends ConsumerStatefulWidget {
  const CurrentAffairsView({super.key});

  @override
  ConsumerState<CurrentAffairsView> createState() => _CurrentAffairsViewState();
}

class _CurrentAffairsViewState extends ConsumerState<CurrentAffairsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchOpen = false;

  final List<String> _tabs = [
    'বাংলাদেশ',
    'আন্তর্জাতিক',
    'মাসিক ডাইজেস্ট',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final notifier = ref.read(currentAffairsHubNotifierProvider.notifier);
      final index = _tabController.index;

      if (index == 0) {
        notifier.setCategoryType('bangladesh');
      } else if (index == 1) {
        notifier.setCategoryType('international');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateFilter() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      ref.read(currentAffairsHubNotifierProvider.notifier).setDateFilter(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hubState = ref.watch(currentAffairsHubNotifierProvider);
    final notifier = ref.read(currentAffairsHubNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final isDigestTab = _tabController.index == 2;

    return Scaffold(
      appBar: AppBar(
        title: _isSearchOpen
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'প্রশ্ন, বিষয় বা ট্যাগ অনুসন্ধান করুন...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onSubmitted: (query) {
                  notifier.setSearchQuery(query);
                },
              )
            : const Text(
                'কারেন্ট অ্যাফেয়ার্স ও সাধারণ জ্ঞান',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearchOpen ? Icons.close : Icons.search_rounded, color: Colors.white),
            tooltip: _isSearchOpen ? 'অনুসন্ধান বন্ধ করুন' : 'অনুসন্ধান',
            onPressed: () {
              setState(() {
                if (_isSearchOpen) {
                  _searchController.clear();
                  notifier.setSearchQuery('');
                  _isSearchOpen = false;
                } else {
                  _isSearchOpen = true;
                }
              });
            },
          ),
          if (!isDigestTab)
            IconButton(
              icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
              tooltip: 'তারিখ নির্বাচন',
              onPressed: _pickDateFilter,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          onTap: (index) {
            if (index == 0) {
              notifier.setCategoryType('bangladesh');
            } else if (index == 1) {
              notifier.setCategoryType('international');
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Bangladesh
          _buildFeedView(hubState, notifier, isDark, primaryColor),
          // 2. International
          _buildFeedView(hubState, notifier, isDark, primaryColor),
          // 3. Monthly Digest
          const CurrentAffairsDigestView(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isDigestTab
          ? null
          : _buildFloatingCalendarBar(hubState, notifier, isDark, primaryColor),
    );
  }

  Widget _buildFeedView(
    CurrentAffairsHubState state,
    CurrentAffairsHubNotifier notifier,
    bool isDark,
    Color primaryColor,
  ) {
    if (state.isFeedLoading && state.feedItems.isEmpty && state.dateGroups.isEmpty) {
      return const CurrentAffairsShimmerLoader();
    }

    final hasSelectedDate = state.selectedDate != null && state.selectedDate!.trim().isNotEmpty;
    final hasSelectedMonth = state.selectedMonth != null && state.selectedMonth!.trim().isNotEmpty;
    final hasSearch = state.searchQuery.trim().isNotEmpty;
    final hasActiveFilters = hasSelectedDate || hasSelectedMonth || hasSearch;

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent - 200) {
          if (state.pagination.hasMore &&
              !state.isMoreLoading &&
              !state.isFeedLoading) {
            notifier.fetchFeed(resetPage: false);
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          await notifier.fetchFeed(resetPage: true);
        },
        child: ListView(
          padding: EdgeInsets.only(bottom: 80.h),
        children: [
          // Active Filter Chips
          if (hasActiveFilters) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (hasSelectedDate) ...[
                      _buildActiveFilterChip(
                        label: 'তারিখ: ${state.selectedDate}',
                        onClear: () => notifier.setDateFilter(null),
                        primaryColor: primaryColor,
                      ),
                      SizedBox(width: 8.w),
                    ],
                    if (hasSelectedMonth) ...[
                      _buildActiveFilterChip(
                        label: 'মাস: ${_getMonthDisplay(state)}',
                        onClear: () => notifier.setMonthFilter(null),
                        primaryColor: primaryColor,
                      ),
                      SizedBox(width: 8.w),
                    ],
                    if (hasSearch) ...[
                      _buildActiveFilterChip(
                        label: 'অনুসন্ধান: "${state.searchQuery}"',
                        onClear: () {
                          _searchController.clear();
                          notifier.setSearchQuery('');
                        },
                        primaryColor: primaryColor,
                      ),
                      SizedBox(width: 8.w),
                    ],
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        notifier.clearAllFilters();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.red.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.clear_all_rounded, size: 14.sp, color: Colors.red),
                            SizedBox(width: 4.w),
                            Text(
                              'সব মুছুন',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
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
          ],

          // Top Highlights (if on 'all' tab and no active search)
          if (state.activeType == 'all' &&
              state.searchQuery.isEmpty &&
              state.selectedDate == null &&
              state.latest != null &&
              (state.latest!.bangladesh.isNotEmpty || state.latest!.international.isNotEmpty)) ...[
            _buildHighlightsSection(state.latest!, isDark, primaryColor),
          ],

          // Date-Grouped Questions List or Flat Items List
          if (state.dateGroups.isNotEmpty) ...[
            Builder(
              builder: (context) {
                int globalIndex = 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: state.dateGroups.map((group) {
                    final dateQuestions = group.questions.isNotEmpty
                        ? group.questions
                        : state.feedItems.where((it) => it.date == group.date).toList();
                    final totalDateQuestions = dateQuestions.isNotEmpty
                        ? dateQuestions.length
                        : group.totalQuestions;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Banner with green left accent border (Matching Reader UI)
                        Container(
                          margin: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h, bottom: 8.h),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFD1FAE5),
                              width: 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Container(
                                  width: 4.w,
                                  color: const Color(0xFF10B981),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_month_rounded,
                                          size: 15,
                                          color: Color(0xFF059669),
                                        ),
                                        SizedBox(width: 6.w),
                                        Expanded(
                                          child: Text(
                                            group.dateBn ?? group.dateFormatted ?? group.date,
                                            style: TextStyle(
                                              fontSize: 12.5.sp,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF065F46),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF475569),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Text(
                                            '${_toBengaliNumber(totalDateQuestions)}টি প্রশ্ন',
                                            style: TextStyle(
                                              fontSize: 10.5.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
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

                        // Questions in this Date Group
                        ...dateQuestions.map((q) {
                          globalIndex++;
                          return CurrentAffairsQuestionCard(
                            item: q,
                            serialNumber: globalIndex,
                          );
                        }),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ] else if (state.feedItems.isNotEmpty) ...[
            Builder(
              builder: (context) {
                int globalIndex = 0;
                return Column(
                  children: state.feedItems.map((q) {
                    globalIndex++;
                    return CurrentAffairsQuestionCard(
                      item: q,
                      serialNumber: globalIndex,
                    );
                  }).toList(),
                );
              },
            ),
          ] else ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 48.h),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.feed_outlined, size: 48.sp, color: Colors.grey.withOpacity(0.5)),
                    SizedBox(height: 12.h),
                    Text(
                      'কোনো তথ্য পাওয়া যায়নি',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () => notifier.fetchFeed(resetPage: true),
                      child: const Text('পুনরায় চেষ্টা করুন'),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Pagination Loader or "আরও দেখুন" Button
          if (state.pagination.hasMore)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: state.isMoreLoading
                    ? const CircularProgressIndicator()
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                        ),
                        onPressed: () {
                          notifier.fetchFeed(resetPage: false);
                        },
                        child: const Text('আরও প্রশ্ন দেখুন'),
                      ),
              ),
            ),
        ],
      ),
    ),
    );
  }

  Widget _buildHighlightsSection(
    CurrentAffairsLatestResponse latest,
    bool isDark,
    Color primaryColor,
  ) {
    final allTop = [...latest.bangladesh.take(3), ...latest.international.take(3)];
    if (allTop.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: const Color(0xFFF59E0B), size: 20.sp),
              SizedBox(width: 6.w),
              Text(
                'সাম্প্রতিক গুরুত্বপূর্ণ আপডেট',
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Column(
            children: allTop.map((item) {
              return Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 6.h),
                      width: 5.r,
                      height: 5.r,
                      decoration: BoxDecoration(
                        color: item.category?.type == 'bangladesh'
                            ? const Color(0xFF10B981)
                            : const Color(0xFF0284C7),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        item.displayTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
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

  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onClear,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: onClear,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D5E),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 10, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthDisplay(CurrentAffairsHubState state) {
    if (state.selectedMonth == null || state.selectedMonth!.trim().isEmpty) return '';
    try {
      final match = state.availableMonths.firstWhere(
        (m) => m.value == state.selectedMonth,
      );
      if (match.labelBn.isNotEmpty) return match.labelBn;
      return match.displayTitle;
    } catch (_) {
      return state.selectedMonth!;
    }
  }

  Widget _buildFloatingCalendarBar(
    CurrentAffairsHubState state,
    CurrentAffairsHubNotifier notifier,
    bool isDark,
    Color primaryColor,
  ) {
    final hasDate = state.selectedDate != null && state.selectedDate!.trim().isNotEmpty;
    final hasMonth = state.selectedMonth != null && state.selectedMonth!.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: (hasDate || hasMonth)
              ? primaryColor
              : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          width: 1.2,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
          // 1. Date Action Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24.r),
              onTap: _pickDateFilter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: hasDate ? primaryColor.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 15.sp,
                      color: hasDate ? primaryColor : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      hasDate ? state.selectedDate! : 'তারিখ বাছুন',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: hasDate ? FontWeight.bold : FontWeight.w600,
                        color: hasDate ? primaryColor : (isDark ? Colors.white : const Color(0xFF1E293B)),
                      ),
                    ),
                    if (hasDate) ...[
                      SizedBox(width: 6.w),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          notifier.setDateFilter(null);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 11.sp, color: primaryColor),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Divider
          Container(
            height: 18.h,
            width: 1,
            color: isDark ? Colors.white24 : const Color(0xFFE2E8F0),
            margin: EdgeInsets.symmetric(horizontal: 2.w),
          ),

          // 2. Month Action Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24.r),
              onTap: () => _showMonthPickerSheet(context, state, notifier, isDark, primaryColor),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: hasMonth ? primaryColor.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.date_range_rounded,
                      size: 16.sp,
                      color: hasMonth ? primaryColor : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      hasMonth ? _getMonthDisplay(state) : 'মাস বাছুন',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: hasMonth ? FontWeight.bold : FontWeight.w600,
                        color: hasMonth ? primaryColor : (isDark ? Colors.white : const Color(0xFF1E293B)),
                      ),
                    ),
                    if (hasMonth) ...[
                      SizedBox(width: 6.w),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          notifier.setMonthFilter(null);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 11.sp, color: primaryColor),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showMonthPickerSheet(
    BuildContext context,
    CurrentAffairsHubState state,
    CurrentAffairsHubNotifier notifier,
    bool isDark,
    Color primaryColor,
  ) {
    if (state.availableMonths.isEmpty) {
      notifier.fetchMonths();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Consumer(
          builder: (context, ref, _) {
            final currentState = ref.watch(currentAffairsHubNotifierProvider);
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(sheetCtx).size.height * 0.65,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'মাস নির্বাচন করুন',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        if (currentState.selectedMonth != null && currentState.selectedMonth!.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              notifier.setMonthFilter(null);
                              Navigator.pop(sheetCtx);
                            },
                            child: const Text('ফিল্টার মুছুন', style: TextStyle(color: Colors.red)),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: currentState.availableMonths.isEmpty
                        ? Center(
                            child: currentState.isMonthsLoading
                                ? const CircularProgressIndicator()
                                : const Text('কোন মাস পাওয়া যায়নি'),
                          )
                        : ListView.separated(
                            itemCount: currentState.availableMonths.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                            ),
                            itemBuilder: (context, index) {
                              final m = currentState.availableMonths[index];
                              final isSelected = currentState.selectedMonth == m.value;
                              return ListTile(
                                title: Text(
                                  m.labelBn.isNotEmpty ? m.labelBn : m.displayTitle,
                                  style: TextStyle(
                                    fontSize: 14.5.sp,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected
                                        ? primaryColor
                                        : (isDark ? Colors.white : const Color(0xFF1E293B)),
                                  ),
                                ),
                                subtitle: Text(
                                  '${m.count} টি প্রশ্ন',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                  ),
                                ),
                                trailing: isSelected
                                    ? Icon(Icons.check_circle_rounded, color: primaryColor)
                                    : null,
                                onTap: () {
                                  notifier.setMonthFilter(m.value);
                                  Navigator.pop(sheetCtx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
